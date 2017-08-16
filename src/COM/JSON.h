/* *****************************************************************************
**
**                       Standalone bitcoin miner
**
** Project      : DE10 Standard kit review
** Module       : json
**
** Description  : json serialize/deserialize routines
**
** ************************************************************************** */

/* *****************************************************************************
**  REVISION HISTORY
** Date         Inits   Description
** ----------------------------------------------------------------------------
** 16.08.17     bd      [no issue number] File creation
**
** ************************************************************************** */
#ifndef STRATUM_JSON_H
#define STRATUM_JSON_H

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

/* *****************************************************************************
**                                  API
** ************************************************************************** */
byte* JSON_Ser_PoolConnect(void);   /* Protocol config and so on. Callable once */
byte* JSON_Deser_PoolConnect(void); /* Protocol config and so on. Callable once */

byte* JSON_Ser_PoolAuth(void);    /* Protocol config and so on. Callable once */
byte* JSON_Deser_PoolAuth(void);  /* Protocol config and so on. Callable once */

byte* JSON_Deser_PoolJob(void);  /* Protocol config and so on. Callable once */

byte* JSON_Deser_PoolDifficulty(void);  /* Protocol config and so on. Callable once */

byte* JSON_Ser_PoolShare(void);  /* Protocol config and so on. Callable once */

#endif
