//bass-n64
//===getPolygonACS===============================
// return the proper alt-char-state (acs) enum for NONE
//--Inputs-----------------------------
// void
//--Output-----------------------------
// v0 : ACSenum NONE

scope getNoneACS: {
            jr    ra
            ori   v0, r0, AltState.NONE
}

// Verbose Print info [-d v on cli]
if {defined v} {
  print "Included getNoneACS.asm \n"
}
