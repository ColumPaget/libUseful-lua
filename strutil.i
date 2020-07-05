/*
Copyright (c) 2019 Colum Paget <colums.projects@googlemail.com>
* SPDX-License-Identifier: GPL-3.0
*/

/*
This module implemements various string-based utility functions, including different forms of quoting and unquoting 
*/


%module strutil
%{
#include "libUseful-4/GeneralFunctions.h"
#include "libUseful-4/Tokenizer.h"
#include "libUseful-4/Http.h"
#include "libUseful-4/Markup.h"
#include "libUseful-4/String.h"
#include "libUseful-4/Errors.h"
#include "libUseful-4/PatternMatch.h"
#include "libUseful-4/Encodings.h"

#define safestrlen(Str) (StrLen(Str))
#define httpQuote(Str) (HTTPQuote(NULL, Str))
#define httpUnQuote(Str) (HTTPUnQuote(NULL, Str))
#define htmlQuote(Str) (HTMLQuote(NULL, Str))
#define htmlUnQuote(Str) (HTMLUnQuote(NULL, Str))
#define quoteChars(Str, Chars) (QuoteCharsInStr(NULL, Str, Chars))
#define unQuote(Str) (UnQuoteStr(NULL, Str))
#define pad(Str, Pad, PadLen) (CopyPadStr(NULL, Str, Pad, PadLen))
#define padto(Str, Pad, PadLen) (CopyPadStrTo(NULL, Str, Pad, PadLen))
#define pmatch_check(Pattern, String, len) (pmatch_one(Pattern, String, (len > 0 ? len: StrLen(String)), NULL, NULL, 0))
#define decode(Data, Encoding) (DecodeToText(NULL, Data, EncodingParse(Encoding)))

char *stripCRLF(const char *Str) 
{
char *Ret=NULL;
Ret=CopyStr(Ret, Str);
StripCRLF(Ret);
return(Ret);
}

char *stripQuotes(const char *Str) 
{
char *Ret=NULL;
Ret=CopyStr(Ret, Str);
StripQuotes(Ret);
return(Ret);
}

char *stripTrailingWhitespace(const char *Str) 
{
char *Ret=NULL;
Ret=CopyStr(Ret, Str);
StripTrailingWhitespace(Ret);
return(Ret);
}

char *stripLeadingWhitespace(const char *Str) 
{
char *Ret=NULL;
Ret=CopyStr(Ret, Str);
StripLeadingWhitespace(Ret);
return(Ret);
}

char *trim(const char *Str)
{
char *Ret=NULL;
Ret=CopyStr(Ret, Str);
StripTrailingWhitespace(Ret);
StripLeadingWhitespace(Ret);
return(Ret);
}


typedef struct
{
const char *Data;
const char *Separators;
int Flags;
} TOKENIZER;
%}


typedef struct
{
//empty struct that we will extend
} TOKENIZER;


/* strlen that works with nil instead of throwing an error */
%rename(strlen) safestrlen;
int safestrlen(const char *Str);



/* strutil.toMetric(value, type)   - convert a numeric value to a metric notation string. e.g.  1200 gives 1.2k */
%rename(toMetric) ToMetric;
const char *ToMetric(double Value, int Precision=1);

/* strutil.frommetric(Str, type)   - convert a numeric value from a metric notation string. e.g.  2.6k gives 2600 */
%rename(fromMetric) FromMetric;
double FromMetric(const char *Str, int Precision=1);


/* strutil.toIEC(value, type)   - convert a numeric value to a IEC notation string. e.g.  1200 gives 1.2k */
%rename(toIEC) ToIEC;
const char *ToIEC(double Value, int Precision=1);

/* strutil.fromIEC(Str, type)   - convert a numeric value from a IEC notation string. e.g.  2.6k gives 2600 */
%rename(fromIEC) FromIEC;
double FromIEC(const char *Str, int Precision=1);

/* strutil.fromIEC(Str, type)   - convert a numeric value from a IEC notation string. e.g.  2.6k gives 2600 */
%rename(pmatch) pmatch_check;
bool pmatch_check(const char *Pattern, const char *String, int len=0);


/* apply HTTP style 'percent' encoding to a string */
%newobject httpQuote;
char *httpQuote(const char *Str);

/* undo HTTP style 'percent' encoding to recover original string */
%newobject httpUnQuote;
char *httpUnQuote(const char *Str); 

/* apply HTML style quoting to a string */
%newobject htmlQuote;
char *htmlQuote(const char *Str); 

/* undo HTML style quoting */
%newobject htmlUnQuote;
char *htmlUnQuote(const char *Str); 

/* apply 'C' style quoting (with backslash) to a string, quoting out those characters listed in 'Chars' */
%newobject quoteChars;
char *quoteChars(const char *Str, const char *Chars);

/* undo 'C' style quoting (with backslash) of a string */
%newobject unQuote;
char *unQuote(const char *Str);


/* pad str with len chars */
%newobject pad;
char *pad(const char *Str, char Pad, int Len);

/* pad str to len chars */
%newobject padto;
char *padto(const char *Str, char Pad, int Len);


/* returns true if a string is alphanumeric */
bool istext(const char *Str);

/* returns true if a string is numeric */
bool isnum(const char *Str);

/* strip spaces from string */
%newobject stripTrailingWhitespace;
char *stripTrailingWhitespace(char *Str);

%newobject stripLeadingWhitespace;
char *stripLeadingWhitespace(char *Str);

%newobject stripQuotes;
char *stripQuotes(char *Str);

/* strip carriage-return and/or linefeed from end of string */
%newobject stripCRLF;
char *stripCRLF(char *Str);


/* strip leading and trailing whitespace */
%newobject trim;
char *trim(char *Str);

/* Decode from base64 etc, to text */
%newobject decode;
char *decode(const char *Data, const char *Encoding);



/* Break a string up into tokens. For my money this is easier to use than the default lua method */
%extend TOKENIZER
{

/* Create a tokenizer, specifiying the string to be tokenized, a list of seperator strings, and optional */
/* flags that alter tokenizer behavior */

/* Flags is a string of characters:

m    'multi separators', more than one separator string can be given, seperated by '|' 
     e.g. strutil.TOKENIZER(str, "<|>", "m")   to break a string up at instances of '<' or '>'

q    'honor quotes', don't tokenize substrings in quotes
Q    'honor quotes' but also strip quotes from returned tokens
s    include separators as tokens returned from the tokenizer
+    include separators by appending them to the preceeding token

*/

TOKENIZER(const char *Str, const char *Separators=" ", const char *Flags="")
{
TOKENIZER *Item;

Item=(TOKENIZER *) calloc(1,sizeof(TOKENIZER));
Item->Data=Str;
Item->Separators=Separators;
Item->Flags=GetTokenParseConfig(Flags);
return(Item);
}

~TOKENIZER()
{
free($self);
}

/* get next token. If 'Separators' is not provided, then fall back to the separators specified at */
/* tokenizer creation */
%newobject next;
char *next(const char *Separators="")
{
char *Token=NULL;

if (! StrValid(Separators)) Separators=$self->Separators;
$self->Data=GetToken($self->Data,Separators,&Token,$self->Flags);
if ($self->Data==NULL) 
{
  /*if you don't do this, you get a memory leak */
  Destroy(Token);
  return(NULL);
}
return(Token);
}

%newobject peek;
char *peek(const char *Separators="")
{
char *Token=NULL;
const char *ptr;

if (! StrValid(Separators)) Separators=$self->Separators;
ptr=GetToken($self->Data,Separators,&Token,$self->Flags);
if (ptr==NULL)
{
  /*if you don't do this, you get a memory leak */
  Destroy(Token);
  return(NULL);
}
return(Token);
}


const char *remaining()
{
return($self->Data);
}

}
