/* *****************************************************************************
**
**                       DE10 Standard project
**
** Project      : DE10 standard project
** Module       : FPGA_Drv
**
** Description  : Provide access to the FPGA fabric.
**
** ************************************************************************** */

/* *****************************************************************************
**  REVISION HISTORY
** Date         Inits   Description
** ----------------------------------------------------------------------------
** 28.05.17     bd      [no issue number] File creation
**
** ************************************************************************** */

/* *****************************************************************************
**                          SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "Macros.h" /* Divers macros definitions */
#include "Types.h"  /* Legacy types definitions */

#include <signal.h>   /* signal handling */
#include <stdio.h>    /* Standard IO definitions */
#include <unistd.h>   /* Standard symbolic constants and types */
#include <fcntl.h>    /* Manipulate file descriptor */
#include <sys/mman.h> /* Memory mapping */
#include <math.h>     /* Math defns */
#include <stdlib.h>   /* Libc */
#include <string.h>   /* String defns */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "FPGA_Drv.h"       /* Module's header */

#include "hwlib.h"          /* General ALTERA HW definitions */
#include "socal/socal.h"    /* ALTERA Socal defns */
#include "socal/hps.h"      /* Hardware processing system (controller)  defns */
#include "socal/alt_gpio.h" /* ALTERA GPIO defns */
#include "hps_0.h"          /* FPGA interface defns */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
#define HW_REGS_BASE ( ALT_STM_OFST )     /* Altera memory offset */
#define HW_REGS_SPAN ( 0x04000000 )       /* Address range */
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 ) /* Spanning mask */

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */
typedef struct
{
    word wFileDesc;
    void *pvVirtBase;

} FPGA_Drv_Data_t;

#if 0
typedef struct
{
    word wFileDesc;
    void *pvVirtBase;

} FPGA_Drv_Result_t;
#endif

/* *****************************************************************************
**                                 GLOBALS
** ************************************************************************** */

/* *****************************************************************************
**                                 LOCALS
** ************************************************************************** */
static FPGA_Drv_Data_t stLocalData;
#if 0
static FPGA_Drv_Result_t stLocalResults;
#endif

/* *****************************************************************************
**                              LOCALS ROUTINES
** ************************************************************************** */
static void ResetData(void);

/* *****************************************************************************
**                                  API
** ************************************************************************** */

/* ************************************************************************** */
dword FPGA_Drv_Setup(void)
/* *****************************************************************************
** Input  : -
** Output : -
** Return : 0 In case of failure. 1 otherwise.
**
** Description  : Setup hw. Get acces to memory and map physical address to virtual so the
**                application can use it.
**
** ************************************************************************** */
{
    dword dwRetVal;

    /* Initialize locals pessimistically  */
    dwRetVal = 0;

    /* reset internal data */
    ResetData();

#if 0
    /* Publish data */
    pstFPGA_Drv_Results = &stLocalResults;
#endif

    /* Get access to memory */
    stLocalData.wFileDesc = open( "/dev/mem", ( O_RDWR | O_SYNC ) );
    if( -1  != stLocalData.wFileDesc )
    {
        /*
        ** Map the address space for the FPGA into user space so we can
        ** interact with them. we'll actually map in the entire CSR span of the
        ** HPS since we want to access various registers within that span
        */
        stLocalData.pvVirtBase = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, stLocalData.wFileDesc, HW_REGS_BASE );
        if( MAP_FAILED != stLocalData.pvVirtBase )
        {
            /* Update return value */
            dwRetVal = 1;
        }
    }

    if( 0 == dwRetVal )
    {
        printf( "ERROR: mmap() or open() failed...\n" );
    }

    return dwRetVal;
}

/* ************************************************************************** */
dword FPGA_Drv_Init(void)
/* *****************************************************************************
** Input  : -
** Output : -
** Return : 0 for the time being.
**
** Description  : Init local descriptor.
**
** ************************************************************************** */
{
    dword dwRetVal;

    /* Initialize locals pessimistically  */
    dwRetVal = 0;

    /* Nothing to do here for the time being */

    return dwRetVal;
}

/* ************************************************************************** */
dword FPGA_Drv_StageWork(stSCHEDULER_Work_t * const pstWork)
/* *****************************************************************************
** Input  : Pointer to work structure to be staged for work.
** Output : -
** Return : 0 In case of failure. 1 otherwise.
**
** Description  : Give a work package that is in a format allowing FPGA mining.
**                That is hex and not strings.
**
** ************************************************************************** */
{
    dword dwRetVal;
    dword dwIndex;
#if 0
    dword dwIdx;
    dword dwMerkleIdx;
#endif

    /* Initialize locals */
    dwRetVal = 0;

    if( NULL != pstWork )
    {
        for ( dwIndex = 0; dwIndex < NUM_BMC_CORES; dwIndex++ )
        {
#if 0
            /* Debug */
            printf("\n--------------------------------------\n");
            printf("pstWork->abyNonce1 : 0x");
			for( dwIdx=0;dwIdx<NONCE1_SIZE;dwIdx++ )
			{
	            printf("%.2x",pstWork->abyNonce1[dwIdx]);
			}
            printf("\n");

            printf("pstWork->wN2size : %d\n",pstWork->wN2size);

            printf("pstWork->abyJobId : 0x");
			for( dwIdx=0;dwIdx<JOBID_SIZE;dwIdx++ )
			{
	            printf("%.2x",pstWork->abyJobId[dwIdx]);
			}
            printf("\n");

            printf("pstWork->abyPrevHash : 0x");
			for( dwIdx=0;dwIdx<HASH_SIZE;dwIdx++ )
			{
	            printf("%.2x",pstWork->abyPrevHash[dwIdx]);
			}
            printf("\n");

            printf("pstWork->abyCoinBase1 : 0x");
			for( dwIdx=0;dwIdx<COINBASE1_SIZE;dwIdx++ )
			{
	            printf("%.2x",pstWork->abyCoinBase1[dwIdx]);
			}
            printf("\n");

            printf("pstWork->abyCoinBase2 : 0x");
			for( dwIdx=0;dwIdx<COINBASE2_SIZE;dwIdx++ )
			{
	            printf("%.2x",pstWork->abyCoinBase2[dwIdx]);
			}
            printf("\n");

			for( dwMerkleIdx=0;dwMerkleIdx<MERKLE_TREE_MAX_DEPTH;dwMerkleIdx++ )
			{
	            printf("pstWork->aabyMerkleBranch : 0x");
				for( dwIdx=0;dwIdx<HASH_SIZE;dwIdx++ )
				{
		            printf("%.2x",pstWork->aabyMerkleBranch[dwMerkleIdx][dwIdx]);
				}
	            printf("\n");
			}

            printf("pstWork->aabyNonce : 0x");
			for( dwIdx=0;dwIdx<NONCE_SIZE;dwIdx++ )
			{
	            printf("%.2x",pstWork->aabyNonce[dwIndex][dwIdx]);
			}
            printf("\n");

            printf("pstWork->abyBlckVer : 0x");
			for( dwIdx=0;dwIdx<BLOCK_VER_SIZE;dwIdx++ )
			{
	            printf("%.2x",pstWork->abyBlckVer[dwIdx]);
			}
            printf("\n");

            printf("pstWork->abyNbits : 0x");
			for( dwIdx=0;dwIdx<NBITS_SIZE;dwIdx++ )
			{
	            printf("%.2x",pstWork->abyNbits[dwIdx]);
			}
            printf("\n");

            printf("pstWork->abyNtime : 0x");
			for( dwIdx=0;dwIdx<NTIME_SIZE;dwIdx++ )
			{
	            printf("%.2x",pstWork->abyNtime[dwIdx]);
			}
            printf("\n");

            /* Display merkle hashes */
            printf("--------------------------------------\n");
#endif
        }

        dwRetVal = 1;
    }


    return dwRetVal;
}

/* ************************************************************************** */
eFPGA_State_t FPGA_Drv_GetStatus(void)
/* *****************************************************************************
** Input  : Pointer to work structure to be staged for work.
** Output : -
** Return : 0 In case of failure. 1 otherwise.
**
** Description  : Give a work package that is in a format allowing FPGA mining.
**                That is hex and not strings.
**
** ************************************************************************** */
{
    /* always return true for the time being */
    return eFPGA_COMPUTING;
}

void FPGA_Drv_Shutdown(void)
{
    /* clean up our memory mapping and exit */
    if( 0 != munmap( stLocalData.pvVirtBase, HW_REGS_SPAN ) )
    {
        printf( "ERROR: munmap() failed...\n" );
    }

    /* Release access to memory */
    close( stLocalData.wFileDesc );

    return;
}

/* *****************************************************************************
**                            LOCALS ROUTINES Defn
** ************************************************************************** */

/* ************************************************************************** */
static void ResetData(void)
/* *****************************************************************************
** Input  : -
** Output : -
** Return : -
**
** Description  : Reset local data. The design allow this method to be called
**                more than once.
**
** ************************************************************************** */
{
    memset(&stLocalData,sizeof(FPGA_Drv_Data_t),0x00);

    stLocalData.wFileDesc = -1;
    stLocalData.pvVirtBase = NULL;

    return;
}
