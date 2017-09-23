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
** ----------------------------------------------------------------------------
** 17.09.17     bd      [no issue number] Make sure all stratum transaction are
** 									      unpacked properly
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
/* Handy struct for string to FPGA readable format */
static const stAsciiHexEntry_t abyStringToHexTable[] =
{
	{'0',0x00}, /* '0' is 48 and correspond to 0x00 */
	{'1',0x01}, /* '1' is 49 and correspond to 0x00 */
	{'2',0x02}, /* '2' is 50 and correspond to 0x00 */
	{'3',0x03}, /* '3' is 51 and correspond to 0x00 */
	{'4',0x04}, /* '4' is 52 and correspond to 0x00 */
	{'5',0x05}, /* '5' is 53 and correspond to 0x00 */
	{'6',0x06}, /* '6' is 54 and correspond to 0x00 */
	{'7',0x07}, /* '7' is 55 and correspond to 0x00 */
	{'8',0x08}, /* '8' is 56 and correspond to 0x00 */
	{'9',0x09}, /* '9' is 57 and correspond to 0x00 */
	{'a',0x0a}, /* 'a' is 97 and correspond to 0x00 */
	{'b',0x0b}, /* 'b' is 98 and correspond to 0x00 */
	{'c',0x0c}, /* 'c' is 99 and correspond to 0x00 */
	{'d',0x0d}, /* 'd' is 100 and correspond to 0x00 */
	{'e',0x0e}, /* 'e' is 101 and correspond to 0x00 */
	{'f',0x0f}, /* 'f' is 102 and correspond to 0x00 */
	{'A',0x0a}, /* 'A' is 65 and correspond to 0x00 */
	{'B',0x0b}, /* 'B' is 66 and correspond to 0x00 */
	{'C',0x0c}, /* 'C' is 67 and correspond to 0x00 */
	{'D',0x0d}, /* 'D' is 68 and correspond to 0x00 */
	{'E',0x0e}, /* 'E' is 69 and correspond to 0x00 */
	{'F',0x0f}  /* 'F' is 70 and correspond to 0x00 */
};

/* *****************************************************************************
**                              LOCALS ROUTINES

** ************************************************************************** */
static void StringToHex(byte*abyDest,const byte * const abySrc, const dword dwLength);
static byte NumMsgPacked( byte * abyMsg);
static byte *UnpackReq( byte * abyMsg,const byte * const abyToken);

/* *****************************************************************************
**                                  API
** ************************************************************************** */

/* ************************************************************************** */
eJSON_Status_t JSON_Ser_ReqConnect(const word wWorkId, byte * const pbyRequest)
/* **************************************************************************
** Input  : -
** Output : -
** Return : -
**
** Description : Build connection request.
**
** ************************************************************************** */
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

/* ************************************************************************** */
eJSON_Status_t JSON_Deser_ResConnect( stSCHEDULER_Work_t * const pstResult, byte * const pbyResponse )
/* **************************************************************************
** Input  : pstResult   - structure receiving the data from the network
**          pbyResponse - the received string
** Output : -
** Return : JSON deserializing status.
**
** Description : Deserialize connection response.
**
** ************************************************************************** */
{
    eJSON_Status_t eRetVal;
    json_object *pstJsonObj;
    json_object *pstJsonErr;
    json_object *pstJsonRes;
    byte *pbyData;

    /* Init locals */
    eRetVal = eJSON_ERR;
    pbyData = NULL;

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

            /* Deserialise nonce 2 size */
            pstJsonObj = json_object_array_get_idx(pstJsonRes,2);
            pstResult->wN2size = json_object_get_int(pstJsonObj);
        }

        /* Have we received a "set_difficulty" request ? */
        pbyData = UnpackReq((byte*)pbyResponse,(const byte* const)"mining.set_difficulty");

        /* Extract infos */
        pstResult->doDiff = JSON_Deser_ResDifficulty(pbyData);

        /* Have we received a "notify" request ? */
        pbyData = UnpackReq((byte*)pbyResponse,(const byte* const)"mining.notify");

        /* Extract infos */
        eRetVal = JSON_Deser_ResJob(pstResult,pbyData);

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

eJSON_Status_t JSON_Deser_ResJob(stSCHEDULER_Work_t * const pstResult,byte * const pbyResponse)
{
    eJSON_Status_t eRetVal;
    json_object *pstJsonObj;
    json_object *pstJsonArr;
    json_object *pstJsonMeth;
    byte * pbyData;
    dword dwMerkleBLen;
    dword dwIndex;

    /* Init locals */
    eRetVal = eJSON_SUCCESS;
    pbyData = NULL;

    if( NULL != pbyResponse )
    {
        /* Have we received a "set_difficulty" request ? */
        pbyData = UnpackReq((byte*)pbyResponse,(const byte* const)"mining.set_difficulty");

        /* Extract infos */
        if ( NULL != pbyData )
        {
            pstResult->doDiff = JSON_Deser_ResDifficulty(pbyData);
            printf("difficulty :%lf\n", pstResult->doDiff);
        }

        /* crack on with the job exctraction */
        pstJsonObj = json_tokener_parse((const char*)pbyResponse);

        /* Get value of each object */
        json_object_object_get_ex(pstJsonObj, "params", &pstJsonArr);
        json_object_object_get_ex(pstJsonObj, "method", &pstJsonMeth);

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
        pstResult->bClean = (boolean)json_object_get_boolean(pstJsonObj);

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

            /* Get merkle branch */
            pstJsonObj = json_object_array_get_idx(json_object_array_get_idx(pstJsonArr,4),dwIndex);

            /* Copy memory */
            StringToHex( pstResult->aabyMerkleBranch[dwIndex],
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

double JSON_Deser_ResDifficulty(byte * const pbyResponse)
{
	double doRetVal;
    json_object *pstJsonObj;
    json_object *pstJsonErr;
    json_object *pstJsonRes;
    json_object *pstJsonPar;

    /* Init locals */
    doRetVal = 0;

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
        doRetVal=json_object_get_double(json_object_array_get_idx(pstJsonPar,0));
        printf("difficulty :%lf\n", doRetVal);

        /* Free allocated memory */
        free(pstJsonObj);
        free(pstJsonErr);
        free(pstJsonRes);
    }

    return doRetVal;
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

/* Need to implement a parsing state machine */
static byte * UnpackReq( byte * abyMsg,const byte* const abyToken)
{
	dword dwIdx;
	byte byNumRequest ;
    json_object *pstJsonObj;
    json_object *pstJsonErr;
    json_object *pstJsonMeth;
    byte *pbyRet;
    byte *pbyData;

    /* Init locals */
    pbyData = NULL;
    pbyRet = NULL;

	/* Basic sanity check */
	if(  NULL != abyMsg )
	{
		/* Init locals */
		byNumRequest = NumMsgPacked(abyMsg);
		pbyData = abyMsg;

		for( dwIdx = 0; dwIdx < byNumRequest ; dwIdx++ )
		{
	        /* Search */
	        pbyData = (byte*)strchr(((char*)pbyData), '{');

	        pstJsonObj = json_tokener_parse((const char*)pbyData);

	        /* Get value of each object */
	        json_object_object_get_ex(pstJsonObj, "method",&pstJsonMeth);
	        json_object_object_get_ex(pstJsonObj, "error",&pstJsonErr);

	        /* Difficulty */
	        if(    ( NULL != pstJsonMeth )
	        	&& ( 0 == strcmp(json_object_get_string(pstJsonMeth),(const char*)abyToken) )
			  )
	        {
	            /* Update return value */
	            pbyRet = pbyData;

                /* Getting out */
                break;
	        }

            /* Slice up these two JSON request */
            pbyData++;
		}
	}

	return pbyRet;
}

static byte NumMsgPacked( byte * abyMsg)
{
	byte byRetVal;
	byte * pbyData;

	/* Init locals */
	byRetVal = 0;

	/* Basic sanity check */
	if(  NULL != abyMsg )
	{
		/* Search */
        pbyData = (byte*)strchr(((char*)abyMsg), '{');

		for(;NULL != pbyData;byRetVal++)
		{
			/* Trigger new search */
			pbyData++;

			/* Search */
	        pbyData = (byte*)strchr(((char*)pbyData), '{');
		}
	}

	return byRetVal;
}
