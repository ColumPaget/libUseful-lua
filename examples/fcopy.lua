--[[

Uses S:copy to copy a stream, which can be a file path, an http url, a tcp connection, etc, etc

try passing these as arg[1]

http://www.google.com/
/etc/hosts
cmd:ps

]]--

require("stream")
require("strutil")


S=stream.STREAM(arg[1])
name="test"
if (S ~= nil)
then
print("PATH ".. S:path())
print("Downloading "..S:basename().." ".. strutil.tometric(S:size(),1) .. " bytes")
S:copy(name);
S:close();
else 
print("ERROR: failed to connect to "..arg[1]);
end
