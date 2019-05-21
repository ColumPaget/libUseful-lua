/*
This module provides various functions related to filesystem access

many of these functions are called just as:

filesys.rename(from, to);
*/


%module filesys
%{
#include "libUseful-4/FileSystem.h"
#include "libUseful-4/Hash.h"
#include "libUseful-4/Errors.h"
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
%rename(pathaddslash) SlashTerminateDirectoryPath;
char *SlashTerminateDirectoryPath(char *DirPath);


/*  filesys.pathdelslash(Path)   remove the final a '/' from a path, if it ends with one */
%rename(pathdelslash) StripDirectorySlash;
char *StripDirectorySlash(char *DirPath);

/*  filesys.exists(Path)   return true if a filesystem object (file, directory, etc) exists at path 'Path', false otherwise */
%rename(exists) FileExists;
int FileExists(const char *Path);

/*  filesys.mkdir(Path)   make a directory. DirMask is the 'mode' of the created directory, and is optional */
int mkdir(const char *Path, int DirMask=0777) { if (mkdir(Path, DirMask)==0) return(TRUE); return(FALSE);}

int rmdir(const char *Path) { if (rmdir(Path)==0) return(TRUE); return(FALSE);}

/*  filesys.mkdirPath(Path)   make a directory, CREATING ALL PARENT DIRECTORIES AS NEEDED. 
DirMask is the 'mode' of the created directory, and is optional */
%rename(mkdirPath) MakeDirPath;
int MakeDirPath(const char *Path, int DirMask=0777);

/*  Path=filesys.find(File */
%newobject find;
char *find(const char *File, const char *Path);

/*   filesys.chown(Path, Owner)   change owner of a file. 'Owner' is the name, not the uid */
%rename(chown) FileChOwner;
int FileChOwner(const char *Path, const char *Owner);

/*   filesys.chgrp(Path, Group)   change group of a file. 'Group' is the group name, not the gid */
%rename(chgrp) FileChGroup;
int FileChGroup(const char *Path, const char *Group);

/*  filesys.copy(src, dest)     make a copy of a file */
%rename(copy) FileCopy;
int FileCopy(const char *oldpath, const char *newpath);

/*  filesys.newExtn(Path, NewExtn)   change the ms-dos style extension of a file. Adds one to files that have no extension */
%rename(newExtn) FileChangeExtension;
int FileChangeExtension(const char *FilePath, const char *NewExt);

/*  filesys.symlink(path, symlink)   create a symbolic link at 'symlink' pointing to file/directory at 'path' */
int symlink(const char *oldpath, const char *newpath) { if (symlink(oldpath, newpath)==0) return(TRUE); return(FALSE);}

/*  filesys.link(path, linkname)     create a hard link at 'linkname' pointing to file/directory at 'path' */
int link(const char *oldpath, const char *newpath) { if (link(oldpath, newpath)==0) return(TRUE); return(FALSE);}

int unlink(const char *path) { if (unlink(path)==0) return(TRUE); return(FALSE);}

int rename(const char *OldPath, const char *NewPath) { if (rename(OldPath, NewPath)==0) return(TRUE); return(FALSE);}


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
int FileSystemMount(const char *Dev, const char *MountPoint, const char *Type, const char *Args="");

/*  filesys.unmount(mountpoint, args)  Unmount a filesystem. 'args' is optional and can be a space seperated list of

detach   - use 'MNT_DETACH' to do a lazy unmount, which means if filesystem is busy it will be marked for unmounting and unmount when ceases to be busy
lazy     - use 'MNT_DETACH' to do a lazy unmount, which means if filesystem is busy it will be marked for unmounting and unmount when ceases to be busy
recurse  - umount any mounts under the mount point as well as the mount point. Without this the mount will fail if other mounts are active under it
rmdir    - remove mountpoint directory after unmounting
*/
%rename(unmount) FileSystemUnMount;
int FileSystemUnMount(const char *MountPoint, const char *Args="");

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

