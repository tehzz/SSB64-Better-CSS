//bass-n64
//=========================================================
//---Load Only Active Characters on the Results Screen-----
//
// This code will load the <=4 actually used characters
// (legal or "illegal") on the results screen,
// instead of loading all of the legal 12 (Mario to Ness)
// Other codes are necessary to make the illegal character
// work/not-crash, though.
//=========================================================

//---Begin Hook------------------------
//---Original Code-----------
// At ROM 0x157DF8:
// 80138C58    or    s0, s0, 0x0001
//       5C    jal   0x800D786C
//       60    or    a0, s0, r0
//       64    addiu s0, s0, 0x0001
//       68    slti  at, s0, 0x000C
//       6C    bnez  at, 0x80138C5C
//       70    nop
//---------------------------
// All of that can be replaced with a
// jump to our routine

pushvar pc
origin 0x157DF8
base 0x80138C58

{
  jal   loadUsedChars
  nop
  b     0x80138C70
  nop
  // nop everything after the routine
  while pc() <= 0x80138C70 {
    nop
  }
}

pullvar pc
//---End Hook--------------------------

//---Begin loadUsedChars Routine-------
// Replace Giant DK (0x1A) in the char LUT with DK (0x2), since
// the only difference for us will be the size, and DK has more animations
// Then, load the <= 4 used characters
//
//---Register Map------------
// s0 : <i> loop value
// s1 : player[i] global struct addr
// t0 : charLUT Base Addr
//      player state (<0, 1, 2> ; <MAN, CPU, NONE>)
// t1 : DK struct pointer
// a0 : player character (for ssb.loadCharacterModel)
//
//---Pseuo-Code--------------
// charLUT[GDK] = charLUT[DK];
// for (i = 0; i < 4; i++) {
//   if(player[i].ingame_state == not_ingame) continue
//   loadCharacterModel(player[i].character)
// }
//
//---Defs--------------------
scope Player_Global {
  constant base_addr(0x800A4D28)
  constant struct_size(0x74)
  // level is byte 0
  // handicap is byte 1
  // ingame is byte 2
  // character is byte 3 [0,1,2,3]
  // team is byte 4
  // team is byte 5..?
  // color is byte 6
}

constant charLUT_base_addr(0x80116E10)
//---End Defs----------------

scope loadUsedChars: {
    nonLeafStackSize(2)               // for s0, s1

prologue:
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
            sw    s0, 0x0018(sp)
            sw    s1, 0x001C(sp)
// replace GDK pointer with DK pointer
            la    t0, charLUT_base_addr
            lw    t1, 0x2 << 2(t0)    // 0x2 is DK; convert to words to load pointer
            sw    t1, 0x1A << 2(t0)   // store at Giant DK location
// initialize loop: for(i = 0; i < 4; i++, player++)
loop_init:
            or    s0, r0, r0          // i = 0
            la    s1, Player_Global.base_addr
loop_body:
            lbu   t0, 0x0002(s1)      // get player in-game state
            sltiu at, t0, 0x0002      // 0x2 = not-in-game
            beqz  at, loop_afterthought // if state = not-in-game continue
            nop
            jal   fn.ssb.loadCharacterModel
            lbu   a0, 0x0003(s1)      // get player's character
loop_afterthought:
            addiu s0, s0, 0x0001      // i++
loop_condition:
            sltiu at, s0, 0x0004
            bnez  at, loop_body       // while i < 4
            addiu s1, s1, Player_Global.struct_size // player++
epilogue:
            lw    ra, 0x0014(sp)
            lw    s0, 0x0018(sp)
            lw    s1, 0x001C(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included load-chars.asm\n"
}
