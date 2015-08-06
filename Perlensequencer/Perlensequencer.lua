-- Perlenspiel s1_a3_fugere.lua
-- Perlensequencer: A toy for creating piano and drum loops at a chosen tempo
-- By Matt Fugere
-- This code is released to the public domain

-- REQUIRED FUNCTIONS

-- These globals hold the x and y size of the game grid for reference.
PS_GRID_X = 9
PS_GRID_Y = 10

-- Possible sounds to play
soundbank = {}
soundbank[0] = "Piano_A4"
soundbank[1] = "Piano_G4"
soundbank[2] = "Piano_E4"
soundbank[3] = "Piano_D4"
soundbank[4] = "Piano_C4"
soundbank[5] = "Cymbal_Hihat_Closed"
soundbank[6] = "Drum_Snare"
soundbank[7] = "Drum_Tom3"
soundbank[8] = "Drum_Bass"

-- Is a square "on" (Does a note/beat play there?)
on = {}
for i = 1, 8 do
	on[i] = {}
	for j = 0, 9 do
		on[i][j] = false
	end
end

-- Our current grid location in the update loop
marker_x = 1
marker_y = 0

-- ps_init ()
-- Initializes the game
-- The ps_init() function MUST call ps_setup (x, y),
-- where x and y are the desired size of the grid.

-- Every game MUST include a ps_init() function, and that function MUST call ps_setup() with the x and y dimensions of the grid!

function ps_init ()
	ps_setup (PS_GRID_X, PS_GRID_Y)
	ps_window (PS_DEFAULT, PS_DEFAULT, PS_BLACK)
	ps_gridlines (PS_DEFAULT, PS_GRAY)
	ps_font (PS_MESSAGE_BOX, PS_DEFAULT, PS_WHITE)

	ps_message ("Click spaces to create piano and drum loops!")
	
	-- Color and glyph the "label" column
	for j = 0, 4 do
		ps_color (0, j, PS_LIGHT_GRAY)
	end
	for j = 5, 8 do
		ps_color (0, j, PS_GRAY)
	end
	ps_color (0, 9, PS_DARK_GRAY)
	ps_glyph (0, 0, "A", PS_BLACK)
	ps_glyph (0, 1, "G", PS_BLACK)
	ps_glyph (0, 2, "E", PS_BLACK)
	ps_glyph (0, 3, "D", PS_BLACK)
	ps_glyph (0, 4, "C", PS_BLACK)
	ps_glyph (0, 5, "H", PS_BLACK)
	ps_glyph (0, 6, "S", PS_BLACK)
	ps_glyph (0, 7, "T", PS_BLACK)
	ps_glyph (0, 8, "B", PS_BLACK)
	ps_glyph (0, 9, "T", PS_BLACK)
	
	-- Set the starting tempo
	for i = 1, 5 do
		ps_color (i, 9, 0x009966)
	end
	ps_timer (3)
end

-- ps_click (x, y, data)
-- This function is called whenever a bead is clicked
-- x = the x-position of the bead on the grid
-- y = the y-position of the bead on the grid
-- data = the data value associated with this bead, 0 if none has been set

-- Every game MUST include a ps_click() function. It doesn't have to do anything.

function ps_click (x, y, data)
	-- If the tempo row wasn't clicked
	if y ~= 9 then
		-- If the label column wasn't clicked
		if x ~= 0 then
			-- If the current grid location is not filled
			if on[x][y] == false then
				-- Color it
				if y < 5 then
					ps_color (x, y, 0x00CC33)
				else
					ps_color (x, y, 0x009933)
				end
				-- Turn it on
				on[x][y] = true
			-- If it is already on, turn it off
			else
				ps_color (x, y, PS_BLACK)
				on[x][y] = false
			end
		end
	-- If the tempo row was clicked
	else
		-- Color it up to the clicked space
		for i = 1, x do
			ps_color (i, y, 0x009966)
		end
		for i = x + 1, 8 do
			ps_color (i, y, PS_BLACK)
		end
		-- Set the tempo (update frequency)
		ps_timer ((1 / x) * 15)
	end
end

-- OPTIONAL FUNCTIONS
-- These are only needed when special functionality has been activated with ps_settings()

-- ps_key (val)
-- This function is called whenever a key on the keyboard is pressed
-- val = the ASCII code of the pressed key, or one of the following Lua constants:
-- Arrow keys = PS_UP_ARROW, PS_DOWN_ARROW, PS_LEFT_ARROW, PS_RIGHT_ARROW
-- Function keys = PS_F1 through PS_F12

-- This function MUST exist if key capture has been enabled with ps_settings (PS_KEY_CAPTURE, 1)
-- It doesn't have to do anything.

function ps_key (val)
	-- placeholder
end

-- ps_enter (x, y, data, button)
-- This function is called whenever the mouse over a bead
-- x = the x-position of the bead on the grid
-- y = the y-position of the bead on the grid
-- data = the data value associated with this bead, 0 if none has been set
-- button = 1 if mouse button is held down, else 0

-- This function MUST exist if mouse motion sensing has been enabled with ps_settings (PS_MOUSE_MOTION, 1).
-- It doesn't have to do anything.

function ps_enter (x, y, data, button)
	
end

-- ps_leave(x, y, data, button)
-- This function is called whenever the mouse moves away from a bead
-- x = the x-position of the bead on the grid
-- y = the y-position of the bead on the grid
-- data = the data value associated with this bead, 0 if none has been set
-- button = 1 if mouse button is held down, else 0

-- This function MUST exist if mouse motion sensing has been enabled with ps_settings (PS_MOUSE_MOTION, 1).
-- It doesn't have to do anything.

function ps_leave (x, y, data, button)
	
end

-- ps_tick ()
-- This function is called on every clock tick

-- This function MUST exist if the timer has been activated with a call to ps_timer()
-- It doesn't have to do anything.

function ps_tick ()
	-- For each space in the current column
	for marker_y = 0, 8 do
		-- If the space is on, play its sound
		if on[marker_x][marker_y] == true then
			ps_play (soundbank[marker_y])
		end
	end
	
	-- Move to the next column or back to the first
	if marker_x == 8 then
		marker_x = 1
	else
		marker_x = marker_x + 1
	end
end

-- ps_state()
-- This function is called when the player wants to save the game
-- It MUST contain a call to ps_save(str), where str is a string containing the game state

-- This function MUST exist if save/restore functionality has been activated with a call to ps_settings (PS_SAVE_RESTORE, 1)
-- It MUST at least call ps_save() with a string representing the game state

function ps_state ()
	ps_save ("Your gamestate string\n")

	-- Put any other game-save code you need here
end

-- ps_restore()
-- This function is called immediately after the player has restored a gamestate string
-- Use it to perform any post-restore operations

-- This function MUST exist if save/restore functionality has been activated with a call to ps_settings (PS_SAVE_RESTORE, 1)
-- It doesn't have to do anything.

function ps_restore ()
	-- Put code here to perform any post-restore operations
end




