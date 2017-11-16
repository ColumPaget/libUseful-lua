require("stream")
require("terminal");


outfield=function(title, value)
print(terminal.format("~e" .. title .. ":~0 " .. value .. "~0"))
end

outstatus=function(value)
if value=="OK" then str="~gVALID~0"
else str="~r"..value.."~0"
end
outfield("status", str);
end

outcipher=function(cipher, bitsStr)
bits=tonumber(bitsStr)
if bits < 128 
	then
		bitsStr="~r"..bitsStr.."~0"
	else
		if bits < 256
		then
		bitsStr="~y~b"..bitsStr.."~0"
		else
		bitsStr="~g"..bitsStr.."~0"
		end
	end

	outfield("cipher",cipher.." "..bitsStr.." bits")
end






-- MAIN STARTS HERE
if #arg > 0
then
S=stream.STREAM(arg[1])
if S ~= nill
then
	cipher=S:getvalue("SSL-Cipher") 
	if (cipher ~= nil)
	then
		outcipher(S:getvalue("SSL-Cipher-Details"), S:getvalue("SSL-Bits"))
		-- S:getvalue("SSL-Cipher-Details"))
		outfield("cert for", S:getvalue("SSL-Certificate-Subject"))
		outfield("cert CN", S:getvalue("SSL-Certificate-CommonName"))
		outfield("cert issuer", S:getvalue("SSL-Certificate-Issuer"))
		outstatus(S:getvalue("SSL-Certificate-Verify"))
		outfield("start", S:getvalue("SSL-Certificate-NotBefore"))
		outfield("end", S:getvalue("SSL-Certificate-NotAfter"))
	else
		print(terminal.format("~rNO TLS/SSL SUPPORT~0"))
	end
	S:close()
else
	print(terminal.format"~rCONNECTION FAILED~0")
end
else
print("Please supply a URL on the command line")
end
