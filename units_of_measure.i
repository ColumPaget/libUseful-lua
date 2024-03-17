/*
Copyright (c) 2019 Colum Paget <colums.projects@googlemail.com>
* SPDX-License-Identifier: GPL-3.0
*/

/*

This module provides functions that convert strings with metric suffixes (n,m,k,M,G,T,P) into double values
and visa-versa,


*/


%module units_of_measure
%{
#ifdef HAVE_LIBUSEFUL_5_LIBUSEFUL_H
#include "libUseful-5/libUseful.h"
#else
#include "libUseful-4/libUseful.h"
#endif


/* 
convert a number to a string with a suffix
Here 'base' is 1024 for IEC/power of two suffixes, as used in measuring bytes (kB, MB)
or 1000 for metrix, as used in measuring physical values (mg, km, MJ etc)
*/
char *to_si_unit(double Value, int Base, int Precision)
{
return(CopyStr(NULL, ToSIUnit(Value, Base, Precision)));
}

/* convert a number to IEC/power-of-two suffixes as used in measuring bytes */
char *to_iec(double Value, int Precision) 
{
return(CopyStr(NULL, ToIEC(Value, Precision)));
}

/* convert a number to metric suffixes as used in measuring weights/distances etc */
char *to_metric(double Value, int Precision) 
{
return(CopyStr(NULL, ToMetric(Value, Precision)));
}

/* convert from suffixes to a number, Base is 1024 for power-of-two, 1000 for metric */
double from_si_unit(const char *Value, int Base)
{
return(FromSIUnit(Value, Base));
}

/* convert from IEC/power-of-two suffixes as used in measuring bytes, to a number */
double from_iec(const char *Value)
{
return(FromIEC(Value, 0));
}

/* convert a from metric suffixes as used in measuring weights/distances etc, to a number */
double from_metric(const char *Value)
{
return(FromMetric(Value, 0));
}


%}



%init
%{
/* As lua uses garbage collection, and strings passed out of libUseful may not be*/
/* freed within libuseful before reuse, so we cannot use StrLen caching*/
LibUsefulSetValue("StrLenCache", "n");
%}

%newobject to_si_unit;
char *to_si_unit(double Value, int Base, int Precision);

%newobject to_iec;
char *to_iec(double Value, int Precision);

%newobject to_metric;
char *to_metric(double Value, int Precision);

double from_si_unit(const char *Value, int Base);

double from_iec(const char *Value);

double from_metric(const char *Value);


