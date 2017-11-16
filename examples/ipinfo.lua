require("stream")
--require("dataparser")

API_KEY="1261fcbf647ea02c165aa3bfa66810f0be453d8a1c2e7f653c0666d4e7e205f0"

--const char *DesiredTags[]={"CountryCode","CountryName","City","RegionName","Latitude","Longitude","TimeZone",NULL};

IP="217.33.140.70"
url="http://api.ipinfodb.com/v3/ip-city.php?key=" .. API_KEY .. "&ip="..IP
print(url)
S=stream.STREAM(url);
xml=S:readdoc();
print(xml)

