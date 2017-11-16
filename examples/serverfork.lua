--[[

There's two ways of doing server processes with libUseful (probably three if you use lua co-routines). This is a simple example of doing it
using 'xfork'. you use 'accept' to wait for a connection, and then fork a process off to handle it. This example will send a message, read
one line, and then exit.

]]--

require("stream")
require("process")
require("net")

ClientRead = function(S)
if S ~= nil
then
	S:writeln("WELCOME TO LUA SERVER: type something\n");
	line=S:readln();
	if (line ~= nil)  then  print(line)
	else S:close()
	end
end

-- we have to exit from the child process now, or it will return to the main loop and start processing that!
process.exit(1);
end


Serv=net.SERVER("tcp::8888");
while 1
do
	S=Serv:accept();
	if S ~= nil
	then
	--xfork splits our process into two processes. The parent process gets the pid of the new child, but the child gets passed '0' instead,
	--so that it knows it's the child. The child will thereform run the 'ClientRead' function while the parent goes around the loop again
	if process.xfork() == 0 then ClientRead(S) end
	end

	--collect any child processes that have exited
	process.childExited();
end

