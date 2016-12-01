//bass-n64
//=========================================================
//---Generic Character Stock Iocn----------------
//
// This prevents the game from crashing when attempting
// to draw the stock icon for the polygon characters
//=========================================================

//---Begin Hook------------------------

pushvar pc
origin 0x15475C
base 0x801355BC

scope stockicon_hook {
  // first two instructions are original code
            lw    t5, 0x0000(s5)
            lw    s1, 0x0084(t5)    // pointer to character data
            jal   getStockImagePointer
            or    a0, r0, s1
  // next something to do with adding image data to a linked list.
  // basically, it "draws" the image pointed to in a1
            or    a0, r0, s6        // set up for call to 0x800CCFDC
            jal   0x800CCFDC
            or    a1, r0, v0
  // change pallet if needed (for character stock icons)
            or    a1, r0, s1
            jal   updateIconPallet
            or    a0, r0, v0        // pass pointer to image data in list
  // update colorization (?) flags (original code)
            lhu   t5, 0x0024(v0)
            and   t7, t5, s8
            ori   t8, t7, 0x1
            sh    t7, 0x0024(v0)
            sh    t8, 0x0024(v0)    // who knows why there are two "sh"

  // all code up to 0x8013560C has been replaced
  while pc() < 0x8013560C {
            nop
  }
}

pullvar pc

//---End Hook--------------------------

//===getStockImagePointer==============
// a0 -> &char_data_struct
// v0 -> &stock_icon image footer struct
//--Register Map-------------
// t0 : data.stock_icon[char]
//      &file-0x19 || **&char_stock_icon
//---------------------------
// if null, redirect to generic icon
// last dereference seems to be null, but probably should check each one
scope getStockImagePointer: {
  // Beginning of list of loaded into RAM resource files
  // first word is loade file; second word is pointer to file
  constant LoadedResFiles(0x80139C50)

  deref_char_icon:
  // the deref-chain code taken from the game
  // check for null pointers after every deref-chain
            lw    t0, 0x09C8(a0)
            beqz  t0, get_generic_icon
            lw    t0, 0x0340(t0)
            beqz  t0, get_generic_icon
            lw    v0, 0x0000(t0)        // should point to stock icon footer
            beqz  v0, get_generic_icon
            nop
  return:
            jr    ra
            nop
  get_generic_icon:
            la    t0, LoadedResFiles
            lw    t0, 0x003C(t0)        //this should point to file 0x19; make routine to check?
            b     return
            addiu v0, t0, 0x0080        //offset to polygon stock icon image footer
}

//===updateIconPallet==================
// a0 -> &image footer
// a1 -> &char_data
// v0 -> &image footer
//--Register Map-------------
// t0 : color (costume) index
// t1 : **pallet[color]
//---------------------------
scope updateIconPallet: {
  get_char_color:
            lbu   t0, 0x0010(a1)
  deref_color_pallets:
  // if there's a null pointer, do not update pallet for generic stock icon
            lw    t1, 0x09C8(a1)
            sll   t0, t0, 0x2       // color index -> word offset
            beqz  t1, return
            lw    t1, 0x0340(t1)
            beqz  t1, return
            lw    t1, 0x0004(t1)    // pointer to [&pallet]
            beqz  t1, return
            addu  t1, t1, t0        // offset array
  update_pallet:
            lw    t1, 0x0000(t1)    // &pallet
            // add one last deref check?
            sw    t1, 0x0030(a0)    // store new pallet in image footer
  return:
            jr    ra
            or    v0, r0, a0
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included generic-stock-icon.asm\n"
}
