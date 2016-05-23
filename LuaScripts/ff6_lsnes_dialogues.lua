toRelease = 0

confirminput = function()
	if toRelease == 1 then
		input.set2(1, 0, 8, 0)
		toRelease = 0
	end
	
	if (memory2.WRAM:byte(0x00d3) == 0x02) then
		input.set2(1, 0, 8, 1)
		toRelease = 1
	end
end

callback.register("input", confirminput)
