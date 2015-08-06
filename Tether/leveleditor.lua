PS_GRID_X = 25
PS_GRID_Y = 16

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

p1_X = (PS_GRID_X-1)/4
p1_Y = PS_GRID_Y-2
p2_X = (PS_GRID_X-1)/4+(PS_GRID_X-1)/2
p2_Y = PS_GRID_Y-2

drawColor = wallColor
drawGlyph = " "
drawGlyphColor = PS_BLACK

worldMap = {}
for x =0,PS_GRID_X-1 do
	worldMap[x]={}
	for y=1,PS_GRID_Y-1 do
		worldMap[x][y] = {}
	end
end

function ps_init ()
	ps_setup (PS_GRID_X, PS_GRID_Y)
	ps_settings(PS_BEAD_FLASH,0)
	ps_settings(PS_SAVE_RESTORE, 1)
	ps_gridlines(1)
	ps_window(720,600,PS_BLUE)
	
	for x = 0, PS_GRID_X-1 do
		for y = 0,PS_GRID_Y-2 do
			if x == (PS_GRID_X-1)/2
			   or x == 0 or x == PS_GRID_X-1
			   or y == 0 or y == PS_GRID_Y-2 then
				ps_color(x,y+1,wallColor)
			else
				ps_color(x,y+1,floorColor)
			end
		end
	end
	
	ps_color(p1_X, p1_Y, playerColor)
	ps_color(p2_X, p2_Y, playerColor)
	
	ps_color(0,0,wallColor)
	ps_color(1,0,floorColor)
	ps_color(2,0,blockColor)
	ps_color(3,0,holeColor)
	ps_glyph(3,0,"0",PS_WHITE)
	ps_color(4,0,holeColor)
	ps_glyph(4,0,"1",PS_WHITE)
	ps_color(5,0,holeColor)
	ps_glyph(5,0,"2",PS_WHITE)
	ps_color(6,0,holeColor)
	ps_glyph(6,0,"3",PS_WHITE)
	ps_color(7,0,holeColor)
	ps_glyph(7,0,"4",PS_WHITE)
	ps_color(8,0,holeColor)
	ps_glyph(8,0,"5",PS_WHITE)
	ps_color(9,0,door1Color)
	ps_glyph(9,0,"1",PS_BLACK)
	ps_color(10,0,door2Color)
	ps_glyph(10,0,"2",PS_BLACK)
	ps_color(11,0,door3Color)
	ps_glyph(11,0,"3",PS_BLACK)
	ps_color(12,0,door4Color)
	ps_glyph(12,0,"4",PS_BLACK)
	ps_color(13,0,door5Color)
	ps_glyph(13,0,"5",PS_BLACK)
end

function ps_click (x, y, data)
	if y == 0 then
		if x < 14 then 
			drawColor = ps_color(x,y)
			drawGlyph, drawGlyphColor = ps_glyph(x,y)
		end
	else
		if x == (PS_GRID_X-1)/2
			   or x == 0 or x == PS_GRID_X-1
			   or y == 1 or y == PS_GRID_Y-1
			   or ps_color(x,y) == playerColor then
				--Do nothing
			else
				ps_color(x,y,drawColor)
				ps_glyph(x,y,drawGlyph,drawGlyphColor)
			end
	end
end

-- ps_state()
-- This function is called when the player wants to save the game
-- It MUST contain a call to ps_save(str), where str is a string containing the game state

-- This function MUST exist if save/restore functionality has been activated with a call to ps_settings (PS_SAVE_RESTORE, 1)
-- It MUST at least call ps_save() with a string representing the game state
-- If you also want to save the state of the grid, change the second ps_save() parameter to a 1

function ps_state ()
	saveString = ""
	saveString = saveString.."p1_X = (PS_GRID_X-1)/4\np1_Y = PS_GRID_Y-2\np2_X = (PS_GRID_X-1)/4+(PS_GRID_X-1)/2\np2_Y = PS_GRID_Y-2\n"
	for x = 1,PS_GRID_X-2 do
		for y=2, PS_GRID_Y-2 do
			tempY = y - 1
			tempString = "worldMap["..x.."]["..tempY.."][\"color\"]="..ps_color(x,y).."\n"
			if ps_color(x,y) == holeColor then
				if ps_glyph(x,y) == string.byte("0") then
					tempString = tempString.."worldMap["..x.."]["..tempY.."][\"door\"]=\"none\"\n"
				elseif ps_glyph(x,y) == string.byte("1") then
					tempString = tempString.."worldMap["..x.."]["..tempY.."][\"door\"]=door1Color\n"
				elseif ps_glyph(x,y) == string.byte("2") then
					tempString = tempString.."worldMap["..x.."]["..tempY.."][\"door\"]=door2Color\n"
				elseif ps_glyph(x,y) == string.byte("3") then
					tempString = tempString.."worldMap["..x.."]["..tempY.."][\"door\"]=door3Color\n"
				elseif ps_glyph(x,y) == string.byte("4") then
					tempString = tempString.."worldMap["..x.."]["..tempY.."][\"door\"]=door4Color\n"
				elseif ps_glyph(x,y) == string.byte("5") then
					tempString = tempString.."worldMap["..x.."]["..tempY.."][\"door\"]=door5Color\n"
				end
			end
			saveString = saveString..tempString
		end
	end
	ps_save (saveString, 0)

	-- Put any other game-save code you need here
end

-- ps_restore()
-- This function is called immediately after the player has restored a gamestate string
-- Use it to perform any post-restore operations

-- This function MUST exist if save/restore functionality has been activated with a call to ps_settings (PS_SAVE_RESTORE, 1)
-- It doesn't have to do anything.

function ps_restore ()
	for x=1, PS_GRID_X - 2 do
		for y=1, PS_GRID_Y-3 do
			ps_color(x,y+1,worldMap[x][y]["color"])
			if worldMap[x][y]["color"]==holeColor then
				if worldMap[x][y]["door"] == door1Color then
					ps_glyph(x,y+1,"1",PS_WHITE)
				elseif worldMap[x][y]["door"] == door2Color then
					ps_glyph(x,y+1,"2",PS_WHITE)
				elseif worldMap[x][y]["door"] == door3Color then
					ps_glyph(x,y+1,"3",PS_WHITE)
				elseif worldMap[x][y]["door"] == door4Color then
					ps_glyph(x,y+1,"4",PS_WHITE)
				elseif worldMap[x][y]["door"] == door5Color then
					ps_glyph(x,y+1,"5",PS_WHITE)
				else
					ps_glyph(x,y+1,"0",PS_WHITE)
				end
			elseif worldMap[x][y]["color"]==door1Color then
				ps_glyph(x,y+1,"1",PS_BLACK)
			elseif worldMap[x][y]["color"]==door2Color then
				ps_glyph(x,y+1,"2",PS_BLACK)
			elseif worldMap[x][y]["color"]==door3Color then
				ps_glyph(x,y+1,"3",PS_BLACK)
			elseif worldMap[x][y]["color"]==door4Color then
				ps_glyph(x,y+1,"4",PS_BLACK)
			elseif worldMap[x][y]["color"]==door5Color then
				ps_glyph(x,y+1,"5",PS_BLACK)
			end
		end
	end
	
	for y=0, PS_GRID_Y-2 do
		ps_glyph(12,y+1,"|",PS_BLACK)
	end	
end




