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
#ifndef SCHEDULER_H
#define SCHEDULER_H

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
typedef enum  {
    eSCHED_FAILOVER = 0,
    eSCHED_ROUNDROBIN,
    eSCHED_ROTATE,
    eSCHED_LOADBALANCE,
    eSCHED_BALANCE

} eSCHEDULER_Strgy_Type_t;

typedef struct {
    qword qwTarget;
    qword qwSDiff;
    byte *abyNonce1;
    word wN2size;
    byte *abyJobId;
    byte *abyPrevHash;
    byte *abyCoinBase1;
    byte *abyCoinBase2;
    byte **abyMerkleBranch;
    byte *abyBlckVer;
    byte *abyNbits;
    byte *abyNtime;

} stSCHEDULER_Work_t;

#if 0
typedef struct {

} eSCHEDULER_Demands_t;

typedef struct {

} eSCHEDULER_Resul_t;
#endif

/* *****************************************************************************
**                                  API
** ************************************************************************** */
void SCHEDULER_Setup(void); /* Setup mudule, make sure we can use the FPGA */
void SCHEDULER_Init(void);  /* Reinit the work queue */

void SCHEDULER_Bkgnd(void); /* queue and donkey work management */

void SCHEDULER_PopWork(void);  /* Schedule work and push to FPGA */
void SCHEDULER_PushWork(void); /*  */

void SCHEDULER_SetStrategy(const eSCHEDULER_Strgy_Type_t eStrategy); /* Set scheduling method */

#endif
