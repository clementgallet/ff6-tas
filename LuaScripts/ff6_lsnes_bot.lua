-- Open the log file

file = assert(io.open("event_addresses.txt", "w"))
totallag = 50

-- Make a savestate

savestatef = function(r)
	if section == 1
	then
		savestate1 = r
	else
		savestate2 = r
	end
end

callback.register("set_rewind", savestatef)
movie.unsafe_rewind()

gocount = 1 -- delay after game over message
section = 1

lagcount = 1
isrewinding = 0

-- step_savestate = 10

-- Wait for lagcount frames

frcount = gocount

fr = function()

	if (frcount == 0) and (section == 2)
	then
		movie.unsafe_rewind()
		lagcount = 1
		frcount = lagcount
		section = 3
	end


	if (frcount == 0) and (section == 1)
	then
		frcount = 615
		section = 2
	end

	-- print(frcount)
	frcount = frcount - 1
	-- if (frcount == 1) and (lagcount == step_savestate + 2)
	-- then
		-- lagcount = lagcount - step_savestate
		-- movie.unsafe_rewind()
	-- end
end

callback.register("frame", fr)




confirminput = function()
	-- print(lagcount)
	if frcount == 0 and (section == 1 or section == 3)
	then
		input.set2(1, 0, 8, 1)
		isrewinding = 0
	else
		input.set2(1, 0, 8, 0)
	end
end

callback.register("input", confirminput)


check=function()
	if isrewinding == 0
	then
		v1=memory2.WRAM:read(0x630)
		v2=memory2.WRAM:read(0x631)
		v3=memory2.WRAM:read(0x632)

		vstring=string.format("%2x%2x%2x for lag %d-%d\n",v3,v2,v1,gocount,lagcount)
		
		file:write(vstring)

		print(vstring)

		if lagcount > (totallag-gocount)
		then
			section = 1
			gocount = gocount + 1
			-- print(gocount)
			frcount = gocount
			movie.unsafe_rewind(savestate1)
			isrewinding = 1
		else
			lagcount = lagcount + 1
			-- print(lagcount)
			frcount = lagcount
			-- if lagcount > 25
			-- then file:close()
			-- end
			isrewinding = 1
			movie.unsafe_rewind(savestate2)
		end
	end
end

memory2.ROM:registerexec(0x00B8D7, check)
