--[[

print out various system info

Unforntuately 'freemem' is a bit meaningless, as it doesn't (yet) include memory being used for cache

]]--

require("sys");
require("strutil");

print("os: "..sys.type())
print("arch: "..sys.arch())
print("release: "..sys.release())
print("hostname: "..sys.hostname())
print("tmpdir: "..sys.tmpdir())
print("uptime: "..sys.uptime())
print("totalmem: " .. sys.totalmem() .. "  (" .. strutil.toMetric(sys.totalmem(), 3) .. ")" )
print("buffermem: " .. sys.buffermem() .. "  (" .. strutil.toMetric(sys.buffermem(), 3) .. ")" )
print("freemem: " .. sys.freemem() .. "  (" .. strutil.toMetric(sys.freemem(), 3) .. ")" )
