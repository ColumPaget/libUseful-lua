/*
Copyright (c) 2019 Colum Paget <colums.projects@googlemail.com>
* SPDX-License-Identifier: GPL-3.0
*/

/*
This module provide a 'RAWDATA' object that can be used to handle binary data.
*/


%module rawdata
%{
#include "libUseful-4/GeneralFunctions.h"
#include "libUseful-4/RawData.h"
#include "libUseful-4/LibSettings.h"
%}




%init
%{
/* As lua uses garbage collection, and strings passed out of libUseful may not be*/
/* freed within libuseful before reuse, so we cannot use StrLen caching*/
LibUsefulSetValue("StrLenCache", "n");
%}



typedef struct
{
} RAWDATA;



%extend RAWDATA
{

/* Create a rawdata object */
RAWDATA(char *Data, int Len, const char *Encoding="")
{
return(RAWDATACreate(Data, Encoding, Len));
}


/* You'll never call this, it's called automatically when the object goes out of scope */
~RAWDATA()
{
RAWDATADestroy($self);
}

/* read from stream into a RAWDATA object. RAWDATA object will be automatically resized if needed */
int read(STREAM *S, size_t len) {return(RAWDATARead($self, S, len));}
int readat(STREAM *S, size_t offset, size_t len) {return(RAWDATAReadAt($self, S, offset, len));}

/* write bytes from a rawdata object to a stream. offset and len can be used to write a subblock of the data */
int write(STREAM *S, size_t len=0, size_t offset=0) {return(RAWDATAWrite($self, S, offset, len));}

/* find a character in rawdata */
char findch(char value, size_t pos=-1) {return(RAWDATAFindChar($self, pos, value));}

/* get a character. Either gets the next one, or a position can be specified with 'pos' */
char getch(size_t pos=-1) {return(RAWDATAGetChar($self, pos));}

/* set a character. Either gets the next one, or a position can be specified with 'pos' */
int setch(char value, size_t pos=-1) {return(RAWDATASetChar($self, pos, value));}

/* get an 8-bit integer. Either gets the next one, or a position can be specified with 'pos' */
int geti8(size_t pos=-1) {return(RAWDATAGetChar($self, pos));}

/* set an 8-bit integer. Either gets the next one, or a position can be specified with 'pos' */
int seti8(char value, size_t pos=-1) {return(RAWDATASetChar($self, pos, value));}

/* get an 16-bit integer. Either gets the next one, or a position can be specified with 'pos' */
int geti16(size_t pos=-1) {return(RAWDATAGetInt16($self, pos));}

/* set a 16-bit integer. Either gets the next one, or a position can be specified with 'pos' */
int seti16(int16_t value, size_t pos=-1) {return(RAWDATASetInt16($self, pos, value));}

/* get a 32-bit integer. Either gets the next one, or a position can be specified with 'pos' */
int geti32(size_t pos=-1) {return(RAWDATAGetInt32($self, pos));}

/* set a 32-bit integer. Either gets the next one, or a position can be specified with 'pos' */
int seti32(int32_t value, size_t pos=-1) {return(RAWDATASetInt32($self, pos, value));}

/* copy a string from rawdata. This will keep going until it encounters a NUL or runs out of data */
%newobject copystr;
char *copystr() {return(RAWDATACopyStr(NULL, $self));}

/* copy a string of fixed size from rawdata */
%newobject copystrlen;
char *copystrlen(int len) {return(RAWDATACopyStrLen(NULL, $self, len));}

/* length of data in rawedata object */
size_t len() {return($self->DataLen);}

/* tel position in rawdata */
size_t tell() {return($self->pos);}

/* change position in rawdata */
int seek(size_t incr)
{
  int pos;

  pos=$self->pos+incr;
  if (pos > $self->BuffLen) return(FALSE);
  $self->pos=pos;
  return(TRUE);
}
}
