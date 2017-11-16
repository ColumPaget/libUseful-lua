require("stream")

s=stream.STREAM("/etc/services");
line=s:readln()
while (line ~= nil)
do
print(line)
line=s:readln()
end
s:close()
