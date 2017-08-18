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

#include <stdio.h>    /* Standard IO defns */
#include <string.h>   /* String defns */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "JSON_ser.h"     /* JSON serialization */
#include "json.h"         /* lib defs */

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
            stJsonObj = json_object_array_get_idx(stJsonRes,3);
            pstResult->abyNonce1 = (byte*)json_object_get_string(stJsonObj);

            /* Deserialise nonce 2 size */
            stJsonObj = json_object_array_get_idx(stJsonRes,4);
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

    /* Init locals */
    eRetVal = eJSON_ERR;

    if( NULL != pbyResponse )
    {
        /* Always check error,id and result anyway */
        eRetVal = eJSON_SUCCESS;
    }

#if 0
    val = JSON_LOADS(sret, &err);
    free(sret);
    res_val = json_object_get(val, "result");
    err_val = json_object_get(val, "error");

    if (!res_val || json_is_false(res_val) || (err_val && !json_is_null(err_val)))  {
        char *ss;

        if (err_val)
            ss = json_dumps(err_val, JSON_INDENT(3));
        else
            ss = strdup("(unknown reason)");
        applog(LOG_INFO, "pool %d JSON stratum auth failed: %s", pool->pool_no, ss);
        free(ss);

        suspend_stratum(pool);

        goto out;
    }

    ret = true;
    applog(LOG_INFO, "Stratum authorisation success for pool %d", pool->pool_no);
    pool->probed = true;
    successful_connect = true;

    if (opt_suggest_diff) {
        sprintf(s, "{\"id\": %d, \"method\": \"mining.suggest_difficulty\", \"params\": [%d]}",
            swork_id++, opt_suggest_diff);
        stratum_send(pool, s, strlen(s));
    }
#endif

    return eRetVal;
}

eJSON_Status_t JSON_Deser_ResJob(stJSON_Job_Result_t * const pstResult,byte * const pbyResponse)
{
    eJSON_Status_t eRetVal;

    /* Init locals */
    eRetVal = eJSON_ERR;

    /* Init locals */
     eRetVal = eJSON_ERR;

     if(   ( NULL != pbyResponse )
        && ( NULL != pstResult )
       )
     {
         eRetVal=eJSON_SUCCESS;
     }

#if 0
    val = JSON_LOADS(s, &err);
    if (!val) {
        applog(LOG_INFO, "JSON decode failed(%d): %s", err.line, err.text);
        goto out;
    }

    method = json_object_get(val, "method");
    if (!method)
        goto out_decref;
    err_val = json_object_get(val, "error");
    params = json_object_get(val, "params");

    if (err_val && !json_is_null(err_val)) {
        char *ss;

        if (err_val)
            ss = json_dumps(err_val, JSON_INDENT(3));
        else
            ss = strdup("(unknown reason)");

        applog(LOG_INFO, "JSON-RPC method decode failed: %s", ss);
        free(ss);
        goto out_decref;
    }

    buf = (char *)json_string_value(method);
    if (!buf)
        goto out_decref;

    if (!strncasecmp(buf, "mining.notify", 13)) {
        if (parse_notify(pool, params))
            pool->stratum_notify = ret = true;
        else
            pool->stratum_notify = ret = false;
        goto out_decref;
    }

    if (!strncasecmp(buf, "mining.set_difficulty", 21)) {
        ret = parse_diff(pool, params);
        goto out_decref;
    }

    if (!strncasecmp(buf, "client.reconnect", 16)) {
        ret = parse_reconnect(pool, params);
        goto out_decref;
    }

    if (!strncasecmp(buf, "client.get_version", 18)) {
        ret =  send_version(pool, val);
        goto out_decref;
    }

    if (!strncasecmp(buf, "client.show_message", 19)) {
        ret = show_message(pool, params);
        goto out_decref;
    }

    if (!strncasecmp(buf, "mining.ping", 11)) {
        applog(LOG_INFO, "Pool %d ping", pool->pool_no);
        ret = send_pong(pool, val);
        goto out_decref;
    }
out_decref:
    json_decref(val);
out:

#endif

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
