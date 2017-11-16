
require("stream")
require("process")

S=stream.STREAM("test.txt")
if S ~= nil
then
S:seek(0,0)
line=S:readln()
print(line)
S:writeln("testing testing new interface\n")
S:extn("done")
S:close()
else
print("Can't open test.txt\n")
end

process.exit(5);

--[[
S=stream.open("http://www.google.com",0)
line=stream.readln(NULL,S)
while line ~= nil do
print(line)
line=stream.readln(NULL,S)
end
stream.close(S)
--]]

