-------------------------
-- Begin of configuration
-------------------------

MOLD_NUMBER = 0 -- number between 0 and 12.

DISPLAY_COMMANDS = false
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
  local charArray = {
  "","","","","","","","","","","","","","","","", -- 0x
  "","","","","","","","","","","","","","","","", -- 1x
  "バ","ば","ビ","び","ブ","ぶ","ベ","べ","ボ","ぼ","ガ","が","ギ","ぎ","グ","ぐ", -- 2x
  "ゲ","げ","ゴ","ご","ザ","ざ","ジ","じ","ズ","ず","ゼ","ぜ","ゾ","ぞ","ダ","だ", -- 3x
  "ヂ","ぢ","ヅ","づ","デ","で","ド","ど","ヴ","パ","ぱ","ピ","ぴ","プ","ぷ","ペ", -- 4x
  "ぺ","ポ","ぽ","0","1","2","3","4","5","6","7","8","9","","","", -- 5x
  "ハ","は","ヒ","ひ","フ","ふ","ヘ","へ","ホ","ほ","カ","か","キ","き","ク","く", -- 6x
  "ケ","け","コ","こ","サ","さ","シ","し","ス","す","セ","せ","ソ","そ","タ","た", -- 7x
  "チ","ち","ツ","つ","テ","て","ト","と","ウ","う","ア","あ","イ","い","エ","え", -- 8x
  "オ","お","ナ","な","ニ","に","ヌ","ぬ","ネ","ね","ノ","の","マ","ま","ミ","み", -- 9x
  "ム","む","メ","め","モ","も","ラ","ら","リ","り","ル","る","レ","れ","ロ","ろ", -- Ax
  "ヤ","や","ユ","ゆ","ヨ","よ","ワ","わ","ン","ん","ヲ","を","ッ","っ","ャ","ゃ", -- Bx
  "ュ","ゅ","ョ","ょ","ァ","ー","ィ","..","ゥ","!","ェ","?","ォ","","/",":", -- Cx
  "「","」","","+","","","","","","","","","","","","", -- Dx
  "","","","","","","","","","","","","","","","", -- Ex
  "","","","","","","","","","","","","",""," ",""  -- Fx
  }
  return charArray[i]
end

readsnesstring = function(from,maximum)
	local res = ""
	local tmp = memory.readbyte(from)
	local i = 0
	while tmp ~= 0xFF do
		if i == maximum then break end
    if (tochar(tmp)) then
      res = res .. tochar(tmp)
    end
		from = from+1
		tmp = memory.readbyte(from)
		i = i+1
	end
	return res
end

getitemname = function(id)
	return readsnesstring(0x2D7776+8*id+1,8)
end

getmagicname = function(id)
	if id < 0x36 then -- magic
	  return readsnesstring(0x2D7400+5*id, 5)
	end
  id = id - 0x36
  return readsnesstring(0x2D750E+8*id, 8)
  -- Swdtechs use kanjis, so won't be printed
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

io.output("log.txt")
io.write(table.concat(header,";"), "\n")

  ---------------------------------------------------------------------------
  -- Function C1/3E4A: Fill the sprite offset ($8257+) for a specific mold
  ---------------------------------------------------------------------------

  mold_shifting = {} -- $8229
  
  -- zeroing the array
  for i = 0,0x197 do
    mold_shifting[i] = 0
  end

  mold_offset = 0xC * MOLD_NUMBER -- $26
  mold_pointer = memory.read_u16_le(0x02C446 + mold_offset); -- $10-$12

  for enemy_slot = 0,5 do -- 6 - $16
    grid_i = 0
    hor_offset = memory.readbyte(0x020000 + mold_pointer); -- $18 = starting horizontal grid position * 32 of this mold slot
    vert_offset = memory.readbyte(0x020001 + mold_pointer); -- $19 = starting vertical grid position * 32
    mold_pointer = mold_pointer + 2;
	grid_pos = memory.readbyte(0x020000 + mold_pointer)-- load the 0-15 grid square of this subsprite record, or an 0xFF null terminator
	while grid_pos ~= 0xFF do
	  mold_shifting[enemy_slot*0x44+grid_i]   = bit.band((memory.readbyte(0x02B987+4*grid_pos) - hor_offset), 0xFF) -- I fear subtractions :(
	  mold_shifting[enemy_slot*0x44+grid_i+1] = bit.band((memory.readbyte(0x02B988+4*grid_pos) - vert_offset), 0xFF)
	  mold_shifting[enemy_slot*0x44+grid_i+2] =  memory.readbyte(0x02B989+4*grid_pos)
	  mold_shifting[enemy_slot*0x44+grid_i+3] =  memory.readbyte(0x02B98A+4*grid_pos)
	  mold_pointer = mold_pointer + 1 -- go to next grid square
    grid_pos = memory.readbyte(0x020000 + mold_pointer)
	  grid_i = grid_i + 4
	end
	mold_shifting[enemy_slot*0x44+grid_i] = 0xFF -- Store our null terminator
    mold_pointer = mold_pointer + 1 -- go to next grid square
  end
  
 for ai = 1, 8 do -- aiming byte
   for sa = 0, 255 do -- spell availability
    
    monster_id = aiming_bytes[ai] * 256 + sa
	monster_offset = bit.band((monster_id * 5),0xFFFF) -- get monster offset, keep it inside two bytes
	
	
	---------------------------------------------------------------------------
	-- Function C1/24CD: Get the monster sprite informations
	---------------------------------------------------------------------------
	
	
	formation_pointer = memory.read_u16_le(0x02CFBC + 0x06 * 2) -- pointer to monster formation size templates ($12)
	formation_shift = memory.read_u16_le(0x020000 + formation_pointer) -- indicates how to shift enemies for the display
	screen_address = formation_shift + 0xAE0F -- address to write the monster sprite ($61-$62)
	formation_width = memory.readbyte(0x020002 + formation_pointer) -- width/8 of formation ($8226)
	formation_height = memory.readbyte(0x020003 + formation_pointer) -- height/8 of formation ($8227)
	
	monster_sprite_pointer = 0x297000 + bit.lshift(bit.band(memory.read_u16_le(0x127000 + monster_offset), 0x7FFF), 3) -- pointer to monster sprite ($64-$66)
	monster_size_template = memory.readbyte(0x127004 + monster_offset) -- $81AA
	monster_color_depth = bit.check(memory.readbyte(0x127001 + monster_offset), 7) -- color depth. 1: 16-bit, 0: 8-bit
	monster_stencil_bit = bit.check(memory.readbyte(0x127002 + monster_offset), 7) -- 1: large bitmap, 0: normal bitmap
	monster_high_id = bit.check(memory.readbyte(0x127002 + monster_offset), 6)
	if monster_high_id then
	  monster_size_template = monster_size_template + 0x0100
	end

	
	
	---------------------------------------------------------------------------
	-- Function C1/2137: gather sprite flag
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
	sprite_width = formation_width -- $8221, using the uninitialised $12 that was previously used in C1/254E
	  
	  
	  
	---------------------------------------------------------------------------
	-- Function C1/227D: copy sprites from ROM to RAM
	---------------------------------------------------------------------------

	loop_nb = 0
	write_log = {} -- log all the writes from ROM to RAM
	write_log[loop_nb] = {} -- first loop
	
	bit_pos = 0 -- $821D
	sprite_flag_index = 0 -- $821E
	offset_rom = 0 -- $8224-$8225
	offset_ram = 0 -- Y
	
	for cur_height = 0,0xFF do -- $8223
	  for cur_width = 0,(sprite_width-1) do -- $8222

		---------------------------------------------------------------------------
		-- Function C1/2209: load the sprite flag
		---------------------------------------------------------------------------

	    if (bit_pos == 0) then
		  bit_pos = 0x10
		  
		  -- Choose where to pick the sprite flag ($821F-$8220)
		  if sprite_flag_index < 0x20 then -- choose from $81FD - $821C
		    sprite_flag = tiles_array[sprite_flag_index] * 256 + tiles_array[sprite_flag_index+1]
		  end
		  if sprite_flag_index == 0x20 then -- choose $821D and $821E
			sprite_flag = bit_pos * 256 + sprite_flag_index
		  end
		  if sprite_flag_index == 0x22 then -- choose $821F and $8220
			sprite_flag = 0
		  end
		  if sprite_flag_index == 0x24 then -- choose $8221 and $8222
			sprite_flag = sprite_width * 256 + (sprite_width - cur_width)
		  end
		  if sprite_flag_index == 0x26 then -- choose $8223 and $8224
			sprite_flag = (0x100 - cur_height) * 256 + bit.band(offset_rom, 0xFF)
		  end
		  if sprite_flag_index == 0x28 then -- choose $8225 and $8226
			sprite_flag = bit.band(offset_rom, 0xFF00) + formation_width
		  end
		  if sprite_flag_index == 0x2A then -- choose $8227 and $8228
			sprite_flag = formation_height * 256 + 0x06
		  end
		  if sprite_flag_index > 0x2A then -- choose from $8229+
			sprite_flag = mold_shifting[sprite_flag_index-0x2C] * 256 + mold_shifting[sprite_flag_index-0x2B]
		  end
		  sprite_flag_index = bit.band(sprite_flag_index + 2, 0xFF) -- 8-bit integer
		end
		bit_pos = bit_pos - 1

		if bit.check(sprite_flag, bit_pos) then
		
		  ---------------------------------------------------------------------------
		  -- Function C1/220B: copy a single sprite from ROM to RAM
		  ---------------------------------------------------------------------------

		  if monster_color_depth then
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
		  item_id = bizstring.hex(write_log[loop][item_offset])
		else
		  item_id = ""
		end
	    if write_log[loop][item_offset] ~= nil then -- item name
		  item_name = getitemname(write_log[loop][item_offset])
		else
		  item_name = ""
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
		table.insert(cell_string, string.format("%s%s (%s/%s/%s/%s)", item_name, item_quantity, item_id, item_flags, item_targeting, item_equipability))
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
		
	    table.insert(cell_string, string.format("%s (%s/%s/%s/%s)", magic_name, bizstring.hex(write_log[loop][magic_offset]), magic_availability, magic_aiming, magic_cost))
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
	io.write(table.concat(write_addresses,";"), "\n")
	return
	end

	
	io.write(table.concat(string_line,";"), "\n")
	
	end -- end if setup is working

   end -- end for spell availability
 end -- end for aiming byte
