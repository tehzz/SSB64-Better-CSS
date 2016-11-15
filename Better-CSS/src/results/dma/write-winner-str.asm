//bass-n64
//=========================================================
//---Write "Character WINS!" String------------------------
//
// Write the winning character to the screen. This can
// probably replace the entire FFA routine...
//=========================================================

//---Hook--------------------
pushvar pc

origin 0x15352C
base 0x8013438C
scope hook_winStr {
  nonLeafStackSize(0)
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
  // get winning character
            jal   fn.results.getWinningCharacter
            nop
  // print the "{Char} WINS!" string
            jal   ffaPrintWinner
            or    a0, r0, v0
  // return
            lw    ra, 0x0014(sp)
            jr    ra
            addiu sp, sp, {StackSize}
            nop
            nop
            nop
}
pullvar pc

//---End Hook----------------

//=====ffaPrintWinner==================
//---Inputs------------------
// a0 : char index
//---Register Map------------
// s0 : char index for winner
//      &str.struct[]
//      &str.struct[char]
// t0 : strArrays.length
//      f32 winXpos.default
//      f32 str xscale (before passing on stack)
// t1 : f32 winXpos[char]
//---Stack Map---------------
// +0x10 : "a4" f32 string xscale (sw from t0)
// +0x14 : ra
// +0x18 : s0
// +0x1C : f32 winXpos[char] | winXpos.default
//---Called Routines----------
// fn.results.writeBlockText(a0: &str, a1: f32 X Pos,
//                           a2: f32 Y Pos, a3 enum <pallet>,
//                           sp+0x10: f32 X Scale )
// writeAdditionalText( a0: enum <customtext> )

scope ffaPrintWinner: {
  nonLeafStackSize(2)

  prologue:
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
            sw    s0, 0x0018(sp)
  check_length:
            ori   t0, r0, data.str.struct.size
            multu a0, t0              // start multiplying strut offset
            ori   t0, r0, data.str.length
            sltu  at, a0, t0
            bnez  at, in_range
            or    s0, r0, a0          // save charindex... maybe remove?
  defaults:
            la    a0, data.str.default.string
            lui   a1, (data.str.default.xpos >> 16) & 0xFFFF
            ori   a3, data.str.default.color
            lui   t0, (data.str.default.winXpos >> 16) & 0xFFFF
            sw    t0, 0x001C(sp)      // store default winXpos on stack
            b     writeCharStr
            lui   t0, (data.str.default.xscale >> 16) & 0xFFFF // load xscale into t0
  in_range:
  // calc &struct[char] to get base addr
            la    s0, data.str.struct.base
            mflo  at
            addu  s0, at, s0
  // write any addition text (eg, "polygon") first
            jal   writeAdditionalText
            or    a0, r0, s0
  // load string pointer and formatting properties
            lw    a0, data.str.struct.name(s0)    // a0 = &str str.array[char*4]
            lw    a1, data.str.struct.xpos(s0)    // a1 = f32  str.xpos[char*4]
            lbu   a3, data.str.struct.pallet(s0)  // a3 = u8   str.color[char]
            lw    t0, data.str.struct.xscale(s0)  // t0 = f32  str.xscale[char*4]
            lw    t1, data.str.struct.winXpos(s0) // t1 = f32  str.winXpos[char*4]
            sw    t1, 0x001C(sp)      // store winXpos to agree with default branch
  writeCharStr:
            lui   a2, 0x4334          // 180.0 in float32 for ypos
            jal   fn.results.writeBlockText
            sw    t0, 0x0010(sp)      // pass str xscale on the stack
  writeWins:
            la    a0, data.str.Wins   // a0 = &str "WINS!"
            lw    a1, 0x001C(sp)      // a1 = restore winXpos[char] | winXpos.default
            lui   a2, 0x4334          // a2 = f32 180.0
            ori   a3, r0, 0x3         // a3 = 3 = <light blue pallet>
            lui   t0, 0x3F80          // a4 = sp+0x10 = f32 1.00
            jal   fn.results.writeBlockText
            sw    t0, 0x0010(sp)
  epilogue:
            lw    ra, 0x0014(sp)
            lw    s0, 0x0018(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}

//=====writeAdditionalText=============
//---Inputs------------------
// a0 : &CharStr struct[char]
//---Register Map------------
// t0 : &CharStr struct[char]
// t1 : enum <addText::null>
// t2 : u32  struct[char].<addText> << 2
//---Stack Map---------------
// +0x10 : f32 string x scale
// +0x14 : ra
//---Called Routines---------
// fn.results.writeBlockText(&str, f32 xpos, f32 ypox, pallet, f32 xscale)

scope writeAdditionalText: {
  nonLeafStackSize(0)

  prologue:
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
            lbu   t2, data.str.struct.addText(a0)
  // if (struct[char].addText != <addText::null>)
            ori   t1, r0, data.str.addText.enum.null
            beq   t1, t2, epilogue
            or    t0, r0, a0
  // grab pointer to additional text string <&str>
            sll   t2, t2, 2
      lwAddr(a0, data.str.addText.str, t2)
  // get string writing parameters from CharStr struct
            lw    a1, data.str.struct.xpos(t0)
            lui   a2, 0x4311      // Str Y Pos = 145.0
            lbu   a3, data.str.struct.pallet(t0)
            lui   t0, 0x3F40      // Str X Scale = 0.75
            jal   fn.results.writeBlockText
            sw    t0, 0x0010(sp)
  epilogue:
            lw    ra, 0x0014(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included write-winner-str.asm\n"
}
