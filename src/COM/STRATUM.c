/* *****************************************************************************
**
**                       Standalone bitcoin miner
**
** Project      : User Interface manager
** Module       : stratum.c
**
** Description  : stratum protocol specific module
**
** ************************************************************************** */

/* *****************************************************************************
**  REVISION HISTORY
** Date         Inits   Description
** ----------------------------------------------------------------------------
** 28.05.17     bd      [no issue number] File creation
**
** ************************************************************************** */

/* *****************************************************************************
**                          SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "Macros.h" /* Divers macros definitions */
#include "Types.h"  /* Legacy types definitions */

#include <stdio.h>    /* Standard IO defns */
#include <stdlib.h>   /* Standard lib C defns */
#include <string.h>   /* String defns */
#include <stdint.h>   /* Integer defns */
#include <unistd.h>   /* Types defns */
#include <sys/time.h> /* Time defns */
#include <time.h>     /* More time defns */
#include <math.h>     /* Math defns for stats */

/* Thread mangement */
#include <pthread.h>  /* posix thread defns */

/* TCP/IP Stack */
#include <sys/socket.h>  /*  */
#include <sys/types.h>   /*  */
#include <netinet/in.h>  /*  */
#include <netinet/tcp.h> /*  */
#include <netdb.h>       /*  */
#if 0
#include <jansson.h>     /* JSON serialization */
#endif

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "COM_Mgr.h" /* Manager defns */

#include "STRATUM.h" /* Module specific defns */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
#define NUM_COM_CLIENT (1)      /* number of running client simultaneously */
#define NUM_POOLS (6)           /* number of pool used */
#define RBUFSIZE (8192)         /* receive buffer size */
#define RECVSIZE (RBUFSIZE - 4) /* receive buffer size minor header */

/* Status to be used in that module */
typedef enum
{
    eSTRATUM_CNX_SUCCESS=0,
    eSTRATUM_CNX_PENDING,
    eSTRATUM_CNX_TIMEOUT,
    eSTRATUM_CNX_FAIL,
    eSTRATUM_MSG_TXING,
    eSTRATUM_MSG_RXING,
    eSTRATUM_MSG_TIMEOUT,
    eSTRATUM_MSG_ERR

}eSTRATUM_Status_t;

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */
typedef qword SOCKTYPE;

typedef struct
{
    const char * const abyUrl;  /* char - avoid signedness compiler warnings */
    const char * const abyPort;

} stSTRATUM_Urls_t;

typedef struct  {
    byte *pbyJobId;
    byte **pabyMerkleBin;
    boolean bClean;
    dword dwDiff;

} stSTRATUM_work_t;

typedef struct {
    struct timeval stTimeLastwork;
    byte *abyJsonReq;
    byte *abyJsonUrl;
    byte *abyJsonUserPass;
    byte *abyJsonUserUser;
    byte *abyJsonPass;

    stSTRATUM_work_t stSwork;
    byte byPoolIdx;
    byte byPoolPrio;

    /* - Stratum variables, No proxy for the time being - */
    byte *abyStratumUrl;  /* The pool URL */
    byte *abyStratumPort; /* String version of the port */
    dword dwStratumPort;  /* Integer version of the port */
    SOCKTYPE sSocket;
    size_t SockBufSize;
    byte *abySockBuf;
    byte *abySessionId;
    byte abyPrevBlock[32]; /* The last block this particular pool knows about */
    struct addrinfo *pstServInfo;
    struct addrinfo stServHints;

    /* -- Rx stuff -- */
    byte abyRecvBuf[RBUFSIZE];

    /* -- Tx stuff -- */
    word wTxReqLen;
    byte abyTxBuf[RBUFSIZE];

    /* -  Mining variables - */
    byte *abyNonce1;
    byte *abyNonce1bin;
    qword qwNonce2;
    word wN2size;
    boolean bHasStratum;
    boolean bStratumActive;
    boolean bStratumInit;
    boolean bstratumNotify;

} stSTRATUM_Pool_t;

typedef struct  {

} stSTRATUM_Data_t;

/* *****************************************************************************
**                                 GLOBALS
** ************************************************************************** */

/* *****************************************************************************
**                                 LOCALS
** ************************************************************************** */
/* Pool informations */
static const stSTRATUM_Urls_t astSTRATUM_Urls[NUM_POOLS]=
{
    /* Europe and North America */
    { "us-east.stratum.slushpool.com", "3333" },
    { "eu.stratum.slushpool.com", "3333" },
    /* Asia */
    { "stratum.f2pool.com", "3333" },
    { "cn.stratum.slushpool.com", "3333" },
    { "cn.stratum.slushpool.com", "443" },
    { "sg.stratum.slushpool.com", "3333" }

};

static stSTRATUM_Pool_t astSTRATUM_Pools[NUM_POOLS];

/* Local data */
static stSTRATUM_Data_t stLocalData;

/* *****************************************************************************
**                              LOCALS ROUTINES
** ************************************************************************** */
#if 0
static eSTRATUM_Status_t Authenticate(void);
static eSTRATUM_Status_t Tx( const byte* const abyData,const dword const dwLength, const stSTRATUM_Pool_t * pstPool );
static eSTRATUM_Status_t Rx( byte* const abyData,dword dwLength, const stSTRATUM_Pool_t * pstPool );
static eSTRATUM_Status_t CnxClient(void);
#endif

static void ResetData(void);

/* *****************************************************************************
**                                  API
** ************************************************************************** */

/* ************************************************************************** */
eCOM_Mgr_Status_t STRATUM_Ptcl_Setup(void)
/* **************************************************************************
** Input  : -
** Output : -
** Return : -
**
** Description  : Initialise data. Pools, thread attr and all the rest.
**
** ************************************************************************** */
{
    eCOM_Mgr_Status_t eRetVal;
    dword dwIndex;

    /* Pessimist assumption */
    eRetVal = eSTRATUM_CNX_FAIL;

    /* Reset module's data */
    ResetData();

    /* Setup pools */
    for( dwIndex = 0; dwIndex < NUM_POOLS; dwIndex++ )
    {
        memset( (void*)&astSTRATUM_Pools[dwIndex],
                0x00,
                sizeof(stSTRATUM_Pool_t) );

        /* Server infos */
        astSTRATUM_Pools[dwIndex].abyStratumUrl = (byte*)astSTRATUM_Urls[dwIndex].abyUrl;
        astSTRATUM_Pools[dwIndex].abyStratumPort = (byte*)astSTRATUM_Urls[dwIndex].abyPort;

        astSTRATUM_Pools[dwIndex].stServHints.ai_family = AF_UNSPEC;
        astSTRATUM_Pools[dwIndex].stServHints.ai_socktype = SOCK_STREAM;

    }

    /* Most important, setup threads and support the kids ! */

    return eRetVal;
}

/* ************************************************************************** */
eCOM_Mgr_Status_t STRATUM_Ptcl_Init(void)
/* **************************************************************************
** Input  : -
** Output : -
** Return : -
**
** Description  : Initialise sockets. Kick off threads/connections
**
** ************************************************************************** */
{
    struct addrinfo *pstAddrInfo;
    int swork_id;
    ssize_t ssent = 0;
    dword dwIndex;
    struct timeval timeout = {1, 0};
    ssize_t sent;
    fd_set wd;
    ssize_t n;

    /* Local initialization */
    swork_id=1;

    for( dwIndex = 0; dwIndex < NUM_POOLS; dwIndex++ )
    {
        /* Get server info, prepare connection */
        if ( 0  == getaddrinfo( (const char*)astSTRATUM_Pools[dwIndex].abyStratumUrl,
                                (const char*)astSTRATUM_Pools[dwIndex].abyStratumPort,
                                &astSTRATUM_Pools[dwIndex].stServHints,
                                &astSTRATUM_Pools[dwIndex].pstServInfo )
           )
        {
            for ( pstAddrInfo = astSTRATUM_Pools[dwIndex].pstServInfo; NULL != pstAddrInfo ; pstAddrInfo = pstAddrInfo->ai_next )
            {
                /* Create socket */
                astSTRATUM_Pools[dwIndex].sSocket = socket( pstAddrInfo->ai_family,
                                                            pstAddrInfo->ai_socktype,
                                                            pstAddrInfo->ai_protocol );

                /* Verify socket status */
                if ( -1 != astSTRATUM_Pools[dwIndex].sSocket )
                {
                    /* Iterate non blocking over entries returned by getaddrinfo
                     * to cope with round robin DNS entries, finding the first one
                     * we can connect to quickly. */
                    if ( -1 != connect( astSTRATUM_Pools[dwIndex].sSocket, pstAddrInfo->ai_addr, pstAddrInfo->ai_addrlen ) )
                    {
                        /* Formulate request to stratum server */
                        sprintf((char*)astSTRATUM_Pools[dwIndex].abyTxBuf, "{\"id\": %d, \"method\": \"mining.subscribe\", \"params\": []}", swork_id++);

                        /* Important ! */
                        strcat((char*)astSTRATUM_Pools[dwIndex].abyTxBuf, "\n");

                        astSTRATUM_Pools[dwIndex].wTxReqLen = strlen((char*)astSTRATUM_Pools[dwIndex].abyTxBuf);

                        while ( 0 < astSTRATUM_Pools[dwIndex].wTxReqLen  )
                        {
                            FD_ZERO(&wd);
                            FD_SET(astSTRATUM_Pools[dwIndex].sSocket, &wd);
                            if (select((astSTRATUM_Pools[dwIndex].sSocket + 1), NULL, &wd, NULL, &timeout) < 1)
                            {
                                printf("Send select failed\n");
                            }
                            else
                            {
                                printf("Select send success\n");
                            }

                            sent = send(astSTRATUM_Pools[dwIndex].sSocket, astSTRATUM_Pools[dwIndex].abyTxBuf + astSTRATUM_Pools[dwIndex].wTxReqLen, astSTRATUM_Pools[dwIndex].wTxReqLen, MSG_NOSIGNAL);

                            if (sent < 0) {
                                sent = 0;
                            }
                            ssent += sent;
                            astSTRATUM_Pools[dwIndex].wTxReqLen -= sent;
                        }

                        /* Now receive */
                        do {
                            n = recv(astSTRATUM_Pools[dwIndex].sSocket, astSTRATUM_Pools[dwIndex].abyRecvBuf, RECVSIZE, 0);

                            if (!n)
                            {
                                printf("Socket closed waiting in recv_line\n");
                            }

                            printf("recv_line : %s\n",astSTRATUM_Pools[dwIndex].abyRecvBuf);

                            if(!strstr((char*)astSTRATUM_Pools[dwIndex].abyRecvBuf, "\n"))
                            {
                                break;
                            }

                        } while (1);

                        break;
                    }
                }
            }
        }

        /* Need to obtain session Id now ... */

    }

    pthread_exit(NULL);
}

void STRATUM_Ptcl_Bkgnd(void)
{
    /* Nothing to do for the time being */
}

/* *****************************************************************************
**                            LOCALS ROUTINES Defn
** ************************************************************************** */
#if 0
void CnxSockInit(void)
{

}

void CnxClient(void)
{
    /* Nothing to do for the time being */
}

/* Authentication */
bool auth_stratum(struct pool *pool)
{
    json_t *val = NULL, *res_val, *err_val;
    char s[RBUFSIZE], *sret = NULL;
    json_error_t err;
    bool ret = false;

    sprintf(s, "{\"id\": %d, \"method\": \"mining.authorize\", \"params\": [\"%s\", \"%s\"]}",
        swork_id++, pool->rpc_user, pool->rpc_pass);

    if (!stratum_send(pool, s, strlen(s)))
        return ret;

    /* Parse all data in the queue and anything left should be auth */
    while (42) {
        sret = recv_line(pool);
        if (!sret)
            return ret;
        if (parse_method(pool, sret))
            free(sret);
        else
            break;
    }

    val = JSON_LOADS(sret, &err);
    free(sret);
    res_val = json_object_get(val, "result");
    err_val = json_object_get(val, "error");

    if (!res_val || json_is_false(res_val) || (err_val && !json_is_null(err_val)))  {
        char *ss;

        if (err_val)
            ss = json_dumps(err_val, JSON_INDENT(3));
        else
            ss = strdup("(unknown reason)");
        applog(LOG_INFO, "pool %d JSON stratum auth failed: %s", pool->pool_no, ss);
        free(ss);

        suspend_stratum(pool);

        goto out;
    }

    ret = true;
    applog(LOG_INFO, "Stratum authorisation success for pool %d", pool->pool_no);
    pool->probed = true;
    successful_connect = true;

    if (opt_suggest_diff) {
        sprintf(s, "{\"id\": %d, \"method\": \"mining.suggest_difficulty\", \"params\": [%d]}",
            swork_id++, opt_suggest_diff);
        stratum_send(pool, s, strlen(s));
    }
out:
    json_decref(val);
    return ret;
}
#endif


/* TX  */
#if 0
bool stratum_send(struct pool *pool, char *s, ssize_t len)
{
    enum send_ret ret = SEND_INACTIVE;

    if (opt_protocol)
        applog(LOG_DEBUG, "SEND: %s", s);

    mutex_lock(&pool->stratum_lock);
    if (pool->stratum_active)
        ret = __stratum_send(pool, s, len);
    mutex_unlock(&pool->stratum_lock);

    /* This is to avoid doing applog under stratum_lock */
    switch (ret) {
        default:
        case SEND_OK:
            break;
        case SEND_SELECTFAIL:
            applog(LOG_DEBUG, "Write select failed on pool %d sock", pool->pool_no);
            suspend_stratum(pool);
            break;
        case SEND_SENDFAIL:
            applog(LOG_DEBUG, "Failed to send in stratum_send");
            suspend_stratum(pool);
            break;
        case SEND_INACTIVE:
            applog(LOG_DEBUG, "Stratum send failed due to no pool stratum_active");
            break;
    }
    return (ret == SEND_OK);
}

static enum send_ret __stratum_send(struct pool *pool, char *s, ssize_t len)
{
    SOCKETTYPE sock = pool->sock;
    ssize_t ssent = 0;

    strcat(s, "\n");
    len++;

    while (len > 0 ) {
        struct timeval timeout = {1, 0};
        ssize_t sent;
        fd_set wd;
retry:
        FD_ZERO(&wd);
        FD_SET(sock, &wd);
        if (select(sock + 1, NULL, &wd, NULL, &timeout) < 1) {
            if (interrupted())
                goto retry;
            return SEND_SELECTFAIL;
        }
#ifdef __APPLE__
        sent = send(pool->sock, s + ssent, len, SO_NOSIGPIPE);
#elif WIN32
        sent = send(pool->sock, s + ssent, len, 0);
#else
        sent = send(pool->sock, s + ssent, len, MSG_NOSIGNAL);
#endif
        if (sent < 0) {
            if (!sock_blocks())
                return SEND_SENDFAIL;
            sent = 0;
        }
        ssent += sent;
        len -= sent;
    }

    pool->cgminer_pool_stats.times_sent++;
    pool->cgminer_pool_stats.bytes_sent += ssent;
    pool->cgminer_pool_stats.net_bytes_sent += ssent;
    return SEND_OK;
}
#endif

/* RX */
#if 0

#endif

static void ResetData(void)
{
    memset((void*)&stLocalData,0x00,sizeof(stSTRATUM_Data_t));
    return;
}
