--Title of Level
levelTitle = "Sea"

--Color Schemes
drumColor = 0xBB996B
floorColor = 0x057CD8
shooterColor = 0xE5E1E2
shooterOnAlpha = 200
shooterOffAlpha = 50
sensorColor = 0x56B8FF
instrumentColor = sensorColor --Don't touch this line

--Speeds
instrumentSpeed = 2
spawnSpeed = 8
sensorSpeed = 16

--Instruments
instrument[1] = "Piano_C4"
instrument[2] = "Piano_D4"
instrument[3] = "Piano_Eb4"
instrument[4] = "Piano_G4"
instrument[5] = "Piano_B4"
instrument[6] = "Piano_C5"

--Drums
drum[1]["sound"] ="Bongo_Low"
drum[1]["speed"] = 4
drum[1]["color"] = drumColor
drum[1]["start"] = 4
drum[1]["velocity"] = "right"
drum[1]["active"] = true

drum[2]["sound"] = "Shaker"
drum[2]["speed"] = 2
drum[2]["color"] = drumColor
drum[2]["start"] = 5
drum[2]["velocity"] = "left"
drum[2]["active"] = true

drum[3]["sound"] = "Bongo_High"
drum[3]["speed"] = 2
drum[3]["color"] = drumColor
drum[3]["start"] = 3
drum[3]["velocity"] = "right"
drum[3]["active"] = true

drum[4]["sound"] = "Bongo_Low"
drum[4]["speed"] = 2
drum[4]["color"] = drumColor
drum[4]["start"] = 2
drum[4]["velocity"] = "left"
drum[4]["active"] = true

drum[5]["sound"] = "Shaker"
drum[5]["speed"] = 2
drum[5]["color"] = drumColor
drum[5]["start"] = 7
drum[5]["velocity"] = "right"
drum[5]["active"] = true

drum[6]["sound"] = "Cymbal_Ride"
drum[6]["speed"] = 4
drum[6]["color"] = drumColor
drum[6]["start"] = 3
drum[6]["velocity"] = "right"
drum[6]["active"] = false

for i = 1, 6 do
	sensorTimer[i] = sensorSpeed
end