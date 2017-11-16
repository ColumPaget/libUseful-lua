
require("securemem")
require("process")

S=securemem.SECURESTORE("/tmp/creds.test");
S:test("realm2","fred");

--process.sleep(100);
--process.abort();
