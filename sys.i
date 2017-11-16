/*
This module provides functions that return various system information.
*/

%module sys
%{
#include "libUseful-3/GeneralFunctions.h"
#include "libUseful-3/Errors.h"

//mapped to sys_(name) to prevent clashes e.g. with 'hostname'
#define sys_uptime() (OSSysInfoLong(OSINFO_UPTIME))
#define sys_totalmem() (OSSysInfoLong(OSINFO_TOTALMEM))
#define sys_freemem() (OSSysInfoLong(OSINFO_FREEMEM))
#define sys_type() (OSSysInfoString(OSINFO_TYPE))
#define sys_hostname() (OSSysInfoString(OSINFO_HOSTNAME))
#define sys_release() (OSSysInfoString(OSINFO_RELEASE))
#define sys_arch() (OSSysInfoString(OSINFO_ARCH))
#define sys_tmpdir() (OSSysInfoString(OSINFO_TMPDIR))
%}


/* sys.uptime   - return uptime in seconds as a number */
%rename(uptime) sys_uptime;
unsigned long sys_uptime();

/* sys.totalmem   - return total system memory in bytes */
%rename(totalmem) sys_totalmem;
unsigned long sys_totalmem();

/* sys.totalmem   - return free memory in bytes */
%rename(freemem) sys_freemem;
unsigned long sys_freemem();

/* sys.arch   - returns system architecture */
%rename(arch) sys_arch;
const char * sys_arch();

/* sys.release   - returns system operating system release */
%rename(release) sys_release;
const char * sys_release();

/* sys.hostname   - returns system hostname */
%rename(hostname) sys_hostname;
const char * sys_hostname();

/* sys.type   - returns operating system type */
%rename(type) sys_type;
const char * sys_type();

/* sys.tmpdir   - returns system temporary directory */
%rename(tmpdir) sys_tmpdir;
const char * sys_tmpdir();





