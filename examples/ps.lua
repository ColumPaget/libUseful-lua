--[[
This just illustrates how to spawn another process and read from it

You can also write to a processes stream, so bi-directional comms is possible
]]--

require("stream")
require("strutil")

S=stream.STREAM("cmd:ps ax");
line=S:readln()
while line ~= nil
do
strutil.stripTrailingWhitespace(line)
print("ps:  "..line)
line=S:readln()
end
