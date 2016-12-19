//bass-n64
//===Color Cycle on the CSS======================
// Press Z or R to cycle through all colors for a
// character on the CSS
// Press L to cycle through shade!
//===============================================


//--Hook CSS Button Handler------------
// Create space to jump into custom routine from the
// character select screen button handler.

pushvar pc

scope CC_hook {
  // grab space to allow for a JAL
  // now, beqls jump -0x4 than originally coded
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

pullvar pc
//--End Hook---------------------------

//===cycle_colors======================
// Routine for processing Z/R and L inputs to cycle through
// the colors and shade. This is only active in Free-for-All
// I might want to make a hook for TEAM MODE for shade only
//--Register Map------------------
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
//--Stack Map---------------------
// + 0x14 : ra
// + 0x18 -> 0x30
//    s8, s0, s1, s2, s3, s4, t1
//--------------------------------


scope cycle_colors: {
  constant player_struct_css(0x8013BA88)
  nonLeafStackSize(7)
  prologue:
            or    at, r0, sp          // Grab our frame pointer
            subiu sp, sp, {StackSize}
  // store only s8 and s0; store others after checking for pressed buttons
            sw    s8, 0x0018(sp)
            sw    s0, 0x001C(sp)
  // load buttons state halfword and check for Z, R, or L
            or    s8, at, r0          // move frame pointer to s8
            lw    s0, 0x0024(s8)      // pointer to buttons
            lhu   s0, 0x0002(s0)      // load the halfword of pressed buttons
            andi  s0, s0, 0x2030
            beq   s0, r0, exit        // if ( not Z,R,or L ) exit
            ori   at, r0, 0x00BC

  loadParameters:
  // store other registers on stack, and calc pointer to big player struct
            sw    s1, 0x0020(sp)
            lw    s1, 0x0028(s8)      // player index [0-3]
            multu s1, at              // player * size of struct (188 [0xBC])
            sw    ra, 0x0014(sp)
            sw    s2, 0x0024(sp)
            sw    s3, 0x0028(sp)
            sw    s4, 0x002C(sp)

            la    at, player_struct_css   // base pointer for player struct
            mflo  s2                  // playerIndex * 188 [0xBC]
            addu  s2, at, s2          // offset base pointer to get the correct player struct

  checkLegalCharacter:
            lbu   s3, 0x004B(s2)      // load current character index from player struct
            ori   at, r0, 0x001C      // 0x1C is "no selected character" value
            beq   s3, at, long_exit   // if (char == 0x1C) exit
            lw    at, 0x0080(s2)      // Load bolean selected value
            beq   at, r0, long_exit   // if (!selected) exit
            lw    s4, 0x004C(s2)      // load current color

            la    t2, data.color_max_array
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
            or    s4, r0, t2          // if < 0, set to max (t2)
  checkR:
            andi  t1, s0, 0x0010
            beq   t1, r0, checkL      // if no R, goto check L
            addiu t1, r0, 0x0001      // set +1
  checkMax:
            addu  s4, s4, t1          // color + (+1)
            addiu at, t2, 0x1         // max + 1 to make slt be stle
            slt   at, s4, at          // check if s4 < at(max+1)
            bne   at, r0, checkAvail  // if <max, no need to reset
            nop
            beq   r0, r0, checkAvail  // if >=max, set to 0
            or    s4, r0, r0
  checkAvail:
  // use built-in routine to check if the current color is already in use
            sw    t1, 0x0030(sp)      // store +/- on stack
            or    a0, r0, s3          // character index to a0
            or    a1, r0, s1          // player index to a1
            jal   fn.css.colorCompare   // t2(max color) trashed
            or    a2, r0, s4          // color to a2
            beq   v0, r0, checkL      // if not matched, check for L
            lw    t1, 0x0030(sp)      // recover +/-.
  // there was a conflict; get new color and check again
            bgtz  t1, checkMax        // if(inc value > 0) checkMax
            nop
            beq   r0, r0, checkMin    // else checkMin
            nop
  checkL:
            andi  t1, s0, 0x0020      // mask for L
            beq   r0, t1, storeValues // if no L, go update the value
            lw    a2, 0x0050(s2)      // load shade
  incShade:
            addiu a2, a2, 0x0001      // shade +1
            slti  at, a2, 0x0003      // check if <2
            bne   r0, at, storeValues // if (shade >=2) shade = 0
            nop
            addu  a2, r0, r0

  storeValues:
            sw    s4, 0x004C(s2)      // store color index
            sw    a2, 0x0050(s2)      // store shade index
            lw    a0, 0x0008(s2)      // needed pointer
            jal   fn.css.updateCharacterModel
            or    a1, r0, s4          // load color to a1; shade is already a2
            jal   fn.ssb.playFGM      // play "clink" selection soundfx
            ori   a0, r0, 0x00A4

  long_exit:
  // Stack: s8, s0, s1, s2, s3, s4 starting at 0x18
            lw    ra, 0x0014(sp)
  // pop s-registers off stack except for s0 and s8
            lw    s1, 0x0020(sp)
            lw    s2, 0x0024(sp)
            lw    s3, 0x0028(sp)
            lw    s4, 0x002C(sp)
  exit:
  // pop s0 and s8 off stack
            lw    s8, 0x0018(sp)
            lw    s0, 0x001C(sp)
            addiu sp, sp, {StackSize}
  // replace the original lines of code that were replaced by hook
            lw    t1,0x0024(sp)       // replacement line 1
            jr    ra
            lw    a1,0x0028(sp)       // replacement line 2
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included cycle-colrs.asm\n"
}
