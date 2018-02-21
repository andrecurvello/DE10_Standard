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
#include "hex.h"     /* hex string manipulations */
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
#define BLOCK_SIZE_BITS (512) /* A 512bits SHA256 block size in bytes */
#define PADDING_SIZE_BYTES (8) /* 64bits padding block */
#define TEST_TABLE_LEN (512) /* A 56(byte vectors) + 448(bit vectors) test vectors have a length < 448 */
#define MAX_TEST_VECTOR_LEN (448) /* Maximum test vector length */

typedef enum
{
    eTEST_VECTOR_TYPE_BIT=0,
    eTEST_VECTOR_TYPE_BYTE

} eTEST_VECTORS_Type_st;

typedef struct
{
    eTEST_VECTORS_Type_st eType;
    word wLength;
    byte abyMsg[BLOCK_SIZE_BYTES];
    byte abyDigest[BLOCK_SIZE_BYTES];

}SHAVS_Test_Vector_st;

typedef struct
{
    SHAVS_Test_Vector_st stVector;
    byte abyMsgHex[BLOCK_SIZE_BYTES];
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
    byte abyWorkingBlock[BLOCK_SIZE_BYTES];

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

/* stdout output of a block */
static void DisplayBlock(const byte * pbyBlock);

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
        pChar = (byte*)strchr( (char*)pstLocalDesc.stHndl.abyVectByte_File_Name, '\n' );
        if( NULL != pChar )
        {
            *pChar = 0;
        }

        pChar = (byte*)strchr( (char*)pstLocalDesc.stHndl.abyVectBit_File_Name, '\n' );
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

    /*
    ** The test table is now full, next step consist in making sure the format
    ** is compatible with the FPGA interface.
    */
    PrepareVectors();

    /* Give hand to the background task ... */

    return;
}


/* ************************************************************************** */
void TEST_VECTORS_Bckgnd(void)
/* *****************************************************************************
** Input  : -
** Output : -
** Return : -
**
** Description  : Background task
**
** ************************************************************************** */
{
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
            pCrLf = (byte*)strchr( (char*)pChar, '\n' );
            if( NULL != pCrLf )
            {
                *pCrLf = 0;
            }

            /* Now pointing to Msg string. just exit */
            strcpy((char*)pbyDataDest,(char*)pChar);
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
** Description  : Work on the the table entries and make them FPGA-compatible.
**                That means that the message and padding have to be in right format.
**                See NIST FIPS PUB 180-4 for more details.
**
** ************************************************************************** */
{
    word wIdx;
    byte* pbyEndOfBlock;
    qword* pqwPaddingBlock;

    /* Prepare working data */
    memset(pstLocalDesc.abyWorkingBlock,0x00,BLOCK_SIZE_BYTES);

    /* Loop through  */
    for( wIdx = 0; wIdx < TEST_TABLE_LEN ; wIdx++ )
    {
        /* At the moment we just consider the byte vectors */
        if( eTEST_VECTOR_TYPE_BYTE == astTestTable[wIdx].stVector.eType )
        {
            /* The work will be base on the work data */
            memset(astTestTable[wIdx].abyMsgHex,0x00,BLOCK_SIZE_BYTES);

            /* Base read format is the following  */
            /* [ A , B , C , D] -> [ D , C   , B , A ] where A,B,C,D are 32 bits word + Need to add some padding */
            printf( "[%s] Size : %d\n",__func__,astTestTable[wIdx].stVector.wLength);
            printf( "[%s] Msg : %s\n",__func__,astTestTable[wIdx].stVector.abyMsg);

            StringToHex(pstLocalDesc.abyWorkingBlock,astTestTable[wIdx].stVector.abyMsg,BLOCK_SIZE_BYTES);

            /*  Padding information
            Suppose that the length of the message, M, is l bits. Append the bit “1” to the end of the
            message, followed by k zero bits, where k is the smallest, non-negative solution to the equation
            l + 1 + k = 448mod512 . Then append the 64-bit block that is equal to the number l expressed
            using a binary representation. For example, the (8-bit ASCII) message “abc” has length
            8*3=24, so the message is padded with a one bit, then 448 - (24 + 1) = 423 zero bits, and then
            the message length, to become the 512-bit padded message

               a        b        c     |   423 0s     last 64bits block
            01100001 01100010 01100011 1 0000…0000    00000000000…011000
                                                              l=24

            The length of the padded message should now be a multiple of 512 bits.
            */

            /* Point to byte after the last message byte */
            pbyEndOfBlock=&pstLocalDesc.abyWorkingBlock[(astTestTable[wIdx].stVector.wLength/8)];
            *pbyEndOfBlock=0x80;

            /* Now add the padding */
            pqwPaddingBlock = (qword*)&pstLocalDesc.abyWorkingBlock[(BLOCK_SIZE_BYTES-PADDING_SIZE_BYTES)];
            *pqwPaddingBlock = astTestTable[wIdx].stVector.wLength;

            DisplayBlock(&pstLocalDesc.abyWorkingBlock[0]);

            /* Now, we have to reoder to be compatible with the IP endianess */

            /* From now on, be careful, it all big endian based */
            Swap32BitsBigEndian( (unsigned int*)astTestTable[wIdx].abyMsgHex,
                                 (const unsigned int*)pstLocalDesc.abyWorkingBlock,
                                 BLOCK_SIZE_BITS );

            DisplayBlock(&astTestTable[wIdx].abyMsgHex[0]);
        }
    }

    return;
}

static void DisplayBlock(const byte * pbyBlock)
{
    word wIdx;

    for( wIdx=0; wIdx<BLOCK_SIZE_BYTES; wIdx++ )
    {
        printf("%02x ",pbyBlock[wIdx]);
    }

    printf("\n");

    return;
}
