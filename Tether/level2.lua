--Set player start positions
p1_X = (PS_GRID_X-1)/4
p1_Y = PS_GRID_Y-2
p2_X = (PS_GRID_X-1)/4+(PS_GRID_X-1)/2
p2_Y = PS_GRID_Y-2


for x=1,5 do
	worldMap[x][2]["color"] = wallColor
	worldMap[x][8]["color"] = wallColor
end

for y=3,7 do
	worldMap[5][y]["color"] = wallColor
end
worldMap[5][5]["color"] = door2Color

worldMap[3][5]["color"] = blockColor

for y=1,4 do
	worldMap[7][y]["color"] = wallColor
end
worldMap[8][4]["color"] = wallColor
worldMap[9][4]["color"] = door2Color
worldMap[10][4]["color"] = wallColor
worldMap[11][4]["color"] = wallColor

worldMap[1][10]["color"] = holeColor
worldMap[1][10]["door"] = door3Color

worldMap[1][13]["color"] = wallColor
worldMap[2][13]["color"] = wallColor
worldMap[3][13]["color"] = wallColor
worldMap[8][13]["color"] = wallColor

worldMap[3][11]["color"] = wallColor
worldMap[3][12]["color"] = wallColor

worldMap[4][11]["color"] = wallColor
worldMap[5][11]["color"] = wallColor
worldMap[6][11]["color"] = wallColor
worldMap[8][11]["color"] = wallColor

worldMap[6][10]["color"] = blockColor

worldMap[3][11]["color"] = wallColor

worldMap[7][9]["color"] = wallColor
worldMap[8][9]["color"] = wallColor
worldMap[8][10]["color"] = wallColor
worldMap[8][12]["color"] = wallColor

worldMap[9][9]["color"] = wallColor
worldMap[10][9]["color"] = door1Color
worldMap[11][9]["color"] = wallColor

worldMap[11][1]["color"] = holeColor
worldMap[11][1]["door"] = "none"


worldMap[13][12]["color"] = wallColor
worldMap[13][13]["color"] = wallColor
worldMap[14][9]["color"] = wallColor
worldMap[14][10]["color"] = wallColor
worldMap[15][9]["color"] = wallColor
worldMap[15][10]["color"] = wallColor
worldMap[15][12]["color"] = wallColor
worldMap[16][11]["color"] = wallColor
worldMap[16][12]["color"] = wallColor
worldMap[17][10]["color"] = wallColor
worldMap[17][11]["color"] = wallColor
worldMap[17][12]["color"] = wallColor
worldMap[17][13]["color"] = wallColor
worldMap[18][11]["color"] = wallColor

worldMap[15][13]["color"] = blockColor
worldMap[16][13]["color"] = holeColor
worldMap[16][13]["door"] = door1Color

for x=1,6 do
	worldMap[x+12][6]["color"] = wallColor
end

worldMap[21][10]["color"] = wallColor
worldMap[21][11]["color"] = wallColor
worldMap[21][12]["color"] = wallColor

worldMap[21][13]["color"] = door3Color

worldMap[22][13]["color"] = blockColor
worldMap[23][13]["color"] = holeColor
worldMap[23][13]["door"] = door2Color
