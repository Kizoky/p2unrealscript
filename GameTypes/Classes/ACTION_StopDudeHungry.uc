///////////////////////////////////////////////////////////////////////////////
// ACTION_StopDudeHungry.uc
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_StopDudeHungry extends P2ScriptedAction;

function bool InitActionFor(ScriptedController C)
	{
	if(AWPlayer(GetPlayer(C)) != None)
		AWPlayer(GetPlayer(C)).StopHungry();
	else
		warn(" Tried to start action without AWPlayer");

	return false;
	}

defaultproperties
{
     ActionString="Stop Dude Hungry"
}
