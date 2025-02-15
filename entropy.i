/*
Copyright (c) 2019 Colum Paget <colums.projects@googlemail.com>
* SPDX-License-Identifier: GPL-3.0
*/

/*

This module provides some wrapper functions around libUseful's "GetRandom" functions


*/


%module entropy
%{
#include "libUseful-5/libUseful.h"

char *get(int len, const char *Encoding)
{
char *Str=NULL;
int encode;

if (StrLen(Encoding)==0) encode=ENCODE_PBASE64;
else encode=HashEncodingFromStr(Encoding);

GenerateRandomBytes(&Str, len, encode);
return(Str);
}


char *hex(int len)
{
char *Str=NULL;

Str=GetRandomHexStr(Str, len);
return(Str);
}

char *alphanum(int len)
{
char *Str=NULL;

Str=GetRandomAlphabetStr(Str, len);
return(Str);
}



%}



%init
%{
/* As lua uses garbage collection, and strings passed out of libUseful may not be*/
/* freed within libuseful before reuse, so we cannot use StrLen caching*/
LibUsefulSetValue("StrLenCache", "n");
%}


%newobject get;
char *get(int len, const char *Encoding="");

%newobject hex;
char *hex(int len);

%newobject alphanum;
char *alphanum(int len);
