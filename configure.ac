
AC_INIT()

AC_PROG_CC
AC_LANG_C
AC_PROG_MAKE_SET
AC_PROG_INSTALL
AC_HEADER_STDC
AC_SUBST([LUA_INCLUDE_DIR])
AC_SUBST([LUA_MODULES_DIR])

LUA_INCLUDE_DIR=""
LUA_MODULES_DIR=""
AC_PATH_PROG([LUA_EXE_PATH], [lua],,)

AC_ARG_WITH([lua-includes], [  --with-lua-includes       path to directory containing liblua .h headers],LUA_INCLUDE_DIR=$withval)
AC_ARG_WITH([lua-libs], [  --with-lua-libs       path to directory containing liblua libs],LUA_LIBS_DIR=$withval)
AC_ARG_WITH([lua-modules], [  --with-lua-modules       path to directory in which to install modules files],LUA_MODULES_DIR=$withval)


if test "$LUA_INCLUDE_DIR" = ""
then
LUA_INCLUDE_DIR=`dirname $LUA_EXE_PATH | sed "s/bin$/include/"`
echo "INC: $LUA_INCLUDE_DIR"
fi


if test "$LUA_LIBS_DIR" = ""
then
LUA_LIBS_DIR=`dirname $LUA_EXE_PATH | sed "s/bin$/lib/"`
echo "LIB: $LUA_LIBS_DIR"
fi


if test "$LUA_INCLUDE_DIR" != ""
then
	CFLAGS="$CFLAGS -I$LUA_INCLUDE_DIR"
fi

if test "$LUA_LIBS_DIR" != ""
then
	CFLAGS="$CFLAGS -L$LUA_LIBS_DIR"
fi

if test "$LUA_MODULES_DIR" = ""
then
	LUA_MODULES_DIR=`$LUA_EXE_PATH -e "print(package.cpath)" | cut -d ? -f 1`
fi


echo "MODS: $LUA_MODULES_DIR"


AC_OUTPUT(Makefile)
