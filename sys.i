/*
This module provides functions that return various system information.
*/

%module sys
%{
#include "libUseful-4/GeneralFunctions.h"
#include "libUseful-4/Errors.h"
#include "libUseful-4/Time.h"

//mapped to sys_(name) to prevent clashes e.g. with 'hostname'
#define sys_uptime() (OSSysInfoLong(OSINFO_UPTIME))
#define sys_totalmem() (OSSysInfoLong(OSINFO_TOTALMEM))
#define sys_freemem() (OSSysInfoLong(OSINFO_FREEMEM))
#define sys_buffermem() (OSSysInfoLong(OSINFO_BUFFERMEM))
#define sys_type() (OSSysInfoString(OSINFO_TYPE))
#define sys_hostname() (OSSysInfoString(OSINFO_HOSTNAME))
#define sys_release() (OSSysInfoString(OSINFO_RELEASE))
#define sys_arch() (OSSysInfoString(OSINFO_ARCH))
#define sys_tmpdir() (OSSysInfoString(OSINFO_TMPDIR))
#define sys_time() (GetTime(0))
#define sys_centitime() (GetTime(TIME_CENTISECS))
#define sys_millitime() (GetTime(TIME_MILLISECS))
%}


/* sys.uptime   - return uptime in seconds as a number */
%rename(uptime) sys_uptime;
unsigned long sys_uptime();

/* sys.totalmem   - return total system memory in bytes */
%rename(totalmem) sys_totalmem;
unsigned long sys_totalmem();

/* sys.totalmem   - return free memory in bytes. Unfortunately this is rendered useless on linux as */
/* the kernel will grab much free memory for caching, but it's still available for use by applications */
/* even though it no longer counts as 'free' */
%rename(freemem) sys_freemem;
unsigned long sys_freemem();

%rename(buffermem) sys_buffermem;
unsigned long sys_buffermem();


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

/* return time as seconds since 1 jan 1970 */
%rename(time) sys_time;
unsigned long sys_time();

/* return time as centiseconds since 1 jan 1970 */
%rename(centitime) sys_centitime;
unsigned long sys_centitime();

/* return time as milliseconds since 1 jan 1970 */
%rename(millitime) sys_millitime;
unsigned long sys_millitime();


