require("terminal")
require("process")
require("stream")

t=terminal.TERM();
--t:clear();
t:puts("~U9994 ~U262F ~U26A1\n")

t:puts("testing ~rred ~U98A0 ~ggreen ~U266C ~0 ~ebold~0 ~iinverse~0 ~uunderline ~mmagenta~0 ~Cwhatever~0\n");

--terminal.move(S,10,10);
t:flush()

process.sleep(2);
t:puts("~<\r~>");

for i=1,4
do
t:scroll();
t:flush();
process.sleep(1);
end
t:flush()
