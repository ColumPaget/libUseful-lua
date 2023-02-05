/*
Copyright (c) 2019 Colum Paget <colums.projects@googlemail.com>
* SPDX-License-Identifier: GPL-3.0
*/

/*
this module implements functions related to a process.
*/


%module process
%{
#define _GNU_SOURCE
#include <unistd.h>
#include <signal.h>
#include <sys/wait.h>
#include "libUseful-4/Process.h"
#include "libUseful-4/SpawnPrograms.h"
#include "libUseful-4/GeneralFunctions.h"
#include "libUseful-4/Errors.h"
#include "libUseful-4/LibSettings.h"
#include "libUseful-4/FileSystem.h"


typedef struct
{
  STREAM *S;
  pid_t pid;
  char *Command;
  STREAM *PtyS;
} PROCESS;


const char *LibUsefulLuaGetValue(const char *Name)
{
if (strcasecmp(Name,"LibUseful-lua:Version")==0) return(VERSION);
return(LibUsefulGetValue(Name));
}

uint8_t *Signals=NULL;


void LUL_HandleSignal(int sig)
{
int result;

#ifndef _NSIG
#define _NSIG 64
#endif

if (! Signals) Signals=(uint8_t *) calloc(_NSIG, sizeof(uint8_t));

Signals[sig]=1;
signal(sig, LUL_HandleSignal);
}

void WatchSignal(int sig)
{
struct sigaction sa;

memset(&sa, 0, sizeof(struct sigaction));
sa.sa_handler=LUL_HandleSignal;

sigaction(sig, &sa, NULL);
}


bool CheckSignal(int sig)
{
int result;

if (! Signals) return(FALSE);
LUL_HandleSignal(FALSE);
result=Signals[sig];
Signals[sig]=0;

if (result) return(TRUE);
return(FALSE);
}


STREAM *sfork(const char *Config) 
{ 
return(STREAMSpawnFunction(NULL, NULL, Config));
}

#define LibUsefulLua_Process_GetUser() (LookupUserName(getuid()))
#define LibUsefulLua_Process_GetGroup() (LookupGroupName(getgid()))

#define Wait(pid) (waitpid(pid, NULL, 0))

bool ChildExited(long pid)
{
if (pid==-1) return(FALSE); 
if (waitpid((pid_t) pid, NULL, WNOHANG)==pid) return(TRUE);
return(FALSE);
}

long ChildCollect(long pid)
{
return(waitpid((pid_t) pid, NULL, WNOHANG));
}

char *ChildStatus(long pid, int flags)
{
char *RetStr=NULL;
int Status;

if (pid < 1) RetStr=CopyStr(RetStr, "no such pid"); 
else
{
  pid=waitpid((pid_t) pid, &Status, flags);
  if (pid==-1) RetStr=CopyStr(RetStr, "no such pid");
  else if (pid==0) RetStr=CopyStr(RetStr, "running");
  else if (WIFEXITED(Status)) RetStr=FormatStr(RetStr, "exit:%d", WEXITSTATUS(Status));
  else if (WIFSIGNALED(Status)) RetStr=FormatStr(RetStr, "signal:%d", WTERMSIG(Status));
  else RetStr=CopyStr(RetStr, "exit:unknown");
}

return(RetStr);
}

#define ChildStatusNoWait(pid) (ChildStatus((pid), (WNOHANG)))
#define ChildStatusWait(pid) (ChildStatus((pid), (0)))

%}




%init
%{
/* As lua uses garbage collection, and strings passed out of libUseful may not be*/
/* freed within libuseful before reuse, so we cannot use StrLen caching*/
LibUsefulSetValue("StrLenCache", "n");
%}





/* define POSIX signal names. This looks strange, but it's mapping process.SIGHUP in the lua world, to SIGHUP in C */
/* note that these must be used as process.SIGHUP rather than just SIGHUP in lua */
%constant float  SIGHUP=SIGHUP; /* Hangup.  */
%constant float  SIGINT=SIGINT; /* Interactive attention signal.  */
%constant float  SIGQUIT=SIGQUIT; /* Quit.  */
%constant float  SIGILL=SIGILL; /* Illegal instruction.  */
%constant float  SIGTRAP=SIGTRAP; /* Trace/breakpoint trap.  */
%constant float  SIGABRT=SIGABRT; /* Abnormal termination.  */
%constant float  SIGFPE=SIGFPE; /* Erroneous arithmetic operation.  */
%constant float  SIGKILL=SIGKILL; /* Killed.  */
%constant float  SIGBUS=SIGBUS; /* Bus error.  */
%constant float  SIGSEGV=SIGSEGV; /* Invalid access to storage.  */
%constant float  SIGSYS=SIGSYS; /* Bad system call.  */
%constant float  SIGPIPE=SIGPIPE; /* Broken pipe.  */
%constant float  SIGALRM=SIGALRM; /* Alarm clock.  */
%constant float  SIGTERM=SIGTERM; /* Termination request.  */
%constant float  SIGURG=SIGURG; /* Urgent data is available at a socket.  */
%constant float  SIGSTOP=SIGSTOP; /* Stop, unblockable.  */
%constant float  SIGTSTP=SIGTSTP; /* Keyboard stop.  */
%constant float  SIGCONT=SIGCONT; /* Continue.  */
%constant float  SIGCHLD=SIGCHLD; /* Child terminated or stopped.  */
%constant float  SIGTTIN=SIGTTIN; /* Background read from control terminal.  */
%constant float  SIGTTOU=SIGTTOU; /* Background write to control terminal.  */
%constant float  SIGPOLL=SIGPOLL; /* Pollable event occurred (System V).  */
%constant float  SIGXCPU=SIGXCPU; /* CPU time limit exceeded.  */
%constant float  SIGXFSZ=SIGXFSZ; /* File size limit exceeded.  */
%constant float  SIGVTALRM=SIGVTALRM; /* Virtual timer expired.  */
%constant float  SIGPROF=SIGPROF; /* Profiling timer expired.  */
%constant float  SIGWINCH=SIGWINCH; /* Window size change (4.3 BSD, Sun).  */
%constant float  SIGUSR1=SIGUSR1; /* User-defined signal 1.  */
%constant float  SIGUSR2=SIGUSR2; /* User-defined signal 2.  */




/* process.sleep(seconds)  - sleep for 'seconds' */
int sleep(unsigned long seconds);

/* process.usleep(usec)  - sleep for 'usec' milliseconds */ 
int usleep(unsigned long usec);

/* process.chdir(dir)  - change process current directory */ 
bool chdir(const char *dir);

/* process.chroot(dir)  - chroot (jail) process, dir is optional, current directory is the default */ 
bool chroot(const char *dir=".");

/* send a signal to another process. Default signal is SIGTERM. Default process is self */
bool kill(int pid=0, int sig=SIGTERM);

/* exit with exitcode 'val' */
void exit(int val=0);

/* exit as an 'abort' */
void abort();

/* create a daemon process. This is a 'server' process that has no terminal but is visible running in 'ps ax'. */
bool demonize();

/* return current process pid */
long getpid();

/* return parent process pid */
long getppid();

/* return current process pid */
%rename(pid) getpid;
long getpid();

/* return parent process pid */
%rename(ppid) getppid;
long getppid();

/* return current process user id */
%rename(uid) getuid;
long getuid();

/* return current process group id */
%rename(gid) getgid;
long getgid();

%rename(user) LibUsefulLua_Process_GetUser;
const char *LibUsefulLua_Process_GetUser();

%rename(group) LibUsefulLua_Process_GetGroup;
const char *LibUsefulLua_Process_GetGroup();

/* process.getenv(Name)   -  get an environment varible */
const char *getenv(const char *Name);

/* process.setenv(Name, Value)   - set an environment varible */
%rename(setenv) xsetenv;
bool xsetenv(const char *Name, const char *Value);



/*
process.configure(Config)   configure the current process. 'Config' is a space separated list of key-value pairs. Numeric values can be
set in 'metric' format, so for example 'mem=100M' would set the memory resource limit to 100 meg.

config values are:

prio       - set scheduler priority of current process 
priority   - set scheduler priority of current process 
nice       - set 'nice' value of current process (another way of expressing priority)

newpgroup  - start a new process group with this processes pid as the process group id
setsid     - start a new session with this processes pid as the session id

daemon     - daemonize current process (will result in a change in the process ID to be different from the one returned by xfork etc)
demon      - daemonize current process (will result in a change in the process ID to be different from the one returned by xfork etc)

mem        - set memory resource limit of current process
fsize      - set file size resource limit of current process
files      - set max number of files resource limit
coredumps  - set max coredump size in bytes
procs      - set max processes FOR THE CURRENT PROCESSES USER

outnull    - send stdout to /dev/null (usually used with programs launched via process.spawn or managed processes using the process.PROCESS object)
innull     - join stdin to /dev/null (usually used with programs launched via process.spawn or managed processes using the process.PROCESS object)
pty        - create a psuedo-terminal, so the process thinks it's interacting with a user at a real terminal. For use with programs managed via the process.PROCESS object)

chroot     - chroot. If just 'chroot=dir' is passed then process will chdir to 'dir' and then chroot, if just 'chroot' it will chroot in current directory

For example:

process.configure("daemon mem=10M files=50 prio=5")
*/

%rename(configure) ProcessApplyConfig;
void ProcessApplyConfig(const char *Config);


/* enhanced 'fork' command. Returns pid of child process, unless you are the child process, where it returns 0 */
/* Config can be made up of options as described for process.configure */
long xfork(const char *Config="");

/* like 'xfork' but returns a stream so we can talk to the forked process */
STREAM *sfork(const char *Config="");

/* spawn is like os.exec, but the process is spawned in the background, and runs independantly */
/* it will continue to run even if our process exits */
/* Config can be made up of options as described for process.configure */
%rename(spawn) Spawn;
long Spawn(const char *Command, const char *Config="");


/*  process.childExited(pid)    - Check if a SPECIFIC child exited. */
%rename(childExited) ChildExited;
bool ChildExited(long pid);

/* process.collect(pid) - Check if a child exited, return pid of any that did. */
/* We can pass pid to get a specific child, or default is 'any child' (-1) */
%rename(collect) ChildCollect;
long ChildCollect(long pid=-1);


/* 
The following two functions return a string that describes the exit status of
the child process. This string can be:

'no such pid'      - no child with that pid exists
'running'          - child is still running and hasn't exited
'exit:<status>'    - exit status of a process that exited normally by calling 'exit'
'signal:<signal>'  - process was killed with signal  
'exit:unknown'     - something weird happened. Process exited but we don't know why.
*/

/* get exit status of a child process, but don't wait if it hasn't exited */
%rename(childStatus) ChildStatusNoWait;
%newobject childStatus;
char *ChildStatusNoWait(long pid);

/* wait for child to exit and return it's status */
%rename(waitStatus) ChildStatusWait;
%newobject waitStatus;
char *ChildStatusWait(long pid);


/* Wait for a child to exit. returns pid of any that did */
/* have to use rename here to prevent name class with existing wait function */
%rename(wait) Wait;
long Wait(long pid=-1);

/*  process.cwd()   - get current directory */
%rename(cwd) get_current_dir_name;
char *get_current_dir_name();

/*  process.homeDir()  - get home dir of user the process is running as */
%rename(homeDir) GetCurrUserHomeDir;
char *GetCurrUserHomeDir();

/*  process.switchUser(UserName)  - switch user the current process is running as. You'll probably need to be root to do this */
/*  if wanting to switch both user and group, then do process.switchGroup first */
%rename(switchUser) SwitchUser;
bool SwitchUser(const char *User);

/*  process.switchGroup(GroupName)  - switch group the current process is running as. You'll probably need to be root to do this */
%rename(switchGroup) SwitchGroup;
bool SwitchGroup(const char *Group);

/*  process.pidfile(FileName)  - write pid file. if 'FileName' is a full path, then that path will be used, else file will appear in /var/run. */
%rename(pidfile) WritePidFile;
bool WritePidFile(char *ProgName);

/* process.createLockFile(Path, timeout)  - create a lockfile. 
'timeout' is optional, it's the time to wait to get access to a lockfile if some other process has it locked. Default is '0' meaning 'forever'
*/
%rename(createLockFile) CreateLockFile;
bool CreateLockFile(char *FilePath,int Timeout=0);

/* 

process.lu_get(ValName);
process.lu_set(ValName, Value);

get/set a libUseful internal variable. Useful variables are:

LibUseful:Version     version number of libUseful library
LibUseful:BuildTime   build time of libUseful library

LibUseful-lua:Version version number of libUseful-lua 

You can also set some global values that effect behavior of libUseful functions

HTTP:Debug            set to 'Y' to get debugging output from HTTP connections
HTTP:NoCookies        disable HTTP cookies
HTTP:NoCompress       disable HTTP compression
HTTP:NoRedirect       do not automatically handle HTTP redirects
HTTP:NoCache          tell HTTP servers not to serve a cached copy of a document
HTTP:UserAgent        set HTTP User-Agent string for this process

SSL:Level             set minimum SSL/TLS level. can be one of ''
SSL:PermittedCiphers  set list of permitted SSL/TLS ciphers
SSL:DHParams-File     if using Diffie-Helman Perfect-Forward-Secrecy then set path to the 'params' file

*/


%rename(lu_get) LibUsefulLuaGetValue;
const char *LibUsefulLuaGetValue(const char *Name);

%rename(lu_set) LibUsefulSetValue;
void LibUsefulSetValue(const char *Name, const char *Value);

/*
 process.sigwatch(sig) 
 watch a signal, this means it will interrupt system calls, and we will catch it and update the list of
 recieved signals which we can query with 'sigcheck'
*/

%rename(sigwatch) WatchSignal;
void WatchSignal(int sig=0);


/*
 process.sigcheck(sig) 
 check if we received a signal
*/
%rename(sigcheck) CheckSignal;
bool CheckSignal(int sig=0);



/* PROCESS object. This allows you to launch a program and talk to it using the PROCESS:send() method. 'Config' takes the same values as for Spawn or xfork, described above, plus a couple of extras discussed below.

e.g.

proc=process.PROCESS("ssh myhost", "pty")
proc:send("halt\r\n")


the process object comes with a 'get_stream' function that allows you to get the stream to talk to the process, and then you can use standard stream functions to talk to it instead of 'proc:send()'

e.g.

S=proc.get_stream()
S:readln("hello\n");
str=S:readln()

it's also possible to launch a process with a seperate stream thats the 'tty' or the process. This is used with commands that ask for passwords on their controlling tty. This can be distinct from their stdin/stdout. For instance:

cat file.encrypted | openssl enc -d -aes-256-cbc > file.txt

will ask for a password, but not on it's stdout, as that is being written to file.txt. Instead if will connect to it's controlling terminal. 

The command:

proc=process.PROCESS("open ssl enc -a", "ptystream")

will produce a proc object that has a seperate stream for the controlling tty, allowing us to talk to it like so:

PtyS=proc:get_pty()
PtyS:readto(':')  -- read password request
PtyS:writeln(password.."\n")

S=proc:get_stream()
S:writeln("data to encrypt")
S:commit()
encrypted=S:readdoc()


Finally the proc:pid() method returns the pid of the process, the proc:pause() method pauses execution, proc:continue() restarts it, and proc:stop() kills the process.

*/

typedef struct
{
} PROCESS;


/* create a new  process object */
%extend PROCESS {
PROCESS (const char *Command, const char *Config="")
{
PROCESS *item=NULL;
STREAM *S, *PtyS;
int SeperatePty=FALSE;
char *Tempstr=NULL, *Token=NULL;
const char *ptr;

ptr=GetToken(Config, "\\S", &Token, GETTOKEN_QUOTES);
while (ptr)
{
if (strcasecmp(Token, "ptystream")==0) SeperatePty=TRUE;
else Tempstr=MCatStr(Tempstr, Token, " ", NULL);
ptr=GetToken(ptr, "\\S", &Token, GETTOKEN_QUOTES);
}


if (StrValid(Command)) 
{
  if (SeperatePty) STREAMSpawnCommandAndPty(Command, Tempstr, &S, &PtyS);
  else S=STREAMSpawnCommand(Command, Config);
}
else S=STREAMSpawnFunction(NULL, NULL, Config);

if (S)
{
item=(PROCESS *) calloc(1, sizeof(PROCESS));
item->S=S;
item->PtyS=PtyS;
item->pid=atoi(STREAMGetValue(S, "PeerPid"));
item->Command=CopyStr(NULL, Command);
}

Destroy(Tempstr);
Destroy(Token);

return(item);
}



/* destroy  process object */
~PROCESS()
{
STREAMClose($self->S);
Destroy($self->Command);
free($self);
}


/* return underlying stream object so we can do file/stream operations on it*/
STREAM* get_stream()
{
return($self->S);
}

STREAM* get_pty()
{
return($self->PtyS);
}

/* return pid of managed process */
double pid()
{
return((double) $self->pid);
}



/* kill managed process */
void stop()
{
kill($self->pid, SIGKILL);
}

/* kill managed process group owned by this process. This works for processes created
by calling PROCESS with the 'newpgroup' option */
void stop_pgroup()
{
kill(0 - ($self->pid), SIGKILL);
}


/* pause managed process */
void pause()
{
kill($self->pid, SIGSTOP);
}


/* unpause managed process */
void continue()
{
kill($self->pid, SIGCONT);
}

/*send a string to the managed process on it's stdin */
void send(const char *line)
{
STREAMWriteBytes($self->S, line, StrLen(line));
STREAMFlush($self->S);
}


/* write bytes */
void write(const char *bytes, int len)
{
STREAMWriteBytes($self->S, bytes, len);
}

void flush()
{
STREAMFlush($self->S);
}

/* read a line (Ending in '\n') from the managed process on its stdout */
%newobject readln;
char *readln()
{
return(STREAMReadLine(NULL, $self->S));
}


/* return the command-line of the managed process */
%newobject command;
char *command()
{
return(CopyStr(NULL, $self->Command));
}


/* return the path to the executable of the managed process */
%newobject exec_path;
char *exec_path()
{
char *Path=NULL;

GetToken($self->Command, "\\S", &Path, GETTOKEN_QUOTES);

return(Path);
}


/* return the basename (program name) of the executable of the managed process */
%newobject exec_basename;
char *exec_basename()
{
char *Path=NULL, *Tempstr=NULL;

GetToken($self->Command, "\\S", &Tempstr, GETTOKEN_QUOTES);
Path=CopyStr(Path, GetBasename(Tempstr));

Destroy(Tempstr);

return(Path);
}



}
