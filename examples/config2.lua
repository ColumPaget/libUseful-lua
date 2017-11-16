require("dataparser")

config=[[
host1 {
ip=192.168.2.1
port=22
user=metacosm89
}

host2
{
ip=192.168.2.2
port=23
user=metacosm99
}
]]

json=[[
{
	host1 {
		ip: 192.168.2.1
	}

	host2 {
		ip: 192.168.2.2
	}
}
]]

--print("CONFIG: ".. config)
P=dataparser.PARSER("config", config)

I=P:open("/host1");
if I == nil 
then
print("I==nil!")
end
print(I:value("ip"))

I=P:open("/host2");
print(I:value("ip"))
