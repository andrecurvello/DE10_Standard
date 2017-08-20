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

typedef struct
{
    byte * abyUser;
    byte * abyPass;
    word wWorkId;

} stJSON_Auth_Demand_t;

/*
** Subscriptions details - 2-tuple with name of subscribed notification and subscription ID.
**                         Theoretically it may be used for unsubscribing. Not used/implemented here
** Extranonce1           - Hex-encoded, per-connection unique string which will be used for coinbase serialization later.
** Extranonce2_size      - Represents expected length of extranonce2 which will be generated by the miner.
**
*/
typedef struct
{
    byte *abyNonce1;
    word wN2size;

} stJSON_Connect_Result_t;

/*
** job_id        - ID of the job. Use this ID while submitting share generated from this job.
** prevhash      - Hash of previous block.
** coinb1        - Initial part of coinbase transaction.
** coinb2        - Final part of coinbase transaction.
** merkle_branch - List of hashes, will be used for calculation of merkle root.
**                 This is not a list of all transactions, it only contains prepared
**                 hashes of steps of merkle tree algorithm. Please read some materials
**                 for understanding how merkle trees calculation works.
**                 Unfortunately this example don't have any step hashes included
** version       - Bitcoin block version.
** nbits         - Encoded current network difficulty
** ntime         - Current ntime
** clean_jobs    - When true, server indicates that submitting shares from previous
**                 jobs don't have a sense and such shares will be rejected.
**                 When this flag is set, miner should also drop all previous jobs,
**                 so job_ids can be eventually rotated.
*/
typedef struct
{
    byte *abyJobId;
    byte *abyPrevHash;
    byte *abyCoinBase1;
    byte *abyCoinBase2;
    byte *abyMerkleBranch;
    byte *abyBlckVer;
    byte *abyNbits;
    byte *abyNtime;
    boolean bCleanJobs;

} stJSON_Job_Result_t;

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */

/* *****************************************************************************
**                                  API
** ************************************************************************** */
eJSON_Status_t JSON_Ser_ReqConnect(const word wWorkId, byte * const pbyRequest);
eJSON_Status_t JSON_Deser_ResConnect( stJSON_Connect_Result_t * const pstResult, byte * const pbyResponse);

eJSON_Status_t JSON_Ser_ReqAuth(const stJSON_Auth_Demand_t * const pstDemand, byte * const pbyRequest);
eJSON_Status_t JSON_Deser_ResAuth(byte * const pbyResponse); /* If return is successfull. Authentication has worked. */

eJSON_Status_t JSON_Deser_ResJob(stJSON_Job_Result_t * const pstResult,byte * const pbyResponse);

eJSON_Status_t JSON_Deser_ResDifficulty(byte * const pbyResponse);

eJSON_Status_t JSON_Ser_ReqShare(byte * const pbyResponse);

#endif