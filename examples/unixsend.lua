require("stream")

S=stream.STREAM("unix:/tmp/test.sock");
line=S:readln();
print(line);
S:writeln("hello back\n");
S:close();
