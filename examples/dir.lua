--[[
This illustrates using globbing to get a directory list, and indexes through it using two methods
]]--


require("filesys")

D=filesys.GLOB("/tmp/*");

print("******************************** Iteration using 'next' ***************************")
item=D:next()
while item ~= nil
do
print(item)
item=D:next()
end
print()
print()


print("******************** Iteration using indexing and with hashes *********************")
for i=0, D:size()-1, 1
do
item=D:nth(i)
info=D:info()
hash=D:hash("sha1")
if hash ~= nil then print(info.type .. "  " .. hash .."   " .. info.path) end
end


