require("stream")
require("net")

net.setProxy("socks5:192.168.2.1:5052")
S=stream.STREAM("tcp://217.33.140.66:25")
if (S ~= nill)
then
line=S:readln()
print(line)
S:writeln("HELO mx.columpaget.name\n");
S:flush()
line=S:readln()
print(line)
S:writeln("QUIT")
S:flush()
line=S:readln()
print(line)
else
print("ERROR: Connection Failed")
end
