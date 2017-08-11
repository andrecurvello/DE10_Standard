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
**                                  API
** ************************************************************************** */
dword COM_Mgr_Setup(void); /* Protocol config and so on. Callable once */
dword COM_Mgr_Init(void);  /* Protocol config and so on. Callable more than once */

dword COM_Mgr_Bkgnd(void); /* Background task */

#endif
