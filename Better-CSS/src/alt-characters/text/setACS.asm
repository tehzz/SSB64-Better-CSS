//bass-n64
//===setACS======================================
// Set the ACS for player a0 with ACSenum a1
//--Inputs-----------------------------
// a0 : u32 player
// a1 : u8  ACSenum
//--Output-----------------------------
// void

scope setACS: {
            la    t0, acs.baseAddr
            addu  t0, t0, a0
            jr    ra
            sb    a1, 0x0000(t0)
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included setACS.asm \n"
}
