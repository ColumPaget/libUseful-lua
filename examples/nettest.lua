--[[

simple demo of some 'net' functions

]]-

require("net")

internal_ip=net.interfaceIP("wlan0")
if internal_ip == "" then internal_ip=net.interfaceIP("eth0") end

print("intIP: " .. internal_ip)
print("google: " .. net.lookupIP("www.google.com"))
print("axiom: " .. net.lookupIP("mx1.axiomgb.com"))
print("extIP: " .. net.externalIP())
