//bass-n64
//=========================================================
//---Write "Character WINS!" String------------------------
//
// Write the winning character to the screen. This can
// probably replace the entire FFA routine...
//=========================================================

//---Hook--------------------
pushvar pc

origin 0x15352C
base 0x8013438C
scope hook_winStr {
  nonLeafStackSize(0)
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
  // get winning character
            jal   fn.results.getWinningCharacter
            nop
  // print the "{Char} WINS!" string
            jal   ffaPrintWinner
            or    a0, r0, v0
  // return
            lw    ra, 0x0014(sp)
            jr    ra
            addiu sp, sp, {StackSize}
            nop
  // Zero out rest of the original function
  while pc() <= 0x8013447C {
    nop
  }
}
pullvar pc

//---End Hook----------------

//=== void ffaPrintWinner(u32 character ) ======================================
//--- Inputs -------------------------------------------------------------------
// a0 : u32 char index
//--- Register Map -------------------------------------------------------------
// s0 : *CharInfo struct for winning character
//--- Stack Map ----------------------------------------------------------------
// +0x10 <- "a4" f32 string xscale (sw from t0)
// +0x14 <- ra
// +0x18 <- s0
// +0x1C
//--- Called Routines ----------------------------------------------------------
// void colorWrapper(a0: &str, a1: f32 X Pos,
//                   a2: f32 Y Pos, a3 enum <pallet>,
//                   sp+0x10: f32 X Scale )
// void writeAdditionalText( *CharInfo a0 )
//==============================================================================

scope ffaPrintWinner: {
  nonLeafStackSize(1)

  prologue:
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
            sw    s0, 0x0018(sp)

  get_CharInfo:
            jal   getCharInfoPtr
            nop
            or    s0, r0, v0          // save pointer to CharInfo struct
  write_AddText_str:
            jal   writeAdditionalText   //void writeAdditionalText(*CharInfo a0)
            or    a0, r0, s0

  write_base_str:
            lw    at, data.CharInfo.name.x_scale (s0)
            lw    a0, data.CharInfo.name.base_str (s0)
            sw    at, 0x0010(sp)        // pass f32 string xscale on stack
            lw    a1, data.CharInfo.name.x_pos (s0)
            lw    a2, data.CharInfo.name.y_pos (s0)
            jal   colorWrapper
            lbu   a3, data.CharInfo.name.pallet (s0)

  write_wins_str:
            la    a0, data.str.Wins
            lw    a1, data.CharInfo.name.win_x_pos (s0)
            lw    a2, data.CharInfo.name.win_y_pos (s0)
            ori   a3, r0, data.Pallet.lightBlue
            lui   at, 0x3F80          // 0x3F800000 = 1.00f32 for x-scale
            jal   colorWrapper
            sw    at, 0x0010(sp)

  epilogue:
            lw    ra, 0x0014(sp)
            lw    s0, 0x0018(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}

//=== void writeAdditionalText(*CharInfo a0) ===================================
//  Take a pointer to a CharInfo struct and write the text described by the
// addText field.
//--- Inputs -------------------------------------------------------------------
// a0 : *CharInfo
//--- Register Map -------------------------------------------------------------
// t0 : *CharInfo
// t1 : u8  enum AddText
// t2 : f32 35.0
//-- FP Registers --------------------------------
// f4 : f32 base string x position
//      f32 base - lineHeight
// f6 : f32 lineHeight
//--- Stack Map ----------------------------------------------------------------
// +0x10 : f32 string x scale (for called routine)
// +0x14 : ra
//--- Called Routines ----------------------------------------------------------
// colorWrapper(*char a0, f32 a1 xpos, f32 a2 ypox,
//              u8 Pallet a3, f32 sp+10 xscale)
//==============================================================================

scope writeAdditionalText: {
  nonLeafStackSize(0)
  constant lineHeight(0x42180000) // 38.0f32

  prologue:
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
  check_if_null:
            or    t0, r0, a0          // Move *CharInfo out of a0
            lbu   t1, data.CharInfo.name.addText (t0)
            ori   at, r0, data.AddText.null
            beq   t1, at, epilogue

  calc_y_position:
            li    t2, lineHeight      // lds
            lwc1  f4, data.CharInfo.name.y_pos (t0)
            mtc1  t2, f6
            sub.s f4, f4, f6
            mfc1  a2, f4              // y position as f32
  deref_addText_enum:
            sll   t1, t1, 0x2         // put offset in terms of words
          lwAddr(a0, data.addTextArr, t1) // pointer to addtional text string
  write_string:
            lw    a1, data.CharInfo.name.add_x_pos (t0)
            lbu   a3, data.CharInfo.name.pallet (t0)
            lui   at, 0x3F40          // 0.75f32
            jal   colorWrapper
            sw    at, 0x0010(sp)

  epilogue:
            lw    ra, 0x0014(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}

//=== colorWrapper(*char a0, f32 a1, f32 a2, u8 enum a3, f32 sp + 10) ==========
//  This routine can add additional pallets to the writeBlockText routine
// by switching out a defaul pallet for a custom pallet
//--- Inputs -------------------------------------------------------------------
// a0 : *char string to write
// a1 : f32 x position
// a2 : f32 y position
// a3 : enum Pallet
// sp + 0x10 : f32 x scale
//--- Register Map -------------------------------------------------------------
// t0 : f32 string x scale from input
//      &additionalPallet -> *&additionalPallet
// t1 : pallet - 0x5
// t2 : location to load original/store custom pallet
// s0 : &text_pallet[]
// s1 : text_pallet[0x2] (green)
//---Stack Map------------------------------------------------------------------
// +0x10 : f32 string x scale
// +0x14 : ra
// +0x18 : s0
// +0x1C : s1
//---Called Routines------------------------------------------------------------
// fn.results.writeBlockText(*char a0, f32 a1 xpos, f32 a2 ypox,
//                           Pallet a3, f32 sp+10 xscale)
//==============================================================================

scope colorWrapper: {
  nonLeafStackSize(2)
  constant defaultPalletArray(0x80139494)

  prologue:
            lw    t0, 0x0010(sp)      // restore f32 string x scale from input
            subiu sp, sp, {StackSize}
            sw    ra, 0x0014(sp)
            sw    t0, 0x0010(sp)      // for calling writeBlockText
  check_replaced_pallet:
    // Enum values below begin_custom are already useable
            sltiu at, a3, data.custom_pallets.begin_custom
            bnez  at, no_pallet_change
            subiu t1, a3, data.custom_pallets.begin_custom
  pallet_change:
            sw    s0, 0x0018(sp)
            sw    s1, 0x001C(sp)
            la    s0, defaultPalletArray
            lw    s1, 0x000C(s0)      // save original color for pallet 0x2 (6*2)
            sll   t1, t1, 0x2         // shift custom pallet color into words
        lwAddr(t0, data.custom_pallets.arr, t1)  // load custom pallet color
            sw    t0, 0x000C(s0)      // store custom pallet
            jal   fn.results.writeBlockText
            ori   a3, r0, 0x2         // use the custom pallet
  restore_original_pallet:
            sw    s1, 0x000C(s0)
            lw    s0, 0x0018(sp)
            b     epilogue
            lw    s1, 0x001C(sp)
  no_pallet_change:
            jal   fn.results.writeBlockText
            nop
  epilogue:
            lw    ra, 0x0014(sp)
            jr    ra
            addiu sp, sp, {StackSize}
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included write-winner-str.asm\n"
}
