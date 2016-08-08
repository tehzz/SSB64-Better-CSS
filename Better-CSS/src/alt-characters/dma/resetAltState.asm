//bass-n64

// void resetAltState( uint player-index )
// a0 : player index
// Set's a players alt-char-state to NONE, and refreshs the pallet bg
//-------------------
// Register Map
//-------------------
// a0 : player index pinput]
//      -> pointer for update pallet
// a1 : player index
// a2 : MAN | CPU panel state
//
// t0 : alt_char_state base addr
//      -> + a0 to offset for player
//      then
//      *Player_Struct
// t1 : team mode checks

scope resetAltState: {
  nonLeafStackSize(0)         // Grab stack space for 0 saved regs
  prologue:
  subiu sp, sp, {StackSize}
  sw    ra, 0x0014(sp)

  reset_alt_state:
  ori   at, r0, 0xBC
  multu at, a0                // for player_struct pointer
  li    t0, alt_char_state
  ori   at, r0, AltState.NONE
  addu  t0, t0, a0            // pointer to current player alt_char_state
  sb    at, 0x0000(t0)        // set alt state to NONE

  pointer_player_struct:
  li    t0, 0x8013BA88
  mflo  at
  addu  t0, t0, at          // generate player_struct pointer

  update_pallet:
  scope if_teams {
    condition:
    lui   t1, 0x8014
    lw    t1, 0xBDA8(t1)        // team mode int (0 Off | 1 On)
    beqz  t1, endif_else        // if (team mode){ ...
    if_true: {
      lui   t1, 0x8013
      ori   t1, 0xB7D8           // teams_pallet_indicies.array
      lw    at, 0x0040(t0)       // current_team
      sll   at, at, 0x2          // current_team * 4
      addu  t1, at, t1           // a1 = t_p_i[current_team]
      b     endelse              //
      lw    a1, 0x0000(t1)      // } else {
    }
    endif_else: {
      or    a1, r0, a0          // move player index into a1
    }
    endelse:                   // }
  }
  lw    a0, 0x0018(t0)      // pointer to pallet image
  jal   fn.css.updatePlayerPanelPallet
  lw    a2, 0x0084(t0)      // MAN | CPU | Closed: lw a2, 0x84(s0)

  epilogue:
  lw    ra, 0x0014(sp)
  jr    ra
  addiu sp, sp, {StackSize}
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included resetAltState.asm\n"
}
