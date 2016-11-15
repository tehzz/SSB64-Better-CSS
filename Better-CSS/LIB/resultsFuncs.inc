//bass-n64
//==============================================================
//      Results Screen Routines
//
// Label Include for useful/known routines on the results screen
//==============================================================

//= void Write Block Text =============
//-------------------------------------
// a0 : &str (null-terminated)
// a1 : f32  Starting X Position
// a2 : f32  Starting Y Position
// a3 : u8   Pallet Index
// sp + 0x10 : f32 String X Scale
//------------------------------------
origin 0x15310C
base 0x80133F6C
writeBlockText:

//= u8 Get Winning Character =============
//-------------------------------------
// v0 : winning character index
//------------------------------------
origin 0x153504
base 0x80134364
getWinningCharacter:

//--------------------------------------
print "Results Screen Routines included!\n\n"
