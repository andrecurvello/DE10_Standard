/* *****************************************************************************
**
**                       GPIO/7SEG Demonstration sub project
**
** Project      : Button and 7 segment display show case
** Module       : main.c
**
** Description  : main application that uses Buttons and 7 segment display.
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
#include "Macros.h"   /* Divers macros definitions */
#include "Types.h"    /* Legacy types definitions */

#include <signal.h>   /* signal handling */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "terasic_os_includes.h" /* terasic lib */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
#define HW_REGS_BASE ( ALT_STM_OFST )
#define HW_REGS_SPAN ( 0x04000000 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )

#define USER_IO_DIR     (0x01000000)
#define BIT_LED         (0x01000000)
#define BUTTON_MASK     (0x02000000)

#define ALT_GPIO_CONFG ( virtual_base + ( ( word )( ALT_GPIO1_SWPORTA_DDR_ADDR ) & ( word )( HW_REGS_MASK ) ) )
#define ALT_GPIO_W ( virtual_base + ( ( word )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( word )( HW_REGS_MASK ) ) )
#define ALT_GPIO_R ( virtual_base + ( ( word )( ALT_GPIO1_EXT_PORTA_ADDR ) & ( word )( HW_REGS_MASK ) ) )

/* *****************************************************************************
**                                 GLOBALS
** ************************************************************************** */

/* *****************************************************************************
**                                 LOCALS
** ************************************************************************** */
static volatile boolean bEndDemo = FALSE; /* End of demonstration bool */

/* *****************************************************************************
**                              LOCALS ROUTINES
** ************************************************************************** */
static void handle_int(int iSignal)
{
	if ( iSignal == SIGINT )
	{
		printf("\r\n");
		printf("Ending DEMO_GPIO ...\r\n");
		bEndDemo=TRUE;
	}

	exit(1);
}

/* *****************************************************************************
**                                  API
** ************************************************************************** */
int main(int argc, char **argv)
{
	void *virtual_base;
	int fd;
	word scan_input;
	byte byIndex;
    int iRetVal;

    /* Initialize locals pessimistically  */
    fd = -1;
    iRetVal = 1;
    virtual_base = NULL;
    scan_input = 0;

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
            iRetVal = 0;
            /* initialize the pio controller */
            /* led: set the direction of the HPS GPIO1 bits attached to LEDs to output */
            alt_setbits_word( ALT_GPIO_CONFG, USER_IO_DIR );

            printf("led test\r\n");
            printf("the led flash 2 times\r\n");

            for( byIndex=0; byIndex<2; byIndex++ )
            {
                /* LED On */
                alt_setbits_word( ALT_GPIO_W, BIT_LED );

                /* Delay */
                usleep(500*1000);

                /* LED Off */
                alt_clrbits_word( ALT_GPIO_W, BIT_LED );

                /* Delay */
                usleep(500*1000);
            }

            printf("user key test \r\n");
            printf("press key to control led\r\n");
            printf("press ctrl-C o exit demo neatly\r\n");

            for(;bEndDemo==FALSE;)
            {
                /* Get button status */
                scan_input = alt_read_word( ALT_GPIO_R );

                if(~scan_input&BUTTON_MASK)
                {
                    /* LED On */
                    alt_setbits_word( ALT_GPIO_W, BIT_LED );
                }
                else
                {
                    /* LED Off */
                    alt_clrbits_word( ALT_GPIO_W, BIT_LED );
                }
            }

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
