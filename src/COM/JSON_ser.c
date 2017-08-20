/* *****************************************************************************
**
**                       Standalone bitcoin miner
**
** Project      : User Interface manager
** Module       : stratum.c
**
** Description  : stratum protocol specific module
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

#include <stdio.h>  /* Standard IO defns */
#include <string.h> /* String defns */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "JSON_ser.h" /* JSON serialization */
#include "json.h"     /* lib defs */

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
**                                 LOCALS
** ************************************************************************** */

/* *****************************************************************************
**                              LOCALS ROUTINES
** ************************************************************************** */

/* *****************************************************************************
**                                  API
** ************************************************************************** */
eJSON_Status_t JSON_Ser_ReqConnect(const word wWorkId, byte * const pbyRequest)
{
    eJSON_Status_t eRetVal;

    /* Init locals */
    eRetVal = eJSON_ERR;

    if( NULL != pbyRequest )
    {
        /* Formulate request to stratum server */
        sprintf((char*)pbyRequest, "{\"id\": %d, \"method\": \"mining.subscribe\", \"params\": []}", wWorkId);

        /* Important ! */
        strcat((char*)pbyRequest, "\n");

        /* Update return value */
        eRetVal = eJSON_SUCCESS;
    }

    return eRetVal;
}

eJSON_Status_t JSON_Deser_ResConnect( stJSON_Connect_Result_t * const pstResult, byte * const pbyResponse )
{
    eJSON_Status_t eRetVal;
    json_object *stJsonObj;
    json_object *stJsonErr;
    json_object *stJsonRes;

    /* Init locals */
    eRetVal = eJSON_ERR;

    if(   ( NULL != pbyResponse )
       && ( NULL != pstResult )
      )
    {
        stJsonObj = json_tokener_parse((const char*)pbyResponse);

        /* Get value of each object */
        json_object_object_get_ex(stJsonObj, "result",&stJsonRes);
        json_object_object_get_ex(stJsonObj, "error",&stJsonErr);

        /* Is the answer sound ? */
        if( 0 == json_object_get_int(stJsonErr) )
        {
            /* Update return value */
            eRetVal = eJSON_SUCCESS;

            /* Deserialise nonce 1, that is the "session Id" */
            stJsonObj = json_object_array_get_idx(stJsonRes,1);
            pstResult->abyNonce1 = (byte*)json_object_get_string(stJsonObj);

            /* Deserialise nonce 2 size */
            stJsonObj = json_object_array_get_idx(stJsonRes,2);
            pstResult->wN2size = json_object_get_int(stJsonObj);

            /* Ignore the 2-tuples for the time being */

            /* do we need to free some memory ? */
        }
    }

    return eRetVal;
}

eJSON_Status_t JSON_Ser_ReqAuth(const stJSON_Auth_Demand_t * const pstDemand, byte * const pbyRequest)
{
    eJSON_Status_t eRetVal;

    /* Init locals */
    eRetVal = eJSON_ERR;

    if(   ( NULL != pbyRequest )
       && ( NULL != pstDemand )
      )
    {
        /* Prepare JSON request */
        sprintf( (char*)pbyRequest,
                 "{\"id\": %d, \"method\": \"mining.authorize\", \"params\": [\"%s\", \"%s\"]}",
                 pstDemand->wWorkId,
                 (char*)pstDemand->abyUser,
                 (char*)pstDemand->abyPass );
        strcat((char*)pbyRequest, "\n"); /* Do not forget to add \n */

        /* Update return value */
        eRetVal = eJSON_SUCCESS;
   }

    return eRetVal;
}

eJSON_Status_t JSON_Deser_ResAuth(byte * const pbyResponse)
{
    eJSON_Status_t eRetVal;
    json_object *stJsonObj;
    json_object *stJsonErr;
    json_object *stJsonRes;

    /* Init locals */
    eRetVal = eJSON_ERR;

    if( NULL != pbyResponse )
    {
        stJsonObj = json_tokener_parse((const char*)pbyResponse);

        /* Get value of each object */
        json_object_object_get_ex(stJsonObj, "result",&stJsonRes);
        json_object_object_get_ex(stJsonObj, "error",&stJsonErr);

        /* Is the answer sound ? */
        if(   ( 0 == json_object_get_int(stJsonErr) )
           && ( 1 == json_object_get_boolean(stJsonRes) )
          )
        {
            /* Answer is sound, update return value */
            eRetVal = eJSON_SUCCESS;
        }
    }

    return eRetVal;
}

eJSON_Status_t JSON_Deser_ResJob(stJSON_Job_Result_t * const pstResult,byte * const pbyResponse)
{
    eJSON_Status_t eRetVal;
    json_object *stJsonObj;
    json_object *stJsonArr;

    /* Init locals */
    eRetVal = eJSON_ERR;

    if( NULL != pbyResponse )
    {
        stJsonObj = json_tokener_parse((const char*)pbyResponse);

        /* Get value of each object */
        json_object_object_get_ex(stJsonObj, "params", &stJsonArr);

        /* Deserialise Job Id */
        stJsonObj = json_object_array_get_idx(stJsonArr,0);
        pstResult->abyJobId = (byte*)json_object_get_string(stJsonObj);

        /* Deserialise previous hash */
        stJsonObj = json_object_array_get_idx(stJsonArr,1);
        pstResult->abyPrevHash = (byte*)json_object_get_string(stJsonObj);

        /* Deserialise Coinbase 1 */
        stJsonObj = json_object_array_get_idx(stJsonArr,2);
        pstResult->abyCoinBase1 = (byte*)json_object_get_string(stJsonObj);

        /* Deserialise Coinbase 2 */
        stJsonObj = json_object_array_get_idx(stJsonArr,3);
        pstResult->abyCoinBase2 = (byte*)json_object_get_string(stJsonObj);

        /* What about merkle branches ????? */

        /* Deserialise block version */
        stJsonObj = json_object_array_get_idx(stJsonArr,5);
        pstResult->abyBlckVer = (byte*)(json_object_get_string(stJsonObj));

        /* Deserialise nbits, network difficulty */
        stJsonObj = json_object_array_get_idx(stJsonArr,6);
        pstResult->abyNbits = (byte*)(json_object_get_string(stJsonObj));

        /* Deserialise time, crypto-system clock */
        stJsonObj = json_object_array_get_idx(stJsonArr,7);
        pstResult->abyNtime = (byte*)(json_object_get_string(stJsonObj));

        /* Deserialise clean, is it still relevent to share for that block ?*/
        stJsonObj = json_object_array_get_idx(stJsonArr,8);
        pstResult->bCleanJobs = (boolean)json_object_get_boolean(stJsonObj);

        /* Answer is sound, update return value */
        eRetVal = eJSON_SUCCESS;
    }

    return eRetVal;
}

eJSON_Status_t JSON_Deser_ResDifficulty(byte * const pbyResponse)
{
    eJSON_Status_t eRetVal;

    /* Init locals */
    eRetVal = eJSON_ERR;

    return eRetVal;
}

eJSON_Status_t JSON_Ser_ReqShare(byte * const pbyResponse)
{
    eJSON_Status_t eRetVal;

    /* Init locals */
    eRetVal = eJSON_ERR;

    return eRetVal;
}

/* *****************************************************************************
**                            LOCALS ROUTINES Defn
** ************************************************************************** */
