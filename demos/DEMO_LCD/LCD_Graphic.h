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
#ifndef INC_LCD_GRAPHIC_H
#define INC_LCD_GRAPHIC_H

/* *****************************************************************************
**                          SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "Macros.h" /* Divers macros definitions */
#include "Types.h"  /* Legacy types definitions */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
#define LCD_WIDTH (128)
#define LCD_HEIGHT (64)

#define LCD_WHITE   0x00
#define LCD_BLACK   0xFF

#define LCD_CELL_SIZE_X (16)
#define LCD_CELL_SIZE_Y (2)

/* *****************************************************************************
**                                 GLOBALS
** ************************************************************************** */

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */
typedef unsigned char FONT_BITMAP[LCD_CELL_SIZE_Y][LCD_CELL_SIZE_X];

typedef struct{
    int FontWidth;
    int FontHeight;
    int CellWidth;
    int CellHeight;
    int CodeStart;
    int CodeEnd;
    int BitPerPixel;
    FONT_BITMAP *pBitmap;
}FONT_TABLE;

typedef struct{

    word Width;
    word Height;
    word BitPerPixel;
    word FrameSize;
    byte *pFrame;

} stLCDDrv_Canvas_t;

/* *****************************************************************************
**                                  API
** ************************************************************************** */
void LCDGrph_Init(void);
void LCDGrph_Clear( stLCDDrv_Canvas_t *pCanvas, word Color );
void LCDGrph_ClearScreen( void );
void LCDGrph_Refresh(stLCDDrv_Canvas_t *pCanvas );

/* 1 Dimension */
void LCDGrph_Pixel( stLCDDrv_Canvas_t *pCanvas,
                    word X,
                    word Y,
                    word Color );

/* 2 Dimensions */
void LCDGrph_Line( stLCDDrv_Canvas_t *pCanvas,
                   word X1,
                   word Y1,
                   word X2,
                   word Y2,
                   word Color );

void LCDGrph_DrawRect( stLCDDrv_Canvas_t *pCanvas,
                       word X1,
                       word Y1,
                       word X2,
                       word Y2,
                       word Color );

void LCDGrph_DrawCircle( stLCDDrv_Canvas_t *pCanvas,
                         word x0,
                         word y0,
                         word Radius,
                         word Color );

/* String and char management */
void LCDGrph_PrintChar( stLCDDrv_Canvas_t *pCanvas,
                        word X0,
                        word Y0,
                        char Text,
                        word Color );

void LCDGrph_PrintString( stLCDDrv_Canvas_t *pCanvas,
                          word X0,
                          word Y0,
                          char *pText,
                          word Color );

#endif
