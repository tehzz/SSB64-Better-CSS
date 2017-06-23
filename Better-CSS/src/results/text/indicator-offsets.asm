//bass-n64
//=========================================================
//---Model Player Indicator Fix----------------------------
//
// Currently, the structure used to offset the y-position
// of the player indicator triangle above a model only
// has the original 12 character. Fix.
//=========================================================

//--Hook positionModelIndicator--------

pushvar pc

scope posModelIndHook {
  //2-Player Game
  origin 0x152D08
  base 0x80133B68
            j     calcIndYOffset
            nop
  //3-Player Game
  origin 0x152D60
  base 0x80133BC0
            j     calcIndYOffset
            nop
  //4-Player Game
  origin 0x152DB8
  base 0x80133C18
            j     calcIndYOffset
            nop
}

pullvar pc

//--End Hook---------------------------

//===calcIndYOffset====================
//--Important Registers/Stack Values--
// s0 : model position index
// s1 : player index
// s2 : pointer to active image-footer data
// v0 : character index
// sp + 0x28 : Point to Place struct (+0x4 for f32 base Y offset) -> v1
//--Register Map-------------
// t0 : pointer to replacement "indicatorYoffsets" struct
// t1 : char index offset (i << 2)
// t2 : pointer to image-footer
//
// f4 : y position offset
// f6 : y position base
// f8 : y-base + y-offset
//---------------------------

scope calcIndYOffset: {
  constant utilizeOffset(0x80133C40)

  get_CharInfo:
  // save v0 + v1 to stack
            sw    v0, 0x00F0(sp)      // sp + 0xF0 is the start of one of the replaced arrays
            sw    v1, 0x00F4(sp)
            jal   getCharInfoPtr
            or    a0, r0, v0
            or    t0, r0, v0
  // restore v0 + v1
            lw    v1, 0x00F4(sp)      // is this original v1 used?
            lw    v0, 0x00F0(sp)
  get_place_struct:
            lw    v1, 0x0028(sp)
  load_y_offset_to_COP1:
            addu  t1, t0, s0          // offset *CharInfo by model position index
            lb    t1, data.CharInfo.label_offset(t1)
  calc_y_offset:
  // load to COP1 and convert
            lwc1  f6, 0x0004(v1)      // y position base (from per-player positioning struct)
            mtc1  t1, f4
            cvt.s.w f4, f4
  store_offset_into_image_footer:
            lw    t2, 0x0074(s2)
            add.s f8, f6, f4
            j     utilizeOffset
            swc1  f8, 0x005C(t2)
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included indicator-offsets.asm\n"
}
