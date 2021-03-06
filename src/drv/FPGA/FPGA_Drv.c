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
#define ALT_FPGA_BMC0_INTFC ( ( unsigned long )( ALT_H2F_OFST + BMC_0_BASE ) & ( unsigned long)( HW_REGS_MASK ) )
#define ALT_FPGA_REG0_INTFC ( ( unsigned long )( ALT_H2F_OFST + REGISTER_0_BASE ) & ( unsigned long)( HW_REGS_MASK ) )

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */
typedef struct
{
    word wFileDesc;
    void *pvVirtBase;

    void *pvManager;
    void *pvCoreIntfc;
    void *pvRegisterMap;

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
    stLocalData.pvCoreIntfc = (stLocalData.pvVirtBase + ALT_FPGA_BMC0_INTFC);
    stLocalData.pvRegisterMap = (stLocalData.pvVirtBase + ALT_FPGA_REG0_INTFC);

    return dwRetVal;
}

/* ************************************************************************** */
dword FPGA_Drv_StageWork(void * const pstWork)
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

    /* Initialize locals */
    dwRetVal = 0;

    if( NULL != pstWork )
    {
        /* TBD ... */

        dwRetVal = 1;
    }

    return dwRetVal;
}

/* ************************************************************************** */
void FPGA_Drv_Bkgnd(void)
/* *****************************************************************************
** Input  : -
** Output : -
** Return : -
**
** Description  : Guarantee good operation of the FPGA
**
** ************************************************************************** */
{
	byte *pbyData;
    dword dwIdx;

    /* Read calculated checksums */
    if( 0x0000000000000000000000000000000 != *((byte*)stLocalData.pvRegisterMap + 0 ) )
    {
    	pbyData = ((byte*)stLocalData.pvRegisterMap + 0 );
    	printf("Data 0 : 0x");
    	for( dwIdx=0;dwIdx<16;dwIdx++ )
    	{
            printf("%.2x",*(pbyData + dwIdx));
    	}
        printf("\n");

    	pbyData = ((byte*)stLocalData.pvRegisterMap + 16 );
    	printf("Data 1 : 0x");
    	for( dwIdx=0;dwIdx<16;dwIdx++ )
    	{
            printf("%.2x",*(pbyData + dwIdx));
    	}
        printf("\n");
    }

    return;
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
    stLocalData.pvCoreIntfc = NULL;
    stLocalData.pvRegisterMap = NULL;

    return;
}
