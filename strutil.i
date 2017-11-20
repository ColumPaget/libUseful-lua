/*
This module implemements various string-based utility functions, including different forms of quoting and unquoting 
*/


%module strutil
%{
#include "libUseful-3/GeneralFunctions.h"
#include "libUseful-3/Tokenizer.h"
#include "libUseful-3/Http.h"
#include "libUseful-3/Markup.h"
#include "libUseful-3/String.h"
#include "libUseful-3/Errors.h"

#define httpQuote(Str) (HTTPQuote(NULL, Str))
#define httpUnQuote(Str) (HTTPUnQuote(NULL, Str))
#define htmlQuote(Str) (HTMLQuote(NULL, Str))
#define htmlUnQuote(Str) (HTMLUnQuote(NULL, Str))
#define quoteChars(Str, Chars) (QuoteCharsInStr(NULL, Str,Chars))
#define unQuote(Str) (UnQuoteStr(NULL, Str))
#define stripTrailingWhitespace(Str) (StripTrailingWhitespace(Str))
#define stripLeadingWhitespace(Str) (StripLeadingWhitespace(Str))
#define stripCRLF(Str) (StripCRLF(Str))

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


/* strutil.tometric(value, type)   - convert a numeric value to a metric notation string. e.g.  1200 gives 1.2k */
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

/* returns true if a string is alphanumeric */
int istext(const char *Str);

/* returns true if a string is numeric */
int isnum(const char *Str);

/* strip spaces from string */
void stripTrailingWhitespace(char *Str);
void stripLeadingWhitespace(char *Str);

/* strip carriage-return and/or linefeed from end of string */
void stripCRLF(char *Str);


/* Break a string up into tokens. For my money this is easier to use than the default lua method */
%extend TOKENIZER
{

/* Create a tokenizer, specifiying the string to be tokenized, a list of seperator strings, and optional */
/* flags that alter tokenizer behavior */
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
if ($self->Data==NULL) return(NULL);
return(Token);
}

const char *remaining()
{
return($self->Data);
}

}
