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
    return NULL;
}

byte* JSON_Deser_PoolConnect(void)
{
    return NULL;
}

byte* JSON_Ser_PoolAuth(void)
{
    return NULL;
}

byte* JSON_Deser_PoolAuth(void)
{
    return NULL;
}

byte* JSON_Deser_PoolJob(void)
{
    return NULL;
}

byte* JSON_Deser_PoolDifficulty(void)
{
    return NULL;
}

byte* JSON_Ser_PoolShare(void)
{
    return NULL;
}

/* *****************************************************************************
**                            LOCALS ROUTINES Defn
** ************************************************************************** */
