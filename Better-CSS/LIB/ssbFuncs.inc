//bass-n64

//==============================================================
//      Universal Routines
//
// Label Include for "universal" routines in SSB64
// These should be callable at any time/place in the ROM
//==============================================================

// void Managed DMA    [bit]
//-------------------------------
// a0:  ROM source  (unmasked ROM addr)
// a1:  RAM des     (TLB'd address is okay?)
// a2:  Size        (in bytes)
//-------------------------------
// This is a nice routine. It writes back any current data
// [osWriteBackD()] and invalidates the Dcache [osInvalDCache()]
// and uses osEPiStartDma to perform a managed DMA into RAM
// NOTICE: Uses two more words on the stack..
//         allocate 0x8 more than you need
origin 0x33204
base 0x80002CA0
managedDMA:

//void playFGM
//-------------------------------
// a0: soundFx index
//-------------------------------
// This will play whatever sound effect you send to it
// It eats the top word on the stack, though,
// so remeber to take 4 more bytes than you need
// (or don't store anything important at SP + 0x0000)
origin 0x275C0
base 0x800269C0
playFGM:

//void loadCharacterModel
//-------------------------------
// a0: character index to load
//-------------------------------
// This loads assort files for the character in a0
// into RAM 
origin 0x5306C
base 0x800D786C
loadCharacterModel:

//--------------------------------------
print "Univseral SSB Routines included!\n\n"
