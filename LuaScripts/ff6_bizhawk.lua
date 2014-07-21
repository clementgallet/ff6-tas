-- Features:
-- 1. Encounter prediction: predicts steps until encounter, and what will be encountered.
--    Does not predict front/back/pincer/side/preemptive variants, not will it work properly
--    on the floating continent. (there is tentative support for this (which actually makes up
--    a good part of the code), but it is buggy, and only works well when one is on the world map,
--    and has 3 or 4 chars in party, so it is disabled by default)
-- 2. Outline treasure chests and show their contents and status (green = untaken, red = taken)
-- 3. Outline squares that trigger events. Blue = transition to new area, light blue = transition
--    to same area, very light blue = transition to map, yellow = unclassified event.
-- 4. In battle, hp and mp bars are displayed over the enemies, as well as their battle gauges.
--    Their level is also displayed. On gau's turns, a "?" is displayed by any monster whose
--    rage is not known. Additionally, the enemies' resistances etc. are displayed in a compact
--    but hopefully readable manner, as a set of 4 3x3 sqares of pixels, where each has the
--    following format:
--      fil   ; fire (red) ice (blue) lightning (yellow)
--      pwp   ; poison (green) wind (gray) holy (white)
--      ew    ; earth (brown) water (blue)
--    The order of the sqares is, from left to right, absorb, nullify, resist, weak.
-- 5. Extra information is displayed for the currently selected monster.
--    normally, only its drops and hp/mp are displayed, but if locke is selecting the
--    monster with the steal command, its steals are also listed. If relm is selecting
--    a monster with control or sketch, that information will also be indicated.
-- 6. While in the rage menu, information about what the selected rage does is
--    displayed. Only the attack part of the rage is displayed so far, since I haven't thought
--    of a compact way of displaying all the status information associated with a rage.


DISPLAY_RELM_INFO = false -- display sketch and control attacks
DISPLAY_LOCKE_INFO = false -- display common and rare steal when in steal menu
DISPLAY_GAU_INFO = false -- display unknown rages
DISPLAY_CRITICALS = true

-- End of user configuration --

require 'ff6_bizhawk_helper'

MODE_BATTLE = 0
MODE_CAVE = 1
MODE_MAP = 2
MODE_MENU = 3

-- to get the pixel distance from an encounter, we
-- need to fix an occational off-by-1 error for
-- count. this happens on the first frame when we reach
-- a whole square. we thus need to keep track of whether
-- the last position was whole or not
last_position_whole = true

function display_battle()
	local sel_side, sel_i = mainmemory.readbyte(0x7ace), mainmemory.readbyte(0x7acf)
	local sel_enemy, sel_party = mainmemory.readbyte(0x7b7e),mainmemory.readbyte(0x7b7d)
	local sel_multi = mainmemory.readbyte(0x7b7f)
	-- loop through present monsters
	for i = 0, 5 do
		-- a few shortcuts
		local j, k = 2*i, 2*(4+i)
		local state = mainmemory.read_u16_le(0x3aa0+k)
		if state ~= 0 and bit.check(state,15) ~= 1 then
		-- get coordinates (we should know the size of the monster too, but we don't)
		local x = mainmemory.readbyte(0x80c2+1+j)
		-- this size is really the x-offset of the pointing hand relative to the start
		-- of the sprite. For a normal attack, this works fine, but for monsters on the
		-- right hand side of the screen, this offset is 0, as the hand is on their left
		-- side. To do things properly, I should get this in a more direct fashion, but
		-- I can't be bothered
		local xsize = mainmemory.readbyte(0x807a+1+j)
		if xsize == 0 then xsize = 0x20 end
		local y = mainmemory.readbyte(0x80ce+1+j)
		-- other interesting information
		local id   = mainmemory.read_u16_le(0x3388+j)
		local xp   = mainmemory.read_u16_le(0x3d8c+j)
		local gold = mainmemory.read_u16_le(0x3da0+j)
		local hp   = mainmemory.read_u16_le(0x3bf4+k)
		local mp   = mainmemory.read_u16_le(0x3c08+k)
		local mhp  = mainmemory.read_u16_le(0x3c1c+k)
		local mmp  = mainmemory.read_u16_le(0x3c30+k)
		local level= mainmemory.readbyte(0x3b18+k)
		local speed= mainmemory.readbyte(0x3b19+k)
		local gauge= mainmemory.read_u16_le(0x3218+k)
		-- elements
		local absorb  =  mainmemory.readbyte(0x3bcc+k)
		local nullify =  mainmemory.readbyte(0x3bcd+k)
		local resist  =  mainmemory.readbyte(0x3be1+k)
		local weak    =  mainmemory.readbyte(0x3be0+k)
		local stealn  =  mainmemory.readbyte(0x3311+j)
		local stealr  =  mainmemory.readbyte(0x3310+j)
		local dropn   =  memory.readbyte(0x0f3000+4*id+3)
		local dropr   =  memory.readbyte(0x0f3000+4*id+2)

		local name = getmonstername(id)

		-- Print the gauges
		startgauge(x,y,xsize)
		drawgauge(mp, mmp, 0x7f0000ff)
		drawgauge(hp, mhp, 0x7f00ff00)
		drawgauge(gauge, 0x10000, 0x7fff0000)
		local by = gy
		gui.drawText(x-16, by-8, string.format("%2d",level))
		print_element(x, by-6, absorb)
		print_element(x+4, by-6, nullify)
		print_element(x+8, by-6, resist)
		print_element(x+12, by-6, weak)
		gui.drawText(x+18, by-8, ""..hp)

		local active_slot = mainmemory.readbyte(0x0201)
		local active_player = mainmemory.readbyte(0x3ed8+active_slot*2)
		local menu_pos = mainmemory.readbyte(0x890f+active_slot)
		local relm_info = DISPLAY_RELM_INFO and active_player == 8 and menu_pos == 1
		local locke_info = DISPLAY_LOCKE_INFO and active_player == 1 and menu_pos == 1
		local gau_info = DISPLAY_GAU_INFO and active_player == 0xb

		if gau_info then
			local id_byte, id_bit = math.floor(id/8), id % 8
			if bit.check(mainmemory.readbyte(0x1d2c+id_byte),id_bit) == 0 then
				-- monster not known!
				gui.drawText(x-8,y,"?")
			end
		end
		
		-- More detailed information for the monster we point to.
		-- This will depend on how it is being pointed to
		if (sel_side == 0 or sel_side == 2) and sel_i == i and
			sel_multi == 0 and sel_enemy ~= 0 then
			--gui.drawText(10,offset,"Level "..level.." "..name)
			--offset = offset+10
			gui.drawText(10,offset,string.format("HP:%d/%d, MP:%d/%d",hp,mhp,mp,mmp))
			offset = offset+10
			--gui.drawText(10,offset,string.format("XP:%d, gold:%d",xp,gold))
			--offset = offset+10
			if DISPLAY_CRITICALS then
				be = mainmemory.readbyte(0x00be)
				be = (be + 0x31) % 0x100
				rng = memory.readbyte(0x00fd00+be)
				if rng < 0x08 then
					gui.drawText(10,offset,string.format("Critical (%X)",be))
					offset = offset+10
				else
					gui.drawText(10,offset,string.format("(%X)",be))
					offset = offset+10
				end
			end
			if locke_info then
				gui.drawText(10,offset,string.format("Steal %s/%s", getitemname(stealn), getitemname(stealr)))
				offset = offset+10
			end
			gui.drawText(10,offset,string.format("Drops %s/%s", getitemname(dropn), getitemname(dropr)))
			offset = offset+10
			-- Special attack description
			local specialn = get_special(id)
			if relm_info then
				-- Sketch
				local sketch1 = memory.readbyte(0x0f4300+2*id)
				local sketch2 = memory.readbyte(0x0f4300+2*id+1)
				-- control
				local control, controln = {}, {}
				for ctrl_i = 0, 3 do
					control[ctrl_i] = memory.readbyte(0x0f3d00+4*id+ctrl_i)
				end
				if sketch1 == 0xEF then sketch1n = specialn else sketch1n = getattackname(sketch1) end
				if sketch2 == 0xEF then sketch2n = specialn else sketch2n = getattackname(sketch2) end
				for ctrl_i = 0, 3 do
					local ctrl,foo = control[ctrl_i]
					if ctrl == 0xEF then foo = specialn
					elseif ctrl == 0xFF then foo = "Nothing"
					else foo = getattackname(ctrl) end
					controln[ctrl_i] = foo
				end
				gui.drawText(10,offset,string.format("Sketch %s/%s", sketch2n, sketch1n))
				offset = offset+10
				gui.drawText(10,offset,string.format("Control %s/%s",controln[0],controln[1]))
				offset = offset+10
				gui.drawText(10,offset,string.format("        %s/%s",controln[2],controln[3]))
				offset = offset+10
			end
		end
	end end
	-- Rage information when in the rage menu
	if mainmemory.readbyte(0x7bd4) == 0x24 then
		local x = mainmemory.readbyte(0x892f)
		local y = mainmemory.readbyte(0x8933)
		local scroll = mainmemory.readbyte(0x892b)
		local i = 2*(y+scroll)+x
		local id = mainmemory.readbyte(0x257e + i)
		if id ~= 0xFF then
			-- What rages does this monster have?
			local rage1 = memory.readbyte(0x0f4600+2*id)
			local rage2 = memory.readbyte(0x0f4600+2*id+1)
			-- Special attack description
			local specialn = get_special(id)
			if rage1 == 0xEF then rage1n = specialn else rage1n = getattackname(rage1) end
			if rage2 == 0xEF then rage2n = specialn else rage2n = getattackname(rage2) end
			gui.drawText(10,offset,string.format("%s/%s", rage1n, rage2n))
			offset = offset+10
		end
	end
end


----------------------------------------
-- Display treasures and events in caves
----------------------------------------



display_treasures = function()
	-- get the screen position
	local sx     = mainmemory.read_u16_le(0x8297)
	local sy     = mainmemory.read_u16_le(0x8299)
	if sx >= 0x8000 then sx = sx-0x10000 end
	if sy >= 0x8000 then sy = sy-0x10000 end
	-- prepare to loop through treasures
	local area   = mainmemory.read_u16_le(0x0082)
	local table  = 0x2d8634
	local i      = memory.read_u16_le(0x2d82f4+2*area)
	local to     = memory.read_u16_le(0x2d82f4+2*(area+1))
	-- loop through the treasures
	while i ~= to do
		-- read from the treasure information array
		local xi     = memory.readbyte(table+i)
		local yi     = memory.readbyte(table+i+1)
		local flagi  = memory.read_u16_le(table+i+2)
		local item   = memory.readbyte(table+i+4)
		local name   = getitemname(item)
		-- Has the box been taken? To find out, we need to
		-- do some bit manipulation.
		local byte_index = math.floor(flagi/8)
		local bit_index = flagi % 8
		if byte_index >= 0x40 then
			byte_index = byte_index - 0x40*math.floor(byte_index/0x40)
		end
		local flag = mainmemory.readbyte(0x1e40+byte_index)
		flag = flag % (2^(bit_index+1))
		flag = math.floor(flag/ 2^bit_index)
		-- flag is now 0 if not taken and 1 if taken
		if flag == 0 then color = 0x7f00ff00 else color = 0x7fff0000 end

		-- get the real x,y position, using the fact that
		-- each square is 0x10 big.
		local x,y = 0x10*xi, 0x10*yi
		-- relative coordinates
		local rx, ry = x-sx, y-sy

		-- draw a nice red box around the treasure box
		gui.drawRectangle(rx, ry, 0x10, 0x10, color)
		gui.drawText(rx, ry-5, name)

		i = i + 5
	end
	table = 0x1fbb00
	i     = memory.read_u16_le(table+2*area)
	to    = memory.read_u16_le(table+2*(area+1))
	-- loop through the transitions
	while i ~= to do
		-- read from the treasure information array
		local xi     = memory.readbyte(table+i)
		local yi     = memory.readbyte(table+i+1)
		local hmm    = memory.read_u16_le(table+i+2)
		local xti    = memory.readbyte(table+i+4)
		local yti    = memory.readbyte(table+i+5)
		local area2 = hmm % 0x200
		-- is it to the same area? If so, color it
		-- light blue. Else make it normal blue.
		if area2 == area then color = 0x7f8080ff
		else color = 0x7f0000ff end

		-- get the real x,y position, using the fact that
		-- each square is 0x10 big.
		local x,y = 0x10*xi, 0x10*yi
		-- relative coordinates
		local rx, ry = x-sx, y-sy
		gui.drawRectangle(rx, ry, 0x10, 0x10, color)

		i = i + 6
	end
	table = 0x2df480
	i     = memory.read_u16_le(table+2*area)
	to    = memory.read_u16_le(table+2*(area+1))
	-- loop through the wide transitions
	while i ~= to do
		-- read from the treasure information array
		local xi     = memory.readbyte(table+i)
		local yi     = memory.readbyte(table+i+1)
		local dxi    = memory.readbyte(table+i+2)
		local dyi    = 0
		local hmm    = memory.read_u16_le(table+i+3)
		local xti    = memory.readbyte(table+i+5)
		local yti    = memory.readbyte(table+i+6)
		local area2 = hmm % 0x200
		if dxi >= 0x80 then dxi, dyi = 0, dxi % 0x80 end
		-- is it to the same area? If so, color it
		-- light blue. Else make it normal blue.
		if area2 == area then color = 0x7f8080ff
		elseif area2 == 0x1ff then color = 0x7fb0b0ff
		else color = 0x7f0000ff end

		-- get the real x,y position, using the fact that
		-- each square is 0x10 big.
		local x,y,dx,dy = 0x10*xi, 0x10*yi, 0x10*dxi, 0x10*dyi
		-- relative coordinates
		local rx, ry = x-sx, y-sy
		gui.drawRectangle(rx, ry, dx+0x10, dy+0x10, color)

		i = i + 7
	end
	table= 0x040000
	i    = memory.read_u16_le(table+2*area)
	to   = memory.read_u16_le(table+2*(area+1))

	-- loop through the reactions
	while i ~= to do
		-- read from the treasure information array
		local xi     = memory.readbyte(table+i)
		local yi     = memory.readbyte(table+i+1)
		local react1 = memory.read_u16_le(table+i+2)
		local react2 = memory.readbyte(table+i+4)
		local color = 0x7fffff00

		-- get the real x,y position, using the fact that
		-- each square is 0x10 big.
		local x,y = 0x10*xi, 0x10*yi
		-- relative coordinates
		local rx, ry = x-sx, y-sy
		gui.drawRectangle(rx, ry, 0x10, 0x10, color)

		i = i + 5
	end
end


-----------------------------------------
-- Predict encounters during map and cave
-----------------------------------------


function display_encounters()
	-- Equipment-derived information is not kept permanently, it is recomputed
	-- at the beginning of every frame, I think. We need to know if the party
	-- has the moogle charm or charm bangle effect.
	-- We will therefore loop through the equipment of all characters.
	local field_effects = 0
	local status_effects = 0
	local char_in_party = 0
	local slot_speed = {0xFF, 0xFF, 0xFF, 0xFF} -- for computing ATB much later
	local slot_name = {"", "", "", ""} -- for displaying ATB much later
	for id = 0, 0xF do
		local tmp = mainmemory.readbyte(0x1850+id)
		if tmp % 8 == mainmemory.readbyte(0x1a6d) then
			-- character is present. If necessary, information about
			-- row and slot is also available in tmp.
			char_in_party = char_in_party + 1
			local x = id*0x25+0x1F -- start of equipment
			for i = 0, 5 do
				local item = mainmemory.readbyte(0x1600+x+i)
				if item ~= 0xFF then
					-- item actually equipped
					field_effects = bit.bor(field_effects,memory.readbyte(0x185005+item*0x1e))
					status_effects = bit.bor(status_effects,memory.readbyte(0x18500a+item*0x1e))
				end
			end
			
			-- Gather the speed of the corresponding character
			slot = bit.rshift(bit.band(tmp, 0x18), 3)
			slot_speed[slot+1] = mainmemory.readbyte(0x161B+0x25*id)
			slot_name[slot+1] = readsnesstringram(0x1602+0x25*id,6)
		end
	end
	-- field_effects is what is later put in 11df

	
	-- Get the encounter rate of the current tile
	local encounter_rate
	local pack_index
	
	if mode == MODE_MAP then
		local terrain = mainmemory.readbyte(0x11f9) % 8
		local at_22 = memory.readbyte(0x00c28f+terrain) -- lave tall, men hva betyr de?
		local a = memory.readbyte(0x00c297+terrain) -- denne arrayen fÃ¸lger rett etter. samme stÃ¸rrelsesorden.
		-- b og c er faktisk x og y-posisjonen pÃ¥ kartet til *forrige encounter*!
		local last_x = mainmemory.readbyte(0x1f60)
		local last_y = mainmemory.readbyte(0x1f61)
		local zone_x, zone_y = math.floor(last_x/0x20),math.floor(last_y/0x20)
		local zone = mainmemory.readbyte(0x1f64)*0x40+zone_y*8+zone_x

		-- a mÃ¥ inneholde en mapping fra terreng til offsets i fÃ¸lgende array.
		-- merkelig at slikt trengs.
		pack_index = memory.readbyte(0x0f5400+zone*4+a)
		-- den hÃ¸ye byten her angir kanskje om det er world of balance eller ruin eller noe annet?
		local encounter_rate_index = math.floor(memory.readbyte(0x0f5800+zone) / 4^at_22) % 4
		 -- field_effects har info om charm bangle etc. encounter_rate_index info om more/less enc.
		local x = (field_effects)%4*8 + encounter_rate_index*2
		-- x er nÃ¥ indeks inn i encounter rate-tabellen.
		encounter_rate = memory.read_u16_le(0x00c29f+x)
	else
		local area = mainmemory.read_u16_le(0x0082)
		local ax,ay = math.floor(area/4), area % 4
		local a = (memory.readbyte(0x0f5880+ax) / 4^ay) % 4
		local x = ((mainmemory.readbyte(0x11df) % 4) * 4 + a) * 2
		encounter_rate = memory.read_u16_le(0x00c2bf+x)
		if bit.check(mainmemory.readbyte(0x0525),7) == 0 then
			encounter_rate = 0
		end
		pack_index = memory.readbyte(0x0f5600+area)
	end
		
	if encounter_rate ~= 0 then
	
		-- Compute how many steps until the next fight
		local enc1 = mainmemory.read_u16_le(0x1f6e)
		local enc2 = mainmemory.readbyte(0x1fa1)
		local enc3 = mainmemory.readbyte(0x1fa4)
		local count = -1

		for i = 0, 250 do
			enc1 = enc1 + encounter_rate
			gui.drawPixel(i+2, 220-math.floor(enc1/0x100), 0x7F00FF00)
			
			if enc1 >= 0x10000 then enc1 = 0xff00 end
			enc2 = (enc2+1) % 0x100
			if enc2 == 0 then enc3 = (enc3 + 0x11) % 0x100 end
			local rng = (memory.readbyte(0x00fd00+enc2)+enc3) % 0x100
			if rng < math.floor(enc1/0x100) then
				gui.drawLine(i+2, max(220-rng, 190), i+2, 190, 0x7FFF0000)
				if count == -1 then
					count = i + 1
				end
				enc1 = 0
			else
				gui.drawLine(i+2, max(220-rng, 190), i+2, 190, 0x7F0000FF)
			end
		end
		gui.drawText(10,offset,"Encounter in ".. count.." steps.")
		offset = offset+10

		local formation
		-- Veldt?
		if pack_index == 0xFF then
			local enc_veldt = (mainmemory.readbyte(0x1fa5)+1) % 0x40
			-- find a nonzero byte in the encountered formations bitarray.
			while mainmemory.readbyte(0x1ddd+enc_veldt) == 0 do
				enc_veldt = (enc_veldt+1) % 0x40
			end
			local enc5 = mainmemory.readbyte(0x1fa3)
			local enc4 = (mainmemory.readbyte(0x1fa2)+1) % 0x100
			if enc4 == 0 then enc5 = enc5 + 0x17 end
			local bit_index = (memory.readbyte(0x00fd00+enc4)+enc5) % 0x8
			local bitset = mainmemory.readbyte(0x1ddd+enc_veldt)
			-- find a nonzero bit, starting at a random position
			while bit.check(bitset,bit_index) == 0 do
				bit_index = (bit_index+1) % 8
			end
			formation = enc_veldt*8+bit_index
		else
			local x = pack_index*8
			-- Encounter type. x is the index into the monster pack array
			local enc1 = (mainmemory.readbyte(0x1fa2)+1) % 0x100
			local enc2 = mainmemory.readbyte(0x1fa3)
			if enc1 == 0 then enc2 = enc2+0x17 end
			local a = (memory.readbyte(0x00fd00+enc1)+enc2) % 0x100

			if a > 0x50 then x = x+2 end
			if a > 0xa0 then x = x+2 end
			if a > 0xf0 then x = x+2 end
			formation = memory.read_u16_le(0x0f4800+x)
		end


		-- To find out more about the encounter, we need the frame-
		-- dependent be variable. We must first predict the number
		-- of pixels we are away from an encounter.
		
		local faceing
		local xpos, ypos
		local pixels
		
		if mode == MODE_MAP then
			faceing = mainmemory.readbyte(0x00f6)
			xpos = mainmemory.readbyte(0x00c6)
			ypos = mainmemory.readbyte(0x00c8)
		else
			-- have to loop through all chars to find out who is the leader
			-- for id = 0, 0xF do
				-- local delta = 0x29*id
				-- if bit.check(memory.readbyte(0x0867+delta),7) then
					-- faceing = memory.readbyte(0x087f+delta)
					-- break
				-- end
			-- end

			faceing = mainmemory.readbyte(0x00b3) - 1
			xpos = mainmemory.readbyte(0x005c)
			ypos = mainmemory.readbyte(0x0060)
		end
		if faceing == 0 then pixels = ypos % 0x10
		elseif faceing == 1 then pixels = (0x100 - xpos) % 0x10
		elseif faceing == 2 then pixels = (0x100 - ypos) % 0x10
		else pixels = xpos % 0x10
		end
		-- this is the pixels left in our current step. then add the number
		-- of whole steps
		local standing_still = false
		if pixels == 0 then
			-- this is a whole position. was the last position whole too?
			if last_position_whole then
				standing_still = true
				pixels = 0x10*count
			else
				if mode == MODE_MAP then
					pixels = 0x10*count
				else
					pixels = 0x10*(count-1)
				end
			end
			last_position_whole = true
		else
			pixels = pixels + 0x10*(count-1)
			last_position_whole = false
		end
		-- sprint shoes?
		if mode == MODE_CAVE and bit.check(field_effects,5) then
			pixels = math.floor(pixels/2)
		end
		-- compensate for the time it takes to start moving
		if standing_still then
			if mode == MODE_MAP then -- it only takes 1 frame to start moving on the map
				if mainmemory.readbyte(0xB652) == 0 then -- unknown value that seems to work well.
					pixels = pixels+1
				end
			else
				local frame_rule = mainmemory.readbyte(0x0014) / 12
				if mainmemory.readbyte(0x000d) == 0 then -- we didn't start moving yet.
					pixels = pixels + 3 - ((frame_rule + 0) % 4)
				else
					pixels = pixels + 2 - ((frame_rule + 3) % 4)
				end
			end
		end
		
		-- The length of the battle transition depends on if we are in the world map or not.
		local battle_transition
		if mode == MODE_MAP then
			battle_transition = 0x22
		else
			battle_transition = 0x2A
		end
			
		-- we assume that we are walking with maximum speed of 1 pixel per frame
		-- this will lead to be getting this value at the beginning of battle
		
		be = 4*((mainmemory.readbyte(0x021e)+pixels+battle_transition-1) % 0x3c) + 4
		
		-- Print the frame rule.
		gui.drawText(10,offset,"Frame rule: ".. ((be/4)%4))
		offset = offset+10

		gui.drawText(10,offset,string.format("be: %x vs %x, %x %x %x", mainmemory.readbyte(0x00be), be,pixels,xpos,ypos))
		offset = offset+10

		if bit.check(formation, 15) then
			-- High bit of formation set: randomly add 0..3 to formation
			be = (be+1) % 0x100
			local a = memory.readbyte(0x00fd00+be) % 4
			formation = bit.band(formation + a, 0x7FFF)
		end

		local info1 = memory.readbyte(0x0f5900+4*formation)
		local info2 = memory.readbyte(0x0f5900+4*formation+1)
		local info3 = memory.readbyte(0x0f5900+4*formation+2)
		local info4 = memory.readbyte(0x0f5900+4*formation+3)

		-- Build monster list
		local start = 0x0f6201+15*formation
		local present = memory.readbyte(start)
		local which = {}
		local number_of_enemies = 0
		local enemy_slot_speed = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}
		local enemy_slot_name = {"", "", "", "", "", ""}
		for i = 1, 6 do
			if bit.check(present, i-1) then
				local id = memory.readbyte(start+i)
				if which[id] then which[id] = which[id]+1
				else which[id] = 1 end
				number_of_enemies = number_of_enemies + 1
				
				-- Grab the enemy speed
				enemy_slot_speed[i] = memory.readbyte(0x0f0001+0x20*id)
				enemy_slot_name[i] = getmonstername(id)
			end
		end
		-- Display list
		for id, num in pairs(which) do
			gui.drawText(10, offset, ""..num.." "..getmonstername(id))
			offset = offset + 10
		end

		-- What kind of encounter?
		-- In info1, bit 4: disable normal, bit 5: disable back, bit 6: disable pincer, bit 7: disable side
		local allowed = {} -- will hold {normal, back, pincer, side}
		local allowed_number = 0
		for i = 0, 3 do
			allowed[i] = not bit.check(info1, 4 + i) -- if checked, then disable corresponding encounter
			if allowed[i] then
				allowed_number = allowed_number + 1
			end
		end
		if bit.check(status_effects,1) then
			-- back guard, disable back and pincer.
			-- This will prefer to remove pincer if not
			-- both can be removed.
			for i = 0, 1 do if allowed_number > 1 then
				allowed[2-i] = false
				allowed_number = allowed_number - 1
			end end
		end
		if char_in_party < 3 and allowed_number > 1 then
			-- not enough characters to do side attack
			allowed[3] = false
			allowed_number = allowed_number - 1
		end

		-- Now we pick one of the possibilities
		-- First find the sum of the weights
		local sum = 0
		for i = 0, 3 do if allowed[3-i] then
			sum = sum + memory.readbyte(0x025279+i)+1
		end end
		-- before this point, be has been incremented by other things
		be = be + 0xa + 2*number_of_enemies + char_in_party
		-- get a random number from 0 to sum-1, using be
		be = (be+1) % 0x100
		local rng = bit.band(bit.rshift(memory.readbyte(0x00fd00+be)*sum, 8), 0xFF)
		
		-- now loop through again, and pick the first that is bigger
		-- than the number
		sum = 0
		local chosen = 0
		for i = 0, 3 do if allowed[3-i] then
			sum = sum + memory.readbyte(0x025279+i)+1
			if sum > rng then
				chosen = 3-i
				break
			end
		end end

		local vardesc = { "Front", "Back", "Pincer", "Side" }

		-- Finally, describe the result
		if chosen ~= 0 then
			gui.drawText(10, offset, string.format("%s attack",vardesc[chosen+1]))
			offset = offset+10
		end
		
		-- Determine preemptive
		local preemptive = false
		if bit.check(info4, 2) then
			gui.drawText(10, offset, "Preemptive disabled")
			offset = offset+10
		elseif chosen == 0 or chosen == 3 then -- front or side, preemptive possible
			
			-- determine the preemptive rate
			local rate = 8 * chosen + 0x20

			if bit.check(status_effects,0) then -- Gale hairpin equipped
				rate = rate * 2
			end

			-- call the rng
			be = (be+1) % 0x100
			local rng = memory.readbyte(0x00fd00+be)

			if rng < rate then
				preemptive = true
			end
		end

		-- Finally, describe the result
		if preemptive then
			gui.drawText(10, offset, "Pre-emptive battle")
			offset = offset+10
		end
			
		-- Determine ATB startup values
		general_incrementor = 0x10 * (10 - number_of_enemies - char_in_party)
		
		-- Compute random specific incrementor
		atb_bar = {}
		entity_bit = 0x03FF
		
		for entity = 9, 0, -1 do 
			entity_remaining = entity + 1
			be = (be+1) % 0x100
			local rng = bit.band(bit.rshift(memory.readbyte(0x00fd00+be)*entity_remaining, 8), 0xFF)
			
			-- take the rnd-th set bit starting 0
			local specific_incrementor
			for b = 0, 9 do
				if bit.check(entity_bit, b) then
					rng = rng - 1
				end
				if rng < 0 then
					specific_incrementor = b * 8
					entity_bit = bit.clear(entity_bit, b)
					break
				end
			end
						
			if entity < 4 then -- character
				if preemptive or chosen == 3 then -- Preemptive or side attack
					atb_bar[entity] = 0xFF
				elseif chosen == 0 then -- Front attack
					local speed = slot_speed[entity+1]
					be = (be+1) % 0x100
					local random_speed = bit.band(bit.rshift(memory.readbyte(0x00fd00+be)*speed, 8), 0xFF)
					atb_bar[entity] = speed + random_speed + specific_incrementor + general_incrementor + 1
				else -- Pincer or Back
					atb_bar[entity] = specific_incrementor + 1
				end
			else
				if preemptive or chosen == 3 then -- Preemptive or side attack
					atb_bar[entity] = 2
				else
					local speed = enemy_slot_speed[entity-3]
					be = (be+1) % 0x100
					local random_speed = bit.band(bit.rshift(memory.readbyte(0x00fd00+be)*speed, 8), 0xFF)
					atb_bar[entity] = speed + random_speed + specific_incrementor + general_incrementor + 1
				end
			end
		end
		
		for cs = 1, 4 do if slot_speed[cs] ~= 0xFF then -- character slot is filled
				gui.drawText(10, offset, string.format("ATB %s: %d",slot_name[cs], atb_bar[cs-1]))
				offset = offset+10
		end	end
		
		for ms = 1, 6 do if enemy_slot_speed[ms] ~= 0xFF then -- monster slot is filled
				gui.drawText(10, offset, string.format("ATB %s: %d",enemy_slot_name[ms], atb_bar[ms+3]))
				offset = offset+10
		end	end
	end
end


-- Main loop
while true do
	-- Determine if we're in battle, on the world map, in a town/dungeon, or in the menu
	if mainmemory.readbyte(0x2000) < 13 then
		mode = MODE_BATTLE
	elseif bit.band(mainmemory.read_u16_le(0x1f64), 0x01FF) <= 0x0002 then
		mode = MODE_MAP
	elseif bit.band(mainmemory.read_u16_le(0x1f64), 0x01FF) >= 0x0003 and bit.band(mainmemory.read_u16_le(0x1f64), 0x01FF) <= 0x019E then
		mode = MODE_CAVE
	end
	if mainmemory.read_u16_le(0x1501) == 0x1387 and mainmemory.readbyte(0x1503) == 0xC3 then
		mode = MODE_MENU
	end -- there's actually no way to tell you're in the menu other than checking it's NMI address

	offset = 10
	if mode == MODE_BATTLE then
		display_battle()
	elseif mode == MODE_CAVE then
		display_treasures()
	end
	
	if mode == MODE_MAP or mode == MODE_CAVE then
		display_encounters()
	end
	emu.frameadvance()
end

