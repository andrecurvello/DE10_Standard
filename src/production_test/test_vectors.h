/* *****************************************************************************
**
**                       DE10 Standard project
**
** Project      : DE10 standard project miner
** Module       : test_vectors
**
** Description  : The purpose of production test is to make sure everything work
**                as it should. The typical test vectors are 448 bits max.
**                It consist in parsing the official SHA256 test vectors from
**                NIST specs and check that the result is matching.
**                If that is the case, the test is considered successful.
**
** ************************************************************************** */
#ifndef TEST_VECTORS_H
#define TEST_VECTORS_H

/* *****************************************************************************
**  REVISION HISTORY
** Date         Inits   Description
** ----------------------------------------------------------------------------
** 10.01.18     bd      [no issue number] File creation
**
** ************************************************************************** */

/* *****************************************************************************
**                          SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "Macros.h" /* Divers macros definitions */
#include "Types.h"  /* Legacy types definitions */

#include <signal.h> /* signal handling */
#include <stdio.h>  /* standard IOs */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
typedef enum
{
    eTEST_VECTORS_SUCCESS=0,
    eTEST_VECTORS_FAILED,
    eTEST_VECTORS_TIMEOUT

} eTEST_VECTORS_Status_st;

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
/* Have to have and init to read the test vector files */
void TEST_VECTORS_Setup(void); /* Get the test config env */
void TEST_VECTORS_Init(void); /* Init internal data structures */

/* Need some kind of interface to the FPGA */

/* Inject/stage work to FPGA */ /* ------> tricky */

/* Get the results */ /* ------> tricky */

/* Compare, check result coherency and so on ... */
void TEST_VECTORS_Bckgnd(void); /* All the above forthe time being */

#endif
