require("net")

print("intIP: " .. net.interfaceIP("wlan0"))
print("google: " .. net.lookupIP("www.google.com"))
print("axiom: " .. net.lookupIP("mx1.axiomgb.com"))
print("extIP: " .. net.externalIP())
