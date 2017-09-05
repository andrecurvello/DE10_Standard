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

#include <stdio.h>  /* Standard IO defns */
#include <string.h> /* String defns */

/* *****************************************************************************
**                          NON-SYSTEM INCLUDE FILES
** ************************************************************************** */
#include "JSON_ser.h" /* JSON serialization */
#include "json.h"     /* lib defs */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */
typedef struct
{
	dword dwAscci;
	dword dwHex;

}stAsciiHexEntry_t;

/* *****************************************************************************
**                                 GLOBALS
** ************************************************************************** */

/* *****************************************************************************
**                                 LOCALS
** ************************************************************************** */
static const stAsciiHexEntry_t abyStringToHexTable[] =
{
	{'0',0x00},
	{'1',0x01},
	{'2',0x02},
	{'3',0x03},
	{'4',0x04},
	{'5',0x05},
	{'6',0x06},
	{'7',0x07},
	{'8',0x08},
	{'9',0x09},
	{'a',0x0a},
	{'b',0x0b},
	{'c',0x0c},
	{'d',0x0d},
	{'e',0x0e},
	{'f',0x0f},
	{'A',0x0a},
	{'B',0x0b},
	{'C',0x0c},
	{'D',0x0d},
	{'E',0x0e},
	{'F',0x0f}
};

/* *****************************************************************************
**                              LOCALS ROUTINES
** ************************************************************************** */
static void StringToHex(byte*abyDest,const byte * const abySrc, const dword dwLength);

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
    json_object *pstJsonObj;
    json_object *pstJsonErr;
    json_object *pstJsonRes;

    /* Init locals */
    eRetVal = eJSON_ERR;

    if(   ( NULL != pbyResponse )
       && ( NULL != pstResult )
      )
    {
        pstJsonObj = json_tokener_parse((const char*)pbyResponse);

        /* Get value of each object */
        json_object_object_get_ex(pstJsonObj, "result",&pstJsonRes);
        json_object_object_get_ex(pstJsonObj, "error",&pstJsonErr);

        /* Is the answer sound ? */
        if( 0 == json_object_get_int(pstJsonErr) )
        {
            /* Update return value */
            eRetVal = eJSON_SUCCESS;

            /* Deserialise nonce 1, that is the "session Id" */
            pstJsonObj = json_object_array_get_idx(pstJsonRes,1);
            StringToHex( pstResult->abyNonce1,
            		     (byte*)json_object_get_string(pstJsonObj),
						 json_object_get_string_len(pstJsonObj) );
#if 0
            /* Debug */
            printf("[JSON] 0x");
			for( dwIdx=0;dwIdx<(json_object_get_string_len(pstJsonObj)/2);dwIdx++ )
			{
	            printf("%.2x",pstResult->abyNonce1[dwIdx]);
			}
            printf("\n");
#endif
            /* Deserialise nonce 2 size */
            pstJsonObj = json_object_array_get_idx(pstJsonRes,2);
            pstResult->wN2size = json_object_get_int(pstJsonObj);
        }

        /* Free allocated memory */
        free(pstJsonObj);
        free(pstJsonErr);
        free(pstJsonRes);
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
    json_object *pstJsonObj;
    json_object *pstJsonErr;
    json_object *pstJsonRes;

    /* Init locals */
    eRetVal = eJSON_ERR;

    if( NULL != pbyResponse )
    {
        pstJsonObj = json_tokener_parse((const char*)pbyResponse);

        /* Get value of each object */
        json_object_object_get_ex(pstJsonObj, "result",&pstJsonRes);
        json_object_object_get_ex(pstJsonObj, "error",&pstJsonErr);

        /* Is the answer sound ? */
        if(   ( 0 == json_object_get_int(pstJsonErr) )
           && ( 1 == json_object_get_boolean(pstJsonRes) )
          )
        {
            /* Answer is sound, update return value */
        }

        eRetVal = eJSON_SUCCESS;

        /* Free allocated memory */
        free(pstJsonObj);
        free(pstJsonRes);
        free(pstJsonErr);
    }

    return eRetVal;
}

eJSON_Status_t JSON_Deser_ResJob(stJSON_Job_Result_t * const pstResult,byte * const pbyResponse)
{
    eJSON_Status_t eRetVal;
    json_object *pstJsonObj;
    json_object *pstJsonArr;
    json_object *pstJsonMeth;
    char * pbyData;
    dword dwMerkleBLen;
    dword dwIndex;

    /* Init locals */
    eRetVal = eJSON_SUCCESS;
    pbyData = NULL;

    if( NULL != pbyResponse )
    {
        pstJsonObj = json_tokener_parse((const char*)pbyResponse);

        /* Get value of each object */
        json_object_object_get_ex(pstJsonObj, "params", &pstJsonArr);
        json_object_object_get_ex(pstJsonObj, "method", &pstJsonMeth);

        if( 0 == strcmp(json_object_get_string(pstJsonMeth),"mining.set_difficulty") )
        {
            if ( eJSON_SUCCESS == JSON_Deser_ResDifficulty( pstResult->doLiveDifficulty,
                                                            (byte*const)pbyResponse )
               )
            {
                /* Slice up these two JSON request */
                pbyData = strchr(((char*)pbyResponse+1), '{');
                pstJsonObj = json_tokener_parse((const char*)pbyData);
                json_object_object_get_ex(pstJsonObj, "params", &pstJsonArr);
            	printf("Diff %s\n",pbyResponse);

            }
            else
            {
               /* Update return value consequently */
                eRetVal = eJSON_ERR;
            }
        }

        /* Deserialise Job Id */
        pstJsonObj = json_object_array_get_idx(pstJsonArr,0);
        StringToHex( pstResult->abyJobId,
        		     (byte*)json_object_get_string(pstJsonObj),
					 json_object_get_string_len(pstJsonObj) );

        /* Deserialise previous hash */
        pstJsonObj = json_object_array_get_idx(pstJsonArr,1);
        StringToHex( pstResult->abyPrevHash,
        		     (byte*)json_object_get_string(pstJsonObj),
					 json_object_get_string_len(pstJsonObj) );

        /* Deserialise Coinbase 1 */
        pstJsonObj = json_object_array_get_idx(pstJsonArr,2);
        StringToHex( pstResult->abyCoinBase1,
        		     (byte*)json_object_get_string(pstJsonObj),
					 json_object_get_string_len(pstJsonObj) );

        /* Deserialise Coinbase 2 */
        pstJsonObj = json_object_array_get_idx(pstJsonArr,3);
        StringToHex( pstResult->abyCoinBase2,
        		     (byte*)json_object_get_string(pstJsonObj),
					 json_object_get_string_len(pstJsonObj) );

        /* Deserialise block version */
        pstJsonObj = json_object_array_get_idx(pstJsonArr,5);
        StringToHex( pstResult->abyBlckVer,
        		     (byte*)json_object_get_string(pstJsonObj),
					 json_object_get_string_len(pstJsonObj) );

        /* Deserialise nbits, network difficulty */
        pstJsonObj = json_object_array_get_idx(pstJsonArr,6);
        StringToHex( pstResult->abyNbits,
        		     (byte*)json_object_get_string(pstJsonObj),
					 json_object_get_string_len(pstJsonObj) );

        /* Deserialise time, crypto-system clock */
        pstJsonObj = json_object_array_get_idx(pstJsonArr,7);
        StringToHex( pstResult->abyNtime,
        		     (byte*)json_object_get_string(pstJsonObj),
					 json_object_get_string_len(pstJsonObj) );

        /* Deserialise clean, is it still relevent to share for that block ?*/
        pstJsonObj = json_object_array_get_idx(pstJsonArr,8);
        pstResult->bCleanJobs = (boolean)json_object_get_boolean(pstJsonObj);

        /* Merkle branches  */
        pstJsonObj = json_object_array_get_idx(pstJsonArr,4);
        dwMerkleBLen = json_object_array_length(pstJsonObj);
        for( dwIndex=0 ; dwIndex < dwMerkleBLen ; dwIndex++ )
        {
            if( MERKLE_TREE_MAX_DEPTH < dwIndex )
            {
                /* Update return value consequently */
                eRetVal = eJSON_ERR;
                break;
            }

            /* Copy memory */
            StringToHex( *(pstResult->abyMerkleBranch+dwIndex),
            		     (byte*)json_object_get_string(pstJsonObj),
    					 json_object_get_string_len(pstJsonObj) );
        }

        /* Free allocated memory */
        free(pstJsonObj);
        free(pstJsonArr);
        free(pstJsonMeth);
    }

    return eRetVal;
}

eJSON_Status_t JSON_Deser_ResDifficulty(double doLiveDifficulty, byte * const pbyResponse)
{
    eJSON_Status_t eRetVal;
    json_object *pstJsonObj;
    json_object *pstJsonErr;
    json_object *pstJsonRes;
    json_object *pstJsonPar;

    /* Init locals */
    eRetVal = eJSON_ERR;

    if( NULL != pbyResponse )
    {
        pstJsonObj = json_tokener_parse((const char*)pbyResponse);

        /* Get value of each object */
        json_object_object_get_ex(pstJsonObj, "result",&pstJsonRes);
        json_object_object_get_ex(pstJsonObj, "error",&pstJsonErr);
        json_object_object_get_ex(pstJsonObj, "params",&pstJsonPar);

        /* Is the answer sound ? */
        if(   ( 0 == json_object_get_int(pstJsonErr) )
           && ( 1 == json_object_get_boolean(pstJsonRes) )
          )
        {
        	/* Do nothing for the time being */
        }

        /* Get diff */
        doLiveDifficulty=json_object_get_double(pstJsonPar);

        /* Answer is sound, update return value */
        eRetVal = eJSON_SUCCESS;

        /* Free allocated memory */
        free(pstJsonObj);
        free(pstJsonErr);
        free(pstJsonRes);
    }

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
static void StringToHex( byte * abyDest, const byte * const abySrc, const dword dwLength)
{
	dword dwIdx;
	dword dwConvIdx;
	const byte * pbyChar;

	/* Basic sanity check */
	if(   ( NULL != abyDest )
	   && ( NULL != abySrc )
      )
	{
		/* Conversion */
		for(dwIdx = 0; dwIdx < dwLength; dwIdx++)
		{
			pbyChar=&abySrc[dwIdx];

			for(dwConvIdx = 0; dwConvIdx < mArraySize(abyStringToHexTable); dwConvIdx++)
			{
				/* Odd or even ? */
				if( abyStringToHexTable[dwConvIdx].dwAscci == ((int)(*pbyChar)) )
				{
					/* High or low nibble ? */
					if( 1 == (dwIdx%2) )
					{
						abyDest[dwIdx/2]|=(abyStringToHexTable[dwConvIdx].dwHex & 0x0F);
					}
					else
					{
						abyDest[dwIdx/2]=((abyStringToHexTable[dwConvIdx].dwHex<<4) & 0xF0);
					}
				}
			}
		}
	}

	return;
}
