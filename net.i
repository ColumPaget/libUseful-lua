/*
Copyright (c) 2019 Colum Paget <colums.projects@googlemail.com>
* SPDX-License-Identifier: GPL-3.0
*/

/*

This module implements various functions related to TCP/IP networking. However, it does not provide actual
network client functionality, which is done via the 'stream' module instead

*/


%module net
%{
#include "libUseful-4/Socket.h"
#include "libUseful-4/IPAddress.h"
#include "libUseful-4/inet.h"
#include "libUseful-4/ConnectionChain.h"
#include "libUseful-4/Errors.h"
#include "libUseful-4/LibSettings.h"
#include "libUseful-4/URL.h"

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



char *reformatURL(const char *URL) 
{
char *Tempstr=NULL;
URL_INFO_STRUCT *info;

if (! StrValid(URL)) return(NULL);
info=parseURL(URL);
if (! info) return(NULL);
Tempstr=MCopyStr(Tempstr, info->type,"://",NULL);
if (StrValid(info->user)) 
{
  Tempstr=MCatStr(Tempstr, info->user, ":", info->pass, "@", NULL);
}
Tempstr=CatStr(Tempstr, info->host);
if (StrValid(info->port)) Tempstr=MCatStr(Tempstr, ":", info->port, NULL);
Tempstr=MCatStr(Tempstr, "/", info->path, NULL);

if (StrValid(info->args)) Tempstr=MCatStr(Tempstr, "?", info->args, NULL);

return(Tempstr);
}



%}




%init
%{
/* As lua uses garbage collection, and strings passed out of libUseful may not be*/
/* freed within libuseful before reuse, so we cannot use StrLen caching*/
LibUsefulSetValue("StrLenCache", "n");
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
%newobject parseURL;
URL_INFO_STRUCT *parseURL(const char *URL);


%newobject reformatURL;
char *reformatURL(const char *URL);

/* net.lookupIP(hostname)   - return IP address associated with hostname */
%rename(lookupIP) LookupHostIP;
char *LookupHostIP(const char *Host);

/* net.lookupHost(IPAddress)   - return hostname associated with IP address */
%rename(lookupHost) IPStrToHostName;
char *IPStrToHostName(const char *);

/* net.IsIP4Address(string)   - returns 'true' if string is a valid IP4 address */
bool IsIP4Address(const char *Str);

/* net.IsIP6Address(string)   - returns 'true' if string is a valid IP6 address */
bool IsIP6Address(const char *Str);

/* net.IsIPAddress(string)   - returns 'true' if string is a either an IP4 or IP6 address */
bool IsIPAddress(const char *);

/* net.interfaceIP("eth0")   - returns primary IP address of a network interface (in this case eth0) */
%rename(interfaceIP) GetInterfaceIP;
char *GetInterfaceIP(const char *Interface);

/* net.externalIP()   - returns external IP address of the system by conversing with various external servers */
%newobject externalIP;
char *externalIP();

/* net.setProxy(string)  - set a proxy chain to be used for all connections by this process. A proxy chain is a 
list of proxy urls separated by '|'. Proxy urls have the form <protocol>://<user>:<password>@<host>:<port>. 
<user> and <password> are optional when using open proxies, in which case the url is <protocol>://@<host>:<port>.
The '//' syntax can also be ommited if desired.

proxy protocols are:

https
socks4
socks5
ssh        - use ssh -w method to connect to remote host/port
sshtunnel  - use ssh -L method to connect to remote host/port
sshproxy   - use ssh -D method to connect to remote host/port

e.g.   net.setProxy("sshtunnel://localhost|socks5:27.88.101.50:1080")  - setup ssh tunnel through localhost, and then through that use a socks5 proxy to finally access the destination

*/
%rename(setProxy) SetGlobalConnectionChain;
bool SetGlobalConnectionChain(const char *Chain);



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
SERVER (const char *URL, const char *Args="") {
SERVER *Item;

Item=(SERVER *) calloc(1,sizeof(SERVER));
Item->S=STREAMServerNew(URL, Args);
return(Item);
}

~SERVER () {
if ($self->S) STREAMClose($self->S);
free($self);
}



/* 
  setup TLS/SSL. 'Certificate' and 'Key' are paths to the Certificate and Key file respectively 
  you call this before 'accept', and when connections are accepted, TLS is activated on the new 
  connection
*/
bool setupTLS(const char *Certificate, const char *Key)
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




/* return port server is bound to. If you bind tls::0 then use this to figure out assigned port */
int port()
{
int Port=-1;

if (! $self->S) return(-1);
GetSockDetails($self->S->in_fd, NULL, &Port, NULL, NULL);
return(Port);
}



STREAM *get_stream()
{
return($self->S);
}


}
