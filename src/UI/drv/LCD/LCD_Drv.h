/* *****************************************************************************
**
**                       Standalone bitcoin miner
**
** Project      : DE10 Standard kit review
** Module       : LED_Drv.h
**
** Description  : Declarations of the LCD screen module
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
#include "Types.h"          /*  */
#include "Macros.h"         /*  */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "hwlib.h"          /*  */
#include "socal/socal.h"    /*  */
#include "socal/hps.h"      /*  */
#include "socal/alt_gpio.h" /*  */
#include "socal/alt_spim.h" /*  */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
#define LCD_WHITE  0x00
#define LCD_BLACK  0xFF
#define LCD_WIDTH  128
#define LCD_HEIGHT 64

/* *****************************************************************************
** Font table information :
**   Font size                -> 8 x 16 (pixels)
**   Font cell size for lcd   -> 16 x 16 (pixels)  16 x 2 (byte_array)
**   ASCII coding index range -> 0x00 ~ 0xff
**   Cell looking up method   -> &font_table[ascii_code][0][0]
** ************************************************************************** */

/* #define FONT_SIZE_X (8) */
/* #define FONT_SIZE_Y (16) */

/* #define CELL_SIZE_X (16) */
/* #define CELL_SIZE_Y (16) */

#define LCD_CELL_SIZE_X (16)
#define LCD_CELL_SIZE_Y (2)

/* #define FONTTBL_ASCII_CODE_MIN (0x00) */
/* #define FONTTBL_ASCII_CODE_MAX (0xff) */

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */
typedef struct{
    word Width;
    word Height;
    word BitPerPixel;
    word FrameSize;
    byte *pbyFrame;
}stLCD_DRV_Canvas_t;

typedef byte FONT_BITMAP[LCD_CELL_SIZE_Y][LCD_CELL_SIZE_X];

typedef struct{
    word FontWidth;
    word FontHeight;
    word CellWidth;
    word CellHeight;
    word CodeStart;
    word CodeEnd;
    word BitPerPixel;
    FONT_BITMAP *pBitmap;
}stLCD_DRV_FontTable_t;

/* *****************************************************************************
**                                 GLOBALS
** ************************************************************************** */
// hint: unsigned char font_table[ascii_code][lcd_cell_height/8][lcd_cell_width]
extern stLCD_DRV_FontTable_t  stLCD_DRV_FontTable_16x16;

/* *****************************************************************************
**                                  API
** ************************************************************************** */
#if 0
void LCDHW_Init(void *virtual_base);
void LCDHW_BackLight(boolean bON);
void LCDHW_Write8(byte bIsData, byte Data);

void LCDDrv_Display(boolean bOn);
void LCDDrv_SetStartLine(byte StartLine);
void LCDDrv_SetPageAddr(byte PageAddr);
void LCDDrv_SetColAddr(byte ColAddr);
void LCDDrv_WriteData(byte Data);
void LCDDrv_WriteMultiData(byte * Data, dword num);

void LCDDrv_SetADC(boolean bNormal);
void LCDDrv_SetReverse(boolean bNormal);
void LCDDrv_SetBias(boolean bEntireOn);
void LCDDrv_SetBias(boolean bDefault);
void LCDDrv_ReadModifyWrite_Start(void);
void LCDDrv_ReadModifyWrite_End(void);
void LCDDrv_Reset(void);
void LCDDrv_SetOsc(boolean bDefault);
void LCDDrv_SetPowerControl(byte PowerMask);
void LCDDrv_SetResistorRatio(byte Value);
void LCDDrv_SetOuputResistorRatio(byte Value);
void LCDDrv_SetOuputStatusSelect(boolean bNormal);

void DRAW_Clear(stLCD_DRV_Canvas_t *pCanvas, word Color);
void DRAW_Line(stLCD_DRV_Canvas_t *pCanvas, word X1, word Y1, word X2, word Y2, word Color);
void DRAW_Pixel(stLCD_DRV_Canvas_t *pCanvas, word X, word Y, word Color);
void DRAW_Rect(stLCD_DRV_Canvas_t *pCanvas, word X1, word Y1, word X2, word Y2, word Color);
void DRAW_Circle(stLCD_DRV_Canvas_t *pCanvas, word x0, word y0, word Radius, word Color);
void DRAW_Refresh(stLCD_DRV_Canvas_t *pCanvas);

void DRAW_PrintChar(stLCD_DRV_Canvas_t *pCanvas, word X0, word Y0, byte Text, word Color, stLCD_DRV_FontTable_t *font_table);
void DRAW_PrintString(stLCD_DRV_Canvas_t *pCanvas, word X0, word Y0, byte *pText, word Color, stLCD_DRV_FontTable_t *font_table);
#endif
