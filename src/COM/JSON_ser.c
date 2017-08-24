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
    json_object *pstJsonObj;
    json_object *pstJsonErr;
    json_object *pstJsonRes;

    /* Init locals */
    eRetVal = eJSON_ERR;

    if(   ( NULL != pbyResponse )
       && ( NULL != pstResult )
      )
    {
        pstJsonObj = json_tokener_parse((const char*)pbyResponse);

        /* Get value of each object */
        json_object_object_get_ex(pstJsonObj, "result",&pstJsonRes);
        json_object_object_get_ex(pstJsonObj, "error",&pstJsonErr);

        /* Is the answer sound ? */
        if( 0 == json_object_get_int(pstJsonErr) )
        {
            /* Update return value */
            eRetVal = eJSON_SUCCESS;

            /* Deserialise nonce 1, that is the "session Id" */
            pstJsonObj = json_object_array_get_idx(pstJsonRes,1);
            memcpy(pstResult->abyNonce1,json_object_get_string(pstJsonObj),NONCE1_SIZE);

            /* Deserialise nonce 2 size */
            pstJsonObj = json_object_array_get_idx(pstJsonRes,2);
            pstResult->wN2size = json_object_get_int(pstJsonObj);
        }

        /* Free allocated memory */
        free(pstJsonObj);
        free(pstJsonErr);
        free(pstJsonRes);
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
    json_object *pstJsonObj;
    json_object *pstJsonErr;
    json_object *pstJsonRes;

    /* Init locals */
    eRetVal = eJSON_ERR;

    if( NULL != pbyResponse )
    {
        pstJsonObj = json_tokener_parse((const char*)pbyResponse);

        /* Get value of each object */
        json_object_object_get_ex(pstJsonObj, "result",&pstJsonRes);
        json_object_object_get_ex(pstJsonObj, "error",&pstJsonErr);

        /* Is the answer sound ? */
        if(   ( 0 == json_object_get_int(pstJsonErr) )
           && ( 1 == json_object_get_boolean(pstJsonRes) )
          )
        {
            /* Answer is sound, update return value */
            eRetVal = eJSON_SUCCESS;
        }

        /* Free allocated memory */
        free(pstJsonObj);
        free(pstJsonRes);
        free(pstJsonErr);
    }

    return eRetVal;
}

eJSON_Status_t JSON_Deser_ResJob(stJSON_Job_Result_t * const pstResult,byte * const pbyResponse)
{
    eJSON_Status_t eRetVal;
    json_object *pstJsonObj;
    json_object *pstJsonArr;
    json_object *pstJsonMeth;
    char * pbyData;
    dword dwMerkleBLen;
    dword dwIndex;

    /* Init locals */
    eRetVal = eJSON_SUCCESS;
    pbyData = NULL;

    if( NULL != pbyResponse )
    {
        pstJsonObj = json_tokener_parse((const char*)pbyResponse);

        /* Get value of each object */
        json_object_object_get_ex(pstJsonObj, "params", &pstJsonArr);
        json_object_object_get_ex(pstJsonObj, "method", &pstJsonMeth);

        if( 0 == strcmp(json_object_get_string(pstJsonMeth),"mining.set_difficulty") )
        {
            if ( eJSON_SUCCESS == JSON_Deser_ResDifficulty( pstResult->doLiveDifficulty,
                                                            (byte*const)pbyResponse )
               )
            {
                /* Slice up these two JSON request */
                pbyData = strchr((char*)pbyResponse, '{');
                pstJsonObj = json_tokener_parse((const char*)pbyData);

                json_object_object_get_ex(pstJsonObj, "params", &pstJsonArr);
            }
            else
            {
                /* Update return value consequently */
                eRetVal = eJSON_ERR;
            }
        }

        /* Deserialise Job Id */
        pstJsonObj = json_object_array_get_idx(pstJsonArr,0);
        memcpy( pstResult->abyJobId,json_object_get_string(pstJsonObj),JOBID_SIZE);

        /* Deserialise previous hash */
        pstJsonObj = json_object_array_get_idx(pstJsonArr,1);
        memcpy( pstResult->abyPrevHash,json_object_get_string(pstJsonObj),HASH_SIZE);

        /* Deserialise Coinbase 1 */
        pstJsonObj = json_object_array_get_idx(pstJsonArr,2);
        memcpy( pstResult->abyCoinBase1,json_object_get_string(pstJsonObj),COINBASE1_SIZE);

        /* Deserialise Coinbase 2 */
        pstJsonObj = json_object_array_get_idx(pstJsonArr,3);
        memcpy( pstResult->abyCoinBase2,json_object_get_string(pstJsonObj),COINBASE2_SIZE);

        /* Merkle branches  */
        pstJsonObj = json_object_array_get_idx(pstJsonArr,4);
        dwMerkleBLen = json_object_array_length(pstJsonObj);
        for( dwIndex=0 ; dwIndex < dwMerkleBLen ; dwIndex++ )
        {
            if( MERKLE_TREE_MAX_DEPTH < dwIndex )
            {
                /* Update return value consequently */
                eRetVal = eJSON_ERR;
                break;
            }

            /* Copy memory */
            memcpy( (*(pstResult->abyMerkleBranch + dwIndex)),
                    json_object_get_string(pstJsonObj),
                    MERKLE_SIZE );
        }

        /* Deserialise block version */
        pstJsonObj = json_object_array_get_idx(pstJsonArr,5);
        memcpy( pstResult->abyBlckVer, json_object_get_string(pstJsonObj), BLOCK_VER_SIZE );

        /* Deserialise nbits, network difficulty */
        pstJsonObj = json_object_array_get_idx(pstJsonArr,6);
        memcpy( pstResult->abyNbits, json_object_get_string(pstJsonObj), NBITS_SIZE );

        /* Deserialise time, crypto-system clock */
        pstJsonObj = json_object_array_get_idx(pstJsonArr,7);
        memcpy( pstResult->abyNtime, json_object_get_string(pstJsonObj), NTIME_SIZE );

        /* Deserialise clean, is it still relevent to share for that block ?*/
        pstJsonObj = json_object_array_get_idx(pstJsonArr,8);
        pstResult->bCleanJobs = (boolean)json_object_get_boolean(pstJsonObj);

        /* Free allocated memory */
        free(pstJsonObj);
        free(pstJsonArr);
        free(pstJsonMeth);
    }

    return eRetVal;
}

eJSON_Status_t JSON_Deser_ResDifficulty(double doLiveDifficulty, byte * const pbyResponse)
{
    eJSON_Status_t eRetVal;
    json_object *pstJsonObj;
    json_object *pstJsonErr;
    json_object *pstJsonRes;

    /* Init locals */
    eRetVal = eJSON_ERR;

    if( NULL != pbyResponse )
    {
        pstJsonObj = json_tokener_parse((const char*)pbyResponse);

        /* Get value of each object */
        json_object_object_get_ex(pstJsonObj, "result",&pstJsonRes);
        json_object_object_get_ex(pstJsonObj, "error",&pstJsonErr);

        /* Is the answer sound ? */
        if(   ( 0 == json_object_get_int(pstJsonErr) )
           && ( 1 == json_object_get_boolean(pstJsonRes) )
          )
        {
            /* Answer is sound, update return value */
            eRetVal = eJSON_SUCCESS;
        }

        /* Free allocated memory */
        free(pstJsonObj);
        free(pstJsonErr);
        free(pstJsonRes);
    }

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
