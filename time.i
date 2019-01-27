/*
This module provides functions that return various system information.
*/

%module time
%{
#include "libUseful-4/GeneralFunctions.h"
#include "libUseful-4/Errors.h"
#include "libUseful-4/Time.h"

#define time_time() (GetTime(0))
#define time_centitime() (GetTime(TIME_CENTISECS))
#define time_millitime() (GetTime(TIME_MILLISECS))
#define time_tosecs(fmt, str, zone) (DateStrToSecs(fmt, str, zone))
#define time_formatsecs(fmt, secs, zone) (GetDateStrFromSecs(fmt, secs, zone))
#define time_format(fmt, zone) (GetDateStrFromSecs(fmt, GetTime(0), zone))
#define time_tzoffset(zone) (TimezoneOffset(zone))
%}

/* return time as seconds since 1 jan 1970 */
%rename(secs) time_time;
unsigned long time_time();

/* return time as centiseconds since 1 jan 1970 */
%rename(centisecs) time_centitime;
unsigned long time_centitime();

/* return time as milliseconds since 1 jan 1970 */
%rename(millisecs) time_millitime;
unsigned long time_millitime();

/* return time as milliseconds since 1 jan 1970 */
%rename(tzoffset) time_tzoffset;
long time_tzoffset(const char *zone);


/* convert date-time str 'str' to seconds using format 'fmt'. The format string is as 'strptime' and strftime' */
%rename(tosecs) time_tosecs;
unsigned long time_tosecs(const char *fmt, const char *str, const char *zone="");

/* format date expressed as seconds since epoch using format string format 'fmt'. The format string is as 'strptime' and strftime' */
%rename(formatsecs) time_formatsecs;
const char *time_formatsecs(const char *fmt, unsigned long secs, const char *zone="");

/* format current time using format string format 'fmt'. The format string is as 'strptime' and strftime' */
%rename(format) time_format;
const char *time_format(const char *fmt, const char *zone="");

/* return time as seconds since 1 jan 1970 */
%rename(secs) time_time;
unsigned long time_time();


