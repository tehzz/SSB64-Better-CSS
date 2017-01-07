//bass-n64
//==============================================================
//      Character Select Screen Routines
//
// Label Include for useful/known routines on the CSS
// These are probably only callable when on the CSS
//==============================================================

// boolean colorCompare
// ROM : 0x1328F4
// RAM : 0x80134674
//-------------------------------
// a0:  Character Index
// a1:  Player Index
// a2:  Color Index
//----------------------
// v0: 0 | 1 [No Match | Match]
//-------------------------------
// Returns TRUE/0x1 if there is another player with
// the same character with the same color
constant colorCompare(0x80134674)

// void updateCharacterModel
// ROM : 0x64A48
// RAM : 0x800E9248
//-------------------------------
// a0:  u32 Unknown Pointer (0x8 + player struct)
// a1:  Color Index
// a2:  Shade Index
//-------------------------------
// Update the character model of player (a0) with color (a1) and shade (a2)
// Pointer might be to some model struct...
// This might be a universal routine
constant updateCharacterModel(0x800E9248)

// void updatePlayerPanelPallet
// ROM : 0x13152C
// RAM : 0x801332AC
//-------------------------------
// a0: u32 Unknown Poiner (0x18 + player struc)
// a1: Player Index [0-3]
// a2: Player State
//      [0: In-Game Human; 1: In-Game CPU; 2: Not In-game]
//-------------------------------
// Note: this doesn't actually "close" the panel with 0x2 in a2
// a1 can also be used as a "Team Index" that reuses 0, 1, and 3
constant updatePlayerPanelPallet(0x801332AC)

// bool selectCharConditional
//--------------------------------
// a0 : u32 pointer from CSS_playerData + 0x0
// a1 : u32 player index
// a2 : u32 held token
// a3 : u32 C-Button Color index || 0x4 Default
//--------------------------------
// v0 : bool character was selected by routine
//--------------------------------
// a3 == 0x4 seems to be a "default" that the routine loads
// the current displayed color, instead of setting a color
constant selectCharConditional(0x8013718C)

// u32 colorLookUpFFA
//--------------------------------
// a0 : u32 character
// a1 : u32 C-Button Direction (or, "i")
//--------------------------------
// v0 : u32 color index
//--------------------------------
constant colorLookUpFFA(0x800EC0EC)

// bool colorLookUpFFA
//--------------------------------
// a0 : u32 character
// a1 : u32 player-index
// a2 : u32 color-index
//--------------------------------
// v0 : bool color in use
//--------------------------------
constant colorInUse(0x80134674)

// void pickupToken
//--------------------------------
// a0 : u32 player index of cursor
// a1 : u32 player index of token (to be picked up)
//--------------------------------
constant pickupToken(0x8013760C)

//--------------------------------------
print "CSS Routines included!\n"
