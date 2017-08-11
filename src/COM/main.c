/* *****************************************************************************
**
**                       LCD Demonstration sub project
**
** Project      : LCD show case
** Module       : LED_Drv.c
**
** Description  : main application that uses LCD.
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

#include <signal.h> /* signal handling */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "terasic_os_includes.h" /* terasic lib */

/* COM management */
#include "COM_Mgr.h" /* COM manager defn */

/* FPGA and user interface */
#include "FPGA_Drv.h" /* FPGA driver */
#include "UI_Mgr.h"   /* LCD hardware management */

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

    /* Initialise FPGA */
    FPGA_Drv_Setup();

    /* Initialise UI */
    UI_Mgr_Setup();

    /* Initialise COM and protocol stack */
    COM_Mgr_Setup();
    COM_Mgr_Init();

    /* Launch background task */
    TASK_Bkgnd();

	return 0;
}

static void TASK_Bkgnd(void)
{
    for(;bEnd==FALSE;)
    {
        /* Process COMs */
        COM_Mgr_Bkgnd();

        /* Process user interface */
        UI_Mgr_Bkgnd();
    };

    return;
}
