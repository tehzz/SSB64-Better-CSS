//bass-n64

//==============================================================
//      Universal Routines
//
// Label Include for "universal" routines in SSB64
// These should be callable at any time/place in the ROM
//==============================================================

// void managedDMA    [bit]
// ROM : 0x33204
// RAM : 0x80002CA0
//-------------------------------
// a0:  u32 ROM source  (unmasked ROM addr)
// a1:  u32 RAM des     (TLB'd address is okay?)
// a2:  u32 Size        (in bytes)
//-------------------------------
// This routine writes back any current data [osWriteBackD()]
// and invalidates the Dcache [osInvalDCache()],
// then it uses osEPiStartDma to perform a managed DMA into RAM
constant managedDMA(0x80002CA0)

// void playFGM
// ROM : 0x275C0
// RAM : 0x800269C0
//-------------------------------
// a0: u16 soundFx index
//-------------------------------
// This will play whatever sound effect you send to it
constant playFGM(0x800269C0)

// void playBGM
// ROM : 0x216B4
// RAM : 0x80020AB4
//-------------------------------
// a0: sound distortion effect?
// a1: background music index
//-------------------------------
// Play the indexed background track
constant playBGM(0x80020AB4)

// void loadCharacterModel
// ROM : 0x5306C
// RAM : 0x800D786C
//--------------------------------
// a0: u8 character index to load
//--------------------------------
// This loads assorted files for the character in a0 into RAM heap
constant loadCharacterModel(0x800D786C)

// u32 getRandomInt
// ROM : 0x19594
// RAM : 0x80018994
//--------------------------------
// a0 : u32 N
//--------------------------------
// Returns a random integer between 0 and N-1
constant getRandomInt(0x80018994)

//--------------------------------------
print "Univseral SSB Routines included!\n"
