require("stream")

S=stream.STREAM("tty:/dev/ttyUSB1","1152000");
S:writeln("ATI\r\n");

line=S:readln()
while line ~= nil
do
print("line: "..S:readln());
end
