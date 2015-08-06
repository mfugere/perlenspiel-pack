-- Viraleperlenspiel
-- by Mattam Enigma (Matt Fugere and Tamlyn Miller)
-- This code is released to the public domain

-- REQUIRED FUNCTIONS

-- These globals hold the x and y size of the game grid for reference.

PS_GRID_X = 12
PS_GRID_Y = 14 --Must be two higher than X

player_x = 0
player_y = 2

enemy_x = 6
enemy_shoot_time = 40 --How many ticks it takes to shoot
enemy_move_time = 10 --How many ticks is 1 tick (for enemy/projectiles)

hole_move_time = 10 --How many ticks 'til the hole moves.
hole_x = PS_GRID_X-2
hole_y = PS_GRID_Y-2

tick_count = 0 --Keeps track of enemy movement
hole_count = 0 --Keeps track of hole movement
hole_absorb = 0 --Keeps track of how many times a hole has absorbed an arrow
shoot_count = 0 -- Keeps track of enemy shooting
turns = 0 --How many turns have passed sofar?

winning = false

colorArray = {0x74C2E1,0xCA75E1,0xE1758D,0xE19475,0xE1CA75,0x8DE175}
curr_color = 1
hole_color = colorArray[ps_random(6)] --The color the hole replaced

--Music stuff (change these variables only if you change the song)
--How many engine ticks per beat (quarter note)
ticks_per_beat = 4
--How many beats per measure
beats_per_measure = 4 --it's in 4/4 time
--How many measures until it repeats
total_measures = 8
music_count = 0 --Keeps track of current ticks
first_time = true --Whether the music has played through once already

-- ps_init ()
-- Initializes the game
-- The ps_init() function MUST call ps_setup (x, y),
-- where x and y are the desired size of the grid.
function ps_init ()
	ps_setup (PS_GRID_X, PS_GRID_Y)
	ps_gridlines (3, PS_BLACK)
	ps_window (600, 600, PS_WHITE)
	ps_settings (PS_BEAD_FLASH, 0)
	ps_settings (PS_KEY_CAPTURE, 1)
	ps_font (PS_MESSAGE_BOX, PS_CURRENT, PS_BLACK)
	ps_font (PS_STATUS_BOX, PS_CURRENT, PS_BLACK)
	--Mouse clicking is handled through ps_exec
	for x = 0, PS_GRID_X-1 do
		if x < 6 then
			ps_color (x, 0, colorArray[x+1])
			exec_val = x + 1
			exec_string = "change_color("..exec_val..")"
			ps_exec(x, 0, exec_string)
		end
		for y = 0, PS_GRID_Y-1 do
			ps_border (x, y, 0)
			if  y > 1 then
				ps_color (x, y, colorArray[ps_random(6)])
			end
		end
	end
	ps_message ("Viraleperlenspiel")
	ps_status ("Click the top row to spread color. Avoid arrows and holes. Get to X with arrow keys! 'r' restarts.")
	--Place an X at the upper row and the goal
	ps_glyph (0, 0, "X", PS_WHITE)
	ps_glyph (PS_GRID_X-1, PS_GRID_Y-1, "X", 0x000000)
	ps_color (0, 2, colorArray[1])
	ps_border (0, 2, 1)
	--Make the enemies
	ps_glyph (enemy_x, 1, "O", PS_BLACK)
	ps_color (hole_x, hole_y, PS_BLACK)
	--Initialize the timer
	ps_timer(1)
end

-- ps_click (x, y, data)
-- This function is called whenever a bead is clicked
-- x = the x-position of the bead on the grid
-- y = the y-position of the bead on the grid
-- data = the data value associated with this bead, 0 if none has been set
function ps_click (x, y, data)

end

-- ps_key (val)
-- This function is called whenever a key on the keyboard is pressed
-- val = the ASCII code of the pressed key, or one of the following Lua constants:
-- Arrow keys = PS_ARROW_UP, PS_ARROW_DOWN, PS_ARROW_LEFT, PS_ARROW_RIGHT
-- Function keys = PS_F1 through PS_F12
function ps_key (val)
	--Arrow keys and WASD are used to move the player
	if val == PS_ARROW_UP or val == string.byte("w") then
		move_player(0,-1)
	elseif val == PS_ARROW_DOWN or val == string.byte("s") then
		move_player(0,1)
	elseif val == PS_ARROW_LEFT or val == string.byte("a") then
		move_player(-1,0)
	elseif val == PS_ARROW_RIGHT or val == string.byte("d") then
		move_player(1,0)
	elseif val == string.byte("r") then
		reset() -- 'r' is used to reset the game
	end
end

-- ps_tick ()
-- This function is called on every clock tick
function ps_tick ()
	play_music()
	--If the player ever collides with a V glyph, end the game
	if ps_glyph (player_x, player_y) == string.byte("V") then
		reset()
		ps_play ("Uhoh")
	end

	--If a hole collides with an arrow, increase its speed
	if ps_glyph(hole_x,hole_y) == string.byte("V") then
		hole_absorb = hole_absorb + 1
		ps_glyph(hole_x,hole_y," ")
		ps_play ("Error2")
	end

	--If the player collides with a hole, end the game
	if ps_color(player_x, player_y) == PS_BLACK then
		ps_play ("Uhoh")
		reset();
	end

	--If the player won, flash the screen 'cause it's pretty.
	--You see, winners deserve seizures.
	if winning == true then
		randColor = ps_random(6)
		for x = 0, PS_GRID_X-1 do
			for y = 2, PS_GRID_Y-1 do
				ps_color (x, y, colorArray[randColor])
			end
		end
	else
		--If it's time to move sprites, do it.
		tick_count = tick_count + 1
		if tick_count == enemy_move_time then
			tick_count = 0

			--Move enemy
			rand = ps_random (3)
			if rand == 1 and enemy_x+1 < PS_GRID_X then
				ps_glyph (enemy_x, 1, " ")
				ps_glyph (enemy_x+1, 1, "O", PS_BLACK)
				enemy_x = enemy_x + 1
			elseif rand == 2 and enemy_x-1 >= 0 then
				ps_glyph (enemy_x, 1, " ")
				ps_glyph (enemy_x-1, 1, "O", PS_BLACK)
				enemy_x = enemy_x - 1
			end

			--Move all projectiles
			i = PS_GRID_X-1
			while i >= 0 do
				j = PS_GRID_Y-1
				while j >= 2 do
					if ps_glyph (i, j) == string.byte("V") then
						ps_glyph (i, j, " ")
						if j+1 < PS_GRID_Y then
							if i ~= PS_GRID_X - 1 or j+1 ~= PS_GRID_Y-1 then
								ps_glyph (i, j+1, "V", PS_BLACK)
							end
						end
					end
					j = j - 1
				end
				i = i - 1
			end
		end

		--Move the hole such that it targets the player
		hole_count = hole_count + 1
		if hole_count >= hole_move_time - math.min(5, hole_absorb) then
			hole_count = 0
			rand = ps_random(2)
			if rand == 1 then
				if player_x > hole_x then
					ps_color(hole_x, hole_y, hole_color)
					hole_x = hole_x + 1
					hole_color = ps_color (hole_x, hole_y)
					ps_color (hole_x, hole_y, PS_BLACK)
				elseif player_x < hole_x then
					ps_color (hole_x, hole_y, hole_color)
					hole_x = hole_x - 1
					hole_color = ps_color (hole_x, hole_y)
					ps_color (hole_x, hole_y, PS_BLACK)
				end
			else
				if player_y > hole_y then
					ps_color (hole_x, hole_y, hole_color)
					hole_y = hole_y + 1
					hole_color = ps_color (hole_x, hole_y)
					ps_color (hole_x, hole_y, PS_BLACK)
				elseif player_y < hole_y then
					ps_color (hole_x, hole_y, hole_color)
					hole_y = hole_y - 1
					hole_color = ps_color (hole_x, hole_y)
					ps_color (hole_x, hole_y, PS_BLACK)
				end
			end

		end

		--If it's time to shoot, shoot.
		shoot_count = shoot_count + 1
		if shoot_count >= enemy_shoot_time - math.min(enemy_shoot_time-20,turns)  then
			ps_glyph (enemy_x, 2, "V", PS_BLACK)
			shoot_count = 0
		end
	end
end

--change_color(val)
--Change the selected color and call change_space
function change_color(val)
	--Each time a new color is selected, add a turn
	if ps_glyph(val-1, 0) ~= string.byte("X") then
		turns = turns + 1
	end
	--Move the color selecting glyph
	ps_glyph (curr_color-1, 0, " ", PS_BLACK)
	ps_glyph (val-1, 0, "X", PS_WHITE)
	curr_color = val
	--Change each controlled space's color along with any new spaces absorbed by the player
	change_space (player_x, player_y)
	for x = 0, PS_GRID_X-1 do
		for y = 2, PS_GRID_Y-1 do
			ps_data (x, y, 0)
		end
	end
end

--change_space(x, y)
--Change the color of the current space and recurse through all spaces
function change_space(x, y)
	--Space verification
	ps_data(x, y, 1)

	--Assimilate all conquered squares to the current color
	if x < PS_GRID_X-1 and
		ps_data (x+1, y) == 0 and
		(ps_color (x, y) == ps_color (x+1, y) or (ps_color (x, y) == PS_BLACK and
		ps_color (x+1, y) == hole_color) or (ps_color (x+1, y) == PS_BLACK and
		ps_color (x, y) == hole_color)) then
		change_space(x+1, y)
	end

	if y < PS_GRID_Y-1 and ps_data (x, y+1) == 0 and
		(ps_color(x, y) == ps_color(x, y+1) or
		(ps_color(x, y) == PS_BLACK and ps_color(x, y+1) == hole_color) or
		(ps_color(x, y+1) == PS_BLACK and ps_color(x, y) == hole_color)) then
		change_space(x,y+1)
	end

	if x > 0 and
		ps_data(x-1, y) == 0 and
		(ps_color(x, y) == ps_color(x-1, y) or
		(ps_color(x, y) == PS_BLACK and ps_color(x-1, y) == hole_color) or
		(ps_color(x-1, y) == PS_BLACK and ps_color(x, y) == hole_color)) then
		change_space(x-1, y)
	end

	if y > 0 and ps_data(x, y-1) == 0 and
		(ps_color(x, y) == ps_color (x, y-1) or
		(ps_color(x, y) == PS_BLACK and ps_color(x, y-1) == hole_color) or
		(ps_color(x, y-1) == PS_BLACK and ps_color(x, y) == hole_color)) then
		change_space(x, y-1)
	end

	if ps_color(x, y) == PS_BLACK then
		hole_color = colorArray[curr_color]
	else
		ps_color(x, y, colorArray[curr_color])
	end
end

--move_player(x, y)
--Moves the player within the boundaries of conquered spaces
function move_player(x, y)
	new_x, new_y = player_x, player_y

	if new_x + x >= 0 and new_x + x < PS_GRID_X then
		new_x = new_x + x
	end

	if new_y + y >= 0 and new_y + y < PS_GRID_Y then
		new_y = new_y + y
	end

	if ps_color(player_x, player_y) == ps_color(new_x, new_y) or ps_color(new_x,new_y)==PS_BLACK then
		ps_border(player_x,player_y,0)
		ps_border(new_x,new_y,1)
		player_x,player_y = new_x,new_y
	end

	--If the player reaches X end the game
	if ps_glyph(player_x,player_y) == 88 then
		win()
	end
end

--reset()
--Resets the game to its initial values with a newly-randomized board
function reset()
	for x = 0, PS_GRID_X-1 do
		if x < 6 then
			ps_color(x, 0, colorArray[x+1])
			exec_val = x + 1
			exec_string = "change_color("..exec_val..")"
			ps_exec(x, 0, exec_string)
		end
		for y = 0, PS_GRID_Y-1 do
			ps_border(x, y, 0)
			ps_glyph(x, y, " ")
			if  y > 1 then
				ps_color(x, y, colorArray[ps_random(6)])
			end
		end
	end
	ps_glyph (0, 0, "X", PS_WHITE)
	ps_glyph (PS_GRID_X-1, PS_GRID_Y-1, "X", 0x000000)
	ps_color(0, 2, colorArray[1])
	ps_border(0, 2, 1)
	enemy_x = 6
	tick_count = 0
	shoot_count = 0
	ps_glyph (enemy_x, 1, "O", PS_BLACK)
	player_x, player_y = 0, 2
	winning = false
	turns = 0
	curr_color = 1
	hole_x = PS_GRID_X - 2
	hole_y = PS_GRID_Y - 2
	ps_color(hole_x, hole_y, PS_BLACK)
	hole_absorb = 0
	ticks_per_beat = 4
	ps_status ("Click the top row to spread color. Avoid arrows and holes. Get to X with arrow keys! 'r' restarts.")
end

--win()
--Display the winning animation and such
function win()
	winning = true
	ps_status("YOU WON! Press 'r' to play again.")
	ps_play ("Ding")

	--Seizure!
	for x = 0, PS_GRID_X-1 do
		for y = 0, PS_GRID_Y-1 do
			ps_border(x, y, 0)
			ps_glyph(x, y, " ")
		end
	end
end

--play_music()
--This function plays the music of the game.
function play_music ()
	--If it's time to repeat, reset the count
	if music_count >= ticks_per_beat * beats_per_measure * total_measures then
		music_count = 0
	end

	--This if statement is for the melody
	if music_count == (beats_per_measure*0 + 0) * ticks_per_beat then
		ps_play("Piano_C2")
		ps_play("Drum_Bass")
	elseif music_count == (beats_per_measure*0 + 1) * ticks_per_beat then
		ps_play("Piano_C2")
	elseif music_count == (beats_per_measure*0 + 2) * ticks_per_beat then
		ps_play("L_Hchord_Ab4")
		ps_play("Piano_C4")
		ps_play("Piano_E4")
		ps_play("Piano_Gb4")
		ps_play("Tambourine")
	elseif music_count == (beats_per_measure*0 + 3) * ticks_per_beat then

	elseif music_count == (beats_per_measure*1 + 0) * ticks_per_beat then
		ps_play("L_Hchord_Bb4")
		ps_play("Piano_C2")
		ps_play("Triangle")
	elseif music_count == (beats_per_measure*1 + 1) * ticks_per_beat then
		ps_play("Piano_C2")
	elseif music_count == (beats_per_measure*1 + 2) * ticks_per_beat then
		ps_play("Xylo_Eb5")
		ps_play("Tambourine")
	elseif music_count == (beats_per_measure*1 + 3) * ticks_per_beat then
		ps_play("Xylo_E5")
	elseif music_count == (beats_per_measure*2 + 0) * ticks_per_beat then
		ps_play("Xylo_Eb5")
		ps_play("Piano_C2")
		ps_play("Drum_Bass")
	elseif music_count == (beats_per_measure*2 + 1) * ticks_per_beat then
		ps_play("Xylo_Db5")
		ps_play("Piano_C2")
	elseif music_count == (beats_per_measure*2 + 2) * ticks_per_beat then
		ps_play("Xylo_Ab4")
		ps_play("Tambourine")
	elseif music_count == (beats_per_measure*2 + 3) * ticks_per_beat then

	elseif music_count == (beats_per_measure*3 + 0) * ticks_per_beat then
		ps_play("Piano_C2")
	elseif music_count == (beats_per_measure*3 + 1) * ticks_per_beat then
		ps_play("Piano_C2")
	elseif music_count == (beats_per_measure*3 + 2) * ticks_per_beat then
		ps_play("Tambourine")
	elseif music_count == (beats_per_measure*3 + 3) * ticks_per_beat then

	elseif music_count == (beats_per_measure*4 + 0) * ticks_per_beat then
		ps_play("Piano_C2")
		ps_play("Drum_Bass")
	elseif music_count == (beats_per_measure*4 + 1) * ticks_per_beat then
		ps_play("Piano_C2")
	elseif music_count == (beats_per_measure*4 + 2) * ticks_per_beat then
		ps_play("L_Hchord_Ab4")
		ps_play("Piano_C4")
		ps_play("Piano_E4")
		ps_play("Piano_Ab4")
		ps_play("Tambourine")
	elseif music_count == (beats_per_measure*4 + 3) * ticks_per_beat then

	elseif music_count == (beats_per_measure*5 + 0) * ticks_per_beat then
		ps_play("L_Hchord_C5")
		ps_play("Piano_C2")
		ps_play("Triangle")
	elseif music_count == (beats_per_measure*5 + 1) * ticks_per_beat then
		ps_play("Piano_C2")
	elseif music_count == (beats_per_measure*5 + 2) * ticks_per_beat then
		ps_play("Tambourine")
	elseif music_count == (beats_per_measure*5 + 3) * ticks_per_beat then

	elseif music_count == (beats_per_measure*6 + 0) * ticks_per_beat then
		ps_play("Piano_C2")
		ps_play("Drum_Bass")
	elseif music_count == (beats_per_measure*6 + 1) * ticks_per_beat then
		ps_play("Piano_C2")
	elseif music_count == (beats_per_measure*6 + 2) * ticks_per_beat then
		ps_play("Tambourine")
	elseif music_count == (beats_per_measure*6 + 3) * ticks_per_beat then

	elseif music_count == (beats_per_measure*7 + 0) * ticks_per_beat then
		ps_play("Piano_C2")
	elseif music_count == (beats_per_measure*7 + 1) * ticks_per_beat then
		ps_play("Piano_C2")
	elseif music_count == (beats_per_measure*7 + 2) * ticks_per_beat then
		ps_play("Tambourine")
	elseif music_count == (beats_per_measure*7 + 3) * ticks_per_beat then

		first_time = false
	end

	--Increment the number of ticks that have happened
	music_count = music_count + 1
end
