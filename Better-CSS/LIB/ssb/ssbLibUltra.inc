// n64-bass
//================================================
// N64 osFunctions in SSB
//================================================
// A list of all n64 built-in / libultra routines
// in SSB NTSC-U
// For descriptions of these routines, look up
// the n64 devkit man pages

// void osInvalICache()
// ROM : 0x1344B0
// RAM : 0x800344B0
//-------------------------------
// a0:  u32 RAM vaddr
// a1:  s32 Size
//-------------------------------
constant osInvalICache(0x800344B0)

//--LibUltra C standard functions---------------
constant memcpy(0x800343e0)
constant strlen(0x8003440c)
constant strchr(0x80034434)
constant bcopy(0x80035430)
constant bzero(0x800315b0)
constant sqrtf(0x80033510)
constant sinf(0x800303f0)
constant cosf(0x80035cd0)

//--os functions-----------------------
constant osSendMesg(0x80030000)
constant osStopThread(0x80030150)
constant osRecvMesg(0x80030210)
constant osSetIntMask(0x80030350)
constant osCreateThread(0x80031e20)
constant osVirtualToPhysical(0x80032150)
constant osWritebackDCache(0x800321d0)
constant osPiRawReadIo(0x800325b0)
constant osViBlack(0x80032860)
constant osSpTaskYield(0x80032920)
constant osViSetMode(0x80032bb0)
constant osPiRawStartDma(0x800333b0)
constant osGetCount(0x80033490)
constant osSetEventMesg(0x800334a0)
constant osContStartQuery(0x80033540)
constant osContGetQuery(0x800335c4)
constant osEPiStartDma(0x80034300)
constant osCreateMesgQueue(0x80034480)
constant osInvalICache(0x800344b0)
constant osInvalDCache(0x80034530)
constant osJamMesg(0x80034640)
constant osSetThreadPri(0x80034790)
constant osGetThreadPri(0x80034870)
constant osViSwapBuffer(0x80034890)
constant osSpTaskYielded(0x80034cd0)
constant osGetTime(0x80034d50)
constant osPiGetCmdQueue(0x80035ca0)
constant osSetTime(0x80035e40)
constant osViSetEvent(0x80035e70)
constant osMapTLBRdb(0x800362b0)
constant osYieldThread(0x80036310)
constant osDpSetNextBuffer(0x80038d30)
constant osWritebackDCacheAll(0x80039160)
constant osStartThread(0x80039190)
constant osViSetYScale(0x800392e0)
constant osViModeNtscLan1(0x8003d4b0)
constant osViModeMpalLan1(0x8003d500)



print "LibUltra defs included!\n"
