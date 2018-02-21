/* *****************************************************************************
**
**                       General macros definitions
**
** Project      : -
** Module       : Macros.h
**
** Description  : This is the legacy header file that encapsulate useful macros
**
** ************************************************************************** */
#ifndef MACROS_H
#define MACROS_H

/* *****************************************************************************
**  REVISION HISTORY
** Date         Inits   Description
** ----------------------------------------------------------------------------
** 28.05.17     bd      [no issue number] File creation
**
** ************************************************************************** */
#define BYTE_MAX (0xFF)
#define DWORD_MAX (0xFFFF)
#define QWORD_MAX (0xFFFFFFFF)

#ifndef TRUE
#define TRUE (1)
#endif

#ifndef FALSE
#define FALSE (0)
#endif

#ifndef NULL
#define NULL (0x00000000) /* Null pointer definition */
#endif

/* Array macros */
#define mArraySize(Array) (sizeof(Array)/sizeof(Array[0]))

/* Offset macros */
#define mBITS_LeftShiftDouble(DblVal,Offs) ((double)(DblVal<<Offs))
#define mBITS_RightShiftDouble(DblVal,Offs) ((double)(DblVal>>Offs))

#define mSetBit(word,index) (word|=(0x1<<index))
#define mClearBit(word,index) (word&=~(0x1<<index))

#endif
