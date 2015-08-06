--Title of Level
levelTitle = "Forest"

--Color Schemes
drumColor = 0x015517
floorColor = 0x102810
shooterColor = 0x037D03
shooterOnAlpha = 200
shooterOffAlpha = 50
sensorColor = 0x3F983F
instrumentColor = sensorColor --Don't touch this line

--Speeds
instrumentSpeed = 1
spawnSpeed = 8
sensorSpeed = 16

--Instruments
instrument[1] = "Xylo_G5"
instrument[2] = "Xylo_C6"
instrument[3] = "Xylo_E6"
instrument[4] = "Xylo_G6"
instrument[5] = "Xylo_Bb6"
instrument[6] = "Xylo_C7"

--Drums
drum[1]["active"] = true
drum[1]["sound"] ="Xylo_G4"
drum[1]["speed"] = 2
drum[1]["start"] = 7
drum[1]["velocity"] = "right"

drum[2]["active"] = true
drum[2]["sound"] = "Triangle"
drum[2]["speed"] = 4
drum[2]["start"] = 6
drum[2]["velocity"] = "left"

drum[3]["active"] = true
drum[3]["sound"] = "Xylo_G4"
drum[3]["speed"] = 2
drum[3]["start"] = 5
drum[3]["velocity"] = "right"

drum[4]["active"] = true
drum[4]["sound"] = "Xylo_C5"
drum[4]["speed"] = 4
drum[4]["start"] = 3
drum[4]["velocity"] = "right"

drum[5]["active"] = true
drum[5]["sound"] = "Woodblock_Low"
drum[5]["speed"] = 4
drum[5]["start"] = 5
drum[5]["velocity"] = "left"

drum[6]["active"] = true
drum[6]["sound"] = "Woodblock_Low"
drum[6]["speed"] = 4
drum[6]["start"] = 6
drum[6]["velocity"] = "right"

for i = 1, 6 do
	sensorTimer[i] = sensorSpeed
end