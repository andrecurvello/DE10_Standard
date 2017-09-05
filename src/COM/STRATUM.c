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
#include <sys/socket.h>  /* socket defns */
#include <sys/types.h>   /* network types */
#include <netinet/in.h>  /* Internet address family */
#include <netinet/tcp.h> /* TCP stack defns */
#include <netdb.h>       /* net def "in_addr_t" */
#include <errno.h>       /* ErrNo defns */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "STRATUM.h" /* Module specific defns */

#include "COM_Mgr.h"   /* Manager defns */
#include "JSON_ser.h"  /* JSON serialization */
#include "SCHEDULER.h" /* Scheduler work definitions */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
#define RECVSIZE (RBUFSIZE - 4) /* receive buffer size minor header */
#define DEFAULT_SOCKWAIT 60     /* default timeout */

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */
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

} eSTRATUM_Status_t;

/* Introduce state machine for better handling of the threads */
typedef enum
{
    eSTRATUM_CONNECTING=0,
    eSTRATUM_AUTHENTICATING,
    eSTRATUM_LISTENING,
    eSTRATUM_PUBLISHING,
    eSTRATUM_SHARING

} eSTRATUM_State_t;

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */
typedef qword SOCKTYPE;

typedef struct
{
    const eSTRATUM_Pool_Id_t const eIdentifier;
    const char * const abyUser; /* char - avoid signedness compiler warnings */
    const char * const abyPw;

} stSTRATUM_Credentials_t;

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
    boolean bWorkReady;
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
    /* JSON */
    stJSON_Job_Result_t stJob;
    stJSON_Connect_Result_t stConnection;

    /* Scheduler */
    stSCHEDULER_Work_t stCurrentWork;

} stSTRATUM_Data_t;

/* Finally, connection descriptor */
typedef struct  {
    stSTRATUM_Credentials_t * const pstCred;
    stSTRATUM_Pool_t stPool;
    stSTRATUM_Data_t stData;
    pthread_t stThId;
    pthread_attr_t stThAttr;
    eSTRATUM_State_t eState;

} stSTRATUM_Desc_t;

/* *****************************************************************************
**                                 GLOBALS
** ************************************************************************** */

/* *****************************************************************************
**                                 LOCALS
** ************************************************************************** */
/* Pool informations */
static const stSTRATUM_Credentials_t astSTRATUM_Credentials[eSTRATUM_ID_TOTAL] =
{
#if 0
    /* Europe and North America */
    { eSTRATUM_ID_NA_EAST, "badiss_djafar.worker1", "qekWUE8Kwc34Q?" },
    { eSTRATUM_ID_EU, "badiss_djafar.worker1", "qekWUE8Kwc34Q?" },
    /* Asia */
    { eSTRATUM_ID_CN_2, NULL, NULL }, /* Not subscribed yet */
    { eSTRATUM_ID_CN_1, "badiss_djafar.worker1", "qekWUE8Kwc34Q?" },
    { eSTRATUM_ID_CN_0, "badiss_djafar.worker1", "qekWUE8Kwc34Q?" },
#endif
    { eSTRATUM_ID_SG, "badiss_djafar.worker1", "qekWUE8Kwc34Q?" }

};

/* Array of connection descriptors */
static stSTRATUM_Desc_t astDesc[eSTRATUM_ID_TOTAL];

/* *****************************************************************************
**                              LOCALS ROUTINES
** ************************************************************************** */
static void * CnxClient(void * pbyId); /* Connection thread */

/* Pool level operating routines */
static eSTRATUM_Status_t TxPool( const byte* const abyData,const dword dwLength, stSTRATUM_Pool_t * const pstPool );
static eSTRATUM_Status_t RxPool( byte* const abyData,dword dwLength, stSTRATUM_Pool_t * const pstPool );

/* Descriptor level operating routines */
static eSTRATUM_Status_t Connect(stSTRATUM_Desc_t * const pstDesc);
static eSTRATUM_Status_t Authenticate(stSTRATUM_Desc_t * const pstDesc);
static void Publish(stSTRATUM_Desc_t * const pstDesc);

/* For data management */
static void ResetData(void);

/* *****************************************************************************
**                                  API
** ************************************************************************** */

/* ************************************************************************** */
eCOM_Mgr_Status_t STRATUM_Ptcl_Setup( const COM_Mgr_CnxTableEntry_t * const pstComDesc)
/* *****************************************************************************
** Input  : -
** Output : -
** Return : -
**
** Description  : Initialize data. Pools, thread attr and all the rest.
**
** ************************************************************************** */
{
    eCOM_Mgr_Status_t eRetVal;
    stSTRATUM_Pool_t * pstPool;
    dword dwIndex;
    dword dwCredIdx;

    /* Pessimist assumption */
    eRetVal = eCOM_MGR_FAIL;
    pstPool = NULL;

    /* Reset module's data */
    ResetData();

    /* First level integrity check */
    if( NULL != pstComDesc )
    {
        /* Setup pools */
        for( dwIndex = 0; dwIndex < eSTRATUM_ID_TOTAL; dwIndex++ )
        {
            /* Retrieve pool informations */
            pstPool = &astDesc[dwIndex].stPool;

            /* Server infos */
            pstPool->abyStratumUrl = (byte*)pstComDesc->abyUrl;
            pstPool->abyStratumPort = (byte*)pstComDesc->abyPort;

            /* Get credential */
            for ( dwCredIdx = 0; dwCredIdx < eSTRATUM_ID_TOTAL; dwCredIdx++ )
            {
                if( pstComDesc->byIdentifier == (byte)astSTRATUM_Credentials[dwCredIdx].eIdentifier )
                {
                    pstPool->abyJsonUser = (byte*)astSTRATUM_Credentials[dwCredIdx].abyUser;
                    pstPool->abyJsonPass = (byte*)astSTRATUM_Credentials[dwCredIdx].abyPw;
                    break;
                }
            }

            /* TCP related */
            pstPool->stServHints.ai_family = AF_UNSPEC;
            pstPool->stServHints.ai_socktype = SOCK_STREAM;

            /* Control */
            pstPool->bWorkReady = FALSE;

            /* Fill up pool Id */
            pstPool->byPoolIdx = dwIndex;

            /* Clear up thread id */
            memset( (void*)&astDesc[dwIndex].stThId,
                    0x00,
                    sizeof(pthread_t) );

            memset( (void*)&astDesc[dwIndex].stThAttr,
                    0x00,
                    sizeof(pthread_attr_t) );

            pthread_attr_init(&astDesc[dwIndex].stThAttr);
            pthread_attr_setdetachstate(&astDesc[dwIndex].stThAttr, PTHREAD_CREATE_JOINABLE);
        }

        /* Most important, setup threads and support the kids ! */
    }

    return eRetVal;
}

/* ************************************************************************** */
eCOM_Mgr_Status_t STRATUM_Ptcl_Init(void)
/* **************************************************************************
** Input  : -
** Output : -
** Return : -
**
** Description  : Initialize sockets. Kick off threads/connections
**
** ************************************************************************** */
{
    eCOM_Mgr_Status_t eRetVal;
    dword dwIndex;

    /* Local initialization */
    eRetVal=eCOM_MGR_FAIL;

    for( dwIndex = 0; dwIndex < eSTRATUM_ID_TOTAL; dwIndex++ )
    {
        /* Initialize the state machine */
        astDesc[dwIndex].eState = eSTRATUM_CONNECTING;

        /* Attach data */
        astDesc[dwIndex].stData.stConnection.abyNonce1 = &astDesc[dwIndex].stData.stCurrentWork.abyNonce1[0];
        astDesc[dwIndex].stData.stJob.abyBlckVer = &astDesc[dwIndex].stData.stCurrentWork.abyBlckVer[0];
        astDesc[dwIndex].stData.stJob.abyCoinBase1 = &astDesc[dwIndex].stData.stCurrentWork.abyCoinBase1[0];
        astDesc[dwIndex].stData.stJob.abyCoinBase2 = &astDesc[dwIndex].stData.stCurrentWork.abyCoinBase2[0];
        astDesc[dwIndex].stData.stJob.abyJobId = &astDesc[dwIndex].stData.stCurrentWork.abyJobId[0];
        astDesc[dwIndex].stData.stJob.abyPrevHash = &astDesc[dwIndex].stData.stCurrentWork.abyPrevHash[0];
        astDesc[dwIndex].stData.stJob.abyPrevHash = &astDesc[dwIndex].stData.stCurrentWork.abyPrevHash[0];
        astDesc[dwIndex].stData.stJob.abyNbits = &astDesc[dwIndex].stData.stCurrentWork.abyNbits[0];
        astDesc[dwIndex].stData.stJob.abyNtime = &astDesc[dwIndex].stData.stCurrentWork.abyNtime[0];
        astDesc[dwIndex].stData.stJob.abyMerkleBranch = astDesc[dwIndex].stData.stCurrentWork.aabyMerkleBranch;

        /* Kick off threads */
        if ( 0 == pthread_create( &astDesc[dwIndex].stThId,
                                  &astDesc[dwIndex].stThAttr,
                                  CnxClient,
                                  (void*)&astDesc[dwIndex].stPool.byPoolIdx )
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

/* ************************************************************************** */
void STRATUM_Ptcl_Bkgnd(void)
/* **************************************************************************
** Input  : -
** Output : -
** Return : -
**
** Description  : Stratum protocol background task.
**
** ************************************************************************** */
{
    /* Nothing to do for the time being */
    /* Dispatch work if data is valid and coherent */
    dword dwIndex;
    stSTRATUM_Pool_t * pstPool;
    stSTRATUM_Data_t * pstData;

    for( dwIndex = 0; dwIndex < eSTRATUM_ID_TOTAL; dwIndex++ )
    {
        /* Retrieve pool informations */
        pstPool = &astDesc[dwIndex].stPool;
        pstData = &astDesc[dwIndex].stData;

        /* is work ready on a pool ? */
        if( TRUE == pstPool->bWorkReady )
        {
            /* Push work to the scheduler */
            SCHEDULER_PushWork(&pstData->stCurrentWork);

            /* Reset work status for reuse */
            pstPool->bWorkReady = FALSE;
        }
    }
}

/* *****************************************************************************
**                            LOCALS ROUTINES Defn
** ************************************************************************** */

/* ************************************************************************** */
static void * CnxClient(void * pbyId)
/* *****************************************************************************
** Input  : Thread Id. Useful to link thread to pools, and pools to work.
** Output : -
** Return : -
**
** Description  : Stratum protocol background task.
**
** ************************************************************************** */
{
    eSTRATUM_Status_t eRetVal;
    stSTRATUM_Pool_t * pstPool;
    stSTRATUM_Data_t * pstData;
    byte byId;

    /* Get thread index, that is the pool idx */
    byId=*((byte*)pbyId);
    eRetVal=eSTRATUM_CNX_FAIL;

    /* Retrieve necessary infos */
    pstPool = &astDesc[byId].stPool;
    pstData = &astDesc[byId].stData;

    /* Stratum connection state machine */
    for(;;)
    {
        switch (astDesc[byId].eState)
        {
            case eSTRATUM_CONNECTING:
            {
                /* Set thread priority. Consider pool mngmt strategy and so one ... */
                if( eSTRATUM_CNX_SUCCESS == Connect(&astDesc[byId]) )
                {
                    /* Trigger transition to authentication state */
                    astDesc[byId].eState = eSTRATUM_AUTHENTICATING;
                }

                break;
            }
            case eSTRATUM_AUTHENTICATING:
            {
                /* Need to login */
                if ( eSTRATUM_CNX_SUCCESS == Authenticate(&astDesc[byId]) )
                {
                    /* Trigger transition to authentication state */
                    astDesc[byId].eState = eSTRATUM_LISTENING;
                }
                else
                {
                    /* Trigger transition to authentication state */
                    astDesc[byId].eState = eSTRATUM_CONNECTING;
                }

                break;
            }
            case eSTRATUM_PUBLISHING:
            case eSTRATUM_LISTENING:
            {

                /*
                ** Start receiving jobs, Fill out pool structure accordingly
                ** Get answer from the server. Get extra nonce 1 and ext nonce 2 size
                */
                eRetVal = RxPool( (byte*)pstPool->abyJsonRes,
                                  pstPool->dwJsonResLen,
                                  pstPool );

                if ( eRetVal != eSTRATUM_MSG_SUCCESS )
                {
                    /* Something is wrong with the receiving trigger transition to reconnect */
                    printf("Ouch!\n");

                    astDesc[byId].eState = eSTRATUM_CONNECTING;
                }
                else
                {
                    /* Received anything ? */
                    if( 0 != pstPool->dwJsonResLen )
                    {
                        astDesc[byId].eState = eSTRATUM_LISTENING;
                    }
                }

                /* Link JSON request to work */
                if ( eSTRATUM_LISTENING == astDesc[byId].eState )
                {
                    /* Deserialize */
                    if ( eJSON_SUCCESS == JSON_Deser_ResJob( &pstData->stJob,
                                                             (byte*const)&pstPool->abyJsonRes )
                       )
                    {
                    	printf("[RX]{JOB} %s\n",pstPool->abyJsonRes);

                        /* And publish */
                        Publish(&astDesc[byId]);

                        /* Received something, cannot publish anymore */
                        astDesc[byId].eState = eSTRATUM_PUBLISHING;
                    }
                }

                break;
            }
            case eSTRATUM_SHARING:
            {
                /* Send golden nonce to pool */
                break;
            }
            default:
            {
                break;
            }
        }
    }


    pthread_exit(NULL);
}

static eSTRATUM_Status_t Connect(stSTRATUM_Desc_t * const pstDesc)
{
    struct addrinfo *pstAddrInfo;
    struct timeval timeout = {1, 0};
    ssize_t sent;
    fd_set stFd;
    int swork_id;
    eSTRATUM_Status_t eRetVal;
    stSTRATUM_Data_t *pstData;
    stSTRATUM_Pool_t *pstPool;

    /* Get thread index, that is the pool idx */
    eRetVal=eSTRATUM_CNX_FAIL;
    pstData=NULL;
    pstPool=NULL;
    swork_id=1;
    sent=0;

    /* Get server info, prepare connection */
    if (   ( NULL != pstDesc )
        && ( 0  == getaddrinfo( (const char*)pstDesc->stPool.abyStratumUrl,
                                (const char*)pstDesc->stPool.abyStratumPort,
                                &pstDesc->stPool.stServHints,
                                &pstDesc->stPool.pstServInfo ) )
       )
    {
        /* Retrieve descriptor information */
        pstPool = &pstDesc->stPool;
        pstData = &pstDesc->stData;

        for ( pstAddrInfo = pstPool->pstServInfo; NULL != pstAddrInfo ; pstAddrInfo = pstAddrInfo->ai_next )
        {
            /* Create socket */
            pstPool->sSocket = socket( pstAddrInfo->ai_family,
                                       pstAddrInfo->ai_socktype,
                                       pstAddrInfo->ai_protocol );

            /* Verify socket status */
            if ( -1 != pstPool->sSocket )
            {
                /* Iterate non blocking over entries returned by getaddrinfo
                 * to cope with round robin DNS entries, finding the first one
                 * we can connect to quickly. */
                if ( -1 != connect( pstPool->sSocket, pstAddrInfo->ai_addr, pstAddrInfo->ai_addrlen ) )
                {
                    /* Formulate request to stratum server */
                    JSON_Ser_ReqConnect(swork_id,&pstPool->abyJsonReq[0]);
                    pstPool->dwJsonReqLen = strlen((char*)pstPool->abyJsonReq);

                    while ( sent != pstPool->dwJsonReqLen  )
                    {
                        FD_ZERO(&stFd);
                        FD_SET(pstPool->sSocket, &stFd);

                        if (select((pstPool->sSocket + 1), NULL, &stFd, NULL, &timeout) < 1)
                        {
                            printf("Send select failed\n");
                        }

                        sent += send( pstPool->sSocket,
                                      (&pstPool->abyJsonReq + sent),
                                      pstPool->dwJsonReqLen,
                                      MSG_NOSIGNAL );
                    }

                	printf("[TX]{CONNECT} %s",pstPool->abyJsonReq);

                    /* Trigger stratum connect answer */
                    eRetVal = eSTRATUM_CNX_PENDING;

                    /* Get answer from the server. Get extra nonce 1 and ext nonce 2 size */
                    while( eSTRATUM_MSG_SUCCESS != eRetVal )
                    {
                        eRetVal = RxPool( (byte*)pstPool->abyJsonRes,
                                          pstPool->dwJsonResLen,
                                          pstPool );

                        /* Deserialize */
                        if ( eJSON_SUCCESS == JSON_Deser_ResConnect( &pstData->stConnection,
                                                                     (byte*const)pstPool->abyJsonRes )
                           )
                        {
                            eRetVal = eSTRATUM_CNX_SUCCESS;

                        	printf("[RX]{CONNECT} %s\n",pstPool->abyJsonRes);

                            break;
                        }
                    }
                }
            }
        }
    }

    return eRetVal;
}

/* Authentication */
static eSTRATUM_Status_t Authenticate(stSTRATUM_Desc_t * const pstDesc)
{
    eSTRATUM_Status_t eRetVal;
    stJSON_Auth_Demand_t stJSON_Auth_Demand;
    stSTRATUM_Pool_t *pstPool;

    /* Init locals */
    eRetVal = eSTRATUM_CNX_FAIL;
    pstPool=NULL;

    /* Basic sanity check */
    if ( NULL != pstDesc )
    {
        /* Retrieve descriptor information */
        pstPool = &pstDesc->stPool;

        /* Prepare JSON request */
        stJSON_Auth_Demand.abyPass = pstPool->abyJsonPass;
        stJSON_Auth_Demand.abyUser = pstPool->abyJsonUser;
        stJSON_Auth_Demand.wWorkId = 2;

        JSON_Ser_ReqAuth(&stJSON_Auth_Demand,&pstPool->abyJsonReq[0]);

        /* Send request */
        if ( eSTRATUM_MSG_SUCCESS == TxPool(pstPool->abyJsonReq,strlen((char*)pstPool->abyJsonReq),pstPool) )
        {
        	printf("[TX]{AUTH} %s",pstPool->abyJsonReq);

            /* Parse all data in the queue and anything left should be auth */
            for (;;)
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
                	printf("[RX]{AUTH} %s\n",pstPool->abyJsonRes);

                    eRetVal = eSTRATUM_CNX_SUCCESS;
                    break;
                }
            }

            /* That is it for now but there is more to do .... */
        }
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
               	/* Clear buffer on exit */
#if 0
                memset((char*)abyData, 0x00, RBUFSIZE);
#endif
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
    byte *pbyData;
    eSTRATUM_Status_t eRetVal;

    /* Init locals,  Reset receive buffer */
    eRetVal = eSTRATUM_MSG_ERR;
    memset((char*)abyData, 0x00, RBUFSIZE);
    dwLength=0;
    pbyData=abyData;

    if (NULL == strstr((char*)abyData, "\n"))
    {
        do {
        	dwLength += recv(pstPool->sSocket, (char*)(abyData), RECVSIZE, 0);

            if (dwLength < 0)
            {
                close(pstPool->sSocket);
                printf("socket error %d, errno %d\n",dwLength,errno);
                pstPool->bStratumActive=FALSE;
                break;
            }

            if(   (NULL != strstr((char*)abyData, "\n"))
               || (0 == dwLength)
              )
            {
            	/* Update return value */
                eRetVal = eSTRATUM_MSG_SUCCESS;
            }

            /* Update data pointer */
            pbyData+=dwLength;
        }
        while (    ( dwLength < RECVSIZE )
                && ( !strstr((char*)abyData, "\n") )
              );
    }

    return eRetVal;
}

static void ResetData(void)
{
    dword dwIndex;

    /* Setup pools */
    for( dwIndex = 0; dwIndex < eSTRATUM_ID_TOTAL; dwIndex++ )
    {
        /* Reset data */
        memset( (void*)&astDesc[dwIndex].stData,
                0x00,
                sizeof(stSTRATUM_Data_t) );

        /* Reset pools */
        memset( (void*)&astDesc[dwIndex].stPool,
                0x00,
                sizeof(stSTRATUM_Pool_t) );
    }

    return;
}

static void Publish(stSTRATUM_Desc_t * const pstDesc)
{
    stSTRATUM_Data_t * pstData;

    /* Retrieve necessary infos */
    pstData = &pstDesc->stData;

    /* Copy non pointer data, this may need mutex protection actually */
    if (   ( NULL != pstDesc )
        && ( FALSE == pstDesc->stPool.bWorkReady )
       )
    {
        pstData->stCurrentWork.wN2size = pstData->stConnection.wN2size;
        pstData->stCurrentWork.byPoolId = pstDesc->stPool.byPoolIdx;
        pstData->stCurrentWork.doDiff = (double)2048/*pstData->stJob.doLiveDifficulty*/;

        /* Update pool information consequently */
        pstDesc->stPool.bWorkReady = TRUE;
    }

    return;
}
