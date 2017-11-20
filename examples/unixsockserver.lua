--[[

this is a unix sockets server using POLL_IO. You can send a message to it with unixsend.lua

notice, the only differences to serverselect.lua are the URL specified when the server object is
created, and also the final line to delete the unix socket 

]]--

require("stream")
require("filesys")
require("net")


NewClient = function(Serv)
	S=Serv:accept();
	S:writeln("Hello\n");
	Streams:add(S);
end

ClientRead = function(S)
if S ~= nil
then
	line=S:readln();
	if (line ~= nil)  then  print(line)
	else 
		Streams:delete(S)
		S:close()
	end
end
end

Streams=stream.POLL_IO();
Serv=net.SERVER("unix:/tmp/test.sock");
Streams:add(Serv.S);


while 1
do
	S=Streams:select()
	if S == Serv.S then NewClient(Serv)
	else ClientRead(S)
	end
end

filesys.unlink("/tmp/test.sock")
