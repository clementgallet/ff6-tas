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

memory.usememorydomain("CARTROM")

drawpixel = function(x,y,color)
	if x < 0 or y < 0 then return end
	if x >= 0x100 or y >= 0xE0 then return end
	gui.drawPixel(x,y,color)
end
-- the following section handles out of bounds checking.
-- This will hopefully not be necessary in later versions of snes9x-lua
-- The bounds checking for lines is slightly more complicated, so I did
-- not bother implementing it properly.
min = function(a,b) if a < b then return a else return b end end
max = function(a,b) if a < b then return b else return a end end
order = function(a,b) if a > b then return b, a else return a,b end end
--olddrawBox = gui.drawBox
--gui.drawBox = function(x1,y1,x2,y2,color)
--	x1,x2 = order(x1,x2)
--	y1,y2 = order(y1,y2)
--	x1 = min(max(0,x1),255)
--	y1 = min(max(0,y1),238)
--	x2 = min(max(0,x2),255)
--	y2 = min(max(0,y2),238)
--	olddrawBox(x1,y1,x2,y2,color)
--end
--oldtext = gui.text
--gui.text = function(x,y,text)
--	if x >= 0 and x < 256 and y >= 0 and y < 239 then
--		oldtext(x,y,text)
--	end
--end
horline = function(x1,y,x2,color)
	x1,x2 = order(x1,x2)
	x1 = min(max(0,x1),255)
	x2 = min(max(0,x2),255)
	if y >= 0 and y < 239 then
		gui.drawLine(x1,y,x2,y,color)
	end
end
vertline = function(x,y1,y2,color)
	y1,y2 = order(y1,y2)
	y1 = min(max(0,y1),238)
	y2 = min(max(0,y2),238)
	if x >= 0 and x < 256 then
		gui.drawLine(x,y1,x,y2,color)
	end
end

startgauge = function(x,y,w)
	gx, gy, gw = x, y, w
end
drawgauge = function(c,m,col)
	if m == 0 then m = 1 end
	local g = c*gw/m
	horline(gx,gy,gx+g,col)
	horline(gx+g,gy,gx+gw,0xff000000)
	gy = gy-1
end

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
getmonstername = function(id)
	return readsnesstring(0x0fc050+0xa*id,10)
end
getattackname = function(id)
	local x = 0
	local maxlen = 10
	if id < 0x36 then
		x = id*7
		maxlen = 7
	elseif id < 0x51 then
		x = id*8-0x36
		maxlen = 8
	elseif id < 0x56 then x = id*0xA-0xd8
	else x = id*0xA-0xd8 -- vet ikke hvorfor indeksen blir d8 her.
	--else id < 0x5b then x = id*0xA-0xc4
	end
	return readsnesstring(0x26f567+x,maxlen)
end


-- prints a compact representation of elemental properties.
-- There are 8 elements. Each is assigned a color, and a place
-- in a 3x3 matrix of pixels.
-- fil   ; fire (red) ice (blue) lightning (yellow)
-- pwp   ; poison (green) wind (gray) holy (white)
-- ew    ; earth (brown) water (blue)
-- Colors need not be uniqe, as the position fixes things.
-- This is then surrounded by black border.
print_element = function(x,y,elem)
	-- first draw the border
	horline(x, y, x+4, 0xff404040)
	vertline(x+4, y, y+4, 0xff404040)
	vertline(x, y, y+4, 0xff404040)
	horline(x, y+4, x+4, 0xff404040)
	-- now draw the elements
	local x,y=x+1,y+1
	putpix = function(x,y,b,c)
		if b == 1 then drawpixel(x,y,c) else drawpixel(x,y,0xff000000) end
	end
	cols = {
		0xffff0000,0xff0000ff,0xffffff00,
		0xff00ff00,0xff808080,0xffffffff,
		0xffa08000,0xff0000ff,0xff000000
	}
	for i = 1, 9 do
		dx, dy = (i-1)%3, math.floor((i-1)/3)
		putpix(x+dx,y+dy,elem % 2,cols[i])
		elem = math.floor(elem/2)
	end
end

get_special = function(id)
	-- Information about the special attack
	-- This is used by rage, sketch, control.
	local special = memory.readbyte(0x0f001f+0x20*id)
	local specialn = readsnesstring(0x0fd0d0+id*10,10)
	local no_damage,no_dodge = bit.check(special, 6),bit.check(special,7)
	special = special % 0x40
	desc = "???"
	if special == 0x30 then desc = "absorb hp"
	elseif special == 0x31 then desc = "absorb mp"
	elseif special >= 0x32 then desc = "remove reflect"
	elseif special >= 0x20 then desc = string.format("+%d%%",(special-0x1f)*50)
	else
		local descs = { "Dark","Zombie","Poison","MagiTek","Clear","Imp","Petrify",
			"Death", "Condemned", "Near Fatal", "Image", "Mute", "Berserk",
			"Muddle", "Seizure", "Sleep", "Dance", "Regen", "Slow", "Haste",
			"Stop", "Shell", "Safe", "Reflect", "Rage", "Freeze", "Life 3",
			"Morph", "Chant!", "Disappear!", "Dog block", "Float" }
		desc = descs[special+1]
	end
	specialn = specialn.." ("..desc..")"
	return specialn, no_damage, no_dodge
end


print_status = function(status)
	-- MÃ¥ finne ut hva bitsene i hver status byte betyr.
end


-- to get the pixel distance from an encounter, we
-- need to fix an occational off-by-1 error for
-- count. this happens on the first frame when we reach
-- a whole square. we thus need to keep track of whether
-- the last position was whole or not
last_position_whole = true

while true do
	-- Are we in battle?
	-- Determine if we're in battle, on the world map, in a town/dungeon, or in the menu
	gui.drawRectangle(1,1,100,100,0xFF888888, 0x07FFF0000)
	if bit.band(mainmemory.readbyte(0x11fd), 0x2) == 0x2 then
		mode_cave = false
		mode_battle = true
		mode_map = false
		mode_menu = false
	elseif bit.band(mainmemory.read_u16_le(0x1f64), 0x01FF) <= 0x0002 then
		mode_cave = false
		mode_battle = false
		mode_map = true
		mode_menu = false
	elseif bit.band(mainmemory.read_u16_le(0x1f64), 0x01FF) >= 0x0003 and bit.band(mainmemory.read_u16_le(0x1f64), 0x01FF) <= 0x019E then
		mode_cave = true
		mode_battle = false
		mode_map = false
		mode_menu = false
	elseif mainmemory.read_u16_le(0x1501) == 0x1387 and mainmemory.readbyte(0x1503) == 0xC3 then
		mode_cave = false
		mode_battle = false
		mode_map = false
		mode_menu = true
	end -- there's actually no way to tell you're in the menu other than checking it's NMI address

	offset = 100
	if mode_battle then
		sel_side, sel_i = mainmemory.readbyte(0x7ace), mainmemory.readbyte(0x7acf)
		sel_enemy, sel_party = mainmemory.readbyte(0x7b7e),mainmemory.readbyte(0x7b7d)
		sel_multi = mainmemory.readbyte(0x7b7f)
		-- loop through present monsters
		for i = 0, 5 do
			-- a few shortcuts
			j, k = 2*i, 2*(4+i)
			state = mainmemory.read_u16_le(0x3aa0+k)
			if state ~= 0 and bit.check(state,15) ~= 1 then
			-- get coordinates (we should know the size of the monster too, but we don't)
			x = mainmemory.readbyte(0x80c2+1+j)
			-- this size is really the x-offset of the pointing hand relative to the start
			-- of the sprite. For a normal attack, this works fine, but for monsters on the
			-- right hand side of the screen, this offset is 0, as the hand is on their left
			-- side. To do things properly, I should get this in a more direct fashion, but
			-- I can't be bothered
			xsize = mainmemory.readbyte(0x807a+1+j)
			if xsize == 0 then xsize = 0x20 end
			y = mainmemory.readbyte(0x80ce+1+j)
			-- other interesting information
			id   = mainmemory.read_u16_le(0x3388+j)
			xp   = mainmemory.read_u16_le(0x3d8c+j)
			gold = mainmemory.read_u16_le(0x3da0+j)
			hp   = mainmemory.read_u16_le(0x3bf4+k)
			mp   = mainmemory.read_u16_le(0x3c08+k)
			mhp  = mainmemory.read_u16_le(0x3c1c+k)
			mmp  = mainmemory.read_u16_le(0x3c30+k)
			level= mainmemory.readbyte(0x3b18+k)
			speed= mainmemory.readbyte(0x3b19+k)
			gauge= mainmemory.read_u16_le(0x3218+k)
			-- elements
			absorb  =  mainmemory.readbyte(0x3bcc+k)
			nullify =  mainmemory.readbyte(0x3bcd+k)
			resist  =  mainmemory.readbyte(0x3be1+k)
			weak    =  mainmemory.readbyte(0x3be0+k)
			stealn  =  mainmemory.readbyte(0x3311+j)
			stealr  =  mainmemory.readbyte(0x3310+j)
			dropn   =  memory.readbyte(0x0f3000+4*id+3)
			dropr   =  memory.readbyte(0x0f3000+4*id+2)

			name = getmonstername(id)

			-- Print the gauges
			startgauge(x,y,xsize)
			drawgauge(mp, mmp, 0xff0000ff)
			drawgauge(hp, mhp, 0xff00ff00)
			drawgauge(gauge, 0x10000, 0xffff0000)
			by = gy
			gui.text(x-16, by-8, string.format("%2d",level))
			print_element(x, by-6, absorb)
			print_element(x+4, by-6, nullify)
			print_element(x+8, by-6, resist)
			print_element(x+12, by-6, weak)
			gui.text(x+18, by-8, ""..hp)

			active_slot = mainmemory.readbyte(0x0201)
			active_player = mainmemory.readbyte(0x3ed8+active_slot*2)
			menu_pos = mainmemory.readbyte(0x890f+active_slot)
			relm_info = active_player == 8 and menu_pos == 1
			locke_info = active_player == 1 and menu_pos == 1
			gau_info = active_player == 0xb

			if gau_info then
				local id_byte, id_bit = math.floor(id/8), id % 8
				if bit.check(mainmemory.readbyte(0x1d2c+id_byte),id_bit) == 0 then
					-- monster not known!
					gui.text(x-8,y,"?")
				end
			end
			
			-- More detailed information for the monster we point to.
			-- This will depend on how it is being pointed to
			if (sel_side == 0 or sel_side == 2) and sel_i == i and
				sel_multi == 0 and sel_enemy ~= 0 then
				--gui.text(10,offset,"Level "..level.." "..name)
				--offset = offset+10
				gui.text(10,offset,string.format("HP:%d/%d, MP:%d/%d",hp,mhp,mp,mmp))
				offset = offset+10
				--gui.text(10,offset,string.format("XP:%d, gold:%d",xp,gold))
				--offset = offset+10
				if locke_info then
					gui.text(10,offset,string.format("Steal %s/%s", getitemname(stealn), getitemname(stealr)))
					offset = offset+10
				end
				gui.text(10,offset,string.format("Drops %s/%s", getitemname(dropn), getitemname(dropr)))
				offset = offset+10
				-- Special attack description
				specialn = get_special(id)
				-- Sketch
				sketch1 = memory.readbyte(0x0f4300+2*id)
				sketch2 = memory.readbyte(0x0f4300+2*id+1)
				-- control
				control, controln = {}, {}
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
				if relm_info then
					gui.text(10,offset,string.format("Sketch %s/%s", sketch2n, sketch1n))
					offset = offset+10
					gui.text(10,offset,string.format("Control %s/%s",controln[0],controln[1]))
					offset = offset+10
					gui.text(10,offset,string.format("        %s/%s",controln[2],controln[3]))
					offset = offset+10
				end
			end
		end end
		-- Rage information when in the rage menu
		if mainmemory.readbyte(0x7bd4) == 0x24 then
			x = mainmemory.readbyte(0x892f)
			y = mainmemory.readbyte(0x8933)
			scroll = mainmemory.readbyte(0x892b)
			i = 2*(y+scroll)+x
			id = mainmemory.readbyte(0x257e + i)
			if id ~= 0xFF then
				-- What rages does this monster have?
				rage1 = memory.readbyte(0x0f4600+2*id)
				rage2 = memory.readbyte(0x0f4600+2*id+1)
				-- Special attack description
				specialn = get_special(id)
				if rage1 == 0xEF then rage1n = specialn else rage1n = getattackname(rage1) end
				if rage2 == 0xEF then rage2n = specialn else rage2n = getattackname(rage2) end
				gui.text(10,offset,string.format("%s/%s", rage1n, rage2n))
				offset = offset+10
			end
		end
	elseif mode_cave then
		-- get the screen position
		sx     = mainmemory.read_u16_le(0x8297)
		sy     = mainmemory.read_u16_le(0x8299)
		if sx >= 0x8000 then sx = sx-0x10000 end
		if sy >= 0x8000 then sy = sy-0x10000 end
		-- prepare to loop through treasures
		area   = mainmemory.read_u16_le(0x0082)
		table  = 0x2d8634
		i      = memory.read_u16_le(0x2d82f4+2*area)
		to     = memory.read_u16_le(0x2d82f4+2*(area+1))
		-- loop through the treasures
		while i ~= to do
			-- read from the treasure information array
			xi     = memory.readbyte(table+i)
			yi     = memory.readbyte(table+i+1)
			flagi  = memory.read_u16_le(table+i+2)
			item   = memory.readbyte(table+i+4)
			name   = getitemname(item)
			-- Has the box been taken? To find out, we need to
			-- do some bit manipulation.
			byte_index = math.floor(flagi/8)
			bit_index = flagi % 8
			if byte_index >= 0x40 then
				byte_index = byte_index - 0x40*math.floor(byte_index/0x40)
			end
			flag = mainmemory.readbyte(0x1e40+byte_index)
			flag = flag % (2^(bit_index+1))
			flag = math.floor(flag/ 2^bit_index)
			-- flag is now 0 if not taken and 1 if taken
			if flag == 0 then color = 0xff00ff00 else color = 0xffff0000 end

			-- get the real x,y position, using the fact that
			-- each square is 0x10 big.
			x,y = 0x10*xi, 0x10*yi
			-- relative coordinates
			rx, ry = x-sx, y-sy

			-- draw a nice red box around the treasure box
			gui.drawBox(rx, ry, rx+0x10, ry+0x10, color)
			gui.text(rx, ry-5, name)

			i = i + 5
		end
		table = 0x1fbb00
		i     = memory.read_u16_le(table+2*area)
		to    = memory.read_u16_le(table+2*(area+1))
		-- loop through the transitions
		while i ~= to do
			-- read from the treasure information array
			xi     = memory.readbyte(table+i)
			yi     = memory.readbyte(table+i+1)
			hmm    = memory.read_u16_le(table+i+2)
			xti    = memory.readbyte(table+i+4)
			yti    = memory.readbyte(table+i+5)
			area2 = hmm % 0x200
			-- is it to the same area? If so, color it
			-- light blue. Else make it normal blue.
			if area2 == area then color = 0xff8080ff
			else color = 0xff0000ff end

			-- get the real x,y position, using the fact that
			-- each square is 0x10 big.
			x,y = 0x10*xi, 0x10*yi
			-- relative coordinates
			rx, ry = x-sx, y-sy
			gui.drawBox(rx, ry, rx+0x10, ry+0x10, color)

			i = i + 6
		end
		table = 0x2df480
		i     = memory.read_u16_le(table+2*area)
		to    = memory.read_u16_le(table+2*(area+1))
		-- loop through the wide transitions
		while i ~= to do
			-- read from the treasure information array
			xi     = memory.readbyte(table+i)
			yi     = memory.readbyte(table+i+1)
			dxi    = memory.readbyte(table+i+2)
			dyi    = 0
			hmm    = memory.read_u16_le(table+i+3)
			xti    = memory.readbyte(table+i+5)
			yti    = memory.readbyte(table+i+6)
			area2 = hmm % 0x200
			if dxi >= 0x80 then dxi, dyi = 0, dxi % 0x80 end
			-- is it to the same area? If so, color it
			-- light blue. Else make it normal blue.
			if area2 == area then color = 0xff8080ff
			elseif area2 == 0x1ff then color = 0xffb0b0ff
			else color = 0xff0000ff end

			-- get the real x,y position, using the fact that
			-- each square is 0x10 big.
			x,y,dx,dy = 0x10*xi, 0x10*yi, 0x10*dxi, 0x10*dyi
			-- relative coordinates
			rx, ry = x-sx, y-sy
			gui.drawRectangle(rx, ry, dx+0x10, dy+0x10, color)

			i = i + 7
		end
		table= 0x040000
		i    = memory.read_u16_le(table+2*area)
		to   = memory.read_u16_le(table+2*(area+1))

		-- loop through the reactions
		while i ~= to do
			-- read from the treasure information array
			xi     = memory.readbyte(table+i)
			yi     = memory.readbyte(table+i+1)
			react1 = memory.read_u16_le(table+i+2)
			react2 = memory.readbyte(table+i+4)
			color = 0xffffff00

			-- get the real x,y position, using the fact that
			-- each square is 0x10 big.
			x,y = 0x10*xi, 0x10*yi
			-- relative coordinates
			rx, ry = x-sx, y-sy
			gui.text(1,40,rx)
			gui.drawRectangle(rx, ry, 0x10, 0x10, color)

			i = i + 5
		end
	end
	-- encounter counter
	if mode_map or mode_cave then
		-- Equipment-derived information is not kept permanently, it is recomputed
		-- at the beginning of every frame, I think. We need to know if the party
		-- has the moogle charm or charm bangle effect.
		-- We will therefore loop through the equipment of all characters.
		field_effects = 0
		status_effects = 0
		char_in_party = 0
		for id = 0, 0xF do
			tmp = mainmemory.readbyte(0x1850+id)
			if tmp % 8 == mainmemory.readbyte(0x1a6d) then
				-- character is present. If necessary, information about
				-- row and slot is also awailable in tmp.
				char_in_party = char_in_party + 1
				x = id*0x25+0x1F -- start of equipment
				for i = 0, 5 do
					item = mainmemory.readbyte(0x1600+x+i)
					if item ~= 0xFF then
						-- item actually equipped
						field_effects = bit.bor(field_effects,memory.readbyte(0x185005+item*0x1e))
						status_effects = bit.bor(status_effects,memory.readbyte(0x18500a+item*0x1e))
					end
				end
			end
		end
		-- field_effects is what is later put in 11df

		if mode_map then
			terrain = mainmemory.readbyte(0x11f9) % 8
			at_22 = memory.readbyte(0x00c28f+terrain) -- lave tall, men hva betyr de?
			a = memory.readbyte(0x00c297+terrain) -- denne arrayen fÃ¸lger rett etter. samme stÃ¸rrelsesorden.
			-- b og c er faktisk x og y-posisjonen pÃ¥ kartet til *forrige encounter*!
			last_x = mainmemory.readbyte(0x1f60)
			last_y = mainmemory.readbyte(0x1f61)
			zone_x, zone_y = math.floor(last_x/0x20),math.floor(last_y/0x20)
			zone = mainmemory.readbyte(0x1f64)*0x40+zone_y*8+zone_x

			-- a mÃ¥ inneholde en mapping fra terreng til offsets i fÃ¸lgende array.
			-- merkelig at slikt trengs.
			pack_index = memory.readbyte(0x0f5400+zone*4+a)
			-- den hÃ¸ye byten her angir kanskje om det er world of balance eller ruin eller noe annet?
			encounter_rate_index = math.floor(memory.readbyte(0x0f5800+zone) / 4^at_22) % 4
			 -- field_effects har info om charm bangle etc. encounter_rate_index info om more/less enc.
			x = (field_effects)%4*8 + encounter_rate_index*2
			-- x er nÃ¥ indeks inn i encounter rate-tabellen.
			encounter_rate = memory.read_u16_le(0x00c29f+x)
		else
			area = mainmemory.read_u16_le(0x0082)
			ax,ay = math.floor(area/4), area % 4
			a = (memory.readbyte(0x0f5880+ax) / 4^ay) % 4
			x = ((mainmemory.readbyte(0x11df) % 4) * 4 + a) * 2
			encounter_rate = memory.read_u16_le(0x00c2bf+x)
			if bit.check(mainmemory.readbyte(0x0525),7) == 0 then
				encounter_rate = 0
			end
			pack_index = memory.readbyte(0x0f5600+area)
		end
		enc1 = mainmemory.read_u16_le(0x1f6e)
		enc2 = mainmemory.readbyte(0x1fa1)
		enc3 = mainmemory.readbyte(0x1fa4)
		count = 1
		if encounter_rate ~= 0 then
			for i = 0, 100 do
				enc1 = enc1 + encounter_rate
				if enc1 >= 0x10000 then enc1 = 0xff00 end
				enc2 = (enc2+1) % 0x100
				if enc2 == 0 then enc3 = (enc3 + 0x11) % 0x100 end
				if (memory.readbyte(0x00fd00+enc2)+enc3) % 0x100 < math.floor(enc1/0x100) then break end
				count = count+1
			end
			gui.text(10,offset,"Encounter in ".. count.." steps.")
			offset = offset+10

			-- Veldt?
			if pack_index == 0xFF then
				enc_veldt = (mainmemory.readbyte(0x1fa5)+1) % 0x40
				-- find a nonzero byte in the encountered formations bitarray.
				while mainmemory.readbyte(0x1ddd+enc_veldt) == 0 do
					enc_veldt = (enc_veldt+1) % 0x40
				end
				enc5 = mainmemory.readbyte(0x1fa3)
				enc4 = (mainmemory.readbyte(0x1fa2)+1) % 0x100
				if enc4 == 0 then enc5 = enc5 + 0x17 end
				bit_index = (memory.readbyte(0x00fd00+enc4)+enc5) % 0x8
				bitset = mainmemory.readbyte(0x1ddd+enc_veldt)
				-- find a nonzero bit, starting at a random position
				while bit.check(bitset,bit_index) == 0 do
					bit_index = (bit_index+1) % 8
				end
				formation = enc_veldt*8+bit_index
			else
				x = pack_index*8
				-- Encounter type. x is the index into the monster pack array
				enc1 = (mainmemory.readbyte(0x1fa2)+1) % 0x100
				enc2 = mainmemory.readbyte(0x1fa3)
				if enc1 == 0 then enc2 = enc2+0x17 end
				a = (memory.readbyte(0x00fd00+enc1)+enc2) % 0x100

				if a > 0x50 then x = x+2 end
				if a > 0xa0 then x = x+2 end
				if a > 0xf0 then x = x+2 end
				formation = memory.read_u16_le(0x0f4800+x)
			end

-- At this point, we have all the frame-independent information about the
-- encounter we can get. The following is an attempt to handle the frame-
-- dependent information by predicting at what frame an encounter will occur.
-- This is formation variation (on the floating continent only), attack type
-- (front, back, pincer, side) and preemptiv or not. However, this ended in
-- failure. It works for 3-4 chars in party on the map, mostly, but not for
-- fewer chars, and not when not on the world map. If you want to enable it,
-- comment the following line
			skip_frame_dependent = true

			if not skip_frame_dependent then
				-- To find out more about the encounter, we need the frame-
				-- dependent be variable. We must first predict the number
				-- of pixels we are away from an encounter.
				if mode_map() then
					faceing = mainmemory.readbyte(0x00f6)
					xpos = mainmemory.read_u16_le(0x00c6)
					ypos = mainmemory.read_u16_le(0x00c8)
				else
				-- have to loop through all chars to find out who is the leader?
				-- However, the position we get this way does not move smoothly. Bleh.
					for id = 0, 0xF do
						local delta = 0x29*id
						xpos, ypos = 0,0
						if bit.check(mainmemory.readbyte(0x0867+delta),7) == 1 then
							faceing = mainmemory.readbyte(0x086f+delta)
							xpos = mainmemory.read_u16_le(0x086a+delta)
							ypos = mainmemory.read_u16_le(0x086d+delta)
							break
						end
					end
				end
				if faceing == 0 then pixels = ypos % 0x10
				elseif faceing == 1 then
					pixels = xpos % 0x10
					if pixels ~= 0 then pixels = 0x10-pixels end
				elseif faceing == 2 then
					pixels = ypos % 0x10
					if pixels ~= 0 then pixels = 0x10-pixels end
				else pixels = xpos % 0x10
				end
				-- this is the pixels left in our current step. then add the number
				-- of whole steps
				standing_still = false
				if pixels == 0 then
					-- this is a whole position. was the last position whole too?
					if last_position_whole then
						standing_still = true
						pixels = 0x10*count
					else pixels = 0x10*(count-1) end
					last_position_whole = true
				else
					pixels = pixels + 0x10*(count-1)
					last_position_whole = false
				end
				-- sprint shoes?
				if mode_cave() and bit.check(status_effects,5) then
					pixels = math.floor(pixels/2)
				end
				-- compensate for the time it takes to start moving
				if standing_still then
					if mode_map() then pixels = pixels+2
					else
						if bit.check(status_effects,5) == 1 then
							pixels = pixels + mainmemory.readbyte(0x0021e) % 4
						else pixels = pixels + mainmemory.readbyte(0x0021e) % 4 end
					end
				end
				-- we assume that we are walking with maximum speed of 1 pixel per frame
				-- this will lead to be getting this value at the beginning of battle
				be = 4*((mainmemory.readbyte(0x021e)+pixels+0x22) % 0x3c)
				gui.text(10,90,string.format("be: %x vs %x, %x %x", mainmemory.readbyte(0x00be), be,pixels,xpos))

				if math.floor(formation / 0x8000) == 1 then
					-- High bit of formation set: randomly add 0..3 to formation
					be = (be+1) % 0x100
					a = memory.readbyte(0x00fd00+be) % 4
					formation = (formation+a) % 0x8000
				end
			end
			info1 = memory.readbyte(0x0f5900+4*formation)
			info2 = memory.readbyte(0x0f5900+4*formation+1)
			info3 = memory.readbyte(0x0f5900+4*formation+2)
			info4 = memory.readbyte(0x0f5900+4*formation+3)

			-- Build monster list
			start = 0x0f6201+15*formation
			present = memory.readbyte(start)
			which = {}
			number_of_enemies = 0
			for i = 1, 6 do
				if present % 2 == 1 then
					id = memory.readbyte(start+i)
					if which[id] then which[id] = which[id]+1
					else which[id] = 1 end
					number_of_enemies = number_of_enemies + 1
				end
				present = math.floor(present/2)
			end
			-- Display list
			for id, num in pairs(which) do
				gui.text(10, offset, ""..num.." "..getmonstername(id))
				offset = offset + 10
			end

			if not skip_frame_dependent then
				-- What kind of encounter?
				variant = math.floor(info1 / 0x10) % 0x10
				-- variant is four bits long, and those bits are front, back, pincer, side; inverted.
				-- from high to low.
				-- let us extract these
				allowed = {}
				allowed_number = 0
				for i = 0, 3 do
					allowed[i] = 1 - variant % 2
					allowed_number = allowed_number + allowed[i]
					variant = math.floor(variant/2)
				end
				if bit.check(status_effects,1) == 1 then
					-- back guard, disable back and pincer.
					-- This will prefer to remove pincer if not
					-- both can be removed.
					for i = 1, 2 do if allowed_number > 1 then
						allowed[i] = 0
						allowed_number = allowed_number-1
					end end
				end
				if char_in_party < 3 and allowed_number > 1 then
					-- not enough characters to do side attack
					allowed[3] = 0
					allowed_number = allowed_number - 1
				end

				-- Now we pick one of the possibilities
				-- First find the sum of the weights
				local sum = 0
				for i = 0, 3 do if allowed[i] == 1 then
					sum = sum + memory.readbyte(0x025279+i)+1
				end end
				-- before this point, be has been incremented by other things
				be = be + 0xa + 2*number_of_enemies + char_in_party
				-- get a random number from 0 to sum-1, using be
				be = (be+1) % 0x100
				rnd = math.floor(memory.readbyte(0x00fd00+be)*sum/0x100)
				-- now loop through again, and pick the first that is bigger
				-- than the number
				sum = 0
				for i = 0, 3 do if allowed[3-i] == 1 then
					sum = sum + memory.readbyte(0x025279+i)+1
					if sum > rnd then
						chosen = 3-i
						break
					end
				end end

				vardesc = { "Front", "Back", "Pincer", "Side" }

				-- Finally, describe the result
				if chosen ~= 0 then
					gui.text(10, offset, string.format("%s attack",vardesc[chosen+1]))
					offset = offset+10
				end
			end
		end
	end
	emu.frameadvance()
end