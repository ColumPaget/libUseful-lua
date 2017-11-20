--[[

 just a simple example of downloading a document and printing it out to stdout

 arg[1] would normally be an http url, but you can pass a file path or tcp connection too 

]]--



require("stream")
require("process")

-- this causes the HTTP transaction headers to be printed on stderr
process.lu_set("HttpDebug","true");

if arg[1] == nil
then
	print("ERROR: No url give on command-line. Please supply a url for download");
else
	S=stream.STREAM(arg[1])
	html=S:readdoc()
	print(html)
end
