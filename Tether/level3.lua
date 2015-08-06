--Set player start positions
p1_X = (PS_GRID_X-1)/4
p1_Y = PS_GRID_Y-2
p2_X = (PS_GRID_X-1)/4+(PS_GRID_X-1)/2
p2_Y = PS_GRID_Y-2


for y=1,13 do
	worldMap[1][y]["color"] = wallColor
	worldMap[11][y]["color"] = wallColor
end

worldMap[3][10]["color"] = wallColor
worldMap[3][11]["color"] = wallColor
worldMap[3][12]["color"] = wallColor
worldMap[3][13]["color"] = wallColor

worldMap[5][12]["color"] = wallColor
worldMap[6][12]["color"] = wallColor
worldMap[7][12]["color"] = wallColor

worldMap[9][11]["color"] = wallColor
worldMap[9][12]["color"] = wallColor
worldMap[9][13]["color"] = wallColor

worldMap[2][12]["color"] = blockColor
worldMap[2][10]["color"] = door1Color
worldMap[2][13]["color"] = holeColor
worldMap[2][13]["door"] = "none"

worldMap[10][12]["color"] = blockColor
worldMap[10][13]["color"] = holeColor
worldMap[10][13]["door"] = "none"

worldMap[11][10]["color"] = floorColor

for x=3,10 do
	worldMap[x][8]["color"] = wallColor
end

worldMap[2][8]["color"] = door2Color

--Player 2
worldMap[13][10]["color"] = wallColor
worldMap[13][11]["color"] = wallColor
worldMap[13][13]["color"] = wallColor

worldMap[14][13]["color"] = wallColor

for y=11,13 do
	worldMap[15][y]["color"] = wallColor
	worldMap[16][y]["color"] = wallColor
	worldMap[20][y]["color"] = wallColor
end

for x=16,23 do
	worldMap[x][9]["color"] = wallColor
end

for x = 2, 10 do
	for y = 1,7 do
		if (x+y)%2 == 0 then
			worldMap[x][y]["color"] = blockColor
		end
	end
end

worldMap[10][1]["color"] = holeColor
worldMap[10][1]["door"] = door3Color

worldMap[14][10]["color"] = door3Color
worldMap[21][11]["color"] = blockColor
worldMap[22][11]["color"] = blockColor
worldMap[23][11]["color"] = blockColor
worldMap[22][9]["color"] = holeColor
worldMap[22][9]["door"] = door1Color
worldMap[22][7]["color"] = holeColor
worldMap[22][7]["door"] = door2Color