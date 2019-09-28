/*
Copyright (c) 2019 Colum Paget <colums.projects@googlemail.com>
* SPDX-License-Identifier: GPL-3.0
*/


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


Here's a list of URL types that STREAM will accept:

/tmp/myfile.txt                          file
mmap:/tmp/myfile.txt                     memory mapped file
tty:/dev/ttyS0:38400                     open a serial device, in this case at 38400 baud
udp:192.168.2.1:53                       udp network connection
tcp:192.168.2.1:25                       tcp network connection
ssl:192.168.2.1:443                      tcp network connection with encryption
tls:192.168.2.1:443                      tcp network connection with encryption
unix:/tmp/socket                         unix socket
unixdgram:/tmp/socket                    unix datagram socket
http:user:password@www.google.com        http network connection
https:www.google.com                     https network connection
cmd:cat /etc/hosts                       run command 'cat /etc/hosts' and read/write to/from it
ssh:192.168.2.1:1022/cat /etc/hosts      ssh connect, running the command 'cat /etc/hosts'



For 'file' streams the second argument is a list of charcters with the following meanings

c     create file
r     read only
w     write only
a     append 
+     make read-only, append or write-only be read-write
E     raise an error if this file fails to open
F     follow symlinks. Without this flag an error is raised when a symlink is opened.
l     lock/unlock file on each read
L     lock/unlock file on each write
i     allow this file to be inherited across an exec (default is close-on-exec)
t     make a unique temporary file name. the file path must be a mktemp style template, with the last six characters being 'XXXXXX'
S     file contents are sorted
z     compress/uncompress with gzip

for 'http' and 'https' streams the second argument consists first of a list of characters with the following meanints:

r     GET method
w     POST method

and then the following options:

content-type     content type for use with POST method
content-length   content length for use with POST method
oauth=<name>     use an oauth method that's been set up under 'name'



This module also supplies a POLL_IO object, which stream objects can be added to, and which can then be used to watch 
multiple stream objects for activity

*/


%module stream
%{
#include "libUseful-4/Stream.h"
#include "libUseful-4/FileSystem.h"
#include "libUseful-4/Http.h"
#include "libUseful-4/Expect.h"
#include "libUseful-4/Errors.h"
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

~STREAM()
{
STREAMClose($self);
}

/* read a line from a stream */
%newobject readln;
char *readln() {return(STREAMReadLine(NULL, $self));} 

/* read a byte from a stream, lua will treat this as a number */
int readbyte() {return(STREAMReadChar($self));}

/* read a character from a stream, lua will treat this as a string */
char getch() {return(STREAMReadChar($self));}
char readch() {return(STREAMReadChar($self));}

/* return a byte, but leave it in the string to be read again. Lua will treat it as a number */
int peek() {return(STREAMPeekChar($self));}

/* return a byte, but leave it in the string to be read again. Lua will treat it as a string */
char peekch() {return(STREAMPeekChar($self));}

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

int lock() {return(STREAMLock($self, LOCK_EX|LOCK_NB));}
int waitlock() {return(STREAMLock($self, LOCK_EX));}

int unlock() {return(STREAMLock($self, LOCK_UN));}

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

void truncate(long size) {STREAMTruncate(size);}


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

/*
 Only currently used with HTTP PUT/POST to declare that all data has been uploaded and that the server should 
 process it and send a reply
*/
int commit() {return(STREAMCommit($self));}


/* close a stream */
void close() 
{
STREAMFlush($self);
if ($self->in_fd != $self->out_fd) close($self->in_fd);
close($self->out_fd);

$self->in_fd=-1;
$self->out_fd=-1;
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

return(Item);
}

~POLL_IO () {
ListDestroy($self->Streams,NULL);
free($self);
}

/* add a stream to the POLL_IO */
void add(STREAM *S) {
ListAddItem($self->Streams, S);
}

/* remove a stream from the POLL_IO. YOU MUST DO THIS BEFORE CLOSING THE STREAM */
void delete(STREAM *S) {
ListDeleteItem($self->Streams, S);
}

/* wait for activity from one of the streams, and return it once it happens */
STREAM *select(int centisecs) {
struct timeval tv;

tv.tv_sec=centisecs / 100;
tv.tv_usec=(centisecs - (tv.tv_sec * 100)) * 10000;
return(STREAMSelect($self->Streams, &tv));
}
}
