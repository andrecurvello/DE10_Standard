/* *****************************************************************************
**
**                       GPIO/7SEG Demonstration sub project
**
** Project      : Button and 7 segment display show case
** Module       : main.c
**
** Description  : main application that uses Buttons and 7 segment display.
** This program demonstrate how to use hps communicate with FPGA through light AXI Bridge.
** uses should program the FPGA by GHRD project before executing the program
** refer to user manual chapter 7 for details about the demo
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
#include <stdio.h>    /* classic stdin/out/err defns */
#include <unistd.h>   /* types def */
#include <fcntl.h>    /* function definitions */
#include <sys/mman.h> /* virt to phys mapping routines */
#include <signal.h>   /* signal handling */
#include "Macros.h"   /* Divers macros definitions */
#include "Types.h"    /* Legacy types definitions */

/* *****************************************************************************
**                          SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "hwlib.h"          /* General ALTERA HW definitions */
#include "socal/socal.h"    /* ALTERA Socal defns */
#include "socal/hps.h"      /* Hardware processing system (controller)  defns */
#include "socal/alt_gpio.h" /* ALTERA GPIO defns */
#include "hps_0.h"          /* FPGA interface defns */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
#define HW_REGS_BASE ( ALT_STM_OFST )
#define HW_REGS_SPAN ( 0x04000000 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )
#define ALT_FPGA_7SEG_INTFC ( ( unsigned long )( ALT_LWFPGASLVS_OFST + SEG7_0_BASE ) & ( unsigned long)( HW_REGS_MASK ) )

/* 7 segment display digit/letter index  */
typedef enum e7SEGDisp_Idx
{
    e7SEGDisp_Idx_0=0x00,
    e7SEGDisp_Idx_1,
    e7SEGDisp_Idx_2,
    e7SEGDisp_Idx_3,
    e7SEGDisp_Idx_4,
    e7SEGDisp_Idx_5,
    e7SEGDisp_Idx_6,
    e7SEGDisp_Idx_7,
    e7SEGDisp_Idx_8,
    e7SEGDisp_Idx_9,
    e7SEGDisp_Idx_A,
    e7SEGDisp_Idx_B,
    e7SEGDisp_Idx_C,
    e7SEGDisp_Idx_D,
    e7SEGDisp_Idx_E,
    e7SEGDisp_Idx_F,
    e7SEGDisp_Idx_N,
    e7SEGDisp_Idx_DASH,
    e7SEGDisp_Idx_Z,
    e7SEGDisp_Idx_L,
    e7SEGDisp_Idx_ALL

}e7SEGDisp_Idx_t;

/* *****************************************************************************
**                                 GLOBALS
** ************************************************************************** */

/* *****************************************************************************
**                                 LOCALS
** ************************************************************************** */
static volatile boolean bEndDemo = FALSE; /* End of demonstration bool */

/* 7 segment characters */
const static byte aby7SEG_Display[] =
{
    0x3F, /* 0, segment 0,1,2,3,4,5 */
    0x6,  /* 1, segment 1,2 */
    0x5B, /* 2, segment 0,1,4,5,6 */
    0x4F, /* 3, segment 0,1,2,3,6 */
    0x66, /* 4, segment 1,2,5,6 */
    0x6D, /* 5, segment 0,2,3,5,6 */
    0x7D, /* 6, segment 0,2,3,4,5,6 */
    0x7,  /* 7, segment 0,1,2 */
    0x7F, /* 8, segment 0,1,2,3,4,5,6 */
    0x6F, /* 9, segment 0,1,2,3,5,6 */
    0x77, /* A, segment 0,1,2,4,5,6 */
    0x7C, /* B, segment 2,3,4,5.6 */
    0x39, /* C, segment 0,3,4,5 */
    0x5E, /* D, segment 1,2,3,4,6 */
    0x79, /* E, segment 0,3,4,5,6 */
    0x71, /* F, segment 0,4,5,6 */
    0x37, /* N, segment 0,1,2,4,5 */
    0x40, /* -, segment 6 */
    0x5B, /* Z, segment 0,1,3,4,6 */
    0x38, /* L, segment 3,4,5 */
    0x3F  /* All, segment 0,1,2,3,4,5,6 */

};

/* *****************************************************************************
**                              LOCALS ROUTINES
** ************************************************************************** */
static void handle_int(int iSignal)
{
    if ( iSignal == SIGINT )
    {
        printf("\r\n");
        printf("Ending DEMO_DE10_SIMPLE ...\r\n");
        bEndDemo=TRUE;
    }

    return;
}

/* *****************************************************************************
**                                  API
** ************************************************************************** */
int main() {

	void *virtual_base;
	int fd;
	int loop_count;
	int led_direction;
	int led_mask;
	void *pvHps2Fpga7Seg;
    int iRetVal;

    /* Initialize locals pessimistically */
    fd = -1;
    iRetVal = 1;
    virtual_base = NULL;

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
            /***************************  LED manager *************************/

            /*  Get LED handle and 7SEG */
            pvHps2Fpga7Seg = virtual_base + ALT_FPGA_7SEG_INTFC;

            // toggle the LEDs a bit
            loop_count = 0;
            led_mask = 0x01;
            led_direction = 0; // 0: left to right direction
            while(   ( loop_count < 60 )
            	  && ( FALSE == bEndDemo )
            	 )
            {

                /* delay */
                usleep( 100*1000 );

                /* Update LED status */
                if (led_direction == 0)
                {
                    /* Display -dead- */
                    *((byte*)pvHps2Fpga7Seg + 0 ) = aby7SEG_Display[e7SEGDisp_Idx_DASH];
                    *((byte*)pvHps2Fpga7Seg + 4 ) = aby7SEG_Display[e7SEGDisp_Idx_D];
                    *((byte*)pvHps2Fpga7Seg + 8 ) = aby7SEG_Display[e7SEGDisp_Idx_A];
                    *((byte*)pvHps2Fpga7Seg + 12 ) = aby7SEG_Display[e7SEGDisp_Idx_E];
                    *((byte*)pvHps2Fpga7Seg + 16 ) = aby7SEG_Display[e7SEGDisp_Idx_D];
                    *((byte*)pvHps2Fpga7Seg + 20 ) = aby7SEG_Display[e7SEGDisp_Idx_DASH];

                    led_mask <<= 1;
                    if (led_mask == (0x01 << (10-1)))
                         led_direction = 1;
                }
                else
                {
                    /* Display -beef- */
                    *((byte*)pvHps2Fpga7Seg + 0 ) = aby7SEG_Display[e7SEGDisp_Idx_DASH];
                    *((byte*)pvHps2Fpga7Seg + 4 ) = aby7SEG_Display[e7SEGDisp_Idx_F];
                    *((byte*)pvHps2Fpga7Seg + 8 ) = aby7SEG_Display[e7SEGDisp_Idx_E];
                    *((byte*)pvHps2Fpga7Seg + 12 ) = aby7SEG_Display[e7SEGDisp_Idx_E];
                    *((byte*)pvHps2Fpga7Seg + 16 ) = aby7SEG_Display[e7SEGDisp_Idx_B];
                    *((byte*)pvHps2Fpga7Seg + 20 ) = aby7SEG_Display[e7SEGDisp_Idx_DASH];

                    led_mask >>= 1;
                    if (led_mask == 0x01)
                    {
                        led_direction = 0;
                        loop_count++;
                    }
                }
            }

            /* End ! */
            *((byte*)pvHps2Fpga7Seg + 0 ) = aby7SEG_Display[e7SEGDisp_Idx_DASH];
            *((byte*)pvHps2Fpga7Seg + 4 ) = aby7SEG_Display[e7SEGDisp_Idx_D];
            *((byte*)pvHps2Fpga7Seg + 8 ) = aby7SEG_Display[e7SEGDisp_Idx_N];
            *((byte*)pvHps2Fpga7Seg + 12 ) = aby7SEG_Display[e7SEGDisp_Idx_E];
            *((byte*)pvHps2Fpga7Seg + 16 ) = aby7SEG_Display[e7SEGDisp_Idx_DASH];
            *((byte*)pvHps2Fpga7Seg + 20 ) = 0x00; /* Clear */

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

	close( fd );

	return iRetVal;
}
