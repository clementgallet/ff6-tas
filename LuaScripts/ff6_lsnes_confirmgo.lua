readyA = false
toReleaseA = false
toReleaseD = false

confirminput = function()
	if toReleaseA then
		input.set2(1, 0, 8, 0)
		toReleaseA = false
	end
	if toReleaseD then
		input.set2(1, 0, 8, 0)
		toReleaseD = false
	end
	
	if (memory2.WRAM:byte(0x001d) == 0xe2) then
		readyA = true
	end
  
	if (readyA and memory2.WRAM:byte(0x001d) == 0x00) then
		input.set2(1, 0, 8, 1)
		readyA = false
    toReleaseA = true
	end
	if (memory2.WRAM:byte(0x00e5) == 0xd8 and memory2.WRAM:byte(0x00e3) == 0x00) then
		input.set2(1, 0, 8, 1)
    toReleaseD = true
	end
end

callback.register("input", confirminput)
