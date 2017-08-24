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
#include "design.h"  /* General design macros */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
/* All sizes are in byte */
#define NONCE1_SIZE (4)

/* Fixed by the protocol and the cryptographic scheme */
#define JOBID_SIZE (6)
#define HASH_SIZE (32)     /* we call HASH as merkle root or branch */
#define COINBASE1_SIZE (60)
#define COINBASE2_SIZE (53)
#define MERKLE_SIZE (32)
#define BLOCK_VER_SIZE (4)
#define NTIME_SIZE (4)
#define NBITS_SIZE (4)

#define COINBASE_SIZE (512)
#define BLOCKHEADER_SIZE (512)
#define TARGET_SIZE (32)
#define NONCE_SIZE (32) /* That is a maximum size. The real actual size is wN2size */

#define MERKLE_TREE_MAX_DEPTH (32) /* maximum merkle tree depth supported */

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */
typedef enum  {
    eSCHEDULER_FAILOVER = 0,
    eSCHEDULER_ROUNDROBIN,
    eSCHEDULER_ROTATE,
    eSCHEDULER_LOADBALANCE,
    eSCHEDULER_BALANCE,
    eSCHEDULER_LEAST_DIFF

} eSCHEDULER_Strgy_Type_t;

/* You will find in comment the example of block #25096 */
typedef struct {
    /* From JSON, all in good order/endianess */
    byte abyNonce1[NONCE1_SIZE];
    word wN2size;

    byte abyJobId[JOBID_SIZE];
    byte abyPrevHash[HASH_SIZE];
    byte abyCoinBase1[COINBASE1_SIZE];
    byte abyCoinBase2[COINBASE2_SIZE];
    byte aabyMerkleBranch[MERKLE_TREE_MAX_DEPTH][MERKLE_SIZE];
    byte abyBlckVer[BLOCK_VER_SIZE];
    byte abyNbits[NBITS_SIZE];
    byte abyNtime[NTIME_SIZE];
    double doDiff;

    /* Need the array of nonces */
    byte abyTarget[TARGET_SIZE];
    byte byPoolId;
    byte byPoolPrio;
    boolean bIsFree;
    byte aabyNonce[NUM_BMC_CORES][NONCE_SIZE];
    byte aabyCoinBase[NUM_BMC_CORES][COINBASE_SIZE];
    byte aabyBlockHeader[NUM_BMC_CORES][BLOCKHEADER_SIZE];

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

stSCHEDULER_Work_t * SCHEDULER_PopWork(const byte byPoolIdx);  /* Schedule work and push to FPGA */
void SCHEDULER_PushWork(const stSCHEDULER_Work_t * const pstWork); /* Transfer work to scheduler */

void SCHEDULER_SetStrategy(const eSCHEDULER_Strgy_Type_t eStrategy); /* Set scheduling method */

#endif
