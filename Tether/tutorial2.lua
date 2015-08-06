--Set player start positions
p1_X = (PS_GRID_X-1)/4
p1_Y = PS_GRID_Y-2
p2_X = (PS_GRID_X-1)/4+(PS_GRID_X-1)/2
p2_Y = PS_GRID_Y-2

worldMap[p1_X][PS_GRID_Y - 7]["color"] = blockColor
worldMap[p1_X][PS_GRID_Y - 10]["color"] = holeColor
worldMap[p1_X][PS_GRID_Y - 10]["door"] = "none"

worldMap[p2_X][PS_GRID_Y - 7]["color"] = blockColor
worldMap[p2_X][PS_GRID_Y - 10]["color"] = holeColor
worldMap[p2_X][PS_GRID_Y - 10]["door"] = "none"