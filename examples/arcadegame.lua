
require("terminal")
require("stream")
require("math")
require("sys")
require("string")
require("process")

Bullets={}
ObjList={}
GameTicks=0
twidth=0
tlength=0
Score=0
NextArmor=1000

function GameObjectMoveLeft(obj)
obj.x =obj.x -1
if obj.x < 0 then 
	if obj.class == "player" then obj.x=0 else obj.direction="right" end
end
end

function GameObjectMoveRight(obj)
local max=twidth -3

obj.x =obj.x +1
if obj.x > max then 
	if obj.class == "player" then obj.x=max -3 else obj.direction="left" end
end
end

function GameObjectMoveUp(obj)
obj.y =obj.y -1
if obj.y < 0 then obj.live=false end
end

function GameObjectMoveDown(obj)
obj.y =obj.y + 1
if obj.y > tlength then obj.live=false end
end


function GameObjectAddString(obj, str)
obj.stringCount=obj.stringCount+1
obj.strings[obj.stringCount]=str
end


function CreateObject(x, y, direction)
local Obj={}

Obj.state=0
Obj.charge=0
Obj.armor=0
Obj.points=0
Obj.rate=3
Obj.live=true
Obj.direction=direction;
Obj.x=x;
Obj.y=y;
Obj.stringCount=0;
Obj.strings={};
Obj.moveleft=GameObjectMoveLeft;
Obj.moveright=GameObjectMoveRight;
Obj.moveup=GameObjectMoveUp;
Obj.movedown=GameObjectMoveDown;
Obj.addstr=GameObjectAddString;
Obj.hitbox=1
return Obj
end


function CreateGameObject(x, y, direction)
local Obj

Obj=CreateObject(x, y, direction)
table.insert(ObjList, Obj);
return Obj
end



function CreateBullet(x, y, class)
local Obj

Obj=CreateObject(x, y, class)
Obj.class="player bullet"
table.insert(Bullets, Obj);
return Obj
end


function AnimExplode(Obj)
Obj.state=Obj.state+1
Obj.class="explode"
if Obj.state >= Obj.stringCount then 
Obj.live=false 
Obj.state=0
end
end

function CreateExplode(x, y)
local Obj

Obj=CreateObject(x, y, "explode")
Obj:addstr(" ~r*~0 ");
Obj:addstr(" ~y*~0 ");
Obj:addstr("~y***~0");
Obj:addstr("~r*~y*~r*~0 ");
Obj:addstr("~r*~r*~r*~0 ");
Obj:addstr("~r*~b*~r*~0 ");
Obj:addstr("~r* *~0 ");
Obj:addstr("~b* *~0 ");
Obj.anim=AnimExplode;

--do not insert into object list, it will replace and existing object
--table.insert(ObjList, Obj);
return Obj
end


function EnemyAnimate(Obj)
local bomb

if GameTicks % Obj.rate == 0
then
Obj.state=Obj.state+1
if Obj.direction == "left" then Obj:moveleft() end
if Obj.direction == "right" then Obj:moveright() end
if Obj.charge < 1 then Obj.charge=Obj.charge +1 end
end

if math.random() > 0.95 and Obj.charge > 0
then
bomb=CreateBullet(Obj.x, Obj.y, "down")  
bomb.class="bomb"
bomb:addstr("~r:~0")
Obj.charge = Obj.charge - 3
end

end


function CreateEnemy(x, y, direction)
local Obj

Obj=CreateGameObject(x, y, direction)
Obj.class="enemy"
Obj.points=10
Obj.anim=EnemyAnimate;
Obj:addstr(">0<")
Obj:addstr("<0>")
return Obj
end

function CreateRunner(x, y, direction)
local Obj

Obj=CreateGameObject(x, y, direction)
Obj.class="enemy"
Obj.points=10
Obj.anim=EnemyAnimate;
Obj:addstr("~r-v-~0")
Obj:addstr("^v^")
Obj.rate=1
return Obj
end


function FollowerAnimate(Obj)
local bomb

if GameTicks % Obj.rate == 0
then
	Obj.state=Obj.state+1
	Obj.strings[1]="<=~b~eo~0=>"
	Obj.strings[2]="<=~bo~0=>"
	Obj.stringCount=2

	if PlayerShip.x < Obj.x 
	then
		Obj.x=Obj.x - 1 
	elseif PlayerShip.x > Obj.x 
		then Obj.x=Obj.x + 1 
	else
		Obj.charge=10
	end

	if Obj.charge > 0 
	then
	Obj.points=40
	Obj.strings[1]="<=~m~ev~0=>"
	Obj.strings[2]="<=~mv~0=>"
	if math.random() > 0.5
	then
		bomb=CreateBullet(Obj.x - 1 + GameTicks % Obj.rate, Obj.y, "down")  
		bomb.class="bomb"
		bomb:addstr("~r:~0")
	end
	end
end

end



function CreateFollower(x, y, direction)
local Obj

Obj=CreateGameObject(x, y, direction)
Obj.class="enemy"
Obj.points=20
Obj.hitbox=2
Obj.anim=FollowerAnimate;
return Obj
end


function BomberAnimate(Obj)
local bomb

if GameTicks % Obj.rate == 0
then
Obj.state=Obj.state+1
if Obj.direction == "left" 
then 
Obj.strings[1]="~b<==={~0~y>>~0"
Obj.strings[2]="~b<==={~0~r>~0"
Obj.stringCount=2;
Obj:moveleft() 
end

if Obj.direction == "right" 
then
Obj.strings[1]="~y<<~b}===>~0"
Obj.strings[2]="~r<~b}===>~0"
Obj.stringCount=2;
Obj:moveright() 
end

if math.random() > 0.95 then Obj.charge=6 end

if Obj.charge > 0
then
bomb=CreateBullet(Obj.x - 1 + GameTicks % Obj.rate, Obj.y, "down")  
bomb.class="bomb"
bomb:addstr("~r:~0")
Obj.charge=Obj.charge -1
end

end


end



function CreateBomber(x, y, direction)
local Obj

Obj=CreateGameObject(x, y, direction)
Obj.class="enemy"
Obj.points=50
Obj.charge=0
Obj.stringCount=0
Obj.hitbox=2
Obj.anim=BomberAnimate;
return Obj
end


function PlayerShipAnimate(Obj)

if GameTicks % 10 ==0 
then 
if Obj.charge < 4 then Obj.charge=Obj.charge+1 end
end

if GameTicks % 5 == 0
then
Obj.strings[1]="~e<~g^~0~e>~0"
if Obj.charge < 4
then
	if Obj.charge == 3 then Obj.strings[1]="~e<~m^~0~e>~0"
	elseif Obj.charge == 2 then Obj.strings[1]="~e<~m^~0~e>~0"
	elseif Obj.charge == 1 then Obj.strings[1]="~e<~r^~0~e>~0"
	else Obj.strings[1]="~e<^>~0"
	end
else
end

end
end

function CreatePlayerShip()
local Obj

Obj=CreateGameObject(term:width() / 2, term:length(), "")
Obj:addstr("~e<^>~0")
Obj.class="player"
Obj.anim=PlayerShipAnimate
Obj.armor=3
Obj.charge=3
Obj.points=0
return Obj
end


function ProcessKeyPress(key)
local Obj
--if key=="LEFT" then PlayerShip.x = PlayerShip.x - 1 end
--if key=="RIGHT" then PlayerShip.x = PlayerShip.x + 1 end

if key=="LEFT" then PlayerShip:moveleft() end
if key=="RIGHT" then PlayerShip:moveright() end
if key=="ESC" then return false end
if key=="UP" or key==" " then 
	if PlayerShip.charge > 0
	then
		Obj=CreateBullet(PlayerShip.x, PlayerShip.y-1, "up")  
		Obj:addstr("~g!~0")
		PlayerShip.charge=PlayerShip.charge - 1
	end
end

return true
end



function CollisionValid(item, peer)
local xdiff, ydiff

if peer==nil then return false end

--explosions can't collide with anything
if peer.class == "explode" then return false end

	xdiff=peer.x - item.x
	if xdiff < 0 then xdiff=0 - xdiff end

	ydiff=peer.y - item.y
	if ydiff < 0 then ydiff=0 - ydiff end

	if ydiff > 1 then return false end
	if xdiff > peer.hitbox then return false  end

	-- enemy bombs can only collide with the player
	if item.class=="bomb" and peer.class ~= "player" then return false end

return true
end



function Collision(item, Objects)
local index, peer 

for index,peer in pairs(Objects)
do
	if CollisionValid(item, peer) 
	then 
		if peer.armor < 1 
		then
			peer.live=false
			Score=Score+peer.points
			if Score > NextArmor 
			then 
				PlayerShip.armor = PlayerShip.armor +1
				NextArmor= NextArmor + 1000
			end
				Objects[index]=CreateExplode(peer.x, peer.y)
		else
			peer.armor=peer.armor - 1
		end
		return true
	end
end

return false
end



function RenderBullets(Bullets, Objects)
local index, item, state

for index,item in pairs(Bullets)
do
	if item ~= nil
  then
	if item.direction == "up" then item:moveup() end
	if item.direction == "down" then item:movedown() end

	if item.live
	then
		term:move(item.x, item.y)
		if Collision(item, Objects)
		then
			table.remove(Bullets, index)
		else
			state=item.state % item.stringCount
			term:puts(item.strings[state +1])
		end	
	else
		table.remove(Bullets, index)
	end

	end
end

end



function RenderObjects(Objects)
local index, item, str, len

for index,item in pairs(Objects)
do
	if item ~= nil
  then
	if item.anim ~= nil then item:anim() end

	if item.live and item.stringCount > 0
	then
	str=item.strings[item.state % item.stringCount + 1];
	len=terminal.strlen(str)
		if len > item.x
		then
			term:move(item.x, item.y)
			term:puts(string.sub(str, len-item.x))
		else
			term:move(item.x +1 - (len / 2), item.y)
			term:puts(str)
		end
	else
	table.remove(Objects, index)
	end
	end
end

end

function Render()
term:clear()
term:move(0,0);
term:puts("~e~gSCORE: "..Score.."~0")

term:move(twidth - 11,0);
if PlayerShip.armor > 2 then term:puts("~e~bARMOR: ~g"..PlayerShip.armor.."~0")
elseif PlayerShip.armor > 1 then term:puts("~e~bARMOR: ~y"..PlayerShip.armor.."~0")
else term:puts("~e~bARMOR: ~r"..PlayerShip.armor.."~0")
end

RenderBullets(Bullets, ObjList)
RenderObjects(ObjList)
end



function SpawnEnemies()
local Enemy, val, direction, xpos, ypos

if GameTicks % 20 ==0
then
	val=math.random() 
	if val > 0.5 
	then
		direction="left"
		xpos=twidth
	else 
		direction="right"
		xpos=0
	end

	val=math.random() 
	if val > 0.98
	then
		-- Follower stack! very nasty!
		ypos=math.random() * 10 
		Enemy=CreateFollower(xpos, ypos + 1, direction)
		Enemy=CreateFollower(xpos, ypos + 2, direction)
		Enemy=CreateFollower(xpos, ypos + 3, direction)
	elseif val > 0.85
	then
		Enemy=CreateBomber(xpos, math.random() * 10 +1, direction)
	elseif val > 0.6
	then
		Enemy=CreateFollower(xpos, math.random() * 10 + 1, direction)
	elseif val > 0.4
	then
		Enemy=CreateRunner(xpos, math.random() * (tlength-6) +1, direction)
	else
		Enemy=CreateEnemy(xpos, math.random() * (tlength-6) +1, direction)
	end
end

end


function DisplayGameOver()
local count

for count=1,10,1
do
term:move(twidth /2, tlength / 2)
term:puts("~r~eGAME OVER~0")
term:flush()
process.usleep(200000)

term:move(twidth /2, tlength / 2)
term:puts("~b~eGAME OVER~0")
term:flush()
process.usleep(200000)

term:move(twidth /2, tlength / 2)
term:puts("~y~eGAME OVER~0")
term:flush()
process.usleep(200000)
end
end



math.randomseed(sys.time())
term=terminal.TERM();
term:hidecursor();
term:cork()

Streams=stream.POLL_IO()
Streams:add(term.S)

PlayerShip=CreatePlayerShip()

nextTick=0
while PlayerShip.live
do
	twidth=term:width()
	tlength=term:length()
	Now=sys.centitime()
	if Now > nextTick
	then
	SpawnEnemies()
	Render()
	nextTick = Now + 10
	GameTicks=GameTicks+1
	end

	S=Streams:select(nextTick - Now)
	if S==term.S then 
		if ProcessKeyPress(term:getc()) == false then break end
	end
	term:flush()
end

if PlayerShip.live == false then DisplayGameOver() end

term:move(1, tlength-1)
term:flush()

