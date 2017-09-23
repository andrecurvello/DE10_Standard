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
#include "SCHEDULER.h"  /* Scheduler defns */

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */
typedef enum
{
    eJSON_SUCCESS=0,
    eJSON_ERR

}eJSON_Status_t;

typedef struct
{
    byte * abyUser;
    byte * abyPass;
    word wWorkId;

} stJSON_Auth_Demand_t;

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */

/* *****************************************************************************
**                                  API
** ************************************************************************** */
eJSON_Status_t JSON_Ser_ReqConnect(const word wWorkId, byte * const pbyRequest);
eJSON_Status_t JSON_Deser_ResConnect( stSCHEDULER_Work_t * const pstResult, byte * const pbyResponse);

eJSON_Status_t JSON_Ser_ReqAuth(const stJSON_Auth_Demand_t * const pstDemand, byte * const pbyRequest);
eJSON_Status_t JSON_Deser_ResAuth(byte * const pbyResponse); /* If return is successfull. Authentication has worked. */

eJSON_Status_t JSON_Deser_ResJob(stSCHEDULER_Work_t * const pstResult,byte * const pbyResponse);

double JSON_Deser_ResDifficulty(byte * const pbyResponse);

eJSON_Status_t JSON_Ser_ReqShare(byte * const pbyResponse);

#endif
