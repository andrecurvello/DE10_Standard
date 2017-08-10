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
#include "Macros.h" /* Divers macros definitions */
#include "Types.h"  /* Legacy types definitions */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "LCD_Driver.h"       /*  */

#include <stdio.h>            /*  */
#include <unistd.h>           /*  */
#include <fcntl.h>            /*  */
#include <sys/mman.h>         /*  */
#include <stdarg.h>           /*  */
#include "hwlib.h"            /*  */
#include "socal/socal.h"      /*  */
#include "socal/hps.h"        /*  */
#include "socal/alt_gpio.h"   /*  */
#include "socal/alt_spim.h"   /*  */
#include "socal/alt_rstmgr.h" /*  */

/* *****************************************************************************
**                                 LOCALS
** ************************************************************************** */
static void *lcd_virtual_base=NULL;

/* *****************************************************************************
**                                 MACROS
** ************************************************************************** */
#define HW_REGS_BASE ( ALT_STM_OFST )
#define HW_REGS_SPAN ( 0x04000000 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )

#define HPS_LCM_D_C_BIT_GPIObit41_GPIOreg1          ( 0x00001000 )
#define HPS_LCM_RESETn_BIT_GPIObit44_GPIOreg1       ( 0x00008000 )
#define HPS_LCM_BACKLIHGT_BIT_GPIObit37_GPIOreg1    ( 0x00000100 )

/* *****************************************************************************
**                                 LOCAL ROUTINES
** ************************************************************************** */
static void PIO_DC_Set(bool bIsData);
static void PIO_DC_Reset(void);
#if 0
static bool SPIM_IsTxFifoEmpty(void);
#endif
static void SPIM_WriteTxData(byte Data);

static void Write8(byte Data){
    SPIM_WriteTxData(Data);
}

static void PIO_DC_Set(bool bIsData){

    // ss_n0 = 1, [3:0]
    alt_setbits_word( ( lcd_virtual_base + ( ( uint32_t )( ALT_SPIM0_SER_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_SPIM_SER_SER_SET( 1 ) );

    /* Keep reset high */
    alt_setbits_word( ( lcd_virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_RESETn_BIT_GPIObit44_GPIOreg1 );

    // D_C = "H": Data
    // D_C = "L": CMD
    if (bIsData) // A0 = "H": Data
    {
        alt_setbits_word( ( lcd_virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_D_C_BIT_GPIObit41_GPIOreg1 );
    }
}

static void PIO_DC_Reset(void){

    // ss_n0 = 1, [3:0]
    alt_clrbits_word( ( lcd_virtual_base + ( ( uint32_t )( ALT_SPIM0_SER_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_SPIM_SER_SER_SET_MSK );

    /* Keep reset high */
    alt_setbits_word( ( lcd_virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_RESETn_BIT_GPIObit44_GPIOreg1 );

    // D_C = "L": CMD
    alt_clrbits_word( ( lcd_virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_D_C_BIT_GPIObit41_GPIOreg1 );
}

void SPIM_WriteTxData(byte Data){

    while( ALT_SPIM_SR_TFE_GET( alt_read_word( ( lcd_virtual_base + ( ( uint32_t )( ALT_SPIM0_SR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ) ) ) != ALT_SPIM_SR_TFE_E_EMPTY );
    alt_write_word( ( lcd_virtual_base + ( ( uint32_t )( ALT_SPIM0_DR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_SPIM_DR_DR_SET( Data ) );
    while( ALT_SPIM_SR_TFE_GET( alt_read_word( ( lcd_virtual_base + ( ( uint32_t )( ALT_SPIM0_SR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ) ) ) != ALT_SPIM_SR_TFE_E_EMPTY );
    while( ALT_SPIM_SR_BUSY_GET( alt_read_word( ( lcd_virtual_base + ( ( uint32_t )( ALT_SPIM0_SR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ) ) ) != ALT_SPIM_SR_BUSY_E_INACT );
}

/* *****************************************************************************
**                                 API Defns
** ************************************************************************** */
void LCDDrv_Init(void *virtual_base)
{
    lcd_virtual_base = virtual_base;

    //////// lcd reset
    // set the direction of the HPS GPIO1 bits attached to LCD RESETn to output
    alt_setbits_word( ( virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DDR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_RESETn_BIT_GPIObit44_GPIOreg1 );
    // set the value of the HPS GPIO1 bits attached to LCD RESETn to zero
    alt_clrbits_word( ( virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_RESETn_BIT_GPIObit44_GPIOreg1 );
    usleep( 1000000 / 16 );
    // set the value of the HPS GPIO1 bits attached to LCD RESETn to one
    alt_setbits_word( ( virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_RESETn_BIT_GPIObit44_GPIOreg1 );
    usleep( 1000000 / 16 );

    //////// turn-on backlight
    // set the direction of the HPS GPIO1 bits attached to LCD Backlight to output
    alt_setbits_word( ( virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DDR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_BACKLIHGT_BIT_GPIObit37_GPIOreg1 );
    // set the value of the HPS GPIO1 bits attached to LCD Backlight to ZERO, turn OFF the Backlight
    alt_setbits_word( ( virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_BACKLIHGT_BIT_GPIObit37_GPIOreg1 );

    // set LCD-A0 pin as output pin
    alt_setbits_word( ( virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DDR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_D_C_BIT_GPIObit41_GPIOreg1 );
    // set HPS_LCM_D_C to 0
    alt_clrbits_word( ( virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_D_C_BIT_GPIObit41_GPIOreg1 );

    // SPIM0 Init
    usleep( 1000000 / 16 );

    // initialize the  peripheral to talk to the LCM
    alt_clrbits_word( ( virtual_base + ( ( uint32_t )( ALT_RSTMGR_PERMODRST_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_RSTMGR_PERMODRST_SPIM0_SET_MSK );

    //===================
    // step 1: disable SPI
    //         writing 0 to the SSI Enable register (SSIENR).
    //
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
    alt_clrbits_word( ( virtual_base + ( ( uint32_t )( ALT_SPIM0_CTLR0_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_SPIM_CTLR0_TMOD_SET_MSK );
    alt_setbits_word( ( virtual_base + ( ( uint32_t )( ALT_SPIM0_CTLR0_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_SPIM_CTLR0_TMOD_SET( ALT_SPIM_CTLR0_TMOD_E_TXONLY ) );

    // 200MHz / 64 = 3.125MHz: [15:0] = 64
    alt_clrbits_word( ( virtual_base + ( ( uint32_t )( ALT_SPIM0_BAUDR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_SPIM_BAUDR_SCKDV_SET_MSK );
    alt_setbits_word( ( virtual_base + ( ( uint32_t )( ALT_SPIM0_BAUDR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_SPIM_BAUDR_SCKDV_SET( 64 ) );

    // ss_n0 = 1, [3:0]
    alt_clrbits_word( ( virtual_base + ( ( uint32_t )( ALT_SPIM0_SER_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_SPIM_SER_SER_SET_MSK );
    alt_setbits_word( ( virtual_base + ( ( uint32_t )( ALT_SPIM0_SER_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_SPIM_SER_SER_SET( 1 ) );

    //===================
    // step 3: Enable the SPI master by writing 1 to the SSIENR register.
    // ALT_SPIM0_SPIENR_ADDR
    alt_setbits_word( ( virtual_base + ( ( uint32_t )( ALT_SPIM0_SPIENR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), ALT_SPIM_SPIENR_SPI_EN_SET_MSK );

    // step 4: Write data for transmission to the target slave into the transmit FIFO buffer (write DR)
    //alt_setbits_word( ( virtual_base + ( ( uint32_t )( ALT_SPIM0_DR_ADDR ) & ( uint32_t )( ALT_SPIM1_SPIENR_ADDR ) ) ), data16 );

}

void LCDDrv_Debug(boolean bDebug)
{
    dword dwDebug;

    if(TRUE==bDebug)
    {
        printf("------------------------\n");
        dwDebug=alt_read_word(( lcd_virtual_base + ( ( uint32_t )( ALT_SPIM0_SER_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ));
        printf("Chip select : 0x%.8x\n",dwDebug);
        dwDebug=alt_read_word(( lcd_virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ));
        printf("A0,BackLight,Res : 0x%.8x\n",dwDebug);
        printf("------------------------\n");
    }

    return;
}

void LCDDrv_Display(bool bOn)
{
    PIO_DC_Set(0);
    Write8(bOn?0xAF:0xAE);
    PIO_DC_Reset();
}

/* Specifies line address (refer to Figure 6) to determine the initial display line */
/* When this command changes the line address, smooth scrolling or a page change takes place */
void LCDDrv_SetStartLine(byte StartLine)
{
    PIO_DC_Set(0);
    Write8(0x40 | (StartLine & 0x3F));
    PIO_DC_Reset();
}

void LCDDrv_SetPageAddr(byte PageAddr)
{
    PIO_DC_Set(0);
    Write8(0xB0 | (PageAddr & 0x0F));
    PIO_DC_Reset();
}

void LCDDrv_SetColAddr(byte ColAddr)
{
    PIO_DC_Set(0);
    Write8(0x00 | (ColAddr & 0x0F)); // low 4 bits
    Write8(0x10 | ((ColAddr >> 4) & 0x0F)); // high 4-bits
    PIO_DC_Reset();
}

void LCDDrv_WriteData(byte Data)
{
    PIO_DC_Set(1);
    Write8(Data);
    PIO_DC_Reset();
}

void LCDDrv_WriteMultiData(byte * Data, dword num)
{
    int i;
    PIO_DC_Set(1);
    for(i=0;i<num;i++)
    {
        Write8(*(Data+i));
    }
    PIO_DC_Reset();
}

void LCDDrv_SetADC(bool bNormal)
{
    PIO_DC_Set(0);
    Write8(bNormal?0xA0:0xA1);
    PIO_DC_Reset();
}

void LCDDrv_SetReverse(bool bNormal)
{
    PIO_DC_Set(0);
    Write8(bNormal?0xA6:0xA7);
    PIO_DC_Reset();
}

void LCDDrv_EntireOn(bool bEntireOn)
{
    PIO_DC_Set(0);
    Write8(bEntireOn?0xA5:0xA4);
    PIO_DC_Reset();
}

void LCDDrv_SetBias(bool bDefault)
{
    PIO_DC_Set(0);
    Write8(bDefault?0xA2:0xA3);
    PIO_DC_Reset();
}

/*
** Once Read-Modify-Write is issued, column address is not incremental by Read Display Data command
** but incremental by Write Display Data command only.
** It continues until End command is issued.
*/
void LCDDrv_ReadModifyWrite_Start(void)
{
    PIO_DC_Set(0);
    Write8(0xE0);
    PIO_DC_Reset();
}

void LCDDrv_ReadModifyWrite_End(void)
{
    PIO_DC_Set(0);
    Write8(0xEE);
    PIO_DC_Reset();
}

void LCDDrv_Reset(void)
{
    PIO_DC_Set(0);
    Write8(0xE2);
    PIO_DC_Reset();
}

void LCDDrv_StallScreen(void)
{
    PIO_DC_Set(0);
    Write8(0xA5); /* was 0xE3 */
    PIO_DC_Reset();
}

void LCDDrv_SetOsc(bool bDefault)
{
    PIO_DC_Set(0);
    Write8(bDefault?0xE4:0xE5);
    PIO_DC_Reset();
}

void LCDDrv_SetPowerControl(byte PowerMask)
{
    PIO_DC_Set(0);
    Write8(0x28 | (PowerMask & 0x7));
    PIO_DC_Reset();
}

void LCDDrv_SetResistorRatio(byte Value)
{
    PIO_DC_Set(0);
    Write8(0x20 | (Value & 0x7));
    PIO_DC_Reset();
}

void LCDDrv_SetElectricVolume(byte Value)
{
    PIO_DC_Set(0);
    /* write two bytes */
    Write8(0x81);
    Write8(Value & 0x3F);
    PIO_DC_Reset();
}

void LCDDrv_SetOuputStatusSelect(bool bNormal)
{
    PIO_DC_Set(0);
    Write8(bNormal?0xC0:0xC8);
    PIO_DC_Reset();
}

void LCDDrv_StaticOn(bool bNormal)
{
    PIO_DC_Set(0);
    Write8(bNormal?0xAD:0xAC);
    PIO_DC_Reset();
}

void LCDDrv_BackLight(bool bON)
{
    if (bON)
    {
        alt_setbits_word( ( lcd_virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_BACKLIHGT_BIT_GPIObit37_GPIOreg1 );
        alt_setbits_word( ( lcd_virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_RESETn_BIT_GPIObit44_GPIOreg1 );
    }
    else
    {
        alt_clrbits_word( ( lcd_virtual_base + ( ( uint32_t )( ALT_GPIO1_SWPORTA_DR_ADDR ) & ( uint32_t )( HW_REGS_MASK ) ) ), HPS_LCM_BACKLIHGT_BIT_GPIObit37_GPIOreg1 );
    }
}
