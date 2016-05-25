drawpixel = function(x,y,color)
	if x < 0 or y < 0 then return end
	if x >= 0x100 or y >= 0xE0 then return end
	gui.pixel(x,y,color)
end

min = function(a,b) if a < b then return a else return b end end
max = function(a,b) if a < b then return b else return a end end
order = function(a,b) if a > b then return b, a else return a,b end end

horline = function(x1,y,x2,color)
	x1,x2 = order(x1,x2)
	x1 = min(max(0,x1),255)
	x2 = min(max(0,x2),255)
	if y >= 0 and y < 239 then
		gui.line(x1,y,x2,y,color)
	end
end

vertline = function(x,y1,y2,color)
	y1,y2 = order(y1,y2)
	y1 = min(max(0,y1),238)
	y2 = min(max(0,y2),238)
	if x >= 0 and x < 256 then
		gui.line(x,y1,x,y2,color)
	end
end

startgauge = function(x,y,w)
	gx, gy, gw = x, y, w
end
drawgauge = function(c,m,col)
	if m == 0 then m = 1 end
	local g = bit.quotent(c*gw,m)
	horline(gx,gy,gx+g,col)
	horline(gx+g,gy,gx+gw,0x7f000000)
	gy = gy-1
end

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
  return charArray[i+1]
end

readsnesstring = function(from,maximum)
	local res = ""
	local tmp = memory2.ROM:byte(from)
	local i = 0
	while tmp ~= 0xFF do
		if i == maximum then break end
		res = res .. tochar(tmp)
		from = from+1
		tmp = memory2.ROM:byte(from)
		i = i+1
	end
	return res
end

readsnesstringram = function(from,maximum)
	local res = ""
	local tmp = memory2.WRAM:byte(from)
	local i = 0
	while tmp ~= 0xFF do
		if i == maximum then break end
		res = res .. tochar(tmp)
		from = from+1
		tmp = memory2.WRAM:byte(from)
		i = i+1
	end
	return res
end

getitemname = function(id)
	return readsnesstring(0x26F701+9*id,9)
end
getmonstername = function(id)
	return readsnesstring(0x0fc800+8*id,8)
end
getattackname = function(id)
	if id < 0x36 then -- magic
	  return readsnesstring(0x2D7400+5*id, 5)
	end
  if id < 0x55 then
    id = id - 0x36
    return readsnesstring(0x2D750E+8*id, 8)
  end
  if id < 0x5D then
  -- Swdtechs use kanjis
    id = id - 0x54
    local deathblows = {"必殺剣　牙", "必殺剣　空", "必殺剣　虎", "必殺剣　舞", "必殺剣　龍", "必殺剣　月", "必殺剣　烈", "必殺剣　断"}
    return deathblows[id]
  end
  id = id - 0x36
  return readsnesstring(0x2D750E+8*id, 8)
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
	horline(x, y, x+4, 0x7f404040)
	vertline(x+4, y, y+4, 0x7f404040)
	vertline(x, y, y+4, 0x7f404040)
	horline(x, y+4, x+4, 0x7f404040)
	-- now draw the elements
	local x,y=x+1,y+1
	putpix = function(x,y,b,c)
		if b == 1 then drawpixel(x,y,c) else drawpixel(x,y,0x7f000000) end
	end
	cols = {
		0x7fff0000,0x7f0000ff,0x7fffff00,
		0x7f00ff00,0x7f808080,0x7fffffff,
		0x7fa08000,0x7f0000ff,0x7f000000
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
	local special = memory2.ROM:byte(0x0f001f+0x20*id)
	local specialn = readsnesstring(0x0fd0d0+id*10,10)
	local no_damage,no_dodge = bit.test(special, 6),bit.test(special,7)
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
