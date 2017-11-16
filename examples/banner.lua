--[[
This example illstrates simple networking. It connects to a host/port and prints out the first line
of data received. For many protocols (FTP, SMTP) this first line is called the 'banner'
]]--

require("stream")
require("process")

if arg[1] == nil then
print("ERROR: No hostname given. Please supply a target host and port on the command-line")
process.exit(1)
end

if arg[2] == nil then
print("ERROR: No port given. Please supply a target host and port on the command-line")
process.exit(1)
end


url=string.format("tcp://%s:%s",arg[1],arg[2]);
print(url);
S=stream.STREAM(url);
line=S:readln();
print(line)
