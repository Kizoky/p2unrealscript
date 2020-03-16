///////////////////////////////////////////////////////////////////////////////
// ACTION_StealPlayerInventory
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
//
// Steals one or more player inventory items and adds it to the "robbed list"
// IMPORTANT: Player must be in possession of his pawn or this will not work.
// Recommend putting it in a ScriptedAction that triggers immediately before
// or after the matinee.
///////////////////////////////////////////////////////////////////////////////
class ACTION_StealPlayerInventory extends P2ScriptedAction;

var(Action) array< class<Inventory> > ItemsToSteal;					// Classes of Inventory to take from the player.
var(Action) bool bStealEverything;									// If true, takes everything instead of the ItemsToSteal list.
var(Action) bool bRemovePickupsFromVolume;							// If true, also removes any loose pickups in Volume(s)
var(Action) name VolumeTag;											// Tag of Volume(s) to remove loose pickups from.

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool InitActionFor(ScriptedController C)
{
	local P2Player p2p;
	local int i;
	local Pickup Pick;
	local Volume V;
	
	p2p = GetPlayer(C);
		
	// Steal ALL the things!
	if (bStealEverything)
		p2p.PlayerGotRobbed(None, true);
	else
	{
		// Steal SOME of the things!
		for (i = 0; i < ItemsToSteal.Length; i++)
			p2p.PlayerGotRobbed(ItemsToSteal[i]);
	}
	
	// Remove pickups in a volume
	if (bRemovePickupsFromVolume)
	{
		foreach C.AllActors(class'Volume', V, VolumeTag)
			foreach V.TouchingActors(class'Pickup', Pick)
				Pick.Destroy();			
	}
	return false;
}
