-- config.lua for Perlenspiel

PS_STARTUP = "Tether" -- change this to the name of your main .lua file (without the .lua extension)
PS_APPLICATION = "Tether" -- change this to the name of your game (locks out file menu and debugger)

-- System constants!
-- Do not change ANYTHING under this line!

PS_DEFAULT			= -1
PS_CURRENT			= -2
PS_PATH				= ""

-- keys for ps_settings() command

PS_SAVE_RESTORE		= 1
PS_MOUSE_MOTION		= 2
PS_KEY_CAPTURE		= 3
PS_BEAD_FLASH		= 4
PS_TIMER_OVERDRIVE	= 5
PS_MOUSE_RELEASE	= 6

-- keys for ps_font() command

PS_MESSAGE_BOX		= 1
PS_STATUS_BOX		= 2

-- masks for ps_touch() command

PS_ENABLE_CLICK		= 0x0001
PS_ENABLE_EXEC		= 0x0010
PS_ENABLE_SOUND		= 0x0100
PS_ENABLE_ALL		= 0x0111

-- system color definitions

PS_BLACK			= 0x000000
PS_DARK_GRAY		= 0x404040
PS_GRAY				= 0x808080
PS_LIGHT_GRAY		= 0xC0C0C0
PS_WHITE			= 0xFFFFFF
PS_RED				= 0xFF0000
PS_ORANGE			= 0xFF8000
PS_YELLOW			= 0xFFFF00
PS_GREEN			= 0x00FF00
PS_BLUE				= 0x0000FF
PS_INDIGO			= 0x4040FF
PS_VIOLET			= 0x8000FF
PS_MAGENTA			= 0xFF00FF
PS_CYAN				= 0x00FFFF

-- button parameter values for ps_button(), ps_enter() and ps_leave()

PS_BUTTON_NONE		= 0
PS_BUTTON_LEFT		= 1
PS_BUTTON_RIGHT		= 2
PS_BUTTON_BOTH		= 3

-- constants for ps_sound() and ps_play()

PS_VOLUME_MIN	= 0x00
PS_VOLUME_MAX	= 0xFF
PS_PAN_LEFT		= 0x00
PS_PAN_CENTER	= 0x7F
PS_PAN_RIGHT	= 0xFF

-- system key definitions

PS_FKEY_START		= 1024

PS_ARROW_LEFT		= PS_FKEY_START
PS_ARROW_RIGHT		= PS_FKEY_START + 1
PS_ARROW_UP			= PS_FKEY_START + 2
PS_ARROW_DOWN		= PS_FKEY_START + 3

PS_F1		= PS_FKEY_START + 4
PS_F2		= PS_FKEY_START + 5
PS_F3		= PS_FKEY_START + 6
PS_F4		= PS_FKEY_START + 7
PS_F5		= PS_FKEY_START + 8
PS_F6		= PS_FKEY_START + 9
PS_F7		= PS_FKEY_START + 10
PS_F8		= PS_FKEY_START + 11
PS_F9		= PS_FKEY_START + 12
PS_F10		= PS_FKEY_START + 13

-- default width and height of Perlenspiel window

PS_WINDOW_WIDTH = 512
PS_WINDOW_HEIGHT = 640

-- default background color

PS_WINDOW_BGCOLOR = PS_BLACK

PS_GRID_LINE_WIDTH = 2 -- pixel width of grid lines
PS_GRID_LINE_COLOR = PS_DARK_GRAY -- color of grid lines

-- Default bead colors

PS_BEAD_GLYPH_COLOR = PS_WHITE

-- default text sizes

PS_MESSAGE_FONT_SIZE = 24
PS_MESSAGE_FONT_COLOR = PS_WHITE

PS_STATUS_FONT_SIZE = 12
PS_STATUS_FONT_COLOR = PS_WHITE

-- default minimum box size

PS_BOX_MINIMUM = 8

-- library functions

-- Returns a multiplexed RBG from [r], [g] and [b]

function ps_rgb (r, g, b)
	if type(r) ~= "number" then
		error("ps_rgb(): Parameter 1 not a number")
		return
	end	
	r = math.floor(r)
	if r > 0xFF then
		r = 0xFF
	elseif r < 0 then
		r = 0
	end

	if type(g) ~= "number" then
		error("ps_rgb(): Parameter 2 not a number")
		return
	end	
	g = math.floor(g)
	if g > 0xFF then
		g = 0xFF
	elseif g < 0 then
		g = 0
	end

	if type(b) ~= "number" then
		error("ps_rgb(): Parameter 3 not a number")
		return
	end	
	b = math.floor(b)
	if b > 0xFF then
		b = 0xFF
	elseif b < 0 then
		b = 0
	end

	return (r * 0x10000) + (g * 0x100) + b
end

-- returns a random integer between 1 and [n]

function ps_random (n)
	if type(n) ~= "number" then
		error("ps_random(): Parameter not a number")
		return
	end
	
	n = math.floor(n)
	if n < 2 then
		return 1
	else
		return math.random(n)
	end
end

-- seeds the random number generator
-- if parameter is zero, uses the system clock to get a random seed

function ps_seed (n)
	local str
	
	if type(n) ~= "number" then
		error("ps_seed(): Parameter not a number")
		return
	end
	
	n = math.floor(n)
	if n == 0 then
		str = string.sub (ps_date(), 21)
		n = tonumber (str) -- get milliseconds
	end
	math.randomseed (n)
	math.random(17) -- restart it (why is this needed?)
end


PS_PIANO_NOTES =
{
	"Piano_A0",
	"Piano_Bb0",
	"Piano_B0",
	"Piano_C1",
	"Piano_Db1",
	"Piano_D1",
	"Piano_Eb1",
	"Piano_E1",
	"Piano_F1",
	"Piano_Gb1",
	"Piano_G1",
	"Piano_Ab1",
	"Piano_A1",
	"Piano_Bb1",
	"Piano_B1",
	"Piano_C2",
	"Piano_Db2",
	"Piano_D2",
	"Piano_Eb2",
	"Piano_E2",
	"Piano_F2",
	"Piano_Gb2",
	"Piano_G2",
	"Piano_Ab2",
	"Piano_A2",
	"Piano_Bb2",
	"Piano_B2",
	"Piano_C3",
	"Piano_Db3",
	"Piano_D3",
	"Piano_Eb3",
	"Piano_E3",
	"Piano_F3",
	"Piano_Gb3",
	"Piano_G3",
	"Piano_Ab3",
	"Piano_A3",
	"Piano_Bb3",
	"Piano_B3",
	"Piano_C4",
	"Piano_Db4",
	"Piano_D4",
	"Piano_Eb4",
	"Piano_E4",
	"Piano_F4",
	"Piano_Gb4",
	"Piano_G4",
	"Piano_Ab4",
	"Piano_A4",
	"Piano_Bb4",
	"Piano_B4",
	"Piano_C5",
	"Piano_Db5",
	"Piano_D5",
	"Piano_Eb5",
	"Piano_E5",
	"Piano_F5",
	"Piano_Gb5",
	"Piano_G5",
	"Piano_Ab5",
	"Piano_A5",
	"Piano_Bb5",
	"Piano_B5",
	"Piano_C6",
	"Piano_Db6",
	"Piano_D6",
	"Piano_Eb6",
	"Piano_E6",
	"Piano_F6",
	"Piano_Gb6",
	"Piano_G6",
	"Piano_Ab6",
	"Piano_A6",
	"Piano_Bb6",
	"Piano_B6",
	"Piano_C7",
	"Piano_Db7",
	"Piano_D7",
	"Piano_Eb7",
	"Piano_E7",
	"Piano_F7",
	"Piano_Gb7",
	"Piano_G7",
	"Piano_Ab7",
	"Piano_A7",
	"Piano_Bb7",
	"Piano_B7",
	"Piano_C8"
}

PS_L_PIANO_NOTES =
{
	"L_Piano_A0",
	"L_Piano_Bb0",
	"L_Piano_B0",
	"L_Piano_C1",
	"L_Piano_Db1",
	"L_Piano_D1",
	"L_Piano_Eb1",
	"L_Piano_E1",
	"L_Piano_F1",
	"L_Piano_Gb1",
	"L_Piano_G1",
	"L_Piano_Ab1",
	"L_Piano_A1",
	"L_Piano_Bb1",
	"L_Piano_B1",
	"L_Piano_C2",
	"L_Piano_Db2",
	"L_Piano_D2",
	"L_Piano_Eb2",
	"L_Piano_E2",
	"L_Piano_F2",
	"L_Piano_Gb2",
	"L_Piano_G2",
	"L_Piano_Ab2",
	"L_Piano_A2",
	"L_Piano_Bb2",
	"L_Piano_B2",
	"L_Piano_C3",
	"L_Piano_Db3",
	"L_Piano_D3",
	"L_Piano_Eb3",
	"L_Piano_E3",
	"L_Piano_F3",
	"L_Piano_Gb3",
	"L_Piano_G3",
	"L_Piano_Ab3",
	"L_Piano_A3",
	"L_Piano_Bb3",
	"L_Piano_B3",
	"L_Piano_C4",
	"L_Piano_Db4",
	"L_Piano_D4",
	"L_Piano_Eb4",
	"L_Piano_E4",
	"L_Piano_F4",
	"L_Piano_Gb4",
	"L_Piano_G4",
	"L_Piano_Ab4",
	"L_Piano_A4",
	"L_Piano_Bb4",
	"L_Piano_B4",
	"L_Piano_C5",
	"L_Piano_Db5",
	"L_Piano_D5",
	"L_Piano_Eb5",
	"L_Piano_E5",
	"L_Piano_F5",
	"L_Piano_Gb5",
	"L_Piano_G5",
	"L_Piano_Ab5",
	"L_Piano_A5",
	"L_Piano_Bb5",
	"L_Piano_B5",
	"L_Piano_C6",
	"L_Piano_Db6",
	"L_Piano_D6",
	"L_Piano_Eb6",
	"L_Piano_E6",
	"L_Piano_F6",
	"L_Piano_Gb6",
	"L_Piano_G6",
	"L_Piano_Ab6",
	"L_Piano_A6",
	"L_Piano_Bb6",
	"L_Piano_B6",
	"L_Piano_C7",
	"L_Piano_Db7",
	"L_Piano_D7",
	"L_Piano_Eb7",
	"L_Piano_E7",
	"L_Piano_F7",
	"L_Piano_Gb7",
	"L_Piano_G7",
	"L_Piano_Ab7",
	"L_Piano_A7",
	"L_Piano_Bb7",
	"L_Piano_B7",
	"L_Piano_C8"
}

-- Returns the piano note names corresponding to an index (1-88)

function ps_piano (n)
	local len = #PS_PIANO_NOTES

	if type(n) ~= "number" then
		error("ps_piano(): Parameter not a number")
		return
	end
	
	n = math.floor(n)
	if n < 1 then
		n = 1
	elseif n > len then
		n = len
	end
	
	return PS_PIANO_NOTES[n], PS_L_PIANO_NOTES[n]
end

PS_HCHORD_NOTES =
{
	"HChord_A2",
	"HChord_Bb2",
	"HChord_B2",
	"HChord_C3",
	"HChord_Db3",
	"HChord_D3",
	"HChord_Eb3",
	"HChord_E3",
	"HChord_F3",
	"HChord_Gb3",
	"HChord_G3",
	"HChord_Ab3",
	"HChord_A3",
	"HChord_Bb3",
	"HChord_B3",
	"HChord_C4",
	"HChord_Db4",
	"HChord_D4",
	"HChord_Eb4",
	"HChord_E4",
	"HChord_F4",
	"HChord_Gb4",
	"HChord_G4",
	"HChord_Ab4",
	"HChord_A4",
	"HChord_Bb4",
	"HChord_B4",
	"HChord_C5",
	"HChord_Db5",
	"HChord_D5",
	"HChord_Eb5",
	"HChord_E5",
	"HChord_F5",
	"HChord_Gb5",
	"HChord_G5",
	"HChord_Ab5",
	"HChord_A5",
	"HChord_Bb5",
	"HChord_B5",
	"HChord_C6",
	"HChord_Db6",
	"HChord_D6",
	"HChord_Eb6",
	"HChord_E6",
	"HChord_F6",
	"HChord_Gb6",
	"HChord_G6",
	"HChord_Ab6",
	"HChord_A6",
	"HChord_Bb6",
	"HChord_B6",
	"HChord_C7",
	"HChord_Db7",
	"HChord_D7",
	"HChord_Eb7",
	"HChord_E7",
	"HChord_F7"
}
	
PS_L_HCHORD_NOTES =
{
	"L_HChord_A2",
	"L_HChord_Bb2",
	"L_HChord_B2",
	"L_HChord_C3",
	"L_HChord_Db3",
	"L_HChord_D3",
	"L_HChord_Eb3",
	"L_HChord_E3",
	"L_HChord_F3",
	"L_HChord_Gb3",
	"L_HChord_G3",
	"L_HChord_Ab3",
	"L_HChord_A3",
	"L_HChord_Bb3",
	"L_HChord_B3",
	"L_HChord_C4",
	"L_HChord_Db4",
	"L_HChord_D4",
	"L_HChord_Eb4",
	"L_HChord_E4",
	"L_HChord_F4",
	"L_HChord_Gb4",
	"L_HChord_G4",
	"L_HChord_Ab4",
	"L_HChord_A4",
	"L_HChord_Bb4",
	"L_HChord_B4",
	"L_HChord_C5",
	"L_HChord_Db5",
	"L_HChord_D5",
	"L_HChord_Eb5",
	"L_HChord_E5",
	"L_HChord_F5",
	"L_HChord_Gb5",
	"L_HChord_G5",
	"L_HChord_Ab5",
	"L_HChord_A5",
	"L_HChord_Bb5",
	"L_HChord_B5",
	"L_HChord_C6",
	"L_HChord_Db6",
	"L_HChord_D6",
	"L_HChord_Eb6",
	"L_HChord_E6",
	"L_HChord_F6",
	"L_HChord_Gb6",
	"L_HChord_G6",
	"L_HChord_Ab6",
	"L_HChord_A6",
	"L_HChord_Bb6",
	"L_HChord_B6",
	"L_HChord_C7",
	"L_HChord_Db7",
	"L_HChord_D7",
	"L_HChord_Eb7",
	"L_HChord_E7",
	"L_HChord_F7"
}

-- Returns the harpsichord note names corresponding to an index (1-61)

function ps_hchord (n)
	local len = #PS_HCHORD_NOTES

	if type(n) ~= "number" then
		error("ps_hchord(): Parameter not a number")
		return
	end
	
	n = math.floor(n)
	if n < 1 then
		n = 1
	elseif n > len then
		n = len
	end
	
	return PS_HCHORD_NOTES[n], PS_L_HCHORD_NOTES[n]
end

PS_XYLO_NOTES =
{
	"Xylo_A4",
	"Xylo_Bb4",
	"Xylo_B4",
	"Xylo_C5",
	"Xylo_Db5",
	"Xylo_D5",
	"Xylo_Eb5",
	"Xylo_E5",
	"Xylo_F5",
	"Xylo_Gb5",
	"Xylo_G5",
	"Xylo_Ab5",
	"Xylo_A5",
	"Xylo_Bb5",
	"Xylo_B5",
	"Xylo_C6",
	"Xylo_Db6",
	"Xylo_D6",
	"Xylo_Eb6",
	"Xylo_E6",
	"Xylo_F6",
	"Xylo_Gb6",
	"Xylo_G6",
	"Xylo_Ab6",
	"Xylo_A6",
	"Xylo_Bb6",
	"Xylo_B6",
	"Xylo_C7",
	"Xylo_Db7",
	"Xylo_D7",
	"Xylo_Eb7",
	"Xylo_E7",
	"Xylo_F7",
	"Xylo_Gb7",
	"Xylo_G7",
	"Xylo_Ab7",
	"Xylo_A7",
	"Xylo_Bb7",
	"Xylo_B7"
}
	
-- Returns the xylophone note names corresponding to an index (1-61)

function ps_xylo (n)
	local len = #PS_XYLO_NOTES

	if type(n) ~= "number" then
		error("ps_xylo(): Parameter not a number")
		return
	end
	
	n = math.floor(n)
	if n < 1 then
		n = 1
	elseif n > len then
		n = len
	end
	
	return PS_XYLO_NOTES[n]
end
	