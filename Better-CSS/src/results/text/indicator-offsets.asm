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
//--Important Regsiters/Stack Values--
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

calcIndYOffset: {
  // load pointer to Place struct, and address to "indicatorYoffsets"
            lw    v1, 0x0028(sp)
            la    t0, data.indicatorYoffsets
  // offset to load y-pos-offset for character and model position
            sll   t1, v0, 0x2
            addu  t1, t1, s0
            addu  t1, t1, t0
            lb    t1, 0x0000(t1)
  // get floats into COP1
            lwc1  f6, 0x0004(v1)      //y position base
            mtc1  t1, f4
            cvt.s.w f4, f4            // y pos offset moved and converted
  // calc point to image-footer (game code, mostly)
            lw    t2, 0x0074(s2)
  // add y-base + y-offset and store
            add.s f8, f6, f4
            j     0x80133C40          // where the jumped out routine would eventually branch
            swc1  f8, 0x005C(t2)
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included indicator-offsets.asm\n"
}
