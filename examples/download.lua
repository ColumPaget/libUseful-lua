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
