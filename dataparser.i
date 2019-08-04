/*

This module provides a dataparser class that can parse JSON, YAML, RSS etc.

A parser object can be interrogated for it's immediate child objects. If those objects are themselves collections then
another parser object can be created with 'Child=P:open(name)'. Values of attributes within an object can be obtained using
'value'. So, for example

JSON='{
name: "test json",
subobject: 
{
  name: "subobject",
  id: 1234
}
}

P=dataparser.PARSER("json", JSON);
print("root object name"..P:value("name"));
Child=P:open("/subobject");
printf("child object name: "..Child:value("name").. " ID: ".. Child:value("ID"));

*/



%module dataparser
%{
#include "libUseful-4/DataParser.h"
#include "libUseful-4/Errors.h"
#include "libUseful-4/List.h"
%}


typedef struct 
{
struct lnode *Next;
struct lnode *Prev;
char *Tag;
//in map heads ItemType is used to hold the number of buckets
uint16_t ItemType;
uint16_t Flags;
struct lnode *Head;
void *Item;
struct lnode *Side;
ListStats *Stats;
} PARSER;


%extend PARSER {

/* 
Create a parser. 
'Type' can be 'json', 'yaml' 'rss'
'Doc' is the document string to parse
*/
PARSER(const char *Type, const char *Doc="")
{
PARSER *Item;

Item=ParserParseDocument(Type, Doc);
Item->Side=NULL;
return(Item);
}


/*
Destroy a parser object. The programmer would never normally call this as it's called automatically when an object goes out of scope
*/
~PARSER()
{
//if (! ($self->Flags & PARSER_SUBITEMS) )ParserItemsDestroy($self);
free($self);
}


/*
Open a path within the parse tree. 
This returns a new parser object whose root is the object specified by the path
For instance, if a json object called 'person' contains a subitem called 'address' which itself contains
an element called 'town' you'd use 'Address=P:open("/person/address/") and then 'print(Address:value("town"))
*/
PARSER *open(const char *Path)
{
PARSER *Item;

Item=ParserOpenItem($self, Path);
if (Item) Item->Side=Item;
return(Item);
}


/*
Get the first sub element in a parser object. 
This returns a PARSER object, but you don't need to use that as an internal pointer now points 
to the first child within the original PARSER object, and you can use 'name' and 'value' on that
*/
PARSER *first()
{
$self->Side=ListGetNext($self);
return($self->Side);
}

/*
Get previous sub element of a parser object
This returns a PARSER object, but you don't need to use that as an internal pointer now points 
to the first child within the original PARSER object, and you can use 'name' and 'value' on that
*/
PARSER *prev()
{
if ($self->Side) $self->Side=ListGetPrev($self->Side);
return($self->Side);
}


/*
Get previous next element of a parser object
This returns a PARSER object, but you don't need to use that as an internal pointer now points 
to the first child within the original PARSER object, and you can use 'name' and 'value' on that
*/
PARSER *next()
{
if ($self->Side) $self->Side=ListGetNext($self->Side);
else $self->Side=ListGetNext($self);

return($self->Side);
}


/*
Get the name of the current element in a parser object. The methods 'first', 'next' and 'prev' can be used to 
change which is the current element
*/
const char *name()
{
if (StrValid($self->Tag)) return($self->Tag);
return("");
}

/*
return the type of the current element
*/
const char *type()
{
  if ($self->ItemType==ITEM_VALUE) return("value");
  return("object");
}

/*
get the value of an attribute. If an object in the parse tree is a collection, then you can access its attributes by passing their names here. If an item is a value, then passing nothing will return it's value
*/
const char *value(const char *Name="")
{
const char *ptr=NULL;

if (StrEnd(Name))
{
  if ($self->ItemType==ITEM_VALUE) return($self->Item);
  else return("");
}
else
{
if ($self->Side) ptr=ParserGetValue($self->Side, Name);
if (! StrValid(ptr))  ptr=ParserGetValue($self, Name);
}

return(ptr);
}


/*
Number of immediate children of a PARSER object
*/
int size()
{
return(ListSize($self));
}

}

