require("process")
require("os");

process.setenv("TESTING","This is a test of set env");
os.execute("/bin/sh -c \"set\"");
