/*

This module handles most of the file and network access via a 'STREAM' object. For example read a line from a file:

S=stream.STREAM("/tmp/myfile.txt", "r")
line=S:readln()
print("first line: " .. line) 
S:close()

Read a line from a tcp connection

S=stream.STREAM("tcp:www.google.com:80", "r")
line=S:readln()
print("first line: " .. line) 
S:close()

Read a line from an http  connection (this will be different to a tcp connection. With a tcp connection the first
line will be the HTTP response, with HTTP it will be the first line of the document).

S=stream.STREAM("http:www.google.com:80", "r")
line=S:readln()
print("first line: " .. line) 
S:close()


You can also read from commands (and write to them, allowing read/write communications)

S=stream.STREAM("cmd:ps")
doc=S:readdoc()
print(doc)

*/


%module stream
%{
#include "libUseful-3/Stream.h"
#include "libUseful-3/FileSystem.h"
#include "libUseful-3/Http.h"
#include "libUseful-3/Expect.h"
#include "libUseful-3/Errors.h"
#include <unistd.h>

void Progressor(const char *Path, int bytes, int total){/*printf("\r %s %d %d            ",Path,bytes,total);fflush(NULL);*/}

typedef struct
{
ListNode *Streams;
} POLL_IO;
%}



/* None of stream internals should be exposed to lua */
typedef struct
{
} STREAM;


%extend STREAM {
STREAM (const char *Path, const char *Config="") 
{
if (Path && (*Path != '\0')) return(STREAMOpen(Path, Config));
return(STREAMCreate());
}

/* read a line from a stream */
%newobject readln;
char *readln() {return(STREAMReadLine(NULL, $self));} 


/* read from a stream util a 'terminator' character */
%newobject readto;
char *readto(char Term) {return(STREAMReadToTerminator(NULL, $self, Term));} 

/* read the stream until EOF, return it as one big string */
%newobject readdoc;
char *readdoc() 
{
STREAMAddProgressCallback($self, Progressor);
return(STREAMReadDocument(NULL, $self));
}


/* write a line to a stream */
int writeln(const char *Line) {return(STREAMWriteLine(Line, $self));}

/* write 'inlen' bytes to a stream */
int write(const char *indata, int inlen) {return(STREAMWriteBytes($self, indata, inlen));}

/* check if any bytes are waiting to be read */
int queued() {return(STREAMCountWaitingBytes($self));}

/* flush any bytes held in stream buffers */
void flush() {STREAMFlush($self);}

/* get stream file pointer position */
unsigned long tell() {return((unsigned long) STREAMTell($self));}

/* seek to 'offset' from start of file */
long seek(long offset, int whence=SEEK_SET) {return(STREAMSeek($self, (uint64_t) offset, whence));}

/* change file extension of file associated with stream */
int extn(const char *NewExtn) {return(FileChangeExtension($self->Path, NewExtn));}

/* rename file associated with stream */
int rename(const char *NewPath) {return(rename($self->Path, NewPath));}

/* change owner of file associated with stream */
int chown(const char *NewOwner) {return(FileChOwner($self->Path, NewOwner));}

/* change group of file associated with stream */
int chgrp(const char *NewGroup) {return(FileChGroup($self->Path, NewGroup));}

/* read all data from the current stream and copy it to file 'Dest' */
int copy(const char *Dest) { return(STREAMCopy($self, Dest)); }

/* return path/url associated with the current stream */
const char *path() {return($self->Path);}

/* return filename associated with the current stream */
const char *basename() {return(GetBasename($self->Path));}

/* return the total size of the document associated with the current stream, if known */
size_t size() {return($self->Size);}

/* return number of bytes read so far */
size_t bytesRead() {return($self->BytesRead);}

/* return number of bytes written so far */
size_t bytesWritten() {return($self->BytesWritten);}

/* returns true if stream is associated with a tty */
int isatty() {return(isatty($self->in_fd));}

/* get a value that's set on the current stream */
const char *getvalue(const char *ValName) {return(STREAMGetValue($self,ValName));}

/* set a value on the current stream */
void setvalue(const char *ValName, const char *Value) {return(STREAMSetValue($self,ValName, Value));}

/* wait for the string 'String' to occur in a stream. Optionally send 'Reply' */
int expect(const char *String, const char *Reply="") {return(STREAMExpectAndReply($self, String, Reply)); }

/* wait for silence on a stream */
int silence(int wait=0) {return(STREAMExpectSilence($self, wait)); }


/* startTLS. This will start SSL/TLS communications on a stream */
int startTLS()
{
switch ($self->Type)
{
case STREAM_TYPE_UNIX_ACCEPT: return(DoSSLServerNegotiation($self, 0)); break;
case STREAM_TYPE_TCP_ACCEPT: return(DoSSLServerNegotiation($self, 0)); break;
case STREAM_TYPE_UNIX: DoSSLClientNegotiation($self, 0); break;
case STREAM_TYPE_TCP: DoSSLClientNegotiation($self, 0); break;
}

return(FALSE);
}

/* close a stream */
void close() 
{
STREAMFlush($self);
if ($self->in_fd != $self->out_fd) close($self->in_fd);
close($self->out_fd);
}

}



/* 
A POLL_IO object can watch a number of streams for activity. You use it like this: 

P=stream.POLL_IO()
P:add(S1)
P:add(S2)

ActiveS=P:select()
if ActiveS == S1 then ProcessStream(S1) end
if ActiveS == S2 then ProcessStream(S2) end

*/



typedef struct
{
ListNode *Streams;
} POLL_IO;

%extend POLL_IO {
POLL_IO () {
POLL_IO *Item;

Item=(POLL_IO *) calloc(1,sizeof(POLL_IO));
Item->Streams=ListCreate();
}

~POLL_IO () {
ListDestroy($self->Streams,NULL);
free($self);
}

void add(STREAM *S) {
ListAddItem($self->Streams, S);
}

STREAM *select() {
return(STREAMSelect($self->Streams, 0));
}
}
