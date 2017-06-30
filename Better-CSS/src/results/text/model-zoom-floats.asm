//bass-n64
//=========================================================
//---Character Model Zoom Pointers-------------------------
//
// Return in v0 a pointer to a float32 zoom value for a
// given character
//=========================================================

//---Hook--------------------
// Have 6 instructions, starting at 801338EC, that generate a pointer to a
// f32 zoom value in an array indexed by character
// character is in a2; need point to zoom float in v0
pushvar pc

origin 0x152A8C
base 0x801338EC
scope zoom_hook: {
            sw    a1, 0x0004(sp)
            sw    a3, 0x000C(sp)
            j     pointToFloat
            nop
            nop
            nop
  rejoin:     //Jump back here to continue routine once pointer is created
}
pullvar pc
//---End Hook----------------

//---Register Map
// t0 : char_zoom.length
//      &char_zoom (base)
// t1 : char-index << 2
// a2 : character index
// v0 : &char_zoom[char] || &char_zoom.default

scope pointToFloat: {
  nonLeafStackSize(0)
  get_CharInfoPtr:
            sw    a2, 0x0008(sp)
            sw    a0, 0x0000(sp)
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
            jal   getCharInfoPtr
            or    a0, r0, a2
  zoomAddr_in_v0:
            addiu v0, v0, data.CharInfo.model_zoom
  return:
            lw    ra, 0x0014(sp)
            addiu sp, sp, {StackSize}
            lw    a0, 0x0000(sp)
            lw    a1, 0x0004(sp)
            lw    a2, 0x0008(sp)
            j     zoom_hook.rejoin
            lw    a3, 0x000C(sp)
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included model-zoom-floats.asm\n"
}
