CC = gcc
CFLAGS=-g -O2 -I/opt/lua-5.3.4/include -L/opt/lua-5.3.4/lib
LIBS=-lUseful 
LUA_MODULES_DIR=/usr/local/lib/lua/5.3/

MODS=stream.so terminal.so filesys.so process.so net.so syslog.so hash.so sys.so time.so strutil.so dataparser.so oauth.so rawdata.so securemem.so
all: $(MODS)

stream.so: stream_wrap.o
	$(CC) $(CFLAGS) -shared -o stream.so stream_wrap.o $(LIBS)
	
stream_wrap.o: stream_wrap.c
	$(CC) $(CFLAGS) -c stream_wrap.c -o  stream_wrap.o

stream_wrap.c: stream.i
	swig -lua -o stream_wrap.c stream.i

terminal.so: terminal_wrap.o
	$(CC) $(CFLAGS) -shared -o terminal.so terminal_wrap.o $(LIBS)
	
terminal_wrap.o: terminal_wrap.c
	$(CC) $(CFLAGS) -c terminal_wrap.c -o  terminal_wrap.o

terminal_wrap.c: terminal.i
	swig -lua -o terminal_wrap.c terminal.i

filesys.so: filesys_wrap.o
	$(CC) $(CFLAGS) -shared -o filesys.so filesys_wrap.o $(LIBS)
	
filesys_wrap.o: filesys_wrap.c
	$(CC) $(CFLAGS) -c filesys_wrap.c -o  filesys_wrap.o

filesys_wrap.c: filesys.i
	swig -lua -o filesys_wrap.c filesys.i

process.so: process_wrap.o
	$(CC) $(CFLAGS) -shared -o process.so process_wrap.o $(LIBS)
	
process_wrap.o: process_wrap.c
	$(CC) $(CFLAGS) -c process_wrap.c -o  process_wrap.o

process_wrap.c: process.i
	swig -lua -o process_wrap.c process.i

net.so: net_wrap.o
	$(CC) $(CFLAGS) -shared -o net.so net_wrap.o $(LIBS)
	
net_wrap.o: net_wrap.c
	$(CC) $(CFLAGS) -c net_wrap.c -o  net_wrap.o

net_wrap.c: net.i
	swig -lua -o net_wrap.c net.i

syslog.so: syslog_wrap.o
	$(CC) $(CFLAGS) -shared -o syslog.so syslog_wrap.o $(LIBS)
	
syslog_wrap.o: syslog_wrap.c
	$(CC) $(CFLAGS) -c syslog_wrap.c -o  syslog_wrap.o

syslog_wrap.c: syslog.i
	swig -lua -o syslog_wrap.c syslog.i

hash.so: hash_wrap.o
	$(CC) $(CFLAGS) -shared -o hash.so hash_wrap.o $(LIBS)
	
hash_wrap.o: hash_wrap.c
	$(CC) $(CFLAGS) -c hash_wrap.c -o  hash_wrap.o

hash_wrap.c: hash.i
	swig -lua -o hash_wrap.c hash.i

sys.so: sys_wrap.o
	$(CC) $(CFLAGS) -shared -o sys.so sys_wrap.o $(LIBS)
  
sys_wrap.o: sys_wrap.c
	$(CC) $(CFLAGS) -c sys_wrap.c -o  sys_wrap.o

sys_wrap.c: sys.i
	swig -lua -o sys_wrap.c sys.i

time.so: time_wrap.o
	$(CC) $(CFLAGS) -shared -o time.so time_wrap.o $(LIBS)
  
time_wrap.o: time_wrap.c
	$(CC) $(CFLAGS) -c time_wrap.c -o  time_wrap.o

time_wrap.c: time.i
	swig -lua -o time_wrap.c time.i

strutil.so: strutil_wrap.o
	$(CC) $(CFLAGS) -shared -o strutil.so strutil_wrap.o $(LIBS)
  
strutil_wrap.o: strutil_wrap.c
	$(CC) $(CFLAGS) -c strutil_wrap.c -o  strutil_wrap.o

strutil_wrap.c: strutil.i
	swig -lua -o strutil_wrap.c strutil.i


dataparser.so: dataparser_wrap.o
	$(CC) $(CFLAGS) -shared -o dataparser.so dataparser_wrap.o $(LIBS)
  
dataparser_wrap.o: dataparser_wrap.c
	$(CC) $(CFLAGS) -c dataparser_wrap.c -o  dataparser_wrap.o

dataparser_wrap.c: dataparser.i
	swig -lua -o dataparser_wrap.c dataparser.i


oauth.so: oauth_wrap.o
	$(CC) $(CFLAGS) -shared -o oauth.so oauth_wrap.o $(LIBS)
  
oauth_wrap.o: oauth_wrap.c
	$(CC) $(CFLAGS) -c oauth_wrap.c -o  oauth_wrap.o

oauth_wrap.c: oauth.i
	swig -lua -o oauth_wrap.c oauth.i

rawdata.so: rawdata_wrap.o
	$(CC) $(CFLAGS) -shared -o rawdata.so rawdata_wrap.o $(LIBS)
  
rawdata_wrap.o: rawdata_wrap.c
	$(CC) $(CFLAGS) -c rawdata_wrap.c -o  rawdata_wrap.o

rawdata_wrap.c: rawdata.i
	swig -lua -o rawdata_wrap.c rawdata.i

securemem.so: securemem_wrap.o
	$(CC) $(CFLAGS) -shared -o securemem.so securemem_wrap.o $(LIBS)
  
securemem_wrap.o: securemem_wrap.c
	$(CC) $(CFLAGS) -c securemem_wrap.c -o  securemem_wrap.o

securemem_wrap.c: securemem.i
	swig -lua -o securemem_wrap.c securemem.i


install: $(MODS)
	mkdir -p $(DESTDIR)$(LUA_MODULES_DIR)
	cp *.so $(DESTDIR)$(LUA_MODULES_DIR)

clean: 
	rm -f *.o *.so *_wrap.c
