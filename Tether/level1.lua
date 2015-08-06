--Set player start positions
p1_X = (PS_GRID_X-1)/4
p1_Y = PS_GRID_Y-2
p2_X = (PS_GRID_X-1)/4+(PS_GRID_X-1)/2
p2_Y = PS_GRID_Y-2

--Make specific pieces
--Player 1 map

for y = 1, 13 do
	worldMap[1][y]["color"] = wallColor
	worldMap[2][y]["color"] = wallColor
	worldMap[10][y]["color"] = wallColor
	worldMap[11][y]["color"] = wallColor
end

worldMap[3][7]["color"] = door1Color

worldMap[4][3]["color"] = blockColor

for y = 6, 8 do
	worldMap[4][y]["color"] = wallColor
	worldMap[5][y]["color"] = wallColor
	worldMap[6][y]["color"] = wallColor
	worldMap[7][y]["color"] = wallColor
	worldMap[8][y]["color"] = wallColor
	worldMap[9][y]["color"] = wallColor
end

for y = 1, 5 do
	worldMap[6][y]["color"] = wallColor
end

worldMap[6][3]["color"] = door2Color

worldMap[8][3]["color"] = holeColor

--Player 2 map

for y = 1, 13 do
	worldMap[13][y]["color"] = wallColor
	worldMap[14][y]["color"] = wallColor
	worldMap[22][y]["color"] = wallColor
	worldMap[23][y]["color"] = wallColor
end

worldMap[16][3]["color"] = blockColor

worldMap[16][11]["color"] = holeColor
worldMap[16][11]["door"] = door1Color

worldMap[20][3]["color"] = holeColor
worldMap[20][3]["door"] = door2Color

worldMap[20][11]["color"] = blockColor

