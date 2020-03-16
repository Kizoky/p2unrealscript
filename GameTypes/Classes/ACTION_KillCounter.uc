///////////////////////////////////////////////////////////////////////////////
// ACTION_KillCounter.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Starts a mission that has the player needing to kill a certain
// number of pawns. 
//
// Rest of the work is in the AWTrigger. Make pawns placed in the level
// have the event of the AWTrigger. Set trigger to CountTriggers. Each pawn that
// dies will trigger it. TimesTillTrigger will be the max to kill. If you place
// a pawnspawner, make sure all the MaxSpawned add up to TimesTillTrigger. Set the tags of
// all the spawners to the same as the AWTrigger so they will all be notified
// when a pawn dies. 
// Set the event of the AWTrigger to whatever so it starts the next movie or
// whatever to show the player he's done. The AWPlayer will turn off it's
// hud icon but nothing more when finished.
//
// Example:
//	Tom is the tag of the trigger that checks for entry and starts the whole process.
//  Tom's event is ScriptFighter. He triggers (starts up) ScriptFighter when
// the player enters Tom's collision radius.
//  
//  ScriptFighter then counts up the kills and it's KillsTriggerTag is named CowKills.
//  CowKills is the Tag of an AWTrigger. His counter is 5. When ScriptFighter has
// triggered it 5 times, it will call it's event. We'll call it MovieTime. When
// MovieTime gets called, the kill counting sequence is over and a movie or something
// else is played and the whole sequence ends. 
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_KillCounter extends P2ScriptedAction;

var(Action) name	KillsTriggerTag;	// AWTrigger tag that keeps track of our kills
var(Action) Texture HudPawnIcon;		// Icon for hud to display of pawns to kill
var(Action) bool	bPercentageDisplay;	// If true, displays as a % instead of (number)/(max)

function bool InitActionFor(ScriptedController C)
	{
	if(AWPlayer(GetPlayer(C)) != None)
		AWPlayer(GetPlayer(C)).StartKillCount(HudPawnIcon, KillsTriggerTag, bPercentageDisplay);
	else
		warn(" Tried to start action without AWPlayer");

	return false;
	}

function string GetActionString()
	{
	return ActionString$", hud icon "$HudPawnIcon$" trigger tag "$KillsTriggerTag;
	}

defaultproperties
{
     ActionString="action kill counter"
     bRequiresValidGameInfo=True
}
