/* *****************************************************************************
**
**                       Standalone bitcoin miner
**
** Project      : User Interface manager
** Module       : UI_Mgr.c
**
** Description  : Modules that deal with buttons, 7sg display and LCD.
**
** ************************************************************************** */

/* *****************************************************************************
**  REVISION HISTORY
** Date         Inits   Description
** ----------------------------------------------------------------------------
** 28.05.17     bd      [no issue number] File creation
**
** ************************************************************************** */
#ifndef UI_MANAGER_H
#define UI_MANAGER_H

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
void UI_Mgr_Setup(void);
void UI_Mgr_Init(void);

void UI_Mgr_Bkgnd(void); /* user interface backgrounf task */

#endif
