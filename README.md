libUseful-lua is a collection of lua modules that provide function bindings for the libUseful library, and also for a number of standard Posix functions. The aim is to provide a framework for linux system programming in lua. libUseful-lua provides methods and objects for file access, TCP/IP networking, terminal control, hash functions, syslog logging,  mounting and unmounting filesystems, and much else. 

libUseful-lua requires at least libUseful-3.2 to be installed on a system. You can get it from

https://github.com/ColumPaget/libUseful

Building the modules requires SWIG: http://www.swig.org. Once they're built you can install them on systems without SWIG, SWIG is only needed for compiling libUseful-lua


if libUseful and swig are installed then compiling libUseful-lua should be as simple as

	./configure --with-lua-includes=/usr/include/lua --with-lua-lib=/usr/lib/ --with-lua-modules=/usr/lib/lua/5.3
	make 
	make install


The options to configure will need to be set as appropirate for your system. The configure script will try to guess the --with-lua-includes and --with-lua-lib values if they are not supplied, however the --with-lua-modules option is mandatory.

--with-lua-modules sets the directory that the compiled modules will be installed in. It should be one of the directories in lua's CPATH variable. You can view the value of this variable with:

	lua -e "print(package.cpath)"

Basic documentation for the functions and objects in libUseful-lua is currently in the .i interface files for each module. Likely manpages or other better documentation will appear in time, but I wanted to get something out there ("Release early and release often", they said).

Some example programs can be found in the 'examples' directory. You need to install libUseful-lua before using these

This is the initial release, so expect some bugs and maybe some changes going forwards
