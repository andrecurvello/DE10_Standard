/* *****************************************************************************
**
**                       DE10 Standard project
**
** Project      : DE10 standard project miner
** Module       : main
**
** Description  : This is the miner application. The main purpose here is to feed
**                the FPGA with blocks coming from whatever pool using
**                TCP socket and JSON. Also the user interface is dealt with here
**
** ************************************************************************** */

/* *****************************************************************************
**  REVISION HISTORY
** Date         Inits   Description
** ----------------------------------------------------------------------------
** 08.08.17     bd      [no issue number] File creation
**
** ************************************************************************** */

/* *****************************************************************************
**                          SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "Macros.h" /* Divers macros definitions */
#include "Types.h"  /* Legacy types definitions */

#include <signal.h> /* signal handling */
#include <stdio.h>  /* standard IOs */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "terasic_os_includes.h" /* terasic lib */

/* FPGA Intfc */
#include "FPGA_Drv.h" /* FPGA driver */

/* Test Intfc */
#include "test_vectors.h" /* test vector handling */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */

/* *****************************************************************************
**                                 GLOBALS
** ************************************************************************** */

/* *****************************************************************************
**                                 LOCALS
** ************************************************************************** */
static volatile boolean bEnd = FALSE; /* End of demonstration bool */

static void TASK_Bkgnd(void);

/* *****************************************************************************
**                              LOCALS ROUTINES
** ************************************************************************** */
static void handle_int(int iSignal)
{
	if ( iSignal == SIGINT )
	{
		printf("\r\n");
		printf("Ending ...\r\n");
		bEnd=TRUE;
	}

	exit(1);
}

/* *****************************************************************************
**                                  API
** ************************************************************************** */
int main(void)
{
    /* Register signal handler */
    signal(SIGINT,handle_int);

    /* Initialize FPGA */
    FPGA_Drv_Setup();
    FPGA_Drv_Init();

#if 0
    /* Initialize test module */
    TEST_VECTORS_Setup();
#endif

    /* Launch background task */
    TASK_Bkgnd();

    /* Shutdown FPGA communication channels */
    FPGA_Drv_Shutdown();

	return 0;
}

static void TASK_Bkgnd(void)
{
    for(;bEnd==FALSE;)
    {
#if 0
        /* Process scheduler */
        /* TEST_VECTORS_Bkgnd(); */

        /* Process FPGA task */
        FPGA_Drv_Bkgnd();
#endif
    };

    return;
}
