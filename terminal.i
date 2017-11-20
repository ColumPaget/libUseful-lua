/*

This module provides functions related to vt100 terminal control and ansi color

You create a terminal object on stdin/stdout with:

term=terminal.TERM()


Alternatively you can do so on a socket, tty or other kind of stream by:

S=stream.STREAM("tty:/dev/ttyS0:38400")
term=terminal.TERM(S)

You can now send ANSI colored text using 'tilde' markup, like this:


term:puts("~rThis is red text~0);

Tilde commands are:

~~    output the tilde character '~'
~r    switch color to red
~R    switch background to red
~g    switch color to green
~G    switch background to green
~b    switch color to blue
~B    switch background to blue
~n    switch color to black ('night' or 'noir')
~N    switch background to black ('night' or 'noir')
~y    switch color to yellow
~Y    switch background to yellow
~m    switch color to magenta
~M    switch background to magenta
~c    switch color to cyan
~C    switch background to cyan
~e    switch to bold text
~i    switch to inverse text
~u    switch to underlined text
~<    clear to start of line
~>    clear to end of line
~0    reset all attributes (return to normal text)
~U    output a unicode character

Other functions allow clearning the screen, moving the cursor, etc.


You can also translate a tile-formatted string to a printable string using:

str=terminal.format("~y~RThis is yellow on red~0")
print(str)

*/


%module terminal
%{
#include "libUseful-3/Terminal.h"
#include "libUseful-3/Errors.h"

#define term_strlen(s) (TerminalStrLen(s))
#define term_format(s) (TerminalFormatStr(NULL,s))
#define term_stdputs(s) (TerminalPutStr(s, NULL))

typedef struct
{
int Flags;
STREAM *S;
} TERM;
%}


/* returns a strlen after all tilde formatting has been done */
%rename(strlen) term_strlen;
int term_strlen(const char *Str);

/* formats a tilde-markup string to a printable string */
%newobject format;
%rename(format) term_format;
char *term_format(const char *Str);

/* writes a tilde formatted string to stdout, without bothering with a 'TERM' object */
%rename(puts) term_stdputs;
void term_stdputs(const char *Str);



/* From here on in everything relates to a TERM object */
typedef struct
{
STREAM *S;
} TERM;


%extend TERM {

/* Create a terminal object */
TERM(STREAM *S=NULL)
{
TERM *Item;

Item=(TERM *) calloc(1,sizeof(TERM));
if (S) Item->S=S;
else Item->S=STREAMFromDualFD(0,1);
STREAMSetTimeout(Item->S,0);
Item->Flags=TERM_RAWKEYS;
TerminalInit(Item->S, Item->Flags | TERM_SAVEATTRIBS);
return(Item);
}

/* You would never call this, it's called automatically when the object goes out of scope */
~TERM()
{
TerminalReset($self->S);
free($self);
}

/* show cursor or hide it */
void showcursor()
{
  $self->Flags &= ~TERM_HIDECURSOR;
  TerminalInit($self->S, $self->Flags);
}

void hidecursor()
{
  $self->Flags |= TERM_HIDECURSOR;
  TerminalInit($self->S, $self->Flags);
}

void cork()
{
STREAMSetFlushType($self->S, FLUSH_FULL, 0, 0);
}

int width()
{
int wid, len;

TerminalGeometry($self->S, &wid, &len);
return(wid);
}

int length()
{
int wid, len;

TerminalGeometry($self->S, &wid, &len);
return(len);
}

/* Clear the screen */
void clear() { TerminalCommand(TERM_CLEAR_SCREEN, 0, 0, $self->S); }

/* Erase an entire line */
void eraseline() {TerminalCommand(TERM_CLEAR_LINE, 0, 0, $self->S);}

/* Erase from cursor to the end of the current line */
void erasetoend() {TerminalCommand(TERM_CLEAR_ENDLINE, 0, 0, $self->S);}

/* move the cursor to x, y */
void move(int x, int y) {TerminalCommand(TERM_CURSOR_MOVE, x, y, $self->S);}

/* save the cursor postion */
void save() {TerminalCommand(TERM_CURSOR_SAVE, 0, 0, $self->S);}

/* restore the cursor postion (return to last saved position */
void restore() {TerminalCommand(TERM_CURSOR_SAVE, 0, 0, $self->S);}

/* scroll the terminal by 'i' lines up or down. Positive values scroll up, negative scroll down */
void scroll(int i=1) {TerminalCommand(TERM_SCROLL, 1, 0, $self->S);}

/* 
get a character or keystroke. For standard characters this returns a string containing that single character.
For keystrokes that are expressed by escape codes, this returns a key name.

*/

const char *getc() {return(TerminalTranslateKeyCode(TerminalReadChar($self->S)));}

/* put a character 'Char'. Char can be a unicode value */
void putc(int Char) {TerminalPutChar(Char, $self->S);}

/* put a string. This method supports 'tilde' format strings (see above) */
void puts(const char *Str) {TerminalPutStr(Str, $self->S);}

/* flush any bytes held in internal buffers */
void flush() {STREAMFlush($self->S);}

/* read a line of text from the terminal 

 Config can be 
     'hidetext' - don't echo typed text 
     'stars'    - star typed text out 
     'stars+1'  - star typed text, except last typed character 

If the Config argument is not supplied, then text will be echoed as normal.
*/
%newobject readln;
char *readln(const char *Config="") {return(TerminalReadText(NULL, TerminalTextConfig(Config), $self->S));}

/* print a prompt and read a line of text from the terminal */
%newobject prompt;
char *prompt(const char *Prompt, const char *Config="") {return(TerminalReadPrompt(NULL, Prompt, TerminalTextConfig(Config), $self->S));}

/* create a terminal bar */
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

