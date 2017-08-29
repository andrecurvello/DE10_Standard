/* *****************************************************************************
**
**                       Standalone bitcoin miner
**
** Project      : DE10 Standard kit review
** Module       : COM_mgr
**
** Description  : General manager of the COM controller
**
** ************************************************************************** */

/* *****************************************************************************
**  REVISION HISTORY
** Date         Inits   Description
** ----------------------------------------------------------------------------
** 08.08.17     bd      [no issue number] File creation
**
** ************************************************************************** */
#ifndef COM_MANAGER_H
#define COM_MANAGER_H

/* *****************************************************************************
**                          SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "Macros.h" /* Divers macros definitions */
#include "Types.h"  /* Legacy types definitions */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */
/* Status enum for interaction with COMs. The idea here is to stay general */
typedef enum
{
    eCOM_MGR_SUCCESS=0,
    eCOM_MGR_PENDING,
    eCOM_MGR_TIMEOUT,
    eCOM_MGR_FAIL

}eCOM_Mgr_Status_t;

typedef struct
{
    const byte byIdentifier;
    const char * const abyUrl;  /* char - avoid signedness compiler warnings */
    const char * const abyPort;

} COM_Mgr_CnxTableEntry_t;

/* *****************************************************************************
**                                  API
** ************************************************************************** */
eCOM_Mgr_Status_t COM_Mgr_Setup(void); /* Protocol config and so on. Callable once */
eCOM_Mgr_Status_t COM_Mgr_Init(void);  /* Protocol config and so on. Callable more than once */

void COM_Mgr_Bkgnd(void); /* Background task */

#endif
