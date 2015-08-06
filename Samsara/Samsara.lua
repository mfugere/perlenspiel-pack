-- Samsara
-- by Mattam Enigma
-- Matt Fugere
-- Tamlyn Miller
-- Art Director: Ryan Chadwick
-- Theme: Transformation
-- Sources of Custom Audio
--  Drylands: written by Matt Fugere
--  Town: written by Matt Fugere
--	Forest: written by Matt Fugere
--	Lake: written by Tamlyn Miller
--	Coastline: written by Tamlyn Miller
--	The Ruins: written and sung by Tamlyn Miller
--	preta death: recorded and voiced by Tamlyn Miller
--	human death: recorded and voiced by Tamlyn Miller
--	asura death: recorded and voiced by Tamlyn Miller
-- This code is released to the public domain

--Grid Size (Use even numbers only)
PS_GRID_X = 16
PS_GRID_Y = 16

--Half the grid size (makes math easier later on)
halfGridX = PS_GRID_X/2
halfGridY = PS_GRID_Y/2

--Size of the whole world
worldMaxX = 105
worldMaxY = 75

--Map of the world
worldMap = {}

--All the different colors
colors = {}

colors["player_human"] = 0xD95B43
colors["player_bird"] = 0xC02942
colors["player_fish"] =0x78ADB9
colors["player_asura"] = 0xFFFF81
colors["player_preta"] = 0x643447

colors["world edge"] = 0x888801
colors["grass 1"] = 0x40F618
colors["grass 2"] = 0x40FD39

grass_colors = {}
grass_colors[1] = 0x40F618
grass_colors[2] = 0x40E618
grass_colors[3] = 0x40D618

desert_colors = {}
desert_colors[1] = 0xE6B97E
desert_colors[2] = 0xD6A96E
desert_colors[3] = 0xC6995E

colors["evening_bg"] = ps_rgb(200,100,150)
colors["morning_bg"] = ps_rgb(180,180,255)
colors["night_bg"] = ps_rgb(50,0,50)
colors["day_bg"] = ps_rgb(150,150,255)

colors["karma"] = PS_YELLOW
colors["movable block"] = 0xBB9B7B
colors["breakable block"] = 0x900000
colors["tablet"] = PS_WHITE
colors["npcPreta"] = 0xA46487
colors["npcAsura"] = 0xFFFFB1

colors["trench"] = 0xFF9340
colors["deep trench"] = 0x9F7320
colors["water"] = 0x2F4FA9
colors["cleansing pool"] = 0x6F6FF9
colors["bridge"] = 0xAF4300
colors["stone wall"] = 0x5A7A5A
colors["dirt path"] = 0xFFAB73
colors["npc"] = 0xDDDD33
colors["child"] = 0xDDDD33
colors["animal"] = 0x555500
colors["house1"] = 0xFFEEDD
colors["house2"] = 0x111111
colors["tree"] = 0x117711
colors["berries"] = 0xFF8888
colors["rocks"] = 0x777777
colors["light orb"] = 0xFFFF33
colors["log"] = 0xAF4300
colors["hole"] = 0x000000
colors["boat"] = 0xAAAAFF
colors["coastline border"] = 0x1F2F79

quests = {}
quests["water flow"] = "not started"
quests["finish stone"] = "not started"
quests["rescue child"] = "not started"
quests["lighthouse"] = "not started"
quests["bridge"] = "not started"

--Different Timers
statusTimer = 0
ticks_per_hour = 100
current_ticks = 0
current_hour = 6
waterFlowCount = 1

--Player start position (center of the world)
playerPos_X = (worldMaxX-1)/2
playerPos_Y = (worldMaxY-1)/2
playerMove_X = 0
playerMove_Y = 0
tablets = 0
maxTablets = 3
karma = 6
maxKarma = 10

npcMoveSpeed = 5

--These are the incarnations:
--asura, human, bird, fish, preta
currentItem = "none"
birdSpeed = 2
currMoveBird = 0
mouseHover = false
dead = false
moksha = false
incarnation = "human"
startPositionX = {}
startPositionY = {}
startPositionX["asura"] = 22+67
startPositionY["asura"] = 22+37
startPositionX["human"] = 10+37
startPositionY["human"] = 15+7
startPositionX["bird"] = 15+37
startPositionY["bird"] = 15+37
startPositionX["fish"] = 15+67
startPositionY["fish"] = 15+7
startPositionX["preta"] = 13+7
startPositionY["preta"] = 21+7

tutorialMode = true
tutorialCount = 0
tutorialType = "beginning"

--When the game starts...
function ps_init ()
	ps_cover("samsara_box_art")
	ps_setup (PS_GRID_X, PS_GRID_Y)
	ps_settings(PS_KEY_CAPTURE,1)
	ps_settings(PS_BEAD_FLASH,0)
	ps_settings(PS_MOUSE_MOTION,1)
	ps_font(PS_MESSAGE_BOX, 20)

	ps_window(600,600,colors["morning_bg"])
	ps_gridlines(0)

	for x = 1, PS_GRID_X-1 do
		for y = 1, PS_GRID_Y-1 do
			ps_alpha(x, y, (current_hour * 10) + 130)
			ps_alpha(0,y,0)
		end
	end

	playerPos_X = startPositionX[incarnation]
	playerPos_Y = startPositionY[incarnation]

	setupWorld()
	updateTime()
	updateGrid()
	ps_timer(1)
	tutorial()
end

--Sets up all the world maps to their initial positions
function setupWorld()
	for x = 0, worldMaxX-1 do
		worldMap[x]= {}
		for y = 0, worldMaxY-1 do
			worldMap[x][y] = {}
			worldMap[x][y]["movable block"] = false
			worldMap[x][y]["breakable block"] = false
			worldMap[x][y]["npc"] = "none"
			worldMap[x][y]["interactions"] = 0
			worldMap[x][y]["disposition"] = 0
			worldMap[x][y]["quest"] = "none"
			worldMap[x][y]["water time"] = 0
			worldMap[x][y]["tag"] = "none"
			worldMap[x][y]["itemTag"] = "none"
			worldMap[x][y]["item"] = "none"
			worldMap[x][y]["hole"] = false
			worldMap[x][y]["move time"] = 0
			worldMap[x][y]["bridge"] = false
			worldMap[x][y]["log"] = false
			worldMap[x][y]["boat"] = false
			worldMap[x][y]["twilight gate"] = false
			worldMap[x][y]["messageTag"] = "none"
			
			if x >= halfGridX-1  
               and x < (halfGridX-1)+((worldMaxX-(halfGridX*2))/3) 
               and y >= halfGridY-1  
               and y < (halfGridY-1)+((worldMaxY-(halfGridY*2))/2) then 
                worldMap[x][y]["region"] = "desert" 
            else 
                worldMap[x][y]["region"] = "grass" 
            end

			if x < halfGridX - 1
			   or y < halfGridY - 1
			   or x >= worldMaxX - halfGridX
			   or y >= worldMaxY - halfGridY then
				worldMap[x][y]["color"] = colors["world edge"]
			else
				if worldMap[x][y]["region"] == "grass" then
					worldMap[x][y]["color"] = grass_colors[ps_random(3)]
				else
					worldMap[x][y]["color"] = desert_colors[ps_random(3)]
				end
			end
		end
	end
	
	oneThirdX = (worldMaxX - 1 - (halfGridX-1)*2)/3
	oneHalfY = (worldMaxY - 1 - (halfGridY-1)*2)/2
	
	drawDrylands(halfGridX-1, halfGridY-1)
	drawTown(halfGridX-1+oneThirdX, halfGridY-1)
	drawLake(halfGridX-1+oneThirdX*2, halfGridY-1)
	drawCoast(halfGridX-1, halfGridY-1+oneHalfY)
	drawForest(halfGridX-1+oneThirdX, halfGridY-1+oneHalfY)
	drawRuins(halfGridX-1+oneThirdX*2, halfGridY-1+oneHalfY)
end

function drawDrylands(xOff, yOff)
	worldMap[4+xOff][11+yOff]["twilight gate"] = true
	worldMap[5+xOff][11+yOff]["twilight gate"] = true
	
	worldMap[4+xOff][4+yOff]["npc"] = "tablet"
	worldMap[4+xOff][4+yOff]["tag"] = "An ancient tablet."
	
	worldMap[9+xOff][3+yOff]["item"] = "child"
	worldMap[9+xOff][3+yOff]["itemTag"] = "A lost child."
	
	resetPreta(xOff, yOff)
	
	for x = 0,29 do
		worldMap[x+xOff][0+yOff]["color"] = colors["stone wall"]
		worldMap[x+xOff][1+yOff]["color"] = colors["stone wall"]
		worldMap[x+xOff][28+yOff]["color"] = colors["stone wall"]
		worldMap[x+xOff][29+yOff]["color"] = colors["stone wall"]
		worldMap[0+xOff][x+yOff]["color"] = colors["stone wall"]
		worldMap[1+xOff][x+yOff]["color"] = colors["stone wall"]
		worldMap[28+xOff][x+yOff]["color"] = colors["stone wall"]
		worldMap[29+xOff][x+yOff]["color"] = colors["stone wall"]
	end
	
	for y = 13,16 do
		worldMap[28+xOff][y+yOff]["color"] = colors["cleansing pool"]
		worldMap[29+xOff][y+yOff]["color"] = colors["cleansing pool"]
	end
	
	worldMap[2+xOff][22+yOff]["color"] = colors["stone wall"]
	worldMap[3+xOff][22+yOff]["color"] = colors["stone wall"]
	worldMap[4+xOff][22+yOff]["color"] = colors["stone wall"]
	worldMap[27+xOff][22+yOff]["color"] = colors["stone wall"]
	
	for x = 6,25 do
		worldMap[x+xOff][22+yOff]["color"] = colors["stone wall"]
	end
	
	for y = 17,21 do
		worldMap[17+xOff][y+yOff]["color"] = colors["stone wall"]
	end
	
	for y = 24,27 do
		worldMap[17+xOff][y+yOff]["color"] = colors["stone wall"]
	end
	
	for x = 18,23 do
		worldMap[x+xOff][17+yOff]["color"] = colors["stone wall"]
	end
	
	worldMap[25+xOff][17+yOff]["color"] = colors["stone wall"]
	worldMap[26+xOff][17+yOff]["color"] = colors["stone wall"]
	worldMap[27+xOff][17+yOff]["color"] = colors["stone wall"]
	
	for y = 8,16 do
		worldMap[9+xOff][y+yOff]["color"] = colors["stone wall"]
	end
	
	for y = 18,22 do
		worldMap[9+xOff][y+yOff]["color"] = colors["stone wall"]
	end
	
	for y = 2,8 do
		worldMap[11+xOff][y+yOff]["color"] = colors["stone wall"]
	end
	
	worldMap[10+xOff][8+yOff]["color"] = colors["stone wall"]
	worldMap[2+xOff][11+yOff]["color"] = colors["stone wall"]
	worldMap[3+xOff][11+yOff]["color"] = colors["stone wall"]
	worldMap[6+xOff][11+yOff]["color"] = colors["stone wall"]
	worldMap[7+xOff][11+yOff]["color"] = colors["stone wall"]
	worldMap[8+xOff][11+yOff]["color"] = colors["stone wall"]
	
	for x = 2,6 do
		worldMap[x+xOff][2+yOff]["color"] = colors["stone wall"]
		worldMap[2+xOff][x+yOff]["color"] = colors["stone wall"]
		worldMap[6+xOff][x+yOff]["color"] = colors["stone wall"]
	end
	
	worldMap[2+xOff][6+yOff]["color"] = colors["stone wall"]
	worldMap[3+xOff][6+yOff]["color"] = colors["stone wall"]
	worldMap[5+xOff][6+yOff]["color"] = colors["stone wall"]
	worldMap[6+xOff][6+yOff]["color"] = colors["stone wall"]
	
	worldMap[3+xOff][18+yOff]["color"] = colors["house1"]
	worldMap[4+xOff][18+yOff]["color"] = colors["house1"]
	worldMap[5+xOff][18+yOff]["color"] = colors["house2"]
	worldMap[6+xOff][18+yOff]["color"] = colors["house1"]
	worldMap[7+xOff][18+yOff]["color"] = colors["house1"]
	worldMap[4+xOff][17+yOff]["color"] = colors["house1"]
	worldMap[5+xOff][17+yOff]["color"] = colors["house1"]
	worldMap[6+xOff][17+yOff]["color"] = colors["house1"]
	worldMap[5+xOff][16+yOff]["color"] = colors["house1"]
	
	worldMap[13+xOff][5+yOff]["color"] = colors["house1"]
	worldMap[14+xOff][5+yOff]["color"] = colors["house1"]
	worldMap[15+xOff][5+yOff]["color"] = colors["house2"]
	worldMap[16+xOff][5+yOff]["color"] = colors["house1"]
	worldMap[17+xOff][5+yOff]["color"] = colors["house1"]
	worldMap[14+xOff][4+yOff]["color"] = colors["house1"]
	worldMap[15+xOff][4+yOff]["color"] = colors["house1"]
	worldMap[16+xOff][4+yOff]["color"] = colors["house1"]
	worldMap[15+xOff][3+yOff]["color"] = colors["house1"]
	
	worldMap[20+xOff][6+yOff]["color"] = colors["house1"]
	worldMap[21+xOff][6+yOff]["color"] = colors["house1"]
	worldMap[22+xOff][6+yOff]["color"] = colors["house2"]
	worldMap[23+xOff][6+yOff]["color"] = colors["house1"]
	worldMap[24+xOff][6+yOff]["color"] = colors["house1"]
	worldMap[21+xOff][5+yOff]["color"] = colors["house1"]
	worldMap[22+xOff][5+yOff]["color"] = colors["house1"]
	worldMap[23+xOff][5+yOff]["color"] = colors["house1"]
	worldMap[22+xOff][4+yOff]["color"] = colors["house1"]
	
	worldMap[17+xOff][10+yOff]["color"] = colors["house1"]
	worldMap[18+xOff][10+yOff]["color"] = colors["house1"]
	worldMap[19+xOff][10+yOff]["color"] = colors["house2"]
	worldMap[20+xOff][10+yOff]["color"] = colors["house1"]
	worldMap[21+xOff][10+yOff]["color"] = colors["house1"]
	worldMap[18+xOff][9+yOff]["color"] = colors["house1"]
	worldMap[19+xOff][9+yOff]["color"] = colors["house1"]
	worldMap[20+xOff][9+yOff]["color"] = colors["house1"]
	worldMap[19+xOff][8+yOff]["color"] = colors["house1"]
	
	worldMap[12+xOff][16+yOff]["color"] = colors["house1"]
	worldMap[13+xOff][16+yOff]["color"] = colors["house2"]
	worldMap[14+xOff][16+yOff]["color"] = colors["house1"]
	worldMap[12+xOff][15+yOff]["color"] = colors["house1"]
	worldMap[13+xOff][15+yOff]["color"] = colors["house1"]
	worldMap[14+xOff][15+yOff]["color"] = colors["house1"]
	
	worldMap[19+xOff][20+yOff]["color"] = colors["house1"]
	worldMap[20+xOff][20+yOff]["color"] = colors["house2"]
	worldMap[21+xOff][20+yOff]["color"] = colors["house1"]
	worldMap[19+xOff][19+yOff]["color"] = colors["house1"]
	worldMap[20+xOff][19+yOff]["color"] = colors["house1"]
	worldMap[21+xOff][19+yOff]["color"] = colors["house1"]
	
	worldMap[6+xOff][26+yOff]["color"] = colors["house1"]
	worldMap[7+xOff][26+yOff]["color"] = colors["house2"]
	worldMap[8+xOff][26+yOff]["color"] = colors["house1"]
	worldMap[6+xOff][25+yOff]["color"] = colors["house1"]
	worldMap[7+xOff][25+yOff]["color"] = colors["house1"]
	worldMap[8+xOff][25+yOff]["color"] = colors["house1"]
	
	worldMap[11+xOff][25+yOff]["color"] = colors["house1"]
	worldMap[12+xOff][25+yOff]["color"] = colors["house2"]
	worldMap[13+xOff][25+yOff]["color"] = colors["house1"]
	worldMap[11+xOff][24+yOff]["color"] = colors["house1"]
	worldMap[12+xOff][24+yOff]["color"] = colors["house1"]
	worldMap[13+xOff][24+yOff]["color"] = colors["house1"]
	
	worldMap[20+xOff][26+yOff]["color"] = colors["house1"]
	worldMap[21+xOff][26+yOff]["color"] = colors["house1"]
	worldMap[22+xOff][26+yOff]["color"] = colors["house1"]
	worldMap[23+xOff][26+yOff]["color"] = colors["house2"]
	worldMap[24+xOff][26+yOff]["color"] = colors["house1"]
	worldMap[25+xOff][26+yOff]["color"] = colors["house1"]
	worldMap[26+xOff][26+yOff]["color"] = colors["house1"]
	worldMap[21+xOff][25+yOff]["color"] = colors["house1"]
	worldMap[22+xOff][25+yOff]["color"] = colors["house1"]
	worldMap[23+xOff][25+yOff]["color"] = colors["house2"]
	worldMap[24+xOff][25+yOff]["color"] = colors["house1"]
	worldMap[25+xOff][25+yOff]["color"] = colors["house1"]
	worldMap[22+xOff][24+yOff]["color"] = colors["house1"]
	worldMap[23+xOff][24+yOff]["color"] = colors["house1"]
	worldMap[24+xOff][24+yOff]["color"] = colors["house1"]
	worldMap[23+xOff][23+yOff]["color"] = colors["house1"]
	
	worldMap[5+xOff][22+yOff]["breakable block"] = true
	worldMap[9+xOff][17+yOff]["breakable block"] = true
	worldMap[17+xOff][23+yOff]["breakable block"] = true
	worldMap[26+xOff][22+yOff]["breakable block"] = true
	worldMap[24+xOff][17+yOff]["breakable block"] = true
	worldMap[4+xOff][6+yOff]["breakable block"] = true
end

function resetPreta(xOff, yOff)
	for x = 0, worldMaxX-1 do
		for y = 0, worldMaxY-1 do
			if worldMap[x][y]["npc"] == "preta" then
				worldMap[x][y]["npc"] = "none"
			end
		end
	end
	
	worldMap[3+xOff][26+yOff]["npc"] = "preta"
	worldMap[3+xOff][26+yOff]["tag"] = "A preta."
	worldMap[10+xOff][25+yOff]["npc"] = "preta"
	worldMap[10+xOff][25+yOff]["tag"] = "A preta."
	worldMap[15+xOff][27+yOff]["npc"] = "preta"
	worldMap[15+xOff][27+yOff]["tag"] = "A preta."
	worldMap[21+xOff][23+yOff]["npc"] = "preta"
	worldMap[21+xOff][23+yOff]["tag"] = "A preta."
	worldMap[20+xOff][21+yOff]["npc"] = "preta"
	worldMap[20+xOff][21+yOff]["tag"] = "A preta."
	worldMap[11+xOff][20+yOff]["npc"] = "preta"
	worldMap[11+xOff][20+yOff]["tag"] = "A preta."
	worldMap[11+xOff][20+yOff]["messageTag"] = "I was a bird, but then I crashed into a tree."
	worldMap[14+xOff][18+yOff]["npc"] = "preta"
	worldMap[14+xOff][18+yOff]["tag"] = "A preta."
	worldMap[14+xOff][18+yOff]["messageTag"] = "I was a fish, but I was caught by a fisherman."
	worldMap[11+xOff][12+yOff]["npc"] = "preta"
	worldMap[11+xOff][12+yOff]["tag"] = "A preta."
	worldMap[11+xOff][12+yOff]["messageTag"] = "We hold an ancient secret beyond the flashing gate."
	worldMap[16+xOff][13+yOff]["npc"] = "preta"
	worldMap[16+xOff][13+yOff]["tag"] = "A preta."
	worldMap[16+xOff][13+yOff]["messageTag"] = "I was an asura, but- wait, don't I know you?"
	worldMap[15+xOff][6+yOff]["npc"] = "preta"
	worldMap[15+xOff][6+yOff]["tag"] = "A preta."
	worldMap[15+xOff][6+yOff]["messageTag"] = "Sooo...hungry..."
	worldMap[19+xOff][4+yOff]["npc"] = "preta"
	worldMap[19+xOff][4+yOff]["tag"] = "A preta."
	worldMap[19+xOff][4+yOff]["messageTag"] = "What did I do to deserve this?"
	worldMap[19+xOff][11+yOff]["npc"] = "preta"
	worldMap[19+xOff][11+yOff]["tag"] = "A preta."
	worldMap[19+xOff][11+yOff]["messageTag"] = "A child wandered through here earlier."
	worldMap[26+xOff][11+yOff]["npc"] = "preta"
	worldMap[26+xOff][11+yOff]["tag"] = "A preta."
	worldMap[26+xOff][11+yOff]["messageTag"] = "Well, at least the music is nice..."
	worldMap[23+xOff][8+yOff]["npc"] = "preta"
	worldMap[23+xOff][8+yOff]["tag"] = "A preta."
	worldMap[23+xOff][8+yOff]["messageTag"] = "I was once human, but a bear ate me."
end

function drawTown(xOff, yOff)
	worldMap[24+xOff][12+yOff]["npc"] = "water man"
	worldMap[24+xOff][12+yOff]["tag"] = "A man concerned about the town."
	
	worldMap[17+xOff][15+yOff]["npc"] = "mother"
	worldMap[17+xOff][15+yOff]["quest"] = "rescue child"
	worldMap[17+xOff][15+yOff]["tag"] = "A mother concerned about her child."
	
	worldMap[18+xOff][22+yOff]["npc"] = "rich man"
	worldMap[18+xOff][22+yOff]["tag"] = "A wealthy salesman."
	
	worldMap[4+xOff][10+yOff]["npc"] = "stone man"
	worldMap[4+xOff][10+yOff]["tag"] = "A man concerned about his house."
	
	worldMap[3+xOff][17+yOff]["npc"] = "gate man"
	worldMap[3+xOff][17+yOff]["tag"] = "The gate guard."
	
	worldMap[9+xOff][27+yOff]["npc"] = "river man"
	worldMap[9+xOff][27+yOff]["tag"] = "A man down by the river."
	
	worldMap[14+xOff][4+yOff]["npc"] = "backyard man"
	worldMap[14+xOff][4+yOff]["tag"] = "The village idiot."
	
	for y = 0,12 do
		worldMap[0+xOff][y+yOff]["color"] = colors["stone wall"]
		worldMap[1+xOff][y+yOff]["color"] = colors["stone wall"]
		worldMap[0+xOff][y+17+yOff]["color"] = colors["stone wall"]
		worldMap[1+xOff][y+17+yOff]["color"] = colors["stone wall"]
	end
	
	for x = 0,29 do
		worldMap[x+xOff][0+yOff]["color"] = colors["stone wall"]
		worldMap[x+xOff][1+yOff]["color"] = colors["stone wall"]
	end
	
	for y = 1,10 do
		worldMap[28+xOff][y+yOff]["color"] = colors["stone wall"]
		worldMap[29+xOff][y+yOff]["color"] = colors["stone wall"]
	end
	
	for y = 2,6 do
		worldMap[20+xOff][y+yOff]["color"] = colors["stone wall"]
	end
	
	worldMap[21+xOff][6+yOff]["color"] = colors["stone wall"]
	worldMap[22+xOff][6+yOff]["color"] = colors["stone wall"]
	worldMap[26+xOff][6+yOff]["color"] = colors["stone wall"]
	worldMap[27+xOff][6+yOff]["color"] = colors["stone wall"]
	
	worldMap[29+xOff][14+yOff]["color"] = colors["deep trench"]
	
	for y = 15,29 do
		worldMap[28+xOff][y+yOff]["color"] = colors["deep trench"]
		worldMap[29+xOff][y+yOff]["color"] = colors["deep trench"]
	end
	
	worldMap[4+xOff][4+yOff]["color"] = colors["house1"]
	worldMap[5+xOff][4+yOff]["color"] = colors["house1"]
	worldMap[6+xOff][4+yOff]["color"] = colors["house1"]
	worldMap[7+xOff][4+yOff]["color"] = colors["house1"]
	worldMap[8+xOff][4+yOff]["color"] = colors["house1"]
	worldMap[4+xOff][5+yOff]["color"] = colors["house1"]
	worldMap[5+xOff][5+yOff]["color"] = colors["house2"]
	worldMap[6+xOff][5+yOff]["color"] = colors["house1"]
	worldMap[7+xOff][5+yOff]["color"] = colors["house2"]
	worldMap[8+xOff][5+yOff]["color"] = colors["house1"]
	worldMap[4+xOff][6+yOff]["color"] = colors["house1"]
	worldMap[5+xOff][6+yOff]["color"] = colors["house1"]
	worldMap[6+xOff][6+yOff]["color"] = colors["house1"]
	worldMap[7+xOff][6+yOff]["color"] = colors["house1"]
	worldMap[8+xOff][6+yOff]["color"] = colors["house1"]
	worldMap[4+xOff][7+yOff]["color"] = colors["house1"]
	worldMap[5+xOff][7+yOff]["color"] = colors["house1"]
	worldMap[6+xOff][7+yOff]["color"] = colors["house2"]
	worldMap[7+xOff][7+yOff]["color"] = colors["house1"]
	worldMap[8+xOff][7+yOff]["color"] = colors["house1"]
	worldMap[4+xOff][8+yOff]["color"] = colors["house1"]
	worldMap[5+xOff][8+yOff]["color"] = colors["house1"]
	worldMap[6+xOff][8+yOff]["color"] = colors["house2"]
	worldMap[7+xOff][8+yOff]["color"] = colors["house1"]
	worldMap[8+xOff][8+yOff]["color"] = colors["house1"]
	
	worldMap[14+xOff][8+yOff]["color"] = colors["house1"]
	worldMap[15+xOff][8+yOff]["color"] = colors["house1"]
	worldMap[16+xOff][8+yOff]["color"] = colors["house1"]
	worldMap[17+xOff][8+yOff]["color"] = colors["house1"]
	worldMap[18+xOff][8+yOff]["color"] = colors["house1"]
	worldMap[14+xOff][9+yOff]["color"] = colors["house1"]
	worldMap[15+xOff][9+yOff]["color"] = colors["house2"]
	worldMap[16+xOff][9+yOff]["color"] = colors["house1"]
	worldMap[17+xOff][9+yOff]["color"] = colors["house2"]
	worldMap[18+xOff][9+yOff]["color"] = colors["house1"]
	worldMap[14+xOff][10+yOff]["color"] = colors["house1"]
	worldMap[15+xOff][10+yOff]["color"] = colors["house1"]
	worldMap[16+xOff][10+yOff]["color"] = colors["house1"]
	worldMap[17+xOff][10+yOff]["color"] = colors["house1"]
	worldMap[18+xOff][10+yOff]["color"] = colors["house1"]
	worldMap[14+xOff][11+yOff]["color"] = colors["house1"]
	worldMap[15+xOff][11+yOff]["color"] = colors["house1"]
	worldMap[16+xOff][11+yOff]["color"] = colors["house2"]
	worldMap[17+xOff][11+yOff]["color"] = colors["house1"]
	worldMap[18+xOff][11+yOff]["color"] = colors["house1"]
	worldMap[14+xOff][12+yOff]["color"] = colors["house1"]
	worldMap[15+xOff][12+yOff]["color"] = colors["house1"]
	worldMap[16+xOff][12+yOff]["color"] = colors["house2"]
	worldMap[17+xOff][12+yOff]["color"] = colors["house1"]
	worldMap[18+xOff][12+yOff]["color"] = colors["house1"]
	
	worldMap[12+xOff][20+yOff]["color"] = colors["house1"]
	worldMap[13+xOff][20+yOff]["color"] = colors["house1"]
	worldMap[14+xOff][20+yOff]["color"] = colors["house1"]
	worldMap[15+xOff][20+yOff]["color"] = colors["house1"]
	worldMap[16+xOff][20+yOff]["color"] = colors["house1"]
	worldMap[12+xOff][21+yOff]["color"] = colors["house1"]
	worldMap[13+xOff][21+yOff]["color"] = colors["house2"]
	worldMap[14+xOff][21+yOff]["color"] = colors["house1"]
	worldMap[15+xOff][21+yOff]["color"] = colors["house2"]
	worldMap[16+xOff][21+yOff]["color"] = colors["house1"]
	worldMap[12+xOff][22+yOff]["color"] = colors["house1"]
	worldMap[13+xOff][22+yOff]["color"] = colors["house1"]
	worldMap[14+xOff][22+yOff]["color"] = colors["house1"]
	worldMap[15+xOff][22+yOff]["color"] = colors["house1"]
	worldMap[16+xOff][22+yOff]["color"] = colors["house1"]
	worldMap[12+xOff][23+yOff]["color"] = colors["house1"]
	worldMap[13+xOff][23+yOff]["color"] = colors["house1"]
	worldMap[14+xOff][23+yOff]["color"] = colors["house2"]
	worldMap[15+xOff][23+yOff]["color"] = colors["house1"]
	worldMap[16+xOff][23+yOff]["color"] = colors["house1"]
	worldMap[12+xOff][24+yOff]["color"] = colors["house1"]
	worldMap[13+xOff][24+yOff]["color"] = colors["house1"]
	worldMap[14+xOff][24+yOff]["color"] = colors["house2"]
	worldMap[15+xOff][24+yOff]["color"] = colors["house1"]
	worldMap[16+xOff][24+yOff]["color"] = colors["house1"]
	
	worldMap[23+xOff][8+yOff]["color"] = colors["house1"]
	worldMap[24+xOff][8+yOff]["color"] = colors["house1"]
	worldMap[25+xOff][8+yOff]["color"] = colors["house1"]
	worldMap[23+xOff][9+yOff]["color"] = colors["house1"]
	worldMap[24+xOff][9+yOff]["color"] = colors["house2"]
	worldMap[25+xOff][9+yOff]["color"] = colors["house1"]
	worldMap[23+xOff][10+yOff]["color"] = colors["house1"]
	worldMap[24+xOff][10+yOff]["color"] = colors["house2"]
	worldMap[25+xOff][10+yOff]["color"] = colors["house1"]
	
	worldMap[4+xOff][20+yOff]["color"] = colors["house1"]
	worldMap[5+xOff][20+yOff]["color"] = colors["house1"]
	worldMap[6+xOff][20+yOff]["color"] = colors["house1"]
	worldMap[4+xOff][21+yOff]["color"] = colors["house1"]
	worldMap[5+xOff][21+yOff]["color"] = colors["house2"]
	worldMap[6+xOff][21+yOff]["color"] = colors["house1"]
	worldMap[4+xOff][22+yOff]["color"] = colors["house1"]
	worldMap[5+xOff][22+yOff]["color"] = colors["house2"]
	worldMap[6+xOff][22+yOff]["color"] = colors["house1"]
	
	worldMap[24+xOff][16+yOff]["color"] = colors["house1"]
	worldMap[25+xOff][16+yOff]["color"] = colors["house1"]
	worldMap[26+xOff][16+yOff]["color"] = colors["house1"]
	worldMap[24+xOff][17+yOff]["color"] = colors["house1"]
	worldMap[25+xOff][17+yOff]["color"] = colors["house2"]
	worldMap[26+xOff][17+yOff]["color"] = colors["house1"]
	worldMap[24+xOff][18+yOff]["color"] = colors["house1"]
	worldMap[25+xOff][18+yOff]["color"] = colors["house2"]
	worldMap[26+xOff][18+yOff]["color"] = colors["house1"]
	
	worldMap[11+xOff][5+yOff]["color"] = colors["tree"]
	worldMap[13+xOff][14+yOff]["color"] = colors["tree"]
	worldMap[7+xOff][17+yOff]["color"] = colors["tree"]
	worldMap[4+xOff][28+yOff]["color"] = colors["tree"]
	worldMap[5+xOff][26+yOff]["color"] = colors["tree"]
	worldMap[13+xOff][27+yOff]["color"] = colors["tree"]
	worldMap[16+xOff][29+yOff]["color"] = colors["tree"]
	worldMap[21+xOff][28+yOff]["color"] = colors["tree"]
	worldMap[23+xOff][25+yOff]["color"] = colors["tree"]
	worldMap[25+xOff][22+yOff]["color"] = colors["tree"]
	worldMap[25+xOff][29+yOff]["color"] = colors["tree"]
	
	worldMap[25+xOff][4+yOff]["movable block"] = true
	worldMap[6+xOff][9+yOff]["hole"] = true
	worldMap[6+xOff][9+yOff]["quest"] = "finish stone"
	
	for y = 13,16 do
		worldMap[0+xOff][y+yOff]["breakable block"] = true
		worldMap[1+xOff][y+yOff]["breakable block"] = true
	end
end

function drawLake(xOff, yOff)
	worldMap[16+xOff][8+yOff]["npc"] = "fisherman"
	worldMap[16+xOff][8+yOff]["tag"] = "A hungry fisherman."
	
	
	worldMap[28+xOff][2+yOff]["npc"] = "tablet"
	worldMap[28+xOff][2+yOff]["tag"] = "An ancient tablet."
	
	for x = 12,18 do
		worldMap[x+xOff][0+yOff]["color"] = colors["stone wall"]
		worldMap[x+xOff][1+yOff]["color"] = colors["stone wall"]
		worldMap[x+1+xOff][2+yOff]["color"] = colors["trench"]
	end
	
	for x = 20,25 do
		worldMap[x+xOff][1+yOff]["color"] = colors["stone wall"]
	end
	
	for x = 21,25 do
		worldMap[x+xOff][2+yOff]["color"] = colors["stone wall"]
	end
	
	for x = 15,25 do
		worldMap[x+xOff][3+yOff]["color"] = colors["stone wall"]
		worldMap[x-1+xOff][4+yOff]["color"] = colors["trench"]
	end
	
	worldMap[19+xOff][1+yOff]["color"] = colors["water"]
	worldMap[20+xOff][2+yOff]["color"] = colors["trench"]
	worldMap[25+xOff][4+yOff]["color"] = colors["stone wall"]
	worldMap[13+xOff][3+yOff]["color"] = colors["trench"]
	worldMap[14+xOff][3+yOff]["color"] = colors["trench"]
	worldMap[13+xOff][4+yOff]["color"] = colors["trench"]
	worldMap[19+xOff][2+yOff]["movable block"] = true
	
	for x = 25,29 do
		worldMap[x+xOff][3+yOff]["color"] = colors["stone wall"]
	end
	
	for x = 19,29 do
		worldMap[x+xOff][0+yOff]["color"] = colors["water"]
	end
	
	for x = 25,29 do
		if x > 25 then
			for y = 1,4 do
				worldMap[x+xOff][y+yOff]["color"] = colors["water"]
			end
		end
		worldMap[x+xOff][5+yOff]["color"] = colors["stone wall"]
		worldMap[x+xOff][6+yOff]["color"] = colors["stone wall"]
		worldMap[x+xOff][7+yOff]["color"] = colors["deep trench"]
		worldMap[x+xOff][8+yOff]["color"] = colors["deep trench"]
	end
	
	for y = 5,8 do
		worldMap[23+xOff][y+yOff]["color"] = colors["deep trench"]
		worldMap[24+xOff][y+yOff]["color"] = colors["deep trench"]
	end
	
	for x = 13,29 do
		worldMap[x+xOff][9+yOff]["color"] = colors["deep trench"]
	end
	
	for x = 10,29 do
		worldMap[x+xOff][10+yOff]["color"] = colors["deep trench"]
	end
	
	for x = 7,29 do
		worldMap[x+xOff][11+yOff]["color"] = colors["deep trench"]
	end
	
	for x = 4,29 do
		worldMap[x+xOff][12+yOff]["color"] = colors["deep trench"]
	end
	
	for x = 3,29 do
		worldMap[x+xOff][13+yOff]["color"] = colors["deep trench"]
	end
	
	for x = 0,29 do
		for y = 14,17 do
			worldMap[x+xOff][y+yOff]["color"] = colors["deep trench"]
		end
	end
	
	for x = 0,3 do
		worldMap[x+xOff][18+yOff]["color"] = colors["deep trench"]
	end
	
	for x = 6,29 do
		worldMap[x+xOff][18+yOff]["color"] = colors["deep trench"]
		worldMap[x+xOff][19+yOff]["color"] = colors["deep trench"]
	end
	
	for y = 19,29 do
		worldMap[0+xOff][y+yOff]["color"] = colors["deep trench"]
		worldMap[1+xOff][y+yOff]["color"] = colors["deep trench"]
	end
	
	for x = 8,27 do
		worldMap[x+xOff][20+yOff]["color"] = colors["deep trench"]
		worldMap[x+xOff][21+yOff]["color"] = colors["deep trench"]
	end
	
	for x = 10,25 do
		worldMap[x+xOff][22+yOff]["color"] = colors["deep trench"]
		worldMap[x+xOff][23+yOff]["color"] = colors["deep trench"]
	end
	
	for x = 12,23 do
		worldMap[x+xOff][24+yOff]["color"] = colors["deep trench"]
		worldMap[x+xOff][25+yOff]["color"] = colors["deep trench"]
	end
	
	for x = 14,21 do
		worldMap[x+xOff][26+yOff]["color"] = colors["deep trench"]
		worldMap[x+xOff][27+yOff]["color"] = colors["deep trench"]
	end
end

function drawCoast(xOff, yOff)
	worldMap[2+xOff][27+yOff]["npc"] = "tablet"
	worldMap[2+xOff][27+yOff]["tag"] = "An ancient tablet."
	
	worldMap[23+xOff][11+yOff]["npc"] = "poor man"
	worldMap[23+xOff][11+yOff]["tag"] = "A poor villager."
	
	worldMap[8+xOff][10+yOff]["npc"] = "lighthouse man"
	worldMap[8+xOff][10+yOff]["tag"] = "A man concerned about the lighthouse."
	worldMap[8+xOff][10+yOff]["quest"] = "lighthouse"
	
	worldMap[19+xOff][22+yOff]["npc"] = "dock man"
	worldMap[19+xOff][22+yOff]["tag"] = "A villager by the docks."
	
	for y = 0,29 do
		worldMap[0+xOff][y+yOff]["color"] = colors["deep trench"]
		if y > 3 and y < 26 then
			worldMap[1+xOff][y+yOff]["color"] = colors["deep trench"]
			if y > 5 then
				worldMap[2+xOff][y+yOff]["color"] = colors["deep trench"]
			end
			if y > 7 then
				worldMap[3+xOff][y+yOff]["color"] = colors["deep trench"]
			end
		end
		if y > 9 then
			worldMap[4+xOff][y+yOff]["color"] = colors["deep trench"]
		end
		
		if y > 10 then
			worldMap[5+xOff][y+yOff]["color"] = colors["deep trench"]
			worldMap[6+xOff][y+yOff]["color"] = colors["deep trench"]
		end
		
		if y > 12 then
			worldMap[7+xOff][y+yOff]["color"] = colors["deep trench"]
			worldMap[15+xOff][y+yOff]["color"] = colors["deep trench"]
		end
		
		if y > 15 then
			for x = 8,15 do
				worldMap[x+xOff][y+yOff]["color"] = colors["deep trench"]
			end
		end
	end
	
	worldMap[1+xOff][29+yOff]["color"] = colors["deep trench"]
	worldMap[2+xOff][29+yOff]["color"] = colors["deep trench"]
	worldMap[3+xOff][29+yOff]["color"] = colors["deep trench"]
	
	for x = 15,17 do
		for y = 13,19 do
			worldMap[x+xOff][y+yOff]["color"] = colors["deep trench"]
		end
	end
	
	for y = 24,29 do
		worldMap[16+xOff][y+yOff]["color"] = colors["deep trench"]
		if y > 24 then
			worldMap[17+xOff][y+yOff]["color"] = colors["deep trench"]
			worldMap[18+xOff][y+yOff]["color"] = colors["deep trench"]
		end
		
		if y > 25 then
			worldMap[19+xOff][y+yOff]["color"] = colors["deep trench"]
			worldMap[20+xOff][y+yOff]["color"] = colors["deep trench"]
		end
		
		if y > 26 then
			worldMap[21+xOff][y+yOff]["color"] = colors["deep trench"]
			worldMap[22+xOff][y+yOff]["color"] = colors["deep trench"]
			worldMap[23+xOff][y+yOff]["color"] = colors["deep trench"]
		end
	end
	
	for x = 24,27 do
		worldMap[x+xOff][28+yOff]["color"] = colors["deep trench"]
		worldMap[x+xOff][29+yOff]["color"] = colors["deep trench"]
	end
	
	worldMap[16+xOff][11+yOff]["color"] = colors["deep trench"]
	worldMap[16+xOff][12+yOff]["color"] = colors["deep trench"]
	worldMap[18+xOff][13+yOff]["color"] = colors["deep trench"]
	worldMap[18+xOff][14+yOff]["color"] = colors["deep trench"]
	
	for x = 17,20 do
		for y = 9,12 do
			worldMap[x+xOff][y+yOff]["color"] = colors["deep trench"]
		end
	end
	
	worldMap[18+xOff][8+yOff]["color"] = colors["deep trench"]
	
	for x = 18,24 do
		for y = 7,9 do
			worldMap[x+xOff][y+yOff]["color"] = colors["deep trench"]
		end
	end
	
	for x = 25,27 do
		for y = 5,8 do
			worldMap[x+xOff][y+yOff]["color"] = colors["deep trench"]
		end
	end
	
	worldMap[22+xOff][6+yOff]["color"] = colors["deep trench"]
	worldMap[23+xOff][6+yOff]["color"] = colors["deep trench"]
	worldMap[24+xOff][6+yOff]["color"] = colors["deep trench"]
	
	for y = 4,7 do
		worldMap[28+xOff][y+yOff]["color"] = colors["deep trench"]
		worldMap[29+xOff][y+yOff]["color"] = colors["deep trench"]
	end
	
	for y = 8,14 do
		worldMap[29+xOff][y+yOff]["color"] = colors["stone wall"]
	end
	
	for y = 17,29 do
		worldMap[29+xOff][y+yOff]["color"] = colors["stone wall"]
		if y > 23 then
			worldMap[28+xOff][y+yOff]["color"] = colors["stone wall"]
		end
	end
	
	worldMap[6+xOff][5+yOff]["color"] = colors["house1"]
	worldMap[7+xOff][5+yOff]["color"] = colors["house1"]
	worldMap[8+xOff][5+yOff]["color"] = colors["house1"]
	worldMap[6+xOff][6+yOff]["color"] = colors["house1"]
	worldMap[7+xOff][6+yOff]["color"] = colors["house2"]
	worldMap[8+xOff][6+yOff]["color"] = colors["house1"]
	worldMap[6+xOff][7+yOff]["color"] = colors["house1"]
	worldMap[7+xOff][7+yOff]["color"] = colors["house2"]
	worldMap[8+xOff][7+yOff]["color"] = colors["house1"]
	
	worldMap[13+xOff][4+yOff]["color"] = colors["house1"]
	worldMap[14+xOff][4+yOff]["color"] = colors["house1"]
	worldMap[15+xOff][4+yOff]["color"] = colors["house1"]
	worldMap[13+xOff][5+yOff]["color"] = colors["house1"]
	worldMap[14+xOff][5+yOff]["color"] = colors["house2"]
	worldMap[15+xOff][5+yOff]["color"] = colors["house1"]
	worldMap[13+xOff][6+yOff]["color"] = colors["house1"]
	worldMap[14+xOff][6+yOff]["color"] = colors["house2"]
	worldMap[15+xOff][6+yOff]["color"] = colors["house1"]
	
	worldMap[20+xOff][17+yOff]["color"] = colors["house1"]
	worldMap[21+xOff][17+yOff]["color"] = colors["house1"]
	worldMap[22+xOff][17+yOff]["color"] = colors["house1"]
	worldMap[20+xOff][18+yOff]["color"] = colors["house1"]
	worldMap[21+xOff][18+yOff]["color"] = colors["house2"]
	worldMap[22+xOff][18+yOff]["color"] = colors["house1"]
	worldMap[20+xOff][19+yOff]["color"] = colors["house1"]
	worldMap[21+xOff][19+yOff]["color"] = colors["house2"]
	worldMap[22+xOff][19+yOff]["color"] = colors["house1"]
	
	worldMap[23+xOff][22+yOff]["color"] = colors["house1"]
	worldMap[24+xOff][22+yOff]["color"] = colors["house1"]
	worldMap[25+xOff][22+yOff]["color"] = colors["house1"]
	worldMap[23+xOff][23+yOff]["color"] = colors["house1"]
	worldMap[24+xOff][23+yOff]["color"] = colors["house2"]
	worldMap[25+xOff][23+yOff]["color"] = colors["house1"]
	worldMap[23+xOff][24+yOff]["color"] = colors["house1"]
	worldMap[24+xOff][24+yOff]["color"] = colors["house2"]
	worldMap[25+xOff][24+yOff]["color"] = colors["house1"]
	
	--Lighthouse
	worldMap[11+xOff][10+yOff]["color"] = colors["house1"]
	worldMap[10+xOff][11+yOff]["color"] = colors["house1"]
	worldMap[11+xOff][11+yOff]["color"] = colors["house1"]
	worldMap[12+xOff][11+yOff]["color"] = colors["house1"]
	worldMap[9+xOff][12+yOff]["color"] = colors["house1"]
	worldMap[10+xOff][12+yOff]["color"] = colors["house1"]
	worldMap[11+xOff][12+yOff]["color"] = colors["house1"]
	worldMap[12+xOff][12+yOff]["color"] = colors["house1"]
	worldMap[13+xOff][12+yOff]["color"] = colors["house1"]
	worldMap[9+xOff][13+yOff]["color"] = colors["house1"]
	worldMap[10+xOff][13+yOff]["color"] = colors["house1"]
	worldMap[11+xOff][13+yOff]["color"] = colors["house2"]
	worldMap[12+xOff][13+yOff]["color"] = colors["house1"]
	worldMap[13+xOff][13+yOff]["color"] = colors["house1"]
	worldMap[9+xOff][14+yOff]["color"] = colors["house1"]
	worldMap[10+xOff][14+yOff]["color"] = colors["house1"]
	worldMap[11+xOff][14+yOff]["color"] = colors["house2"]
	worldMap[12+xOff][14+yOff]["color"] = colors["house1"]
	worldMap[13+xOff][14+yOff]["color"] = colors["house1"]
	
	worldMap[17+xOff][5+yOff]["color"] = colors["tree"]
	worldMap[19+xOff][3+yOff]["color"] = colors["tree"]
	worldMap[23+xOff][14+yOff]["color"] = colors["tree"]
	worldMap[24+xOff][16+yOff]["color"] = colors["tree"]
	worldMap[25+xOff][12+yOff]["color"] = colors["tree"]
	worldMap[25+xOff][15+yOff]["color"] = colors["tree"]
	worldMap[25+xOff][17+yOff]["color"] = colors["tree"]
	worldMap[26+xOff][11+yOff]["color"] = colors["tree"]
	worldMap[26+xOff][19+yOff]["color"] = colors["tree"]
	worldMap[27+xOff][12+yOff]["color"] = colors["tree"]
	worldMap[27+xOff][14+yOff]["color"] = colors["tree"]
	worldMap[27+xOff][17+yOff]["color"] = colors["tree"]
	worldMap[27+xOff][21+yOff]["color"] = colors["tree"]
	
	worldMap[24+xOff][6+yOff]["bridge"] = true
	worldMap[24+xOff][8+yOff]["bridge"] = true
	worldMap[24+xOff][9+yOff]["bridge"] = true
	
	for x = 13,15 do
		worldMap[x+xOff][21+yOff]["bridge"] = true
		worldMap[x+xOff][22+yOff]["bridge"] = true
	end
	
	worldMap[27+xOff][6+yOff]["log"] = true
	
	
end

function drawForest(xOff, yOff)
	for x = 0,29 do
		worldMap[x+xOff][4+yOff]["color"] = colors["deep trench"]
		if x < 29 then
			worldMap[x+xOff][5+yOff]["color"] = colors["deep trench"]
		end
		if x < 28 then
			worldMap[x+xOff][6+yOff]["color"] = colors["deep trench"]
		end
		if x < 22 then
			worldMap[x+xOff][7+yOff]["color"] = colors["deep trench"]
		end
		if x > 20 then
			worldMap[x+xOff][3+yOff]["color"] = colors["deep trench"]
		end
	end
	worldMap[28+xOff][0+yOff]["color"] = colors["deep trench"]
	worldMap[29+xOff][0+yOff]["color"] = colors["deep trench"]
	worldMap[28+xOff][1+yOff]["color"] = colors["deep trench"]
	worldMap[29+xOff][1+yOff]["color"] = colors["deep trench"]
	worldMap[27+xOff][2+yOff]["color"] = colors["deep trench"]
	worldMap[28+xOff][2+yOff]["color"] = colors["deep trench"]
	worldMap[29+xOff][2+yOff]["color"] = colors["deep trench"]
	
	--Randomly generate trees in the forest
	for x = 0,32 do
		for y = 8,29 do
			chance = ps_random(100)
			
			if chance <= 10
			   and ((x ~= 15 and y ~= 10) 
			   or (x ~= 25 and y ~= 16) 
			   or (x ~= 10 and y ~= 13) 
			   or (x ~= 16 and y ~= 25)) then
				worldMap[x+xOff][y+yOff]["color"] = colors["tree"]
			end
		end
	end
	placeBerries()
	placeRocks()
	
	worldMap[4+xOff][24+yOff]["npc"] = "animal"
	worldMap[4+xOff][24+yOff]["tag"] = "A bear."
	worldMap[12+xOff][11+yOff]["npc"] = "animal"
	worldMap[12+xOff][11+yOff]["tag"] = "A wolf."
	worldMap[16+xOff][18+yOff]["npc"] = "animal"
	worldMap[16+xOff][18+yOff]["tag"] = "A fox."
	worldMap[21+xOff][26+yOff]["npc"] = "animal"
	worldMap[21+xOff][26+yOff]["tag"] = "A velociraptor."
end

function placeBerries()
	for x = 0, worldMaxX-1 do
		for y = 0, worldMaxY-1 do
			if worldMap[x][y]["item"] == "berries" then
				worldMap[x][y]["item"] = "none"
			end
		end
	end
	
	worldMap[25+37][16+37]["item"] = "berries"
	worldMap[25+37][16+37]["itemTag"] = "A pile of berries."
end

function placeRocks()
	for x = 0, worldMaxX-1 do
		for y = 0, worldMaxY-1 do
			if worldMap[x][y]["item"] == "rocks" then
				worldMap[x][y]["item"] = "none"
			end
		end
	end
	
	worldMap[10+37][13+37]["item"] = "rocks"
	worldMap[10+37][13+37]["itemTag"] = "A pile of rocks."
	worldMap[16+37][25+37]["item"] = "rocks"
	worldMap[16+37][25+37]["itemTag"] = "A pile of rocks."
end

function drawRuins(xOff, yOff)
	worldMap[5+xOff][2+yOff]["npc"] = "guardian"
	worldMap[5+xOff][2+yOff]["tag"] = "The asura guardian of the ruins."
	
	worldMap[25+xOff][24+yOff]["item"] = "light orb"
	worldMap[25+xOff][24+yOff]["itemTag"] = "An orb of light for the lighthouse."
	
	worldMap[7+xOff][9+yOff]["npc"] = "asura"
	worldMap[7+xOff][9+yOff]["tag"] = "An asura."
	worldMap[7+xOff][9+yOff]["messageTag"] = "I like peanuts."
	worldMap[19+xOff][7+yOff]["npc"] = "asura"
	worldMap[19+xOff][7+yOff]["tag"] = "An asura."
	worldMap[19+xOff][7+yOff]["messageTag"] = "I am the leeber queen. Nop nop nop."
	worldMap[27+xOff][14+yOff]["npc"] = "asura"
	worldMap[27+xOff][14+yOff]["tag"] = "An asura."
	worldMap[27+xOff][14+yOff]["messageTag"] = "I think I found a dead end!"
	worldMap[19+xOff][20+yOff]["npc"] = "asura"
	worldMap[19+xOff][20+yOff]["tag"] = "An asura."
	worldMap[19+xOff][20+yOff]["messageTag"] = "Pardon my friends in the maze. They're a little...off."
	worldMap[16+xOff][24+yOff]["npc"] = "asura"
	worldMap[16+xOff][24+yOff]["tag"] = "An asura."
	worldMap[16+xOff][24+yOff]["messageTag"] = "Have you seen a flock of swans pass by recently?"
	worldMap[21+xOff][25+yOff]["npc"] = "asura"
	worldMap[21+xOff][25+yOff]["tag"] = "An asura."
	worldMap[21+xOff][25+yOff]["messageTag"] = "Our ruins are blocked off from the lower lifeforms."
	worldMap[25+xOff][23+yOff]["npc"] = "asura"
	worldMap[25+xOff][23+yOff]["tag"] = "An asura."
	worldMap[25+xOff][23+yOff]["messageTag"] = "So shiny."
	
	for y = 0,4 do
		worldMap[0+xOff][y+yOff]["color"] = colors["deep trench"]
	end
	
	worldMap[1+xOff][0+yOff]["color"] = colors["deep trench"]
	worldMap[1+xOff][1+yOff]["color"] = colors["deep trench"]
	
	for y = 3,29 do
		worldMap[3+xOff][y+yOff]["color"] = colors["stone wall"]
		worldMap[4+xOff][y+yOff]["color"] = colors["stone wall"]
		worldMap[28+xOff][y+yOff]["color"] = colors["stone wall"]
		worldMap[29+xOff][y+yOff]["color"] = colors["stone wall"]
		if y > 5 then
			worldMap[y+xOff][3+yOff]["color"] = colors["stone wall"]
			worldMap[y+xOff][4+yOff]["color"] = colors["stone wall"]
			worldMap[y+xOff][28+yOff]["color"] = colors["stone wall"]
			worldMap[y+xOff][29+yOff]["color"] = colors["stone wall"]
			if y > 6 then
				worldMap[y+xOff][16+yOff]["color"] = colors["stone wall"]
				worldMap[y+xOff][17+yOff]["color"] = colors["stone wall"]
			end
		end
	end
	
	worldMap[5+xOff][28+yOff]["color"] = colors["stone wall"]
	worldMap[5+xOff][29+yOff]["color"] = colors["stone wall"]
	
	for x = 5,13 do
		worldMap[x+xOff][6+yOff]["color"] = colors["stone wall"]
		worldMap[x+11+xOff][6+yOff]["color"] = colors["stone wall"]
	end
	
	worldMap[25+xOff][6+yOff]["color"] = colors["stone wall"]
	worldMap[26+xOff][6+yOff]["color"] = colors["stone wall"]
	worldMap[13+xOff][7+yOff]["color"] = colors["stone wall"]
	worldMap[14+xOff][7+yOff]["color"] = colors["stone wall"]
	worldMap[15+xOff][7+yOff]["color"] = colors["stone wall"]
	worldMap[16+xOff][7+yOff]["color"] = colors["stone wall"]
	worldMap[24+xOff][7+yOff]["color"] = colors["stone wall"]
	worldMap[16+xOff][8+yOff]["color"] = colors["stone wall"]
	worldMap[24+xOff][8+yOff]["color"] = colors["stone wall"]
	worldMap[25+xOff][8+yOff]["color"] = colors["stone wall"]
	worldMap[10+xOff][9+yOff]["color"] = colors["stone wall"]
	worldMap[10+xOff][10+yOff]["color"] = colors["stone wall"]
	worldMap[21+xOff][9+yOff]["color"] = colors["stone wall"]
	
	for x = 12,18 do
		worldMap[x+xOff][9+yOff]["color"] = colors["stone wall"]
	end
	
	for x = 5,10 do
		worldMap[x+xOff][11+yOff]["color"] = colors["stone wall"]
		worldMap[x+18+xOff][10+yOff]["color"] = colors["stone wall"]
	end
	
	worldMap[14+xOff][10+yOff]["color"] = colors["stone wall"]
	worldMap[16+xOff][10+yOff]["color"] = colors["stone wall"]
	worldMap[18+xOff][10+yOff]["color"] = colors["stone wall"]
	worldMap[21+xOff][10+yOff]["color"] = colors["stone wall"]
	
	worldMap[14+xOff][11+yOff]["color"] = colors["stone wall"]
	worldMap[16+xOff][11+yOff]["color"] = colors["stone wall"]
	worldMap[21+xOff][11+yOff]["color"] = colors["stone wall"]
	worldMap[23+xOff][11+yOff]["color"] = colors["stone wall"]
	
	worldMap[14+xOff][12+yOff]["color"] = colors["stone wall"]
	worldMap[16+xOff][12+yOff]["color"] = colors["stone wall"]
	worldMap[12+xOff][12+yOff]["color"] = colors["stone wall"]
	worldMap[25+xOff][12+yOff]["color"] = colors["stone wall"]
	worldMap[26+xOff][12+yOff]["color"] = colors["stone wall"]
	worldMap[27+xOff][12+yOff]["color"] = colors["stone wall"]
	
	for x = 19, 23 do
		worldMap[x+xOff][12+yOff]["color"] = colors["stone wall"]
	end
	
	worldMap[5+xOff][13+yOff]["color"] = colors["stone wall"]
	worldMap[6+xOff][13+yOff]["color"] = colors["stone wall"]
	worldMap[7+xOff][13+yOff]["color"] = colors["stone wall"]
	worldMap[12+xOff][13+yOff]["color"] = colors["stone wall"]
	worldMap[14+xOff][13+yOff]["color"] = colors["stone wall"]
	worldMap[19+xOff][13+yOff]["color"] = colors["stone wall"]
	worldMap[25+xOff][13+yOff]["color"] = colors["stone wall"]
	
	worldMap[7+xOff][14+yOff]["color"] = colors["stone wall"]
	worldMap[25+xOff][14+yOff]["color"] = colors["stone wall"]
	
	for x = 9, 12 do
		worldMap[x+xOff][14+yOff]["color"] = colors["stone wall"]
		worldMap[x+7+xOff][14+yOff]["color"] = colors["stone wall"]
		worldMap[x+12+xOff][14+yOff]["color"] = colors["stone wall"]
	end
	
	worldMap[9+xOff][15+yOff]["color"] = colors["stone wall"]
	
	worldMap[7+xOff][18+yOff]["color"] = colors["stone wall"]
	
	for x = 7,14 do
		worldMap[x+xOff][19+yOff]["color"] = colors["stone wall"]
		worldMap[x+xOff][22+yOff]["color"] = colors["stone wall"]
		worldMap[x+xOff][24+yOff]["color"] = colors["stone wall"]
		worldMap[x+xOff][26+yOff]["color"] = colors["stone wall"]
	end
	
	worldMap[5+xOff][22+yOff]["color"] = colors["stone wall"]
	worldMap[6+xOff][22+yOff]["color"] = colors["stone wall"]
	
	worldMap[6+xOff][24+yOff]["color"] = colors["stone wall"]
	
	worldMap[5+xOff][26+yOff]["color"] = colors["stone wall"]
	worldMap[6+xOff][26+yOff]["color"] = colors["stone wall"]
	
	for y = 20,27 do
		worldMap[17+xOff][y+yOff]["color"] = colors["stone wall"]
		worldMap[18+xOff][y+yOff]["color"] = colors["stone wall"]
	end
	
	worldMap[5+xOff][4+yOff]["breakable block"] = true
	worldMap[14+xOff][18+yOff]["breakable block"] = true
	worldMap[14+xOff][20+yOff]["breakable block"] = true
	worldMap[14+xOff][21+yOff]["breakable block"] = true
	worldMap[14+xOff][23+yOff]["breakable block"] = true
	worldMap[14+xOff][25+yOff]["breakable block"] = true
	worldMap[14+xOff][27+yOff]["breakable block"] = true
	worldMap[17+xOff][18+yOff]["breakable block"] = true
	worldMap[17+xOff][19+yOff]["breakable block"] = true
	worldMap[18+xOff][19+yOff]["breakable block"] = true
	worldMap[18+xOff][18+yOff]["breakable block"] = true
	
end

function drawBoat()
	for x = 11,14 do
		for y = 23,25 do
			worldMap[x+7][y+37]["boat"] = true
		end
	end
	worldMap[10+7][24+37]["boat"] = true
end

function eraseBoat()
	for x = 11,14 do
		for y = 23,25 do
			worldMap[x+7][y+37]["boat"] = false
		end
	end
	worldMap[10+7][24+37]["boat"] = false
end

function resetLog()
	if quests["bridge"] ~= "completed" then
		for x = 0, worldMaxX-1 do
			for y = 0, worldMaxY-1 do
				worldMap[x][y]["log"] = false
			end
		end
		worldMap[27+7][6+37]["log"] = true
	end
end

--Updates all the pieces in the world
function updateGrid()
	displayTablets()
	displayKarma()
	for x = 1, PS_GRID_X-1 do
		for y = 1, PS_GRID_Y-1 do
			worldX = x + playerPos_X - halfGridX
			worldY = y + playerPos_Y - halfGridY
			if x == halfGridX and y == halfGridY then
				--Always display the player
				if incarnation == "human" then
					ps_color(x, y, colors["player_human"])
				elseif incarnation == "bird" then
					ps_color(x, y, colors["player_bird"])
				elseif incarnation == "fish" then
					ps_color(x, y, colors["player_fish"])
				elseif incarnation == "asura" then
					ps_color(x, y, colors["player_asura"])
				elseif incarnation == "preta" then
					ps_color(x, y, colors["player_preta"])
				end
			elseif worldMap[worldX][worldY]["twilight gate"] 
			   and (current_hour < 17 or current_hour > 20) then
				ps_color(x,y, ps_rgb(ps_random(255),ps_random(255),ps_random(255)))
			elseif worldMap[worldX][worldY]["hole"] then
				ps_color(x,y,colors["hole"])
			elseif worldMap[worldX][worldY]["movable block"] then
				ps_color(x,y,colors["movable block"])
			elseif worldMap[worldX][worldY]["breakable block"] then
				ps_color(x,y,colors["breakable block"])
			elseif worldMap[worldX][worldY]["boat"] then
				ps_color(x,y,colors["boat"])
			elseif worldMap[worldX][worldY]["npc"] ~= "none" then
				if worldMap[worldX][worldY]["npc"] == "preta" then
					ps_color(x,y,colors["npcPreta"])
				elseif worldMap[worldX][worldY]["npc"] == "asura" then
					ps_color(x,y,colors["npcAsura"])
				else
					ps_color(x,y,colors["npc"])
				end
			elseif worldMap[worldX][worldY]["bridge"] then
				ps_color(x,y,colors["bridge"])
			elseif worldMap[worldX][worldY]["log"] then
				ps_color(x,y,colors["log"])
			elseif worldMap[worldX][worldY]["item"] ~= "none" then
				ps_color(x,y,colors[worldMap[worldX][worldY]["item"]])
			elseif worldMap[worldX][worldY]["color"] == colors["world edge"] then
				if (worldX < 8 and worldY > 36)
				   or (worldX < 37 and worldY > 66) then
					ps_color(x,y,colors["coastline border"])
				else
					ps_color(x,y,worldMap[worldX][worldY]["color"])
				end
			else
				ps_color(x,y,worldMap[worldX][worldY]["color"])
			end
		end
	end
end

--Changes the time of day as appropriate
function updateTime()
	local hour_alpha -- The alpha of the current hour
	current_ticks = current_ticks + 1
	if current_ticks == ticks_per_hour then
		current_hour = current_hour + 1 -- Increment the hour
		if current_hour == 24 then
			current_hour = 0
		end

		current_ticks = 0

		-- Change the alpha value
		if current_hour > 12 then
			hour_alpha = ((24 - current_hour) * 10) + 100
		else
			hour_alpha = (current_hour * 10) + 100
		end

		-- Change the background
		if current_hour > 5 and current_hour < 10 then
			ps_window(600,600,colors["morning_bg"])
		elseif current_hour > 9 and current_hour < 17 then
			ps_window(600,600,colors["day_bg"])
		elseif current_hour > 16 and current_hour < 21 then
			ps_window(600,600,colors["evening_bg"])
		elseif current_hour > 20 or current_hour < 6 then
			ps_window(600,600,colors["night_bg"])
		end

		for x = 1, PS_GRID_X-1 do
			for y = 1, PS_GRID_Y-1 do
				ps_alpha(x, y, hour_alpha)
			end
		end
	end
end

--Displays the amount of tablets you have
function displayTablets()
	for x = PS_GRID_X-1-maxTablets, PS_GRID_X-1  do
		if PS_GRID_X - x <= tablets then
			ps_alpha(x,0,255)
			ps_color(x,0,colors["tablet"])
		else
			ps_alpha(x,0,0)
		end
	end
end

--Displays the amount of karma you have
function displayKarma()
	ps_alpha(11,0,0)
	ps_alpha(12,0,0)
	for x = 1, maxKarma do
		if x <= karma then
			ps_alpha(x,0,255)
			ps_color(x,0,colors["karma"])
		else
			ps_alpha(x,0,0)
		end
	end
end

--When a space is clicked...
function ps_click (x, y, data)

end

--When a key is pressed...
function ps_key (val)
	if tutorialMode then
		if val == PS_F1 then
			tutorial()
		elseif val == 32 then
			leaveTutorial()
		end
	else
		--If it's an arrow key, prepare to move.
		if val == PS_ARROW_UP then
			playerMove_X = 0
			playerMove_Y =  -1
		elseif val == PS_ARROW_DOWN then
			playerMove_X = 0
			playerMove_Y =  1
		elseif val == PS_ARROW_LEFT then
			playerMove_Y = 0
			playerMove_X = -1
		elseif val == PS_ARROW_RIGHT then
			playerMove_Y = 0
			playerMove_X = 1
		elseif val == PS_F1 and dead and moksha ~= true then
			reincarnate()
		elseif val == 32 then
			if incarnation == "bird" and dead == false then
				diveBomb()
			elseif incarnation == "human" and dead == false then
				forage()
			end
		end
	end
end

--Runs the current tutorial
function tutorial()
	if tutorialType == "beginning" then
		if tutorialCount == 0 then
			ps_message("Samsara | Tutorial: F1. No tutorial: space.")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 1 then
			ps_message("You are a spirit in search of moksha. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 2 then
			ps_message("Moksha is gained through good karma. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 3 then
			ps_message("Karma is gained through good deeds. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 4 then
			ps_message("Gain maximum karma to win. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 5 then
			ps_message("If you die, you are reincarnated. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 6 then
			ps_message("Karma determines your reincarnation. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 7 then
			ps_message("Therefore, death is not the end. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 8 then
			ps_message("Over time, day becomes night and vice-versa. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 9 then
			ps_message("There are three ancient tablets in the world. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 10 then
			ps_message("Each one will automatically give you an ascension. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 11 then
			ps_message("Collect as many as you can on your journeys. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 12 then
			ps_message("You will begin life as a human. (F1)")
			tutorialCount = 0
			tutorialType = "human"
		end
	elseif tutorialType == "preta" then
		if tutorialCount == 0 then
			ps_message("Preta tutorial? Yes: F1. No: space.")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 1 then
			ps_message("As a preta, you have an uncontrollable hunger and thirst. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 2 then
			ps_message("Hence, your kind has fed on all the life around you. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 3 then
			ps_message("You may speak to other preta to hear their tales. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 4 then
			ps_message("Upon touching the cleansing pools... (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 5 then
			ps_message("...you will ascend, becoming a higher being. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 6 then
			ps_message("Enjoy the torment, young one. (F1)")
			tutorialCount = 0
			tutorialType = "none"
		end
	elseif tutorialType == "fish" then
		if tutorialCount == 0 then
			ps_message("Fish tutorial? Yes: F1. No: space.")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 1 then
			ps_message("As a fish, you swim in water. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 2 then
			ps_message("Move with arrow keys. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 3 then
			ps_message("Speaking to fisherman will feed them, giving you karma, but killing you. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 4 then
			ps_message("You can push logs in the water by moving into them. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 5 then
			ps_message("Enjoy the waters, young one. (F1)")
			tutorialCount = 0
			tutorialType = "none"
		end
	elseif tutorialType == "bird" then
		if tutorialCount == 0 then
			ps_message("Bird tutorial? Yes: F1. No: space.")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 1 then
			ps_message("As a bird, you fly over objects. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 2 then
			ps_message("Move with arrow keys. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 3 then
			ps_message("You move continuously, since you fly. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 4 then
			ps_message("Press space to pick up certain objects. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 5 then
			ps_message("Drop objects with space. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 6 then
			ps_message("Giving berries to animals gives you karma. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 7 then
			ps_message("Dropping rocks on animals makes you lose karma. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 8 then
			ps_message("Other objects may have special purposes. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 9 then
			ps_message("Press space on hard surfaces to crash and die. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 10 then
			ps_message("Enjoy the skies, young one. (F1)")
			tutorialCount = 0
			tutorialType = "none"
		end
	elseif tutorialType == "human" then
		if tutorialCount == 0 then
			ps_message("Human tutorial? Yes: F1. No: space.")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 1 then
			ps_message("As a human, you can speak to other humans. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 2 then
			ps_message("Move with arrow keys. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 3 then
			ps_message("Speak to people by walking into them. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 4 then
			ps_message("Some people have quests. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 5 then
			ps_message("Completing quests affects karma. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 6 then
			ps_message("You can also push some blocks. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 7 then
			ps_message("Animals will chase and eat you if you get close. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 8 then
			ps_message("Remember, mouse over things to understand them! (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 9 then
			ps_message("Enjoy the world, young one. (F1)")
			tutorialCount = 0
			tutorialType = "none"
		end
	elseif tutorialType == "asura" then
		if tutorialCount == 0 then
			ps_message("Asura tutorial? Yes: F1. No: space.")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 1 then
			ps_message("As an asura, you are a demigod. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 2 then
			ps_message("Move with arrow keys. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 3 then
			ps_message("You ignore people and animals. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 4 then
			ps_message("You are strong enough to break certain blocks. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 5 then
			ps_message("Move into certain blocks to break them. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 6 then
			ps_message("You are allergic to preta, the low-karma lifeforms of this world. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 7 then
			ps_message("Touching a preta will move you to a cleansing pool to clean the taint. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 8 then
			ps_message("You can also speak to other asura. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 9 then
			ps_message("You are close to moksha. (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 10 then
			ps_message("Only one good deed left... (F1)")
			tutorialCount = tutorialCount + 1
		elseif tutorialCount == 11 then
			ps_message("Enjoy the power, young one. (F1)")
			tutorialCount = 0
			tutorialType = "none"
		end
	elseif tutorialType == "none" then
		leaveTutorial()
	end
end

--Ends the tutorial
function leaveTutorial()
	tutorialCount = 0
	tutorialMode = false
end

--As a bird, allows the player to dive bomb a location.
--The bird will then pick up an item, drop an item, or die.
function diveBomb()
	x = playerPos_X
	y = playerPos_Y
	if worldMap[x][y]["color"] == colors["stone wall"]
	   or worldMap[x][y]["movable block"]
	   or worldMap[x][y]["color"] == colors["house1"]
	   or worldMap[x][y]["color"] == colors["tree"]
	   or worldMap[x][y]["breakable block"] then
		die("crashed")
	elseif worldMap[x][y]["color"] == colors["water"] then
		die("drowned")
	else
		if worldMap[x][y]["npc"] == "animal" or worldMap[x][y]["npc"] == "mother" or worldMap[x][y]["npc"] == "lighthouse man" or worldMap[x][y]["npc"] == "none" then
			if currentItem == "none" then
				pickup(x,y)
			else
				drop(x,y)
			end
		else
			die("crashed")
		end
	end
end

--Humans can pick up berries
function forage()
	if worldMap[playerPos_X][playerPos_Y]["item"] == "berries" then
		if currentItem == "none" then
			pickup(playerPos_X,playerPos_Y)
		else
			drop(playerPos_X,playerPos_Y)
		end
	end
end

--Picks up the item on the location
function pickup(x,y)
	if worldMap[x][y]["item"] ~= "none" then
		ps_play("Chirp1")
		currentItem = worldMap[x][y]["item"]
		worldMap[x][y]["item"] = "none"
	end
end

--Drops current item on the location
function drop(x,y)
	if worldMap[x][y]["npc"] == "animal" and incarnation == "bird" then
		if currentItem == "berries" then
			ps_play("Chirp2")
			currentItem = "none"
			modifyKarma(1)
			ps_message("You fed the animal. (+1 Karma)")
			statusTimer = 30
		elseif currentItem == "rocks" then
			ps_play("Chirp2")
			currentItem = "none"
			modifyKarma(-1)
			ps_message("You hurt the animal. (-1 Karma)")
			statusTimer = 30
		end
	elseif worldMap[x][y]["npc"] == "mother" then
		if currentItem == "child" then
			ps_play("Chirp2")
			currentItem = "none"
			progressQuest(worldMap[x][y]["quest"], "completed")
			ps_message("Thank you for returning my child! (+1 karma)")
			modifyKarma(1)
			statusTimer = 30
		else
			ps_message("Be careful, silly bird.")
			statusTimer = 30
		end
	elseif worldMap[x][y]["npc"] == "lighthouse man" then
		if currentItem == "light orb" then
			ps_play("Chirp2")
			currentItem = "none"
			progressQuest(worldMap[x][y]["quest"], "completed")
			ps_message("Thank you for finding the orb! (+1 karma)")
			modifyKarma(1)
			drawBoat()
			worldMap[11+7][10+37]["color"] = colors["light orb"]
			statusTimer = 30
		else
			ps_message("Be careful, silly bird.")
			statusTimer = 30
		end
	elseif worldMap[x][y]["item"] == "none" then
		ps_play("Chirp2")
		worldMap[x][y]["item"] = currentItem
		currentItem = "none"
	end
end

--Reincarnates the player when they're dead
function reincarnate()
	dead = false
	if karma >= 8 then
		incarnation = "asura"
	elseif karma >= 6 then
		incarnation = "human"
	elseif karma >= 4 then
		incarnation = "bird"
	elseif karma >= 2 then
		incarnation = "fish"
	elseif karma >= 0 then
		incarnation = "preta"
	end
	statusTimer = 0
	playerMove_X = 0
	playerMove_Y = 0
	currentItem = "none"
	playerPos_X = startPositionX[incarnation]
	playerPos_Y = startPositionY[incarnation]
	tutorialMode = true
	tutorialType = incarnation
	tutorialCount = 0
	placeBerries()
	placeRocks()
	respawnItems()
	resetLog()
	updateGrid()
	tutorial()
end

function respawnItems()
	if quests["rescue child"] ~= "completed" then
		for x = 0,worldMaxX-1 do
			for y = 0,worldMaxY-1 do
				if worldMap[x][y]["item"] == "child" then
					worldMap[x][y]["item"] = "none"
				end
			end
		end
		worldMap[9+7][3+7]["item"] = "child"
		worldMap[9+7][3+7]["itemTag"] = "A lost child."
	end
	
	if quests["lighthouse"] ~= "completed" then
		for x = 0,worldMaxX-1 do
			for y = 0,worldMaxY-1 do
				if worldMap[x][y]["item"] == "light orb" then
					worldMap[x][y]["item"] = "none"
				end
			end
		end
		worldMap[25+67][24+37]["item"] = "light orb"
		worldMap[25+67][24+37]["itemTag"] = "An orb of light for the lighthouse."
	end
end

--When the mouse is above something...
function ps_enter (x, y, data, button)
	if dead ~= true and tutorialMode ~= true then
		if ps_color(x,y) == colors["karma"] then
			mouseHover = true
			ps_message("This is your karma bar.")
		elseif ps_color(x,y) == colors["tablet"] then
			mouseHover = true
			ps_message("This is the number of tablets you have so far.")
		elseif x == halfGridX and y == halfGridY then
			mouseHover = true
			inc_string = " "..incarnation
			if inc_string == " asura" then
				inc_string = "n asura"
			end
			ps_message("This is you. You are a"..inc_string..".")
		else
			worldX = x + playerPos_X - halfGridX
			worldY = y + playerPos_Y - halfGridY
			if worldMap[worldX][worldY]["movable block"] then
				mouseHover = true
				ps_message("A movable block (cannot move as an animal).")
			elseif worldMap[worldX][worldY]["breakable block"] then
				mouseHover = true
				ps_message("A huge block.")
			elseif worldMap[worldX][worldY]["twilight gate"] then
				mouseHover = true
				ps_message("The Twilight Gate. Only passable during twilight.")
			elseif worldMap[worldX][worldY]["bridge"] then
				mouseHover = true
				ps_message("A bridge.")
			elseif worldMap[worldX][worldY]["boat"] then
				mouseHover = true
				ps_message("A boat. No pirates!")
			elseif worldMap[worldX][worldY]["color"] == colors["cleansing pool"] then
				mouseHover = true
				ps_message("The cleansing pool.")
			elseif worldMap[worldX][worldY]["color"] == colors["deep trench"] then
				mouseHover = true
				ps_message("A really deep trench.")
			elseif worldMap[worldX][worldY]["color"] == colors["house1"] then
				mouseHover = true
				ps_message("A house.")
			elseif worldMap[worldX][worldY]["color"] == colors["house2"] then
				mouseHover = true
				ps_message("A house.")
			elseif worldMap[worldX][worldY]["color"] == colors["stone wall"] then
				mouseHover = true
				ps_message("Stone wall.")
			elseif worldMap[worldX][worldY]["hole"] then
				mouseHover = true
				ps_message("A hole. It's deep.")
			elseif worldMap[worldX][worldY]["color"] == colors["trench"] then
				mouseHover = true
				ps_message("A trench in which water can flow.")
			elseif worldMap[worldX][worldY]["color"] == colors["world edge"] then
				mouseHover = true
				if (worldX < 8 and worldY > 36)
				   or (worldX < 37 and worldY > 66) then
					ps_message("Waters to a faraway (and really boring) land.")
				else
					ps_message("The mountains surrounding the world.")
				end
			elseif ps_color(x,y) == colors["tree"] then
				mouseHover = true
				ps_message("A tree.")
			elseif worldMap[worldX][worldY]["npc"] ~= "none" then
				mouseHover = true
				ps_message(worldMap[worldX][worldY]["tag"])
			elseif worldMap[worldX][worldY]["item"] ~= "none" then
				mouseHover = true
				ps_message(worldMap[worldX][worldY]["itemTag"])
			elseif worldMap[worldX][worldY]["log"] then
				mouseHover = true
				ps_message("A log that can be used to patch up the bridge.")
			elseif worldMap[worldX][worldY]["color"] == colors["water"] then
				mouseHover = true
				ps_message("Water.")
			else
				mouseHover = false
			end
		end
	end
end

--When the mouse leaves something...
function ps_leave (x, y, data, button)
	mouseHover = false
end

--Every tenth of a second...
function ps_tick ()
	ps_alpha(0,0,0)
	runMusic()
	if tutorialMode == false then
		if incarnation == "human" and quests["bridge"] == "completed" then
			worldMap[5+67][2+37]["npc"] = "guardian"
			worldMap[5+67][2+37]["tag"] = "The asura guardian of the ruins."
		elseif quests["bridge"] == "completed" then
			worldMap[5+67][2+37]["npc"] = "none"
		end
		moveAllNPCs()
		moveWater()
		movePlayer()
		updateTime()
		updateGrid()
		updateStatus()
	end
end

--Moves NPCs according to their own patterns
function moveAllNPCs()
	for x = 0, worldMaxX-1 do
		for y = 0, worldMaxY-1 do
			--Animals hunt humans but ignore everything else.
			--They wander otherwise
			if worldMap[x][y]["npc"] == "animal" then
				modX = 0
				modY = 0

				randNum = ps_random(4)

				if incarnation == "human" and dead ~= true and nearPlayer(x,y) then
					if randNum % 2 == 0 then
						if playerPos_X > x then
							modX = 1
						elseif playerPos_X < x then
							modX = -1
						end
					else
						if playerPos_Y > y then
							modY = 1
						elseif playerPos_Y < y then
							modY = -1
						end
					end
				else
					if randNum == 1 then
						modX = 1
					elseif randNum == 2 then
						modY = 1
					elseif randNum == 3 then
						modX = -1
					else
						modY = -1
					end
				end

				moveNPC(x, y, modX, modY)
			elseif worldMap[x][y]["npc"] == "preta" then
				modX = 0
				modY = 0

				randNum = ps_random(4)

				if incarnation == "asura" and dead ~= true and nearPlayer(x,y) then
					if randNum % 2 == 0 then
						if playerPos_X > x then
							modX = 1
						elseif playerPos_X < x then
							modX = -1
						end
					else
						if playerPos_Y > y then
							modY = 1
						elseif playerPos_Y < y then
							modY = -1
						end
					end
				end

				moveNPC(x, y, modX, modY)
			end
		end
	end
end

function nearPlayer(x, y)
	diffX = math.abs(playerPos_X - x)
	diffY = math.abs(playerPos_Y - y)
	
	return diffX+diffY <= 5
end

function moveNPC(x, y, modX, modY)
	if worldMap[x][y]["move time"] == 0 then
		if npcCanMove(x+modX, y+modY, modX, modY) then
			worldMap[x+modX][y+modY]["npc"] = worldMap[x][y]["npc"]
			worldMap[x+modX][y+modY]["interactions"] = worldMap[x][y]["interactions"]
			worldMap[x+modX][y+modY]["disposition"] = worldMap[x][y]["disposition"]
			worldMap[x+modX][y+modY]["quest"] = worldMap[x][y]["quest"]
			worldMap[x+modX][y+modY]["tag"] = worldMap[x][y]["tag"]
			worldMap[x+modX][y+modY]["move time"] = npcMoveSpeed

			worldMap[x][y]["npc"] = "none"
			worldMap[x][y]["interactions"] = 0
			worldMap[x][y]["disposition"] = 0
			worldMap[x][y]["quest"] = "none"
			worldMap[x][y]["tag"] = "none"
		else
			worldMap[x][y]["move time"] = npcMoveSpeed
		end
	else
		worldMap[x][y]["move time"] = worldMap[x][y]["move time"] - 1
	end
end

function npcCanMove(x, y, modX, modY)
	if worldMap[x][y]["color"] == colors["world edge"]
	   or worldMap[x][y]["color"] == colors["stone wall"]
	   or worldMap[x][y]["color"] == colors["deep trench"]
	   or worldMap[x][y]["color"] == colors["water"]
	   or worldMap[x][y]["color"] == colors["deep trench"]
	   or worldMap[x][y]["color"] == colors["cleansing pool"]
	   or worldMap[x][y]["color"] == colors["house1"]
	   or worldMap[x][y]["color"] == colors["house2"]
	   or worldMap[x][y]["color"] == colors["tree"]
	   or worldMap[x][y]["npc"] ~= "none"
	   or worldMap[x][y]["movable block"]
	   or worldMap[x][y]["breakable block"]
	   or worldMap[x][y]["hole"] then
		return false
	end

	if playerPos_X == x and playerPos_Y == y then
		if dead or (incarnation ~= "human" and incarnation ~= "asura") then
			return false
		else
			if incarnation == "human" then
				die("been eaten")
			elseif worldMap[x-modX][y-modY]["npc"] == "preta" then
				resetPreta(7, 7)
				playerPos_X = 29 + 7
				playerPos_Y = 14 + 7
				return false
			end
		end
	end

	return true
end

--Moves water into trenches that a water space is adjacent to
function moveWater()
	for x = 0, worldMaxX-1 do
		for y = 0, worldMaxY-1 do
			if worldMap[x][y]["color"] == colors["water"] then
				if worldMap[x][y]["water time"] == 0 then
					flowWater(x+1, y)
					flowWater(x, y+1)
					flowWater(x-1, y)
					flowWater(x, y-1)
				else
					worldMap[x][y]["water time"] = worldMap[x][y]["water time"] - 1
				end
			end
		end
	end
end

--Makes more water squares
function flowWater(x, y)
	if (worldMap[x][y]["color"] == colors["trench"]
	   or worldMap[x][y]["color"] == colors["deep trench"])
	   and worldMap[x][y]["breakable block"] ~= true
	   and worldMap[x][y]["movable block"] ~= true then
		worldMap[x][y]["color"] = colors["water"]
		worldMap[x][y]["water time"] = waterFlowCount
	end
end

--Attempt to move the player
function movePlayer()
	if dead ~= true then
		currX = playerPos_X + playerMove_X
		currY = playerPos_Y + playerMove_Y
		currMoveBird = currMoveBird + 1
		if incarnation == "bird" then
			if playerCanMove(currX, currY) then
				if currMoveBird >= birdSpeed then
					currMoveBird = 0
					playerPos_X = currX
					playerPos_Y = currY
				end
			else
				die("crashed")
			end
		else
			if worldMap[playerPos_X][playerPos_Y]["color"] == colors["water"] then
				if worldMap[playerPos_X][playerPos_Y]["bridge"] == false
			       and incarnation ~= "fish" and incarnation ~= "bird" then
					modifyKarma(2)
					displayKarma()
					quests["water flow"] = "completed"
					die("drowned while saving the town")
				end
			elseif worldMap[playerPos_X][playerPos_Y]["hole"] then
				die("fallen in a hole")
			elseif worldMap[playerPos_X][playerPos_Y]["color"] == colors["cleansing pool"]
			   and incarnation == "preta" then
				karma = 2
				die("been cleansed and can ascend")
			end

			if playerCanMove(currX,currY) then
				playerPos_X = currX
				playerPos_Y = currY
			end

			playerMove_X, playerMove_Y = 0,0
		end
	end
end

--Returns true if the player can move to the space given
--Otherwise returns false
function playerCanMove(x,y)
	if worldMap[x][y]["twilight gate"] and (current_hour < 17 or current_hour > 20) 
	   and incarnation ~= "bird" then
		return false
	end
	if incarnation == "fish" and worldMap[x][y]["npc"] == "fisherman" then
		modifyKarma(2)
		die("caught by a hungry fisherman")
		return false
	end
	
	if incarnation == "human" and worldMap[x][y]["boat"] then
		playerPos_X = 3 + 7
		playerPos_Y = 27 + 37
		eraseBoat()
		ps_message("Took a trip on a boat to a strange island...")
		statusTimer = 30
	end
	
	if incarnation == "asura" and worldMap[x][y]["npc"] == "asura" then
		interact(x,y)
		return false
	end
	
	--If there's an NPC in that space, interact with it and don't move
	if worldMap[x][y]["npc"] ~= "none" and (incarnation == "human" or incarnation == "fish") then
		interact(x,y)
		return false
	end
	
	if incarnation == "fish" and worldMap[x][y]["color"] ~= colors["water"] then
		return false
	end
	
	if incarnation == "fish" and worldMap[x][y]["log"] then
		if logCanMove(x + playerMove_X, y + playerMove_Y) == false then
			return false
		end
	end
	
	--If there's a tablet in that space, interact with it and don't move
	if worldMap[x][y]["npc"] == "tablet" and incarnation == "asura" then
		interact(x,y)
		return false
	end
	
	if worldMap[x][y]["npc"] == "guardian" and incarnation == "asura" then
		interact(x,y)
		return false
	end
	
	if worldMap[x][y]["npc"] == "preta" then
		if incarnation == "asura" then
			resetPreta(7, 7)
			playerPos_X = 29 + 7
			playerPos_Y = 14 + 7
			return false
		elseif incarnation == "preta" then
			interact(x,y)
			return false
		end
	end

	--If there's a wall, don't move
	if worldMap[x][y]["color"] == colors["world edge"]
	   or (worldMap[x][y]["color"] == colors["stone wall"] and incarnation ~= "bird") then
		return false
	end

	if (worldMap[x][y]["color"] == colors["house1"]
	   or worldMap[x][y]["color"] == colors["house2"]
	   or worldMap[x][y]["color"] == colors["light orb"]
	   or worldMap[x][y]["color"] == colors["tree"])
	   and incarnation ~= "bird" then
		return false
	end
	
	if (worldMap[x][y]["color"] == colors["water"]
	   or worldMap[x][y]["color"] == colors["deep trench"])
	   and worldMap[x][y]["bridge"] == false
	   and incarnation ~= "fish" and incarnation ~= "bird" then
		return false
	end

	--If there's a block, check to see if it can move
	if worldMap[x][y]["movable block"] then
		if incarnation ~= "bird" then
			if blockCanMove(x + playerMove_X, y + playerMove_Y) == false then
				return false
			end
		end
	end

	if worldMap[x][y]["breakable block"] and incarnation ~= "bird" then
		breakBlock(x, y)
		return false
	end

	return true
end

--Returns true if the block can be moved into the specified location
--Otherwise returns false
--Also, it moves the block if it can move
function blockCanMove(x,y)
	if worldMap[x][y]["color"] == colors["world edge"]
	   or worldMap[x][y]["movable block"]
	   or worldMap[x][y]["npc"] ~= "none"
	   or worldMap[x][y]["breakable block"]
	   or worldMap[x][y]["deep trench"]
	   or worldMap[x][y]["color"] == colors["house1"]
	   or worldMap[x][y]["color"] == colors["house2"]
	   or worldMap[x][y]["color"] == colors["tree"] then
		return false
	end

	if worldMap[x][y]["hole"] then
		ps_play("Shaker", 150)
		worldMap[x][y]["hole"] = false
		worldMap[x-playerMove_X][y-playerMove_Y]["movable block"] = false
		progressQuest(worldMap[x][y]["quest"],"filled hole")
	else
		ps_play("Shaker", 150)
		worldMap[x][y]["movable block"] = true
		worldMap[x-playerMove_X][y-playerMove_Y]["movable block"] = false
	end

	return true
end

--Returns true if the log can be moved into the specified location
--Otherwise returns false
--Also, it moves the block if it can move
function logCanMove(x,y)
	if worldMap[x][y]["color"] ~= colors["water"]
	   or worldMap[x][y]["bridge"] then
		return false
	end
	
	worldMap[x][y]["log"] = true
	worldMap[x-playerMove_X][y-playerMove_Y]["log"] = false
	
	ps_play("Shaker", 150)
	
	if x == 24+7 and y == 7+37 then
		worldMap[x][y]["log"] = false
		worldMap[x][y]["bridge"] = true
		quests["bridge"] = "completed"
		ps_message("You've patched up the bridge! What a nice fish.")
		modifyKarma(1)
		statusTimer = 30
	end

	return true
end

--Interact with the npc at the given location
function interact(x,y)
	npc = worldMap[x][y]["npc"]
	if npc == "tablet" then
		readTablet()
		worldMap[x][y]["npc"] = "none"
	elseif npc == "water man" then
		speakToWaterMan(x,y)
	elseif npc == "stone man" then
		speakToStoneMan(x,y)
	elseif npc == "fisherman" then
		speakToFisherman(x,y)
	elseif npc == "mother" then
		speakToMother(x,y)
	elseif npc == "rich man" then
		speakToRichMan(x,y)
	elseif npc == "poor man" then
		speakToPoorMan(x,y)
	elseif npc == "guardian" then
		speakToGuardian(x,y)
	elseif npc == "lighthouse man" then
		speakToLighthouseMan(x,y)
	elseif npc == "dock man" then
		speakToDockMan(x,y)
	elseif npc == "gate man" then
		ps_message("The drylands are beyond this stone wall.")
		statusTimer = 30
	elseif npc == "river man" then
		if quests["bridge"] == "completed" then
			ps_message("Now I can collect berries in the forest past the bridge!")
			statusTimer = 30
		else
			ps_message("The bridge downstream is broken.")
			statusTimer = 30
		end
	elseif npc == "backyard man" then
		ps_message("Fourteen only dies twice.")
		statusTimer = 30
	elseif npc == "preta" and incarnation == "preta" then
		ps_message(worldMap[x][y]["messageTag"])
		statusTimer = 30
	elseif npc == "asura" and incarnation == "asura" then
		ps_message(worldMap[x][y]["messageTag"])
		statusTimer = 30
	elseif npc == "animal" and incarnation == "human" then
		die("been eaten")
	end
end

--Player reads the tablet
--Gains a karma point
function readTablet()
	if incarnation == "fish" then
		karma = 4
	elseif incarnation == "human" then
		karma = 8
	elseif incarnation == "asura" then
		karma = 10
	end
	tablets = tablets + 1
	displayTablets()
	die("ascended")
end

--Speak to the water man
function speakToWaterMan(x,y)
	if quests["water flow"] == "completed" then
		ps_message("We now have water to grow crops.")
		statusTimer = 30
	else
		if worldMap[x][y]["interactions"] == 0 then
			ps_message("Our crops have no water.")
			statusTimer = 30
		elseif worldMap[x][y]["interactions"] == 1 then
			ps_message("A rock blocks the source of water.")
			statusTimer = 30
		elseif worldMap[x][y]["interactions"] == 2 then
			ps_message("I'll drown if I push it out of the way.")
			statusTimer = 30
		elseif worldMap[x][y]["interactions"] > 2 then
			ps_message("Is it right to die to save the town?")
			statusTimer = 30
		end
		worldMap[x][y]["interactions"] = worldMap[x][y]["interactions"] + 1
	end
end

--Speak to the water man
function speakToStoneMan(x,y)
	if quests["finish stone"] == "filled hole" then
		progressQuest("finish stone", "completed")
		ps_message("Thanks! Now I can enter my house! (+1 Karma)")
		modifyKarma(1)
		statusTimer = 30
	elseif quests["finish stone"] == "completed" then
		ps_message("Somehow the earthquake didn't destroy my house.")
		statusTimer = 30
	else
		if worldMap[x][y]["interactions"] == 0 then
			ps_message("An earthquake created a hole in front of my house!")
			statusTimer = 30
		elseif worldMap[x][y]["interactions"] == 1 then
			ps_message("I can't get inside. Maybe a movable rock could fill it...")
			statusTimer = 30
		elseif worldMap[x][y]["interactions"]  == 2 then
			ps_message("I'm too old to move it on my own.")
			statusTimer = 30
		elseif worldMap[x][y]["interactions"]  > 2 then
			ps_message("Could you move it for me?")
			statusTimer = 30
		end
		worldMap[x][y]["interactions"] = worldMap[x][y]["interactions"] + 1
	end
end

--Speak to the mother
function speakToMother(x,y)
	if quests["rescue child"] == "completed" then
		ps_message("Now my child is safe in my arms.")
		statusTimer = 30
	else
		ps_message("Help! My child has gone missing!")
		statusTimer = 30
	end
end

--Speak to the rich man
function speakToRichMan(x,y)
	if currentItem == "berries" then
		ps_message("Thanks kid! People die for my potions!")
		currentItem = "none"
		modifyKarma(-2)
		statusTimer = 30
	else
		if worldMap[x][y]["interactions"] == 0 then
			ps_message("I need some berries to make poison.")
			statusTimer = 30
		elseif worldMap[x][y]["interactions"] == 1 then
			ps_message("My last vendor was eaten by bears.")
			statusTimer = 30
		elseif worldMap[x][y]["interactions"] > 1 then
			ps_message("Wanna go to the forest and find me some berries?")
			statusTimer = 30
		end
		worldMap[x][y]["interactions"] = worldMap[x][y]["interactions"] + 1
	end
end

--Speak to the poor man
function speakToPoorMan(x,y)
	if currentItem == "berries" then
		ps_message("Thank you kind sir.")
		currentItem = "none"
		modifyKarma(2)
		statusTimer = 30
	else
		if worldMap[x][y]["interactions"] == 0 then
			ps_message("My family needs food or they'll starve.")
			statusTimer = 30
		elseif worldMap[x][y]["interactions"] == 1 then
			ps_message("I'm too frail to go into the forest to find berries.")
			statusTimer = 30
		elseif worldMap[x][y]["interactions"] > 1 then
			ps_message("I feel so hopeless...")
			statusTimer = 30
		end
		worldMap[x][y]["interactions"] = worldMap[x][y]["interactions"] + 1
	end
end

function speakToGuardian(x,y)
	if incarnation == "human" then
		ps_message("You do not belong here, human.")
		statusTimer = 30
	else
		if worldMap[x][y]["interactions"] == 0 then
			ps_message("You have disgraced us, young asura.")
			statusTimer = 30
		elseif worldMap[x][y]["interactions"] == 1 then
			ps_message("You have been vandalizing our ruins.")
			statusTimer = 30
		elseif worldMap[x][y]["interactions"] == 2 then
			ps_message("You will be punished.")
			statusTimer = 30
		elseif worldMap[x][y]["interactions"] > 2 then
			karma = 0
			die("been sentenced to life as a preta")
			worldMap[x][y]["npc"] = "none"
		end
		worldMap[x][y]["interactions"] = worldMap[x][y]["interactions"] + 1
	end
end

function speakToLighthouseMan(x,y)
	if quests["lighthouse"] == "completed" then
		ps_message("Now ships can come to the dock without fear.")
		statusTimer = 30
	else
		if worldMap[x][y]["interactions"] == 0 then
			ps_message("The lighthouse's light orb has flickered out.")
			statusTimer = 30
		elseif worldMap[x][y]["interactions"] == 1 then
			ps_message("Legend has it that the ruins contain one.")
			statusTimer = 30
		elseif worldMap[x][y]["interactions"] > 1 then
			ps_message("It's too dangerous for anyone to enter on foot.")
			statusTimer = 30
		end
		worldMap[x][y]["interactions"] = worldMap[x][y]["interactions"] + 1
	end
end

function speakToFisherman(x,y)
	ps_message("Ah'm just a hungreh fishah lookin' for some fish.")
	statusTimer = 30
end

function speakToDockMan(x,y)
	if quests["lighthouse"] == "completed" then
		ps_message("All aboard!")
		statusTimer = 30
	else
		ps_message("Haven't seen any ships since the lighthouse burned out.")
		statusTimer = 30
	end
end

--Player's karma is modified by the value
function modifyKarma(val)
	karma = karma + val
	if karma < 0 then karma = 0 end
	if karma > maxKarma then karma = maxKarma end
end

--Updates the status message
function updateStatus()
	if dead ~= true and mouseHover ~= true then
		if statusTimer > 0 then
			statusTimer = statusTimer - 1
		else
			if incarnation == "bird" or incarnation == "human" then
				ps_message("Samsara | Item held: "..currentItem)
			else
				ps_message("Samsara")
			end
		end
	end
end

--Break a block at the location given, if the player is the right incarnation
function breakBlock(x,y)
	if incarnation == "asura" then
		ps_play("Bucket")
		worldMap[x][y]["breakable block"] = false
		progressQuest(worldMap[x][y]["quest"], "destroyed block")
		worldMap[x][y]["quest"] = "none"
	end
end

--Progress through a given quest with the given status message
function progressQuest(quest, message)
	if quest ~= "none" then
		quests[quest] = message
	end
end

--Kills the player.
function die(death)
	if incarnation == "preta" then
		ps_play("preta death",100)
	elseif incarnation == "fish" then
		ps_play("Bubble")
	elseif incarnation == "bird" then
		ps_play("Squawk")
	elseif incarnation == "human" then
		ps_play("human death",100)
	else
		ps_play("asura death",100)
	end
	
	dead = true
	if karma >= maxKarma then
		ps_message("You have reached Moksha. You have "..tablets.." of "..maxTablets.." tablets! Congratulations!")
		moksha = true
	else
		ps_message("You have "..death..". F1 to reincarnate.")
	end
end

musicCount = 0
musicChannel = 0
songNumber = 0
newSongNumber = 0

songs = {}

for x = 1,6 do
	songs[x] = {}
end

songs[1]["count"] = 514
songs[1]["name"] = "Drylands"
songs[2]["count"] = 533
songs[2]["name"] = "Town"
songs[3]["count"] = 499
songs[3]["name"] = "Lake"
songs[4]["count"] = 463
songs[4]["name"] = "Coastline"
songs[5]["count"] = 383
songs[5]["name"] = "Forest"
songs[6]["count"] = 590
songs[6]["name"] = "The Ruins"

function runMusic()
	detectSong()
	playSong()
end

function detectSong()
	oneThirdX = (worldMaxX - 1 - (halfGridX-1)*2)/3
	oneHalfY = (worldMaxY - 1 - (halfGridY-1)*2)/2
	
	if playerPos_X < halfGridX-1+oneThirdX then
		if playerPos_Y < halfGridY-1+oneHalfY then
			newSongNumber = 1
		else
			newSongNumber = 4
		end
	elseif playerPos_X < halfGridX-1+oneThirdX*2 then
		if playerPos_Y < halfGridY-1+oneHalfY then
			newSongNumber = 2
		else
			newSongNumber = 5
		end
	else
		if playerPos_Y < halfGridY-1+oneHalfY then
			newSongNumber = 3
		else
			newSongNumber = 6
		end
	end
end

function playSong()
	if newSongNumber == songNumber then
		--If you're playing the same song...
		--Then just check to see if it needs to loop
		if musicCount >= songs[songNumber]["count"] then
			musicChannel = ps_play(songs[songNumber]["name"])
			musicCount = 0
		end
	else
		--If you're not playing the same song...
		--Need to start the other one
		musicCount = 0
		ps_mute(musicChannel)
		songNumber = newSongNumber
		musicChannel = ps_play(songs[songNumber]["name"])
	end
	musicCount = musicCount + 1
end
