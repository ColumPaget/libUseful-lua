/*
Copyright (c) 2019 Colum Paget <colums.projects@googlemail.com>
* SPDX-License-Identifier: GPL-3.0
*/

/*

This module implements access to the libUseful errors system. This is mostly useful for discovering
why a connection using a STREAM object failed and returned NULL/nil

usage:

errs=libuseful_errors.ERRORS()

str=errs:next()
while str ~= nil
do
print(str)
str=errs:next()
end

*/

%module libuseful_errors
%{
#include "libUseful-4/Errors.h"
#include "libUseful-4/LibSettings.h"

typedef struct
{
ListNode *Items;
} ERRORS;
%}



%init
%{
/* As lua uses garbage collection, and strings passed out of libUseful may not be*/
/* freed within libuseful before reuse, so we cannot use StrLen caching*/
LibUsefulSetValue("StrLenCache", "n");
%}



typedef struct
{
ListNode *Items;
} ERRORS;

%extend ERRORS {
ERRORS ()
{
ERRORS *Item;
Item=(ERRORS *) calloc(1, sizeof(ERRORS));
Item->Items=ErrorsGet();
return(Item);
}

~ERRORS ()
{
//do not free Item->Items as it is an internal libuseful list
free($self);
}

const char *next()
{
TError *Item;

if (! $self->Items->Side) $self->Items->Side=ListGetNext($self->Items);
else $self->Items->Side=ListGetNext($self->Items->Side);

//if we reached end of list, this will be NULL
if ($self->Items->Side==NULL) return(NULL);
Item=(TError *) $self->Items->Side->Item;
return(Item->msg);
}

}





