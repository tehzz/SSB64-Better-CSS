//bass-n64
//========================================
//-----Hack Info
//========================================
//    This allows for players to use the unselectable characters
// by pressing d-pad buttons after selecting a character
// (like c-buttons for colors)
//    * D-Pad UP to select the Polygon version of a character
//    * D-Pad DOWN to select Metal Mario or Giant DK if Mario or DK
//    * D-Pad LEFT or RIGHT resets the character to normal
//
//    These changes are indicated to the players by changing the background
// behind the character, and by announce the chnange ("FIGHTING POLYGON TEAM", etc.)
//    It also includes code to stop the game from crashing
// on the CSS or the results if using an uselectable character
//----requires--------
// "LIB/N64defs.inc", bass macros, ssbFuncs, cssFuncs
// This the DMA'd stuff for the hack

//--Defs---------------------
//grab current origin for DMA size calcs
evaluate assembledSize(origin())
// AltState character ENUMs
//    Used to repressent the unselectable characters on the CSS
include "inc/alt-char-state-enum.bass"
// FGM Values for a0 for ssb.playFGM()
// Regular Character name will just use the built-in table
scope FGM {
  constant MM(0x1CE)
  constant GDK(0x1E9)
  constant FPT(0x1E2)
}

//---------------------------
// .data section
// ensure word alignment for addressing
align(4)
// Custom Pallets
include "dma/custom-pallets.bass"
align(4)
// the AltState for each player 0-3
alt_char_state: {
  db 0, 0, 0, 0
}
align(4)

//---------------------------
// .text assemble sections
//-----------------
// Incomplete ASM:
//    These aren't callable routines

// Use D-PAD to change alt character state
// scoped name : "dpad_alt_char_state"
include "dma/dpad-handler.asm"

// Going to CSS from SSS, restore legal, non-crashing character
// scoped name : "restore_legal_char_CSS"
include "dma/restore-legal-char-css.asm"

// When hitting "B" to pick up a token, reset alt-char-state
// scoped name : "b_reset_state"
include "dma/b-pick-up-handler.asm"

//-----------------
// Full Routines ASM:
//    Callable routines that follow proper MIPS conventions
//    Probably not very useful to call on their own, though.

// void resetAltState(uint player-index)
// void closePanelResetState(uint player-index)
// void pickUpTokenResetState(uint player-index, uint token-player-index)
include "dma/reset-state-fns.asm"

// void changeCharIndex()
include "dma/changeCharIndex.asm"

//----end .text--------------
// Verbose Print info [-d v on cli]
// calculate the total size of the assembled routine
evaluate assembledSize(origin() - {assembledSize})

if {defined v} {
  print "\nIncluded css_alt-chara.asm!\n"
  print "Compiled Size: {assembledSize} bytes\n\n"
}
