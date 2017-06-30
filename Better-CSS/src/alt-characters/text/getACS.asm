//bass-n64
//===getACS======================================
// return the active ACSenum for a player
//--Inputs-----------------------------
// a0 : u32 player index
//--Output-----------------------------
// v0 : u8  ACSenum

scope getACS: {
            la    v0, acs.baseAddr
            addu  v0, a0, v0
            jr    ra
            lbu   v0, 0x0000(v0)
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included getACS.asm \n"
}
