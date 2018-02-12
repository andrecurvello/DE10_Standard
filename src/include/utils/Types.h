/* *****************************************************************************
**
**                       General types definitions
**
** Project      : -
** Module       : Types.h
**
** Description  : This is the legacy header file that encapsulate types
**                definitions
**
** ************************************************************************** */
#ifndef TYPES_H
#define TYPES_H

/* *****************************************************************************
**  REVISION HISTORY
** Date         Inits   Description
** ----------------------------------------------------------------------------
** 28.05.17     bd      [no issue number] File creation
**
** ************************************************************************** */
typedef unsigned char byte;       /* 1 byte */
typedef unsigned short dword;     /* 2 bytes unsigned */
typedef unsigned int word;        /* 4 bytes unsigned */
typedef unsigned long long qword; /* 8 bytes unsigned */

typedef signed char sbyte;        /* 1 bytes signed */
typedef signed short sdword;      /* 2 bytes signed */
typedef signed int sword;         /* 4 bytes signed */
typedef signed long long sqword;  /* 8 bytes signed */

/* Need support for double and float */
/* float IEEE754 single precision on 32 bits */
/* float IEEE754 double precision on 64 bits */

typedef char boolean; /* define boolean in C */
#endif
