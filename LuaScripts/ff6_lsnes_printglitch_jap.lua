check=function()

v1=memory2.WRAM:read(0x630)
v2=memory2.WRAM:read(0x631)
v3=memory2.WRAM:read(0x632)

vstring=string.format("%2x%2x%2x",v3,v2,v1)

print(vstring)
end

memory2.ROM:registerexec(0x00B80C, check)
