//bass-n64
//===getUnusedColorFFA===========================
// return a color index that is not currently inuse
// for a character. If not possible, return -1
//--Inputs-----------------------------
// a0 : u32 player index
//--Output-----------------------------
// v0 : i32 character color
//---Register Map-----------------
// s0 : u32 CSS_playerData[player].character
// s1 : u32 i
//----Stack Map-------------------

// var char = CSS_playerData[player].character;
// var color, i;
// if( char != Not_Selected) {
//  for(i = 0; i < 4; i++) {
//    color = colorLookUp(char, i);
//    if( !colorInUse(char, player, color) ) return i
//  }
// }
// return false

scope getUnusedColorFFA: {
  nonLeafStackSize(2)
  constant CSS_playerData(0x8013BA88)
  constant Not_Selected(0x1C)

  // prologue
            subiu sp, sp, {StackSize}
            ori   at, r0, 0xBC
            multu at, a0
            sw    ra, 0x0014(sp)
            sw    s0, 0x0018(sp)
            sw    s1, 0x001C(sp)
  // generate CSS_playerData pointer
            la    s0, CSS_playerData
            mflo  at
            addu  s0, at, s0
  // load currently active character for player a0
            lw    s0, 0x0048(s0)
  // check for not-selected character
            ori   at, r0, Not_Selected
            beq   at, s0, return_neg1
            sw    a0, {StackSize} + 0 (sp)  // Save player on caller's stack
  // Initialize for-loop
            or    s1, r0, r0          // i = 0;
  for_loop_body:
    // convert i to character specific C-button-color
            or    a0, r0, s0
            jal   fn.css.colorLookUpFFA
            or    a1, r0, s1
    // check if color is in use
            or    a0, r0, s0
            lw    a1, {StackSize} + 0 (sp)
            jal   fn.css.colorInUse
            or    a2, r0, v0          // color returned from colorLookUpFFA
    // if color is in use, continue loop until a color not in use is found
            bnez  v0, loop_afterword
            nop
    // else, return the i value that found the unused color
            b     epilogue
            or    v0, r0, s1
  loop_afterword:
  // i++ and compare
            addiu s1, s1, 0x1
            sltiu at, s1, 0x4
            bnez  at, for_loop_body
  return_neg1:
            addiu v0, r0, -1          // in branch delay
  epilogue:
            lw    ra, 0x0014(sp)
            lw    s0, 0x0018(sp)
            lw    s1, 0x001C(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included getUnusedColorFFA.asm\n"
}
