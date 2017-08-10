struct stratum_work {
    char *job_id;
    unsigned char **merkle_bin;
    bool clean;

    double diff;
};

#define RBUFSIZE 8192
#define RECVSIZE (RBUFSIZE - 4)

struct pool {
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

    char *rpc_req;
    char *rpc_url;
    char *rpc_userpass;
    char *rpc_user, *rpc_pass;
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

    struct timeval tv_lastwork;
};

bool stratum_send(struct pool *pool, char *s, ssize_t len);
bool auth_stratum(struct pool *pool);
bool restart_stratum(struct pool *pool);
bool STRATUM_Ptcl_Init(struct pool *pool);
