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

/* COM management */
#include "COM_Mgr.h" /* COM manager defn */
#include "SCHEDULER.h" /* Scheduler defn */

/* FPGA and user interface */
#include "FPGA_Drv.h" /* FPGA driver */
#if 0
#include "UI_Mgr.h"   /* LCD hardware management */
#endif

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
    /* Initialise UI */
    UI_Mgr_Setup();
#endif

    /* Initialise COM and protocol stack */
    COM_Mgr_Setup();
    COM_Mgr_Init();

    /* Initialise the scheduler */
    SCHEDULER_Setup();
    SCHEDULER_Init();

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
        /* Process COMs */
        COM_Mgr_Bkgnd();

        /* Process scheduler */
        SCHEDULER_Bkgnd();

        /* Process FPGA task */
        FPGA_Drv_Bkgnd();

#if 0
        /* Process user interface */
        UI_Mgr_Bkgnd();
#endif
    };

    return;
}
