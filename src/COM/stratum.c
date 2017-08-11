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

#include <jansson.h> /* JSON serialization */

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
#include "stratum.h" /* module definitions */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
#define RBUFSIZE 8192
#define RECVSIZE (RBUFSIZE - 4)

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */
typedef struct  {
    byte *pbyJobId;
    byte **pabyMerkleBin;
    boolean bClean;
    dword dwDiff;

} STRATUM_work_t;

typedef struct {
#if 0
    int pool_no;
    int prio;
    int64_t accepted, rejected;
    int seq_rejects;
    int seq_getfails;
    int solved;
    int64_t diff1;
    char diff[8];
    int quota;
    int quota_gcd;
    int quota_used;
    int works;

    double diff_accepted;
    double diff_rejected;
    double diff_stale;

    bool submit_fail;
    bool idle;
    bool probed;
    enum pool_enable enabled;
    bool submit_old;
    bool removed;
    bool lp_started;
    bool blocking;

    char *hdr_path;
    char *lp_url;

    unsigned int getwork_requested;
    unsigned int stale_shares;
    unsigned int discarded_work;
    unsigned int getfail_occasions;
    unsigned int remotefail_occasions;
    struct timeval tv_idle;

    double utility;
    int last_shares, shares;

    proxytypes_t rpc_proxytype;
    char *rpc_proxy;

    pthread_mutex_t pool_lock;
    cglock_t data_lock;

    struct thread_q *submit_q;
    struct thread_q *getwork_q;

    pthread_t longpoll_thread;
    pthread_t test_thread;
    bool testing;

    int curls;
    pthread_cond_t cr_cond;
    struct list_head curlring;

    time_t last_share_time;
    double last_share_diff;
    uint64_t best_diff;
    uint64_t bad_work;

    struct cgminer_stats cgminer_stats;
    struct cgminer_pool_stats cgminer_pool_stats;

    /* The last block this particular pool knows about */
    char prev_block[32];

    /* Stratum variables */
    char *stratum_url;
    char *stratum_port;
    SOCKETTYPE sock;
    char *sockbuf;
    size_t sockbuf_size;
    char *sockaddr_url; /* stripped url used for sockaddr */
    char *sockaddr_proxy_url;
    char *sockaddr_proxy_port;

    char *nonce1;
    unsigned char *nonce1bin;
    uint64_t nonce2;
    int n2size;
    char *sessionid;
    bool has_stratum;
    bool stratum_active;
    bool stratum_init;
    bool stratum_notify;
    struct stratum_work swork;
    pthread_t stratum_sthread;
    pthread_t stratum_rthread;
    pthread_mutex_t stratum_lock;
    struct thread_q *stratum_q;
    int sshares; /* stratum shares submitted waiting on response */

    /* GBT  variables */
    bool has_gbt;
    cglock_t gbt_lock;
    unsigned char previousblockhash[32];
    unsigned char gbt_target[32];
    char *coinbasetxn;
    char *longpollid;
    char *gbt_workid;
    int gbt_expires;
    uint32_t gbt_version;
    uint32_t curtime;
    uint32_t gbt_bits;
    unsigned char *txn_hashes;
    int gbt_txns;
    int height;

    bool gbt_solo;
    unsigned char merklebin[16 * 32];
    int transactions;
    char *txn_data;
    unsigned char scriptsig_base[100];
    unsigned char script_pubkey[25 + 3];
    int nValue;
    CURL *gbt_curl;
    bool gbt_curl_inuse;

    /* Shared by both stratum & GBT */
    size_t n1_len;
    unsigned char *coinbase;
    int coinbase_len;
    int nonce2_offset;
    unsigned char header_bin[128];
    int merkles;
    char prev_hash[68];
    char bbversion[12];
    char nbit[12];
    char ntime[12];
    double next_diff;
    double diff_after;
    double sdiff;
    uint32_t current_height;

#endif
    struct timeval stTimeLastwork;
    byte *abyJsonReq;
    byte *abyJsonUrl;
    byte *abyJsonUserPass;
    byte *abyJsonUserUser;
    byte *abyJsonPass;

} STRATUM_Pool_t;

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

#if 0
bool stratum_send(struct pool *pool, char *s, ssize_t len)
{
    enum send_ret ret = SEND_INACTIVE;

    if (opt_protocol)
        applog(LOG_DEBUG, "SEND: %s", s);

    mutex_lock(&pool->stratum_lock);
    if (pool->stratum_active)
        ret = __stratum_send(pool, s, len);
    mutex_unlock(&pool->stratum_lock);

    /* This is to avoid doing applog under stratum_lock */
    switch (ret) {
        default:
        case SEND_OK:
            break;
        case SEND_SELECTFAIL:
            applog(LOG_DEBUG, "Write select failed on pool %d sock", pool->pool_no);
            suspend_stratum(pool);
            break;
        case SEND_SENDFAIL:
            applog(LOG_DEBUG, "Failed to send in stratum_send");
            suspend_stratum(pool);
            break;
        case SEND_INACTIVE:
            applog(LOG_DEBUG, "Stratum send failed due to no pool stratum_active");
            break;
    }
    return (ret == SEND_OK);
}

bool auth_stratum(struct pool *pool)
{
    json_t *val = NULL, *res_val, *err_val;
    char s[RBUFSIZE], *sret = NULL;
    json_error_t err;
    bool ret = false;

    sprintf(s, "{\"id\": %d, \"method\": \"mining.authorize\", \"params\": [\"%s\", \"%s\"]}",
        swork_id++, pool->rpc_user, pool->rpc_pass);

    if (!stratum_send(pool, s, strlen(s)))
        return ret;

    /* Parse all data in the queue and anything left should be auth */
    while (42) {
        sret = recv_line(pool);
        if (!sret)
            return ret;
        if (parse_method(pool, sret))
            free(sret);
        else
            break;
    }

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
out:
    json_decref(val);
    return ret;
}

static bool setup_stratum_socket(struct pool *pool)
{
    struct addrinfo *servinfo, hints, *p;
    char *sockaddr_url, *sockaddr_port;
    int sockd;

    mutex_lock(&pool->stratum_lock);
    pool->stratum_active = false;
    if (pool->sock)
        CLOSESOCKET(pool->sock);
    pool->sock = 0;
    mutex_unlock(&pool->stratum_lock);

    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;

    if (!pool->rpc_proxy && opt_socks_proxy) {
        pool->rpc_proxy = opt_socks_proxy;
        extract_sockaddr(pool->rpc_proxy, &pool->sockaddr_proxy_url, &pool->sockaddr_proxy_port);
        pool->rpc_proxytype = PROXY_SOCKS5;
    }

    if (pool->rpc_proxy) {
        sockaddr_url = pool->sockaddr_proxy_url;
        sockaddr_port = pool->sockaddr_proxy_port;
    } else {
        sockaddr_url = pool->sockaddr_url;
        sockaddr_port = pool->stratum_port;
    }
    if (getaddrinfo(sockaddr_url, sockaddr_port, &hints, &servinfo) != 0) {
        if (!pool->probed) {
            applog(LOG_WARNING, "Failed to resolve (?wrong URL) %s:%s",
                   sockaddr_url, sockaddr_port);
            pool->probed = true;
        } else {
            applog(LOG_INFO, "Failed to getaddrinfo for %s:%s",
                   sockaddr_url, sockaddr_port);
        }
        return false;
    }

    for (p = servinfo; p != NULL; p = p->ai_next) {
        sockd = socket(p->ai_family, p->ai_socktype, p->ai_protocol);
        if (sockd == -1) {
            applog(LOG_DEBUG, "Failed socket");
            continue;
        }

        /* Iterate non blocking over entries returned by getaddrinfo
         * to cope with round robin DNS entries, finding the first one
         * we can connect to quickly. */
        noblock_socket(sockd);
        if (connect(sockd, p->ai_addr, p->ai_addrlen) == -1) {
            struct timeval tv_timeout = {1, 0};
            int selret;
            fd_set rw;

            if (!sock_connecting()) {
                CLOSESOCKET(sockd);
                applog(LOG_DEBUG, "Failed sock connect");
                continue;
            }
retry:
            FD_ZERO(&rw);
            FD_SET(sockd, &rw);
            selret = select(sockd + 1, NULL, &rw, NULL, &tv_timeout);
            if  (selret > 0 && FD_ISSET(sockd, &rw)) {
                socklen_t len;
                int err, n;

                len = sizeof(err);
                n = getsockopt(sockd, SOL_SOCKET, SO_ERROR, (void *)&err, &len);
                if (!n && !err) {
                    applog(LOG_DEBUG, "Succeeded delayed connect");
                    block_socket(sockd);
                    break;
                }
            }
            if (selret < 0 && interrupted())
                goto retry;
            CLOSESOCKET(sockd);
            applog(LOG_DEBUG, "Select timeout/failed connect");
            continue;
        }
        applog(LOG_WARNING, "Succeeded immediate connect");
        block_socket(sockd);

        break;
    }
    if (p == NULL) {
        applog(LOG_INFO, "Failed to connect to stratum on %s:%s",
               sockaddr_url, sockaddr_port);
        freeaddrinfo(servinfo);
        return false;
    }
    freeaddrinfo(servinfo);

    if (pool->rpc_proxy) {
        switch (pool->rpc_proxytype) {
            case PROXY_HTTP_1_0:
                if (!http_negotiate(pool, sockd, true))
                    return false;
                break;
            case PROXY_HTTP:
                if (!http_negotiate(pool, sockd, false))
                    return false;
                break;
            case PROXY_SOCKS5:
            case PROXY_SOCKS5H:
                if (!socks5_negotiate(pool, sockd))
                    return false;
                break;
            case PROXY_SOCKS4:
                if (!socks4_negotiate(pool, sockd, false))
                    return false;
                break;
            case PROXY_SOCKS4A:
                if (!socks4_negotiate(pool, sockd, true))
                    return false;
                break;
            default:
                applog(LOG_WARNING, "Unsupported proxy type for %s:%s",
                       pool->sockaddr_proxy_url, pool->sockaddr_proxy_port);
                return false;
                break;
        }
    }

    if (!pool->sockbuf) {
        pool->sockbuf = cgcalloc(RBUFSIZE, 1);
        pool->sockbuf_size = RBUFSIZE;
    }

    pool->sock = sockd;
    keep_sockalive(sockd);
    return true;
}

bool restart_stratum(struct pool *pool)
{
    bool ret = false;

    if (pool->stratum_active)
        suspend_stratum(pool);
    if (!initiate_stratum(pool))
        goto out;
    if (!auth_stratum(pool))
        goto out;
    ret = true;
out:
    if (!ret)
        pool_died(pool);
    else
        stratum_resumed(pool);
    return ret;
}

bool initiate_stratum(struct pool *pool)
{
    bool ret = false, recvd = false, noresume = false, sockd = false;
    char s[RBUFSIZE], *sret = NULL, *nonce1, *sessionid, *tmp;
    json_t *val = NULL, *res_val, *err_val;
    json_error_t err;
    int n2size;

resend:
    if (!setup_stratum_socket(pool)) {
        sockd = false;
        goto out;
    }

    sockd = true;

    if (recvd) {
        /* Get rid of any crap lying around if we're resending */
        clear_sock(pool);
        sprintf(s, "{\"id\": %d, \"method\": \"mining.subscribe\", \"params\": []}", swork_id++);
    } else {
        if (pool->sessionid)
            sprintf(s, "{\"id\": %d, \"method\": \"mining.subscribe\", \"params\": [\""PACKAGE"/"VERSION""STRATUM_USER_AGENT"\", \"%s\"]}", swork_id++, pool->sessionid);
        else
            sprintf(s, "{\"id\": %d, \"method\": \"mining.subscribe\", \"params\": [\""PACKAGE"/"VERSION""STRATUM_USER_AGENT"\"]}", swork_id++);
    }

    if (__stratum_send(pool, s, strlen(s)) != SEND_OK) {
        applog(LOG_DEBUG, "Failed to send s in initiate_stratum");
        goto out;
    }

    if (!socket_full(pool, DEFAULT_SOCKWAIT)) {
        applog(LOG_DEBUG, "Timed out waiting for response in initiate_stratum");
        goto out;
    }

    sret = recv_line(pool);
    if (!sret)
        goto out;

    recvd = true;

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

    if (sessionid && pool->sessionid && !strcmp(sessionid, pool->sessionid)) {
        applog(LOG_NOTICE, "Pool %d successfully negotiated resume with the same session ID",
               pool->pool_no);
    }

    cg_wlock(&pool->data_lock);
    tmp = pool->sessionid;
    pool->sessionid = sessionid;
    free(tmp);
    tmp = pool->nonce1;
    pool->nonce1 = nonce1;
    free(tmp);
    pool->n1_len = strlen(nonce1) / 2;
    free(pool->nonce1bin);
    pool->nonce1bin = cgcalloc(pool->n1_len, 1);
    hex2bin(pool->nonce1bin, pool->nonce1, pool->n1_len);
    pool->n2size = n2size;
    cg_wunlock(&pool->data_lock);

    if (sessionid)
        applog(LOG_DEBUG, "Pool %d stratum session id: %s", pool->pool_no, pool->sessionid);

    ret = true;
out:
    if (ret) {
        if (!pool->stratum_url)
            pool->stratum_url = pool->sockaddr_url;
        pool->stratum_active = true;
        pool->next_diff = pool->diff_after = 0;
        pool->sdiff = 1;
        if (opt_protocol) {
            applog(LOG_DEBUG, "Pool %d confirmed mining.subscribe with extranonce1 %s extran2size %d",
                   pool->pool_no, pool->nonce1, pool->n2size);
        }
    } else {
        if (recvd && !noresume) {
            /* Reset the sessionid used for stratum resuming in case the pool
            * does not support it, or does not know how to respond to the
            * presence of the sessionid parameter. */
            cg_wlock(&pool->data_lock);
            free(pool->sessionid);
            free(pool->nonce1);
            pool->sessionid = pool->nonce1 = NULL;
            cg_wunlock(&pool->data_lock);

            applog(LOG_DEBUG, "Failed to resume stratum, trying afresh");
            noresume = true;
            json_decref(val);
            goto resend;
        }
        applog(LOG_DEBUG, "Initiate stratum failed");
        if (sockd)
            suspend_stratum(pool);
    }

    json_decref(val);
    return ret;
}
#endif
