require("stream")
require("dataparser")


--const char *DesiredTags[]={"CountryCode","CountryName","City","RegionName","Latitude","Longitude","TimeZone",NULL};

S=stream.STREAM("https://www.w3schools.com/xml/cd_catalog.xml");
xml=S:readdoc();
print(xml)
P=dataparser.PARSER("xml",xml);
I=P:open("CATALOG")
while I:next() ~= nil
do
print(I:value("TITLE"))
end
