--Title of Level
levelTitle = "Sky"

--Color Schemes
drumColor = 0x77EE66
floorColor = 0xB8D1D8
shooterColor = 0x79ADD0
shooterOnAlpha = 200
shooterOffAlpha = 50
sensorColor = 0xF0F2EF
instrumentColor = sensorColor --Don't touch this line

--Speeds
instrumentSpeed = 1
spawnSpeed = 8
sensorSpeed = 16

--Instruments
instrument[1] = "L_Piano_C5"
instrument[2] = "L_Piano_D5"
instrument[3] = "L_Piano_E5"
instrument[4] = "L_Piano_G5"
instrument[5] = "L_Piano_B5"
instrument[6] = "L_Piano_C6"

--Drums
drum[1]["sound"] ="Cymbal_Ride"
drum[1]["speed"] = 4
drum[1]["color"] = drumColor
drum[1]["start"] = 1
drum[1]["velocity"] = "right"
drum[1]["active"] = true

drum[2]["sound"] = "Cymbal_Hihat_Closed"
drum[2]["speed"] = 2
drum[2]["color"] = drumColor
drum[2]["start"] = 1
drum[2]["velocity"] = "right"
drum[2]["active"] = true

drum[3]["sound"] = "Cymbal_Hihat_Closed"
drum[3]["speed"] = 2
drum[3]["color"] = drumColor
drum[3]["start"] = 3
drum[3]["velocity"] = "right"
drum[3]["active"] = true

drum[4]["sound"] = "Cymbal_Hihat_Closed"
drum[4]["speed"] = 2
drum[4]["color"] = drumColor
drum[4]["start"] = 5
drum[4]["velocity"] = "right"
drum[4]["active"] = true

drum[5]["sound"] = "Cymbal_Hihat_Closed"
drum[5]["speed"] = 1
drum[5]["color"] = drumColor
drum[5]["start"] = 7
drum[5]["velocity"] = "right"
drum[5]["active"] = true

drum[6]["sound"] = "Drum_Bass"
drum[6]["speed"] = 2
drum[6]["color"] = drumColor
drum[6]["start"] = 3
drum[6]["velocity"] = "right"
drum[6]["active"] = true

for i = 1, 6 do
	sensorTimer[i] = sensorSpeed
end