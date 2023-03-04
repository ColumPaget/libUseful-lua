/*
Copyright (c) 2019 Colum Paget <colums.projects@googlemail.com>
* SPDX-License-Identifier: GPL-3.0
*/

/*
This module provides various functions related to filesystem access

many of these functions are called just as:

filesys.rename(from, to);
*/


%module filesys
%{

#ifdef HAVE_LIBUSEFUL_5_LIBUSEFUL_H
#include "libUseful-5/libUseful.h"
#else
#include "libUseful-4/libUseful.h"
#endif

#include <glob.h>
#include <sys/stat.h>
#include <sys/statvfs.h>

typedef struct
{
glob_t Glob;
int pos;
} GLOB;


typedef struct
{
const char *type;
const char *path;
const char *name;
size_t size;
time_t mtime;
} FINFO;


#define find(File, Path) (FindFileInPath(NULL, (File), (Path)))


double fs_size(const char *Path) 
{
struct statvfs StatFS; 

statvfs(Path, &StatFS); 
return(((double) StatFS.f_blocks) * ((double) StatFS.f_frsize)); 
}

double fs_free(const char *Path) 
{
struct statvfs StatFS; 

statvfs(Path, &StatFS); 
return(((double) StatFS.f_bfree * StatFS.f_bsize) * ((double) StatFS.f_frsize)); 

}

double fs_used(const char *Path)
{
struct statvfs StatFS; 

statvfs(Path, &StatFS);
return( ((double) (StatFS.f_blocks - StatFS.f_bfree)) * ((double) StatFS.f_frsize)); 

}

#ifndef FileChMod
bool FileChMod(const char *Path, const char *Mode)
{
int perms;

perms=FileSystemParsePermissions(Mode);
if (chmod (Path, perms) ==0) return(TRUE);
return(FALSE);
}
#endif

#ifndef LUL_MakeDirPath
bool LUL_MakeDirPath(const char *Path, const char *Mode)
{
int perms;

perms=FileSystemParsePermissions(Mode);
return(MakeDirPath(Path, perms)); 
}
#endif



char *LUL_PathAddSlash(const char *Str)
{
char *Ret=NULL;
Ret=CopyStr(Ret, Str);
Ret=SlashTerminateDirectoryPath(Ret);
return(Ret);
}

/*  filesys.pathaddslash(Path)   remove a '/' from end of a path */
char *LUL_PathDelSlash(const char *Str)
{
char *Ret=NULL;
Ret=CopyStr(Ret, Str);
Ret=StripDirectorySlash(Ret);
return(Ret);
}



double LUL_FileMTime(const char *Path)
{
struct stat FStat;

stat(Path, &FStat);
return((double) FStat.st_mtime);
}

double LUL_FileSize(const char *Path)
{
struct stat FStat;

if (stat(Path, &FStat) != 0) return(0);
return((double) FStat.st_size);
}

char *LUL_FileName(const char *Path)
{
const char *ptr;
char *str=NULL;

str=CopyStr(str, GetBasename(Path));
StrRTruncChar(str, '.');
return(str);
}


char *LUL_FileExtn(const char *Path)
{
const char *ptr;
char *str=NULL;

ptr=strrchr(Path, '.');
str=CopyStr(str, ptr);
return(str);
}

char *LUL_FileDir(const char *Path)
{
char *str=NULL;

str=CopyStr(str, Path);
StrRTruncChar(str, '/');
return(str);
}



bool LUL_MkDir(const char *Path, const char *DirMask) 
{ 
if (mkdir(Path, FileSystemParsePermissions(DirMask))==0) return(TRUE); 
return(FALSE);
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
glob_t Glob;
int pos;
} GLOB;


typedef struct
{
const char *type;
const char *path;
const char *name;
size_t size;
time_t mtime;
} FINFO;


/*  filesys.basename(Path)   gets a filename (basename) from a path*/
%rename(basename) GetBasename;
const char *GetBasename(const char *Path);

/*  filesys.pathaddslash(Path)   append a '/' to a path if it doesn't already have one */
%rename(pathaddslash) LUL_PathAddSlash;
%newobject pathaddslash;
char *LUL_PathAddSlash(const char *Str);

/*  filesys.pathdelslash(Path)   remove a '/' from end of a path */
%rename(pathdelslash) LUL_PathDelSlash;
%newobject pathdelslash;
char *LUL_PathDelSlash(const char *Str);


/*  filesys.exists(Path)   return true if a filesystem object (file, directory, etc) exists at path 'Path', false otherwise */
%rename(exists) FileExists;
bool FileExists(const char *Path);


/*  filesys.extn(Path)   gets a file extension from a path*/
%rename(extn) LUL_FileExtn;
%newobject extn;
char *LUL_FileExtn(const char *Path);


/*  filesys.filename(Path)   gets a file name from a path, this is name without extension, so distinct from basename*/
%rename(filename) LUL_FileName;
%newobject filename;
char *LUL_FileName(const char *Path);


/*  filesys.dirname(Path)   gets a directory part of a path, clipping off the last part that should be the filename */
%rename(dirname) LUL_FileDir;
%newobject dirname;
char *LUL_FileDir(const char *Path);


/* filesys.mtime(Path)   get modification time of a file */
%rename(mtime) LUL_FileMTime;
int LUL_FileMTime(const char *Path);

/* filesys.size(Path)   get size of a file */
%rename(size) LUL_FileSize;
int LUL_FileSize(const char *Path);


/*  filesys.mkdir(Path)   make a directory. DirMask is the 'mode' of the created directory, and is optional */
%rename(mkdir) LUL_MkDir;
bool LUL_MkDir(const char *Path, const char *DirMask="0744");

/*  filesys.mkdirPath(Path)   make a directory, CREATING ALL PARENT DIRECTORIES AS NEEDED. 
DirMask is the 'mode' of the created directory, and is optional */
%rename(mkdirPath) LUL_MakeDirPath;
bool LUL_MakeDirPath(const char *Path, const char *DirMask="0744");

/* filesys.rmdir(path)    remove directory. Directory must be empty */
bool rmdir(const char *Path) { if (rmdir(Path)==0) return(TRUE); return(FALSE);}


/*  Path=filesys.find(File */
%newobject find;
char *find(const char *File, const char *Path);

/*   filesys.chown(Path, Owner)   change owner of a file. 'Owner' is the name, not the uid */
%rename(chown) FileChOwner;
bool FileChOwner(const char *Path, const char *Owner);

/*   filesys.chgrp(Path, Group)   change group of a file. 'Group' is the group name, not the gid */
%rename(chgrp) FileChGroup;
bool FileChGroup(const char *Path, const char *Group);

/*   filesys.chmod(Path, Mode)   change mode/permissions of a file. Perms can be a numeric value like '0666' or rwx string like 'rw-rw-rw' */
%rename(chmod) FileChMod;
bool FileChMod(const char *Path, const char *Mode);


/*  filesys.copy(src, dest)     make a copy of a file */
%rename(copy) FileCopy;
bool FileCopy(const char *oldpath, const char *newpath);

/*  filesys.copydir(src, dest)     make a recursive copy of a directory */
%rename(copydir) FileSystemCopyDir;
bool FileSystemCopyDir(const char *oldpath, const char *newpath);

%rename(touch) FileTouch;
bool FileTouch(const char *path);

/*  filesys.newExtn(Path, NewExtn)   change the ms-dos style extension of a file. Adds one to files that have no extension */
%rename(newExtn) FileChangeExtension;
bool FileChangeExtension(const char *FilePath, const char *NewExt);

/*  filesys.symlink(path, symlink)   create a symbolic link at 'symlink' pointing to file/directory at 'path' */
bool symlink(const char *oldpath, const char *newpath) { if (symlink(oldpath, newpath)==0) return(TRUE); return(FALSE);}

/*  filesys.link(path, linkname)     create a hard link at 'linkname' pointing to file/directory at 'path' */
bool link(const char *oldpath, const char *newpath) { if (link(oldpath, newpath)==0) return(TRUE); return(FALSE);}

bool unlink(const char *path) { if (unlink(path)==0) return(TRUE); return(FALSE);}

bool rename(const char *OldPath, const char *NewPath) { if (rename(OldPath, NewPath)==0) return(TRUE); return(FALSE);}


double fs_size(const char *Path); 
double fs_used(const char *Path); 
double fs_free(const char *Path); 

/*  filesys.mount(device, mountpoint, type, args)  mount a filesystem. 'args' is optional. 
If the mount point doesn't exist, it will be created.
This also (linux only) supports 'bind mounts' where 'dev' becomes a directory, and 'type' is 'bind'. 
Bind mounts are a means of mounting a directory onto another directory, so the 'mount point' directory contains the same
items as the 'dev' directory.

'args' is an optional, space-separated list of

ro       - readonly mount
rw       - read/write mount
noatime  - don't record file access times
nodiratime  - don't record file access times
noexec   - don't allow files to be executed on the mounted filesystem
nosuid   - don't honor suid binaries on the mounted filesystem
nodev    - don't honor device files on the mounted filesystem
remount  - remount if already mounted
perms    - permissions for mount-point if it has to be created
*/ 
%rename(mount) FileSystemMount;
bool FileSystemMount(const char *Dev, const char *MountPoint, const char *Type, const char *Args="");

/*  filesys.unmount(mountpoint, args)  Unmount a filesystem. 'args' is optional and can be a space seperated list of

detach   - use 'MNT_DETACH' to do a lazy unmount, which means if filesystem is busy it will be marked for unmounting and unmount when ceases to be busy
lazy     - use 'MNT_DETACH' to do a lazy unmount, which means if filesystem is busy it will be marked for unmounting and unmount when ceases to be busy
recurse  - umount any mounts under the mount point as well as the mount point. Without this the mount will fail if other mounts are active under it
rmdir    - remove mountpoint directory after unmounting
*/
%rename(unmount) FileSystemUnMount;
bool FileSystemUnMount(const char *MountPoint, const char *Args="");

/*
Object for implementing file system globbing. Works like:

Glob=filesys.GLOB("*.txt")
item=Glob:next()
while item ~= nil
do
Info=Glob:info();
print("name: " .. item)
print("type: " .. Info.type)
print("size: " .. Info.size)
print("sha1: " .. Glob:hash("sha1"))
item=Glob:next()
end

*/




%extend GLOB {
/* create a glob object from wildcard path */
GLOB(const char *Path)
{
GLOB *Item;

Item=(GLOB *) calloc(1,sizeof(GLOB));
glob(Path,0,0,&(Item->Glob));
Item->pos=-1;
return(Item);
}

/* destroy a glob object. You'll never call this, it's done automatically */
~GLOB()
{
  globfree(&($self->Glob));
  free(self);
}

/* return path of nth object in list, set it to be the current object */
const char *first()
{
if ($self->Glob.gl_pathc < 1) return(NULL);
$self->pos=0;
return($self->Glob.gl_pathv[$self->pos]);
}


/* return path of prev object in list, set it to be the current object */
const char *prev()
{
if ($self->pos > -1) $self->pos--;
return($self->Glob.gl_pathv[$self->pos]);
}

/* return path of next object in list, set it to be the current object */
const char *next()
{
if ($self->Glob.gl_pathc==0) return(NULL);
$self->pos++;
//must use >= because pathc is unsigned and pos is signed
//so must increment pos to be beyond the -1 that it starts at
if ($self->pos >= $self->Glob.gl_pathc) return(NULL);
return($self->Glob.gl_pathv[$self->pos]);
}

/* return path of nth object in list, set it to be the current object */
const char *nth(int n)
{
if (n > $self->Glob.gl_pathc) return(NULL);
if (n < 0) n=0;
$self->pos=n;
return($self->Glob.gl_pathv[$self->pos]);
}

/* return size of current object in list */
unsigned int size()
{
return($self->Glob.gl_pathc);
}


/* return hash of current object in list, default is hex encoded md5 */
%newobject hash;
char *hash(const char *type="md5", const char *encode="hex")
{
char *Digest=NULL;

HashFile(&Digest, type, $self->Glob.gl_pathv[$self->pos], HashEncodingFromStr(encode));
return(Digest);
}


/* return details of current object in glob list as an FINFO object */
%newobject info;
FINFO *info()
{
struct stat Stat;
FINFO *Item;

if (stat($self->Glob.gl_pathv[$self->pos],&Stat)==-1) return(NULL);
Item=(FINFO *) calloc(1,sizeof(FINFO));
Item->path=$self->Glob.gl_pathv[$self->pos];
Item->name=GetBasename(Item->path);
Item->size=Stat.st_size;
Item->mtime=Stat.st_mtime;

//check ISREG first because they will be most common item
if (S_ISREG(Stat.st_mode)) Item->type="file";
else if (S_ISDIR(Stat.st_mode)) Item->type="directory";
else if (S_ISLNK(Stat.st_mode)) Item->type="sock";
else if (S_ISSOCK(Stat.st_mode)) Item->type="sock";
else if (S_ISFIFO(Stat.st_mode)) Item->type="fifo";
else if (S_ISCHR(Stat.st_mode)) Item->type="cdev";
else if (S_ISBLK(Stat.st_mode)) Item->type="bdev";
else Item->type="???";

return(Item);
}

}

