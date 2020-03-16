///////////////////////////////////////////////////////////////////////////////
// Apocalypse Weekend DudeHungry
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Complains about being hungry so player will go to fast-food joint.
//
///////////////////////////////////////////////////////////////////////////////
class DudeHungry extends DudeTalkMarker;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     WaitTime=40.000000
     WaitTimeRand=40.000000
     DudeSaying(0)=Sound'AWDialog.Dude.Dude_Starving'
     DudeSaying(1)=Sound'AWDialog.Dude.Dude_Hungry'
     DudeSaying(2)=Sound'AWDialog.Dude.Dude_NeedCrappyChinese'
     DudeSaying(3)=Sound'AWDialog.Dude.Dude_GoToRestaraunt'
}
