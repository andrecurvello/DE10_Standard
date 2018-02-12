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
**                Here, We build up an associative structure that is used in
**                order to check the hashes correctness.
**
** ************************************************************************** */

/* *****************************************************************************
**  REVISION HISTORY
** Date         Inits   Description
** ----------------------------------------------------------------------------
** 08.08.17     bd      [no issue number] File creation
**
** ************************************************************************** */

/* *****************************************************************************
**                          SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "Macros.h" /* Divers macros definitions */
#include "Types.h"  /* Legacy types definitions */

#include <signal.h> /* signal handling */
#include <stdio.h>  /* standard IOs */
#include <stdlib.h> /* standard lib definitions */
#include <string.h> /* standard lib definitions */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "design.h"  /* Legacy types definitions */
#include "test_vectors.h" /*
                          ** i)  Parse and inject test vectors in the FPGA fabric
                          ** ii) Check results. Measure performances.
                          */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */
#define TEST_FILE_NAME "test.cfg" /* Name of the actual config file */
#define VECTOR_BYTE_FILE_TAG "NIST_TEST_VECTOR_BYTE_DB\n" /* Name of the actual config file */
#define VECTOR_BIT_FILE_TAG "NIST_TEST_VECTOR_BIT_DB\n" /* Name of the actual config file */
#define MAX_STR_LEN (256) /* Maximum length of a string in that particular module */
#define BLOCK_SIZE_BYTES (64) /* A 512bits SHA256 block size in bytes */
#define TEST_TABLE_LEN (512) /* A 56(byte vectors) + 448(bit vectors) test vectors have a length < 448 */
#define MAX_TEST_VECTOR_LEN (448) /* Maximum test vector length */

typedef enum
{
    eTEST_VECTOR_TYPE_BIT=0,
    eTEST_VECTOR_TYPE_BYTE

} eTEST_VECTORS_Type_st;

typedef struct
{
    word wLength;
    byte abyMsg[BLOCK_SIZE_BYTES];
    byte abyDigest[BLOCK_SIZE_BYTES];
    eTEST_VECTORS_Type_st eType;

}SHAVS_Test_Vector_st;

typedef struct
{
    SHAVS_Test_Vector_st stVector;
    byte abyCalcDigest[BLOCK_SIZE_BYTES];

}SHAVS_Test_Entry_st;

typedef struct
{
    FILE* pstCfg_File;
    byte abyCurLine[MAX_STR_LEN];
    byte abyVectByte_File_Name[MAX_STR_LEN];
    FILE* pstVectByte_File;
    byte abyVectBit_File_Name[MAX_STR_LEN];
    FILE* pstVectBit_File;

} TEST_Vectors_File_Hndl_st;

typedef struct
{
    TEST_Vectors_File_Hndl_st stHndl;

} TEST_Vectors_desc_st;

/* *****************************************************************************
**                                 GLOBALS
** ************************************************************************** */

/* *****************************************************************************
**                                 LOCALS
** ************************************************************************** */
static TEST_Vectors_desc_st pstLocalDesc;
static SHAVS_Test_Entry_st astTestTable[TEST_TABLE_LEN];

/* *****************************************************************************
**                              LOCALS ROUTINES
** ************************************************************************** */
static void ResetData(void); /* Reset modules private data */

static void PrepareVectors(void); /* Add padding, put the test vector in the FPGA
                                  ** interface compatible format
                                  */

static word GetLen(const byte* pbyData);  /* Return test entry message length */
static void GetData(byte* pbyDataDest, const byte* pbyDataSrc); /* Points to the Msg in the test entry */

/* *****************************************************************************
**                                  API
** ************************************************************************** */

/* Have to have and init to read the test vector files */
/* ************************************************************************** */
void TEST_VECTORS_Setup(void)
/* *****************************************************************************
** Input  : -
** Output : Pointer to next work structure.
** Return : -
**
** Description  : Read config. Setup of the persistent data. Get something clean that does the job well.
**                Copy that for the test vector files.
**
** ************************************************************************** */
{
    byte* pChar;

    /* Reset descriptor and other data structs */
    ResetData();

    /* Initialize modules private data */
    pstLocalDesc.stHndl.pstCfg_File = fopen(TEST_FILE_NAME, "r");

    if (NULL != pstLocalDesc.stHndl.pstCfg_File)
    {
        while(    ( 0 == feof(pstLocalDesc.stHndl.pstCfg_File) )
               && (   ( NULL == pstLocalDesc.stHndl.pstVectBit_File )
                   || ( NULL == pstLocalDesc.stHndl.pstVectByte_File )
                  )
             )
        {
            fgets((char*)pstLocalDesc.stHndl.abyCurLine, MAX_STR_LEN, pstLocalDesc.stHndl.pstCfg_File);

            if( 0 == strcmp(VECTOR_BIT_FILE_TAG,(char*)pstLocalDesc.stHndl.abyCurLine) )
            {
                fgets((char*)pstLocalDesc.stHndl.abyVectBit_File_Name, MAX_STR_LEN, pstLocalDesc.stHndl.pstCfg_File);
            }

            /*  */
            if( 0 == strcmp(VECTOR_BYTE_FILE_TAG,(char*)pstLocalDesc.stHndl.abyCurLine) )
            {
                fgets((char*)pstLocalDesc.stHndl.abyVectByte_File_Name, MAX_STR_LEN, pstLocalDesc.stHndl.pstCfg_File);
            }
        }

        /* See if there are no eol interference */
        pChar = strchr( pstLocalDesc.stHndl.abyVectByte_File_Name, '\n' );
        if( NULL != pChar )
        {
            *pChar = 0;
        }

        pChar = strchr( pstLocalDesc.stHndl.abyVectBit_File_Name, '\n' );
        if( NULL != pChar )
        {
            *pChar = 0;
        }

        /* Reached end of file, close descriptor */
        fclose(pstLocalDesc.stHndl.pstCfg_File);
    }

    return;
}

/* ************************************************************************** */
void TEST_VECTORS_Init(void)
/* *****************************************************************************
** Input  : -
** Output : -
** Return : -
**
** Description  : Now that the test configuration has been read. Fill up the test table
**
** ************************************************************************** */
{
    word wIndex;

    /* Initialize module's private data */
    pstLocalDesc.stHndl.pstVectBit_File = fopen((const char*)pstLocalDesc.stHndl.abyVectBit_File_Name, "r");
    pstLocalDesc.stHndl.pstVectByte_File = fopen((const char*)pstLocalDesc.stHndl.abyVectByte_File_Name, "r");
    wIndex = 0;

    printf("\n");

    if (NULL != pstLocalDesc.stHndl.pstVectBit_File)
    {
        while( 0 == feof(pstLocalDesc.stHndl.pstVectBit_File) )
        {
            fgets((char*)pstLocalDesc.stHndl.abyCurLine, MAX_STR_LEN, pstLocalDesc.stHndl.pstVectBit_File);

            /* New entry ? Check if "Len" is present */
            if( 0 == strncmp("Len",(char*)pstLocalDesc.stHndl.abyCurLine,(size_t)strlen("Len") ) )
            {
                astTestTable[wIndex].stVector.eType = eTEST_VECTOR_TYPE_BIT;
                astTestTable[wIndex].stVector.wLength = GetLen((const byte*)pstLocalDesc.stHndl.abyCurLine);

                fgets((char*)pstLocalDesc.stHndl.abyCurLine, MAX_STR_LEN, pstLocalDesc.stHndl.pstVectBit_File);
                GetData(astTestTable[wIndex].stVector.abyMsg, (const byte*)pstLocalDesc.stHndl.abyCurLine);

                fgets((char*)pstLocalDesc.stHndl.abyCurLine, MAX_STR_LEN, pstLocalDesc.stHndl.pstVectBit_File);
                GetData(astTestTable[wIndex].stVector.abyDigest, (const byte*)pstLocalDesc.stHndl.abyCurLine);

                /* Check test entry sanity */
                if( TEST_TABLE_LEN > wIndex )
                {
                    /* Check test entry sanity */
                    if(    (MAX_TEST_VECTOR_LEN >= astTestTable[wIndex].stVector.wLength)
                        && (NULL != astTestTable[wIndex].stVector.abyMsg)
                        && (NULL != astTestTable[wIndex].stVector.abyDigest)
                      )
                    {
                        printf("\n");
                        printf("Length  : %d\n",astTestTable[wIndex].stVector.wLength);
                        printf("Message : %s\n",astTestTable[wIndex].stVector.abyMsg);
                        printf("Digest  : %s\n",astTestTable[wIndex].stVector.abyDigest);
                        /* Valid - Point to next entry in the table */
                        wIndex++;
                    }
                }
                else
                {
                    /* We've scooped all the test vectors we could grab in that file */
                    break;
                }
            }
        }

        /* Reached end of file, close descriptor */
        fclose(pstLocalDesc.stHndl.pstVectBit_File);
    }

    if (NULL != pstLocalDesc.stHndl.pstVectByte_File)
    {
        while( 0 == feof(pstLocalDesc.stHndl.pstVectByte_File) )
        {
            fgets((char*)pstLocalDesc.stHndl.abyCurLine, MAX_STR_LEN, pstLocalDesc.stHndl.pstVectByte_File);

            /* New entry ? Check if "Len" is present */
            if( 0 == strncmp("Len",(char*)pstLocalDesc.stHndl.abyCurLine,(size_t)strlen("Len") ) )
            {
                astTestTable[wIndex].stVector.eType = eTEST_VECTOR_TYPE_BYTE;
                astTestTable[wIndex].stVector.wLength = GetLen((const byte*)pstLocalDesc.stHndl.abyCurLine);

                fgets((char*)pstLocalDesc.stHndl.abyCurLine, MAX_STR_LEN, pstLocalDesc.stHndl.pstVectByte_File);
                GetData(astTestTable[wIndex].stVector.abyMsg, (const byte*)pstLocalDesc.stHndl.abyCurLine);

                fgets((char*)pstLocalDesc.stHndl.abyCurLine, MAX_STR_LEN, pstLocalDesc.stHndl.pstVectByte_File);
                GetData(astTestTable[wIndex].stVector.abyDigest, (const byte*)pstLocalDesc.stHndl.abyCurLine);

                /* Check test entry sanity */
                if( TEST_TABLE_LEN > wIndex )
                {
                    /* Check test entry sanity */
                    if(    (MAX_TEST_VECTOR_LEN >= astTestTable[wIndex].stVector.wLength)
                        && (NULL != astTestTable[wIndex].stVector.abyMsg)
                        && (NULL != astTestTable[wIndex].stVector.abyDigest)
                      )
                    {
                        printf("\n");
                        printf("Length  : %d\n",astTestTable[wIndex].stVector.wLength);
                        printf("Message : %s\n",astTestTable[wIndex].stVector.abyMsg);
                        printf("Digest  : %s\n",astTestTable[wIndex].stVector.abyDigest);
                        /* Valid - Point to next entry in the table */
                        wIndex++;
                    }
                }
                else
                {
                    /* We've scooped all the test vectors we could grab in that file */
                    break;
                }
            }
        }

        /* Reached end of file, close descriptor */
        fclose(pstLocalDesc.stHndl.pstVectByte_File);
    }

    printf("Number of entries : %d \n",wIndex);

    /*
    ** The test table is now fill up, next step consist in make sure the format
    ** is compatible with the FPGA interface.
    */
    PrepareVectors();

    /* Give hand to the background task ... */

    return;
}

/* *****************************************************************************
**                            LOCALS ROUTINES Defn
** ************************************************************************** */
static void ResetData(void)
{
    memset(&pstLocalDesc,0x00,sizeof(TEST_Vectors_desc_st));
    memset(astTestTable,0x00,mArraySize(astTestTable));

    return;
}

/* ************************************************************************** */
static word GetLen(const byte * pbyData)
/* *****************************************************************************
** Input  : -
** Output : -
** Return : -
**
** Description  : Given a message add the necessary padding.
**
** ************************************************************************** */
{
    word wLength;
    byte *pString;

    /* Initialize locals */
    wLength = 0;
    pString = NULL;

    if( NULL != pbyData )
    {
       pString = (byte*)strchr(((char*)pbyData),'=');
       if( NULL != pString)
       {
           /* skip = and space */
           pString += 2;

           /* Now pointing to length in string. Get it in decimal now */
           wLength = atoi((const char*)pString);
       }
       else
       {
           /* Something is wrong with that entry, wrong format */
           /* Nothing to do for the time being */
       }
    }

    return wLength;
}

/* ************************************************************************** */
static void GetData(byte * pbyDataDest, const byte * pbyDataSrc)
/* *****************************************************************************
** Input  : -
** Output : -
** Return : -
**
** Description  : Given a test vector entry extract the Msg part.
**
** ************************************************************************** */
{
    byte *pChar;
    byte *pCrLf;

    /* Initialise locals */
    pChar = NULL;

    if(   ( NULL != pbyDataSrc )
       && ( NULL != pbyDataDest )
      )
    {
        pChar = (byte*)strchr(((char*)pbyDataSrc),'=');
        if( NULL != pChar)
        {
            /* skip = and space */
            pChar += 2;

            /* Get rid of EOL pollution */
            pCrLf = strchr( pChar, '\n' );
            if( NULL != pCrLf )
            {
                *pCrLf = 0;
            }

            /* Now pointing to Msg string. just exit */
            strcpy(pbyDataDest,pChar);
        }
    }

    return;
}

/* ************************************************************************** */
static void PrepareVectors(void)
/* *****************************************************************************
** Input  : -
** Output : -
** Return : -
**
** Description  : Given a message add the necessary padding.
**
** ************************************************************************** */
{

    return;
}
