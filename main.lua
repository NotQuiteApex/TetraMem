--[[
--------------------------------------------------------------------------------

Copyright (c) 2018-2019 NotQuiteApex

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

--------------------------------------------------------------------------------
--]]

-- localizing library functions make them faster to type and faster to use
local sin,cos,abs,atan2 = math.sin,math.cos,math.abs,math.atan2

-- make sure every pattern is unique
math.randomseed( os.time() )


function love.load()
	-- sublime stdout shortcut for windows
	io.stdout:setvbuf('no')

	-- love.module shortcuts
	la = love.audio
	lg = love.graphics
	lt = love.timer
	lm = love.mouse
	lw = love.window

	-- dont let the images be blurry
	lg.setDefaultFilter('nearest','nearest')

	tetrocolor = {
		[0] = {0,0,0},	-- black
		{240,0,0},		-- Z = red
		{240,170,0},	-- L = orange
		{240,240,0},	-- O = yellow
		{0,240,0},		-- S = green
		{0,240,240},	-- I = long cyan
		{0,0,240},		-- J = blue
		{160,0,240},	-- T = tetris! purple
	}

	-- each pattern is meant to be unique.
	-- its only shown on screen for a second or less
	genPattern()

	-- general assets
	lg.setNewFont('holmstock.ttf',16)
	tetramemlogo = lg.newImage('logo.png')
	vingette = lg.newImage('vingette.png')

	-- totally original ost
	-- its so bad its... well still bad
	bgsongintro = la.newSource('tetramemA.ogg','stream'); bgsongintro:play()
	bgsongloop  = la.newSource('tetramemB.ogg','stream'); bgsongloop:setLooping(true)

	-- "gamestate" is basically just what menu youre in
	-- it swaps between what to update and draw
	gamestate = 'menu'
	bplayrotate,bplayscale = 0,1
	bquitrotate,bquitscale = 0,1
	bxplnpos,   bxplnscale = 0,1


	memstate = "countdown"
	memwins = 0
	memloss = 0

	countw,countv = 1,1
	countdt,countmx = 0,0.5
	countwords = {{"ready?", "set.", "! MEMORIZE !"},{"ready?", "set.", "! CHOOSE !"}}

	memorizedt,memorizemx = 0,0.3

	choosechoice = 0
	choosedone = false
	chooseresult = 'nu'
	choosedt,choosemx = 0,2

	explanationscience = [[> The pattern gets stored in your sensory memory, which is the shortest memory you have.

> Things like distractions and waiting between the pattern and answer can cause you to lose the memory.

> Decreasing the time you see the pattern for also makes it harder.]]
	explanationhowplay = [[There will be 4 teams of equal player number.
Only 1 person can play at a time, they can’t go again until everyone else on the team has played.
A pattern of blocks will show on screen for a short amount of time.
Afterwards, you’ll have to select the pattern out of several options.
Guess correctly and your team gets a point.
You can phone a friend, but you’ll only get half a point.]] -- lol i didnt implement the phone a friend
end

function love.update(dt)
	if not bgsongintro:isPlaying() and not bgsongloop:isPlaying() then bgsongloop:play() end

	local mx,my = lm.getPosition()

	if gamestate == 'play' then
		if memstate == 'choose' then

		elseif memstate == 'countdown' then
			countdt = countdt + dt
			if countdt >= countmx then
				countdt = 0
				if countw <= #countwords then countw = countw + 1
				else
					if countv==1 then memstate='memorize'
					else memstate = 'choose' end
					countv = countv==1 and 2 or 1
					countw = 1
				end
			end
		elseif memstate == 'finnamem' then
			choosedt = choosedt + dt
			if choosedt >= choosemx then
				memstate = 'countdown'
				choosedt = 0
				genPattern()
				if chooseresult == '! YOU LOSE !' then
					gamestate = 'menu'
					memwins = 0
					memloss = 0
				end
			end
		elseif memstate == 'memorize' then
			memorizedt = memorizedt + dt
			if memorizedt >= memorizemx then
				memorizedt = 0
				memstate = 'countdown'
			end
		end
	elseif gamestate == 'menu' then
		local t = 0.5*sin(lt.getTime())
		if 268<=mx and mx<=332 and 268<=my and my<=328 then -- play button
			if bplayscale ~=2 then bplayscale  = bplayscale  + (2-bplayscale) *dt*4 end
			if bplayrotate~=t then bplayrotate = bplayrotate + (t-bplayrotate)*dt*4 end
		else
			if bplayscale ~=1 then bplayscale  = bplayscale  + (1-bplayscale) *dt*4 end
			if bplayrotate~=0 then bplayrotate = bplayrotate + (0-bplayrotate)*dt*4 end
		end
		if 468<=mx and mx<=532 and 268<=my and my<=328 then -- quit button
			if bquitscale ~=2 then bquitscale  = bquitscale  + (2-bquitscale) *dt*4 end
			if bquitrotate~=-t then bquitrotate = bquitrotate + (-t-bquitrotate)*dt*4 end
		else
			if bquitscale ~=1 then bquitscale  = bquitscale  + (1-bquitscale) *dt*4 end
			if bquitrotate~=0 then bquitrotate = bquitrotate + (0-bquitrotate)*dt*4 end
		end
		if 340<=mx and mx<=460 and 400<=my and my<=484 then -- explain button
			if bxplnscale~=2 then bxplnscale = bxplnscale + (2-bxplnscale)*dt*4 end
			if bxplnpos ~=abs(t*8) then bxplnpos = bxplnpos + (abs(t*8)-bxplnpos)*dt*4 end
		else
			if bxplnscale~=1 then bxplnscale = bxplnscale + (1-bxplnscale)*dt*4 end
			if bxplnpos  ~=0 then bxplnpos   = bxplnpos   + (0-bxplnpos)  *dt*4 end
		end
	elseif gamestate == 'explaining1' then

	end
end

function love.draw()
	local f = 115-math.floor(lt.getTime()*100)%115-1
	lg.setColor(180+f,0,180+f)
	lg.draw(vingette,400,300, 0,1,1, 400,300)
	lg.setColor(255,255,255)

	if gamestate == 'play' then
		local f = lg.getFont()
		local m = memstate
		if m == 'memorize' then
			local p
			for y=1,#patt do
				for x=1,#patt[y] do
					p = patt[y][x]
					lg.setColor(tetrocolor[p])
					lg.rectangle('fill', 32*x+400-96,32*y+300-96,32,32)
				end
			end
		elseif m == 'choose' then
			for i=1,#fixpat do
				lg.setColor(255,255,255)
				lg.print(i..'. ',  (i-1)*198+96,200)
				for y=1,4 do for x=1,4 do
					p = fixpat[i][y][x]
					lg.setColor(tetrocolor[p])
					lg.rectangle('fill', (i-1)*192+32*x+16,192+32*y,32,32)
				end end
			end
		elseif m == 'countdown' then
			lg.print(countwords[countv][countw], 400,300, 0,4,4, f:getWidth(countwords[countv][countw])/2,14/2)
		elseif m == 'finnamem' then
			if chooseresult == '! CORRECT !' then
				lg.setColor(tetrocolor[4])
				lg.print(chooseresult, 400,300-math.abs(40*sin(lt.getTime()*6)), 0,4,4, f:getWidth(chooseresult)/2,7)
			else
				lg.setColor(tetrocolor[1])
				lg.print(chooseresult, 400+4*sin(lt.getTime()*1000*math.pi),300, 0,4,4, f:getWidth(chooseresult)/2,7)
			end
		end
		lg.setColor(255,255,255)
		lg.printf('WINS\n'..memwins, 140,480, 32, 'center',0,4)
		lg.printf('LOSS\n'..memloss, 540,480, 32, 'center',0,4)
	elseif gamestate == 'menu' then
		lg.setColor(255,255,255)
		lg.draw(tetramemlogo, 400,200+8*sin(lt.getTime()*2), 0,1,1, tetramemlogo:getWidth()/2,tetramemlogo:getHeight()/2)

		lg.print('play',300,300, bplayrotate,bplayscale*2,nil, 16,7)
		lg.print('quit',500,300, bquitrotate,bquitscale*2,nil, 16,7)
		lg.printf('the\nscience\nof it',400,485+bxplnpos, 100,'center', 0,bxplnscale*2,nil, 50,42)
		
		lg.setColor(255,255,255,127)
		lg.rectangle('fill', 340,400,120,84)
		lg.rectangle('fill', 300-32,300-14, 64,28)
		lg.rectangle('fill', 500-32,300-14, 64,28)
	elseif gamestate == 'explaining1' then
		lg.setColor(255,255,255)
		lg.printf("HOW IT WORKS", 0,0, 200, 'center', 0,4)
		lg.printf(explanationscience, 30,80, 250,'left', 0,3)

		lg.print('back', 400,570, 0,2,nil, 16,7)
		lg.setColor(255,255,255,127)
		lg.rectangle('fill',400-34,570-14,68,28)
	end
end


function love.mousepressed(x,y)
	if gamestate == 'menu' then
		if 268<=x and x<=332 and 268<=y and y<=328 then gamestate= 'play' end
		if 468<=x and x<=532 and 268<=y and y<=328 then love.event.quit() end
		if 340<=x and x<=460 and 400<=y and y<=484 then gamestate='explaining1' end
	elseif gamestate == 'explaining1' then
		if 400-34<=x and x<=400+34 and 570-14<=y and y<=570+14 then gamestate = 'menu' end
	elseif gamestate == 'play' then
		if memstate == 'choose' then
			local cx,cy
			for i=1,#fixpat do for a=1,4 do for b=1,4 do
				cx = (i-1)*192+32*a+16
				cy = 192+32*b
				if cx<=x and x<=cx+32 and cy<=y and y<=cy+32 then choosechoice,choosedone = i,true end
			end end end
		end
		if choosedone then
			choosedone = false
			memstate = 'finnamem'
			chooseresult = choosechoice==correctpattern and '! CORRECT !' or 'WRONG.'
			if chooseresult == '! CORRECT !' then memwins = memwins + 1; memorizemx = memorizemx - memorizemx/10
			elseif chooseresult=='WRONG.'    then memloss = memloss + 1
			end
			if memloss == 3 then chooseresult = '! YOU LOSE !' end
			choosechoice = 0

		end
end end



function randomchoice(t)
	return t[math.random(#t)]
end

function genPattern()
	patt = {{},{},{},{}}
	for y=1,4 do
	for x=1,4 do
		patt[y][x] = math.random(1,7)--randomchoice({'I','T','J','L','O','S','Z'})
	end
	end

	fixpat = {}
	correctpattern = math.random(1,4)
	for i=1,4 do
		fixpat[i] = {}
		for y=1,4 do fixpat[i][y] = {}; for x=1,4 do
			fixpat[i][y][x] = patt[y][x]
			if i ~= correctpattern and math.random(1,3)==1 then
				fixpat[i][y][x] = fixpat[i][y][x] + randomchoice({1,-1})
				if fixpat[i][y][x] == 0 then fixpat[i][y][x] = 7 end
				if fixpat[i][y][x] == 8 then fixpat[i][y][x] = 1 end
			end
		end end
	end


	--[[
	patt = {{1,1,1,1},{3,3,4,4},{3,5,5,4},{3,5,5,4},}
	patt = {{0,0,6,0},{0,7,6,6},{7,7,2,6},{7,2,2,2},}
	patt = {{1,1,1,1},{4,4,4,3},{5,5,4,3},{5,5,3,3},}
	]]
end
