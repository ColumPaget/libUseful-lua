require("process")
require("filesys");
require("osext");


process.chdir("/tmp")
-- process.chroot();
-- process.switchUser("nobody");
print(process.cwd())
-- filesys.copy("http://traffic.libsyn.com/djsteveboy/oil.mp3", "/tmp/oil.mp3")

print(os.platform());

