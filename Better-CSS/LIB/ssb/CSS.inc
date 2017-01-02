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
// a3 : u32 character color
//--------------------------------
// v0 : bool character was selected by routine
//--------------------------------
constant selectCharConditional(0x8013718C)

//--------------------------------------
print "CSS Routines included!\n"
