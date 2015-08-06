--Title of Level
levelTitle = "Volcano"

--Color Schemes
drumColor = 0x660033
floorColor = 0x000000
shooterColor = 0xFF3333
shooterOnAlpha = 200
shooterOffAlpha = 50
sensorColor = 0xFF6633
instrumentColor = sensorColor --Don't touch this line

--Speeds
instrumentSpeed = 1
spawnSpeed = 8
sensorSpeed = 16

--Instruments
instrument[1] = "Xylo_C5"
instrument[2] = "Xylo_Db5"
instrument[3] = "Xylo_F5"
instrument[4] = "Xylo_G5"
instrument[5] = "Xylo_Bb5"
instrument[6] = "Xylo_C6"

--Drums
drum[1]["sound"] ="Drum_Snare"
drum[1]["speed"] = 1
drum[1]["color"] = drumColor
drum[1]["start"] = 2
drum[1]["velocity"] = "right"
drum[1]["active"] = true

drum[2]["sound"] = "Drum_Snare"
drum[2]["speed"] = 4
drum[2]["color"] = drumColor
drum[2]["start"] = 5
drum[2]["velocity"] = "left"
drum[2]["active"] = true

drum[3]["sound"] = "Drum_Tom4"
drum[3]["speed"] = 2
drum[3]["color"] = drumColor
drum[3]["start"] = 4
drum[3]["velocity"] = "right"
drum[3]["active"] = true

drum[4]["sound"] = "Drum_Tom3"
drum[4]["speed"] = 2
drum[4]["color"] = drumColor
drum[4]["start"] = 7
drum[4]["velocity"] = "left"
drum[4]["active"] = true

drum[5]["sound"] = "Drum_Tom2"
drum[5]["speed"] = 2
drum[5]["color"] = drumColor
drum[5]["start"] = 7
drum[5]["velocity"] = "right"
drum[5]["active"] = true

drum[6]["sound"] = "Cymbal_Hihat_Closed"
drum[6]["speed"] = 1
drum[6]["color"] = drumColor
drum[6]["start"] = 6
drum[6]["velocity"] = "right"
drum[6]["active"] = true

for i = 1, 6 do
	sensorTimer[i] = sensorSpeed
end