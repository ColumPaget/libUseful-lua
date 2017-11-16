require("terminal")

for i=32,0xFFFF,1
do
terminal.puts(string.format("%x:%%U%04x \r\n",i,i))
end
