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
#include <stdio.h>    /*  */
#include <unistd.h>   /*  */
#include <fcntl.h>    /*  */
#include <sys/mman.h> /*  */
#include <math.h>     /*  */
#include <stdlib.h>   /*  */
#include <string.h>   /*  */

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
#define HW_REGS_BASE ( ALT_STM_OFST )         /*  */
#define HW_REGS_SPAN ( 0x04000000 )           /*  */
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )     /*  */

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
dword FPGA_Drv_Setup(void) /* That should go under the FPGA module actually */
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

dword FPGA_Drv_Init(void)
{
    dword dwRetVal;

    /* Initialize locals pessimistically  */
    dwRetVal = 0;

    /* Nothing to do here for the time being */

    return dwRetVal;
}

dword FPGA_Drv_StageWork(stSCHEDULER_Work_t * const pstWork)
{
    dword dwRetVal;
    dword dwIndex;

    /* Initialize locals */
    dwRetVal = 0;

    if( NULL != pstWork )
    {
        for ( dwIndex = 0; dwIndex < NUM_BMC_CORES; dwIndex++ )
        {
            printf("\n--------------------------------------\n");
            printf("pstWork->abyJobId : %s\n",pstWork->abyJobId);
            printf("pstWork->abyJobId : %s\n",pstWork->abyJobId);
            printf("pstWork->abyJobId : %s\n",pstWork->abyJobId);
            printf("pstWork->abyJobId : %s\n",pstWork->abyJobId);
            printf("pstWork->abyJobId : %s\n",pstWork->abyJobId);
            printf("pstWork->abyJobId : %s\n",pstWork->abyJobId);
            printf("pstWork->abyJobId : %s\n",pstWork->abyJobId);
            printf("pstWork->abyJobId : %s\n",pstWork->abyJobId);
            printf("pstWork->abyJobId : %s\n",pstWork->abyJobId);
            printf("pstWork->abyJobId : %s\n",pstWork->abyJobId);
            printf("pstWork->abyJobId : %s\n",pstWork->abyJobId);
            printf("--------------------------------------\n");
        }

        dwRetVal = 1;
    }


    return dwRetVal;
}

eFPGA_State_t FPGA_Drv_GetStatus(void)
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
static void ResetData(void)
{
    memset(&stLocalData,sizeof(FPGA_Drv_Data_t),0x00);

    stLocalData.wFileDesc = -1;
    stLocalData.pvVirtBase = NULL;

}
