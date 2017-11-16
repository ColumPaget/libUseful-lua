require("stream")
require("process")
require("dataparser")

process.lu_set("HttpNoCompress","true");

S=stream.STREAM("http://www.john00fleming.co.uk/mixes/podcasts/Nov08/podcast.xml")
rss=S:readdoc()

P=dataparser.PARSER("rss", rss)
tag=P:next()

while tag ~= nil
do
I=P:open(tag)
title=I:value("title")
if title ~=nil then print("title: "..title) end
guid=I:value("guid")
if guid ~=nil then print("guid: "..guid) end
pubDate=I:value("pubDate")
if pubDate ~=nil then print("pubDate: "..pubDate) end
tag=P:next()
end



