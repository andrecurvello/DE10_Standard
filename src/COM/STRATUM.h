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
#ifndef STRATUM_PRCL_HEADER_H
#define STRATUM_PRCL_HEADER_H

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "COM_mgr.h" /* Include COM defs */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
#define RBUFSIZE (8192)         /* receive buffer size */

/* *****************************************************************************
**                              TYPEDEFs
** ************************************************************************** */

typedef enum
{
    eSTRATUM_ID_SG=0,
#if 0
    eSTRATUM_ID_CN_0,
    eSTRATUM_ID_CN_1,
    eSTRATUM_ID_CN_2,
    eSTRATUM_ID_EU,
    eSTRATUM_ID_NA_EAST,
#endif
    eSTRATUM_ID_TOTAL

}eSTRATUM_Pool_Id_t;

/* *****************************************************************************
**                                  API
** ************************************************************************** */
eCOM_Mgr_Status_t STRATUM_Ptcl_Setup( const COM_Mgr_CnxTableEntry_t * const pstComDesc);
eCOM_Mgr_Status_t STRATUM_Ptcl_Init(void);  /*  */
void STRATUM_Ptcl_Bkgnd(void);              /*  */

void STRATUM_Ptcl_Monitor(void);           /* Used to monitor connection and get
                                           ** network related data */

void STRATUM_Ptcl_Publish(void);           /* Publish demands */

#endif
