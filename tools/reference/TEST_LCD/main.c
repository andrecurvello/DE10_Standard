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

#include "LCD_Graphic.h" /* Graphics management library of the LCD */
#include "LCD_Driver.h"  /* LCD hardware management */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
#define HW_REGS_BASE ( ALT_STM_OFST )         /*  */
#define HW_REGS_SPAN ( 0x04000000 )           /*  */
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )     /*  */
#define FRAME_SIZE ((LCD_WIDTH*LCD_HEIGHT)/8) /*  */

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */

/* *****************************************************************************
**                                 GLOBALS
** ************************************************************************** */

/* *****************************************************************************
**                                 LOCALS
** ************************************************************************** */
static byte abyFrameBuffer[FRAME_SIZE]; /* The LCD frame buffer */
static volatile boolean bEndDemo = FALSE; /* End of demonstration bool */

/* *****************************************************************************
**                              LOCALS ROUTINES
** ************************************************************************** */
static void handle_int(int iSignal)
{
	if ( iSignal == SIGINT )
	{
		printf("\r\n");
		printf("Ending DEMO_LCD ...\r\n");
		bEndDemo=TRUE;
	}

	exit(1);
}

/* *****************************************************************************
**                                  API
** ************************************************************************** */
int main(void)
{
	void *virtual_base;
	word fd;
	stLCDDrv_Canvas_t LcdCanvas;
	int iRetVal;

	/* Initialize locals pessimistically  */
    fd = -1;
    iRetVal = 1;
    virtual_base = NULL;
    LcdCanvas.Width = LCD_WIDTH; /* Setup canvas */
    LcdCanvas.Height = LCD_HEIGHT;
    LcdCanvas.BitPerPixel = 1;
    LcdCanvas.FrameSize = LcdCanvas.Width * LcdCanvas.Height / 8;
    LcdCanvas.pFrame = &abyFrameBuffer[0];

    /* Register signal handler */
    signal(SIGINT,handle_int);

    /* Get access to memory */
    fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) );
	if( -1  != fd )
	{
	    /*
	    ** Map the address space for the LED registers into user space so we can
	    ** interact with them. we'll actually map in the entire CSR span of the
	    ** HPS since we want to access various registers within that span
	    */
	    virtual_base = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, HW_REGS_BASE );
	    if( MAP_FAILED != virtual_base )
	    {
	        /* Update return value */
	        iRetVal = 0;

	        /* Welcoming message */
	        printf("Graphic LCD Demo\r\n");

	        /*
	        **  Drawing block using the graphic library, prepare canvas.
	        **  These are all operations on the
	        */
	        LCDGrph_Clear(&LcdCanvas, LCD_WHITE);
	        LCDGrph_DrawRect(&LcdCanvas, 0,0, LcdCanvas.Width-1, LcdCanvas.Height-1, LCD_BLACK); // retangle
	        LCDGrph_DrawCircle(&LcdCanvas, 10, 10, 6, LCD_BLACK);
	        LCDGrph_DrawCircle(&LcdCanvas, LcdCanvas.Width-10, 10, 6, LCD_BLACK);
	        LCDGrph_DrawCircle(&LcdCanvas, LcdCanvas.Width-10, LcdCanvas.Height-10, 6, LCD_BLACK);
	        LCDGrph_DrawCircle(&LcdCanvas, 10, LcdCanvas.Height-10, 6, LCD_BLACK);
	        LCDGrph_PrintString(&LcdCanvas, 30, 10, "DE10 kit", LCD_BLACK);
	        LCDGrph_PrintString(&LcdCanvas, 40, 10+8, "review", LCD_BLACK);
	        LCDGrph_PrintString(&LcdCanvas, 30, 10+28, ":) :) :)", LCD_BLACK);

            /* Wake up LCD screen */
            LCDDrv_Init(virtual_base); /* Set up gpios and spi signals */

            LCDGrph_Refresh(&LcdCanvas);

            LCDGrph_Init(); /* Send config to the display */

            printf("Type ctrl-C to exit\r\n");
	        for(;bEndDemo==FALSE;){
	            LCDDrv_BackLight(true); /* turn on LCD back light */
	        };

            LCDDrv_BackLight(false); /* turn off LCD back light */

	        /* clean up our memory mapping and exit */
	        if( 0 != munmap( virtual_base, HW_REGS_SPAN ) )
	        {
	            printf( "ERROR: munmap() failed...\n" );
	            iRetVal = 1;
	        }
	    }
	    else
	    {
            printf( "ERROR: mmap() failed...\n" );
	    }
	}

    /* Release access to memory */
	close( fd );

	return iRetVal;
}
