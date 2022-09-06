/*
Copyright (c) 2019 Colum Paget <colums.projects@googlemail.com>
* SPDX-License-Identifier: GPL-3.0
*/

%module oauth
%{
#include "libUseful-4/OAuth.h"
#include "libUseful-4/Errors.h"
%}



%extend OAUTH {
OAUTH (const char *Type, const char *Name, const char *ClientID="", const char *ClientSecret="", const char *Scopes="", const char *RefreshURL="")
{
return(OAuthCreate(Type, Name, ClientID, ClientSecret, Scopes, RefreshURL));
}

void set(const char *VarName, const char *Value) {SetVar($self->Vars, VarName, Value);}
bool load(const char *Name="", const char *Path="") {return(OAuthLoad($self, Name, Path));}
bool save(const char *Path) {return(OAuthSave($self, Path));}
bool stage1(const char *URL) {return(OAuthStage1($self, URL));}
bool finalize(const char *URL) {return(OAuthFinalize($self, URL));}
bool refresh(const char *URL) {return(OAuthRefresh($self, URL));}
bool listen(int Port, const char *URL) {return(OAuthListen($self, Port, URL, OAUTH_STDIN));}
const char *name() {return($self->Name);}
const char *access_token() {return($self->AccessToken);}
const char *refresh_token() {return($self->RefreshToken);}
const char *auth_url() {return($self->VerifyURL);}
}
