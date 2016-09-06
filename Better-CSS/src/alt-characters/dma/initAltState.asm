//bass-N64
//---------------------------
// This intializes part of the boot code
// to hold our AltState Enums array (1 word)
// there is also a word for the initialization state
//---------------------------
//===Register Map===
// t0 : init_acs
// t1 : *init_acs

align(4)
initAltState: {
  //check if alt_char_state was already initialized
  check_init:
  la    t0, init_acs
  lw    t1, 0x0000(t0)
  addiu at, at, 0xFFFF
  beq   at, t1, exit
  nop
  //if(!initialized){
  initialize:
  sw    at, 0x0000(t0)    //store 0xFFFFFFFF to show we've initialized the array
  sw    r0, 0x0004(t0)    //zero out old data
  exit:
  jr    ra
  nop
}

//-------------------------------------
// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included initAltState.asm!\n"
}
