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
#ifndef JSON_SER_H
#define JSON_SER_H

/* *****************************************************************************
**                          SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "Macros.h" /* Divers macros definitions */
#include "Types.h"  /* Legacy types definitions */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
typedef enum
{
    eJSON_SUCCESS=0,
    eJSON_ERR

}eJSON_Status_t;

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */

/* *****************************************************************************
**                                  API
** ************************************************************************** */
eJSON_Status_t JSON_Ser_ReqConnect(const word wWorkId, byte * const pbyRequest);
eJSON_Status_t JSON_Deser_ResConnect(void);

eJSON_Status_t JSON_Ser_ReqAuth(const byte * abyUser, const byte * abyPass, const word wWorkId, byte * const pbyRequest);
eJSON_Status_t JSON_Deser_ResAuth(void);

eJSON_Status_t JSON_Deser_ResJob(void);

eJSON_Status_t JSON_Deser_ResDifficulty(void);

eJSON_Status_t JSON_Ser_ReqShare(void);

#endif
