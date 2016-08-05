//bass-n64
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

origin 0x135A24
base 0x801377A4

scope hook_pickup_own_token {
  jal   CSS.DMA.pickUpTokenResetState
}


// Original Code:
// jal   0x801377E4
// or    a0, s2, r0
//---------------------------
// This is for picking up other player's token

origin 0x135A64
base 0x801377E4

scope hook_pickup_other_token {
  jal   CSS.DMA.pickUpTokenResetState
}

print "Included hook_pick-up-token.asm\n\n"
