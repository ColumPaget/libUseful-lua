require("stream")
require("process")

process.lu_set("HttpDebug","true");
process.lu_set("HttpNoCompress","true");

S=stream.STREAM(arg[1])

html=S:readdoc()
print(html)
