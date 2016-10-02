//bass-n64

//---Begin Hook----------------------------------
//---------------------------
// When starting a game/going to the SSS
// change a player's character based on the alt-char-state

// Original Code:
// At 0x8013AAB0:
// jal   0x8013A8B8
// sw    t7, 0xBDA4(at)
//---------------------------
// Hook that JAL to our replacement routine
// No inputs into that routine, or into our own

pushvar pc
origin 0x138D30
base 0x8013AAB0
scope change_character {
  jal   changeCharIndex
}

pullvar pc
//---End Hook------------------------------------


// void changeCharIndex()
//-------------------
// Register Map
//-------------------
// t0 : i (= player index)
// t1 : player_struct + i*0xBC
// t2 : is char selected?
//      then-> alt-char-state
// t3 : character index
scope changeCharIndex: {
  nonLeafStackSize(0)
  constant originalRoutine(0x8013A8B8)
  constant Player_BaseAddr(0x8013BA88)

  prologue:
  subiu sp, sp, {StackSize}
  sw    ra, 0x0014(sp)

  initialization:
  or    t0, r0, r0            // t0 = i = 0
  li    t1, Player_BaseAddr   // t1 = *player_struct
  do: {
    check_for_selected_char:
    lw    t2, 0x0088(t1)        // t2 = is char selected (bool 0 | 1)
    beqz  t2, end_if            // if ( char_selected ) {
    lw    t3, 0x0048(t1)        // BD; t3 = character index
    if_true: {
      switch_alt_state: {
        li    t2, alt_char_state
        addu  t2, t0, t2          //
        lbu   t2, 0x0000(t2)      // switch (alt-char-state){
        case_NONE:
        ori   at, r0, AltState.NONE
        beq   at, t2, end_switch

        case_polygon:
        ori   at, r0, AltState.POLYGON    // DB;
        bne   at, t2, case_MM
        addiu at, t3, 0x000E          // offset char-index by 0xE to get polygon version
        b     end_switch
        sw    at, 0x0048(t1)          // set player_struct char to polgyon index

        case_MM:
        ori   at, r0, AltState.MM
        bne   at, t2, case_GDK
        ori   at, r0, 0x000D          // load MM char index
        sw    at, 0x0048(t1)          // player_struct.char = 0xD
        b     end_switch
        sw    r0, 0x004C(t1)          // player_struct.color = 0; for non-glitched stock icons

        case_GDK:
        ori   at, r0, AltState.GDK
        bne   at, t2, update_conditions // do we need this check...?
        ori   at, r0, 0x001A
        b     end_switch
        sw    at, 0x0048(t1)          // player_struct.char = 0x1A (Giant DK)
      }
      end_switch:
    }
    end_if:
  }
  update_conditions:
  addiu t0, t0, 0x1       // i++

  while:
  sltiu at, t0, 0x4       // while ( i < 4 )
  bnez  at, do
  addiu t1, t1, 0xBC      // BD; player_struct + 1 player

  original_code:
  jal   originalRoutine   // afaik, this routine has no inputs or outputs`
  nop
  epilogue:
  lw    ra, 0x0014(sp)
  jr    ra
  addiu sp, sp, {StackSize}
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included changeCharIndex.asm\n"
}
