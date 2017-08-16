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

#if 0 /* Not needed for the time being */
#include <jansson.h>  /* JSON serialization */
#endif

#include <stdio.h>    /* Standard IO defns */
#include <stdlib.h>   /* Standard lib C defns */
#include <string.h>   /* String defns */
#include <stdint.h>   /* Integer defns */
#include <unistd.h>   /* Types defns */
#include <sys/time.h> /* Time defns */
#include <time.h>     /* More time defns */
#include <math.h>     /* Math defns for stats */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "JSON.h" /* module definitions */

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
byte* JSON_Ser_PoolConnect(void)
{
#if 0
    /* Formulate request to stratum server */
    sprintf((char*)astSTRATUM_Pools[dwIndex].abyTxBuf, "{\"id\": %d, \"method\": \"mining.subscribe\", \"params\": []}", swork_id++);

    /* Important ! */
    strcat((char*)astSTRATUM_Pools[dwIndex].abyTxBuf, "\n");
#endif

    return NULL;
}

byte* JSON_Deser_PoolConnect(void)
{
#if 0
    val = JSON_LOADS(sret, &err);
    free(sret);
    if (!val) {
        applog(LOG_INFO, "JSON decode failed(%d): %s", err.line, err.text);
        goto out;
    }

    res_val = json_object_get(val, "result");
    err_val = json_object_get(val, "error");

    if (!res_val || json_is_null(res_val) ||
        (err_val && !json_is_null(err_val))) {
        char *ss;

        if (err_val)
            ss = json_dumps(err_val, JSON_INDENT(3));
        else
            ss = strdup("(unknown reason)");

        applog(LOG_INFO, "JSON-RPC decode failed: %s", ss);

        free(ss);

        goto out;
    }

    sessionid = get_sessionid(res_val);
    if (!sessionid)
        applog(LOG_DEBUG, "Failed to get sessionid in initiate_stratum");
    nonce1 = json_array_string(res_val, 1);
    if (!valid_hex(nonce1)) {
        applog(LOG_INFO, "Failed to get valid nonce1 in initiate_stratum");
        free(sessionid);
        free(nonce1);
        goto out;
    }
    n2size = json_integer_value(json_array_get(res_val, 2));
    if (n2size < 2 || n2size > 16) {
        applog(LOG_INFO, "Failed to get valid n2size in initiate_stratum");
        free(sessionid);
        free(nonce1);
        goto out;
    }
#endif

    return NULL;
}

byte* JSON_Ser_PoolAuth(void)
{
#if 0
    sprintf(s, "{\"id\": %d, \"method\": \"mining.authorize\", \"params\": [\"%s\", \"%s\"]}",
        swork_id++, pool->rpc_user, pool->rpc_pass);
#endif

    return NULL;
}

byte* JSON_Deser_PoolAuth(void)
{
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

    return NULL;
}

byte* JSON_Deser_PoolJob(void)
{
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

    return NULL;
}

byte* JSON_Deser_PoolDifficulty(void)
{
    /* Nothing to do for the time being */
    return NULL;
}

byte* JSON_Ser_PoolShare(void)
{
    /* Nothing to do for the time being */
    return NULL;
}

/* *****************************************************************************
**                            LOCALS ROUTINES Defn
** ************************************************************************** */
