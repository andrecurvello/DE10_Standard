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
/* FPGA Intfc */
#ifdef SIM
#include "FPGA_Drv.h" /* FPGA driver */
#endif

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

	return;
}

/* *****************************************************************************
**                                  API
** ************************************************************************** */
int main(void)
{
    /* Register signal handler */
    signal(SIGINT,handle_int);

    /* Initialize FPGA */
#ifdef SIM
    FPGA_Drv_Setup();
    FPGA_Drv_Init();
#endif

    /* Initialize test module */
    TEST_VECTORS_Setup();
    TEST_VECTORS_Init();

    /* Launch background task */
    TASK_Bkgnd();

    /* Shutdown FPGA communication channels */
#ifdef SIM
    FPGA_Drv_Shutdown();
#endif

	return 0;
}

static void TASK_Bkgnd(void)
{
    for(;bEnd==FALSE;)
    {
        /* Process scheduler */
        TEST_VECTORS_Bckgnd();

#ifdef SIM
        /* Process FPGA task */
        FPGA_Drv_Bkgnd();
#endif

    };

    return;
}
