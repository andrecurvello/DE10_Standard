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

#include <stdio.h>    /* Standard IO defns */
#include <stdlib.h>   /* Standard lib C defns */
#include <string.h>   /* String defns */
#include <unistd.h>   /* Types defns */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "COM_mgr.h" /* Dealing with threads, client and server */

/* Protocol definitions */
#include "STRATUM.h" /* Dealing with the protocol layer, TCP, sockets */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
typedef enum
{
    eCOM_MGR_PRCL_GETWORK=0,
    eCOM_MGR_PRCL_STRATUM

} eCOM_Mgr_PrtcType_t;

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */
/* Pointer to connection client */
typedef eCOM_Mgr_Status_t (*pfnCnxClient_Setup_t)(const COM_Mgr_CnxTableEntry_t *const);
typedef eCOM_Mgr_Status_t (*pfnCnxClient_Init_t)(void);
typedef void (*pfnCnxClient_Bkgnd_t)(void);

/* Need perhaps a connection descriptor something where we can register connection related data */
typedef struct
{
    const eCOM_Mgr_PrtcType_t ePrclType;
    const pfnCnxClient_Setup_t pfnCnxClient_Setup;
    const pfnCnxClient_Init_t pfnCnxClient_Init;
    const pfnCnxClient_Bkgnd_t pfnCnxClient_Bkgnd;
    const COM_Mgr_CnxTableEntry_t * const pstCnxClient_Entry;

} COM_Mgr_Cnx_t;

typedef struct
{
    const COM_Mgr_Cnx_t const* pstCnx;
    dword dwCnxNum;

    /* Usefull for statistic display */

} COM_Mgr_Desc_t;

/* Modules private data */
typedef struct
{
    dword dwErrCnt;
    dword dwThStatus;
    dword dwAttrStatus;
    dword dwNumRetry;

} COM_Mgr_Data_t;

/* *****************************************************************************
**                                 GLOBALS
** ************************************************************************** */

/* *****************************************************************************
**                                 LOCALS
** ************************************************************************** */
/* Pool informations */
static const COM_Mgr_CnxTableEntry_t COM_Mgr_CnxTable[eSTRATUM_ID_TOTAL] =
{
    { eSTRATUM_ID_SG, "sg.stratum.slushpool.com", "3333" }
#if 0
    /* Europe and North America */
    { eSTRATUM_ID_NA_EAST, "us-east.stratum.slushpool.com", "3333?" },
    { eSTRATUM_ID_EU,"eu.stratum.slushpool.com", "3333?" },
    /* Asia */
    { eSTRATUM_ID_CN_2, "stratum.f2pool.com", "3333" }, /* Not subscribed yet */
    { eSTRATUM_ID_CN_1, "cn.stratum.slushpool.com", "443" },
    { eSTRATUM_ID_CN_0, "cn.stratum.slushpool.com", "3333" },
#endif

};

/* Connection definitions */
static COM_Mgr_Cnx_t astCOM_Mgr_Cnx[] =
{
    {   /* Singapore */
        eCOM_MGR_PRCL_STRATUM,
        &STRATUM_Ptcl_Setup,
        &STRATUM_Ptcl_Init,
		&STRATUM_Ptcl_Bkgnd,
        &COM_Mgr_CnxTable[eSTRATUM_ID_SG]
    }
#if 0 /* That is how an additional connection would look like */
    ,{  /* China */
        eCOM_MGR_PRCL_STRATUM,
        &STRATUM_Ptcl_Setup,
        &STRATUM_Ptcl_Init,
        NULL,
        (byte)eSTRATUM_ID_CN_0,
        "cn.stratum.slushpool.com",
        "3333"
    }
    ,{  /* China */
        eCOM_MGR_PRCL_STRATUM,
        &STRATUM_Ptcl_Setup,
        &STRATUM_Ptcl_Init,
        NULL,
        (byte)eSTRATUM_ID_CN_1,
        "cn.stratum.slushpool.com",
        "443"
    }
    ,{  /* China */
        eCOM_MGR_PRCL_STRATUM,
        &STRATUM_Ptcl_Setup,
        &STRATUM_Ptcl_Init,
        NULL,
        (byte)eSTRATUM_ID_CN_2,
        "stratum.f2pool.com",
        "3333"
    }
    ,{  /* Europe */
        eCOM_MGR_PRCL_STRATUM,
        &STRATUM_Ptcl_Setup,
        &STRATUM_Ptcl_Init,
        NULL,
        (byte)eSTRATUM_ID_EU,
        "eu.stratum.slushpool.com",
        "3333"
    }
    ,{  /* North America */
        eCOM_MGR_PRCL_STRATUM,
        &STRATUM_Ptcl_Setup,
        &STRATUM_Ptcl_Init,
        NULL,
        (byte)eSTRATUM_ID_NA_EAST,
        "us-east.stratum.slushpool.com",
        "3333"
    }
#endif
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

/* *****************************************************************************
**                                  API
** ************************************************************************** */
eCOM_Mgr_Status_t COM_Mgr_Setup(void)
{
    eCOM_Mgr_Status_t eRetVal;
    word dwIndex;

    /* Initialise local variables */
    eRetVal = 0;

    /* Reset modules private data */
    ResetData();

    /* Shall we clean up the result here ? */

    /* Visit connection list */
    for( dwIndex=0; dwIndex < stLocalDesc.dwCnxNum; dwIndex++ )
    {
        if ( NULL != stLocalDesc.pstCnx[dwIndex].pfnCnxClient_Setup )
        {
            /* Setup connections */
            stLocalDesc.pstCnx[dwIndex].pfnCnxClient_Setup(stLocalDesc.pstCnx[dwIndex].pstCnxClient_Entry);
        }

        if( eCOM_MGR_PRCL_STRATUM == stLocalDesc.pstCnx[dwIndex].ePrclType )
        {
            /* Protocol specific */
        }

        /* old getwork protocol support */
        if( eCOM_MGR_PRCL_GETWORK == stLocalDesc.pstCnx[dwIndex].ePrclType )
        {
            /* Protocol specific */
        }
    }

    return eRetVal;
}

eCOM_Mgr_Status_t COM_Mgr_Init(void)
{
    eCOM_Mgr_Status_t eRetVal;
    word dwIndex;

    /* Initial locals, pessimist hypothesis */
    eRetVal = 0;

    /* Prepare connection start */
    for( dwIndex=0; dwIndex < stLocalDesc.dwCnxNum; dwIndex++ )
    {
        /* Prepare threads */
        if ( NULL != stLocalDesc.pstCnx[dwIndex].pfnCnxClient_Init )
        {
            /* Update return variable consequently */
            eRetVal = 1;

            /* Init connections */
            stLocalDesc.pstCnx[dwIndex].pfnCnxClient_Init();
        }
    }

    /* Now check the status of connection. */

    /* If faulty connection is present, retry until timeout. */

    return eRetVal;
}

/* Things to do in the background task */
void COM_Mgr_Bkgnd(void)
{
    word dwIndex;

    /* Prepare connection start */
    for( dwIndex=0; dwIndex < stLocalDesc.dwCnxNum; dwIndex++ )
    {
        /* Prepare threads */
        if ( NULL != stLocalDesc.pstCnx[dwIndex].pfnCnxClient_Bkgnd )
        {
            stLocalDesc.pstCnx[dwIndex].pfnCnxClient_Bkgnd();
        }
    }

    /* Maintain connection, make sure it is stable and reliable */

    /* Client connection recovery strategy ? */

    return;
}

/* *****************************************************************************
**                            LOCALS ROUTINES Defn
** ************************************************************************** */
static void ResetData(void)
{
    memset((void*)&stLocalData,0x00,sizeof(COM_Mgr_Data_t));
    return;
}
