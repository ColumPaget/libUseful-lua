require("terminal")

terminal.utf8(3)

--[[
for i=32,0xFFFF,1
do
terminal.puts(string.format("%x:~U%04x\r\n",i,i))
end
]]--

terminal.puts("~:dagger: ~:music: ~:moon: ~:quarter: ~:half: ~:standby: ~:power: ~:media-play: ~:media-pause: ~:media-stop: ~:media-record: ~:media-eject: ~:sun: ~:cloud: ~:phone: ~:skull+crossbones: ~:flower: ~:radiation: ~:spades: ~:hearts: ~:diamonds: ~:clubs:\n")
terminal.puts(" ~:battery: ~:voltage: ~:mute: ~:alien: ~:invader: ~:globe: ~:euro: ~:pound: ~:yen: \n")
terminal.puts(" ~:menu: ~:elipsis: ~:velipsis: ~:bullet: ~:wbullet:  ~:forward: ~:reverse: ~:up: ~:down: ~:left: ~:right: \n")
terminal.puts(" ~:key: ~:lock: ~:unlock: ~:lock+key: ~:wifibars:  ~:paperclip: ~:link: ~:book: ~:down: ~:left: ~:right: \n")
