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
#include <errno.h>       /* ErrNo defns */


/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "STRATUM.h" /* Module specific defns */

#include "COM_Mgr.h" /* Manager defns */
#include "JSON_ser.h"    /* JSON serialization */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
#define NUM_POOLS (6)           /* number of pool used */
#define RBUFSIZE (8192)         /* receive buffer size */
#define RECVSIZE (RBUFSIZE - 4) /* receive buffer size minor header */
#define DEFAULT_SOCKWAIT 60     /* default timeout */

/* Status to be used in that module */
typedef enum
{
    eSTRATUM_CNX_SUCCESS=0,
    eSTRATUM_CNX_PENDING,
    eSTRATUM_CNX_TIMEOUT,
    eSTRATUM_CNX_FAIL,
    eSTRATUM_MSG_SUCCESS,
    eSTRATUM_MSG_PENDING,
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
    const char * const abyUser;
    const char * const abyPw;

} stSTRATUM_Urls_t;

typedef struct {
    /* JSON land */
    byte abyJsonReq[RBUFSIZE];
    dword dwJsonReqLen;
    byte abyJsonRes[RBUFSIZE];
    dword dwJsonResLen;
    byte *abyJsonUser;
    byte *abyJsonPass;

    /* Pool management */
    byte byPoolIdx;
    byte byPoolPrio;
    boolean bHasStratum;
    boolean bStratumActive;
    boolean bStratumInit;
    boolean bstratumNotify;
    struct timeval stTimeLastwork;

    /* TCP-land : stratum variables, no proxy for the time being */
    byte *abyStratumUrl;  /* The pool URL */
    byte *abyStratumPort; /* String version of the port */
    dword dwStratumPort;  /* Integer version of the port */
    SOCKTYPE sSocket;
    byte *abySockBuf;
    byte *abySessionId;
    struct addrinfo *pstServInfo;
    struct addrinfo stServHints;

} stSTRATUM_Pool_t;

typedef struct  {
    stJSON_Job_Result_t stJob;
    stJSON_Connect_Result_t stConnection;

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
    { "us-east.stratum.slushpool.com", "3333", "badiss_djafar.worker1", "password" },
    { "eu.stratum.slushpool.com", "3333", "badiss_djafar.worker1", "password" },
    /* Asia */
    { "stratum.f2pool.com", "3333", NULL, NULL }, /* Not subscribed yet */
    { "cn.stratum.slushpool.com", "3333", "badiss_djafar.worker1", "password" },
    { "cn.stratum.slushpool.com", "443", "badiss_djafar.worker1", "password" },
    { "sg.stratum.slushpool.com", "3333", "badiss_djafar.worker1", "password" }

};

static stSTRATUM_Pool_t astSTRATUM_Pools[NUM_POOLS];
static stSTRATUM_Data_t astSTRATUM_Data[NUM_POOLS];

static pthread_t astSTRATUM_Th_Id[NUM_POOLS];
static pthread_attr_t astSTRATUM_Th_Attr[NUM_POOLS];

/* *****************************************************************************
**                              LOCALS ROUTINES
** ************************************************************************** */
static void * CnxClient(void * pbyId); /* Connection thread */

static eSTRATUM_Status_t TxPool( const byte* const abyData,const dword dwLength, stSTRATUM_Pool_t * const pstPool );
static eSTRATUM_Status_t RxPool( byte* const abyData,dword dwLength, stSTRATUM_Pool_t * const pstPool );
static eSTRATUM_Status_t Authenticate(stSTRATUM_Pool_t * const pstPool);

/* For socket management */
static boolean IsErrnoHappy(void);
#if 0
static boolean IsSockFull(const SOCKTYPE sSock);
#endif

/* For data management */
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
        /* Server infos */
        astSTRATUM_Pools[dwIndex].abyStratumUrl = (byte*)astSTRATUM_Urls[dwIndex].abyUrl;
        astSTRATUM_Pools[dwIndex].abyStratumPort = (byte*)astSTRATUM_Urls[dwIndex].abyPort;
        astSTRATUM_Pools[dwIndex].abyJsonUser = (byte*)astSTRATUM_Urls[dwIndex].abyUser;
        astSTRATUM_Pools[dwIndex].abyJsonPass = (byte*)astSTRATUM_Urls[dwIndex].abyPw;

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
    fd_set stFd;
    int swork_id;
    byte byId;
    eSTRATUM_Status_t eRetVal;

    /* Get thread index, that is the pool idx */
    byId=*((byte*)pbyId);
    swork_id=1;
    eRetVal=eSTRATUM_CNX_FAIL;

    /* Set thread priority. Consider pool mngmt strategy and so one ... */

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
                    JSON_Ser_ReqConnect(swork_id,&astSTRATUM_Pools[byId].abyJsonReq[0]);
                    astSTRATUM_Pools[byId].dwJsonReqLen = strlen((char*)astSTRATUM_Pools[byId].abyJsonReq);

                    while ( 0 < astSTRATUM_Pools[byId].dwJsonReqLen  )
                    {
                        FD_ZERO(&stFd);
                        FD_SET(astSTRATUM_Pools[byId].sSocket, &stFd);
                        if (select((astSTRATUM_Pools[byId].sSocket + 1), NULL, &stFd, NULL, &timeout) < 1)
                        {
                            printf("Send select failed\n");
                        }
                        else
                        {
                            printf("Select send success\n");
                        }

                        sent = send( astSTRATUM_Pools[byId].sSocket,
                                     (astSTRATUM_Pools[byId].abyJsonReq + astSTRATUM_Pools[byId].dwJsonReqLen),
                                     astSTRATUM_Pools[byId].dwJsonReqLen,
                                     MSG_NOSIGNAL );

                        if (sent < 0)
                        {
                            sent = 0;
                            eRetVal = eSTRATUM_CNX_SUCCESS;
                        }
                        ssent += sent;
                        astSTRATUM_Pools[byId].dwJsonReqLen -= sent;
                    }

                    /* Trigger stratum connect answer */
                    eRetVal = eSTRATUM_MSG_PENDING;

                    /* Get answer from the server. Get extra nonce 1 and ext nonce 2 size */
                    while( eSTRATUM_MSG_SUCCESS != eRetVal )
                    {
                        eRetVal = RxPool( (byte*)&astSTRATUM_Pools[byId].abyJsonRes,
                                          astSTRATUM_Pools[byId].dwJsonResLen,
                                          &astSTRATUM_Pools[byId] );

                        if ( eJSON_SUCCESS == JSON_Deser_ResConnect( &astSTRATUM_Data[byId].stConnection,
                                                                     (byte*const)&astSTRATUM_Pools[byId].abyJsonRes )
                           )
                        {
                            /* Start to get mining jobs now */
                            break;
                        }
                    }
                }
            }
        }
    }

    /* Need to obtain session Id now ... */
    Authenticate(&astSTRATUM_Pools[byId]);

    /* Fill out pool structure accordingly */

    pthread_exit(NULL);
}

/* Authentication */
static eSTRATUM_Status_t Authenticate(stSTRATUM_Pool_t * const pstPool)
{
    eSTRATUM_Status_t eRetVal;
    stJSON_Auth_Demand_t stJSON_Auth_Demand;

    /* Init locals */
    eRetVal = eSTRATUM_CNX_FAIL;

    /* Prepare JSON request */
    stJSON_Auth_Demand.abyPass = pstPool->abyJsonPass;
    stJSON_Auth_Demand.abyUser = pstPool->abyJsonUser;
    stJSON_Auth_Demand.wWorkId = 1;

    JSON_Ser_ReqAuth(&stJSON_Auth_Demand,&pstPool->abyJsonReq[0]);

    /* Send request */
    if ( eSTRATUM_MSG_SUCCESS == TxPool(pstPool->abyJsonReq,strlen((char*)pstPool->abyJsonReq),pstPool) )
    {
        /* Parse all data in the queue and anything left should be auth */
        while (TRUE)
        {
            eRetVal = RxPool(pstPool->abyJsonRes,pstPool->dwJsonResLen,pstPool);

            if (   ( eSTRATUM_MSG_ERR == eRetVal )
                || ( eSTRATUM_MSG_TIMEOUT == eRetVal )
               )
            {
                eRetVal = eSTRATUM_CNX_FAIL;
                break;
            }

            /* Deserialize, check if authentication is indeed successful */
            if (   ( eSTRATUM_MSG_SUCCESS == eRetVal )
                && ( eJSON_SUCCESS == JSON_Deser_ResAuth(&pstPool->abyJsonRes[0]) )
               )
            {
                eRetVal = eSTRATUM_CNX_SUCCESS;
                break;
            }
        }

        /* That is it for now but there is more to do .... */
    }

    return eRetVal;
}

/* Transmit routine */
static eSTRATUM_Status_t TxPool( const byte* const abyData,
                                 const dword dwLength,
                                 stSTRATUM_Pool_t * const pstPool )
{
    ssize_t ssent;
    struct timeval timeout = {1, 0};
    fd_set stFd;
    eSTRATUM_Status_t eRetVal;

    /* Init locals */
    eRetVal = eSTRATUM_MSG_ERR;
    ssent = (ssize_t)dwLength;

    while ( 0 < ssent )
    {
        FD_ZERO(&stFd);
        FD_SET(pstPool->sSocket, &stFd);
        if ( 0 != select((pstPool->sSocket + 1), NULL, &stFd, NULL, &timeout) )
        {
            ssent = send( pstPool->sSocket,
                          (abyData + (dwLength - ssent)),
                          ssent,
                          MSG_NOSIGNAL );

            /* Update length */
            ssent = (dwLength - ssent);

            /* Shall we finish ? */
            if ( 0 == ssent )
            {
                /* Buffer sent. Update control variable and return value */
                eRetVal=eSTRATUM_MSG_SUCCESS;
                ssent = 0;
            }
        }
    }

#if 0 /* Update stats */
    pool->cgminer_pool_stats.times_sent++;
    pool->cgminer_pool_stats.bytes_sent += ssent;
    pool->cgminer_pool_stats.net_bytes_sent += ssent;
#endif
    return eRetVal;
}

/* Receive routine */
static eSTRATUM_Status_t RxPool( byte* const abyData,
                                 dword dwLength,
                                 stSTRATUM_Pool_t * const pstPool )
{
    char *tok, *sret = NULL;
    ssize_t len, buflen;
    int waited = 0;
    char s[RBUFSIZE];
    size_t slen;
    ssize_t n;
    eSTRATUM_Status_t eRetVal;

    /* Init locals,  Reset receive buffer */
    eRetVal = eSTRATUM_MSG_ERR;
    memset((char*)abyData, 0x00, RBUFSIZE); /* Risky */

    if (!strstr((char*)abyData, "\n"))
    {
        do {
            n = recv(pstPool->sSocket, s, RECVSIZE, 0);
            if (!n)
            {
                /* Stratum not active anymore, close socket and try reinit */
                close(pstPool->sSocket);
                pstPool->bStratumActive=FALSE;
                break;
            }

            if (n < 0)
            {
                if (   ( FALSE == IsErrnoHappy() )
/*                    || ( FALSE == IsSockFull(pstPool->sSocket, DEFAULT_SOCKWAIT - waited) ) */
                   )
                {
                    close(pstPool->sSocket);
                    pstPool->bStratumActive=FALSE;
                    break;
                }
            }
            else
            {
                slen = strlen(s);
                strcat((char*)(abyData + slen), s);
            }
        }
        while (    ( waited < DEFAULT_SOCKWAIT )
                && ( !strstr((char*)abyData, "\n") )
              );
    }

    buflen = strlen((char*)abyData);
    tok = strtok((char*)abyData, "\n");

    sret = strdup(tok);
    len = strlen(sret);

    /* Copy what's left in the buffer after the \n, including the
     * terminating \0 */
    if (buflen > len + 1)
    {
        memmove( (char*)abyData,
                 (char*)(abyData + len + 1),
                 (buflen - len + 1) );
    }
    else
    {
        strcpy((char*)abyData, "");
    }

#if 0
    pool->cgminer_pool_stats.times_received++;
    pool->cgminer_pool_stats.bytes_received += len;
    pool->cgminer_pool_stats.net_bytes_received += len;
#endif

    return eRetVal;
}

#if 0 /* Is socket full ? */
static bool IsSockFull(struct pool *pool, int wait)
{
    SOCKETTYPE sock = pool->sock;
    struct timeval timeout;
    fd_set rd;

    if (unlikely(wait < 0))
        wait = 0;
    FD_ZERO(&rd);
    FD_SET(sock, &rd);
    timeout.tv_usec = 0;
    timeout.tv_sec = wait;
    if (select(sock + 1, &rd, NULL, NULL, &timeout) > 0)
        return true;
    return false;
}
#endif

static boolean IsErrnoHappy(void)
{
    boolean bRetVal;

    /* Assume errono is happy */
    bRetVal=TRUE;

    if(   ( EAGAIN == errno )
       || ( EWOULDBLOCK == errno )
      )
    {
        /* Assume errono isn't happy anymore :( */
        bRetVal=FALSE;
    }

    return bRetVal;
}

static void ResetData(void)
{
    dword dwIndex;

    /* Setup pools */
    for( dwIndex = 0; dwIndex < NUM_POOLS; dwIndex++ )
    {
        /* Reset data */
        memset( (void*)&astSTRATUM_Data[dwIndex],
                0x00,
                sizeof(stSTRATUM_Data_t) );

        /* Reset pools */
        memset( (void*)&astSTRATUM_Pools[dwIndex],
                0x00,
                sizeof(stSTRATUM_Pool_t) );
    }

    return;
}
