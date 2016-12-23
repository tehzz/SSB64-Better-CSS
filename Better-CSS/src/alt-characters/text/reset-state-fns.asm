//bass-n64
//===Reset State Functions=======================
// Collection of routines to reset the alt-char-state
// of player, and update the screen accordingly
//---Begin Hooks---------------------------------
//---------------------------
// When a player token is picked up,
// reset the alt-char-state

// Original Code:
// jal   0x801377E4
// or    a0, s2, r0
//---------------------------
// Hook that JAL to our replacment routine that can reset the alt-char-state,
// and we can call that routine (which picks up the token)
// a0 : player index of cursor
// a1 : player index of token being picked up
// we only want to replace one line, the JAL
// This is for picking up your own token

pushvar pc
origin 0x135A24
base 0x801377A4

scope hook_pickup_own_token {
  jal   pickUpTokenResetState
}


// Original Code:
// jal   0x801377E4
// or    a0, s2, r0
//---------------------------
// This is for picking up other player's token

origin 0x135A64
base 0x801377E4

scope hook_pickup_other_token {
  jal   pickUpTokenResetState
}

//---------------------------
// When a player panel at the bottom of the screen is closed,
// reset the alt-char-state

// Original Code:
// jal    ssb.playFGM
// addiu  a0, r0, 0x00A7
//---------------------------
// Hook that JAL to our replacment routine that can reset the alt-char-state,
// and then play that soundfx

origin 0x1349BC
base 0x8013673C

scope hook_close_panel {
  jal   closePanelResetState
  or    a0, r0, s1            // move player index to a0, since a0 is free
}

pullvar pc
//---End Hooks-----------------------------------

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
  nonLeafStackSize(0)

  prologue:
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
  reset_alt_state:
            ori   at, r0, 0xBC
            multu at, a0                // for player_struct pointer offset
            la    t0, acs.baseAddr
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
              b     endelse
              lw    a1, 0x0000(t1)
    }
    // } else {
    endif_else: {
              or    a1, r0, a0          // move player index into a1
    }
    endelse:
  }
            lw    a0, 0x0018(t0)      // pointer to pallet image
            jal   fn.css.updatePlayerPanelPallet
            lw    a2, 0x0084(t0)      // MAN | CPU | Closed: lw a2, 0x84(s0)
  epilogue:
            lw    ra, 0x0014(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}

// void closePanelResetState( uint player-index )
// a0 : player index
//-------------------
// Register Map
//-------------------
// a0 : player index [input]
//      -> soundfx for playFGM
scope closePanelResetState: {
  nonLeafStackSize(0)

  // prologue
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
  // Set alt-state to NONE
            jal   resetAltState
            nop                     // a0 is already player index
  // Hooked Code Replacement...?
            jal   fn.ssb.playFGM       // replacement for hook-in code
            ori   a0, r0, 0x00A7
  // epilogue
            lw    ra, 0x0014(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}

// void pickUpTokenResetState( uint player-index, uint token-player index )
// a0 : player index of cursor
// a1 : player index of token being picked up
//-------------------
// Register Map
//-------------------
// a0 : player index of token being picked up
// reset to input regs before calling original routine

scope pickUpTokenResetState: {
  // put into fn.css
  constant pickUpToken(0x8013760C)
  nonLeafStackSize(0)

  // prologue
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
            sw    a0, {StackSize}(sp)
            sw    a1, {StackSize}+4(sp)
  // reset the state of the player whose token is being picked up
            jal   resetAltState
            or    a0, r0, a1
  // Call css.pickUpToken function
            lw    a0, {StackSize}(sp)
            jal   pickUpToken
            lw    a1, {StackSize}+4(sp)
  // epilogue
            lw    ra, 0x0014(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}


// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included reset-state-fns.asm\n"
}
