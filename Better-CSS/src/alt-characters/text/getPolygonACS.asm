//bass-n64
//===getPolygonACS===============================
// return the proper alt-char-state (acs) enum
// for polygon characters
// N.B.: char index isn't being used right now,
//       but it may be relevant in the future.
//--Inputs-----------------------------
// a0 : u32 char index
//--Output-----------------------------
// v0 : ACSenum POLYGON

scope getPolygonACS: {
            jr    ra
            ori   v0, r0, AltState.POLYGON
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included getPolygonACS.asm \n"
}
