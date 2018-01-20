/*

This module implements various functions related to TCP/IP networking. However, it does not provide actual
network client functionality, which is done via the 'stream' module instead

*/


%module net
%{
#include "libUseful-3/Socket.h"
#include "libUseful-3/inet.h"
#include "libUseful-3/ConnectionChain.h"
#include "libUseful-3/Errors.h"
#include "libUseful-3/URL.h"

#define externalIP() (GetExternalIP(NULL))

typedef struct
{
STREAM *S;
char *SSLCertificate;
char *SSLKey;
} SERVER;

typedef struct
{
char *type;  //protocol
char *host;  //hostname
char *port;  
char *path;
char *args; //http style args (things following ? in a url)
char *user;
char *pass;
} URL_INFO_STRUCT;


URL_INFO_STRUCT *parseURL(const char *URL)
{
URL_INFO_STRUCT *Info;

Info=(URL_INFO_STRUCT *) calloc(1, sizeof(URL_INFO_STRUCT));
ParseURL(URL, &(Info->type), &(Info->host), &(Info->port), &(Info->user), &(Info->pass), &(Info->path), &(Info->args));
return(Info);
}


%}



typedef struct
{
char *type;  //protocol
char *host;  //hostname
char *port;  
char *path;
char *args; //http style args (things following ? in a url)
char *user;
char *pass;
} URL_INFO_STRUCT;



/* net.parseURL(URL)   - return a structure containing broken-down parts of a URL (see URL_INFO_STRUCT above)*/
%newobject *parseURL;
URL_INFO_STRUCT *parseURL(const char *URL);


/* net.lookupIP(hostname)   - return IP address associated with hostname */
%rename(lookupIP) LookupHostIP;
char *LookupHostIP(const char *Host);

/* net.lookupHost(IPAddress)   - return hostname associated with IP address */
%rename(lookupHost) IPStrToHostName;
char *IPStrToHostName(const char *);

/* net.IsIP4Address(string)   - returns 'true' if string is a valid IP4 address */
int IsIP4Address(const char *Str);

/* net.IsIP6Address(string)   - returns 'true' if string is a valid IP6 address */
int IsIP6Address(const char *Str);

/* net.IsIPAddress(string)   - returns 'true' if string is a either an IP4 or IP6 address */
int IsIPAddress(const char *);

/* net.interfaceIP("eth0")   - returns primary IP address of a network interface (in this case eth0) */
%rename(interfaceIP) GetInterfaceIP;
char *GetInterfaceIP(const char *Interface);

/* net.externalIP()   - returns external IP address of the system by conversing with various external servers */
%newobject *externalIP;
char *externalIP();

%rename(setProxy) SetGlobalConnectionChain;
int SetGlobalConnectionChain(const char *Chain);


/* 
SERVER provides a network server object. You use it like: 

net.SERVER("tcp::80")


*/

typedef struct
{
STREAM *S;
char *SSLCertificate;
char *SSLKey;
} SERVER;

%extend SERVER {
SERVER (const char *URL) {
SERVER *Item;

Item=(SERVER *) calloc(1,sizeof(SERVER));
Item->S=STREAMServerInit(URL);
return(Item);
}

~SERVER () {
if ($self->S) STREAMClose($self->S);
free($self);
}

int setupTLS(const char *Certificate, const char *Key)
{
if (! SSLAvailable()) return(FALSE);
if (! StrValid(Certificate)) return(FALSE);
if (! StrValid(Key)) return(FALSE);
$self->SSLCertificate=CopyStr($self->SSLCertificate, Certificate);
$self->SSLKey=CopyStr($self->SSLKey, Key);
return(TRUE);
}



STREAM *accept()
{
STREAM *S;

S=STREAMServerAccept($self->S);
if (StrValid($self->SSLCertificate))
{
STREAMSetValue(S,"SSL_CERT_FILE",$self->SSLCertificate);
STREAMSetValue(S,"SSL_KEY_FILE",$self->SSLKey);
DoSSLServerNegotiation(S, 0);
}

return(S);
}

}
