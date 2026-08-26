/*

Basic SMTP send email functions. First a server must be set using:

smtp.set_server("tcp:mail.example.org:25", "username", "password")

The username and password can be passed as part of the URL rather than as the 2nd and 3rd argument:

smtp.set_server("tcp:username:password@mail.example.org:25")

but if both methods are used, then argument 2 and 3 will overrride the username and password supplied in the URL.

the "protocol" part of the URL can be one of the following values:

tcp      -  plain SMTP (no initial TLS but will use STARTTLS command if available)
ssl      -  use 'explicit' SSL/TLS from the get go
tls      -  use 'explicit' SSL/TLS from the get go
smtp     -  plain SMTP (no initial TLS but will use STARTTLS command if available)
smtps    -  use 'explicit' SSL/TLS from the get go


Then a mail can be sent using:

smtp.send_mail(sender, recipients, subject, mail body, flags)

e.g.:

smtp.send_mail("sender@example.org", "recipient@example.org,recipient@another.org", "this is a test", "hello there", "")

The 'flags' argument is a comma-separated list of the following values

nossl     -  don't use SSL/TLS at all, not even STARTTLS
notls     -  don't use SSL/TLS at all, not even STARTTLS
ssl       -  use explicity SSL/TLS from the get go, rather than STARTTLS
tls       -  use explicity SSL/TLS from the get go, rather than STARTTLS
nohead    -  don't add an automatic mail header to the mail body, assume the body comes with a header included 
noheader  -  don't add an automatic mail header to the mail body, assume the body comes with a header included 


If the mail body is too large to pass as a string, then it can be passed as a file:

smtp.send_file(sender, recipients, path, flags)


'send_file' assumes that the file comes with an email header, in fact that it's a complete, formatted email. This means 'the 'noheader' flag is redundant for 'send_file'.

*/


%module smtp
%{
#include "libUseful-5/libUseful.h"


int LUL_SMTPParseFlags(const char *URL, const char *Input)
{
int Flags=0;
char *Token=NULL;
const char *ptr;


if (StrValid(URL))
{
if (strncasecmp(URL, "smtps:", 6)==0) Flags |= LU_SMTP_INITIAL_TLS;
if (strncasecmp(URL, "tls:", 4)==0) Flags |= LU_SMTP_INITIAL_TLS;
if (strncasecmp(URL, "ssl:", 4)==0) Flags |= LU_SMTP_INITIAL_TLS;
}

if (StrValid(Input))
{
ptr=GetToken(Input, ",", &Token, 0);
while (ptr)
{
if (strcasecmp(Token, "notls")==0) Flags |= LU_SMTP_NOTLS;
else if (strcasecmp(Token, "nossl")==0) Flags |= LU_SMTP_NOTLS;
else if (strcasecmp(Token, "starttls")==0) Flags |= LU_SMTP_STARTTLS;
else if (strcasecmp(Token, "tls")==0) Flags |= LU_SMTP_INITIAL_TLS;
else if (strcasecmp(Token, "ssl")==0) Flags |= LU_SMTP_INITIAL_TLS;
else if (strcasecmp(Token, "nohead")==0) Flags |= LU_SMTP_NOHEADER;
else if (strcasecmp(Token, "noheader")==0) Flags |= LU_SMTP_NOHEADER;
ptr=GetToken(ptr, ",", &Token, 0);
}
}

Destroy(Token);

return(Flags);
}


int LUL_SMTPSetServer(const char *URL, const char *iUser, const char *iPassword)
{
char *User=NULL, *Password=NULL, *Proto=NULL, *Host=NULL, *Port=NULL;
char *Tempstr=NULL;

ParseURL(URL, &Proto, &Host, &Port, &User, &Password, NULL, NULL);
if (StrValid(iUser) || StrValid(iPassword)) 
{
User=QuoteCharsInStr(User, iUser, ":@");
Password=QuoteCharsInStr(Password, iPassword, ":@");
}



if (StrValid(User)) Tempstr=MCopyStr(Tempstr, Proto, ":", User, ":", Password, "@", Host, ":", Port, NULL);
else Tempstr=MCopyStr(Tempstr, Proto, ":", Host, ":", Port, NULL);

LibUsefulSetValue("SMTP:Server", Tempstr);

Destroy(User);
Destroy(Password);
Destroy(Proto);
Destroy(Host);
Destroy(Port);
Destroy(Tempstr);
}


int LUL_SMTPSendMail(const char *Sender, const char *Recipients, const char *Subject, const char *Body, const char *FlagsStr)
{
return(SMTPSendMail(Sender, Recipients, Subject, Body, LUL_SMTPParseFlags(LibUsefulGetValue("SMTP:Server"), FlagsStr)));
}

int LUL_SMTPSendMailFile(const char *Sender, const char *Recipients, const char *Path, const char *FlagsStr)
{
return(SMTPSendMailFile(Sender, Recipients, Path, LUL_SMTPParseFlags(LibUsefulGetValue("SMTP:Server"), FlagsStr)));
}

STREAM *LUL_SMTPSendConnect(const char *Sender, const char *Recipients, const char *Path, const char *FlagsStr)
{
return(SMTPConnect(Sender, Recipients, LUL_SMTPParseFlags(LibUsefulGetValue("SMTP:Server"), FlagsStr)));
}


char *LUL_SMTP_READ(STREAM *S)
{
return(SMTPRead(NULL, S));
}

%}


%init
%{
/* As lua uses garbage collection, and strings passed out of libUseful may not be*/
/* freed within libuseful before reuse, so we cannot use StrLen caching*/
LibUsefulSetValue("StrLenCache", "n");
%}

/* %newobject childStatus;*/

%rename(set_server) LUL_SMTPSetServer;
int LUL_SMTPSetServer(const char *URL, const char *iUser="", const char *iPassword="");

%rename(send_mail) LUL_SMTPSendMail;
int LUL_SMTPSendMail(const char *Sender, const char *Recipients, const char *Subject, const char *Body, const char *FlagsStr="");

%rename(send_file) LUL_SMTPSendFile;
int LUL_SMTPSendMailFile(const char *Sender, const char *Recipients, const char *Path, const char *FlagsStr="");



