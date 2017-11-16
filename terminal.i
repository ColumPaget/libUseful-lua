%module terminal
%{
#include "libUseful-3/Terminal.h"
#include "libUseful-3/Errors.h"

#define format(s) (TerminalFormatStr(NULL,s))
#define stdputs(s) (TerminalPutStr(s, NULL))

typedef struct
{
STREAM *S;
} TERM;
%}



%newobject format;
char *format(const char *Str);
%rename(puts) stdputs;
void stdputs(const char *Str);

typedef struct
{
STREAM *S;
} TERM;


%extend TERM {
TERM(STREAM *S=NULL)
{
TERM *Item;

Item=calloc(1,sizeof(TERM));
if (S) Item->S=S;
else Item->S=STREAMFromDualFD(0,1);
STREAMSetTimeout(Item->S,0);
TerminalInit(Item->S, TERM_RAWKEYS);
return(Item);
}


~TERM()
{
TerminalReset($self->S);
free($self);
}

int clear() { TerminalCommand(TERM_CLEAR_SCREEN, 0, 0, $self->S); }
int eraseline() {TerminalCommand(TERM_CLEAR_LINE, 0, 0, $self->S);}
int erasetoend() {TerminalCommand(TERM_CLEAR_ENDLINE, 0, 0, $self->S);}
int move(int x, int y) {TerminalCommand(TERM_CURSOR_MOVE, x, y, $self->S);}
int save() {TerminalCommand(TERM_CURSOR_SAVE, 0, 0, $self->S);}
int restore() {TerminalCommand(TERM_CURSOR_SAVE, 0, 0, $self->S);}
int scroll(int i=1) {TerminalCommand(TERM_SCROLL, 1, 0, $self->S);}
void putc(int Char) {TerminalPutChar(Char, $self->S);}
void puts(const char *Str) {TerminalPutStr(Str, $self->S);}
void flush() {STREAMFlush($self->S);}
%newobject readln;
char *readln() {return(TerminalReadText(NULL, 0, $self->S));}
%newobject prompt;
char *prompt(const char *Prompt) {return(TerminalReadPrompt(NULL, Prompt, 0, $self->S));}
%newobject bar;
TERMBAR *bar(const char *Text, const char *Config="") {return(TerminalBarCreate($self->S, Config, Text));}
}



typedef struct
{
} TERMBAR;




%extend TERMBAR {
TERMBAR()
{
}

~TERMBAR()
{
free($self);
}

%newobject prompt;
char *prompt(const char *Prompt) {return(TerminalBarReadText(NULL, $self, 0, Prompt));}
}

