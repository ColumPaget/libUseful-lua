/*
this module implements functions related to a process.
*/


%module process
%{

#define LUL_VERSION "2.2"

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


const char *LibUsefulLuaGetValue(const char *Name)
{
if (strcasecmp(Name,"LibUseful-lua:Version")==0) return(LUL_VERSION);
return(LibUsefulGetValue(Name));
}

#define ChildExited(pid) (waitpid(pid, NULL, WNOHANG))
#define Wait(pid) (waitpid(pid, NULL, 0))
%}

/* process.sleep(seconds)  - sleep for 'seconds' */
int sleep(unsigned long seconds);

/* process.usleep(usec)  - sleep for 'usec' milliseconds */ 
int usleep(unsigned long usec);

/* process.chdir(dir)  - change process current directory */ 
int chdir(const char *dir);

/* process.chroot(dir)  - chroot (jail) process, dir is optional, current directory is the default */ 
int chroot(const char *dir=".");

/* send a signal to another process. Default signal is SIGTERM. Default process is self */
int kill(int pid=0, int sig=SIGTERM);

/* exit with exitcode 'val' */
void exit(int val=0);

/* exit as an 'abort' */
void abort();

/* create a daemon process. This is a 'server' process that has no terminal but is visible running in 'ps ax'. */
int demonize();

/* return current process pid */
long getpid();


/* return parent process pid */
long getppid();

/* process.getenv(Name)   -  get an environment varible */
const char *getenv(const char *Name);

/* process.setenv(Name, Value)   - set an environment varible */
%rename(setenv) xsetenv;
int xsetenv(const char *Name, const char *Value);

/* enhanced 'fork' command. Returns pid of child process, unless you are the child process, where it returns 0 */
/* Config can be made up of options as described for process.config */
long xfork(char *Config="");

/*  process.CildExited(pid)    - Check if a child exited, return pid of any that did. */
/* We can pass pid to get a specific child, or default is 'any child' */
%rename(childExited) ChildExited;
long ChildExited(long pid=-1);

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
int SwitchUser(const char *User);

/*  process.switchGroup(GroupName)  - switch group the current process is running as. You'll probably need to be root to do this */
%rename(switchGroup) SwitchGroup;
int SwitchGroup(const char *Group);

/*  process.pidfile(FileName)  - write pid file. if 'FileName' is a full path, then that path will be used, else file will appear in /var/run. */
%rename(pidfile) WritePidFile;
int WritePidFile(char *ProgName);

/* createLockFile(Path, timeout)  - create a lockfile. 
'timeout' is optional, it's the time to wait to get access to a lockfile if some other process has it locked. Default is '0' meaning 'forever'
*/
%rename(createLockFile) CreateLockFile;
int CreateLockFile(char *FilePath,int Timeout=0);

/*
process.configure(Config)   configure the current process. 'Config' is a space separated list of key-value pairs. Numeric values can be
set in 'metric' format, so for example 'mem=100M' would set the memory resource limit to 100 meg.

config values are:

prio       - set scheduler priority of current process 
priority   - set scheduler priority of current process 
nice       - set 'nice' value of current process (another way of expressing priority)

daemon     - daemonize current process (will result in a change in the process ID)
demon      - daemonize current process (will result in a change in the process ID)

mem        - set memory resource limit of current process
fsize      - set file size resource limit of current process
files      - set max number of files resource limit
coredumps  - set max coredump size in bytes
procs      - set max processes FOR THE CURRENT PROCESSES USER

chroot     - chroot. If just 'chroot=dir' is passed then process will chdir to 'dir' and then chroot, if just 'chroot' it will chroot in current directory

For example:

process.configure("daemon mem=10M files=50 prio=5")
*/

%rename(configure) ProcessApplyConfig;
void ProcessApplyConfig(const char *Config);

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


