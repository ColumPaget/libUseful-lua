/*
Copyright (c) 2019 Colum Paget <colums.projects@googlemail.com>
* SPDX-License-Identifier: GPL-3.0
*/

/*
This module implemements various string-based utility functions, including different forms of quoting and unquoting 
*/


%module xml
%{
#include "libUseful-4/GeneralFunctions.h"
#include "libUseful-4/Tokenizer.h"
#include "libUseful-4/Markup.h"
#include "libUseful-4/String.h"
#include "libUseful-4/Errors.h"

#define xmlQuote(Str) (HTMLQuote(NULL, Str))
#define xmlUnQuote(Str) (HTMLUnQuote(NULL, Str))


typedef struct
{
char *Data;
const char *Curr;
} XML;


typedef struct
{
char *type;
char *data;
} XML_TAG;


%}


/* apply HTML style quoting to a string */
%newobject xmlQuote;
char *xmlQuote(const char *Str); 

/* undo HTML style quoting */
%newobject xmlUnQuote;
char *xmlUnQuote(const char *Str); 


typedef struct
{
//empty struct that we will extend
} XML;


typedef struct
{
char *type;
char *data;
} XML_TAG;



%extend XML_TAG
{
XML_TAG()
{

}

~XML_TAG()
{
free($self->type);
free($self->data);
free($self);
}

}



/* Break a string up into tokens. For my money this is easier to use than the default lua method */
%extend XML
{

XML(const char *Str)
{
XML *Item;

Item=(XML *) calloc(1,sizeof(XML));
Item->Data=CopyStr(NULL, Str);
Item->Curr=Item->Data;
return(Item);
}

~XML()
{
Destroy($self->Data);
free($self);
}


/* get next token. If 'Separators' is not provided, then fall back to the separators specified at */
/* tokenizer creation */
%newobject next;
XML_TAG *next()
{
char *Token=NULL;
const char *ptr, *tptr;
XML_TAG *Tag=NULL;

ptr=$self->Curr;

if (ptr)
{
while (isspace(*ptr)) ptr++;

Tag=(XML_TAG *) calloc(1, sizeof(XML_TAG));
if (*ptr=='<')
{
  ptr++;
  ptr=GetToken(ptr, "<|>", &Token, GETTOKEN_MULTI_SEP | GETTOKEN_INCLUDE_SEP);
  tptr=GetToken(Token, "\\S", &(Tag->type), 0);
  Tag->data=HTMLUnQuote(Tag->data, tptr);
  ptr=GetToken(ptr, "<|>", &Token, GETTOKEN_MULTI_SEP | GETTOKEN_INCLUDE_SEP);
}
else ptr=GetToken(ptr, "<|>", &(Tag->data), GETTOKEN_MULTI_SEP | GETTOKEN_INCLUDE_SEP);
}

$self->Curr=ptr;
Destroy(Token);

return(Tag);
}

}
