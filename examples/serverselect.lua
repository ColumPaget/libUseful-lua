--[[

There's two ways of doing server processes with libUseful (probably three if you use lua co-routines). This is a simple example of doing it
using a 'POLL_IO' object. POLL_IO lets you watch multiple streams for activity, so as connections come in you accept them and add them to the
POLL_IO, and then call 'select' to see which of them needs processing. 

]]--

require("stream")
require("net")

NewClient = function(Serv)
	S=Serv:accept();
	S:writeln("WELCOME TO LUA SERVER: type something\n");
	Streams:add(S);
end

ClientRead = function(S)
if S ~= nil
then
	line=S:readln();
	if (line ~= nil)  then  print(line)
	else S:close()
	end
end
end

Streams=stream.POLL_IO();
Serv=net.SERVER("tcp::8888");
Streams:add(Serv.S);


while 1
do
	S=Streams:select()
	if S == Serv.S then NewClient(Serv)
	else ClientRead(S)
	end
end

