memory.usememorydomain("CARTROM")

min = function(a,b) if a < b then return a else return b end end
max = function(a,b) if a < b then return b else return a end end

bitcount = function(x) -- compute the sum of bits in x
	c = 0
	for i = 0,7 do
		if bit.check(x,i) then
			c = c + 1
		end
	end
	return i
end

bitcountarray = function(t) -- compute the sump of bits in all elements of array t
	c = 0
    for i, v in ipairs(first_tile_array) do
		c = c + bitcount(v)
	end
	return c
end

-- list of available aiming bytes
aiming_bytes = {0x0000, 0x0001, 0x0002, 0x0003, 0x0004, 0x0021, 0x0029, 0x0041, 0x0043, 0x0061, 0x0069, 0x006A, 0x006E}


for fi = 0, 575 do -- formation index

char* formation_array; -- $CF6200

  formation_offset = fi * 0xF;
  mould_index = bit.rshift(memory.readbyte(0x0F6200 + formation_offset), 4) -- $2000
  enemy_presence = bit.band(memory.readbyte(0x0F6201 + formation_offset), 0x3F) -- $61AA, xx654321
  enemy_id = memory.readbyte(0x0F6202 + formation_offset) -- not true id, will add the boss flag later
  boss_flags = memory.readbyte(0x0F620E + formation_offset)
  
  -- Get mould info to fetch maximum sprite width and height
  mould_info_pointer =  memory.read_u16_le(0x02D01A + 2 * mould_index)
  
  
  for i = 0,5 do
    if (bit.check(enemy_presence, i)) then
	  if (bit.check(boss_flags, i)) then
	    enemy_id = enemy_id + 0x100
      end
	  
      mould_slot_info_pointer = mould_info_pointer + i * 4 + 2
	  maximum_width = memory.readbyte(0x120002 + mould_slot_info_pointer) -- $8256
	  maximum_height = memory.readbyte(0x120003 + mould_slot_info_pointer) -- $8257

      monster_offset = bit.band((monster_id * 5),0xFFFF) -- get monster offset, keep it inside two bytes
      monster_stencil_bit = bit.check(memory.readbyte(0x127002 + monster_offset), 6)
	  monster_size_template = memory.readbyte(0x127004 + monster_offset) -- $81AA

      if monster_stencil_bit ~= 0 then
	    temp_tiles_array = memory.readbyterange(0x12AC24 + monster_size_template * 32, 0x20)
	  else
	    temp_tiles_array = memory.readbyterange(0x12A824 + monster_size_template * 8, 0x20)
	  end

	  tiles_array = {}
	  
	  i = 1
      for u, v in ipairs(first_tile_array) do
	    if monster_stencil_bit then
          tiles_array[i] = v
          i = i + 1
	    else
          tiles_array[i] = v
          tiles_array[i+1] = 0
	      i = i + 2
	    end
	  end
	  
	  -- get the OR of every other element in tiles_array
	  or_bits = 0
	  sprite_height = 0
	  for i = 0,0xF do
	    if (tiles_array[2*i] == 0) and (tiles_array[2*i+1] == 0) then
		  break
		end
		or_bits = bit.bor(or_bits, bit.lshift(tiles_array[2*i],8) + tiles_array[2*i+1])
		sprite_height = sprite_height + 2
	  end

	  for i = 0,0xF do
        if bit.check(or_bits, 0xF-i) then
		  sprite_width = i
		end
      end

	  sprite_width = min(sprite_width, maximum_width) -- $8252
	  sprite_height = min(sprite_height, maximum_height) -- $8253
	  
	  -- TBC...
	end
  end	


for ai = 1, 13 do -- aiming byte
  for sa = 0, 255 do -- spell availability
    
    monster_id = aiming_bytes[ai] * 256 + sa
	monster_offset = bit.band((monster_id * 5),0xFFFF) -- get monster offset, keep it inside two bytes
	
	-- Get the monster sprite informations
	formation_pointer = memory.read_u16_le(0x12D01A + monster_offset) -- pointer to monster formation size templates ($12)
	formation_shift = memory.read_u16_le(0x120000 + formation_pointer) -- indicates how to shift enemies for the display
	screen_address = formation_shift + 0xAE3F -- address to write the monster sprite ($61-$62)
	formation_width = memory.readbyte(0x120002 + formation_pointer) -- width/8 of formation ($8256)
	formation_height = memory.readbyte(0x120003 + formation_pointer) -- height/8 of formation ($8257)
	
	monster_sprite_pointer = 0xE97000 + bit.lshift(bit.band(memory.readbyte(0x127000 + monster_offset), 0x7FFF), 3) -- pointer to monster sprite ($64-$66)
	monster_size_template = memory.readbyte(0x127004 + monster_offset) -- $81AA
	monster_color_depth = bit.rshift(memory.readbyte(0x127002 + monster_offset), 7) -- color depth. 1: 16-bit, 0: 8-bit
	monster_stencil_bit = bit.check(memory.readbyte(0x127002 + monster_offset), 6)
	if monster_stencil_bit then
	  monster_size_template = monster_size_template + 0x0100
	end
	
	-- Read the first byte of the monster sprite disposition
	if monster_stencil_bit then
	  first_tile = memory.read_u16_le(0x12AC24 + monster_size_template * 32)
	else
	  first_tile = memory.read_u16_le(0x12A824 + monster_size_template * 8)
	end
	
	-- Check if glitch will happen
	if first_tile != 0 then
	  break
	end
	
    -- Spell setup will provoke a glitch!

	-- Building the table that determines if a copy has to be done or not.
	copy_bit_list = {}

	if monster_stencil_bit then
	  first_tile_array = memory.readbyterange(0x12AC24 + monster_size_template * 32, 0x20)
	else
	  first_tile_array = memory.readbyterange(0x12A824 + monster_size_template * 8, 0x10)
	end

	-- I don't like how Bizhawk is indexing tables
	i = 1
    for u, v in ipairs(first_tile_array) do
	  if monster_stencil_bit then
        copy_bit_list[i] = v
        i = i + 1
	  else
        copy_bit_list[i] = v
        copy_bit_list[i+1] = 0
	    i = i + 2
	  end
	end
	
	copy_bit_list[0x21] = 0x10 -- $824D
	copy_bit_list[0x22] = 0x20 -- $824E
	copy_bit_list[0x23] = 0x00 -- $824F
	copy_bit_list[0x24] = 0x00 -- $8250
	copy_bit_list[0x25] = formation_width -- $8251
	copy_bit_list[0x26] = formation_width -- $8252
	
	current_bitcount = bitcountarray(copy_bit_list)
	
	copy_bit_list[0x27] = 0xED -- $8253, always same value
	if monster_color_depth then
		copy_bit_list[0x28] = bit.band(current_bitcount * 0x18, 0xFF) -- low byte of bit count of the current table
	else
		copy_bit_list[0x28] = bit.band(current_bitcount * 0x20, 0xFF) -- low byte of bit count of the current table
	end
	
	current_bitcount = bitcountarray(copy_bit_list)
	
	if monster_color_depth then
		copy_bit_list[0x29] = bit.rshift(bit.band(current_bitcount * 0x18, 0xFF00), 8) -- depends on the bit count of the current table
	else
		copy_bit_list[0x29] = bit.rshift(bit.band(current_bitcount * 0x20, 0xFF00), 8) -- depends on the bit count of the current table
	end
	
	copy_bit_list[0x2A] = formation_width -- $8256
	copy_bit_list[0x2B] = formation_height -- $8257
	copy_bit_list[0x2C] = 0x06 -- $8258, temp variable set in C1/257C, should always be 0x06
	
	nb_loops = 256 * formation_width -- number of copy iterations
	remaining_bytes = math.floor(nb_loops / 8) - 0x2C -- number of remaining bytes needed to be read from the mold arrays starting $8259
	mold_array = mainmemory.readbyterange(0x8259, remaining_bytes) -- part of the mold arrays taken as bit sprite info

	-- adding to the whole array. I know it looks bad.
	i = 1
    for u, v in ipairs(mold_array) do
      copy_bit_list[0x2C + i] = v
	  i = i + 1
	end

    -- TBC...
	
      -- writes_list = {} -- Store the list of all writes
	  -- offset_from = 
	  -- offset_to = 0

	
	  -- for i, v in ipairs(first_tile_array) do
	    -- for i = 0, 7 do
		
		  -- if (bit.check(v,7-i)) then
		  
        -- rangestr = rangestr .. string.format("%02X", v) .. " "
      -- console.writeline(string.format("Template %d-%X: (%X,%X)",monster_color_depth, monster_size_template, aiming_bytes[i], j))
  end
end