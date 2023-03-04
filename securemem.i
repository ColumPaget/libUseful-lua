/*
Copyright (c) 2019 Colum Paget <colums.projects@googlemail.com>
* SPDX-License-Identifier: GPL-3.0
*/

%module securemem
%{
#ifdef HAVE_LIBUSEFUL_5_LIBUSEFUL_H
#include "libUseful-5/libUseful.h"
#else
#include "libUseful-4/libUseful.h"
#endif
%}



%init
%{
/* As lua uses garbage collection, and strings passed out of libUseful may not be*/
/* freed within libuseful before reuse, so we cannot use StrLen caching*/
LibUsefulSetValue("StrLenCache", "n");
%}




typedef struct
{
int Size;
int Flags;
} SECURESTORE;


%extend SECURESTORE {
SECURESTORE (const char *Path)
{
SECURESTORE *Item;

Item=SecureStoreLoad(Path);
return(Item);
}

~SECURESTORE()
{
SecureStoreDestroy($self);
}

}


