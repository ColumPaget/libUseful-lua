
AC_INIT()

AC_PROG_CC
AC_LANG_C
AC_PROG_MAKE_SET
AC_PROG_INSTALL
AC_HEADER_STDC
AC_SUBST([LUA_INCLUDE_DIR])
AC_SUBST([LUA_MODULES_DIR])
AC_SUBST([SHLIB_FLAGS])

AC_MSG_CHECKING(whether fPIC compiler option is accepted)
SAVED_CFLAGS="$CFLAGS"
CFLAGS="$CFLAGS -fPIC -Werror"

AC_COMPILE_IFELSE([AC_LANG_PROGRAM([], [return 0;])],
    [AC_MSG_RESULT(yes)
     cf_fpic_supported="yes"],
    [AC_MSG_RESULT(no)
		 cf_fpic_supported="no"])

CFLAGS="$SAVED_CFLAGS"

if test "$cf_fpic_supported" = "yes"
then
CFLAGS="$CFLAGS -fPIC"
fi

LUA_INCLUDE_DIR=""
LUA_MODULES_DIR=""
AC_PATH_PROG([LUA_EXE_PATH], [lua],,)

AC_ARG_WITH([lua-includes], [  --with-lua-includes       path to directory containing liblua .h headers],LUA_INCLUDE_DIR=$withval)
AC_ARG_WITH([lua-libs], [  --with-lua-libs       path to directory containing liblua libs],LUA_LIBS_DIR=$withval)
AC_ARG_WITH([lua-modules], [  --with-lua-modules       path to directory in which to install modules files],LUA_MODULES_DIR=$withval)

AC_CHECK_LIB(Useful,GetToken,,)
cf_have_libUseful=$ac_cv_lib_Useful_GetToken
if test "$cf_have_libUseful" != "yes"
then
echo "ERROR: libUseful not found"
fi


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
