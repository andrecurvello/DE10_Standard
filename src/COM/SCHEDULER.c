/* *****************************************************************************
**
**                       Standalone bitcoin miner
**
** Project      : DE10 Standard project
** Module       : SCHEDULER
**
** Description  : Mining scheduler
**
** ************************************************************************** */

/* *****************************************************************************
**  REVISION HISTORY
** Date         Inits   Description
** ----------------------------------------------------------------------------
** 21.08.17     bd      [no issue number] File creation
**
** ************************************************************************** */

/* *****************************************************************************
**                          SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "Macros.h" /* Divers macros definitions */
#include "Types.h"  /* Legacy types definitions */

#include <endian.h> /* Endianess definitions */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "SCHEDULER.h" /* module definitions */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
typedef enum  {
    eSCHED_FAILOVER = 0,
    eSCHED_ROUNDROBIN,
    eSCHED_ROTATE,
    eSCHED_LOADBALANCE,
    eSCHED_BALANCE

} eSCHEDULER_Strgy_Type_t;

/* Maximum number of work */
#define WORK_QUEUE_SIZE (20)

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */
typedef struct{
    stSCHEDULER_Work_t astWorkQueue[WORK_QUEUE_SIZE];
    stSCHEDULER_Work_t *pstHead;
    stSCHEDULER_Work_t *pstTail;
    stSCHEDULER_Work_t *pstCurrent;

} stSCHEDULER_Data_t;

/* *****************************************************************************
**                                 GLOBALS
** ************************************************************************** */

/* *****************************************************************************
**                                 LOCALS
** ************************************************************************** */
static const byte *pbyPadding = "000000800000000000000000000000000000000000000000000000000000000000000000000000000000000080020000";
/* qwTrueDiffOne == 0x00000000FFFF0000000000000000000000000000000000000000000000000000
 * Generate a 256 bit binary LE target by cutting up difficulty into 64 bit sized
 * portions or vice versa. */
static const qword qwTrueDiffOne = 26959535291011309493156476344723991336010898738574164086137773096960.0;
static const qword qwBits192 = 6277101735386680763835789423207666416102355444464034512896.0;
static const qword qwBits128 = 340282366920938463463374607431768211456.0;
static const qword qwBits64 = 18446744073709551616.0;

static const word waHexToBin_TLB[256] =
{
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
     0,  1,  2,  3,  4,  5,  6,  7,  8,  9, -1, -1, -1, -1, -1, -1,
    -1, 10, 11, 12, 13, 14, 15, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, 10, 11, 12, 13, 14, 15, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
};

static stSCHEDULER_Data_t stLocalData;

/* *****************************************************************************
**                              LOCALS ROUTINES
** ************************************************************************** */
static qword LE256_to_Qword(const void *pvTarget);
static qword Difficulty_from_Taret(void *pvTarget);
static void SetTarget(byte * pstDest, qword qwDifficulty);
static boolean Hex_to_Bin(byte *pbyData, const byte *pbySrc, size_t stLength);
static void ResetData(void);

/* *****************************************************************************
**                                  API
** ************************************************************************** */
void SCHEDULER_Setup(void) /* Setup mudule, make sure we can use the FPGA */
{
    /* Reset data */
    ResetData();
    return;
}

void SCHEDULER_Init(void)     /* Reinit the work queue */
{
    return;
}

void SCHEDULER_Bkgnd(void)    /* queue and donkey work management */
{
    return;
}

void SCHEDULER_PopWork(void)  /* Schedule work and push to FPGA */
{
    return;
}
void SCHEDULER_PushWork(const stSCHEDULER_Work_t * const pstWork) /*  */
{
    return;
}

void SCHEDULER_SetStrategy(const eSCHEDULER_Strgy_Type_t eStrategy) /* Set scheduling method */
{
    return;
}

/* *****************************************************************************
**                                Local routines
** ************************************************************************** */
static qword Difficulty_from_Taret(void *pvTarget)
{
    qword dcut64;

    dcut64 = LE256_to_Qword(pvTarget);
    if (unlikely(!dcut64))
    {
        dcut64 = 1;
    }

    return (qwTrueDiffOne/dcut64);
}

/* Converts a little endian 256 bit value to a double */
static double LE256_to_Qword(const void *pvTarget)
{
    qword *data64;
    double dcut64;

    data64 = (qword *)(pvTarget + 24);
    dcut64 = le64toh(*data64) * qwBits192;

    data64 = (qword *)(pvTarget + 16);
    dcut64 += le64toh(*data64) * qwBits128;

    data64 = (qword *)(pvTarget + 8);
    dcut64 += le64toh(*data64) * qwBits64;

    data64 = (qword *)(pvTarget);
    dcut64 += le64toh(*data64);

    return dcut64;
}

static void SetTarget(byte * pstDest, qword qwDifficulty)
{
    unsigned char target[32];
    qword *data64, h64;
    double d64, dcut64;

    d64 = qwTrueDiffOne;
    d64 /= qwDifficulty;

    dcut64 = d64 / qwBits192;
    h64 = dcut64;
    data64 = (qword *)(target + 24);
    *data64 = htole64(h64);
    dcut64 = h64;
    dcut64 *= qwBits192;
    d64 -= dcut64;

    dcut64 = d64 / qwBits128;
    h64 = dcut64;
    data64 = (qword *)(target + 16);
    *data64 = htole64(h64);
    dcut64 = h64;
    dcut64 *= qwBits128;
    d64 -= dcut64;

    dcut64 = d64 / qwBits64;
    h64 = dcut64;
    data64 = (qword *)(target + 8);
    *data64 = htole64(h64);
    dcut64 = h64;
    dcut64 *= qwBits64;
    d64 -= dcut64;

    h64 = d64;
    data64 = (qword *)(target);
    *data64 = htole64(h64);

    return;
}

/* Does the reverse of bin2hex but does not allocate any ram */
static boolean Hex_to_Bin(byte *pbyData, const byte *pbySrc, size_t stLength)
{
    int nibble1, nibble2;
    unsigned char idx;
    bool bRetVal;

    /* Initialize locals */
    bRetVal = FALSE;

    while ( (*pbySrc) && stLength )
    {
        idx = *pbySrc++;
        nibble1 = waHexToBin_TLB[idx];
        idx = *pbySrc++;
        nibble2 = waHexToBin_TLB[idx];

        *pbyData++ = (((unsigned char)nibble1) << 4) | ((unsigned char)nibble2);
        stLength--;
    }

    if (   (stLength == 0 )
        && (*hexstr == 0)
       )
    {
        bRetVal = TRUE;
    }

    return ret;
}

#if 0
bool fulltest(const unsigned char *hash, const unsigned char *target)
{
    uint32_t *hash32 = (uint32_t *)hash;
    uint32_t *target32 = (uint32_t *)target;
    bool rc = true;
    int i;

    for (i = 28 / 4; i >= 0; i--) {
        uint32_t h32tmp = le32toh(hash32[i]);
        uint32_t t32tmp = le32toh(target32[i]);

        if (h32tmp > t32tmp) {
            rc = false;
            break;
        }
        if (h32tmp < t32tmp) {
            rc = true;
            break;
        }
    }

    if (opt_debug) {
        unsigned char hash_swap[32], target_swap[32];
        char *hash_str, *target_str;

        swab256(hash_swap, hash);
        swab256(target_swap, target);
        hash_str = bin2hex(hash_swap, 32);
        target_str = bin2hex(target_swap, 32);

        applog(LOG_DEBUG, " Proof: %s\nTarget: %s\nTrgVal? %s",
            hash_str,
            target_str,
            rc ? "YES (hash <= target)" :
                 "no (false positive; hash > target)");

        free(hash_str);
        free(target_str);
    }

    return rc;
}
#endif

static void ResetData(void)
{
    /* Reset local data */
    memset(&stLocalData,0x00,sizeof(stSCHEDULER_Data_t));
    return;
}
