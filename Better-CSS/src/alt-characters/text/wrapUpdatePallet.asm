//bass-n64
//=== wrapUpdatePallet ==========================
// wrap the call to css.updatePlayerPanelPallet to easily
// acount for teammode. Simple routine since css.updatePlayerPanelPallet
// does the hard work with updating pointers, etc.
//--Inputs-----------------------------
// a0 : u32 player
//--Output-----------------------------
// void
//---Register Map-----------------
// t0 : u32 pointer to CSS_playerData for player a0
// t1 : bool teamMode
//      u32 teamPalletArray[player.team]
//--------------------------------

scope wrapUpdatePallet: {
  nonLeafStackSize(0)
  constant CSS_playerData(0x8013BA88)
  constant CSS_teamModeBool(0x8013BDA8)
  constant CSS_teamPalletArrary(0x8013B7D8)

  // prologue
            ori   at, r0, 0xBC
            multu at, a0
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
  // generate CSS_playerData pointer
            la    t0, CSS_playerData
            mflo  at
            addu  t0, at, t0
  // check if teammode is on
      lwAddr(t1, CSS_teamModeBool, 0)
            beqz  t1, else_notTeamMode
  // if team mode is on
            lw    at, 0x0040(t0)      // current team for player a0
            la    t1, CSS_teamPalletArrary
            sll   at, at, 0x2
            addu  t1, at, t1          // offset teamPalletArray
            b     call_updatePlayerPanelPallet
            lw    a1, 0x0000(t1)      // teamPalletArray[player.team]
  else_notTeamMode:
            or    a1, r0, a0          // move player index to a1
  call_updatePlayerPanelPallet:
            lw    a0, 0x0018(t0)      // some pointer in the player struct
            jal   fn.css.updatePlayerPanelPallet
            lw    a2, 0x0084(t0)      // player.panelState
  // epilogue
            lw    ra, 0x0014(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included wrapUpdatePallet.asm \n"
}
