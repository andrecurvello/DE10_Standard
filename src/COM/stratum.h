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

/* *****************************************************************************
**                                  API
** ************************************************************************** */
void STRATUM_Ptcl_Setup(void);             /* Will probably need a setup */
void STRATUM_Ptcl_Init(struct pool *pool); /*  */
void STRATUM_Ptcl_Bkgnd(void);             /*  */

#endif
