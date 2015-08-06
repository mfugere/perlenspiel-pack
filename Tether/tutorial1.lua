--Set player start positions
p1_X = (PS_GRID_X-1)/4
p1_Y = PS_GRID_Y-2
p2_X = (PS_GRID_X-1)/4+(PS_GRID_X-1)/2
p2_Y = PS_GRID_Y-2

for x = 1, PS_GRID_X - 2 do
	for y = 1, PS_GRID_Y-2 do
		worldMap[x][y]["color"] = wallColor
	end
end

worldMap[p1_X][PS_GRID_Y - 3]["color"] = floorColor
worldMap[p1_X][PS_GRID_Y - 4]["color"] = floorColor
worldMap[p1_X][PS_GRID_Y - 5]["color"] = floorColor
worldMap[p1_X][PS_GRID_Y - 6]["color"] = floorColor
worldMap[p1_X][PS_GRID_Y - 7]["color"] = blockColor
worldMap[p1_X][PS_GRID_Y - 8]["color"] = floorColor
worldMap[p1_X][PS_GRID_Y - 9]["color"] = floorColor
worldMap[p1_X][PS_GRID_Y - 10]["color"] = holeColor
worldMap[p1_X][PS_GRID_Y - 10]["door"] = "none"

worldMap[p2_X][PS_GRID_Y - 3]["color"] = floorColor
worldMap[p2_X][PS_GRID_Y - 4]["color"] = floorColor
worldMap[p2_X][PS_GRID_Y - 5]["color"] = floorColor
worldMap[p2_X][PS_GRID_Y - 6]["color"] = floorColor
worldMap[p2_X][PS_GRID_Y - 7]["color"] = blockColor
worldMap[p2_X][PS_GRID_Y - 8]["color"] = floorColor
worldMap[p2_X][PS_GRID_Y - 9]["color"] = floorColor
worldMap[p2_X][PS_GRID_Y - 10]["color"] = holeColor
worldMap[p2_X][PS_GRID_Y - 10]["door"] = "none"