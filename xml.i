/*
Copyright (c) 2019 Colum Paget <colums.projects@googlemail.com>
* SPDX-License-Identifier: GPL-3.0
*/

/*
This module implemements xml relevant functions. Its main component is the XML member that returns 
an 'xml' object, which has only one member function 'next()' which returns the next xml tag in a list of 
xml tags. The xml_tag objects contain 'type' and 'data' string members. The 'data' member contains tag 
attributes. for a tag that encloses some text, like so: "<item content-type=text>text</item>" the 'next()' function will
return 3 items one after the other:

1st item: type="item" data="content-type=text"
2nd item: type="" data="text"
3rd item: type="/item" data=""

here is some example code:

string="<xml><item1>value1</item1><item2>value2</item2></xml>"
items=xml.XML(string)
item=items:next()
while item ~= nil
do
print(item.type .. " " .. item.data)
item=items:next()
end
*/




%module xml
%{

#include "libUseful-5/libUseful.h"

/*apply xml/html quoting to a string */
#define xmlQuote(Str) (HTMLQuote(NULL, Str))

/*unapply xml/html quoting to a string */
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




%init
%{
/* As lua uses garbage collection, and strings passed out of libUseful may not be*/
/* freed within libuseful before reuse, so we cannot use StrLen caching*/
LibUsefulSetValue("StrLenCache", "n");
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
