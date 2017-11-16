require("oauth")
require("stream");
require("process");
require("dataparser");
require("filesys");
require("io")
require("string")
require("strutil")
require("terminal")

key="64045-7bc88d0cc96a4215df7a41c5"


SaveAccessToken=function(token)
local S

S=stream.STREAM("/tmp/pocket.oauth","wc")
S:writeln(token);
S:close()
end


LoadAccessToken=function()
local S
local token

S=stream.STREAM("/tmp/pocket.oauth","r")
if S ~= nil
then
token=S:readdoc()
S:close()
end
return(token)
end



GetAuth=function()
local redirect_url="pocketapp64045:authorizationFinished"

token=LoadAccessToken()
if token == nil or string.len(token) == 0
then
token=oauth.requestToken("https://getpocket.com/v3/oauth/request", key, redirect_url);
print(token)
print("GOTO: https://getpocket.com/auth/authorize?request_token=" .. token .. "&redirect_uri=" .. redirect_url);
io.read()
token=oauth.accessToken("https://getpocket.com/v3/oauth/authorize", key, token);
SaveAccessToken(token)
end

return token
end


OutputItem=function(Term, I)
local Tags

url=I:value("resolved_url")
Tags=I:open("tags")
while Tags:next()
do
print(Tags:value("tag"))
end

if url ~= nil 
then
	title=I:value("resolved_title");
	if title == nil or string.len(title) ==0 then title=filesys.basename(I:value("resolved_url")) end

--	id=string.format("%x",tonumber(I:value("resolved_id")))
	id=I:value("resolved_id")
	Term:puts("%g".. id .. "%0 %e%y" .. title .. "%0   %b" ..  strutil.unQuote(url) .."%0".."\n")
	wc=I:value("word_count");
	if wc == nil then wc="0" end
	Term:puts(wc .. " words: " .. I:value("excerpt") .. "\n\n")
end
end


-- This function outputs items selected by 'selector'
ShowItems=function(Term, P, selector)
local I

if selector == nil then selector='.*' end
if string.len(selector) == 0 then selector='.*' end

selector="^"..selector.."$"

I=P:open("list");
while I:next()
do
url=I:value("resolved_url")
if url ~= nil and string.find(url,selector) 
then
OutputItem(Term, I)
end
end

S:close();
end




PocketAction=function(actions)
local S, url, reply, result=false

print("actions: " .. actions)
url="https://getpocket.com/v3/send?consumer_key="..key.."&access_token="..token.."&actions="..strutil.httpQuote(actions)
S=stream.STREAM(url, "w")
reply=S:readdoc()
if S:getvalue("HTTP:ResponseCode") == "200" then result=true end

return result
end


ProcessSingleCommand=function(cmd, id, args)
local result=false

if cmd == 'tag'
then
	result=PocketAction("[{\"action\": \"tags_add\",\"item_id\": \""..id.."\",\"tags\": \""..args.."\"}]")
elseif cmd=='untag'
then
	result=PocketAction("[{\"action\": \"tags_remove\",\"item_id\": \""..id.."\",\"tags\": \""..args.."\"}]")
elseif cmd=='rm' or cmd=='del' or cmd=='delete'
then
	result=PocketAction("[{\"action\": \"delete\",\"item_id\": \""..args.."\"}]")
end

return result
end


-- Does the current item match the selector
ItemMatches=function(I, selector)
local value, pattern, result=false

	if string.sub(selector,1,6) == "title:"
	then
		value=I:value("resolved_title")
		pattern="^"..string.sub(selector,6).."$"
	elseif string.sub(selector,1,3) == "id:"
	then
		value=I:value("resolved_id")
		pattern="^"..string.sub(selector,3).."$"
	else
		value=I:value("resolved_url")
		pattern="^"..selector.."$"
	end

	if value ~= nil and string.find(value, pattern) then result=true end

	return result
end


-- Read lines and process them
ProcessCommands=function(Term, Parser)
local line, I, Tokens, cmd, selector, args

Term:flush()
line=Term:prompt(">> ")

Tokens=strutil.TOKENIZER(line, " ")
cmd=Tokens:next()
selector=Tokens:next()
args=Tokens:remaining()

if selector == nil then selector='.*' end
if string.len(selector) == 0 then selector='.*' end

if cmd == "add" then 
	if PocketAction("[{\"action\": \"add\",\"url\": \""..selector.."\",\"tags\": \""..args.."\"}]")
	then
		Term:puts("%gOKAY%0")
	else
		Term:puts("%rFAIL%0")
	end
elseif cmd=='quit' or cmd=='exit'
then
	process.exit(0)
else
	I=Parser:open("list");
	while I:next()
	do
	if ItemMatches(I, selector)
	then
		if cmd == "show" or cmd == "ls" then OutputItem(Term, I) 
		elseif ProcessSingleCommand(cmd, I:value("resolved_id"), args)
		then
			Term:puts("%gOKAY%0")
		else
			Term:puts("%rFAIL%0")
		end
	end
end
end

S:close();

end




--[[  MAIN STARTS HERE ]]--
Term=terminal.TERM()
token=GetAuth()
print("token: [" .. token .."]")

url="https://getpocket.com/v3/get?consumer_key="..key.."&access_token="..token.."&detailType=complete&sort=oldest"
S=stream.STREAM(url, "w")
data=S:readdoc();
-- io.stderr:write(data)

P=dataparser.PARSER("json",data)
ShowItems(Term, P, "")
while 1 == 1
do
ProcessCommands(Term,P)
end

