// n64-bass
//================================================
// N64 osFunctions in SSB
//================================================
// A list of all n64 built-in / libultra routines
// in SSB NTSC-U
// For descriptions of these routines, look up
// the n64 devkit man pages
// Get other functions from LFE cod files

// void osInvalICache()
//-------------------------------
// a0:  u32 RAM vaddr
// a1:  s32 Size
//-------------------------------
origin 0x1344B0
base 0x800344B0
osInvalICache:


print "LibUltra defs included!\n\n"
