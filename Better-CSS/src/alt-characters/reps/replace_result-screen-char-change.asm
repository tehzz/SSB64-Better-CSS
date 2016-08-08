//bass-n64

// Jump where the result screen loads the character bytes
// and change that byte back to a legal (<0xB), non-crashing character
//---------------------------
// Original Code
//-----------------
// RAM : 0x80131C30
// addiu  at, r0, 0x3C
// lbu    s4, 0x0023(v0)    // load char byte
// divu   t7, at
// sll    t4, s2, 0x0002
//-----------------
// Jump out at the addiu instruction, so the lbu is in the BD
// --------------------------
// Register Map
//-----------------
// v0 : Player Info Global Pointer (800A4D08 + i*0x74)
// s4 : Character Index
// at : Comparison check values

scope result_screen {
  origin 0x150DD0
  base 0x80131C30
  scope jump_out: {
    j     replace_illegal_char
  }

  origin 0x158470
  base 0x801392D0
  scope replace_illegal_char: {
    legality:
    sltiu at, s4, 0x0C      // I think this only runs when there's a character
    bnez  at, return        // to store, so don't have to check for 0x1C..?

    mm_check:
    ori   at, r0, 0x0D      // BD;
    beq   at, s4, mm_restore

    gdk_check:
    ori   at, r0, 0x1A      // BD;
    beq   at, s4, gdk_restore
    nop

    polygon_restore:
    subiu s4, s4, 0x000E    // substract 0xE to get regular verison of the character

    return:
    addiu at, r0, 0x003C    // Original Code Line
    j     jump_out + 0x8    // jump back two instructions later than our jumpout addr
    sb    s4, 0x0023(v0)    // store restored character index

    mm_restore:
    b     return
    or    s4, r0, r0        // char = mario

    gdk_restore:
    b     return
    ori   s4, r0, 0x0002    // char = donkey kong
  }
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included replace_result-screen-char-change.asm\n"
}
// Should we check size...?
// Empty space in ROM goes to ~0x158520 (technically + 0xC, but...)
