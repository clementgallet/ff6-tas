memory.usememorydomain("CARTROM")

aiming_bytes = {0x0000, 0x0001, 0x0002, 0x0003, 0x0004, 0x0021, 0x0029, 0x0041, 0x0043, 0x0061, 0x0069, 0x006A, 0x006E}

for i = 1, 13 do -- aiming byte
  for j = 0, 255 do -- spell availability
    monster_id = aiming_bytes[i] * 256 + j
	monster_id = (monster_id * 5) % 0x10000 -- get monster offset, keep it inside two bytes
	monster_size_template = memory.readbyte(0x127004 + monster_id)
	monster_color_depth = bit.rshift(memory.readbyte(0x127002 + monster_id), 7) -- 1: 16-bit, 0: 8-bit
	if bit.check(memory.readbyte(0x127002 + monster_id), 6) then
	  monster_size_template = monster_size_template + 0x0100
	end
	if monster_color_depth ~= 0 then
	  first_tile = memory.readbyte(0x12AC24 + monster_size_template * 32)
	else
	  first_tile = memory.readbyte(0x12A824 + monster_size_template * 8)
	end
	if first_tile == 0 then
      console.writeline(string.format("Template %d-%X: (%X,%X)",monster_color_depth, monster_size_template, aiming_bytes[i], j))
	end
  end
end