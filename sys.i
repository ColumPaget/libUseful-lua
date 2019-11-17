/*
Copyright (c) 2019 Colum Paget <colums.projects@googlemail.com>
* SPDX-License-Identifier: GPL-3.0
*/

/*
This module provides functions that return various system information.
*/

%module sys
%{
#include "libUseful-4/GeneralFunctions.h"
#ifdef HAVE_LIBUSEFUL_SYSINFO_H
#include "libUseful-4/SysInfo.h"
#endif
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
#define sys_interfaces() (OSSysInfoString(OSINFO_INTERFACES))

char *sys_ifinfo(const char *Interface)
{
char *Tempstr=NULL;

Tempstr=GetInterfaceDetails(Tempstr, Interface);
return(Tempstr);
}


char *sys_if_ip4address(const char *Interface)
{
char *Tempstr=NULL, *RetStr=NULL;

Tempstr=GetInterfaceDetails(Tempstr, Interface);
RetStr=GetNameValue(RetStr, Tempstr, "\\S", "=", "ip4address");

Destroy(Tempstr);
return(RetStr);
}


char *sys_if_ip4netmask(const char *Interface)
{
char *Tempstr=NULL, *RetStr=NULL;

Tempstr=GetInterfaceDetails(Tempstr, Interface);
RetStr=GetNameValue(RetStr, Tempstr, "\\S", "=", "ip4netmask");

Destroy(Tempstr);
return(RetStr);
}

char *sys_if_ip4broadcast(const char *Interface)
{
char *Tempstr=NULL, *RetStr=NULL;

Tempstr=GetInterfaceDetails(Tempstr, Interface);
RetStr=GetNameValue(RetStr, Tempstr, "\\S", "=", "ip4broadcast");

Destroy(Tempstr);
return(RetStr);
}

int sys_if_ip4mtu(const char *Interface)
{
char *Tempstr=NULL, *RetStr=NULL;
int val;

Tempstr=GetInterfaceDetails(Tempstr, Interface);
RetStr=GetNameValue(RetStr, Tempstr, "\\S", "=", "ip4broadcast");

Destroy(Tempstr);
Destroy(RetStr);

return(val);
}




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

/* sys.intefaces   - returns system network interfaces as a space-seperated list of names */
%rename(interfaces) sys_interfaces;
const char * sys_interfaces();

%newobject sys_if_ip4address;
%rename(ip4address) sys_if_ip4address;
char *sys_if_ip4address(const char *Interface);

%newobject sys_if_ip4netmask;
%rename(ip4netmask) sys_if_ip4netmask;
char *sys_if_ip4netmask(const char *Interface);

%newobject sys_if_ip4broadcast;
%rename(ip4broadcast) sys_if_ip4broadcast;
char *sys_if_ip4broadcast(const char *Interface);

%rename(ip4mtu) sys_if_ip4mtu;
char *sys_if_ip4mtu(const char *Interface);


/* return time as seconds since 1 jan 1970 */
%rename(time) sys_time;
unsigned long sys_time();

/* return time as centiseconds since 1 jan 1970 */
%rename(centitime) sys_centitime;
unsigned long sys_centitime();

/* return time as milliseconds since 1 jan 1970 */
%rename(millitime) sys_millitime;
unsigned long sys_millitime();


