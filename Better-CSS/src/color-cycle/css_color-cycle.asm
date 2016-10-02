//bass-n64
//
//---Color Cycle on the CSS----------------------
// Press Z or R to cycle through all colors for a character on the CSS
// Press L to cycle through shade!
//
//-----requires (from main file; put in otherwise)
// ssbFuncs
// cssFuncs
//
//-----Register Map
//  s8: frame pointer ()
//      -> save sp before sub
//  s0: button pointer
//      -> button state
//      -> button state masked for Z,R,L only
//  s1: player index        [0-3]
//  s2: player data pointer [0x8013BA88 + 0xBC * s1]
//  s3: character index     [0-0xB]
//  s4: character color     [0-varies]
//
//  a2: shade (don't allocate until checkL) [0-2]
//
//  t1: temp 1
//  t2: max color index
//----------------------------------

//---Hook--------------------
// Routine is designed to be
// DMA'd, so ROM/RAM addresses are
// given by other code. For hook, save
// those ROM/RAM addrs and restore after

print "Origin/Base/PC before push in css_color-cycle:\n"
print "0x"; printHex(origin()); print "\n"
print "0x"; printHex(base()); print "\n"
print "0x"; printHex(pc()); print "\n"

pushvar pc

print "Origin/Base/PC after push in css_color-cycle:\n"
print "0x"; printHex(origin()); print "\n"
print "0x"; printHex(base()); print "\n"
print "0x"; printHex(pc()); print "\n"

scope CC_hook {
  // grab space to allow for a JAL
  // during the FFA c-button handler
  origin 0x136890
  base 0x80138610
  beql  t7, r0, cc_jump

  origin 0x1368B0
  base 0x80138630
  beql  t8, r0, cc_jump

  // the jump to our DMA'd cycle colors routine
  origin 0x1368C0
  base 0x80138640
  cc_jump:
  jal   cycle_colors
  nop
}

print "Origin/Base/PC before pull in css_color-cycle:\n"
print "0x"; printHex(origin()); print "\n"
print "0x"; printHex(base()); print "\n"
print "0x"; printHex(pc()); print "\n"

pullvar pc

print "Origin/Base/PC after pull in css_color-cycle:\n"
print "0x"; printHex(origin()); print "\n"
print "0x"; printHex(base()); print "\n"
print "0x"; printHex(pc()); print "\n"

//---End Hook----------------

//---DMA'd Routine-----------
//--debug info----------
// used for printing size of assembled routine
evaluate assembledSize(origin())

//--.data section-------
// the max color index for each character
// array is by character index

color_max_array:
db 0x04, 0x03, 0x04, 0x04
db 0x03, 0x03, 0x05, 0x05
db 0x04, 0x04, 0x05, 0x03
// space and ensure PC alignment
fill 4, 0
align(4)

//--end .data section--------

// the actual routine for processing Z/R and L inputs to cycle through
// the colors and shade. This is only active in Free-for-All
// I might want to make a hook for TEAM MODE for shade only
scope cycle_colors: {
  constant stack_size(0x30)

  or    at, r0, sp           // Grab our frame pointer
  subiu sp, sp, stack_size   // 8 words [28 bytes] + 0xC for bad routines
  // stores s8, s0, ra, s1, s2, s3, s4, t1 starting at 0xC
  sw    s8, 0x000C(sp)
  sw  s0, 0x0010(sp)
  //load buttons
  or    s8, at, r0           // move frame pointer to s8
  lw    s0, 0x0024(s8)       // pointer to buttons
  lhu   s0, 0x0002(s0)       // load the halfword of pressed buttons
  andi  s0, s0, 0x2030
  beq   s0, r0, exit         // check for Z,R,or L
  ori   at, r0, 0x00BC

  loadParameters:
  sw    s1, 0x0018(sp)
  lw    s1, 0x0028(s8)      // player index [0-3]
  multu s1, at              // playerIndex * 188 [0xBC]
  sw    ra, 0x0014(sp)
  sw    s2, 0x001C(sp)
  sw    s3, 0x0020(sp)
  sw    s4, 0x0024(sp)

  lui   at, 0x8013
  ori   at, at, 0xBA88      // base pointer for player struct
  mflo  s2                  // playerIndex * 188 [0xBC]
  addu  s2, at, s2          // offset base pointer to get the correct player struct

  checkLegalCharacter:
  lbu   s3, 0x004B(s2)      // load character index
  ori   at, r0, 0x001C      // 0x1C is "no selected character" value
  beq   s3, at, long_exit   // IF character index == 0x1C, do nothing
  lw    at, 0x0080(s2)      // Load selected character address

  beq   at, r0, long_exit   // if 0, no selected character; do nothing
  lw    s4, 0x004C(s2)      // load current color

  li    t2, color_max_array   // get array base pointer
  //pseudo-instruction
  addu  t2, s3, t2           // offset by character index
  lbu   t2, 0x0000(t2)       // get max color value for this character

  checkZ:
  andi  t1, s0, 0x2000      // check for Z
  beq   t1, r0, checkR      // if no Z, goto check R
  addiu t1, r0, 0xFFFF      // set -1

  checkMin:
  addu  s4, s4, t1          // color + (-1)
  bgez  s4, checkAvail      // if >=0, no need to reset
  nop
  beq   r0, r0, checkAvail
  or    s4, r0, t2          // if <0, set to max (t2)


  checkR:
  andi  t1, s0, 0x0010
  beq   t1, r0, checkL      // if no R, goto check L
  addiu t1, r0, 0x0001      // set +1

  checkMax:
  addu  s4, s4, t1         // color + (+1)
  addiu at, t2, 0x1        // max + 1 to make slt be stle
  slt   at, s4, at         // check if s4 < at(max+1)
  bne   at, r0, checkAvail   // if <max, no need to reset
  nop
  beq   r0, r0, checkAvail   // if >=max, set to 0
  or    s4, r0, r0

  checkAvail:
  sw    t1, 0x0028(sp)     // store +/- on stack
  or    a0, r0, s3         // character index to a0
  or    a1, r0, s1         // player index to a1
  jal   fn.css.colorCompare   // call routine; t2(max color) trashed
  or    a2, r0, s4         // color to a2
  beq   v0, r0, checkL     // if not matched, check for L
  lw    t1, 0x0028(sp)     //  recover +/-.
  bgtz  t1, checkMax       // we had a match conflict, get next color
  nop                      // pos inc value = check max, neg inc value = check min
  beq   r0, r0, checkMin
  nop

  checkL:
  andi  t1, s0, 0x0020       // mask for L
  beq   r0, t1, storeValues  // if no L, go update the value
  lw    a2, 0x0050(s2)       // load shade
  incShade:
  addiu a2, a2, 0x0001       // shade +1
  slti  at, a2, 0x0003       // check if <2
  bne   r0, at, storeValues  // if <2, go on
  nop
  addu  a2, r0, r0           // else, set shade to 0 then go on

  storeValues:
  sw    s4, 0x004C(s2)      // store color index
  sw    a2, 0x0050(s2)      // store shade index
  lw    a0, 0x0008(s2)      // needed pointer
  jal   fn.css.updateCharacterModel
  or    a1, r0, s4          // load color to a1; shade is already a2
  jal   fn.ssb.playFGM      // play "clink" selection soundfx
  ori   a0, r0, 0x00A4

  long_exit:
  // Stack: s8, s0, ra, s1, s2, s3, s4, t1 starting at 0xC
  lw    ra, 0x0014(sp)
  lw    s1, 0x0018(sp)      //pop s-registers off stack except for s0 and s8
  lw    s2, 0x001C(sp)
  lw    s3, 0x0020(sp)
  lw    s4, 0x0024(sp)

  exit:
  lw    s0, 0x0010(sp)      //pop s0 and s8 off stack
  lw    s8, 0x000C(sp)
  addiu sp, sp, stack_size
  lw    t1,0x0024(sp)       // replacement line 1
  jr    ra                  // return to original code flow
  lw    a1,0x0028(sp)       // replacement line 2
}

//---End DMA'd Routine-------

// calculate the total size of the assembled routine
evaluate assembledSize(origin() - {assembledSize})
// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included css_color-cycle.asm\n"
  print "Compiled Size: {assembledSize} bytes\n\n"
}
