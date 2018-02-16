/* *****************************************************************************
**
**                       Standalone bitcoin miner
**
** Project      :
** Module       :
**
** Description  :
**
** ************************************************************************** */

/* *****************************************************************************
**  REVISION HISTORY
** Date         Inits   Description
** ----------------------------------------------------------------------------
** 28.05.17     bd      [no issue number] File creation
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
#include "hex.h"  /* hex string manipulations */

/* *****************************************************************************
**                          ENUM & MACRO DEFINITIONS
** ************************************************************************** */

/* *****************************************************************************
**                              TYPE DEFINITIONS
** ************************************************************************** */
typedef struct
{
    dword dwAscii;
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
**                                  API
** ************************************************************************** */
void StringToHex( byte * abyDest, const byte * const abySrc, const dword dwLength)
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
                if( abyStringToHexTable[dwConvIdx].dwAscii == ((int)(*pbyChar)) )
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

/* Length received is in bits */
void Swap32BitsBigEndian(unsigned int * aqwDataDest, const unsigned int * aqwDataSrc, const dword dwLength)
{
    dword dwIdx;
    dword dwWordLen;

    /* Basic sanity check */
    if(   ( NULL != aqwDataSrc )
       && ( NULL != aqwDataDest )
      )
    {
        /* Conversion, the length received is in bits */
        if( 0 != (dwLength%32) )
        {
            dwWordLen=(dwLength/32)+1;
        }
        else
        {
            dwWordLen=(dwLength/32);
        }

        for(dwIdx = 0; dwIdx < dwWordLen; dwIdx++)
        {
            /* Reorder */
            *(aqwDataDest + dwIdx) = *(aqwDataSrc + dwWordLen - 1 - dwIdx);
        }
    }

    return;
}
