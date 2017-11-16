require("hash")

-- result=hash.bytes("sha1", "testing", 7);
-- print(result)

print(hash.types());

h=hash.HASH("whirl,sha1","z85");
h:update("testing");
print(h:finish());

