/*
Copyright (c) 2019 Colum Paget <colums.projects@googlemail.com>
* SPDX-License-Identifier: GPL-3.0
*/

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


The terminal class also supports 'terminal bars' which can be a bar of text or a 
menu-in-one-line, and terminal menus which are multi-line menus.

*/


%module terminal
%{
#include "libUseful-4/Terminal.h"
#include "libUseful-4/TerminalMenu.h"
#include "libUseful-4/TerminalChoice.h"
#include "libUseful-4/TerminalBar.h"
#include "libUseful-4/Errors.h"

#define term_strlen(s) (TerminalStrLen(s))
#define term_strtrunc(s, len) (TerminalStrTrunc(CopyStr(NULL, (s)), (len)))
#define term_format(s) (TerminalFormatStr(NULL,(s),NULL))
#define term_stdputs(s) (TerminalPutStr((s), NULL))
#define term_utf8(l) (TerminalSetUTF8(l))

char *LUL_term_strip_ctrl(char *Input)
{
return(TerminalStripControlSequences(NULL, Input));
}


typedef struct
{
int Flags;
STREAM *S;
} TERM;

%}


/* returns a strlen after all tilde/unicode/quoted formatting has been done */
%rename(strlen) term_strlen;
int term_strlen(const char *Str);

%newobject strtrunc;
%rename(strtrunc) term_strtrunc;
char *term_strtrunc(const char *Str, int Len);


/* formats a tilde-markup string to a printable string */
%newobject format;
%rename(format) term_format;
char *term_format(const char *Str);

/* writes a tilde formatted string to stdout, without bothering with a 'TERM' object */
%rename(puts) term_stdputs;
void term_stdputs(const char *Str);


%newobject stripctrl;
%rename(stripctrl) LUL_term_strip_ctrl;
char *LUL_term_strip_ctrl(char *Input);


/* 
set UTF-8 capabilities. This applies to all terminals.  'level' can be:

  0  -  no UTF-8 support
  1  -  UTF-8 support for values < 0x800
  2  -  UTF-8 support for values < 0x10000
  3  -  UTF-8 support for values < 0x10FFFF
*/
%rename(utf8) term_utf8;
void term_utf8(int level);


/* From here on in everything relates to a TERM object */
typedef struct
{
STREAM *S;
} TERM;


typedef struct
{
int button;
int x;
int y;
} TMouseEvent;

%extend TERM {

/* Create a terminal object */
TERM(STREAM *S=NULL, const char *Config=NULL)
{
TERM *Item;

Item=(TERM *) calloc(1,sizeof(TERM));
if (S) Item->S=S;
else Item->S=STREAMFromDualFD(0,1);
STREAMSetTimeout(Item->S,0);
if (StrValid(Config)) TerminalSetup(Item->S, Config);
else
{
  Item->Flags=TERM_RAWKEYS;
  TerminalInit(Item->S, Item->Flags | TERM_SAVEATTRIBS);
}
return(Item);
}

/* You would never call this, it's called automatically when the object goes out of scope */
~TERM()
{
TerminalReset($self->S);
free($self);
}

/* return underlying stream object so we can do file/stream operations on it*/
STREAM* get_stream()
{
return($self->S);
}

/*set read timeout for this terminal object */
void timeout(int Timeout)
{
STREAMSetTimeout($self->S, Timeout);
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

/* prevent flushing output to screen */
void cork() { STREAMSetFlushType($self->S, FLUSH_FULL, 0, 0); }

/* flush any bytes held in internal buffers (uncork) */
void flush() {STREAMFlush($self->S);}


/* return terminal width */
int width()
{
int wid, len;

TerminalGeometry($self->S, &wid, &len);
return(wid);
}

/* return terminal length/height */
int length()
{
int wid, len;

TerminalGeometry($self->S, &wid, &len);
return(len);
}

/* return terminal length/height */
int height()
{
int wid, len;

TerminalGeometry($self->S, &wid, &len);
return(len);
}

/* Clear the screen */
void clear() { TerminalCommand(TERM_CLEAR_SCREEN, 0, 0, $self->S); }

/* reset terminal config */
void reset() {TerminalReset($self->S);}

void close() {TerminalReset($self->S); STREAMClose($self->S);}

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


/* move the cursor to x, y */
void scrollingregion(int x, int y) {TerminalCommand(TERM_SCROLL_REGION, x, y, $self->S);}


/* 
get a character or keystroke. For standard characters this returns a string containing that single character.
For keystrokes that are expressed by escape codes, this returns a key name.

*/

const char *getc() 
{
int inchar;

inchar=TerminalReadChar($self->S);
if (inchar==STREAM_TIMEOUT) return("");
if (inchar==STREAM_NODATA) return("");

return(TerminalTranslateKeyCode(inchar));
}

/* put a character 'Char'. Char can be a unicode value */
void putc(int Char) {TerminalPutChar(Char, $self->S);}

/* put a string. This method supports 'tilde' format strings (see above) */
void puts(const char *Str) {TerminalPutStr(Str, $self->S);}

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
char *prompt(const char *Prompt, const char *Config="", const char *Text=NULL) 
{
char *Str=NULL;
if (StrLen(Text) > 0) Str=CopyStr(Str, Text);
return(TerminalReadPrompt(Str, Prompt, TerminalTextConfig(Config), $self->S));
}

%newobject mouse;
TMouseEvent *mouse()
{
TMouseEvent *Ev, *New;

Ev=TerminalGetMouse($self->S);
if (Ev==NULL) return(NULL);
New=(TMouseEvent *) calloc(1, sizeof(TMouseEvent));
New->button=Ev->button;
New->x=Ev->x;
New->y=Ev->y;

return(New);
}

/* create a terminal bar for the current terminal */
%newobject bar;
TERMBAR *bar(const char *Text, const char *Config="") {return(TerminalBarCreate($self->S, Config, Text));}

/* create a terminal menu for the current terminal */
%newobject menu;
TERMMENU *menu(int x, int y, int wid, int high) {return(TerminalMenuCreate($self->S, x, y, wid, high));}

/* create a horizontal terminal menu (or 'choice') for the current terminal */
%newobject choice;
TERMCHOICE *choice(const char *Config) {return(TerminalChoiceCreate($self->S, Config));}



/* Send escape sequence to raise an xterm-compatible terminal in the window stack */
#ifdef XtermRaise
void xterm_raise() {return(XtermRaise($self->S));}
#endif

/* Send escape sequence to lower an xterm-compatible terminal in the window stack */
#ifdef XtermLower
void xterm_lower() {return(XtermLower($self->S));}
#endif

/* Send escape sequence to iconify an xterm-compatible terminal */
#ifdef XtermIconify
void xterm_iconify() {return(XtermIconify($self->S));}
#endif

/* Send escape sequence to un-iconify an xterm-compatible terminal */
#ifdef XtermUnIconify
void xterm_uniconify() {return(XtermUnIconify($self->S));}
#endif

/* Send escape sequence to set an xterm-compatible terminal to fullscreen*/
#ifdef XtermFullscreen
void xterm_fullscreen() {return(XtermFullscreen($self->S));}
#endif

/* Send escape sequence to unset an xterm-compatible terminal to fullscreen*/
#ifdef XtermUnFullscreen
void xterm_unfullscreen() {return(XtermUnFullscreen($self->S));}
#endif


/* Send escape sequence to set the title of an xterm-compatible terminal*/
#ifdef XtermSetTitle
void xterm_title(const char *Title) {return(XtermSetTitle($self->S, Title));}
#endif

/* Send escape sequence to set the icon-name (title when iconified) of an xterm-compatible terminal*/
#ifdef XtermSetIconName
void xterm_icon_name(const char *Title) {return(XtermSetIconName($self->S, Title));}
#endif
}



typedef struct
{
} TERMBAR;




%extend TERMBAR {
TERMBAR(TERM *Term, const char *Text, const char *Config="")
{
return(TerminalBarCreate(Term->S, Config, Text));
}

~TERMBAR()
{
free($self);
}

%newobject prompt;
char *prompt(const char *Prompt, const char *Text=NULL) 
{
  char *Str=NULL;
  if (Text) Str=CopyStr(Str, Text);
  return(TerminalBarReadText(Str, $self, 0, Prompt));
}
}


/*

The following functions relate to vertical 'menus' operated with the arrow keys 'up' 'down' and 'enter'.

*/

typedef struct
{
int x;
int y;
int wid;
int high;
STREAM *Term;
ListNode *Options;
char *MenuAttribs;
char *MenuCursorLeft;
char *MenuCursorRight;
char *MenuPadLeft;
char *MenuPadRight;
int Flags;
char *Text;
} TERMMENU;


%extend TERMMENU {

/* Create a terminal menu object */
TERMMENU(TERM *Term, int x, int y, int wid, int high)
{
TERMMENU *Item;
Item=TerminalMenuCreate(Term->S, x, y, wid, high);
return(Item);
}

/* You would never call this, it's called automatically when the object goes out of scope */
~TERMMENU()
{
ListClear($self->Options, Destroy);
TerminalMenuDestroy($self);
}


/* Use this to alter the default colors by passing tilde-strings for 
'MenuAttribs' (which sets background and foreground for the menu) and
'SelectedAttribs' (which sets background and foreground for the selected item)
*/
void config(const char *MenuAttribs, const char *SelectedAttribs)
{
$self->MenuAttribs=CopyStr($self->MenuAttribs, MenuAttribs);
$self->MenuCursorLeft=CopyStr($self->MenuCursorLeft, SelectedAttribs);
}

void resize(int wide, int high)
{
$self->wid=wide;
$self->high=high;
}

/* clear all items out of the menu */
void clear() 
{
ListClear($self->Options, Destroy);
$self->Options->Side=NULL;
}


/*
add an item to the menu. 'str' is what will be displayed, 'id' is what will be returned 
when an item is selected. If 'id' is null or an empty string, then 'str' will be 
returned instead
*/

void add(const char *str, const char *id=NULL) 
{
if (id) ListAddNamedItem($self->Options, str, CopyStr(NULL, id));
else ListAddNamedItem($self->Options, str, NULL);

fflush(NULL);
}

void update(const char *str, const char *id=NULL)
{
ListNode *Curr;

Curr=ListGetNext($self->Options);
while (Curr)
{
  if ( StrValid(id) && StrValid(Curr->Item) && (strcmp(id, Curr->Item)==0) ) 
  {
  Curr->Tag=CopyStr(Curr->Tag, str);
  break;
  }
Curr=ListGetNext(Curr);
}

}

/* Actually draw a menu. This doesn't read keypresses or anything, just draws the menu in its current state */
void draw() {TerminalMenuDraw($self);}

/* 
Pass a keypress into the menu. Changes the selected item, if need be. Redraws the menu.
if the keypress is 'enter' then return the selected item, else return NULL
*/

%newobject onkey;
char* onkey(char *key) 
{
ListNode *Node;
Node=TerminalMenuOnKey($self, TerminalTranslateKeyStr(key));
if (Node)
{
if (Node->Item != NULL) return(CopyStr(NULL, Node->Item));
return(CopyStr(NULL, Node->Tag));
}
return(NULL);
}


/*
  get the currently focused item. This is useful with 'setpos' 
*/
%newobject curr;
char* curr() 
{
if ($self->Options->Side)
{
if ($self->Options->Side->Item != NULL) return(CopyStr(NULL, $self->Options->Side->Item));
return(CopyStr(NULL, $self->Options->Side->Tag));
}
return(NULL);
}

/*
  setpos sets the curr item. This is useful so that a menu that's been redrawn, or even been destroyed and recreated
  can be set back to the position it was at. This can be used to update a menu like this:

  Out:cork()
  Menu:clear()
  Menu:add("this") 
  Menu:add("that") 
  Menu:add("the other") 
  Menu:setpos("that")
  Out:flush()

  corking and flushing the terminal prevents the menu from 'flashing' as it's updated. This use of setpos allows 
  having menus that remember their position even if they're completely rebuilt.
*/
int setpos(const char *id)
{
ListNode *Curr;

Curr=ListGetNext($self->Options);
while (Curr)
{
  if (Curr->Item && (strcmp(id, Curr->Item)==0)) 
  {
    $self->Options->Side=Curr ;
    return(TRUE);
  }
  Curr=ListGetNext(Curr);
}

return(FALSE);
}

/*
run a menu. Read keypresses and update menu until an item is selected or 'escape' is pressed
*/

%newobject run;
char *run() 
{
ListNode *Node;

Node=TerminalMenuProcess($self);
if (Node)
{
if (Node->Item != NULL) return(CopyStr(NULL, Node->Item));
return(CopyStr(NULL, Node->Tag));
}

return(NULL);
}


int xpos() {return($self->x);}
int ypos() {return($self->y);}
int width() {return($self->wid);}
int height() {return($self->high);}
int length() {return($self->high);}
}





/*
    These functions relate to simple 'one line' menus that look like 

    enter choice: <yes> no

    The simples way to use these are with 'terminal.choice'.

    The 'Config' argument of the constructor function, and of 'terminal.choice', contains the following key/value configs

    
 *  prompt=        A text or prompt that preceeds the menu 
 *  options=       A comma-separated list of menu options
 *  choices=       Equivalent to 'options='
 *  x=             Position the menu at terminal column 'x'. Without x and/or y the menu will be on the current line
 *  y=             Position the menu at terminal row 'y'. Without x and/or y the menu will be on the current line
 *  select-left=   Text to the left of a currently selected item. Defaults to '<'
 *  select-right=  Text to the right of a currently selected item. Defaults to '>'
 *  pad-left=      Text to the left of an unselected item. Defaults to ' '
 *  pad-right=     Text to the right of an unselected item. Defaults to ' '
 *

  So, for example:

    terminal.choice("prompt='choose: ' options='life,a job,a career,a family,something else');
*/

typedef struct
{
int x;
int y;
int wid;
int high;
STREAM *Term;
ListNode *Options;
char *MenuAttribs;
char *MenuCursorLeft;
char *MenuCursorRight;
char *MenuPadLeft;
char *MenuPadRight;
int Flags;
char *Text;
} TERMCHOICE;


%extend TERMCHOICE {

/* Create a terminal menu object */
TERMCHOICE(TERM *Term, const char *Config)
{
TERMCHOICE *Item;
Item=TerminalChoiceCreate(Term->S, Config);
return(Item);
}

/* You would never call this, it's called automatically when the object goes out of scope */
~TERMCHOICE()
{
TerminalChoiceDestroy($self);
}


/* Actually draw a menu. This doesn't read keypresses or anything, just draws the menu in its current state */
void draw() {TerminalChoiceDraw($self);}

/* 
Pass a keypress into the menu. Changes the selected item, if need be. Redraws the menu.
if the keypress is 'enter' then return the selected item. If the user presses 'escape' return null
else return ""
*/

%newobject onkey;
char* onkey(char *key) 
{
return(TerminalChoiceOnKey(NULL, $self, TerminalTranslateKeyStr(key)));
}



/*
run a menu. Read keypresses and update menu until an item is selected or 'escape' is pressed
*/

%newobject run;
char *run() 
{
return(TerminalChoiceProcess(NULL, $self));
}


}
