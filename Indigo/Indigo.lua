-- Indigo: The Pucening
-- by Mattam Enigma (Matt Fugere and Tamlyn Miller)
-- This code is released to the public domain

--Grid Size
PS_GRID_X = 13
PS_GRID_Y = 13

--Size of the whole world (in beads)
worldMaxX = 51
worldMaxY = 51

--Half the grid size (makes math easier later on)
halfGridX = (PS_GRID_X-1)/2
halfGridY = (PS_GRID_Y-1)/2

--Here is the world map.
worldMap = {}

wallColor = PS_BLACK -- The color of the walls outside of the map
puceColor = PS_VIOLET -- The color of puce, the spreading purple goo
playerColor = PS_RED -- The player's color
indigoonColor = PS_INDIGO -- The color of Indigoons

-- Possible colors for the random terrain
worldColors = {}
worldColors[1] = ps_rgb(160,160,160)
worldColors[2] = ps_rgb(170,170,170)
worldColors[3] = ps_rgb(180,180,180)
worldColors[4] = ps_rgb(190,190,190)

timePassed = 0 -- How much time has passed since the start of the game
score = 0 -- How many kills the player has obtained
spawnTime = 50 --How many ticks before another spawn
spawnCount = 0 --How many ticks thus far

puceChanceToSpread = 2 -- How likely each puce block is to spawn more puce
puceChanceToBreed = 0.5 -- How likely each puce block is to spawn an Indigoon

playerPos_X = (worldMaxX-1)/2 - 2
playerPos_Y = (worldMaxY-1)/2
playerMove_X = 0
playerMove_Y = 0
shootSpeed = 3 -- How fast a bullet is
shootCooldown = 0
rechargeTime = 5

havePower = false -- Does the player have a power?

-- Power-up information
puceMissileCount = 0
puceMissileColor = PS_WHITE

invincibleTimer = 0
invincibleColor = PS_YELLOW

multishotCount = 0
multishotColor = PS_BLACK

iceShotCount = 0
iceShotColor = PS_CYAN

pierceShotCount = 0
pierceShotColor = PS_RED

playerGlyphColor = PS_BLACK -- The color of the player's directional arrow

-- The default bullet color/glyph
bulletGlyph = "R"
bulletColor = PS_ORANGE

iceTimer = 0 -- How long before the ice will melt
iceMaxTime = 100

-- House information
houses = {}
maxHouses = 5
houseGlyph = "H"
houseColor = PS_GREEN
currHouseColor = houseColor
bonusCounter = 0 -- How long before power-ups will become available
maxBonusCounter = 100 

losing = false -- Has the player lost?

tutorial = "Move with arrow keys. | "
tutorialCount = 0 -- How long before the last tutorial item will reset to its default
tutorialCountdown = 100

indigoonSpeed = 5 -- How quickly Indigoons move

function ps_init ()
	ps_setup (PS_GRID_X, PS_GRID_Y)
	ps_settings(PS_KEY_CAPTURE,1)
	ps_settings(PS_BEAD_FLASH,0)
	ps_font(PS_MESSAGE_BOX, 16, PS_WHITE)
	ps_window(600,600,PS_BLACK)
	ps_gridlines(0)
	ps_gridfont(1,"Wingdings")
	ps_gridfont(2,"Webdings")
	ps_gridfont(3,"Wingdings 3")
	ps_status("Indigo: The Pucening by Mattam Enigma: Matt Fugere and Tamlyn Miller")
	
	-- Create the walls and terrain
	for x = 0, worldMaxX-1 do
		worldMap[x]= {} --Make the world a 2d array
		for y = 0, worldMaxY-1 do
			worldMap[x][y] = {} --Make the world a 3d array
			if x < (PS_GRID_X-1)/2 
			   or y < (PS_GRID_Y-1)/2 
			   or x >= worldMaxX - (PS_GRID_X-1)/2
			   or y >= worldMaxY - (PS_GRID_Y-1)/2 then
			   --If the spot is on the outside, make it a wall
				worldMap[x][y]["color"] = wallColor
			else
			   --Otherwise, make it a random world color
				worldMap[x][y]["color"] = worldColors[ps_random(4)] 
			end
			--Make all the glyphs look the same to start
			worldMap[x][y]["glyph"] = " "
			worldMap[x][y]["glyphcolor"] = PS_BLACK
			worldMap[x][y]["font"] = 1
		end
	end
	
	-- Initialize the house table
	for i = 0, maxHouses do
		houses[i] = {}
	end
	
	-- Create the houses
	i = 0
	while i < maxHouses do
		currX, currY = ps_random(worldMaxX) - 1, ps_random(worldMaxY) - 1
		--If the space is open for a house to exist, then place a house
		if worldMap[currX][currY]["color"] ~= puceColor 
		   and worldMap[currX][currY]["color"] ~= wallColor 
		   and worldMap[currX][currY]["glyph"] ~= houseGlyph
		   and (currX ~= playerPos_X or currY ~= playerPos_Y) then
			i = i + 1
			houses[i]["x"] = currX
			houses[i]["y"] = currY
			worldMap[currX][currY]["glyph"] = houseGlyph
			worldMap[currX][currY]["glyphcolor"] = houseColor
			worldMap[currX][currY]["font"] = 2
			--Give the house a powerup
			if i == 1 then
				worldMap[currX][currY]["bonusColor"] = puceMissileColor
			elseif i == 2 then
				worldMap[currX][currY]["bonusColor"] = invincibleColor
			elseif i == 3 then
				worldMap[currX][currY]["bonusColor"] = iceShotColor
			elseif i == 4 then
				worldMap[currX][currY]["bonusColor"] = pierceShotColor
			else
				worldMap[currX][currY]["bonusColor"] = multishotColor
			end
		end
	end
	
	-- Create the initial puce block, which cannot be destroyed
	worldMap[(worldMaxX-1)/2][(worldMaxY-1)/2]["color"] = puceColor
	worldMap[(worldMaxX-1)/2][(worldMaxY-1)/2]["glyph"] = "S"
	worldMap[(worldMaxX-1)/2][(worldMaxY-1)/2]["glyphcolor"] = houseColor
	worldMap[(worldMaxX-1)/2][(worldMaxY-1)/2]["font"] = 2
	
	-- Create the player's glyph
	ps_glyph(halfGridX, halfGridY, "h", playerGlyphColor, 3)
	
	-- Update the grid and start the timer
	updateGrid()
	ps_timer(1)
end

--Unused
function ps_click (x, y, data)

end

function ps_key (val)
	if losing == false then
		-- If the player's arrow and the direction pressed match up, move in that direction
		-- If not, change the arrow direction
		if val == PS_ARROW_UP then
			if tutorialCount == 0 then
				tutorial = "Shoot bullets with the spacebar. | "
				tutorialCount = tutorialCount + 1
			end
			if ps_glyph(halfGridX, halfGridY) == string.byte("h") then
				playerMove_Y = -1
			else
				ps_glyph(halfGridX, halfGridY, "h", playerGlyphColor, 3)
			end
		elseif val == PS_ARROW_DOWN then
			if tutorialCount == 0 then
				tutorial = "Shoot bullets with the spacebar. | "
				tutorialCount = tutorialCount + 1
			end
			if ps_glyph(halfGridX, halfGridY) == string.byte("i") then
				playerMove_Y = 1
			else
				ps_glyph(halfGridX, halfGridY, "i", playerGlyphColor, 3)
			end
		elseif val == PS_ARROW_LEFT then
			if tutorialCount == 0 then
				tutorial = "Shoot bullets with the spacebar. | "
				tutorialCount = tutorialCount + 1
			end
			if ps_glyph(halfGridX, halfGridY) == string.byte("f") then
				playerMove_X = -1
			else
				ps_glyph(halfGridX, halfGridY, "f", playerGlyphColor, 3)
			end
		elseif val == PS_ARROW_RIGHT then
			if tutorialCount == 0 then
				tutorial = "Shoot bullets with the spacebar. | "
				tutorialCount = tutorialCount + 1
			end
			if ps_glyph(halfGridX, halfGridY) == string.byte("g") then
				playerMove_X = 1
			else
				ps_glyph(halfGridX, halfGridY, "g", playerGlyphColor, 3)
			end
		-- If the spacebar is pressed, fire a bullet
		elseif val == string.byte(" ") then
			if tutorialCount == 1 then
				tutorial = "Avoid Indigoons (Skulls). Houses have powerups. Stay alive! | "
				tutorialCount = tutorialCount + 1
			end
			if shootCooldown == 0 then
				shootCooldown = rechargeTime
				ps_play("Conga_High")
				-- Multishot fires in all directions
				if multishotCount > 0 then
					if worldMap[playerPos_X][playerPos_Y - 1]["color"] ~= iceShotColor 
					   and worldMap[playerPos_X][playerPos_Y - 1]["color"] ~= puceColor 
					   and worldMap[playerPos_X][playerPos_Y - 1]["color"] ~= wallColor 
					   and worldMap[playerPos_X][playerPos_Y - 1]["glyph"] ~= houseGlyph then
						worldMap[playerPos_X][playerPos_Y - 1]["bullet"] = true
						worldMap[playerPos_X][playerPos_Y - 1]["bulletVelocity"] = "up"
						worldMap[playerPos_X][playerPos_Y - 1]["bulletColor"] = multishotColor
						ps_glyph(halfGridX, halfGridY - 1, bulletGlyph, worldMap[playerPos_X][playerPos_Y-1]["bulletColor"], 1)
					end
					if worldMap[playerPos_X][playerPos_Y + 1]["color"] ~= iceShotColor 
					   and worldMap[playerPos_X][playerPos_Y + 1]["color"] ~= puceColor 
					   and worldMap[playerPos_X][playerPos_Y + 1]["color"] ~= wallColor 
					   and worldMap[playerPos_X][playerPos_Y + 1]["glyph"] ~= houseGlyph then
						worldMap[playerPos_X][playerPos_Y + 1]["bullet"] = true
						worldMap[playerPos_X][playerPos_Y + 1]["bulletVelocity"] = "down"
						worldMap[playerPos_X][playerPos_Y + 1]["bulletColor"] = multishotColor
						ps_glyph(halfGridX, halfGridY + 1, bulletGlyph, worldMap[playerPos_X][playerPos_Y-1]["bulletColor"], 1)
					end
					if worldMap[playerPos_X-1][playerPos_Y]["color"] ~= iceShotColor 
					   and worldMap[playerPos_X-1][playerPos_Y]["color"] ~= puceColor 
					   and worldMap[playerPos_X-1][playerPos_Y]["color"] ~= wallColor 
					   and worldMap[playerPos_X-1][playerPos_Y]["glyph"] ~= houseGlyph then
						worldMap[playerPos_X-1][playerPos_Y]["bullet"] = true
						worldMap[playerPos_X-1][playerPos_Y]["bulletVelocity"] = "left"
						worldMap[playerPos_X-1][playerPos_Y]["bulletColor"] = multishotColor
						ps_glyph(halfGridX-1, halfGridY, bulletGlyph, worldMap[playerPos_X][playerPos_Y-1]["bulletColor"], 1)
					end
					if worldMap[playerPos_X+1][playerPos_Y]["color"] ~= iceShotColor 
					   and worldMap[playerPos_X+1][playerPos_Y]["color"] ~= puceColor 
					   and worldMap[playerPos_X+1][playerPos_Y]["color"] ~= wallColor 
					   and worldMap[playerPos_X+1][playerPos_Y]["glyph"] ~= houseGlyph then
						worldMap[playerPos_X+1][playerPos_Y]["bullet"] = true
						worldMap[playerPos_X+1][playerPos_Y]["bulletVelocity"] = "right"
						worldMap[playerPos_X+1][playerPos_Y]["bulletColor"] = multishotColor
						ps_glyph(halfGridX+1, halfGridY, bulletGlyph, worldMap[playerPos_X][playerPos_Y-1]["bulletColor"], 1)
					end
					multishotCount = multishotCount - 1
				-- Normal shots fire in the player's arrow's direction
				elseif ps_glyph(halfGridX, halfGridY) == string.byte("h") 
				   and worldMap[playerPos_X][playerPos_Y - 1]["color"] ~= iceShotColor 
				   and worldMap[playerPos_X][playerPos_Y - 1]["color"] ~= puceColor 
				   and worldMap[playerPos_X][playerPos_Y - 1]["color"] ~= wallColor 
				   and worldMap[playerPos_X][playerPos_Y - 1]["glyph"] ~= houseGlyph then
					worldMap[playerPos_X][playerPos_Y - 1]["bullet"] = true
					worldMap[playerPos_X][playerPos_Y - 1]["bulletVelocity"] = "up"
					if puceMissileCount > 0 then
						worldMap[playerPos_X][playerPos_Y - 1]["bulletColor"] = puceMissileColor
					elseif iceShotCount > 0 then
						worldMap[playerPos_X][playerPos_Y - 1]["bulletColor"] = iceShotColor
					elseif pierceShotCount > 0 then
						worldMap[playerPos_X][playerPos_Y - 1]["bulletColor"] = pierceShotColor
					else
						worldMap[playerPos_X][playerPos_Y - 1]["bulletColor"] = bulletColor
					end
					ps_glyph(halfGridX, halfGridY - 1, bulletGlyph, worldMap[playerPos_X][playerPos_Y-1]["bulletColor"], 1)
				elseif ps_glyph(halfGridX, halfGridY) == string.byte("i") 
				   and worldMap[playerPos_X][playerPos_Y + 1]["color"] ~= iceShotColor 
				   and worldMap[playerPos_X][playerPos_Y +1]["color"] ~= puceColor 
				   and worldMap[playerPos_X][playerPos_Y + 1]["color"] ~= wallColor 
				   and worldMap[playerPos_X][playerPos_Y + 1]["glyph"] ~= houseGlyph then
					worldMap[playerPos_X][playerPos_Y + 1]["bullet"] = true
					worldMap[playerPos_X][playerPos_Y + 1]["bulletVelocity"] = "down"
					if puceMissileCount > 0 then
						worldMap[playerPos_X][playerPos_Y + 1]["bulletColor"] = puceMissileColor
					elseif iceShotCount > 0 then
						worldMap[playerPos_X][playerPos_Y + 1]["bulletColor"] = iceShotColor
					elseif pierceShotCount > 0 then
						worldMap[playerPos_X][playerPos_Y + 1]["bulletColor"] = pierceShotColor
					else
						worldMap[playerPos_X][playerPos_Y + 1]["bulletColor"] = bulletColor
					end
					ps_glyph(halfGridX, halfGridY + 1, bulletGlyph, worldMap[playerPos_X][playerPos_Y+1]["bulletColor"], 1)
				elseif ps_glyph(halfGridX, halfGridY) == string.byte("f") 
				   and worldMap[playerPos_X-1][playerPos_Y]["color"] ~= iceShotColor 
				   and worldMap[playerPos_X-1][playerPos_Y]["color"] ~= puceColor 
				   and worldMap[playerPos_X-1][playerPos_Y]["color"] ~= wallColor 
				   and worldMap[playerPos_X-1][playerPos_Y]["glyph"] ~= houseGlyph then
					worldMap[playerPos_X - 1][playerPos_Y]["bullet"] = true
					worldMap[playerPos_X - 1][playerPos_Y]["bulletVelocity"] = "left"
					if puceMissileCount > 0 then
						worldMap[playerPos_X - 1][playerPos_Y]["bulletColor"] = puceMissileColor
					elseif iceShotCount > 0 then
						worldMap[playerPos_X - 1][playerPos_Y]["bulletColor"] = iceShotColor
					elseif pierceShotCount > 0 then
						worldMap[playerPos_X - 1][playerPos_Y]["bulletColor"] = pierceShotColor
					else
						worldMap[playerPos_X - 1][playerPos_Y]["bulletColor"] = bulletColor
					end
					ps_glyph(halfGridX - 1, halfGridY, bulletGlyph, worldMap[playerPos_X-1][playerPos_Y]["bulletColor"], 1)
				elseif ps_glyph(halfGridX, halfGridY) == string.byte("g") 
				   and worldMap[playerPos_X+1][playerPos_Y]["color"] ~= iceShotColor 
				   and worldMap[playerPos_X+1][playerPos_Y]["color"] ~= puceColor 
				   and worldMap[playerPos_X+1][playerPos_Y]["color"] ~= wallColor 
				   and worldMap[playerPos_X+1][playerPos_Y]["glyph"] ~= houseGlyph then
					worldMap[playerPos_X + 1][playerPos_Y]["bullet"] = true
					worldMap[playerPos_X + 1][playerPos_Y]["bulletVelocity"] = "right"
					if puceMissileCount > 0 then
						worldMap[playerPos_X + 1][playerPos_Y]["bulletColor"] = puceMissileColor
					elseif iceShotCount > 0 then
						worldMap[playerPos_X + 1][playerPos_Y]["bulletColor"] = iceShotColor
					elseif pierceShotCount > 0 then
						worldMap[playerPos_X + 1][playerPos_Y]["bulletColor"] = pierceShotColor
					else
						worldMap[playerPos_X + 1][playerPos_Y]["bulletColor"] = bulletColor
					end
					ps_glyph(halfGridX + 1, halfGridY, bulletGlyph, worldMap[playerPos_X+1][playerPos_Y]["bulletColor"], 1)
				end
				
				-- Decrement the power-up bullet count
				if puceMissileCount > 0 then
					puceMissileCount = puceMissileCount - 1
				end
				if iceShotCount > 0 then
					iceShotCount = iceShotCount - 1
				end
				if pierceShotCount > 0 then
					pierceShotCount = pierceShotCount - 1
				end
			end
		end
	end
	
	-- Reset the game
	if val == string.byte("r") then
		reset()
	end
end

function moveIndigoons()
	--Clear the worldMap of "data"
	for x = 0, worldMaxX - 1 do
		for y = 0, worldMaxY - 1 do
			worldMap[x][y]["data"] = 0
		end
	end
	
	-- Move all Indigoons on the map
	for x = 0, worldMaxX - 1 do
		for y = 0, worldMaxY - 1 do
			-- If the space has an Indigoon
			if worldMap[x][y]["glyph"] == "N" then
				-- If a bullet hits an Indigoon, destroy both unless it's a pierce shot
				if worldMap[x][y]["bullet"] == true then
					if worldMap[x][y]["bulletColor"] ~= pierceShotColor then
						worldMap[x][y]["bullet"] = false
					end
					worldMap[x][y]["glyph"] = " "
					ps_play("Pop")
					score = score + 1
				-- If not, move the Indigoon towards the player
				else
					currX = x
					currY = y
					
					rand = ps_random(2)
					if rand == 1 then
						if x > playerPos_X then
							currX = currX - 1
						elseif x < playerPos_X then
							currX = currX + 1
						end
					else
						if y > playerPos_Y then
							currY = currY - 1
						elseif y < playerPos_Y then
							currY = currY + 1
						end
					end
					
					-- Update glyphs accordingly
					if worldMap[x][y]["data"] == 0 and worldMap[currX][currY]["glyph"] ~= "N" and worldMap[currX][currY]["glyph"] ~= "S" and worldMap[currX][currY]["glyph"] ~= houseGlyph then
						worldMap[x][y]["glyph"] = " "					
						worldMap[currX][currY]["glyph"] = "N"
						worldMap[currX][currY]["glyphcolor"] = indigoonColor
						worldMap[currX][currY]["font"] = 1
						worldMap[currX][currY]["data"] = 1
					-- If the Indigoon walks onto a house, it becomes a new puce/Indigoon spawn point
					elseif worldMap[currX][currY]["glyph"] == houseGlyph then
						worldMap[x][y]["glyph"] = " "
						worldMap[currX][currY]["color"] = puceColor
					end
				end
			end
		end
	end
end

function moveBullets()
	--Clear the worldMap of "data"
	for x = 0, worldMaxX - 1 do
		for y = 0, worldMaxY - 1 do
			worldMap[x][y]["data"] = 0
		end
	end
	
	-- Move all bullets on the map
	for x = 0, worldMaxX - 1 do
		for y = 0, worldMaxY - 1 do
			-- If the current space has a bullet
			if worldMap[x][y]["bullet"] == true then
				-- If it hits an Indigoon, destroy both unless it's a pierce shot
				if worldMap[x][y]["glyph"] == "N" then
					ps_play("Pop")
					if worldMap[x][y]["bulletColor"] ~= pierceShotColor then
						worldMap[x][y]["bullet"] = false
					end
					worldMap[x][y]["glyph"] = " "
					score = score + 1
				-- Move the bullet over a space depending on its direction (velocity)
				elseif worldMap[x][y]["data"] == 0 then
					if worldMap[x][y]["bulletVelocity"] == "up"
					   and worldMap[x][y-1]["color"] ~= wallColor
					   and worldMap[x][y-1]["glyph"] ~= houseGlyph 
					   and worldMap[x][y-1]["glyph"] ~= "S" then
					    -- If puce is hit
						if worldMap[x][y-1]["color"] == puceColor then
							-- Puce missiles destroy it
							if worldMap[x][y]["bulletColor"] == puceMissileColor then
								worldMap[x][y-1]["color"] = worldColors[ps_random(4)]
								ps_play("Cymbal_Hihat_Pedal")
							-- Ice shots freeze it so it can't spawn or breed
							elseif worldMap[x][y]["bulletColor"] == iceShotColor then
								worldMap[x][y-1]["color"] = iceShotColor
								iceTimer = iceMaxTime
								ps_play("Cowbell_High")
							end
							-- Destroy the bullet
							worldMap[x][y]["bullet"] = false
						else
							worldMap[x][y]["bullet"] = false
							worldMap[x][y-1]["bullet"] = true
							worldMap[x][y-1]["bulletVelocity"] = "up"
							worldMap[x][y-1]["bulletColor"] = worldMap[x][y]["bulletColor"]
							worldMap[x][y-1]["data"] = 1
						end
					elseif worldMap[x][y]["bulletVelocity"] == "down" 
					   and worldMap[x][y+1]["color"] ~= wallColor
					   and worldMap[x][y+1]["glyph"] ~= houseGlyph 
					   and worldMap[x][y+1]["glyph"] ~= "S" then
						if worldMap[x][y+1]["color"] == puceColor then
							if worldMap[x][y]["bulletColor"] == puceMissileColor then
								worldMap[x][y+1]["color"] = worldColors[ps_random(4)]
								ps_play("Cymbal_Hihat_Pedal")
							elseif worldMap[x][y]["bulletColor"] == iceShotColor then
								worldMap[x][y+1]["color"] = iceShotColor
								iceTimer = iceMaxTime
								ps_play("Cowbell_High")
							end
							worldMap[x][y]["bullet"] = false
						else
							worldMap[x][y]["bullet"] = false
							worldMap[x][y+1]["bullet"] = true
							worldMap[x][y+1]["bulletVelocity"] = "down"
							worldMap[x][y+1]["bulletColor"] = worldMap[x][y]["bulletColor"]
							worldMap[x][y+1]["data"] = 1
						end
					elseif worldMap[x][y]["bulletVelocity"] == "left" 
					and worldMap[x-1][y]["color"] ~= wallColor
					and worldMap[x-1][y]["glyph"] ~= houseGlyph 
					and worldMap[x-1][y]["glyph"] ~= "S" then
						if worldMap[x-1][y]["color"] == puceColor then
							if worldMap[x][y]["bulletColor"] == puceMissileColor then
								worldMap[x-1][y]["color"] = worldColors[ps_random(4)]
								ps_play("Cymbal_Hihat_Pedal")
							elseif worldMap[x][y]["bulletColor"] == iceShotColor then
								worldMap[x-1][y]["color"] = iceShotColor
								iceTimer = iceMaxTime
								ps_play("Cowbell_High")
							end
							worldMap[x][y]["bullet"] = false
						else
							worldMap[x][y]["bullet"] = false
							worldMap[x-1][y]["bullet"] = true
							worldMap[x-1][y]["bulletVelocity"] = "left"
							worldMap[x-1][y]["bulletColor"] = worldMap[x][y]["bulletColor"]
							worldMap[x-1][y]["data"] = 1
						end
					elseif worldMap[x][y]["bulletVelocity"] == "right" 
					and worldMap[x+1][y]["color"] ~= wallColor
					and worldMap[x+1][y]["glyph"] ~= houseGlyph 
					and worldMap[x+1][y]["glyph"] ~= "S" then
						if worldMap[x+1][y]["color"] == puceColor then
							if worldMap[x][y]["bulletColor"] == puceMissileColor then
								worldMap[x+1][y]["color"] = worldColors[ps_random(4)]
								ps_play("Cymbal_Hihat_Pedal")
							elseif worldMap[x][y]["bulletColor"] == iceShotColor then
								worldMap[x+1][y]["color"] = iceShotColor
								iceTimer = iceMaxTime
								ps_play("Cowbell_High")
							end
							worldMap[x][y]["bullet"] = false
						else
							worldMap[x][y]["bullet"] = false
							worldMap[x+1][y]["bullet"] = true
							worldMap[x+1][y]["bulletVelocity"] = "right"
							worldMap[x+1][y]["bulletColor"] = worldMap[x][y]["bulletColor"]
							worldMap[x+1][y]["data"] = 1
						end
					else
						worldMap[x][y]["bullet"] = false -- If it hits a wall
					end
				end
			end
		end
	end
end

function updatePlayer(currX,currY)
	-- Move the player unless there's a wall/puce/bullet in the way
	if worldMap[currX][currY]["color"] ~= wallColor 
	   and worldMap[currX][currY]["color"] ~= puceColor 
	   and worldMap[currX][currY]["color"] ~= iceShotColor
	   and worldMap[currX][currY]["bullet"] ~= true then
		playerPos_X = currX
		playerPos_Y = currY
		-- If the player walks onto a house and it's a power-up color, get that power-up
		if worldMap[playerPos_X][playerPos_Y]["glyph"] == houseGlyph and bonusCounter >= maxBonusCounter then
			havePower = true
			ps_play("Ding")
			bonusCounter = 0
			if worldMap[playerPos_X][playerPos_Y]["glyphcolor"] == puceMissileColor then
				puceMissileCount = 10
				tutorialCount = 3
				tutorial = "Puce Missile: Destroy blocks of puce. | "
			elseif worldMap[playerPos_X][playerPos_Y]["glyphcolor"] == multishotColor then
				multishotCount = 10
				tutorialCount = 3
				tutorial = "Multishot: Shoot in all directions. | "
			elseif worldMap[playerPos_X][playerPos_Y]["glyphcolor"] == iceShotColor then
				iceShotCount = 1
				tutorialCount = 3
				tutorial = "Ice Shot: Freeze blocks of puce. | "
			elseif worldMap[playerPos_X][playerPos_Y]["glyphcolor"] == pierceShotColor then
				pierceShotCount = 5
				tutorialCount = 3
				tutorial = "Pierce Shot: Shoot through a line of Indigoons. | "
			elseif worldMap[playerPos_X][playerPos_Y]["glyphcolor"] == invincibleColor then
				invincibleTimer = 100
				tutorialCount = 3
				tutorial = "Invincibility: Immunity to Indigoons. | "
			end
		end
	end
	playerMove_X = 0
	playerMove_Y = 0
end

function updatePowers()
	-- The player is invincible for the duration of the timer
	if invincibleTimer > 0 then
		playerColor = invincibleColor
		invincibleTimer = invincibleTimer - 1
	else
		playerColor = PS_RED
	end
	if multishotCount == 0 and pierceShotCount == 0 and iceShotCount == 0 and invincibleTimer == 0 and puceMissileCount == 0 then
		havePower = false
		if tutorialCount == 3 then
			tutorial = "Indigo: The Pucening | "
		end
	end
end

--Returns true if the location is touching frozen puce
function touchingFrozenPuce(x,y)
	if worldMap[x][y-1]["color"] == iceShotColor
	   or worldMap[x][y+1]["color"] == iceShotColor
	   or worldMap[x-1][y]["color"] == iceShotColor
	   or worldMap[x+1][y]["color"] == iceShotColor then
		return true
	else
		return false
	end
end

function pucefaction()
	--Clear the worldMap of "data"
	for x = 0, worldMaxX - 1 do
		for y = 0, worldMaxY - 1 do
			worldMap[x][y]["data"] = 0
		end
	end
	
	-- All puce blocks on the map have a chance to spawn puce/Indigoons
	for x = 0, worldMaxX - 1 do
		for y = 0, worldMaxY - 1 do
			if worldMap[x][y]["color"] == puceColor then
				if touchingFrozenPuce(x,y) then
					worldMap[x][y]["color"] = iceShotColor
				else
					randNum = ps_random(1000)
					if randNum <= 10*puceChanceToSpread then
						randNum = ps_random(4)
						spawnX = x
						spawnY = y
						if randNum == 1 then --Spawn a Puce up
							spawnY = spawnY - 1
						elseif randNum == 2 then --Spawn a Puce down
							spawnY = spawnY + 1
						elseif randNum == 3 then --Spawn a Puce left
							spawnX = spawnX - 1
						else --Spawn a Puce right
							spawnX = spawnX + 1
						end
						
						worldMap[x][y]["data"] = 1
						
						if worldMap[spawnX][spawnY]["color"] ~= puceColor 
						   and worldMap[spawnX][spawnY]["color"] ~= wallColor 
						   and worldMap[spawnX][spawnY]["color"] ~= iceShotColor 
						   and (x~=playerPos_X or y~=playerPos_Y) then
							worldMap[spawnX][spawnY]["color"] = puceColor
							worldMap[spawnX][spawnY]["data"] = 1
							ps_play("Bubble")
						end
					--If it doesn't spawn a Puce, it might spawn an indigoon on itself
					elseif randNum <= 10*(puceChanceToSpread + puceChanceToBreed) 
					   and worldMap[x][y]["glyph"] ~= "N" 
					   and worldMap[x][y]["glyph"] ~= houseGlyph 
					   and worldMap[x][y]["glyph"] ~= "S" then
						worldMap[x][y]["glyph"] = "N"
						worldMap[x][y]["glyphcolor"] = indigoonColor
						worldMap[x][y]["font"] = 1
						ps_play("Chirp1")
					end
				end
			end
		end
	end
end

function updateGrid()
	-- Update all spaces on the grid for new colors/glyphs/etc.
	for x = 0, PS_GRID_X-1 do
		for y = 0, PS_GRID_Y-1 do
			worldX = x + playerPos_X - (PS_GRID_X-1)/2
			worldY = y + playerPos_Y - (PS_GRID_Y-1)/2
			if x == (PS_GRID_X-1)/2 and y == (PS_GRID_Y-1)/2 then
				ps_color(x,y,playerColor)
			else
				if worldMap[worldX][worldY]["color"] == iceShotColor and iceTimer <= 0 then
					worldMap[worldX][worldY]["color"] = puceColor
				end
				
				ps_color(x,y,worldMap[worldX][worldY]["color"])
				if worldMap[worldX][worldY]["bullet"] == true then
					ps_glyph(x,y,bulletGlyph,worldMap[worldX][worldY]["bulletColor"],1)
				else
					if worldMap[worldX][worldY]["glyph"] == houseGlyph then
						if bonusCounter >= maxBonusCounter then
							worldMap[worldX][worldY]["glyphcolor"] = worldMap[worldX][worldY]["bonusColor"]
						else
							worldMap[worldX][worldY]["glyphcolor"] = houseColor
						end						
					end
					ps_glyph(x,y,worldMap[worldX][worldY]["glyph"],worldMap[worldX][worldY]["glyphcolor"],worldMap[worldX][worldY]["font"])
				end
			end
			test1, test2 = ps_gridfont(1)
		end
	end
	
	-- If the player isn't invincible and hits an Indigoon or puce spawns on it, he loses
	if (invincibleTimer == 0 and worldMap[playerPos_X][playerPos_Y]["glyph"] == "N") or worldMap[playerPos_X][playerPos_Y]["color"] == puceColor then
		lose()
	end
end

function ps_tick ()
	-- Call update functions and increment/decrement timers
	
	--Play the music
	play_music()
	
	--Lower the shoot cooldown
	if shootCooldown > 0 then
		shootCooldown = shootCooldown - 1
	end
	
	--Increase the time passed
	timePassed = timePassed + 1
	totalTime = timePassed/10
	
	--Display appropriate tutorial/score
	ps_message(tutorial .. "Kills: ".. score)
	
	--If you don't have a power, increment the bonus counter
	if havePower == false then
		bonusCounter = bonusCounter + 1
	end
	
	--Reduce frozen blocks
	iceTimer = iceTimer - 1
	
	--Move the player
	updatePlayer(playerPos_X + playerMove_X, playerPos_Y + playerMove_Y)
	
	--Spread the puce
	pucefaction()
	
	--Check to see if tutorials are done
	if tutorialCount == 2 then
		tutorialCountdown = tutorialCountdown - 1
		if tutorialCountdown == 0 then
			tutorialCount = 3
			tutorial = "Indigo: The Pucening | "
		end
	end
	
	--Move indigoons, if it's time
	if timePassed % indigoonSpeed == 0 then
		moveIndigoons()
	end
	
	--Move bullets, if it's time
	if timePassed % shootSpeed == 0 then
		moveBullets()
	end
	
	--Update power stats 
	updatePowers()
	
	--Update the world and display
	updateGrid()
end

--Resets the game
function reset ()
	timePassed = 0
	spawnTime = 50
	spawnCount = 0
	score = 0
	
	puceMissileCount = 0
	invincibleTimer = 0
	multishotCount = 0
	iceShotCount = 0
	pierceShotCount = 0
	
	iceTimer = 0
	
	music_count = 0
	first_time = true
	playerPos_X = (worldMaxX-1)/2 - 2
	playerPos_Y = (worldMaxY-1)/2

	losing = false
	
	currHouseColor = houseColor
	bonusCounter = 0
	
	for x = 0, worldMaxX-1 do
		worldMap[x]= {}
		for y = 0, worldMaxY-1 do
			worldMap[x][y] = {}
			if x < (PS_GRID_X-1)/2 
			   or y < (PS_GRID_Y-1)/2 
			   or x >= worldMaxX - (PS_GRID_X-1)/2
			   or y >= worldMaxY - (PS_GRID_Y-1)/2 then
				worldMap[x][y]["color"] = wallColor
			else
				worldMap[x][y]["color"] = worldColors[ps_random(4)] 
			end
			worldMap[x][y]["glyph"] = " "
			worldMap[x][y]["glyphcolor"] = PS_BLACK
			worldMap[x][y]["font"] = 1
		end
	end
	
	for i = 0, maxHouses do
		houses[i] = {}
	end
	
	i = 0
	while i < maxHouses do
		currX, currY = ps_random(worldMaxX) - 1, ps_random(worldMaxY) - 1
		
		if worldMap[currX][currY]["color"] ~= puceColor 
		   and worldMap[currX][currY]["color"] ~= wallColor 
		   and worldMap[currX][currY]["glyph"] ~= houseGlyph
		   and (currX ~= playerPos_X or currY ~= playerPos_Y) then
			i = i + 1
			houses[i]["x"] = currX
			houses[i]["y"] = currY
			worldMap[currX][currY]["glyph"] = houseGlyph
			worldMap[currX][currY]["glyphcolor"] = houseColor
			worldMap[currX][currY]["font"] = 2
			if i == 1 then
				worldMap[currX][currY]["bonusColor"] = puceMissileColor
			elseif i == 2 then
				worldMap[currX][currY]["bonusColor"] = invincibleColor
			elseif i == 3 then
				worldMap[currX][currY]["bonusColor"] = iceShotColor
			elseif i == 4 then
				worldMap[currX][currY]["bonusColor"] = pierceShotColor
			else
				worldMap[currX][currY]["bonusColor"] = multishotColor
			end
		end
	end
	
	worldMap[(worldMaxX-1)/2][(worldMaxY-1)/2]["color"] = puceColor
	worldMap[(worldMaxX-1)/2][(worldMaxY-1)/2]["glyph"] = "S"
	worldMap[(worldMaxX-1)/2][(worldMaxY-1)/2]["glyphcolor"] = houseColor
	worldMap[(worldMaxX-1)/2][(worldMaxY-1)/2]["font"] = 2
	
	ps_glyph(halfGridX, halfGridY, "h", playerGlyphColor, 3)
	
	updateGrid()
	ps_timer(1)
end

--Called when you lose.
function lose ()
	ps_timer(0)
	ps_play("L_Piano_Eb1")
	ps_play("L_Piano_Eb2")
	ps_play("L_Piano_Eb3")
	ps_play("Cymbal_Crash2")
	losing = true
	for x = 0, PS_GRID_X-1 do
		for y = 0, PS_GRID_Y-1 do
			ps_color(x, y, puceColor)
			ps_glyph(x, y, ' ')
		end
	end
	local totalTime = timePassed / 10
	ps_message("You have been pucified! Press 'r' to restart. | Kills: " .. score .. " | Time survived: " .. totalTime .. " seconds.")
end


--Music stuff (change these variables only if you change the song)
--How many engine ticks per beat (quarter note)
ticks_per_beat = 2
--How many beats per measure
beats_per_measure = 8 --it's in 4/4 time
--How many measures until it repeats
total_measures = 8
music_count = 0 --Keeps track of current ticks
first_time = true --Whether the music has played through once already

normalVolume = 150
melodyVolume = 220

--play_music()
--This function plays the music of the game.
function play_music ()
	--If it's time to repeat, reset the count
	if music_count >= ticks_per_beat * beats_per_measure * total_measures then
		music_count = 0
	end
	
	--This if statement is for the melody
	if music_count == (beats_per_measure*0 + 0)* ticks_per_beat then
		ps_play("Piano_Eb2",normalVolume)
		ps_play("Piano_Eb6",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*0 + 1)* ticks_per_beat then
		ps_play("Piano_Bb2",normalVolume)
		ps_play("Piano_F6",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*0 + 2)* ticks_per_beat then
		ps_play("Piano_Eb2",normalVolume)
		ps_play("Piano_Gb6",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Drum_Snare",200)
	elseif music_count == (beats_per_measure*0 + 3)* ticks_per_beat then
		ps_play("Piano_Bb2",normalVolume)
		ps_play("Piano_Eb6",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
		ps_play("Drum_Snare",150)
	elseif music_count == (beats_per_measure*0 + 4)* ticks_per_beat then
		ps_play("Piano_Eb2",normalVolume)
		ps_play("Piano_F6",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*0 + 5)* ticks_per_beat then
		ps_play("Piano_Bb2",normalVolume)
		ps_play("Piano_Gb6",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*0 + 6)* ticks_per_beat then
		ps_play("Piano_Eb2",normalVolume)
		ps_play("Piano_Eb6",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Drum_Snare",200)
	elseif music_count == (beats_per_measure*0 + 7)* ticks_per_beat then
		ps_play("Piano_Bb2",normalVolume)
		ps_play("Piano_F6",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*1 + 0)* ticks_per_beat then
		ps_play("Piano_Eb2",normalVolume)
		ps_play("Piano_Gb6",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*1 + 1)* ticks_per_beat then
		ps_play("Piano_Bb2",normalVolume)
		ps_play("Piano_Eb6",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*1 + 2)* ticks_per_beat then
		ps_play("Piano_Eb2",normalVolume)
		ps_play("Piano_F6",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Drum_Snare",200)
	elseif music_count == (beats_per_measure*1 + 3)* ticks_per_beat then
		ps_play("Piano_Bb2",normalVolume)
		ps_play("Piano_Gb6",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
		ps_play("Drum_Snare",150)
	elseif music_count == (beats_per_measure*1 + 4)* ticks_per_beat then
		ps_play("Piano_Eb2",normalVolume)
		ps_play("Piano_Eb6",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*1 + 5)* ticks_per_beat then
		ps_play("Piano_Bb2",normalVolume)
		ps_play("Piano_F6",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*1 + 6)* ticks_per_beat then
		ps_play("Piano_Eb2",normalVolume)
		ps_play("L_Piano_Gb6",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Drum_Snare",200)
	elseif music_count == (beats_per_measure*1 + 7)* ticks_per_beat then
		ps_play("Piano_Bb2",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*2 + 0)* ticks_per_beat then
		ps_play("Piano_B1",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*2 + 1)* ticks_per_beat then
		ps_play("Piano_Gb2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*2 + 2)* ticks_per_beat then
		ps_play("Piano_B1",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Drum_Snare",200)
	elseif music_count == (beats_per_measure*2 + 3)* ticks_per_beat then
		ps_play("Piano_Gb2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
		ps_play("Drum_Snare",150)
	elseif music_count == (beats_per_measure*2 + 4)* ticks_per_beat then
		ps_play("Piano_B1",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*2 + 5)* ticks_per_beat then
		ps_play("Piano_Gb2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*2 + 6)* ticks_per_beat then
		ps_play("Piano_B1",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Drum_Snare",200)
	elseif music_count == (beats_per_measure*2 + 7)* ticks_per_beat then
		ps_play("Piano_Gb2",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*3 + 0)* ticks_per_beat then
		ps_play("Piano_Gb2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*3 + 1)* ticks_per_beat then
		ps_play("Piano_Db3",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*3 + 2)* ticks_per_beat then
		ps_play("Piano_Gb2",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Drum_Snare",200)
	elseif music_count == (beats_per_measure*3 + 3)* ticks_per_beat then
		ps_play("Piano_Db3",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
		ps_play("Drum_Snare",150)
	elseif music_count == (beats_per_measure*3 + 4)* ticks_per_beat then
		ps_play("Piano_Gb2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*3 + 5)* ticks_per_beat then
		ps_play("Piano_Db3",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*3 + 6)* ticks_per_beat then
		ps_play("Piano_Gb2",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Drum_Snare",200)
	elseif music_count == (beats_per_measure*3 + 7)* ticks_per_beat then
		ps_play("Piano_Db3",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*4 + 0)* ticks_per_beat then
		ps_play("Piano_Eb2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*4 + 1)* ticks_per_beat then
		ps_play("Piano_Bb2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*4 + 2)* ticks_per_beat then
		ps_play("Piano_Eb2",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Drum_Snare",200)
	elseif music_count == (beats_per_measure*4 + 3)* ticks_per_beat then
		ps_play("Piano_Bb2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
		ps_play("Drum_Snare",150)
	elseif music_count == (beats_per_measure*4 + 4)* ticks_per_beat then
		ps_play("Piano_Eb2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*4 + 5)* ticks_per_beat then
		ps_play("Piano_Bb2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*4 + 6)* ticks_per_beat then
		ps_play("Piano_Eb2",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Drum_Snare",200)
	elseif music_count == (beats_per_measure*4 + 7)* ticks_per_beat then
		ps_play("Piano_Bb2",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*5 + 0)* ticks_per_beat then
		ps_play("Piano_Eb2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*5 + 1)* ticks_per_beat then
		ps_play("Piano_Bb2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*5 + 2)* ticks_per_beat then
		ps_play("Piano_Eb2",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Drum_Snare",200)
	elseif music_count == (beats_per_measure*5 + 3)* ticks_per_beat then
		ps_play("Piano_Bb2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
		ps_play("Drum_Snare",150)
	elseif music_count == (beats_per_measure*5 + 4)* ticks_per_beat then
		ps_play("Piano_Eb2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*5 + 5)* ticks_per_beat then
		ps_play("Piano_Bb2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*5 + 6)* ticks_per_beat then
		ps_play("Piano_Eb2",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Drum_Snare",200)
	elseif music_count == (beats_per_measure*5 + 7)* ticks_per_beat then
		ps_play("Piano_Bb2",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*6 + 0)* ticks_per_beat then
		ps_play("Piano_B1",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*6 + 1)* ticks_per_beat then
		ps_play("Piano_Gb2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*6 + 2)* ticks_per_beat then
		ps_play("Piano_B1",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Drum_Snare",200)
	elseif music_count == (beats_per_measure*6 + 3)* ticks_per_beat then
		ps_play("Piano_Gb2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
		ps_play("Drum_Snare",150)
	elseif music_count == (beats_per_measure*6 + 4)* ticks_per_beat then
		ps_play("Piano_B1",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*6 + 5)* ticks_per_beat then
		ps_play("Piano_Gb2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*6 + 6)* ticks_per_beat then
		ps_play("Piano_B1",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Drum_Snare",200)
	elseif music_count == (beats_per_measure*6 + 7)* ticks_per_beat then
		ps_play("Piano_Gb2",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*7 + 0)* ticks_per_beat then
		ps_play("Piano_Db2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*7 + 1)* ticks_per_beat then
		ps_play("Piano_Ab2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*7 + 2)* ticks_per_beat then
		ps_play("Piano_Db2",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Drum_Snare",200)
	elseif music_count == (beats_per_measure*7 + 3)* ticks_per_beat then
		ps_play("Piano_Ab2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
		ps_play("Drum_Snare",150)
	elseif music_count == (beats_per_measure*7 + 4)* ticks_per_beat then
		ps_play("Piano_Db2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*7 + 5)* ticks_per_beat then
		ps_play("Piano_Ab2",normalVolume)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
	elseif music_count == (beats_per_measure*7 + 6)* ticks_per_beat then
		ps_play("Piano_Db2",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Drum_Snare",200)
	elseif music_count == (beats_per_measure*7 + 7)* ticks_per_beat then
		ps_play("Piano_Ab2",normalVolume)
		ps_play("Drum_Bass",255)
		ps_play("Cymbal_Hihat_Closed",normalVolume*3/4)
		first_time = false
	end
	
	if first_time == false then
		if music_count == (beats_per_measure*0 + 0)* ticks_per_beat then
			ps_play("L_Piano_Eb3",melodyVolume)
		elseif music_count == (beats_per_measure*0 + 1)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*0 + 2)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*0 + 3)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*0 + 4)* ticks_per_beat then
			ps_play("Piano_Gb4",melodyVolume)
		elseif music_count == (beats_per_measure*0 + 5)* ticks_per_beat then
			ps_play("Piano_F4",melodyVolume)
		elseif music_count == (beats_per_measure*0 + 6)* ticks_per_beat then
			ps_play("Piano_Gb4",melodyVolume)
		elseif music_count == (beats_per_measure*0 + 7)* ticks_per_beat then
			ps_play("Piano_Ab4",melodyVolume)
		elseif music_count == (beats_per_measure*1 + 0)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*1 + 1)* ticks_per_beat then
			ps_play("Piano_Gb4",melodyVolume)
		elseif music_count == (beats_per_measure*1 + 2)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*1 + 3)* ticks_per_beat then
			ps_play("L_Piano_F4",melodyVolume)
		elseif music_count == (beats_per_measure*1 + 4)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*1 + 5)* ticks_per_beat then
			ps_play("Piano_Gb4",melodyVolume)
		elseif music_count == (beats_per_measure*1 + 6)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*1 + 7)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*2 + 0)* ticks_per_beat then
			ps_play("L_Piano_Eb3",melodyVolume)
		elseif music_count == (beats_per_measure*2 + 1)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*2 + 2)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*2 + 3)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*2 + 4)* ticks_per_beat then
			ps_play("Piano_Gb4",melodyVolume)
		elseif music_count == (beats_per_measure*2 + 5)* ticks_per_beat then
			ps_play("Piano_F4",melodyVolume)
		elseif music_count == (beats_per_measure*2 + 6)* ticks_per_beat then
			ps_play("Piano_Gb4",melodyVolume)
		elseif music_count == (beats_per_measure*2 + 7)* ticks_per_beat then
			ps_play("L_Piano_Db5",melodyVolume)
			ps_play("Piano_Gb4",normalVolume)
		elseif music_count == (beats_per_measure*3 + 0)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*3 + 1)* ticks_per_beat then
			ps_play("Piano_F4",normalVolume)
		elseif music_count == (beats_per_measure*3 + 2)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*3 + 3)* ticks_per_beat then
			ps_play("Piano_Eb4",normalVolume)
		elseif music_count == (beats_per_measure*3 + 4)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*3 + 5)* ticks_per_beat then
			ps_play("Piano_F4",normalVolume)
		elseif music_count == (beats_per_measure*3 + 6)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*3 + 7)* ticks_per_beat then
			ps_play("Piano_Eb4",normalVolume)
		elseif music_count == (beats_per_measure*4 + 0)* ticks_per_beat then
			ps_play("L_Piano_Eb3",melodyVolume)
		elseif music_count == (beats_per_measure*4 + 1)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*4 + 2)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*4 + 3)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*4 + 4)* ticks_per_beat then
			ps_play("Piano_Gb4",melodyVolume)
			ps_play("Piano_Bb4",melodyVolume)
		elseif music_count == (beats_per_measure*4 + 5)* ticks_per_beat then
			ps_play("Piano_F4",melodyVolume)
			ps_play("Piano_Ab4",melodyVolume)
		elseif music_count == (beats_per_measure*4 + 6)* ticks_per_beat then
			ps_play("Piano_Gb4",melodyVolume)
			ps_play("Piano_Bb4",melodyVolume)
		elseif music_count == (beats_per_measure*4 + 7)* ticks_per_beat then
			ps_play("Piano_Ab4",melodyVolume)
			ps_play("Piano_B4",melodyVolume)
		elseif music_count == (beats_per_measure*5 + 0)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*5 + 1)* ticks_per_beat then
			ps_play("Piano_Gb4",melodyVolume)
			ps_play("Piano_Bb4",melodyVolume)
		elseif music_count == (beats_per_measure*5 + 2)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*5 + 3)* ticks_per_beat then
			ps_play("Piano_F4",melodyVolume)
			ps_play("Piano_Ab4",melodyVolume)
		elseif music_count == (beats_per_measure*5 + 4)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*5 + 5)* ticks_per_beat then
			ps_play("Piano_Gb4",melodyVolume)
			ps_play("Piano_Bb4",melodyVolume)
		elseif music_count == (beats_per_measure*5 + 6)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*5 + 7)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*6 + 0)* ticks_per_beat then
			ps_play("L_Piano_Db5",melodyVolume)
			ps_play("L_Piano_Gb5",melodyVolume)
		elseif music_count == (beats_per_measure*6 + 1)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*6 + 2)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*6 + 3)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*6 + 4)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*6 + 5)* ticks_per_beat then
			ps_play("Piano_B4",melodyVolume)
			ps_play("Piano_Gb5",melodyVolume)
		elseif music_count == (beats_per_measure*6 + 6)* ticks_per_beat then
			ps_play("Piano_Bb4",melodyVolume)
			ps_play("Piano_Gb5",melodyVolume)
		elseif music_count == (beats_per_measure*6 + 7)* ticks_per_beat then
			ps_play("Piano_Ab4",melodyVolume)
			ps_play("Piano_F5",melodyVolume)
		elseif music_count == (beats_per_measure*7 + 0)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*7 + 1)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*7 + 2)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*7 + 3)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*7 + 4)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*7 + 5)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*7 + 6)* ticks_per_beat then
			
		elseif music_count == (beats_per_measure*7 + 7)* ticks_per_beat then
			
		end
	end
	
	--Increment the number of ticks that have happened
	music_count = music_count + 1
end

