//bass-n64
//==============================================================
//      Results Screen Routines
//
// Label Include for useful/known routines on the results screen
//==============================================================

//= void writeBlockText =============
// ROM : 0x15310C
// RAM : 0x80133F6C
//-------------------------------------
// a0 : *char str (null-terminated)
// a1 : f32  Starting X Position
// a2 : f32  Starting Y Position
// a3 : u8   Pallet Index
// sp + 0x10 : f32 String X Scale
//------------------------------------
constant writeBlockText(0x80133F6C)

//= u8 getWinningCharacter =============
// ROM : 0x153504
// RAM : 0x80134364
//-------------------------------------
// v0 : u8 winning character index
//------------------------------------
constant getWinningCharacter(0x80134364)

//= u8 getCharacterFromPlayer ============
// ROM : 0x1522E8
// RAM : 0x80133148
//-------------------------------------
// a0 : u8 player index
//-------------------------------------
// v0 : u8 character index
//-------------------------------------
constant getCharacterFromPlayer(0x80133148)

//--------------------------------------
print "Results Screen Routines included!\n"
