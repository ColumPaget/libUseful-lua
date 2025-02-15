/*
Copyright (c) 2019 Colum Paget <colums.projects@googlemail.com>
* SPDX-License-Identifier: GPL-3.0
*/

/*
This module provides functions that return various system information.
*/

%module time
%{
#include "libUseful-5/libUseful.h"

#define time_time() (GetTime(0))
#define time_centitime() (GetTime(TIME_CENTISECS))
#define time_millitime() (GetTime(TIME_MILLISECS))
#define time_tosecs(fmt, str, zone) (DateStrToSecs( (fmt), (str), (zone) ))
#define time_formatsecs(fmt, secs, zone) (GetDateStrFromSecs( (fmt), (secs), (zone) ))
#define time_format(fmt, zone) (GetDateStrFromSecs( (fmt), GetTime(0), (zone) ))
#define time_tzoffset(zone) (TimezoneOffset(zone))
#define time_sleep(secs) (sleep(secs))
#define time_msleep(msecs) (usleep(msecs * 1000))
#define time_usleep(usecs) (usleep(usecs))
#define time_calendar_csv(mon, year) (CalendarFormatCSV(NULL, (mon), (year)))
#define time_tzconvert(time, from, to) (TimeZoneConvert(NULL, (time), (from), (to)))
%}




%init
%{
/* As lua uses garbage collection, and strings passed out of libUseful may not be*/
/* freed within libuseful before reuse, so we cannot use StrLen caching*/
LibUsefulSetValue("StrLenCache", "n");
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
long time_tosecs(const char *fmt, const char *str, const char *zone="");

/* format date expressed as seconds since epoch using format string format 'fmt'. The format string is as 'strptime' and strftime' */
%rename(formatsecs) time_formatsecs;
const char *time_formatsecs(const char *fmt, unsigned long secs, const char *zone="");

/* format current time using format string format 'fmt'. The format string is as 'strptime' and strftime' */
%rename(format) time_format;
const char *time_format(const char *fmt, const char *zone="");

/* return time as seconds since 1 jan 1970 */
%rename(secs) time_time;
unsigned long time_time();

/* sleep for secs seconds*/
%rename(sleep) time_sleep;
void time_sleep(int secs);

/* sleep for msecs milliseconds */
%rename(msleep) time_msleep;
void time_msleep(long msecs);

/* sleep for umsecs nanoseconds */
%rename(usleep) time_usleep;
void time_usleep(long usecs);

/*
* Convert a string describing a duration to seconds. 
* String in the form "1d 5h 30m" where m=minutes h=hours d=days w=weeks y=year Y=year (year always 365 days)
*/
%rename(parse_duration) ParseDuration;
int ParseDuration(const char *Str);

/*
* format a string using the substitutions %w %d %h %m %s for weeks, days, hours, minutes and seconds
* if any of the substututions are missing, then their value is carried over to the next highest substitution
* so if there's no '%d', then the 'days' part will be counted in '%h' (hours) 
* or if that is missing in '%m' (mins) or '%s' (seconds) 
*/
%rename(format_duration) FormatDuration;
const char *FormatDuration(const char *Fmt, time_t Duration);

/* 
* convert Time from timezone 'SrcZone' to 'DstZone'
* time must be in format "%Y/%m/%d %H:%M:%S"
*/
%rename(tz_convert) time_tzconvert;
%newobject tz_convert;
char *time_tzconvert(const char *Time, const char *SrcZone, const char *DstZone);

/* return the offset in seconds of "TimeZone" */
%rename(tz_offset) TimezoneOffset;
long TimezoneOffset(const char *TimeZone);

/*given a year, return TRUE if it's a leap year, FALSE otherwise*/
%rename(is_today) IsToday;
int IsToday(unsigned int day, unsigned int month, unsigned int year);


/*given a year, return TRUE if it's a leap year, FALSE otherwise*/
%rename(is_leap_year) IsLeapYear;
int IsLeapYear(unsigned int year);

/*return number of days in month (month range 1-12, months < 1 are in previous years and >12 are in subsequent years) */
%rename(days_in_month) GetDaysInMonth;
int GetDaysInMonth(int Month, int Year);

/*
* produce a csv of days in month. each line is a week. Any dates starting
* with '-' are in the previous month to the one requested, and any 
* started with '+' are in the next month
*/
%rename(calendar_csv) time_calendar_csv;
%newobject calendar_csv;
char *time_calendar_csv(unsigned int Month, unsigned int Year);

