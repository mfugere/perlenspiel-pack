--Title of Level
levelTitle = "Earth"

--Color Schemes
drumColor = 0x606060
floorColor = 0x303030
shooterColor = 0x754A1F
shooterOnAlpha = 200
shooterOffAlpha = 50
sensorColor = 0xCD8337
instrumentColor = sensorColor --Don't touch this line

--Speeds
instrumentSpeed = 1
spawnSpeed = 8
sensorSpeed = 16

--Instruments
instrument[1] = "L_Hchord_C5"
instrument[2] = "L_Hchord_D5"
instrument[3] = "L_Hchord_E5"
instrument[4] = "L_Hchord_Gb5"
instrument[5] = "L_Hchord_Bb5"
instrument[6] = "L_Hchord_C6"

--Drums
drum[1]["active"] = true
drum[1]["sound"] ="Bongo_Low"
drum[1]["speed"] = 4
drum[1]["start"] = 7
drum[1]["velocity"] = "right"

drum[2]["active"] = true
drum[2]["sound"] = "Triangle"
drum[2]["speed"] = 4
drum[2]["start"] = 6
drum[2]["velocity"] = "left"

drum[3]["active"] = true
drum[3]["sound"] = "Bongo_Low"
drum[3]["speed"] = 4
drum[3]["start"] = 5
drum[3]["velocity"] = "right"

drum[4]["active"] = true
drum[4]["sound"] = "Bongo_High"
drum[4]["speed"] = 4
drum[4]["start"] = 3
drum[4]["velocity"] = "right"

drum[5]["active"] = true
drum[5]["sound"] = "Drum_Bass"
drum[5]["speed"] = 4
drum[5]["start"] = 5
drum[5]["velocity"] = "left"

drum[6]["active"] = true
drum[6]["sound"] = "Bongo_High"
drum[6]["speed"] = 4
drum[6]["start"] = 6
drum[6]["velocity"] = "right"

for i = 1, 6 do
	sensorTimer[i] = sensorSpeed
end