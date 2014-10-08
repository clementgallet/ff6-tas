-------------------------
-- Begin of configuration
-------------------------

MOLD_NUMBER = 12

DISPLAY_COMMANDS = true
DISPLAY_ITEMS = true
DISPLAY_MAGIC = true
DISPLAY_ENGULF = false
DISPLAY_WRITE = false

-------------------------
-- End of configuration
-------------------------

memory.usememorydomain("CARTROM")

min = function(a,b) if a < b then return a else return b end end
max = function(a,b) if a < b then return b else return a end end

tochar = function(i)
	if i < 0x80 then return ""
	elseif i < 0x9a then return string.char(string.byte("A")+i-0x80)
	elseif i < 0xb4 then return string.char(string.byte("a")+i-0x9a)
	elseif i < 0xbe then return string.char(string.byte("0")+i-0xb4)
	elseif i == 0xfe then return " "
	else return "" end
end

readsnesstring = function(from,maximum)
	local res = ""
	local tmp = memory.readbyte(from)
	local i = 0
	while tmp ~= 0xFF do
		if i == maximum then break end
		res = res .. tochar(tmp)
		from = from+1
		tmp = memory.readbyte(from)
		i = i+1
	end
	return res
end

getitemname = function(id)
	return readsnesstring(0x12b300+0xd*id+1,12)
end

getmagicname = function(id)
	if id < 0x36 then -- magic
	  return readsnesstring(0x26F567+7*id, 7)
	end
	if id < 0x51 then -- esper
	  id = id - 0x36
	  return readsnesstring(0x26F6E1+8*id, 8)
	end
	if id < 0x55 then -- skean
	  id = id - 0x51
	  return readsnesstring(0x26F7B9+10*id, 10)
	end
	if id < 0x5D then -- sword tech, totally different place
	  id = id - 0x55
	  return readsnesstring(0x0F3C40+12*id, 12)
	end
	-- blitz, dances, slots, magitek, lores, enemy attacks, desperation attacks, miscellaneous attacks
    id = id - 0x5D
	return readsnesstring(0x26F831+10*id, 10)
end

getcommandname = function(id)
	if id < 32 then -- standard command
	  return readsnesstring(0x18CEA0+7*id, 7)
	end
	return "???" -- unknown command
end


-- list of available aiming bytes
aiming_bytes = {0x0001, 0x0003, 0x0004, 0x0021, 0x0029, 0x0041, 0x0061, 0x006A}

-- print_header

header = {"Spell setup"}

if DISPLAY_COMMANDS then
for c = 1,4 do
  for i = 1,4 do
    table.insert(header, string.format("Char %d command %d", c, i))
  end
end
end


if DISPLAY_ITEMS then
for i = 0,255 do
  table.insert(header, string.format("Item slot %d", i))
end
for i = 1,4 do
  table.insert(header, string.format("Char %d right arm", i))
end
for i = 1,4 do
  table.insert(header, string.format("Char %d left arm", i))
end
end

if DISPLAY_MAGIC then
for c = 1,4 do
  for i = 0,78 do
    table.insert(header, string.format("Char %d magic slot %d", c, i))
  end
end
end

if DISPLAY_ENGULF then
  table.insert(header, "$3A8A")
  table.insert(header, "$3A8D")
  table.insert(header, "$3EBC")
end

console.writeline(table.concat(header,";"))

-- -------------------------------------------------------------------------------------------------
-- The following commented code is to computed formation dependent memory. For now, we don't need it
-- -------------------------------------------------------------------------------------------------


-- for fi = 0, 575 do -- formation index

-- char* formation_array; -- $CF6200

  -- formation_offset = fi * 0xF;
  -- mould_index = bit.rshift(memory.readbyte(0x0F6200 + formation_offset), 4) -- $2000
  -- enemy_presence = bit.band(memory.readbyte(0x0F6201 + formation_offset), 0x3F) -- $61AA, xx654321
  -- enemy_id = memory.readbyte(0x0F6202 + formation_offset) -- not true id, will add the boss flag later
  -- boss_flags = memory.readbyte(0x0F620E + formation_offset)
  
  -- Get mould info to fetch maximum sprite width and height
  -- mould_info_pointer =  memory.read_u16_le(0x02D01A + 2 * mould_index)
  
  
  -- for i = 0,5 do
    -- if (bit.check(enemy_presence, i)) then
	  -- if (bit.check(boss_flags, i)) then
	    -- enemy_id = enemy_id + 0x100
      -- end
	  
      -- mould_slot_info_pointer = mould_info_pointer + i * 4 + 2
	  -- maximum_width = memory.readbyte(0x120002 + mould_slot_info_pointer) -- $8256
	  -- maximum_height = memory.readbyte(0x120003 + mould_slot_info_pointer) -- $8257

      -- monster_offset = bit.band((monster_id * 5),0xFFFF) -- get monster offset, keep it inside two bytes
      -- monster_stencil_bit = bit.check(memory.readbyte(0x127002 + monster_offset), 6)
	  -- monster_size_template = memory.readbyte(0x127004 + monster_offset) -- $81AA

      -- if monster_stencil_bit ~= 0 then
	    -- temp_tiles_array = memory.readbyterange(0x12AC24 + monster_size_template * 32, 0x20)
	  -- else
	    -- temp_tiles_array = memory.readbyterange(0x12A824 + monster_size_template * 8, 0x20)
	  -- end

	  -- tiles_array = {}
	  
	  -- i = 1
      -- for u, v in ipairs(first_tile_array) do
	    -- if monster_stencil_bit then
          -- tiles_array[i] = v
          -- i = i + 1
	    -- else
          -- tiles_array[i] = v
          -- tiles_array[i+1] = 0
	      -- i = i + 2
	    -- end
	  -- end
	  
	  -- get the OR of every other element in tiles_array
	  -- or_bits = 0
	  -- sprite_height = 0
	  -- for i = 0,0xF do
	    -- if (tiles_array[2*i] == 0) and (tiles_array[2*i+1] == 0) then
		  -- break
		-- end
		-- or_bits = bit.bor(or_bits, bit.lshift(tiles_array[2*i],8) + tiles_array[2*i+1])
		-- sprite_height = sprite_height + 2
	  -- end

	  -- for i = 0,0xF do
        -- if bit.check(or_bits, 0xF-i) then
		  -- sprite_width = i
		-- end
      -- end

	  -- sprite_width = min(sprite_width, maximum_width) -- $8252
	  -- sprite_height = min(sprite_height, maximum_height) -- $8253
	  
	  -- TBC...
	-- end
	
-- -------------------------------------------------------------------------------------------------
-- End of formation dependent computations
-- -------------------------------------------------------------------------------------------------


  ---------------------------------------------------------------------------
  -- Function C1/3E72: Fill the sprite offset ($8257+) for a specific mold
  ---------------------------------------------------------------------------

  mold_shifting = {} -- $8259
  
  -- zeroing the array
  for i = 0,0x197 do
    mold_shifting[i] = 0
  end

  mold_offset = 0xC * MOLD_NUMBER -- $26
  mold_pointer = memory.read_u16_le(0x02C4A4 + mold_offset); -- $10-$12

  for enemy_slot = 0,5 do -- 6 - $16
    grid_i = 0
    hor_offset = memory.readbyte(0x020000 + mold_pointer); -- $18 = starting horizontal grid position * 32 of this mold slot
    vert_offset = memory.readbyte(0x020001 + mold_pointer); -- $19 = starting vertical grid position * 32
    mold_pointer = mold_pointer + 2;
	grid_pos = memory.readbyte(0x020000 + mold_pointer)-- load the 0-15 grid square of this subsprite record, or an 0xFF null terminator
	while grid_pos ~= 0xFF do
	  mold_shifting[enemy_slot*0x44+grid_i]   = bit.band((memory.readbyte(0x02B9E7+4*grid_pos) - hor_offset), 0xFF) -- I fear subtractions :(
	  mold_shifting[enemy_slot*0x44+grid_i+1] = bit.band((memory.readbyte(0x02B9E8+4*grid_pos) - vert_offset), 0xFF)
	  mold_shifting[enemy_slot*0x44+grid_i+2] =  memory.readbyte(0x02B9E9+4*grid_pos)
	  mold_shifting[enemy_slot*0x44+grid_i+3] =  memory.readbyte(0x02B9EA+4*grid_pos)
	  mold_pointer = mold_pointer + 1 -- go to next grid square
      grid_pos = memory.readbyte(0x020000 + mold_pointer)
	  grid_i = grid_i + 4
	end
	mold_shifting[enemy_slot*0x44+grid_i] = 0xFF -- Store our null terminator
    mold_pointer = mold_pointer + 1 -- go to next grid square
  end
  
--  console.writeline(mold_shifting)

 for ai = 1, 8 do -- aiming byte
   for sa = 0, 255 do -- spell availability
    
    monster_id = aiming_bytes[ai] * 256 + sa
	-- console.writeline(monster_id)
	monster_offset = bit.band((monster_id * 5),0xFFFF) -- get monster offset, keep it inside two bytes
	
	
	
	
	
	---------------------------------------------------------------------------
	-- Function C1/24F5: Get the monster sprite informations
	---------------------------------------------------------------------------
	
	
	formation_pointer = memory.read_u16_le(0x02D01A + 0x06 * 2) -- pointer to monster formation size templates ($12)
	formation_shift = memory.read_u16_le(0x020000 + formation_pointer) -- indicates how to shift enemies for the display
	screen_address = formation_shift + 0xAE3F -- address to write the monster sprite ($61-$62)
	formation_width = memory.readbyte(0x020002 + formation_pointer) -- width/8 of formation ($8256)
	formation_height = memory.readbyte(0x020003 + formation_pointer) -- height/8 of formation ($8257)
	
	monster_sprite_pointer = 0x297000 + bit.lshift(bit.band(memory.read_u16_le(0x127000 + monster_offset), 0x7FFF), 3) -- pointer to monster sprite ($64-$66)
	monster_size_template = memory.readbyte(0x127004 + monster_offset) -- $81AA
	monster_color_depth = bit.check(memory.readbyte(0x127001 + monster_offset), 7) -- color depth. 1: 16-bit, 0: 8-bit
	monster_stencil_bit = bit.check(memory.readbyte(0x127002 + monster_offset), 7) -- 1: large bitmap, 0: normal bitmap
	monster_high_id = bit.check(memory.readbyte(0x127002 + monster_offset), 6)
	if monster_high_id then
	  monster_size_template = monster_size_template + 0x0100
	end

	
	
	
	
	---------------------------------------------------------------------------
	-- Function C1/215F: gather sprite flag
	---------------------------------------------------------------------------
	
	
	-- Read the first byte of the monster sprite disposition
	if monster_stencil_bit then
	  first_tile = memory.read_u16_le(0x12AC24 + monster_size_template * 32)
	else
	  first_tile = memory.read_u16_le(0x12A824 + monster_size_template * 8)
	end
	
	-- Check if glitch will happen
	if first_tile == 0 then
	
    -- Spell setup will provoke a glitch!

	tiles_array = {}
	if monster_stencil_bit then
	  for i = 0,0x1F do
	    tiles_array[i] = memory.readbyte(0x12AC24 + monster_size_template * 32 + i)
	  end
	else
	  for i = 0,0x0F do
	    tiles_array[2*i] = memory.readbyte(0x12A824 + monster_size_template * 8 + i)
	    tiles_array[2*i+1] = 0
	  end
	end
	
	-- Compute the sprite width
	-- sprite_width = min(bit.band(formation_pointer+3,0xFF),formation_width) -- $8251, using the uninitialised $12 that was previously used in C1/254E
	sprite_width = formation_width -- $8251, using the uninitialised $12 that was previously used in C1/254E
	  
	  
	  
	---------------------------------------------------------------------------
	-- Function C1/22A5: copy sprites from ROM to RAM
	---------------------------------------------------------------------------

	loop_nb = 0
	write_log = {} -- log all the writes from ROM to RAM
	write_log[loop_nb] = {} -- first loop
	
	bit_pos = 0 -- $824D
	sprite_flag_index = 0 -- $824E
	offset_rom = 0 -- $8254-$8255
	offset_ram = 0 -- Y
	
	for cur_height = 0,0xFF do -- $8253
	  for cur_width = 0,(sprite_width-1) do -- $8252

		---------------------------------------------------------------------------
		-- Function C1/2209: load the sprite flag
		---------------------------------------------------------------------------

	    if (bit_pos == 0) then
		  bit_pos = 0x10
		  
		  -- Choose where to pick the sprite flag ($824F-$8250)
		  if sprite_flag_index < 0x20 then -- choose from $822D - $824C
		    sprite_flag = tiles_array[sprite_flag_index] * 256 + tiles_array[sprite_flag_index+1]
		  end
		  if sprite_flag_index == 0x20 then -- choose $824D and $824E
			sprite_flag = bit_pos * 256 + sprite_flag_index
		  end
		  if sprite_flag_index == 0x22 then -- choose $824F and $8250
			sprite_flag = 0
		  end
		  if sprite_flag_index == 0x24 then -- choose $8251 and $8252
			sprite_flag = sprite_width * 256 + (sprite_width - cur_width)
		  end
		  if sprite_flag_index == 0x26 then -- choose $8253 and $8254
			sprite_flag = (0x100 - cur_height) * 256 + bit.band(offset_rom, 0xFF)
		  end
		  if sprite_flag_index == 0x28 then -- choose $8255 and $8256
			sprite_flag = bit.band(offset_rom, 0xFF00) + formation_width
		  end
		  if sprite_flag_index == 0x2A then -- choose $8257 and $8258
			sprite_flag = formation_height * 256 + 0x06
		  end
		  if sprite_flag_index > 0x2A then -- choose from $8259+
			sprite_flag = mold_shifting[sprite_flag_index-0x2C] * 256 + mold_shifting[sprite_flag_index-0x2B]
		  end
		  sprite_flag_index = bit.band(sprite_flag_index + 2, 0xFF) -- 8-bit integer
		end
		bit_pos = bit_pos - 1

		if bit.check(sprite_flag, bit_pos) then
		
		  ---------------------------------------------------------------------------
		  -- Function C1/2233: copy a single sprite from ROM to RAM
		  ---------------------------------------------------------------------------

		  if monster_color_depth then
			  -- console.writeline(string.format("%s;%s", bizstring.hex(bit.band(screen_address+offset_ram, 0xFFFF)),bizstring.hex(monster_sprite_pointer+offset_rom)))
			for n = 0, 7 do
			  write_log[loop_nb][bit.band(screen_address+offset_ram+2*n, 0xFFFF)] = memory.readbyte(monster_sprite_pointer+offset_rom+2*n)
			  write_log[loop_nb][bit.band(screen_address+offset_ram+2*n+1, 0xFFFF)] = memory.readbyte(monster_sprite_pointer+offset_rom+2*n+1)
			end
			for n = 0, 7 do
			  write_log[loop_nb][bit.band(screen_address+offset_ram+0x10+2*n, 0xFFFF)] = memory.readbyte(monster_sprite_pointer+offset_rom+0x10+n)
			  write_log[loop_nb][bit.band(screen_address+offset_ram+0x11+2*n, 0xFFFF)] = 0
			end
		    offset_rom = bit.band(offset_rom + 0x18, 0xFFFF)
		  else
			-- console.writeline(string.format("%s;%s", bizstring.hex(bit.band(screen_address+offset_ram, 0xFFFF)),bizstring.hex(monster_sprite_pointer+offset_rom)))
			for n = 0, 15 do
			  write_log[loop_nb][bit.band(screen_address+offset_ram+2*n, 0xFFFF)] = memory.readbyte(monster_sprite_pointer+offset_rom+2*n)
			  write_log[loop_nb][bit.band(screen_address+offset_ram+2*n+1, 0xFFFF)] = memory.readbyte(monster_sprite_pointer+offset_rom+2*n+1)
			end
		    offset_rom = bit.band(offset_rom + 0x20, 0xFFFF)
		  end
		end
		
		offset_ram = bit.band(offset_ram + 0x20, 0xFFFF)
		  
		  
	  end -- end for cur_width
	  
	  bit_pos = 0
	  offset_ram = 0
	  past_screen_address = screen_address
	  screen_address = bit.band(screen_address + 0x0200, 0xFFFF)
	  if screen_address < past_screen_address then
		loop_nb = loop_nb + 1
		write_log[loop_nb] = {}
	  end
	end -- end for cur_height
	
	
	-- console.writeline(write_log)
	
    ---------------------------------------------------------------------------
	-- Extract and format relevent writes from the write log
	---------------------------------------------------------------------------
	
	string_line = {bizstring.hex(monster_id)}
	
	-- Function C2/532C fills battle commands from character commands and optional modifications by relics, etc. Starts at $202E and takes 3 bytes per slot: id, availability and aiming
	if DISPLAY_COMMANDS then
	for command_slot = 0,15 do
	  command_offset = 0x202E + 3 * command_slot
	  cell_string = {}
	  for loop = 0,loop_nb do
	  if write_log[loop][command_offset] ~= nil or write_log[loop][command_offset+2] ~= nil then
	    if write_log[loop][command_offset] ~= nil then
	      command_name = getcommandname(write_log[loop][command_offset]) .. "(" .. write_log[loop][command_offset]
		else
	      command_name = "("
		end
	    if write_log[loop][command_offset+1] ~= nil then
	      command_availability = bizstring.hex(write_log[loop][command_offset+1])
		else
	      command_availability = ""
		end
	    if write_log[loop][command_offset+2] ~= nil then
	      command_aiming = bizstring.hex(write_log[loop][command_offset+2])
		else
	      command_aiming = ""
		end
		table.insert(cell_string, string.format("%s/%s/%s)", command_name, command_availability, command_aiming))
	  else
		table.insert(cell_string, "")
	  end
	  end
	  table.insert(string_line, table.concat(cell_string,"-"))
	end
	end
	  
	-- Function C2/546E construct in-battle Item menu, equipment sub-menus, and possessed Tools bitfield, based off of equipped and possessed items.
	if DISPLAY_ITEMS then
	for item_slot = 0,263 do
	  item_offset = item_slot*5+0x2686
  	  cell_string = {}
	  for loop = 0,loop_nb do

      if write_log[loop][item_offset] ~= nil or write_log[loop][item_offset+4] ~= nil then
	    if write_log[loop][item_offset] ~= nil then -- item id
		  item_id = getitemname(write_log[loop][item_offset])
		else
		  item_id = ""
		end
	    if write_log[loop][item_offset+1] ~= nil then -- item flags
		  item_flags = bizstring.hex(write_log[loop][item_offset+1])
		else
		  item_flags = ""
		end
	    if write_log[loop][item_offset+2] ~= nil then -- item targeting
		  item_targeting = bizstring.hex(write_log[loop][item_offset+2])
		else
		  item_targeting = ""
		end
	    if write_log[loop][item_offset+3] ~= nil then -- item quantity
		  item_quantity = string.format(" * %d",write_log[loop][item_offset+3])
		else
		  item_quantity = ""
		end
	    if write_log[loop][item_offset+4] ~= nil then -- item targeting
		  item_equipability = bizstring.hex(write_log[loop][item_offset+4])
		else
		  item_equipability = ""
		end
		table.insert(cell_string, string.format("%s%s (%s/%s/%s)", item_id, item_quantity, item_flags, item_targeting, item_equipability))
	  else
		table.insert(cell_string, "") -- No item
	  end
	  end
	  table.insert(string_line, table.concat(cell_string,"-"))
	end
	end
	
	
	-- Magic and Lore list is stored in $208E, $21CA, $2306 and $2442 for each character
	if DISPLAY_MAGIC then
	for magic_slot = 0,(79*4-1) do
	  magic_offset = 0x208E + 4 * magic_slot
  	  cell_string = {}
	  for loop = 0,loop_nb do
	  if write_log[loop][magic_offset] ~= nil then -- magic id
	  
	    magic_name = getmagicname(write_log[loop][magic_offset])
	    if write_log[loop][magic_offset+1] == nil then -- magic availability
		  magic_availability = ""
		else
		  magic_availability = bizstring.hex(write_log[loop][magic_offset+1])
		end
		
	    if write_log[loop][magic_offset+2] == nil then -- magic aiming
		  magic_aiming = ""
		else
		  magic_aiming = bizstring.hex(write_log[loop][magic_offset+2])
		end
		
	    if write_log[loop][magic_offset+3] == nil then -- magic cost
		  magic_cost = ""
		else
		  magic_cost = bizstring.hex(write_log[loop][magic_offset+3])
		end
		
	    table.insert(cell_string, string.format("%s (%s/%s/%s)", magic_name, magic_availability, magic_aiming, magic_cost))
	  else
	    table.insert(cell_string, "")
	  end
	  end
  	  table.insert(string_line, table.concat(cell_string,"-"))
	end
	end
	
	-- Engulf variables include $3A8A (which characters have been engulfed), $3A8D (active characters at the beginning of the battle) and $3EBC (bit 7 is set if all party engulfed).
	engulf_addresses = {0x3A8A, 0x3A8D, 0x3EBC}
	if DISPLAY_ENGULF then
	  for i = 1,3 do
	    if write_log[engulf_addresses[i]] ~= nil then
	      table.insert(string_line, bizstring.hex(write_log[engulf_addresses[i]]))
		else
	      table.insert(string_line, "")
		end
	  end
	end
	
	-- Display all addresses that have been written to.
	write_addresses = {}
	if DISPLAY_WRITE then
	for address = 0,0xFFFF do
      if write_log[address] ~= nil then
		table.insert(write_addresses, bizstring.hex(address))
	  end
	end
	console.writeline(table.concat(write_addresses,";"))
	return
	end

	
	console.writeline(table.concat(string_line,";"))
	
	end -- end if setup is working

   end -- end for spell availability
 end -- end for aiming byte
