/* *****************************************************************************
**
**                       DE10 standard project
**
** Project      : DE10 standard project
** Module       : COM_Mgr
**
** Description  : Communication manager. That is essentially TCP socket put in
**                threads.
**
** ************************************************************************** */

/* *****************************************************************************
**  REVISION HISTORY
** Date         Inits   Description
** ----------------------------------------------------------------------------
** 10.08.17     bd      [no issue number] File creation
**
** ************************************************************************** */

/* *****************************************************************************
**                          SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "Macros.h" /* Divers macros definitions */
#include "Types.h"  /* Legacy types definitions */

#include <pthread.h>  /* posix thread defns */
#include <stdio.h>    /* Standard IO defns */
#include <stdlib.h>   /* Standard lib C defns */
#include <string.h>   /* String defns */
#include <unistd.h>   /* Types defns */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "COM_mgr.h" /* Dealing with threads, client and server */

/* Protocol definitions */
#if 0
#include "stratum.h" /* Dealing with the protocol layer, TCP, sockets */
#endif
/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
#define NUM_COM_CLIENT (1) /* number of running client simultaneously */

typedef enum
{
    eCOM_MGR_PRCL_GETWORK=0,
    eCOM_MGR_PRCL_STRATUM

} eCOM_Mgr_PrtcType_t;

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */
typedef struct
{
    /* Empty for now */
} COM_Mgr_Result_t;

/* Need perhaps a connection descriptor something where we can register connection related data */
typedef struct
{
    pthread_t *astThId;
    pthread_attr_t *astAttr;
    const dword dwNumClients;
    const eCOM_Mgr_PrtcType_t ePrclType;

} COM_Mgr_Cnx_t;

typedef struct
{
    COM_Mgr_Cnx_t const* pstCnx;
    dword dwCnxNum;

    /* Usefull for statistic display */

} COM_Mgr_Desc_t;

/* Modules private data */
typedef struct
{
    dword dwErrCnt;
    dword dwThStatus;
    dword dwAttrStatus;

} COM_Mgr_Data_t;

/* *****************************************************************************
**                                 GLOBALS
** ************************************************************************** */

/* *****************************************************************************
**                                 LOCALS
** ************************************************************************** */
/* Stratum connection declaration */
static pthread_t astThIdStrtm[NUM_COM_CLIENT];
static pthread_attr_t astAttrStrtm[NUM_COM_CLIENT];

static COM_Mgr_Cnx_t astCOM_Mgr_Cnx[] =
{
    {
        &astThIdStrtm[0],
        &astAttrStrtm[0],
        NUM_COM_CLIENT,
        eCOM_MGR_PRCL_STRATUM
    }
};

static COM_Mgr_Desc_t stLocalDesc =
{
    &astCOM_Mgr_Cnx[0],
    mArraySize(astCOM_Mgr_Cnx)
};

static COM_Mgr_Data_t stLocalData;

/* *****************************************************************************
**                              LOCALS ROUTINES
** ************************************************************************** */
static void ResetData(void);
static void* CnxClient(void* pvData); /* That is the client thread. That will move */

/* *****************************************************************************
**                                  API
** ************************************************************************** */
dword COM_Mgr_Setup(void)
{
    dword dwRetVal;
    word byIndex;
    word byIndexTh;

    /* Initialise local variables */
    dwRetVal = 0;

    /* Reset modules private data */
    ResetData();

    /* Shall we clean up the result here ? */

    /* Visit connection list */
    for( byIndex=0; byIndex < mArraySize(astCOM_Mgr_Cnx); byIndex++ )
    {
        memset( (void*)&astCOM_Mgr_Cnx[byIndex].astAttr[0],
                (sizeof(pthread_t)*astCOM_Mgr_Cnx[byIndex].dwNumClients),
                0x00 );

        memset( (void*)&astCOM_Mgr_Cnx[byIndex].astAttr[0],
                (sizeof(pthread_attr_t)*astCOM_Mgr_Cnx[byIndex].dwNumClients),
                0x00 );
    }

    /* Prepare connection start */
    for( byIndex=0; byIndex < stLocalDesc.dwCnxNum; byIndex++ )
    {
        if( eCOM_MGR_PRCL_STRATUM == stLocalDesc.pstCnx[byIndex].ePrclType )
        {
            /* Start init the stratum prot */
        }

        /* old getwork protocol support */
        if( eCOM_MGR_PRCL_GETWORK == stLocalDesc.pstCnx[byIndex].ePrclType )
        {
            /* Start init the getwork prot */
        }

        /* Prepare threads */
        for( byIndexTh=0; byIndexTh < stLocalDesc.pstCnx[byIndex].dwNumClients; byIndexTh++ )
        {
            pthread_attr_init(&stLocalDesc.pstCnx[byIndex].astAttr[byIndexTh]);
            pthread_attr_setdetachstate(&stLocalDesc.pstCnx[byIndex].astAttr[byIndexTh], PTHREAD_CREATE_JOINABLE);
        }
    }

    return dwRetVal;
}

dword COM_Mgr_Init(void)
{
    dword dwRetVal;
    word byIndex;
    word byIndexTh;

    /* Initial locals */
    dwRetVal = 0;

    /* Prepare connection start */
    for( byIndex=0; byIndex < stLocalDesc.dwCnxNum; byIndex++ )
    {
        /* Prepare threads */
        for( byIndexTh=0; byIndexTh < stLocalDesc.pstCnx[byIndex].dwNumClients; byIndexTh++ )
        {
            if ( 0 != pthread_create( &stLocalDesc.pstCnx[byIndex].astThId[byIndexTh],
                                      NULL,
                                      CnxClient,
                                      NULL )
               )
            {
                /* Update return variable consequently */
                dwRetVal = 1;
                printf("ERROR; return code from pthread_create()\n");
            }
        }
    }

    return dwRetVal;
}

/* Things to do in the background task */
dword COM_Mgr_Bkgnd(void)
{
    dword dwRetVal;

    dwRetVal = 0;

    /* Monitor clients and connections */

    /* Client connection recovery strategy ? */

    return dwRetVal;
}

/* *****************************************************************************
**                            LOCALS ROUTINES Defn
** ************************************************************************** */
static void ResetData(void)
{
    memset((void*)&stLocalData,sizeof(COM_Mgr_Data_t),0x00);
    return;
}

static void* CnxClient(void* pvData)
{
    printf("Connection test");
    pthread_exit(NULL);
}
