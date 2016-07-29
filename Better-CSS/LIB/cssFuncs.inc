//bass-n64
//==============================================================
//      Character Select Screen Routines`
//
// Label Include for useful/known routines on the CSS
// These are probably only callable when on the CSS
//==============================================================

// boolean Color Compare
//-------------------------------
// a0:  Character Index
// a1:  Player Index
// a2:  Color Index
//----------------------
// v0: 0 | 1 [No Match | Match]
//-------------------------------
// Returns TRUE/0x1 if there is another player with
// the same character with the same color
origin 0x1328F4
base 0x80134674
colorCompare:

// void Update Character Model
//-------------------------------
// a0:  u32 Unknown Pointer (0x8 + player struct)
// a1:  Color Index
// a2:  Shade Index
//-------------------------------
// Update the character model of player (a0) with color (a1) and shade (a2)
// NOTICE: This eats the top three words of the stack, so remeber to grab
// more stack space than you need
origin 0x64A48      //REPLACE!!!
base 0x800E9248
updateCharacterModel:

//--------------------------------------
print "CSS Routines included!\n\n"
