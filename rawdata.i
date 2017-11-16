/*
This module provide a 'RAWDATA' object that can be used to handle binary data.
*/


%module rawdata
%{
#include "libUseful-3/GeneralFunctions.h"
#include "libUseful-3/RawData.h"
%}


typedef struct
{
} RAWDATA;



%extend RAWDATA
{
RAWDATA(char *Data, int Len, const char *Encoding="")
{
return(RAWDATACreate(Data, Encoding, Len));
}

~RAWDATA()
{
RAWDATADestroy($self);
}

int read(STREAM *S, size_t len, size_t offset=0) {return(RAWDATARead($self, S, len));}
int write(STREAM *S, size_t len=0, size_t offset=0) {return(RAWDATAWrite($self, S, offset, len));}
char findch(char value, size_t pos=-1) {return(RAWDATAFindChar($self, pos, value));}
char getch(size_t pos=-1) {return(RAWDATAGetChar($self, pos));}
int setch(char value, size_t pos=-1) {return(RAWDATASetChar($self, pos, value));}
int geti8(size_t pos=-1) {return(RAWDATAGetChar($self, pos));}
int seti8(char value, size_t pos=-1) {return(RAWDATASetChar($self, pos, value));}
int geti16(size_t pos=-1) {return(RAWDATAGetInt16($self, pos));}
int seti16(int16_t value, size_t pos=-1) {return(RAWDATASetInt16($self, pos, value));}
int geti32(size_t pos=-1) {return(RAWDATAGetInt32($self, pos));}
int seti32(int32_t value, size_t pos=-1) {return(RAWDATASetInt32($self, pos, value));}

%newobject copystr;
char *copystr() {return(RAWDATACopyStr(NULL, $self));}

%newobject copystrlen;
char *copystrlen(int len) {return(RAWDATACopyStrLen(NULL, $self, len));}
size_t tell() {return($self->pos);}
size_t len() {return($self->DataLen);}
int seek(size_t incr)
{
  int pos;

  pos=$self->pos+incr;
  if (pos > $self->BuffLen) return(FALSE);
  $self->pos=pos;
  return(TRUE);
}
}
