/* *****************************************************************************
**
**                       Standalone bitcoin miner
**
** Project      : DE10 Standard kit review
** Module       : LED_Drv.c
**
** Description  : Definitiion and implementation of the LCD driver module.
**
** ************************************************************************** */

/* *****************************************************************************
**  REVISION HISTORY
** Date         Inits   Description
** ----------------------------------------------------------------------------
** 28.05.17     bd      [no issue number] File creation
**
** ************************************************************************** */
#ifndef LCD_DRV_H
#define LCD_DRV_H

/* *****************************************************************************
**                          SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "Types.h"  /* Legacy type definitions */
#include "Macros.h" /* Legacy macro definitions */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "LCD_Drv.h" /* Module header */

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
**                                  API
** ************************************************************************** */
void LCDHW_Init(void *virtual_base){

    lcd_virtual_base = virtual_base;

    ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////
    //////// lcd reset
    // set the direction of the HPS GPIO1 bits attached to LCD RESETn to output
    alt_setbits_word( ( virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DDR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_RESETn_BIT_GPIObit44_GPIOreg1 );
    // set the value of the HPS GPIO1 bits attached to LCD RESETn to zero
    alt_clrbits_word( ( virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_RESETn_BIT_GPIObit44_GPIOreg1 );
    usleep( 1000000 / 16 );
    // set the value of the HPS GPIO1 bits attached to LCD RESETn to one
    alt_setbits_word( ( virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_RESETn_BIT_GPIObit44_GPIOreg1 );
    usleep( 1000000 / 16 );

    ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////
    //////// turn-on backlight
    // set the direction of the HPS GPIO1 bits attached to LCD Backlight to output
    alt_setbits_word( ( virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DDR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_BACKLIHGT_BIT_GPIObit37_GPIOreg1 );
    // set the value of the HPS GPIO1 bits attached to LCD Backlight to ZERO, turn OFF the Backlight
    alt_clrbits_word( ( virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_BACKLIHGT_BIT_GPIObit37_GPIOreg1 );



    ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////
    // set LCD-A0 pin as output pin

    alt_setbits_word( ( virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DDR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_D_C_BIT_GPIObit41_GPIOreg1 );
    // set HPS_LCM_D_C to 0
    alt_clrbits_word( ( virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_D_C_BIT_GPIObit41_GPIOreg1 );


    ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////
    // SPIM0 Init
#ifdef USE_SPI_DRIVER
    char *filename = "/dev/spidev32766.0";

    MY_DEBUG("use spi driver = %s\r\n", filename);

    lcd_spi_file = open(filename,O_RDWR);
    if (lcd_spi_file > 0){
        uint8_t    mode, lsb, bits;
        uint32_t speed=2500000, max_speed;

            if (ioctl(lcd_spi_file, SPI_IOC_RD_MODE, &mode) < 0)
                {
                MY_DEBUG("SPI rd_mode");
                return;
                }
            if (ioctl(lcd_spi_file, SPI_IOC_RD_LSB_FIRST, &lsb) < 0)
                {
                MY_DEBUG("SPI rd_lsb_fist");
                return;
                }
            if (ioctl(lcd_spi_file, SPI_IOC_RD_BITS_PER_WORD, &bits) < 0)
                {
                MY_DEBUG("SPI bits_per_word");
                return;
                }
            if (ioctl(lcd_spi_file, SPI_IOC_RD_MAX_SPEED_HZ, &max_speed) < 0)
                {
                MY_DEBUG("SPI max_speed_hz");
                return;
                }
            MY_DEBUG("%s: spi mode %d, %d bits %sper word, %d Hz max\n",filename, mode, bits, lsb ? "(lsb first) " : "", max_speed);

    spi_xfer.len = 3; /* Length of  command to write*/
    spi_xfer.cs_change = 0; /* Keep CS activated */
    spi_xfer.delay_usecs = 0; //delay in us
    spi_xfer.speed_hz = (speed > max_speed)?max_speed: speed;//2500000, //speed
    spi_xfer.bits_per_word = bits;//8, // bites per word 8
    }else{
        MY_DEBUG("failed to open file = %s(lcd_spi_file=%d)\r\n", filename, lcd_spi_file);
    }

#else

    usleep( 1000000 / 16 );

    MY_DEBUG("[SPIM0]enable SPIM0 interface\r\n");
    // initialize the  peripheral to talk to the LCM
    alt_clrbits_word( ( virtual_base + ( ( uint32_t )( ALT_RSTMGR_PERMODRST_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_RSTMGR_PERMODRST_SPIM0_SET_MSK );

    //===================
    // step 1: disable SPI
    //         writing 0 to the SSI Enable register (SSIENR).
    //

    MY_DEBUG("[SPIM0]SPIM0.spi_en = 0 # disable the SPI master\r\n");
    // [0] = 0, to disalbe SPI
    alt_clrbits_word( ( virtual_base + ( ( uint32_t )( ALT_SPIM0_SPIENR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_SPIM_SPIENR_SPI_EN_SET_MSK );

    //===================
    // step 2: setup
    //         Write Control Register 0 (CTRLLR0).
    //         Write the Baud Rate Select Register (BAUDR)
    //         Write the Transmit and Receive FIFO Threshold Level registers (TXFTLR and RXFTLR) to set FIFO buffer threshold levels.
    //         Write the IMR register to set up interrupt masks.
    //         Write the Slave Enable Register (SER) register here to enable the target slave for selection......


    // Transmit Only: Transfer Mode [9:8], TXONLY = 0x01
    MY_DEBUG("[SPIM0]SPIM0_ctrlr0.tmod = 1  # TX only mode\r\n");
    alt_clrbits_word( ( virtual_base + ( ( uint32_t )( ALT_SPIM0_CTLR0_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_SPIM_CTLR0_TMOD_SET_MSK );
    alt_setbits_word( ( virtual_base + ( ( uint32_t )( ALT_SPIM0_CTLR0_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_SPIM_CTLR0_TMOD_SET( ALT_SPIM_CTLR0_TMOD_E_TXONLY ) );


    // 200MHz / 64 = 3.125MHz: [15:0] = 64
    MY_DEBUG("[SPIM0]SPIM0_baudr.sckdv = 64  # 200MHz / 64 = 3.125MHz\r\n");
    alt_clrbits_word( ( virtual_base + ( ( uint32_t )( ALT_SPIM0_BAUDR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_SPIM_BAUDR_SCKDV_SET_MSK );
    alt_setbits_word( ( virtual_base + ( ( uint32_t )( ALT_SPIM0_BAUDR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_SPIM_BAUDR_SCKDV_SET( 64 ) );



    // ss_n0 = 1, [3:0]
    MY_DEBUG("[SPIM0]SPIM0_ser.ser = 1  #ss_n0 = 1\r\n");
    alt_clrbits_word( ( virtual_base + ( ( uint32_t )( ALT_SPIM0_SER_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_SPIM_SER_SER_SET_MSK );
    alt_setbits_word( ( virtual_base + ( ( uint32_t )( ALT_SPIM0_SER_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_SPIM_SER_SER_SET( 1 ) );



    //===================
    // step 3: Enable the SPI master by writing 1 to the SSIENR register.
    // ALT_SPIM0_SPIENR_ADDR
    MY_DEBUG("[SPIM0]spim0_spienr.spi_en = 1  # ensable the SPI master\r\n");
    alt_setbits_word( ( virtual_base + ( ( uint32_t )( ALT_SPIM0_SPIENR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_SPIM_SPIENR_SPI_EN_SET_MSK );

    // step 4: Write data for transmission to the target slave into the transmit FIFO buffer (write DR)
    //alt_setbits_word( ( virtual_base + ( ( uint32_t )( ALT_SPIM0_DR_ADDR ) & ( uint32_t )( ALT_SPIM1_SPIENR_ADDR ) ) ), data16 );

#endif

    MY_DEBUG("[SPIM0]LCD_Init done\r\n");

}
