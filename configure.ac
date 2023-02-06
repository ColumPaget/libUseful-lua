
AC_INIT

AC_PROG_CC
AC_LANG([C])
AC_PROG_MAKE_SET
AC_PROG_INSTALL
m4_warn([obsolete],
[The preprocessor macro `STDC_HEADERS' is obsolete.
  Except in unusual embedded environments, you can safely include all
  ISO C90 headers unconditionally.])dnl
# Autoupdate added the next two lines to ensure that your configure
# script's behavior did not change.  They are probably safe to remove.
AC_CHECK_INCLUDES_DEFAULT
AC_PROG_EGREP

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

if test "$LUA_EXE_PATH" = ""
then
	AC_PATH_PROGS([LUA_EXE_PATH], [lua5.2 lua5.3 lua5.4 lua5.5],,)
fi

AC_ARG_WITH([lua-includes], [  --with-lua-includes       path to directory containing liblua .h headers],LUA_INCLUDE_DIR=$withval)
AC_ARG_WITH([lua-libs], [  --with-lua-libs       path to directory containing liblua libs],LUA_LIBS_DIR=$withval)
AC_ARG_WITH([lua-modules], [  --with-lua-modules       path to directory in which to install modules files],LUA_MODULES_DIR=$withval)

AC_CHECK_LIB(Useful,GetToken,,)
cf_have_libUseful=$ac_cv_lib_Useful_GetToken
if test "$cf_have_libUseful" != "yes"
then
echo "ERROR: libUseful not found"
fi

AC_CHECK_HEADER([libUseful-4/SysInfo.h],AC_DEFINE(HAVE_LIBUSEFUL_SYSINFO_H),,)

AC_CHECK_LIB(Useful,STREAMShutdown,,)
cf_have_STREAMShutdown=$ac_cv_lib_Useful_STREAMShutdown
if test "$cf_have_STREAMShutdown" == "yes"
then
AC_DEFINE(HAVE_STREAM_SHUTDOWN)
else
echo "WARNING: libUseful lacks STREAMShutdown, there may be issues with programs leaking sshtunnel processes if that feature is used"
fi


if test "$LUA_INCLUDE_DIR" == ""
then
LUA_INCLUDE_CANDIDATE=`dirname $LUA_EXE_PATH | sed "s/bin$/include/"`
for INC in $LUA_INCLUDE_CANDIDATE /usr/include/lua /usr/include/lua5.2 /usr/include/lua5.3 /usr/include/lua5.4 /usr/include/lua5.5
do
	AC_CHECK_FILE([$INC/lua.h], [LUA_INCLUDE_DIR=$INC])
	if test "$LUA_INCLUDE_DIR" != ""
	then 
		break 
	fi
done
fi

if test "$LUA_LIBS_DIR" = ""
then
	LUA_LIBS_DIR=`dirname $LUA_EXE_PATH | sed "s/bin$/lib/"`
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

echo "INC: $LUA_INCLUDE_DIR"
echo "LIB: $LUA_LIBS_DIR"
echo "MODS: $LUA_MODULES_DIR"


AC_CONFIG_FILES([Makefile])
AC_OUTPUT
