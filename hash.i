/*

This module implements various hash functions. Available hashing algorithms should at least include md5, sha1, sha256, sha512, whirl (whirlpool). Hash types can be concatted, so:

"whirl, sha1"

means "first hash with whirlpool, then has the result of that with sha1"

hash.types()       produces a string that lists the types of hash available.
hash.hashstr(str, type, encoding)   hashes string 'str' using hash function 'type' (e.g. 'sha1'). encoding is optional, (e.g. 'base64', 'hex', 'octal' etc). Default encoding is 'hex'.
hash.hashfile(path, type, encoding)   hashes file at 'path' using hash function 'type' (e.g. 'sha1'). encoding is optional, (e.g. 'base64', 'hex', 'octal' etc). Default encoding is 'hex'.

Also available is the hash object for more general hashing:

h=hash.HASH("whirl,sha1","base64");
h:update("some text to hash");
h:update("more text to hash");
print("result: " .. h:finish());

*/

%module hash
%{
#include "libUseful-3/Hash.h"
#include "libUseful-3/Errors.h"

#define types() HashAvailableTypes(NULL);

char *hashstr(const char *Str, const char *Type, const char *Encoding)
{
char *RetStr=NULL;
HashBytes(&RetStr, Type, Str, StrLen(Str), HashEncodingFromStr(Encoding));

return(RetStr);
}


char *hashfile(const char *Path, const char *Type, const char *Encoding)
{
char *RetStr=NULL;

HashFile(&RetStr, Type, Path, HashEncodingFromStr(Encoding));

return(RetStr);
}
%}

typedef struct
{
int Encoding;
HASH_UPDATE Update;
} HASH;

%extend HASH {
HASH (const char *Type, const char *Encoding="", const char *Key="")
{
HASH *Item;

Item=HashInit(Type);
if (StrValid(Key)) HMACSetKey(Item, Key, StrLen(Key));
Item->Encoding=HashEncodingFromStr(Encoding);
return(Item);
}

~HASH ()
{
HashDestroy($self);
}

void update(const char *Bytes)
{
$self->Update($self, Bytes, StrLen(Bytes));
}

%newobject finish;
char *finish()
{
char *Str=NULL;

HashFinish($self, $self->Encoding, &Str);
return(Str);
}
}



%newobject types;
char *types();


%newobject hashstr;
char *hashstr(const char *Str, const char *Type, const char *Encoding="hex");

%newobject hashfile;
char *hashfile(const char *Path, const char *Type, const char *Encoding="hex");
