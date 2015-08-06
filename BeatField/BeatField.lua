--Beat Grid by Mattam Enigma
--Matt Fugere and Tamlyn Miller
--This code is released to the public domain.

PS_GRID_X = 8
PS_GRID_Y = 8

--Color/Alpha levels for the win button
winColor = 0x7ACC40
winAlpha1 = 25
winAlpha2 = 250

--Color of the reset button
resetColor = 0xED454A

winning = false --Start off as not winning
tutorialCount = 0 --Tutorial starts at the beginning
onResetButton = false --Player is not initially over the reset or next level buttons
onLevelButton = false

--Array containing instruments (set up in level files)
instrument = {}

--Array containing drum beats (set up in level files)
drum = {}
for i = 1, 6 do
	drum[i] = {}
end

--Timer for all the shooters in the level
sensorTimer = {}

--Level file names
levels = {}
levels[1] = "Earth.lua"
levels[2] = "Forest.lua"
levels[3] = "Sea.lua"
levels[4] = "Sky.lua"
levels[5] = "Volcano.lua"

--Total levels
totalLevels = 5
levelCount = 1


-- ps_init ()
-- Initializes the game
-- The ps_init() function MUST call ps_setup (x, y),
-- where x and y are the desired size of the grid.

-- Every game MUST include a ps_init() function, and that function MUST call ps_setup() with the x and y dimensions of the grid!
function ps_init ()
	ps_setup (PS_GRID_X, PS_GRID_Y)
	ps_settings(PS_BEAD_FLASH, 0)
	ps_settings(PS_MOUSE_MOTION, 1)
		
	generateLevel(levels[levelCount])

	ps_timer(1)
end

-- ps_click (x, y, data)
-- This function is called whenever a bead is clicked
-- x = the x-position of the bead on the grid
-- y = the y-position of the bead on the grid
-- data = the data value associated with this bead, 0 if none has been set

-- Every game MUST include a ps_click() function. It doesn't have to do anything.
function ps_click (x, y, data)
	--If the player clicks on a shooter, activate or deactivate it.
	if ps_alpha(x, y) == shooterOffAlpha then
		ps_alpha(x, y, shooterOnAlpha)
		ps_data(x, y, spawnSpeed)
		if ps_color(x, y-1) ~= drumColor then
			ps_color(x, y-1, instrumentColor)
			ps_data(x, y-1, instrumentSpeed)
		end
	elseif ps_alpha(x, y) == shooterOnAlpha then
		ps_alpha(x, y, shooterOffAlpha)
		
	--If the player clicks on the reset button, reset.
	elseif ps_color(x, y) == resetColor then
		reset()
		
	--If the player clicks on the next level button and they won the current level, go to the next
	elseif winning and ps_alpha(x,y) == winAlpha2 then
		levelCount = levelCount + 1
		if levelCount <= totalLevels then
			winning = false
			generateLevel(levels[levelCount])
		end
	end
end

-- ps_enter (x, y, data, button)
-- This function is called whenever the mouse over a bead
-- x = the x-position of the bead on the grid
-- y = the y-position of the bead on the grid
-- data = the data value associated with this bead, 0 if none has been set
-- button = 1 if mouse button is held down, else 0

-- This function MUST exist if mouse motion sensing has been enabled with ps_settings (PS_MOUSE_MOTION, 1).
-- It doesn't have to do anything.
function ps_enter (x, y, data, button)

	--If player is over a specific button, give the player instructions
	if ps_color(x, y) == resetColor then
		onResetButton = true
		ps_status = "boop"
	elseif ps_color(x, y) == winColor and winning == true and levelCount < totalLevels then
		onLevelButton = true
	else
		onResetButton = false
		onLevelButton = false
	end
end

-- ps_leave(x, y, data, button)
-- This function is called whenever the mouse moves away from a bead
-- x = the x-position of the bead on the grid
-- y = the y-position of the bead on the grid
-- data = the data value associated with this bead, 0 if none has been set
-- button = one of the following values:
-- PS_BUTTON_NONE if neither button was being held down
-- PS_BUTTON_LEFT if left button was being held down
-- PS_BUTTON_RIGHT if right button was being held down
-- PS_BUTTON_BOTH if both buttons were being held down

-- This function MUST exist if mouse motion sensing has been enabled with ps_settings (PS_MOUSE_MOTION, 1).
-- It doesn't have to do anything.
function ps_leave (x, y, data, button)

end

-- generateLevel()
--This function sets up a level from a level file
function generateLevel(fileName)
	dofile(PS_PATH..fileName)

	--Set up the window appropriately
	ps_gridlines(2, sensorColor)
	ps_window(600, 600, floorColor)
	
	--Clear the board
	for i = 0, PS_GRID_X-1 do
		for j = 0, PS_GRID_Y-1 do
			ps_color(i, j, floorColor)
			ps_border(i, j, 0)
		end
	end
	
	--Set up the drums on-screen
	for i = 1, 6 do
		if drum[i]["active"] then
			ps_color(drum[i]["start"], i, drumColor)
			ps_data(drum[i]["start"], i, drum[i]["speed"])
		end
		ps_color(i, PS_GRID_Y-1, shooterColor)
		ps_alpha(i, PS_GRID_Y-1, shooterOffAlpha)
	end
	
	--Place the next level/reset buttons
	ps_color(PS_GRID_X-1, PS_GRID_Y-1, winColor)
	ps_alpha(PS_GRID_X-1, PS_GRID_Y-1, winAlpha1)
	
	ps_color(0, PS_GRID_Y-1, resetColor)
end

-- ps_tick ()
-- This function is called on every clock tick

-- This function MUST exist if the timer has been activated with a call to ps_timer()
-- It doesn't have to do anything.
function ps_tick ()
	--Decide what to display in the message box
	if onResetButton == true then
		ps_message("Turn all note shooters off.")
	elseif winning == false then
		tutorialize()
	elseif onLevelButton == true then
		ps_message("Advance to the next level.")
	else
		if levelCount == totalLevels then
			ps_message("Congratulations! You have mastered the Beat Field!")
		else
			ps_message("You won!")
		end
	end

	--Decrement timers for all objects
	for i = 0, PS_GRID_X-1 do
		for j = 0, PS_GRID_Y-1 do
			if ps_color(i, j) == drumColor or ps_color(i, j) == instrumentColor or ps_alpha(i, j) == shooterOnAlpha then
				ps_data(i, j, ps_data(i, j)-1)
			end
		end
	end
	
	--Move everything appropriately
	moveDrums()
	moveInstruments()
	spawnInstrument()
	updateSensors()
end

--moveDrums()
--Moves the drums back and forth on the screen
function moveDrums()
	for i = 0, PS_GRID_X-1 do
		for j = 1, PS_GRID_Y-2 do
			if ps_color(i, j) == drumColor and ps_data(i, j) <= 0 then
				local curX = i
				--If it hits a wall, play a sound
				--Then make it move in the other direction
				if drum[j]["velocity"] == "right" then
					if i == PS_GRID_X-1 then
						ps_play(drum[j]["sound"])
						drum[j]["velocity"] = "left"
					else
						curX = curX + 1
					end
				else
					if i == 0 then
						ps_play(drum[j]["sound"])
						drum[j]["velocity"] = "right"
					else
						curX = curX - 1
					end
				end
				
				ps_color(i, j, floorColor)
				ps_color(curX, j, drumColor)
				ps_data(curX, j, drum[j]["speed"])
			end
		end
	end
end

--moveInstruments()
--Moves instrument shots upward, unless a drum is in the way
function moveInstruments()
	for i = 1, PS_GRID_X-2 do
		for j = 0, PS_GRID_Y-2 do
			if ps_color(i, j) == instrumentColor and ps_data(i, j) <= 0 then
				local curY = j
				if j == 0 then
					ps_play(instrument[i])
					ps_border(i, 0, 1)
					sensorTimer[i] = sensorSpeed
				elseif ps_color(i, j-1) ~= drumColor then
					curY = curY - 1
					ps_color(i, curY, instrumentColor)
					ps_data(i, curY, instrumentSpeed)
				end
				
				ps_color(i, j, floorColor)
			end
		end
	end
end

--spawnInstrument()
--Creates an instrument shot if there is an open space above the shooter
--Only creates shots when the timers are at 0
function spawnInstrument()
	for i = 1, 6 do
		if ps_data(i, PS_GRID_Y-1) == 0 and ps_alpha(i, PS_GRID_Y-1) == shooterOnAlpha then
			ps_data(i, PS_GRID_Y-1, spawnSpeed)
			if ps_color(i, PS_GRID_Y-2) ~= drumColor then
				ps_color(i, PS_GRID_Y-2, instrumentColor)
				ps_data(i, PS_GRID_Y-2, instrumentSpeed)
			end
		end
	end
end

--updateSensors()
--Checks to see if the sensors are activated 
--Also deactivates them when their time runs out
function updateSensors()
	winCount = 0
	for i = 1, 6 do
		if ps_border(i, 0) ~= 0 then
			winCount = winCount + 1
			sensorTimer[i] = sensorTimer[i] - 1
			
			if sensorTimer[i] == 0 then
				ps_border(i, 0, 0)
			end
		end
	end
	
	if winCount == 6 then
		win()
	end
end

--win()
--This function is called when the player wins a level.
function win()
	winning = true
	--If there is another level, make the next level button
	if levelCount < totalLevels then
		ps_alpha(PS_GRID_X-1, PS_GRID_Y-1, winAlpha2)
	end
end

--reset()
--Resets the level
function reset()
	generateLevel(levels[levelCount])
	winning = false
end

--tutorialize()
--Decide which part of the tutorial is displayed on the screen
function tutorialize()
	if levelCount == 1 then
		if tutorialCount < 40 then
			tutorial = "Beat Field (wait for tutorial) | "..levelTitle
		elseif tutorialCount < 80 then
			tutorial = "Click the dark blocks at the bottom to activate note shooters."
		elseif tutorialCount < 120 then
			tutorial = "Bright blocks shoot note blocks upward."
		elseif tutorialCount < 160 then
			tutorial = "Notes that hit the top trigger a sensor."
		elseif tutorialCount < 200 then
			tutorial = "When all sensors are triggered, you win."
		elseif tutorialCount < 240 then
			tutorial = "Drum blocks move back and forth."
		elseif tutorialCount < 280 then
			tutorial = "Drum blocks stop notes."
		elseif tutorialCount < 320 then
			tutorial = "Find the right rhythm to trigger all sensors."
		elseif tutorialCount >= 320 then
			tutorial = "Beat Field | "..levelTitle
			tutorialCount = 0
		end
		tutorialCount = tutorialCount + 1
	else
		tutorial = "Beat Field | "..levelTitle
	end

	ps_message(tutorial)
end




