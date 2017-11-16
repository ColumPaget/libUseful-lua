require("process")
require("os");

process.configure("container=/var/run/container.%d");
os.execute("ls -l /")
os.execute("ps ax")

