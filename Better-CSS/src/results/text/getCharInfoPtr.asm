//bass-n64
//=== *CharInfo getCharInfoPtr(u32 charIndex) ==================================
// Return a pointer to a character's CharInfo struct. That struct contains
// everything needed for the Results screen
//-- Inputs and Outputs --------------------------------------------------------
// a0 : u32 character index
//-------------------------------------
// v0 : *CharInfo
//--- Register Map -------------------------------------------------------------
//  v0 : charInfoArray[]
//       charInfoArray[charIndex]
//==============================================================================

// Routine is currently writen for sizeof CharInfo == 0x40; Error if not

if (data.CharInfo.sizeof != 0x40) {
  error "CharInfo Struct size has changed! Update getCharInfoPtr.asm\n\n"
}

scope getCharInfoPtr: {
  check_char_in_range:
            sltiu at, a0, data.charInfoArray.length
            beqz  at, char_out_of_range
            sll   at, a0, 0x6         // index * 0x40
  char_in_range:
            la    v0, data.charInfoArray
            b     return
            add   v0, at, v0
  char_out_of_range:
            la    v0, data.charInfoDefault
  return:
            jr    ra
            nop
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included getCharInfoPtr.asm\n"
}
