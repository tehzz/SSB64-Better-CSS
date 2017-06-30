//bass-n64
//=== Reset ACS when Picking Up Token with A===============
//---Begin Hooks---------------------------------
//---------------------------
// When a player token is picked up,
// reset the alt-char-state

// Original Code:
// jal   0x8013760C
// or    a0, s2, r0
//---------------------------
// Hook that JAL to css.pickupToken to our replacment routine
// that can reset the ACS before calling css.pickupToken
// So, "pickup_token_reset" is a wrapper for css.pickupToken
//---Current Registers-------
// a0 : player index of cursor
// a1 : player index of token being picked up
// we only want to replace one line, the JAL
// This is for picking up your own token

pushvar pc
origin 0x135A24
base 0x801377A4

scope hook_pickup_own_token {
  jal   wrapPickupToken
}


// Original Code:
// jal   0x8013760C
// or    a0, s2, r0
//---------------------------
// This is for picking up other player's token

origin 0x135A64
base 0x801377E4

scope hook_pickup_other_token {
  jal   wrapPickupToken
}
pullvar pc

//---End Hooks-------------------------

//---Main Code
// a0 : u32 player index of cursor
// a1 : u32 player index of token being picked up
//-------------------
// Register Map
//-------------------
// a0 : player index of token being picked up
// reset to input regs before calling original routine

scope wrapPickupToken: {
  nonLeafStackSize(0)

  // prologue
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
            sw    a0, {StackSize}(sp)
            sw    a1, {StackSize}+4(sp)
  // reset the state of the player whose token is being picked up
            jal   resetACS
            or    a0, r0, a1
  // Call css.pickupToken
            lw    a0, {StackSize}(sp)
            jal   fn.css.pickupToken
            lw    a1, {StackSize}+4(sp)
  // epilogue
            lw    ra, 0x0014(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}


// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included pickup-token-A-reset.asm\n"
}
