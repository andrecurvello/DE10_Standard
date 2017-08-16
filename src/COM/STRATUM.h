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
eCOM_Mgr_Status_t STRATUM_Ptcl_Setup(void); /* Will probably need a setup */
eCOM_Mgr_Status_t STRATUM_Ptcl_Init(void);  /*  */
void STRATUM_Ptcl_Bkgnd(void);              /*  */

/*  */
void STRATUM_Ptcl_Monitor(void);           /* Used to monitor connection and get
                                           ** network related data */

void STRATUM_Ptcl_Publish(void);           /* Publish demands */

#endif
