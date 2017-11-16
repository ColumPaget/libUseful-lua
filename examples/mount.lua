require("filesys")

filesys.mkdir("/mnt/proc");
filesys.mount("","/mnt/proc","proc"); 

filesys.mkdir("/mnt/sys");
filesys.mount("","/mnt/sys","sysfs"); 
