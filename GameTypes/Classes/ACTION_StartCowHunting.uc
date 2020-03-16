///////////////////////////////////////////////////////////////////////////////
// ACTION_StartCowHunting.uc
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_StartCowHunting extends P2ScriptedAction;

function bool InitActionFor(ScriptedController C)
	{
	if(AWPlayer(GetPlayer(C)) != None)
		AWPlayer(GetPlayer(C)).StartCowHunting();
	else
		warn(" Tried to start action without AWPlayer");

	return false;
	}

defaultproperties
{
     ActionString="Start Dude Cow Hunting"
}
