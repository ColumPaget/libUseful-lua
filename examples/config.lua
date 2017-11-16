require("dataparser")

config =[[smtp_host mx1.axiomgb.com
maxconnections = 30
ssl=true
ttl : 80
name =test
event: whatever]]

yaml=[[
from: test
subject: this is a test
#comment: this is a comment
declare: "#this is not a comment"
text:
 color: red
 style: bold
 contents: "this is some text"
]]


languages=[[
java:
 object_oriented: true
 compiled_mcode: false
 compiled_pcode: true
 interpreted: false
 vm: true
c++:
 object_oriented: true
 compiled_mcode: false
 compiled_pcode: true
 interpreted: false
 vm: true
c:
 object_oriented: false
 compiled_mcode: true
 compiled_pcode: false
 interpreted: false
 vm: false
basic:
 object_oriented: false
 compiled_mcode: false
 compiled_pcode: false
 interpreted: true
 vm: false
lua:
 object_oriented: false
 compiled_mcode: false
 compiled_pcode: true
 interpreted: true
 vm: true
]]


PrintItems=function(P)
local item, I

item=P:next()
while item ~= nil
do
print("item: " ..item.. " = ".. P:value(item))
item=P:next()
end
end

print("config:")
P=dataparser.PARSER("config", config)
PrintItems(P)

print()

print("yaml:")
P=dataparser.PARSER("yaml", yaml)
PrintItems(P)

P:open("/text")
PrintItems(P)

print("languages:")
P=dataparser.PARSER("yaml", languages)
item=P:next()
while item ~= nil
do
print(item .."->")
I=P:open(item)
PrintItems(I)
item=P:next()
end

