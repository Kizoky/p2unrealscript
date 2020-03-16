///////////////////////////////////////////////////////////////////////////////
// ACTION_StartDudeHungry.uc
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_StartDudeHungry extends P2ScriptedAction;

function bool InitActionFor(ScriptedController C)
	{
	if(DudePlayer(GetPlayer(C)) != None)
		DudePlayer(GetPlayer(C)).StartHungry();
	else
		warn(" Tried to start action without AWPlayer");

	return false;
	}

defaultproperties
{
     ActionString="Start Dude Hungry"
}
