-- Tether
-- by Mattam Enigma (Matt Fugere and Tamlyn Miller)
-- This code is released to the public domain

-- Grid size
PS_GRID_X = 25
PS_GRID_Y = 15

wallColor = 0x8F304C 
floorColor = 0xDF73AD
playerColor = 0x342DA8
holeColor = PS_BLACK
blockColor = 0xDF3333
tetherColor = 0xA768AB
door1Color = 0xFFC340
door2Color = 0xFFC341
door3Color = 0xFFC342
door4Color = 0xFFC343
door5Color = 0xFFC344

auraRange = 3

-- Level files
levelArray = {}
levelArray[0] = "tutorial1.lua"
levelArray[1] = "tutorial2.lua"
levelArray[2] = "tutorial3.lua"
levelArray[3] = "tutorial4.lua"
levelArray[4] = "level1.lua"
levelArray[5] = "level2.lua"
levelArray[6] = "level3.lua"
levelArray[7] = "level4.lua"
levelArray[8] = "level5.lua"
levelCount = 0

-- Level names
levelNames = {}
levelNames[0] = "First Steps"
levelNames[1] = "Two Holes in One"
levelNames[2] = "Mirrorrim"
levelNames[3] = "Open Door"
levelNames[4] = "Thinking with Holes"
levelNames[5] = "Rites of Passage"
levelNames[6] = "Red Tide"
levelNames[7] = "Adoorable"
levelNames[8] = "The Final Tear"
maxLevels = 9

p1_X = (PS_GRID_X-1)/4
p1_Y = PS_GRID_Y-2
p2_X = (PS_GRID_X-1)/4+(PS_GRID_X-1)/2
p2_Y = PS_GRID_Y-2

winning = false

tutorialCount = 0
tutorial = "Welcome to Tether. Would you like a tutorial? y/n"

-- Keep track of world's objects
worldMap = {}

-- What is the aura's shape (Square or diamond)?
auraSetting = 0

function ps_init ()
	ps_setup (PS_GRID_X, PS_GRID_Y)
	ps_settings(PS_KEY_CAPTURE,1)
	ps_settings(PS_BEAD_FLASH,0)
	ps_gridlines(1)
	ps_gridfont(1,"Webdings")
	ps_window(720,600,PS_BLACK)
	ps_message(tutorial)
	ps_status("Tether by Mattam Enigma: Matt Fugere and Tamlyn Miller")
	
	setupWorld(levelArray[0])
	
	drawAura(auraSetting)
	ps_timer(1)
end

--setupWorld(filename)
--Sets up the level
function setupWorld(filename)
	for x = 0, PS_GRID_X - 1 do
		worldMap[x]={}
		for y = 0, PS_GRID_Y-1 do
			worldMap[x][y] = {}
		end
	end
	
	--Creates base Walls and Floors
	for x = 0, PS_GRID_X-1 do
		for y = 0, PS_GRID_Y-1 do
			if x == (PS_GRID_X-1)/2
			   or x == 0 or x == PS_GRID_X-1
			   or y == 0 or y == PS_GRID_Y-1 then
				worldMap[x][y]["color"] = wallColor
			else
				worldMap[x][y]["color"] = floorColor
			end
		end
	end
	
	dofile(PS_PATH..filename)
	
	-- Puts glyphs down the middle to represent separate dimensions
	for x=0, PS_GRID_X - 1 do
		for y=0, PS_GRID_Y-1 do
			ps_color(x,y,worldMap[x][y]["color"])
			if notDoor(x,y) == false then
				ps_glyph(x,y,"x", PS_BLACK,1)
			end
		end
	end
	
	-- Divide the map
	for y = 0, PS_GRID_Y-1 do
		ps_glyph(12,y,"|",PS_BLACK)
	end
end

function ps_click (x, y, data)

end

--ps_key(val)
--Processes keystrokes
function ps_key (val)
	if winning == false then
		if val == PS_ARROW_UP then
			movePlayer2(0,-1)
		elseif val == PS_ARROW_DOWN then
			movePlayer2(0,1)
		elseif val == PS_ARROW_LEFT then
			movePlayer2(-1,0)
		elseif val == PS_ARROW_RIGHT then
			movePlayer2(1,0)
		elseif val == string.byte("w") then
			movePlayer1(0,-1)
		elseif val == string.byte("s") then
			movePlayer1(0,1)
		elseif val == string.byte("a") then
			movePlayer1(-1,0)
		elseif val == string.byte("d") then
			movePlayer1(1,0)
		elseif val == PS_F1 then
			progressTutorial()
		elseif val == string.byte("y") and tutorialCount == 0 then
			progressTutorial()
		elseif val == string.byte("n") and tutorialCount == 0 then
			tutorialCount = 13
			progressTutorial()
		end
	else
		if val == string.byte("p") and levelCount < maxLevels then
			winning = false
			for x = 0, PS_GRID_X-1 do
				for y = 0,PS_GRID_Y-1 do
					if x == (PS_GRID_X-1)/2
					   or x == 0 or x == PS_GRID_X-1
					   or y == 0 or y == PS_GRID_Y-1 then
						worldMap[x][y]["color"] = wallColor
					else
						worldMap[x][y]["color"] = floorColor
					end
				end
			end
			setupWorld(levelArray[levelCount])
			drawAura(auraSetting)
			progressTutorial()
		end
	end
	if val == string.byte("r") then
		reset()
	end
end

--progressTutorial()
--Changes the tutorial message
function progressTutorial()
	tutorialCount = tutorialCount + 1
	if tutorialCount == 1 then
		tutorial = "Two alternate dimensions have collided! (F1 to continue)"
	elseif tutorialCount == 2 then
		tutorial = "Fragments of the dimensions have been knocked loose. (F1 to continue)"
	elseif tutorialCount == 3 then
		tutorial = "You and alternate you must work together. (F1 to continue)"
	elseif tutorialCount == 4 then
		tutorial = "Push blocks into holes to patch up the dimensions. (F1 to continue)"
	elseif tutorialCount == 5 then
		tutorial = "Blocks are red, holes are black. (F1 to continue)"
	elseif tutorialCount == 6 then
		tutorial = "One problem: You are tethered to your alternate self. (F1 to continue)"
	elseif tutorialCount == 7 then
		tutorial = "Your aura (light blue) extends to the alternate dimension. (F1 to continue)"
	elseif tutorialCount == 8 then
		tutorial = "You can only move in your alternate self's aura. (F1 to continue)"
	elseif tutorialCount == 9 then
		tutorial = "Left Player (dark blue) moves with WASD. (F1 to continue)"
	elseif tutorialCount == 10 then
		tutorial = "Right Player (dark blue) moves with Arrow Keys. (F1 to continue)"
	elseif tutorialCount == 11 then
		tutorial = "If you get stuck, press 'r' to reset. (F1 to continue)"
	elseif tutorialCount == 12 then
		tutorial = "Help each other to patch the dimensions! (F1 to continue)"
	elseif tutorialCount == 6 then
		tutorial = "Some holes open doors ('no' symbol). (F1 to continue)"
	else
		tutorial = "Tether | "..levelNames[levelCount]
	end
	ps_message(tutorial)
end

--notDoor(x,y)
--Does the space have a door?
function notDoor(x,y)
	if ps_color(x,y) == door1Color then return false end
	if ps_color(x,y) == door2Color then return false end
	if ps_color(x,y) == door3Color then return false end
	if ps_color(x,y) == door4Color then return false end
	if ps_color(x,y) == door5Color then return false end
	return true
end

--movePlayer1(x,y)
--Move the first player
function movePlayer1(x,y)
	if ps_data(x+p1_X, y+p1_Y) == 1 
	   and ps_color(x+p1_X, y+p1_Y) ~= holeColor 
	   and ps_color(x+p1_X, y+p1_Y) ~= wallColor 
	   and notDoor(x+p1_X, y+p1_Y) then
		if ps_color(x+p1_X, y+p1_Y) == blockColor
		   and vacant(x+p1_X, y+p1_Y, x, y) then
			moveBlock(x+p1_X, y+p1_Y, x, y)
			p1_X = p1_X + x
			p1_Y = p1_Y + y
			drawAura(auraSetting)
		elseif ps_color(x+p1_X, y+p1_Y) ~= blockColor then
			p1_X = p1_X + x
			p1_Y = p1_Y + y
			drawAura(auraSetting)
		end
	end
end

--movePlayer2(x,y)
--Move the second player
function movePlayer2(x,y)
	if ps_data(x+p2_X, y+p2_Y) == 1 
	   and ps_color(x+p2_X, y+p2_Y) ~= holeColor 
	   and ps_color(x+p2_X, y+p2_Y) ~= wallColor
	   and notDoor(x+p2_X, y+p2_Y) then
		if ps_color(x+p2_X, y+p2_Y) == blockColor
		   and vacant(x+p2_X, y+p2_Y, x, y) then
			moveBlock(x+p2_X, y+p2_Y, x, y)
			p2_X = p2_X + x
			p2_Y = p2_Y + y
			drawAura(auraSetting)
		elseif ps_color(x+p2_X, y+p2_Y) ~= blockColor then
			p2_X = p2_X + x
			p2_Y = p2_Y + y
			drawAura(auraSetting)
		end
	end
end

--vacant(oldX, oldY, addX, addY)
--Determines if a block can be pushed onto a space
function vacant(oldX, oldY, addX, addY)
	if ps_color(oldX+addX, oldY+addY) == floorColor
	   or ps_color(oldX+addX, oldY+addY) == tetherColor
	   or ps_color(oldX+addX, oldY+addY) == holeColor then
		return true
	else
		return false
	end
end

--moveBlock(oldX, oldY, addX, addY)
--Move a block
function moveBlock(oldX, oldY, addX, addY)
	if ps_color(oldX+addX, oldY+addY) == holeColor then
		removeDoor(worldMap[oldX+addX][oldY+addY]["door"])
		ps_color(oldX,oldY, floorColor)
		ps_color(oldX+addX,oldY+addY, floorColor)
		if music_count < (beats_per_measure*4 + 0)* ticks_per_beat then
			ps_play("L_Hchord_G5")
		else
			ps_play("L_Hchord_C5")
		end
	else
		ps_play("Click")
		ps_color(oldX+addX, oldY+addY, blockColor)
	end
end

--removeDoor(color)
--Remove the corresponding hole's door (ID'd by color)
function removeDoor(color)
	if color ~= "none" then
		for x=0,PS_GRID_X-1 do
			for y=0,PS_GRID_Y-1 do
				if ps_color(x,y) == color then
					ps_color(x,y,floorColor)
					ps_glyph(x,y," ")
				end
			end
		end
	end
end

--reset()
--Resets the current level
function reset()
	p1_X = (PS_GRID_X-1)/4
	p1_Y = PS_GRID_Y-2
	p2_X = (PS_GRID_X-1)/4+(PS_GRID_X-1)/2
	p2_Y = PS_GRID_Y-2
	
	for x = 0, PS_GRID_X-1 do
		for y = 0,PS_GRID_Y-1 do
			if x == (PS_GRID_X-1)/2
			   or x == 0 or x == PS_GRID_X-1
			   or y == 0 or y == PS_GRID_Y-1 then
				ps_color(x, y, wallColor)
			else
				ps_color(x, y, floorColor)
			end
		end
	end
	
	setupWorld(levelArray[levelCount])
	
	drawAura(auraSetting)
end

--win()
--Win rewards (Music and text)
function win()
	winning = true
	ps_play("Cymbal_Ride",255)
	tutorialCount = 13
	
	if music_count < (beats_per_measure*4 + 0)* ticks_per_beat then
		ps_play("L_Hchord_G5")
		ps_play("L_Hchord_B5")
		ps_play("L_Hchord_D5")
		ps_play("L_Hchord_F5")
	else
		ps_play("L_Hchord_C5")
		ps_play("L_Hchord_E5")
		ps_play("L_Hchord_G5")
		ps_play("L_Hchord_B5")
	end
	levelCount = levelCount + 1
	if levelCount >= maxLevels then
		ps_message("The dimensions are sealed, for now. You won!")
	else
		ps_message("The dimensions are sealed, for now. Press 'p' for next level.")
	end
	for x=1,PS_GRID_X-2 do
		for y=1,PS_GRID_Y-2 do
			if ps_color(x,y) == tetherColor then
				ps_color(x,y,floorColor)
			end
		end
	end
end

function ps_enter (x, y, data, button)
	
end

function ps_leave (x, y, data, button)
	
end

--ps_tick()
--Plays the music one beat per tick
function ps_tick ()
	play_music()
end

--drawAura(shape)
--Draws the aura around both players, either in a diamond shape or square
function drawAura(shape)
	holeCounter = 0
	for x = 0, PS_GRID_X-1 do
		for y = 0,PS_GRID_Y-1 do
			if ps_color(x,y) == holeColor then
				holeCounter = holeCounter + 1
			end
		end
	end
	
	if holeCounter > 0 then
		ps_color(p1_X, p1_Y, playerColor)
		ps_color(p2_X, p2_Y, playerColor)
		if shape == 1 then
			for x = 0,PS_GRID_X-1 do
				for y = 0,PS_GRID_Y-1 do
					if (x < p2_X - (PS_GRID_X-1)/2 + auraRange
					   and x > p2_X - (PS_GRID_X-1)/2 - auraRange
					   and y < p2_Y + auraRange
					   and y > p2_Y - auraRange
					   and x < (PS_GRID_X-1)/2)
					   or
					   (x < p1_X + (PS_GRID_X-1)/2 + auraRange
					   and x > p1_X + (PS_GRID_X-1)/2 - auraRange
					   and x > (PS_GRID_X-1)/2
					   and y < p1_Y + auraRange
					   and y > p1_Y - auraRange) then
						ps_data(x,y,1)
						if ps_color(x,y) == floorColor
						   or ps_color(x,y) == tetherColor
						   or (ps_color(x,y) == playerColor and (x ~= p2_X or y ~= p2_Y) and (x ~= p1_X or y ~= p1_Y)) then
							ps_color(x,y,tetherColor)
						end
					else
						ps_data(x,y,0)
						if ps_color(x,y) == tetherColor then
							ps_color(x,y,floorColor)
						end
					end
				end
			end
		else
			for x = 0,PS_GRID_X-1 do
				for y = 0,PS_GRID_Y-1 do
					if (math.abs(p2_X - (PS_GRID_X-1)/2 - x) + math.abs(p2_Y-y)< auraRange
					   and x < (PS_GRID_X-1)/2)
					   or (math.abs(p1_X + (PS_GRID_X-1)/2 - x) + math.abs(p1_Y-y)< auraRange
					   and x > (PS_GRID_X-1)/2) then
						ps_data(x,y,1)
						if ps_color(x,y) == floorColor
						   or ps_color(x,y) == tetherColor 
						   or (ps_color(x,y) == playerColor and (x ~= p2_X or y ~= p2_Y) and (x ~= p1_X or y ~= p1_Y)) then
							ps_color(x,y,tetherColor)
						end
					else
						ps_data(x,y,0)
						if ps_color(x,y) == tetherColor then
							ps_color(x,y,floorColor)
						end
					end
				end
			end
		end
	else
		win()
	end
end

--Music stuff (change these variables only if you change the song)
--How many engine ticks per beat (quarter note)
ticks_per_beat = 2
--How many beats per measure
beats_per_measure = 6 --it's in 3/4 time
--How many measures until it repeats
total_measures = 8
music_count = 0 --Keeps track of current ticks
first_time = true --Whether the music has played through once already

normalVolume = 70
melodyVolume = 130

--play_music()
--This function plays the music of the game.
function play_music ()
	--If it's time to repeat, reset the count
	if music_count >= ticks_per_beat * beats_per_measure * total_measures then
		music_count = 0
	end
	
	--This if statement is for the melody
	if music_count == (beats_per_measure*0 + 0)* ticks_per_beat then
		ps_play("L_Piano_F3",normalVolume)
	elseif music_count == (beats_per_measure*0 + 1)* ticks_per_beat then
	elseif music_count == (beats_per_measure*0 + 2)* ticks_per_beat then
		ps_play("L_Piano_G3",normalVolume)
		ps_play("L_Piano_F3",normalVolume/2)
		ps_play("Triangle",normalVolume)
	elseif music_count == (beats_per_measure*0 + 3)* ticks_per_beat then
	elseif music_count == (beats_per_measure*0 + 4)* ticks_per_beat then
		ps_play("L_Piano_B3",normalVolume)
		ps_play("L_Piano_G3",normalVolume/2)
		ps_play("L_Piano_F3",normalVolume/4)
		ps_play("Triangle",normalVolume/2)
	elseif music_count == (beats_per_measure*0 + 5)* ticks_per_beat then
	elseif music_count == (beats_per_measure*1 + 0)* ticks_per_beat then
		ps_play("L_Piano_F3",normalVolume)
		ps_play("L_Piano_B3",normalVolume/2)
		ps_play("L_Piano_G3",normalVolume/4)
		ps_play("Triangle",normalVolume/4)
	elseif music_count == (beats_per_measure*1 + 1)* ticks_per_beat then
	elseif music_count == (beats_per_measure*1 + 2)* ticks_per_beat then
		ps_play("L_Piano_G3",normalVolume)
		ps_play("L_Piano_F3",normalVolume/2)
		ps_play("L_Piano_B3",normalVolume/4)
	elseif music_count == (beats_per_measure*1 + 3)* ticks_per_beat then
	elseif music_count == (beats_per_measure*1 + 4)* ticks_per_beat then
		ps_play("L_Piano_B3",normalVolume)
		ps_play("L_Piano_G3",normalVolume/2)
		ps_play("L_Piano_F3",normalVolume/4)
		ps_play("Triangle",normalVolume)
	elseif music_count == (beats_per_measure*1 + 5)* ticks_per_beat then
	elseif music_count == (beats_per_measure*2 + 0)* ticks_per_beat then
		ps_play("L_Piano_F3",normalVolume)
		ps_play("L_Piano_B3",normalVolume/2)
		ps_play("L_Piano_G3",normalVolume/4)
		ps_play("Triangle",normalVolume/2)
	elseif music_count == (beats_per_measure*2 + 1)* ticks_per_beat then
	elseif music_count == (beats_per_measure*2 + 2)* ticks_per_beat then
		ps_play("L_Piano_G3",normalVolume)
		ps_play("L_Piano_F3",normalVolume/2)
		ps_play("L_Piano_B3",normalVolume/4)
		ps_play("Triangle",normalVolume/4)
	elseif music_count == (beats_per_measure*2 + 3)* ticks_per_beat then
	elseif music_count == (beats_per_measure*2 + 4)* ticks_per_beat then
		ps_play("L_Piano_B3",normalVolume)
		ps_play("L_Piano_G3",normalVolume/2)
		ps_play("L_Piano_F3",normalVolume/4)
	elseif music_count == (beats_per_measure*2 + 5)* ticks_per_beat then
	elseif music_count == (beats_per_measure*3 + 0)* ticks_per_beat then
		ps_play("L_Piano_F3",normalVolume)
		ps_play("L_Piano_B3",normalVolume/2)
		ps_play("L_Piano_G3",normalVolume/4)
		ps_play("Triangle",normalVolume)
	elseif music_count == (beats_per_measure*3 + 1)* ticks_per_beat then
	elseif music_count == (beats_per_measure*3 + 2)* ticks_per_beat then
		ps_play("L_Piano_G3",normalVolume)
		ps_play("L_Piano_F3",normalVolume/2)
		ps_play("L_Piano_B3",normalVolume/4)
		ps_play("Triangle",normalVolume/2)
	elseif music_count == (beats_per_measure*3 + 3)* ticks_per_beat then
	elseif music_count == (beats_per_measure*3 + 4)* ticks_per_beat then
		ps_play("L_Piano_B3",normalVolume)
		ps_play("L_Piano_G3",normalVolume/2)
		ps_play("L_Piano_F3",normalVolume/4)
		ps_play("Triangle",normalVolume/4)
	elseif music_count == (beats_per_measure*3 + 5)* ticks_per_beat then
	elseif music_count == (beats_per_measure*4 + 0)* ticks_per_beat then
		ps_play("L_Piano_C3",normalVolume)
		ps_play("L_Piano_B3",normalVolume/2)
		ps_play("L_Piano_G3",normalVolume/4)
	elseif music_count == (beats_per_measure*4 + 1)* ticks_per_beat then
	elseif music_count == (beats_per_measure*4 + 2)* ticks_per_beat then
		ps_play("L_Piano_E3",normalVolume)
		ps_play("L_Piano_C3",normalVolume/2)
		ps_play("L_Piano_B3",normalVolume/4)
		ps_play("Triangle",normalVolume)
	elseif music_count == (beats_per_measure*4 + 3)* ticks_per_beat then
	elseif music_count == (beats_per_measure*4 + 4)* ticks_per_beat then
		ps_play("L_Piano_B3",normalVolume)
		ps_play("L_Piano_E3",normalVolume/2)
		ps_play("L_Piano_C3",normalVolume/4)
		ps_play("Triangle",normalVolume/2)
	elseif music_count == (beats_per_measure*4 + 5)* ticks_per_beat then
	elseif music_count == (beats_per_measure*5 + 0)* ticks_per_beat then
		ps_play("L_Piano_C3",normalVolume)
		ps_play("L_Piano_B3",normalVolume/2)
		ps_play("L_Piano_E3",normalVolume/4)
		ps_play("Triangle",normalVolume/4)
	elseif music_count == (beats_per_measure*5 + 1)* ticks_per_beat then
	elseif music_count == (beats_per_measure*5 + 2)* ticks_per_beat then
		ps_play("L_Piano_E3",normalVolume)
		ps_play("L_Piano_C3",normalVolume/2)
		ps_play("L_Piano_B3",normalVolume/4)
	elseif music_count == (beats_per_measure*5 + 3)* ticks_per_beat then
	elseif music_count == (beats_per_measure*5 + 4)* ticks_per_beat then
		ps_play("L_Piano_B3",normalVolume)
		ps_play("L_Piano_E3",normalVolume/2)
		ps_play("L_Piano_C3",normalVolume/4)
		ps_play("Triangle",normalVolume)
	elseif music_count == (beats_per_measure*5 + 5)* ticks_per_beat then
	elseif music_count == (beats_per_measure*6 + 0)* ticks_per_beat then
		ps_play("L_Piano_C3",normalVolume)
		ps_play("L_Piano_B3",normalVolume/2)
		ps_play("L_Piano_E3",normalVolume/4)
		ps_play("Triangle",normalVolume/2)
	elseif music_count == (beats_per_measure*6 + 1)* ticks_per_beat then
	elseif music_count == (beats_per_measure*6 + 2)* ticks_per_beat then
		ps_play("L_Piano_E3",normalVolume)
		ps_play("L_Piano_C3",normalVolume/2)
		ps_play("L_Piano_B3",normalVolume/4)
		ps_play("Triangle",normalVolume/4)
	elseif music_count == (beats_per_measure*6 + 3)* ticks_per_beat then
	elseif music_count == (beats_per_measure*6 + 4)* ticks_per_beat then
		ps_play("L_Piano_B3",normalVolume)
		ps_play("L_Piano_E3",normalVolume/2)
		ps_play("L_Piano_C3",normalVolume/4)
	elseif music_count == (beats_per_measure*6 + 5)* ticks_per_beat then
	elseif music_count == (beats_per_measure*7 + 0)* ticks_per_beat then
		ps_play("L_Piano_C3",normalVolume)
		ps_play("L_Piano_B3",normalVolume/2)
		ps_play("L_Piano_E3",normalVolume/4)
		ps_play("Triangle",normalVolume)
	elseif music_count == (beats_per_measure*7 + 1)* ticks_per_beat then
	elseif music_count == (beats_per_measure*7 + 2)* ticks_per_beat then
		ps_play("L_Piano_E3",normalVolume)
		ps_play("L_Piano_C3",normalVolume/2)
		ps_play("L_Piano_B3",normalVolume/4)
		ps_play("Triangle",normalVolume/2)
	elseif music_count == (beats_per_measure*7 + 3)* ticks_per_beat then
		ps_play("L_Hchord_A6",melodyVolume,255)
	elseif music_count == (beats_per_measure*7 + 4)* ticks_per_beat then
		ps_play("L_Piano_B3",normalVolume)
		ps_play("L_Piano_E3",normalVolume/2)
		ps_play("L_Piano_C3",normalVolume/4)
		ps_play("L_Piano_C4",melodyVolume)
		ps_play("L_Hchord_B6",melodyVolume,210)
		ps_play("Triangle",normalVolume/4)
	elseif music_count == (beats_per_measure*7 + 5)* ticks_per_beat then
		ps_play("L_Hchord_C7",melodyVolume,170)
		ps_play("L_Hchord_A6",melodyVolume/2,170)
		first_time = false
	end
	
	if first_time == false then
		if music_count == (beats_per_measure*0 + 0)* ticks_per_beat then
			ps_play("L_Piano_B3",normalVolume/2)
			ps_play("L_Piano_E3",normalVolume/4)
			ps_play("L_Piano_B4",melodyVolume)
			ps_play("L_Piano_C4",melodyVolume/2)
			ps_play("L_Hchord_B6",melodyVolume/2, 130)
		elseif music_count == (beats_per_measure*0 + 1)* ticks_per_beat then
			ps_play("L_Hchord_C7",melodyVolume/2,90)
			ps_play("L_Hchord_A6",melodyVolume/4,90)
		elseif music_count == (beats_per_measure*0 + 2)* ticks_per_beat then
			ps_play("L_Piano_B3",normalVolume/4)
			ps_play("L_Piano_B4",melodyVolume/2)
			ps_play("L_Piano_C4",melodyVolume/4)
			ps_play("L_Hchord_B6",melodyVolume/4,50)
		elseif music_count == (beats_per_measure*0 + 3)* ticks_per_beat then
			ps_play("L_Hchord_C7",melodyVolume/4,0)
		elseif music_count == (beats_per_measure*0 + 4)* ticks_per_beat then
			ps_play("L_Piano_B4",melodyVolume/4)
			ps_play("Drum_Snare",150)
		elseif music_count == (beats_per_measure*0 + 5)* ticks_per_beat then
			ps_play("Drum_Snare",130)
		elseif music_count == (beats_per_measure*1 + 0)* ticks_per_beat then
			ps_play("Drum_Snare",110)
		elseif music_count == (beats_per_measure*1 + 1)* ticks_per_beat then
			ps_play("Drum_Snare",90)
		elseif music_count == (beats_per_measure*1 + 2)* ticks_per_beat then
			ps_play("Drum_Snare",70)
			ps_play("Drum_Tom4",70)
		elseif music_count == (beats_per_measure*1 + 3)* ticks_per_beat then
			ps_play("Drum_Snare",70)
			ps_play("Drum_Tom4",70)
		elseif music_count == (beats_per_measure*1 + 4)* ticks_per_beat then
			ps_play("Drum_Snare",70)
			ps_play("Drum_Tom4",70)
		elseif music_count == (beats_per_measure*1 + 5)* ticks_per_beat then
		elseif music_count == (beats_per_measure*2 + 0)* ticks_per_beat then
		elseif music_count == (beats_per_measure*2 + 1)* ticks_per_beat then
		elseif music_count == (beats_per_measure*2 + 2)* ticks_per_beat then
		elseif music_count == (beats_per_measure*2 + 3)* ticks_per_beat then
		elseif music_count == (beats_per_measure*2 + 4)* ticks_per_beat then
		elseif music_count == (beats_per_measure*2 + 5)* ticks_per_beat then
		elseif music_count == (beats_per_measure*3 + 0)* ticks_per_beat then
			ps_play("L_Piano_A4",melodyVolume,0)
		elseif music_count == (beats_per_measure*3 + 1)* ticks_per_beat then
		elseif music_count == (beats_per_measure*3 + 2)* ticks_per_beat then
			ps_play("L_Piano_A4",melodyVolume/2,50)
		elseif music_count == (beats_per_measure*3 + 3)* ticks_per_beat then
		elseif music_count == (beats_per_measure*3 + 4)* ticks_per_beat then
			ps_play("L_Piano_A4",melodyVolume/4,90)
			ps_play("L_Piano_G4",melodyVolume,90)
		elseif music_count == (beats_per_measure*3 + 5)* ticks_per_beat then
			ps_play("L_Piano_F4",melodyVolume,130)
		elseif music_count == (beats_per_measure*4 + 0)* ticks_per_beat then
			ps_play("L_Piano_D4",melodyVolume,170)
			ps_play("L_Piano_G4",melodyVolume/2,170)
		elseif music_count == (beats_per_measure*4 + 1)* ticks_per_beat then
			ps_play("L_Piano_F4",melodyVolume/2,210)
		elseif music_count == (beats_per_measure*4 + 2)* ticks_per_beat then
			ps_play("L_Piano_D4",melodyVolume/2,230)
			ps_play("L_Piano_G4",melodyVolume/4,230)
		elseif music_count == (beats_per_measure*4 + 3)* ticks_per_beat then
			ps_play("L_Piano_F4",melodyVolume/4,255)
		elseif music_count == (beats_per_measure*4 + 4)* ticks_per_beat then
			ps_play("L_Piano_D4",melodyVolume/4,255)
			ps_play("Drum_Snare",150)
		elseif music_count == (beats_per_measure*4 + 5)* ticks_per_beat then
			ps_play("Drum_Snare",130)
		elseif music_count == (beats_per_measure*5 + 0)* ticks_per_beat then
			ps_play("Drum_Snare",110)
		elseif music_count == (beats_per_measure*5 + 1)* ticks_per_beat then
			ps_play("Drum_Snare",90)
		elseif music_count == (beats_per_measure*5 + 2)* ticks_per_beat then
			ps_play("Drum_Snare",70)
			ps_play("Drum_Tom4",70)
		elseif music_count == (beats_per_measure*5 + 3)* ticks_per_beat then
			ps_play("Drum_Snare",70)
			ps_play("Drum_Tom4",70)
		elseif music_count == (beats_per_measure*5 + 4)* ticks_per_beat then
			ps_play("Drum_Snare",70)
			ps_play("Drum_Tom4",70)
		elseif music_count == (beats_per_measure*5 + 5)* ticks_per_beat then
		elseif music_count == (beats_per_measure*6 + 0)* ticks_per_beat then
		elseif music_count == (beats_per_measure*6 + 1)* ticks_per_beat then
		elseif music_count == (beats_per_measure*6 + 2)* ticks_per_beat then
		elseif music_count == (beats_per_measure*6 + 3)* ticks_per_beat then
		elseif music_count == (beats_per_measure*6 + 4)* ticks_per_beat then
		elseif music_count == (beats_per_measure*6 + 5)* ticks_per_beat then
		elseif music_count == (beats_per_measure*7 + 0)* ticks_per_beat then
		elseif music_count == (beats_per_measure*7 + 1)* ticks_per_beat then
		elseif music_count == (beats_per_measure*7 + 2)* ticks_per_beat then
		elseif music_count == (beats_per_measure*7 + 3)* ticks_per_beat then
		elseif music_count == (beats_per_measure*7 + 4)* ticks_per_beat then
		elseif music_count == (beats_per_measure*7 + 5)* ticks_per_beat then
		end
	end
	
	--Increment the number of ticks that have happened
	music_count = music_count + 1
end




