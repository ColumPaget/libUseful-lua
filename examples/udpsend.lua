require("stream")

S=stream.STREAM("udp://192.168.2.1:17");
S:writeln("udp test\n");
S:close();
