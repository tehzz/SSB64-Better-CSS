//bass-n64
//===============================================
//-----Alternative Characters on CSS
//===============================================
//    This allows for players to use the unselectable characters
// by pressing d-pad buttons after selecting a character
// (like c-buttons for colors)
//    * D-Pad UP to select the Polygon version of a character
//    * D-Pad DOWN to select Metal Mario or Giant DK if Mario or DK
//    * D-Pad LEFT or RIGHT resets the character to normal
//
//    These changes are indicated to the players by changing the background
// behind the character, and by announce the chnange ("FIGHTING POLYGON TEAM", etc.)


//---Defs------------------------------
// AltState character ENUMs
//    Used to repressent the unselectable characters on the CSS
include "def/alt-char-state-enum.bass"
// FGM Values for ssb.playFGM()
include "def/alt-fgm.bass"

scope acs {
  // initialization state for alt-char
  // <0xFFFFFFFF = initialized>
  constant initialized(0x800002A8)
  // base address for the AltState for each player 0-3 (1 byte per player)
  constant baseAddr(initialized + 0x4)
  //constant alt_char_state(init_acs + 0x4)
}
//---End Defs---------------------------


// grab origin before adding data for DMA size calcs
evaluate assembledSize(origin())

//---.data-----------------------------
align(4)
scope data {
  // Custom CI-4 Pallets for Player Panel Image
  include "data/custom-pallets.bass"
}
//---end .data-------------------------

//--.text------------------------------
scope text {
  align(4)
//--Replacement on-ROM Routines---

  // void css.updatePlayerPanelPallet( *struct?, u8 Player, u8 PlayerState )
  include "text/replace_cssPalletChange.asm"

//--Full, Callable Routines-------

  // void initAltState()
  include "text/initAltState.asm"
  // ACSenum getACS( player )
  include "text/getACS.asm"
  // u16 getCharFGM( ACSenum, character )
  include "text/getCharFGM.asm"
  // ACSenum getNoneACS()
  include "text/getNoneACS.asm"
  // ACSenum getPolygonACS( character )
  include "text/getPolygonACS.asm"
  // ACSenum getSpecialACS( character )
  include "text/getSpecialACS.asm"
  // void setACS( player, ACSenum )
  include "text/setACS.asm"
  // bool setACSandAnnounce( player, ACSenum, character )
  include "text/setACSandAnnounce.asm"
  // void wrapUpdatePallet( player )
  include "text/wrapUpdatePallet.asm"

  // void resetAltState(u32 player-index)
  // void closePanelResetState(u32 player-index)
  // void pickUpTokenResetState(u32 player-index, u32 token-player-index)
  include "text/reset-state-fns.asm"

//--Incomplete ASM (Side Effects)------

  // Update character value(s) within CSS_playerData to match ACS
  include "text/resetCharIndex.asm"
  // D-PAD to change alt character state
  include "text/dpad-handler.asm"
  // Going to CSS from SSS, restore legal, non-crashing character
  include "text/restore-legal-char-css.asm"
  // When hitting "B" to pick up a token, reset alt-char-state
  include "text/b-pick-up-handler.asm"

}
//---end .text-------------------------

// Verbose Print info [-d v on cli]
// calculate the total size of the assembled routine
evaluate assembledSize(origin() - {assembledSize})

if {defined v} {
  print "\nIncluded css_alt-chara.asm!\n"
  print "Compiled Size: 0x"; printHex({assembledSize}); print " bytes\n\n"
}
