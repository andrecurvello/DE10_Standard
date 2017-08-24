/* *****************************************************************************
**
**                       Standalone bitcoin miner
**
** Project      : DE10 Standard project
** Module       : SCHEDULER
**
** Description  : Mining scheduler
**
** ************************************************************************** */

/* *****************************************************************************
**  REVISION HISTORY
** Date         Inits   Description
** ----------------------------------------------------------------------------
** 21.08.17     bd      [no issue number] File creation
**
** ************************************************************************** */

/* *****************************************************************************
**                          SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "Macros.h" /* Divers macros definitions */
#include "Types.h"  /* Legacy types definitions */

#include <endian.h> /* Endianess definitions */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "SCHEDULER.h" /* module definitions */

#include "FPGA_Drv.h"  /* Interaction with the FPGA fabric */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
/* Maximum number of work */
#define WORK_QUEUE_SIZE (20)

#define BLOCK_HEADER_PADDING "000000800000000000000000000000000000000000000000000000000000000000000000000000000000000080020000"
#define MASK_8_BYTES (0xFFFFFFFFFFFFFFFF)

/* Target related macros */
#define TGT_OFFS_64 (64)
#define TGT_OFFS_128 (128)
#define TGT_OFFS_192 (192)
#define TGT_OFFS_208 (208)
#define TGT_DIFF_1 ((double)(0xFFFF*((double)(1<<TGT_OFFS_208))))

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */
typedef enum  {
    eSCHEDULER_RECALIBRATION = 0, /* Recalibration of nonces */
    eSCHEDULER_COMPUTING,         /* FPGA is computing work, wait for hw notification */
    eSCHEDULER_READY              /* computation has finished. interpret the result */

} eSCHEDULER_Type_t;

typedef struct{
    stSCHEDULER_Work_t astWorkQueue[WORK_QUEUE_SIZE]; /* This work as a LIFO */
    stSCHEDULER_Work_t *pstCurrent;
    eSCHEDULER_Strgy_Type_t eStrategy;
    eSCHEDULER_Type_t eState;
    byte byNumWork;

} stSCHEDULER_Data_t;

/* *****************************************************************************
**                                 GLOBALS
** ************************************************************************** */

/* *****************************************************************************
**                                 LOCALS
** ************************************************************************** */
static stSCHEDULER_Data_t stLocalData;

/* *****************************************************************************
**                              LOCALS ROUTINES
** ************************************************************************** */
/* Difficulty and Target calculation */
static void SetTarget(byte * pstDest, double doDifficulty);

/* Pre-FPGA treatment */
static void PrepareNonceArray(stSCHEDULER_Work_t *pstWork);
static void PrepareCoinbase(stSCHEDULER_Work_t *pstWork);

/* Work queue managment */
static stSCHEDULER_Work_t * SelectWork(void);

/* Module private data management */
static void ResetData(void);

/* *****************************************************************************
**                                  API
** ************************************************************************** */
void SCHEDULER_Setup(void) /* Setup module, make sure we can use the FPGA */
{
    /* Reset data */
    ResetData();

    return;
}

void SCHEDULER_Init(void)     /* Reinit the work queue */
{
    /* Initialize working queue */
    stLocalData.byNumWork = 0;
    stLocalData.pstCurrent = &stLocalData.astWorkQueue[0];

    /* Initialize strategy */
    stLocalData.eStrategy = eSCHEDULER_LEAST_DIFF;

    /* Initialize state machine control variable */
    stLocalData.eState = eSCHEDULER_READY;

    return;
}

void SCHEDULER_Bkgnd(void)
{
    stSCHEDULER_Work_t * pstCurrent;
    dword dwFPGAState;

    /* Initialize locals, retrieve data */
    pstCurrent = stLocalData.pstCurrent;
    dwFPGAState = 0;

    switch( stLocalData.eState )
    {
        case eSCHEDULER_RECALIBRATION :
        {
            /* Recalculate nonces */
            PrepareNonceArray(pstCurrent);

            /* Get coinbase */
            PrepareCoinbase(pstCurrent);

            dwFPGAState = FPGA_Drv_StageWork( pstCurrent );

            /* Now ready trigger transition to next state */
            stLocalData.eState = eSCHEDULER_COMPUTING;

            break;
        }
        case eSCHEDULER_COMPUTING :
        {
            /*
            ** FPGA fabric computing the batch. Crunching big number real'hard.
            */

            /* Feed FPGA */
            dwFPGAState = FPGA_Drv_GetStatus();

            /* Now ready trigger transition to next state, go to ready in all cases */
            if( /* Need to be interrupted ? */ )
            {
                /* Purge FPGA from now useless work */

                stLocalData.eState = eSCHEDULER_READY;
            }

            /*  ---- OR ---- */
            if( /* Need to recalibrate ? */ )
            {
                stLocalData.eState = eSCHEDULER_RECALIBRATION;
            }

            break;
        }
        case eSCHEDULER_READY :
        {
            /* Interpret the result, two options really :
            ** i)  No good result, recalibrate and compute.
            ** ii) Good result found :), prepare and send share.
            */

            /* Mark work as done or abandone if notrelevant anymore, see bClear in stratum */

            /* Get next work */
            if( /* need work update ? */ )
            {
                pstCurrent = SelectWork();

                /* New work, trigger transition to calibration state */
                stLocalData.eState = eSCHEDULER_RECALIBRATION;
            }

            /* If no new work is present, just hang in that state */

            break;
        }
        default:
        {
            break;
        }
    }

    return;
}

/* Can be use in order to determine if a share is available for a specific pool */
stSCHEDULER_Work_t * SCHEDULER_PopWork(const byte byPoolIdx)
{
    stSCHEDULER_Work_t * pstReturn;

    /* Initialize locals */
    pstReturn = NULL;

    /* Poll FPGA for answers */

    return pstReturn;
}

/* ************************************************************************** */
void SCHEDULER_PushWork(const stSCHEDULER_Work_t * const pstWork)
/* *****************************************************************************
** Input  : Work structure to be pushed
** Output : -
** Return : -
**
** Description  : The aim here is to push the work to the head of the key,
**                determine a suitable target based upon the difficulty factor
**                that we received. Note that Get Head and GetTail modify the
**                logical state of the queue. See function description for more
**                details.
**
** ************************************************************************** */
{
    stSCHEDULER_Work_t *pstLocalWork;
    dword dwIndex;

    /* Initialise locals */
    pstLocalWork = NULL;

    /* If we are full, let protocol and manager know */
    if(   ( NULL != pstWork )
       && ( WORK_QUEUE_SIZE > stLocalData.byNumWork )
      )
    {
        /* Looking for a free slot */
        for( dwIndex = 0; dwIndex < WORK_QUEUE_SIZE; dwIndex++ )
        {
            /* Retrieve data */
            pstLocalWork = stLocalData.astWorkQueue[dwIndex];

            /* Found free slot ? */
            if( TRUE == pstLocalWork->bIsFree )
            {
                /* Increment number of elements */
                stLocalData.byNumWork++;

                /* Prepare slot */
                break;
            }
        }

        /* Put data in the free work slot */
        memcpy(pstLocalWork,pstWork,sizeof(stSCHEDULER_Work_t));

        /* Mark slot as taken */
        pstLocalWork->bIsFree = FALSE;

        /* Calculate target from difficulty parameter */
        SetTarget( pstLocalWork->abyTarget, pstLocalWork->doDiff );
    }

    return;
}

/* ************************************************************************** */
void SCHEDULER_SetStrategy(const eSCHEDULER_Strgy_Type_t eStrategy) /* Set scheduling method */
/* *****************************************************************************
** Input  : Strategy type
** Output : -
** Return : -
**
** Description  : Set mining strategy.
**
** ************************************************************************** */
{
    /* Changing mining strategy */
    stLocalData.eStrategy = eStrategy;

    return;
}

/* *****************************************************************************
**                                Local routines
** ************************************************************************** */

/* ************************************************************************** */
static void SetTarget(byte * pstDest, double doDifficulty)
/* *****************************************************************************
** Input  : Double representing the difficulty
** Output : Pointer to destination array of byte
** Return : None for the time being
**
** Description  : Calculate target given the difficulty. Essentially, we get a
**                floating number (actually generally an integer) and calculate
**                the ration :
**                             Difficulty_1_target, that is 0x00000000FFFF << (26*8)
**                Difficulty = -------------------------------------------------
**                                             Current target
**
**                The format used by the bitcoin scheme to represent big numbers
**                is the "compact" format. See https://en.bitcoin.it/wiki/Difficulty
**                for more info.
**
**                Ex : 0x000000000FFFF << (26*8) (rounded) is 0x00FFFF*(2**(8*(0x1d-3)))
**                     which gives 0x1D00FFFF in compact format
**
**                     Don't forget, "real" Difficulty_1_target is
**
**                     0x00000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
**
** ************************************************************************** */
{
    double dDiffRatio;
    double dChunk;
    qword *pqwData64;
    byte byTarget[TARGET_SIZE];

    /* Initialize variables */
    dDiffRatio = (double)( TGT_DIFF_1 / doDifficulty ); /* Get difficulty ratio */

    /*
    ** This has been voluntarily implemented like this and not in the loop in
    ** order to keep it clear and understandable.
    */

    /* 1st chunk */
    dChunk = ( MASK_8_BYTES & mBITS_RightShiftDouble(dDiffRatio,TGT_OFFS_192) );
    pqwData64 = (qword *)(byTarget + 24);
    *pqwData64 = htole64(dChunk);

    /* 2nd chunk */
    dChunk = ( MASK_8_BYTES & mBITS_RightShiftDouble(dDiffRatio,TGT_OFFS_128) );
    pqwData64 = (qword *)(byTarget + 16);
    *pqwData64 = htole64(dChunk);

    /* 3rd chunk */
    dChunk = ( MASK_8_BYTES & mBITS_RightShiftDouble(dDiffRatio,TGT_OFFS_64) );
    pqwData64 = (qword *)(byTarget + 8);
    *pqwData64 = htole64(dChunk);

    /* 4th chunk */
    dChunk = ( MASK_8_BYTES & dDiffRatio );
    pqwData64 = (qword *)(byTarget);
    *pqwData64 = htole64(dChunk);

    return;
}

static void PrepareNonceArray(stSCHEDULER_Work_t * const pstWork)
{
    dword dwIndex;

    /* Update the nonce array for the next batch */
    if ( NULL != pstWork )
    {
        for ( dwIndex = 0; dwIndex < NUM_BMC_CORES; dwIndex++ )
        {
            /* Increment nonce. Beware of the size as we get it in the connection phase ! */
            *(pstWork->aabyNonce[dwIndex]) += NUM_BMC_CORES;
        }
    }

    return;
}

static void PrepareCoinbase(stSCHEDULER_Work_t *pstWork)
{
    dword dwIndex;
    byte * pbyData;

    /* Initialize pointer to data */
    pbyData = NULL;

    /* Basic sanity check */
    if ( NULL != pstWork )
    {
        for ( dwIndex = 0; dwIndex < NUM_BMC_CORES; dwIndex++ )
        {
            /* Retrieve data */
            pbyData = pstWork->aabyCoinBase[dwIndex];

            /*
            ** Update coinbases as follow :
            ** Coinbase = CoinBase_1 ## ExtraNonce_1 ## CoinBase_2 ## ExtraNonce_2
            */

            /* Cb1 */
            *(pbyData) = pstWork->abyCoinBase1 ;
            pbyData += strlen(pstWork->abyCoinBase1);

            /* ExtN1 */
            *(pbyData) = pstWork->abyNonce1 ;
            pbyData += strlen(pstWork->abyNonce1);

            /* Cb2 */
            *(pbyData) = pstWork->abyCoinBase2 ;
            pbyData += strlen(pstWork->abyCoinBase2);

            /* ExtN2 */
            *(pbyData) = *(pstWork->aabyNonce[dwIndex]) ;
        }
    }

    return;
}

static stSCHEDULER_Work_t *SelectWork(void)
{
    stSCHEDULER_Work_t * pstWork;
    stSCHEDULER_Work_t * pstCompare;
    dword dwIndex;

    /* Init locals */
    pstWork = NULL;
    pstCompare = NULL;

    switch( stLocalData.eStrategy )
    {
        case eSCHEDULER_FAILOVER:
        case eSCHEDULER_ROUNDROBIN:
        case eSCHEDULER_ROTATE:
        case eSCHEDULER_LOADBALANCE:
        case eSCHEDULER_BALANCE:
        case eSCHEDULER_LEAST_DIFF:
        {
            /* Init the work */
            pstWork = &stLocalData.astWorkQueue[0];

            /* Find the smallest difficulty */
            for( pstCompare = &stLocalData.astWorkQueue[0];
                 pstCompare == &stLocalData.astWorkQueue[WORK_QUEUE_SIZE];
                 pstCompare++
               )
            {
                if( pstCompare->doDiff < pstWork->doDiff )
                {
                    pstWork = pstCompare;
                }
            }
            break;
        }
        default:
        {
            break;
        }
    }

    return pstWork;
}

static void ResetData(void)
{
    /* Reset local data */
    memset(&stLocalData,0x00,sizeof(stSCHEDULER_Data_t));
    return;
}
