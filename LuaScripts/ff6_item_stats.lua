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

getitemname = function(id)
	return readsnesstring(0x12b300+0xd*id+1,12)
end


header = {"Name", "Type", "Thrown", "Useable in battle", "Useable on field", "Equipable actors", "Spell learn rate", "Spell to learn", "Field effects", "Status protection", "Equip Status", "Status effects", "Battle effects", "Targetting", "Elemental property or -50% dmg", "Vigor", "Speed", "Stamina", "Mag. Pwr.", "Weapon Spell casting", "Random casting", "Remove from inventory", "Weapon flags", "Item flags", "Weapon:Power/Item:Heal Power/Other:Defense", "Weapon:Hit Rate/Armor-Relic:Magic Defense", "Elemental Absorb", "Elemental Nullify", "Elemental Weak", "Item:Cure", "Equip Status", "Evade", "MBlock", "Special Attack", "Special Item", "Price"}

local ff = assert(io.open("items.txt", "wb"))
ff:write(table.concat(header,";"), "\n")

for id = 0,0xff do
  line = {}
  -- Name --
  table.insert(line, getitemname(id))
  
  -- Type --
  local t = memory2.ROM:byte( 0x185000+id*0x1e)
  local it = bit.band(t, 0x07)
  local typestr = {"Tools", "Weapon", "Armor", "Shield", "Hat", "Relic", "Item", ""}
  table.insert(line, typestr[it+1])
  
  if (bit.band(t, 0x10) ~= 0) then
    table.insert(line, "y")
  else
    table.insert(line, "n")
  end
  
  if (bit.band(t, 0x20) ~= 0) then
    table.insert(line, "y")
  else
    table.insert(line, "n")
  end  
  
  if (bit.band(t, 0x40) ~= 0) then
    table.insert(line, "y")
  else
    table.insert(line, "n")
  end  
  
  -- Equipable actors --
  local t = memory2.ROM:word( 0x185001+id*0x1e)
  table.insert(line, string.format("%x", t))
  
  -- Spell learn rate --
  local t = memory2.ROM:byte( 0x185003+id*0x1e)
  table.insert(line, string.format("%d", t))
  
  -- Spell to learn --
  local t = memory2.ROM:byte( 0x185004+id*0x1e)
  table.insert(line, string.format("%x", t))

  -- Field effects --
  local t = memory2.ROM:byte( 0x185005+id*0x1e)
  cell = {}
  strs = {"Reduce enemy attacks", "Prevent enemy attacks", "", "", "", "2x speed walk", "", "+1 HP per step"}
  for b = 0,7 do
    if (bit.band(t, bit.lshift(1, b)) ~= 0) then
      table.insert(cell, strs[b+1])
    end
  end
  table.insert(line, table.concat(cell, ", "))
    
  -- Status Protection --
  local t = memory2.ROM:word( 0x185006+id*0x1e)
  cell = {}
  strs = {"Dark", "Zombie", "Poison", "Magitek", "Vanish", "Imp", "Petrify", "Death", "Condemned", "Kneeling", "Blink", "Silence", "Berserk", "Confusion", "HP Drain", "Sleep"}
  for b = 0,15 do
    if (bit.band(t, bit.lshift(1, b)) ~= 0) then
      table.insert(cell, strs[b+1])
    end
  end
  table.insert(line, table.concat(cell, ", "))

  -- Equip Status --
  local t = memory2.ROM:byte( 0x185008+id*0x1e)
  cell = {}
  strs = {"Float", "Regen", "Slow", "Haste", "Stop", "Shell", "Safe", "Reflect"}
  for b = 0,7 do
    if (bit.band(t, bit.lshift(1, b)) ~= 0) then
      table.insert(cell, strs[b+1])
    end
  end
  table.insert(line, table.concat(cell, ", "))

  -- Status Effects --
  local t = memory2.ROM:byte( 0x185009+id*0x1e)
  cell = {}
  strs = {"Raise Attack Damage", "Raise Magic Damage", "Raise HP by 25%", "Raise HP by 50%", "Raise HP by 12.5%", "Raise MP by 25%", "Raise MP by 50%", "Raise MP by 12.5%"}
  for b = 0,7 do
    if (bit.band(t, bit.lshift(1, b)) ~= 0) then
      table.insert(cell, strs[b+1])
    end
  end

  local t = memory2.ROM:byte( 0x18500b+id*0x1e)
  strs = {"Increase Steal Rate", "", "Increase Sketch", "Increase Control", "100% Hit Rate", "Halve MP Cost", "Reduce MP Cost to 1", "Raise Vigor"}
  for b = 0,7 do
    if (bit.band(t, bit.lshift(1, b)) ~= 0) then
      table.insert(cell, strs[b+1])
    end
  end
  table.insert(line, table.concat(cell, ", "))

  -- Battle Effects --
  local t = memory2.ROM:byte( 0x18500a+id*0x1e)
  cell = {}
  strs = {"Preemptive", "Prevent back/pincer", "Jump", "X-Magic", "Control", "GP Rain", "Capture", "Jump continuously"}
  for b = 0,7 do
    if (bit.band(t, bit.lshift(1, b)) ~= 0) then
      table.insert(cell, strs[b+1])
    end
  end

  local t = memory2.ROM:word( 0x18500c+id*0x1e)
  strs = {"X-Fight", "Random counterattacks", "Increases chance of evade", "Attack with two hands", "Can equip a weapon in each hand", "Can equip heavy armor", "Protect chars with low HP", "", "Casts Shell when low HP", "Casts Safe when low HP", "Casts Reflect when low HP", "EXP*2", "GP*2", "", "", "Make body cold"}
  for b = 0,15 do
    if (bit.band(t, bit.lshift(1, b)) ~= 0) then
      table.insert(cell, strs[b+1])
    end
  end
  table.insert(line, table.concat(cell, ", "))

  -- Targetting --
  local t = memory2.ROM:byte( 0x18500e+id*0x1e)
  cell = {}
  strs = {"Single", "Enemies or allies only", "All allies and enemies", "All allies or enemies", "Auto-accept", "Multiple possible", "Enemy by default", "Random"}
  for b = 0,7 do
    if (bit.band(t, bit.lshift(1, b)) ~= 0) then
      table.insert(cell, strs[b+1])
    end
  end
  table.insert(line, table.concat(cell, ", "))
  
  -- Elemental property
  local t = memory2.ROM:byte( 0x18500f+id*0x1e)
  cell = {}
  strs = {"Fire", "Ice", "Lightning", "Poison", "Wind", "Pearl", "Earth", "Water"}
  for b = 0,7 do
    if (bit.band(t, bit.lshift(1, b)) ~= 0) then
      table.insert(cell, strs[b+1])
    end
  end
  table.insert(line, table.concat(cell, ", "))
  
  -- Vigor/Speed
  local t = memory2.ROM:byte( 0x185010+id*0x1e)
  if (bit.band(t, 0x08) ~= 0) then
    table.insert(line, string.format("-%d", bit.band(t, 0x07)))
  else
    table.insert(line, string.format("+%d", bit.band(t, 0x07)))
  end
  if (bit.band(t, 0x80) ~= 0) then
    table.insert(line, string.format("-%d", bit.band(t, 0x70)/16))
  else
    table.insert(line, string.format("+%d", bit.band(t, 0x70)/16))
  end
  
  -- Stamina/Mag. Pwr.
  local t = memory2.ROM:byte( 0x185011+id*0x1e)
  if (bit.band(t, 0x08) ~= 0) then
    table.insert(line, string.format("-%d", bit.band(t, 0x07)))
  else
    table.insert(line, string.format("+%d", bit.band(t, 0x07)))
  end
  if (bit.band(t, 0x80) ~= 0) then
    table.insert(line, string.format("-%d", bit.band(t, 0x70)/16))
  else
    table.insert(line, string.format("+%d", bit.band(t, 0x70)/16))
  end
  
  local t = memory2.ROM:byte( 0x185012+id*0x1e)
  table.insert(line, string.format("%x", bit.band(t, 0x3F)))
  if (bit.band(t, 0x40) ~= 0) then
    table.insert(line, "y")
  else
    table.insert(line, "n")
  end
  if (bit.band(t, 0x80) ~= 0) then
    table.insert(line, "y")
  else
    table.insert(line, "n")
  end

  -- Weapon flags --
  local t = memory2.ROM:byte( 0x185013+id*0x1e)
  cell = {}
  strs = {"", "SwdTech", "", "", "", "Same damage from back row", "2-Hand", "Runic"}
  for b = 0,7 do
    if (bit.band(t, bit.lshift(1, b)) ~= 0) then
      table.insert(cell, strs[b+1])
    end
  end
  table.insert(line, table.concat(cell, ", "))

  -- Item flags --
  local t = memory2.ROM:byte( 0x185013+id*0x1e)
  cell = {}
  strs = {"", "Damage on Undead", "", "Affects HP", "Affects MP", "Remove Status", "Causes damage", "Max out"}
  for b = 0,7 do
    if (bit.band(t, bit.lshift(1, b)) ~= 0) then
      table.insert(cell, strs[b+1])
    end
  end
  table.insert(line, table.concat(cell, ", "))

  -- Power --
  local t = memory2.ROM:byte( 0x185014+id*0x1e)
  table.insert(line, string.format("%d", t))
  
  -- Hit Rate --
  local t = memory2.ROM:byte( 0x185015+id*0x1e)
  table.insert(line, string.format("%d", t))

  -- Elemental Absorb
  local t = memory2.ROM:byte( 0x185016+id*0x1e)
  cell = {}
  strs = {"Fire", "Ice", "Lightning", "Poison", "Wind", "Pearl", "Earth", "Water"}
  for b = 0,7 do
    if (bit.band(t, bit.lshift(1, b)) ~= 0) then
      table.insert(cell, strs[b+1])
    end
  end
  table.insert(line, table.concat(cell, ", "))
  
  -- Elemental Null
  local t = memory2.ROM:byte( 0x185017+id*0x1e)
  cell = {}
  strs = {"Fire", "Ice", "Lightning", "Poison", "Wind", "Pearl", "Earth", "Water"}
  for b = 0,7 do
    if (bit.band(t, bit.lshift(1, b)) ~= 0) then
      table.insert(cell, strs[b+1])
    end
  end
  table.insert(line, table.concat(cell, ", "))
  
  -- Elemental Weak
  local t = memory2.ROM:byte( 0x185018+id*0x1e)
  cell = {}
  strs = {"Fire", "Ice", "Lightning", "Poison", "Wind", "Pearl", "Earth", "Water"}
  for b = 0,7 do
    if (bit.band(t, bit.lshift(1, b)) ~= 0) then
      table.insert(cell, strs[b+1])
    end
  end
  table.insert(line, table.concat(cell, ", "))
  

  -- Item used --
  local t = memory2.ROM:word( 0x185015+id*0x1e)
  cell = {}
  strs = {"Dark", "Zombie", "Poison", "Magitek", "Vanish", "Imp", "Petrify", "Death", "Condemned", "Kneeling", "Blink", "Silence", "Berserk", "Confusion", "HP Drain", "Sleep"}
  for b = 0,15 do
    if (bit.band(t, bit.lshift(1, b)) ~= 0) then
      table.insert(cell, strs[b+1])
    end
  end
  
  local t = memory2.ROM:word( 0x185017+id*0x1e)
  strs = {"Dance", "Regen", "Slow", "Haste", "Stop", "Shell", "Safe", "Reflect", "Rage", "Frozen", "Protection from Death", "Morph into Esper", "Casting Spell", "Remove from Battle", "Interceptor", "Float"}
  for b = 0,15 do
    if (bit.band(t, bit.lshift(1, b)) ~= 0) then
      table.insert(cell, strs[b+1])
    end
  end
  table.insert(line, table.concat(cell, ", "))
  
  -- Equip Status --
  local t = memory2.ROM:byte( 0x185019+id*0x1e)
  cell = {}
  strs = {"Condemned", "Kneeling", "Blink", "Silence", "Berserk", "Confusion", "HP Drain", "Sleep"}
  for b = 0,15 do
    if (bit.band(t, bit.lshift(1, b)) ~= 0) then
      table.insert(cell, strs[b+1])
    end
  end
  table.insert(line, table.concat(cell, ", "))

  -- Evade --
  local t = memory2.ROM:byte( 0x18501a+id*0x1e)
  table.insert(line, string.format("%d", bit.band(t, 0x0F)))
  table.insert(line, string.format("%d", bit.band(t, 0xF0)/16))  

  -- Special attack --
  local t = memory2.ROM:byte( 0x18501b+id*0x1e)
  strs = {"None", "Steal Item", "Attack increases as HP increases", "Kill", "Cause 2x damage to humans", "Drain HP", "Drain MP", "Attack with MP", "", "Dice", "Attack increases as HP decreases", "Wind attack", "Recover HP", "Kill", "Uses MP to inflict mortal blow", "Uses more MP to inflict mortal blow"}
  table.insert(line, strs[1+bit.band(t, 0xF0)/16])
  for b = 0,15 do
    if (bit.band(t, bit.lshift(1, b)) ~= 0) then
      table.insert(cell, strs[b+1])
    end
  end

  -- Special item --
  local t = memory2.ROM:byte( 0x18501b+id*0x1e)
  strs = {"None", "Summon random esper", "Super Ball attack", "Remove char from battle", "Elixir/Megalixir", "Remove all chars from battle", "Attracts Gau on the Veldt"}
  if (t == 0xFF) then
    table.insert(line, "None")
  else
    if (t < 7) then
      table.insert(line, strs[t+1])
    else
      table.insert(line, "")
    end
  end

  -- Price --
  local t = memory2.ROM:byte( 0x18501c+id*0x1e)
  table.insert(line, string.format("%d", t))

  
  ff:write(table.concat(line,";"), "\n")
end  

 ff:close()  
  
