//bass-n64
//=========================================================
//---Character Model Zoom Pointers-------------------------
//
// Return in v0 a pointer to a float32 zoom value for a
// given character
//=========================================================

//---Hook--------------------
// Have 6 instructions starting at 801338EC
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

scope pointToFloat: {
            ori   t0, r0, data.char_zoom.length
            sltu  at, a2, t0
            bnez  at, in_range
            lui   v0, (data.char_zoom.default >> 16) & 0xFFFF
            b     return
            ori   v0, t0, data.char_zoom.default & 0xFFFF
  in_range:
            la    t0, data.char_zoom
            sll   t1, a2, 2
            addu  v0, t0, t1          // &char_zoom[char]
  return:
            j     zoom_hook.rejoin
            nop
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included model-zoom-floats.asm\n"
}
