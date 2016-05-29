saveslot = 1
lastaddress = 0x1F63
sramaddress = 1 + lastaddress - 0x1600 + 0xA00 * (saveslot - 1)
sramend = 0xA00 * saveslot - 3

printcheck = function()
  checksum = 0
  for i=0x1600, lastaddress do
    checksum = checksum + memory2.WRAM:byte(i)
  end
  
  for j=sramaddress,sramend do
    checksum = checksum + memory2.SRAM:byte(j)
  end

  scheck = 0
  for j=0xA00 * (saveslot - 1),0xA00 * saveslot - 1 do
    scheck = scheck + memory2.SRAM:byte(j)
  end
  
  writtenchecksum = memory2.SRAM:word(sramend+1)
  gui.text(8, 420, string.format("Checksum computed %x, stored %x, computedsram %x", bit.band(checksum, 0xffff), writtenchecksum, scheck))
  
end

callback.register("paint", printcheck)
