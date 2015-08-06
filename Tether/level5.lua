--Set player start positions
p1_X = (PS_GRID_X-1)/4
p1_Y = PS_GRID_Y-2
p2_X = (PS_GRID_X-1)/4+(PS_GRID_X-1)/2
p2_Y = PS_GRID_Y-2

--Make specific pieces
--Player 1 map
worldMap[1][1]["color"] = holeColor
worldMap[1][1]["door"] = door2Color

worldMap[3][9]["color"] = blockColor

for y = 1, PS_GRID_Y-2 do
	worldMap[5][y]["color"] = wallColor
end

worldMap[5][7]["color"] = door1Color

worldMap[7][6]["color"] = blockColor

worldMap[8][2]["color"] = wallColor
worldMap[8][3]["color"] = wallColor
worldMap[8][4]["color"] = wallColor
worldMap[8][5]["color"] = wallColor

worldMap[8][9]["color"] = wallColor
worldMap[8][10]["color"] = wallColor
worldMap[8][11]["color"] = wallColor
worldMap[8][12]["color"] = wallColor

worldMap[9][9]["color"] = wallColor
worldMap[9][10]["color"] = wallColor
worldMap[9][11]["color"] = wallColor
worldMap[9][12]["color"] = wallColor

worldMap[9][2]["color"] = wallColor

worldMap[9][3]["color"] = holeColor
worldMap[8][2]["door"] = "none"

worldMap[9][5]["color"] = wallColor

worldMap[9][7]["color"] = blockColor

worldMap[9][8]["color"] = holeColor
worldMap[9][8]["door"] = door3Color

worldMap[10][1]["color"] = door4Color
worldMap[10][2]["color"] = wallColor
worldMap[10][3]["color"] = blockColor

for y = 5,13 do
	worldMap[10][y]["color"] = wallColor
	worldMap[11][y]["color"] = wallColor
end

--Player 2 map
for y=1, PS_GRID_Y-2 do
	worldMap[13][y]["color"] = wallColor
	worldMap[14][y]["color"] = wallColor
end

worldMap[14][2]["color"] = floorColor
--worldMap[15][2]["color"] = wallColor
worldMap[15][3]["color"] = wallColor
worldMap[15][4]["color"] = wallColor
worldMap[15][5]["color"] = wallColor

--worldMap[15][9]["color"] = wallColor
worldMap[15][10]["color"] = wallColor
worldMap[15][11]["color"] = wallColor
worldMap[15][12]["color"] = wallColor

worldMap[16][2]["color"] = wallColor
worldMap[16][3]["color"] = wallColor
--worldMap[16][4]["color"] = wallColor
worldMap[16][5]["color"] = wallColor

worldMap[16][9]["color"] = wallColor
worldMap[16][10]["color"] = wallColor
worldMap[16][11]["color"] = wallColor
worldMap[16][12]["color"] = wallColor

worldMap[17][4]["color"] = blockColor

worldMap[18][2]["color"] = blockColor

worldMap[18][12]["color"] = holeColor
worldMap[18][12]["door"] = door1Color

for y = 1, PS_GRID_Y-2 do
	worldMap[19][y]["color"] = wallColor
end

worldMap[19][7]["color"] = door2Color

worldMap[21][1]["color"] = door4Color

for y = 2, 12 do
	worldMap[21][y]["color"] = wallColor
	worldMap[22][y]["color"] = wallColor
	worldMap[23][y]["color"] = wallColor
end

worldMap[23][2]["color"] = floorColor

worldMap[21][13]["color"] = door3Color

worldMap[22][13]["color"] = blockColor

worldMap[23][13]["color"] = holeColor
worldMap[23][13]["door"] = door4Color

