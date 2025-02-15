/*
Copyright (c) 2019 Colum Paget <colums.projects@googlemail.com>
* SPDX-License-Identifier: GPL-3.0
*/

/*

This module provides some wrapper functions around the syslog system call. You use it like:

syslog.warn("Something went wrong at line %d", lineno);

other than 'warn' the log-levels 'emerg', 'alert', 'crit', 'error', 'notice', 'info', and 'debug' are available

*/


%module syslog
%{
#include <syslog.h>

#include "libUseful-5/libUseful.h"

#define open(name) (openlog((name), (LOG_PID), (LOG_USER)))
#define emerg(fmt, ...) (syslog(LOG_EMERG,fmt, __VA_ARGS__))
#define alert(fmt, ...) (syslog(LOG_ALERT,fmt, __VA_ARGS__))
#define crit(fmt, ...) (syslog(LOG_CRIT,fmt, __VA_ARGS__))
#define error(fmt, ...) (syslog(LOG_ERR,fmt, __VA_ARGS__))
#define warn(fmt, ...) (syslog(LOG_WARNING,fmt, __VA_ARGS__))
#define notice(fmt, ...) (syslog(LOG_NOTICE,fmt, __VA_ARGS__))
#define info(fmt, ...) (syslog(LOG_INFO,fmt, __VA_ARGS__))
#define debug(fmt, ...) (syslog(LOG_DEBUG,fmt, __VA_ARGS__))
%}



%init
%{
/* As lua uses garbage collection, and strings passed out of libUseful may not be*/
/* freed within libuseful before reuse, so we cannot use StrLen caching*/
LibUsefulSetValue("StrLenCache", "n");
%}


void open(const char *arg);

%varargs(10,char *arg = NULL) emerg;
void emerg(const char *format, ...);
%varargs(10,char *arg = NULL) alert;
void alert(const char *format, ...);
%varargs(10,char *arg = NULL) crit;
void crit(const char *format, ...);
%varargs(10,char *arg = NULL) error;
void error(const char *format, ...);
%varargs(10,char *arg = NULL) warn;
void warn(const char *format, ...);
%varargs(10,char *arg = NULL) notice;
void notice(const char *format, ...);
%varargs(10,char *arg = NULL) info;
void info(const char *format, ...);
%varargs(10,char *arg = NULL) debug;
void debug(const char *format, ...);

