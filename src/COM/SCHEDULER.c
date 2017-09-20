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

#include <stdio.h>  /* Standard IO defns */
#include <endian.h> /* Endianess definitions */
#include <string.h> /* memset and memcpy */

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
    dword dwWorkIterationCounter;

} stSCHEDULER_Data_t;

/* *****************************************************************************
**                                 GLOBALS
** ************************************************************************** */

/* *****************************************************************************
**                                 LOCALS
** ************************************************************************** */
static stSCHEDULER_Data_t stLocalData;

/*
** Target related locals. Unfortunately can't use anything cleaner like,
** Masks and bits offset with double type.
*/
static const double doTrueDiffOne = 26959535291011309493156476344723991336010898738574164086137773096960.0;
static const double doBits192 = 6277101735386680763835789423207666416102355444464034512896.0;
static const double doBits128 = 340282366920938463463374607431768211456.0;
static const double doBits64 = 18446744073709551616.0;

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

/* ************************************************************************** */
void SCHEDULER_Setup(void)
/* **************************************************************************
** Input  : -
** Output : -
** Return : -
**
** Description  : Setup module, make sure we can use the FPGA
**
** ************************************************************************** */
{
    /* Reset data */
    ResetData();

    return;
}

/* ************************************************************************** */
void SCHEDULER_Init(void)     /* Reinit the work queue */
/* **************************************************************************
** Input  : -
** Output : -
** Return : -
**
** Description  : Init mining Hw
**
** ************************************************************************** */
{
    dword dwIndex;

    /* Initialize working queue */
    stLocalData.byNumWork = 0;
    stLocalData.pstCurrent = &stLocalData.astWorkQueue[0];

    /* Initialize strategy */
    stLocalData.eStrategy = eSCHEDULER_LEAST_DIFF;

    /* Initialize state machine control variable */
    stLocalData.eState = eSCHEDULER_READY;

    /* General  */
    stLocalData.dwWorkIterationCounter = 0;

    for(dwIndex=0;dwIndex<WORK_QUEUE_SIZE;dwIndex++)
    {
    	stLocalData.astWorkQueue[dwIndex].bIsFree=TRUE;
    }


    return;
}

/* ************************************************************************** */
void SCHEDULER_Bkgnd(void)
/* **************************************************************************
** Input  : -
** Output : -
** Return : -
**
** Description  : Continuously feed the FPGA.
**
** ************************************************************************** */
{
    dword dwIndex;
    stSCHEDULER_Work_t * pstCurrent;

    /* Initialize locals, retrieve data */
    pstCurrent = stLocalData.pstCurrent;

    switch( stLocalData.eState )
    {
        case eSCHEDULER_READY :
        {
        	/* Is there a work ready in the queue ? */
			if( 0 != stLocalData.byNumWork )
			{
	            /*
	            ** Interpret the result, two options really :
	            ** i)  No good result, recalibrate and compute.
	            ** ii) Good result found :), prepare and send share.
	            */

	            /* Mark work as done or abandon if not relevant anymore, see bClear in stratum */

	            /* Get next work */
	            pstCurrent = SelectWork();

	            /* Preset nonce array */
	            for( dwIndex = 0; dwIndex < NUM_BMC_CORES; dwIndex++ )
	            {
	                /* WRONG should be a string still */
	                pstCurrent->aabyNonce[dwIndex][0]=dwIndex;
	            }

	            /* New work, trigger transition to calibration state */
	            stLocalData.eState = eSCHEDULER_RECALIBRATION;
			}


            /* If no new work is present, just hang in that state */

            break;
        }
        case eSCHEDULER_RECALIBRATION :
        {
            /* Recalculate nonces */
            if ( 0 != stLocalData.dwWorkIterationCounter )
            {
                PrepareNonceArray(pstCurrent);
            }

            /* Increment the work iteration counter */
            stLocalData.dwWorkIterationCounter++;

            /* Get coinbase */
            PrepareCoinbase(pstCurrent);

            /* Feed FPGA */
            FPGA_Drv_StageWork( pstCurrent );

            /* Now ready trigger transition to next state */
            stLocalData.eState = eSCHEDULER_COMPUTING;

            break;
        }
        case eSCHEDULER_COMPUTING :
        {
            /*
            ** FPGA fabric computing the batch. Crunching big number real'hard.
            */
            if( eFPGA_COMPUTING != FPGA_Drv_GetStatus() )
            {
#if 0
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
#endif
                /* Do nothing for the time being */
            }

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
            pstLocalWork = &stLocalData.astWorkQueue[dwIndex];

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
    double doDiffRatio;
    double doChunk;
    qword *pqwData64;
    dword dwIdx;

    printf("Diff %lf\n",doDifficulty);
    /* Initialize variables */
    doDiffRatio = (double)( doTrueDiffOne / doDifficulty ); /* Get difficulty ratio */
    printf("DiffRatio %lf\n",doDiffRatio);

    /*
    ** This has been voluntarily implemented like this and not in the loop in
    ** order to keep it clear and understandable.
    */

    /* REMINDER :
    ** Unfortunately can't use anything cleaner like masks and bit offsets with
    ** double type :(
    */

    /* 1st chunk */
    doChunk = (doDiffRatio/doBits192); /* Right shift for double */
    pqwData64 = (qword *)(pstDest + 24); /* Get target buffer */
    *pqwData64 = htole64(doChunk); /* Write/convert */
    doChunk *= doBits192; /* Offset of 192 again to be able to mask for the second chunk */
    doDiffRatio = (doDiffRatio - doChunk); /* Mask out the 1st chunk */

    /* 2nd chunk */
    doChunk = (doDiffRatio/doBits128); /* Right shift for double */
    pqwData64 = (qword *)(pstDest + 16); /* Get target buffer */
    *pqwData64 = htole64(doChunk); /* Write/convert */
    doChunk *= doBits128; /* Offset of 128 again to be able to mask for the third chunk */
    doDiffRatio = (doDiffRatio - doChunk); /* Mask out the 2nd chunk */

    /* 3rd chunk */
    doChunk = (doDiffRatio/doBits64); /* Right shift for double */
    pqwData64 = (qword *)(pstDest + 8);
    *pqwData64 = htole64(doChunk);
    doChunk *= doBits64; /* Offset of 64 again to be able to mask for the fourth chunk */
    doDiffRatio = (doDiffRatio - doChunk); /* Mask out the 3rd chunk */

    /* 4th chunk */
    doChunk = doDiffRatio;
    pqwData64 = (qword *)(pstDest);
    *pqwData64 = htole64(doChunk);

    printf("Target :\n");
    printf("0x");
    for(dwIdx=0;dwIdx<TARGET_SIZE;dwIdx++)
    {
        printf("%.2x",pstDest[dwIdx]);
    }
    printf("\n");


    return;
}

/* ************************************************************************** */
static void PrepareNonceArray(stSCHEDULER_Work_t * const pstWork)
/* *****************************************************************************
** Input  : Work structure to prepare
** Output : -
** Return : -
**
** Description  : Prepare nonce array for FPGA stage work.
**
** ************************************************************************** */
{
    dword dwIndex;

    /* Update the nonce array for the next batch */
    if ( NULL != pstWork )
    {
        for ( dwIndex = 0; dwIndex < NUM_BMC_CORES; dwIndex++ )
        {
            /* Increment nonce. Beware of the size as we get it in the connection phase ! */
            /* WRONG should be a string still */
            *(pstWork->aabyNonce[dwIndex]) += NUM_BMC_CORES;
        }
    }

    return;
}

/* ************************************************************************** */
static void PrepareCoinbase(stSCHEDULER_Work_t *pstWork)
/* *****************************************************************************
** Input  : Work structure to prepare
** Output : -
** Return : -
**
** Description  : Putting coinbase together.
**
** ************************************************************************** */
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
            memcpy(pbyData,pstWork->abyCoinBase1,strlen((char*)pstWork->abyCoinBase1));
            pbyData += (word)strlen((char*)pstWork->abyCoinBase1);

            /* ExtN1 */
            memcpy(pbyData,pstWork->abyNonce1,strlen((char*)pstWork->abyNonce1));
            pbyData += (word)strlen((char*)pstWork->abyNonce1);

            /* Cb2 */
            memcpy(pbyData,pstWork->abyCoinBase2,strlen((char*)pstWork->abyCoinBase2));
            pbyData += (word)strlen((char*)pstWork->abyCoinBase2);

            /* ExtN2 */
            memcpy(pbyData,pstWork->aabyNonce[dwIndex],strlen((char*)(pstWork->aabyNonce[dwIndex])));
        }
    }

    return;
}

/* ************************************************************************** */
static stSCHEDULER_Work_t *SelectWork(void)
/* *****************************************************************************
** Input  : -
** Output : Pointer to next work structure.
** Return : -
**
** Description  : Select next empty element in the queue according to current strategy
**
** ************************************************************************** */
{
    stSCHEDULER_Work_t * pstWork;
    stSCHEDULER_Work_t * pstCompare;

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
                if(   ( 0!= pstCompare->doDiff )
               	   && ( pstCompare->doDiff < pstWork->doDiff )
				  )
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

/* ************************************************************************** */
static void ResetData(void)
/* *****************************************************************************
** Input  : -
** Output : -
** Return : -
**
** Description  : Reset modules data structures.
**
** ************************************************************************** */
{
    /* Reset local data */
    memset(&stLocalData,0x00,sizeof(stSCHEDULER_Data_t));
    return;
}
