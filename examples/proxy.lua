require ("net")
require ("stream")

--net.setProxy("socks5:127.0.0.1:5050");
--net.setProxy("https:178.62.22.69:8118");
--net.setProxy("https:77.81.234.244:8080");
--net.setProxy("https:38.96.13.182:8008");
--net.setProxy("https:212.237.9.64:8080");
--net.setProxy("socks5:127.0.0.1:5052,https:38.96.13.182:8008");
--net.setProxy("socks5:127.0.0.1:5052,https:212.237.9.64:8080");
--net.setProxy("socks5:127.0.0.1:5052,socks5:123.57.10.224:1102");
--net.setProxy("socks5:123.57.10.224:1102,https:212.237.9.64:8080");

--S=stream.STREAM("socks5:127.0.0.1:5052,https:212.237.9.64:8080,tcp://freshcode.club:80/");
--S:writeln("GET / HTTP/1.1\r\nHost: freshcode.club\r\nConnection: close\r\n\r\n");

S=stream.STREAM("ssh:ssh_userX745:metaPack1999@217.33.140.70:1022,tcp:217.33.140.70:25");

doc=S:readdoc();
print(doc)

