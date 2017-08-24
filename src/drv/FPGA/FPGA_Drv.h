/* *****************************************************************************
**
**                       DE10 Standard project
**
** Project      : DE10 standard project
** Module       : FPGA_Drv
**
** Description  : Provide access to the FPGA fabric.
**
** ************************************************************************** */

/* *****************************************************************************
**  REVISION HISTORY
** Date         Inits   Description
** ----------------------------------------------------------------------------
** 08.08.17     bd      [no issue number] File creation
**
** ************************************************************************** */
#ifndef FPGA_DRV_H
#define FPGA_DRV_H

/* *****************************************************************************
**                          SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "Macros.h" /* Divers macros definitions */
#include "Types.h"  /* Legacy types definitions */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "SCHEDULER.h"

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */
typedef enum
{
    eFPGA_IDLE = 0,
    eFPGA_COMPUTING

} eFPGA_State_t;

typedef struct
{
    void *pvVirtBase;

} FPGA_Drv_Result_t;

/* *****************************************************************************
**                               PUBLIC INTFC
** ************************************************************************** */
FPGA_Drv_Result_t *pstFPGA_Drv_Results;

/* *****************************************************************************
**                                  API
** ************************************************************************** */
dword FPGA_Drv_Setup(void);
dword FPGA_Drv_Init(void);

dword FPGA_Drv_StageWork(stSCHEDULER_Work_t * const pstWork);
eFPGA_State_t FPGA_Drv_GetStatus(void);

void FPGA_Drv_Shutdown(void); /* Avoid segfault and wrong access to phy memory */

#endif
