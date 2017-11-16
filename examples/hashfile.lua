require("hash")
require("filesys");

Glob=filesys.GLOB("*")
item=Glob:next()
while item ~= nil
do
Info=Glob:info();
print("name: " .. item)
print("type: " .. Info.type)
print("size: " .. Info.size)
print("sha1: " .. Glob:hash("sha1"))
print("md5 : " .. hash.hashfile(item, "md5"));
item=Glob:next()
end

