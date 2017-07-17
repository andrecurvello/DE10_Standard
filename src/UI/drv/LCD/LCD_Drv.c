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

/* *****************************************************************************
**                          SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "Types.h"  /* Legacy type definitions */
#include "Macros.h" /* Legacy macro definitions */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "LCD_Drv.h" /* Module header */

#include "hwlib.h"            /* general altera definition */
#include "socal/socal.h"      /* library declaration */
#include "socal/hps.h"        /* hard processing system */
#include "socal/alt_gpio.h"   /* gpio definitions */
#include "socal/alt_spim.h"   /* spi definitions */
#include "socal/alt_rstmgr.h" /* reset manager */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
#define HW_REGS_BASE ( ALT_STM_OFST )
#define HW_REGS_SPAN ( 0x04000000 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )

#define HPS_LCM_D_C_BIT_GPIObit41_GPIOreg1 ( 0x00001000 )
#define HPS_LCM_RESETn_BIT_GPIObit44_GPIOreg1 ( 0x00008000 )
#define HPS_LCM_BACKLIHGT_BIT_GPIObit37_GPIOreg1 ( 0x00000100 )

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */

/* *****************************************************************************
**                                 GLOBALS
** ************************************************************************** */

/* *****************************************************************************
**                                 LOCALS
** ************************************************************************** */
static void *lcd_virtual_base=NULL;

 // internal fucniton
//#define MY_DEBUG(msg, arg...) printf("%s:%s(%d): " msg, __FILE__, __FUNCTION__, __LINE__, ##arg)
#define MY_DEBUG(msg, arg...)
void PIO_DC_Set(boolean bIsData);
#if 0
boolean SPIM_IsTxFifoEmpty(void);
#endif
void SPIM_WriteTxData(byte Data);

/* *****************************************************************************
**                                  API
** ************************************************************************** */
void LCDHW_Init(void *virtual_base)
{
    lcd_virtual_base = virtual_base;

    //////// lcd reset
    // set the direction of the HPS GPIO1 bits attached to LCD RESETn to output
    alt_setbits_word( ( virtual_base + ( ( word )( ALT_GPIO1_SWPORTA_DDR_ADDR ) & ( word )( HW_REGS_MASK ) ) ), HPS_LCM_RESETn_BIT_GPIObit44_GPIOreg1 );
    // set the value of the HPS GPIO1 bits attached to LCD RESETn to zero
    alt_clrbits_word( ( virtual_base + ( ( word )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( word )( HW_REGS_MASK ) ) ), HPS_LCM_RESETn_BIT_GPIObit44_GPIOreg1 );
    usleep( 1000000 / 16 );
    // set the value of the HPS GPIO1 bits attached to LCD RESETn to one
    alt_setbits_word( ( virtual_base + ( ( word )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( word )( HW_REGS_MASK ) ) ), HPS_LCM_RESETn_BIT_GPIObit44_GPIOreg1 );
    usleep( 1000000 / 16 );

    //////// turn-on backlight
    // set the direction of the HPS GPIO1 bits attached to LCD Backlight to output
    alt_setbits_word( ( virtual_base + ( ( word )( ALT_GPIO1_SWPORTA_DDR_ADDR ) & ( word )( HW_REGS_MASK ) ) ), HPS_LCM_BACKLIHGT_BIT_GPIObit37_GPIOreg1 );
    // set the value of the HPS GPIO1 bits attached to LCD Backlight to ZERO, turn OFF the Backlight
    alt_clrbits_word( ( virtual_base + ( ( word )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( word )( HW_REGS_MASK ) ) ), HPS_LCM_BACKLIHGT_BIT_GPIObit37_GPIOreg1 );

    // set LCD-A0 pin as output pin
    alt_setbits_word( ( virtual_base + ( ( word )( ALT_GPIO1_SWPORTA_DDR_ADDR ) & ( word )( HW_REGS_MASK ) ) ), HPS_LCM_D_C_BIT_GPIObit41_GPIOreg1 );
    // set HPS_LCM_D_C to 0
    alt_clrbits_word( ( virtual_base + ( ( word )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( word )( HW_REGS_MASK ) ) ), HPS_LCM_D_C_BIT_GPIObit41_GPIOreg1 );

    // SPIM0 Init
#ifdef USE_SPI_DRIVER
    char *filename = "/dev/spidev32766.0";

    MY_DEBUG("use spi driver = %s\r\n", filename);

    lcd_spi_file = open(filename,O_RDWR);
    if (lcd_spi_file > 0){
        byte    mode, lsb, bits;
        word speed=2500000, max_speed;

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
    alt_clrbits_word( ( virtual_base + ( ( word )( ALT_RSTMGR_PERMODRST_ADDR ) & ( word )( HW_REGS_MASK ) ) ), ALT_RSTMGR_PERMODRST_SPIM0_SET_MSK );

    //===================
    // step 1: disable SPI
    //         writing 0 to the SSI Enable register (SSIENR).
    //
    MY_DEBUG("[SPIM0]SPIM0.spi_en = 0 # disable the SPI master\r\n");
    // [0] = 0, to disalbe SPI
    alt_clrbits_word( ( virtual_base + ( ( word )( ALT_SPIM0_SPIENR_ADDR ) & ( word )( HW_REGS_MASK ) ) ), ALT_SPIM_SPIENR_SPI_EN_SET_MSK );

    //===================
    // step 2: setup
    //         Write Control Register 0 (CTRLLR0).
    //         Write the Baud Rate Select Register (BAUDR)
    //         Write the Transmit and Receive FIFO Threshold Level registers (TXFTLR and RXFTLR) to set FIFO buffer threshold levels.
    //         Write the IMR register to set up interrupt masks.
    //         Write the Slave Enable Register (SER) register here to enable the target slave for selection......
    // Transmit Only: Transfer Mode [9:8], TXONLY = 0x01
    MY_DEBUG("[SPIM0]SPIM0_ctrlr0.tmod = 1  # TX only mode\r\n");
    alt_clrbits_word( ( virtual_base + ( ( word )( ALT_SPIM0_CTLR0_ADDR ) & ( word )( HW_REGS_MASK ) ) ), ALT_SPIM_CTLR0_TMOD_SET_MSK );
    alt_setbits_word( ( virtual_base + ( ( word )( ALT_SPIM0_CTLR0_ADDR ) & ( word )( HW_REGS_MASK ) ) ), ALT_SPIM_CTLR0_TMOD_SET( ALT_SPIM_CTLR0_TMOD_E_TXONLY ) );

    // 200MHz / 64 = 3.125MHz: [15:0] = 64
    MY_DEBUG("[SPIM0]SPIM0_baudr.sckdv = 64  # 200MHz / 64 = 3.125MHz\r\n");
    alt_clrbits_word( ( virtual_base + ( ( word )( ALT_SPIM0_BAUDR_ADDR ) & ( word )( HW_REGS_MASK ) ) ), ALT_SPIM_BAUDR_SCKDV_SET_MSK );
    alt_setbits_word( ( virtual_base + ( ( word )( ALT_SPIM0_BAUDR_ADDR ) & ( word )( HW_REGS_MASK ) ) ), ALT_SPIM_BAUDR_SCKDV_SET( 64 ) );

    // ss_n0 = 1, [3:0]
    MY_DEBUG("[SPIM0]SPIM0_ser.ser = 1  #ss_n0 = 1\r\n");
    alt_clrbits_word( ( virtual_base + ( ( word )( ALT_SPIM0_SER_ADDR ) & ( word )( HW_REGS_MASK ) ) ), ALT_SPIM_SER_SER_SET_MSK );
    alt_setbits_word( ( virtual_base + ( ( word )( ALT_SPIM0_SER_ADDR ) & ( word )( HW_REGS_MASK ) ) ), ALT_SPIM_SER_SER_SET( 1 ) );

    //===================
    // step 3: Enable the SPI master by writing 1 to the SSIENR register.
    // ALT_SPIM0_SPIENR_ADDR
    MY_DEBUG("[SPIM0]spim0_spienr.spi_en = 1  # ensable the SPI master\r\n");
    alt_setbits_word( ( virtual_base + ( ( word )( ALT_SPIM0_SPIENR_ADDR ) & ( word )( HW_REGS_MASK ) ) ), ALT_SPIM_SPIENR_SPI_EN_SET_MSK );

    // step 4: Write data for transmission to the target slave into the transmit FIFO buffer (write DR)
    //alt_setbits_word( ( virtual_base + ( ( word )( ALT_SPIM0_DR_ADDR ) & ( word )( ALT_SPIM1_SPIENR_ADDR ) ) ), data16 );
#endif
    MY_DEBUG("[SPIM0]LCD_Init done\r\n");

}

void LCDHW_BackLight(boolean bON)
{
    if (bON)
    {
        alt_setbits_word( ( lcd_virtual_base + ( ( word )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( word )( HW_REGS_MASK ) ) ),
                          HPS_LCM_BACKLIHGT_BIT_GPIObit37_GPIOreg1 );
    }
    else
    {
        alt_clrbits_word( ( lcd_virtual_base + ( ( word )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( word )( HW_REGS_MASK ) ) ),
                          HPS_LCM_BACKLIHGT_BIT_GPIObit37_GPIOreg1 );
    }
}

void LCDHW_Write8(byte bIsData, byte Data)
{
    static byte bPreIsData=0xFF;

    // set A0
    if (bPreIsData != bIsData)
    {
        // Note. cannot change D_C until all tx dara(or command) are sent. i.e. fifo is empty
        //  while(!SPIM_IsTxEmpty()); // wait if buffer is not empty

        PIO_DC_Set(bIsData);
        bPreIsData = bIsData;
    }
    else
    {
        // wait buffer is not full
        //  while(SPIM_IsTxFull()); // wait if buffer is full
    }

    SPIM_WriteTxData(Data);
}

//////////////////////////////////////////////////////////////
// internal funciton
//////////////////////////////////////////////////////////////
void PIO_DC_Set(boolean bIsData)
{
    // D_C = "H": Data
    // D_C = "L": CMD
    if (bIsData) // A0 = "H": Data
        alt_setbits_word( ( lcd_virtual_base + ( ( word )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( word )( HW_REGS_MASK ) ) ), HPS_LCM_D_C_BIT_GPIObit41_GPIOreg1 );
    else
        alt_clrbits_word( ( lcd_virtual_base + ( ( word )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( word )( HW_REGS_MASK ) ) ), HPS_LCM_D_C_BIT_GPIObit41_GPIOreg1 );
}

#ifdef USE_SPI_DRIVER

//////////
// Write n bytes int the 2 bytes address add1 add2
//////////
void spi_write8(int file, byte Data)
    {
        int status;

    spi_xfer.tx_buf = (unsigned long)&Data;
    spi_xfer.len = 1; /* Length of  command to write*/
    status = ioctl(file, SPI_IOC_MESSAGE(1), &spi_xfer);
    if (status < 0)
    {
        MY_DEBUG("SPI_IOC_MESSAGE");
        return;
    }
    //printf("env: %02x %02x %02x\n", buf[0], buf[1], buf[2]);
    //printf("ret: %02x %02x %02x %02x\n", buf2[0], buf2[1], buf2[2], buf2[3]);

    //com_serial=1;
    //failcount=0;
    }

  #endif

void SPIM_WriteTxData(byte Data)
{
#ifdef USE_SPI_DRIVER
    if (lcd_spi_file > 0)
        spi_write8(lcd_spi_file, Data);
#else
    while( ALT_SPIM_SR_TFE_GET( alt_read_word( ( lcd_virtual_base + ( ( word )( ALT_SPIM0_SR_ADDR ) & ( word )( HW_REGS_MASK ) ) ) ) ) != ALT_SPIM_SR_TFE_E_EMPTY );
    alt_write_word( ( lcd_virtual_base + ( ( word )( ALT_SPIM0_DR_ADDR ) & ( word )( HW_REGS_MASK ) ) ), ALT_SPIM_DR_DR_SET( Data ) );
    while( ALT_SPIM_SR_TFE_GET( alt_read_word( ( lcd_virtual_base + ( ( word )( ALT_SPIM0_SR_ADDR ) & ( word )( HW_REGS_MASK ) ) ) ) ) != ALT_SPIM_SR_TFE_E_EMPTY );
    while( ALT_SPIM_SR_BUSY_GET( alt_read_word( ( lcd_virtual_base + ( ( word )( ALT_SPIM0_SR_ADDR ) & ( word )( HW_REGS_MASK ) ) ) ) ) != ALT_SPIM_SR_BUSY_E_INACT );
#endif
}
