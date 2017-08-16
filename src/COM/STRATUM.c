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

static pthread_t astSTRATUM_Th_Id[NUM_POOLS];
static pthread_attr_t astSTRATUM_Th_Attr[NUM_POOLS];

/* Local data */
static stSTRATUM_Data_t stLocalData;

/* *****************************************************************************
**                              LOCALS ROUTINES
** ************************************************************************** */
static void * CnxClient(void * pbyId);
#if 0
static eSTRATUM_Status_t Authenticate(void);
static eSTRATUM_Status_t Tx( const byte* const abyData,const dword const dwLength, const stSTRATUM_Pool_t * pstPool );
static eSTRATUM_Status_t Rx( byte* const abyData,dword dwLength, const stSTRATUM_Pool_t * pstPool );
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
    eRetVal = eCOM_MGR_FAIL;

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

        /* Fill up pool Id */
        astSTRATUM_Pools[dwIndex].byPoolIdx = dwIndex;

        /* Clear up thread attr */
        memset( (void*)&astSTRATUM_Th_Id[dwIndex],
                0x00,
                sizeof(pthread_t) );

        memset( (void*)&astSTRATUM_Th_Attr[dwIndex],
                0x00,
                sizeof(pthread_attr_t) );

        pthread_attr_init(&astSTRATUM_Th_Attr[dwIndex]);
        pthread_attr_setdetachstate(&astSTRATUM_Th_Attr[dwIndex], PTHREAD_CREATE_JOINABLE);
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
    eCOM_Mgr_Status_t eRetVal;
    dword dwIndex;

    /* Local initialization */
    eRetVal=eCOM_MGR_FAIL;

    for( dwIndex = 0; dwIndex < NUM_POOLS; dwIndex++ )
    {
        /* Kick off threads */
        if ( 0 == pthread_create( &astSTRATUM_Th_Id[dwIndex],
                                  &astSTRATUM_Th_Attr[dwIndex],
                                  CnxClient,
                                  (void*)&astSTRATUM_Pools[dwIndex].byPoolIdx )
           )
        {
            /* Update return variable consequently */
            eRetVal = eCOM_MGR_SUCCESS;
        }

        if( eCOM_MGR_FAIL == eRetVal )
        {
            /* Act in consequence */
            /* Try'n kick off the thread again and again for ex ... */
        }
    }

    return eRetVal;
}

void STRATUM_Ptcl_Bkgnd(void)
{
    /* Nothing to do for the time being */
}

/* *****************************************************************************
**                            LOCALS ROUTINES Defn
** ************************************************************************** */
static void * CnxClient(void * pbyId)
{
    struct addrinfo *pstAddrInfo;
    ssize_t ssent = 0;
    struct timeval timeout = {1, 0};
    ssize_t sent;
    fd_set wd;
    ssize_t n;
    int swork_id;
    byte byId;

    swork_id=1;

    /* Get thread index, that is the pool idx */
    byId=*((byte*)pbyId);

    /* Get server info, prepare connection */
    if ( 0  == getaddrinfo( (const char*)astSTRATUM_Pools[byId].abyStratumUrl,
                            (const char*)astSTRATUM_Pools[byId].abyStratumPort,
                            &astSTRATUM_Pools[byId].stServHints,
                            &astSTRATUM_Pools[byId].pstServInfo )
       )
    {
        for ( pstAddrInfo = astSTRATUM_Pools[byId].pstServInfo; NULL != pstAddrInfo ; pstAddrInfo = pstAddrInfo->ai_next )
        {
            /* Create socket */
            astSTRATUM_Pools[byId].sSocket = socket( pstAddrInfo->ai_family,
                                                     pstAddrInfo->ai_socktype,
                                                     pstAddrInfo->ai_protocol );

            /* Verify socket status */
            if ( -1 != astSTRATUM_Pools[byId].sSocket )
            {
                /* Iterate non blocking over entries returned by getaddrinfo
                 * to cope with round robin DNS entries, finding the first one
                 * we can connect to quickly. */
                if ( -1 != connect( astSTRATUM_Pools[byId].sSocket, pstAddrInfo->ai_addr, pstAddrInfo->ai_addrlen ) )
                {
                    /* Formulate request to stratum server */
                    sprintf((char*)astSTRATUM_Pools[byId].abyTxBuf, "{\"id\": %d, \"method\": \"mining.subscribe\", \"params\": []}", swork_id++);

                    /* Important ! */
                    strcat((char*)astSTRATUM_Pools[byId].abyTxBuf, "\n");

                    astSTRATUM_Pools[byId].wTxReqLen = strlen((char*)astSTRATUM_Pools[byId].abyTxBuf);

                    while ( 0 < astSTRATUM_Pools[byId].wTxReqLen  )
                    {
                        FD_ZERO(&wd);
                        FD_SET(astSTRATUM_Pools[byId].sSocket, &wd);
                        if (select((astSTRATUM_Pools[byId].sSocket + 1), NULL, &wd, NULL, &timeout) < 1)
                        {
                            printf("Send select failed\n");
                        }
                        else
                        {
                            printf("Select send success\n");
                        }

                        sent = send(astSTRATUM_Pools[byId].sSocket, astSTRATUM_Pools[byId].abyTxBuf + astSTRATUM_Pools[byId].wTxReqLen, astSTRATUM_Pools[byId].wTxReqLen, MSG_NOSIGNAL);

                        if (sent < 0) {
                            sent = 0;
                        }
                        ssent += sent;
                        astSTRATUM_Pools[byId].wTxReqLen -= sent;
                    }

                    /* Now receive */
                    do {
                        n = recv(astSTRATUM_Pools[byId].sSocket, astSTRATUM_Pools[byId].abyRecvBuf, RECVSIZE, 0);

                        if (!n)
                        {
                            printf("Socket closed waiting in recv_line\n");
                        }

                        printf("recv_line : %s\n",astSTRATUM_Pools[byId].abyRecvBuf);

                        if(!strstr((char*)astSTRATUM_Pools[byId].abyRecvBuf, "\n"))
                        {
                            break;
                        }

                    } while (TRUE);
                }
            }
        }
    }

    /* Need to obtain session Id now ... */

    /* Fill out pool structure accordingly */

    pthread_exit(NULL);
}

/* Authentication */
#if 0
static eSTRATUM_Status_t Authenticate(void)
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
    while (TRUE)
    {
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

    if (!res_val || json_is_false(res_val) || (err_val && !json_is_null(err_val)))
    {
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

    if (opt_suggest_diff)
    {
        sprintf(s, "{\"id\": %d, \"method\": \"mining.suggest_difficulty\", \"params\": [%d]}",
            swork_id++, opt_suggest_diff);
        stratum_send(pool, s, strlen(s));
    }
out:
    json_decref(val);
    return ret;
}

/* Transmit routine */
static eSTRATUM_Status_t Tx(struct pool *pool, char *s, ssize_t len)
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

        sent = send(pool->sock, s + ssent, len, MSG_NOSIGNAL);

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

static void ResetData(void)
{
    memset((void*)&stLocalData,0x00,sizeof(stSTRATUM_Data_t));
    return;
}
