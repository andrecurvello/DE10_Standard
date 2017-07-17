/* *****************************************************************************
**
**                       Standalone bitcoin miner
**
** Project      : DE10 Standard mining rig
** Module       : LED_Drv.c
**
** Description  : Definition and implementation of the LCD driver module.
**
** ************************************************************************** */

/* *****************************************************************************
**  REVISION HISTORY
** Date         Inits   Description
** ----------------------------------------------------------------------------
** 28.05.17     bd      [no issue number] File creation
** ----------------------------------------------------------------------------
** 17.07.17     bd      [no issue number] Tidy up. Start implementation of the
**                                        mining rig
**
** ************************************************************************** */
#ifndef NT7534_DRIVER_H
#define NT7534_DRIVER_H

/* *****************************************************************************
**                          SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "Macros.h" /* Divers macros definitions */
#include "Types.h"  /* Legacy types definitions */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "terasic_os_includes.h" /* terasic lib declarations */

/* *****************************************************************************
**                                  API
** ************************************************************************** */
void LCDDrv_Init(void *virtual_base);
void LCDDrv_BackLight(bool bON);

void LCDDrv_Display(bool bOn);
void LCDDrv_Debug(boolean bOn);
void LCDDrv_SetStartLine(byte StartLine);
void LCDDrv_SetPageAddr(byte PageAddr);
void LCDDrv_SetColAddr(byte ColAddr);
void LCDDrv_WriteData(byte Data);
void LCDDrv_WriteMultiData(byte * Data, dword num);
void LCDDrv_SetElectricVolume(byte Value);
void LCDDrv_StaticOn(bool bNormal);

void LCDDrv_EntireOn(bool bEntireOn);
void LCDDrv_SetADC(bool bNormal);
void LCDDrv_SetReverse(bool bNormal);
void LCDDrv_SetBias(bool bEntireOn);
void LCDDrv_SetBias(bool bDefault);
void LCDDrv_ReadModifyWrite_Start(void);
void LCDDrv_ReadModifyWrite_End(void);
void LCDDrv_Reset(void);
void LCDDrv_StallScreen(void);
void LCDDrv_SetOsc(bool bDefault);
void LCDDrv_SetPowerControl(byte PowerMask);
void LCDDrv_SetResistorRatio(byte Value);
void LCDDrv_SetOuputResistorRatio(byte Value);
void LCDDrv_SetOuputStatusSelect(bool bNormal);

#endif
