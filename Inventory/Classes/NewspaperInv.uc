///////////////////////////////////////////////////////////////////////////////
// NewspaperInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// A newspaper the player has because he probably picked it up.
//
// Activating it, pauses the game and brings it up
//
///////////////////////////////////////////////////////////////////////////////

class NewspaperInv extends OwnedInv;


///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
state Activated
{
	function LookAtIt()
	{
		local P2Player Player;

		Player = P2Player(P2Pawn(Owner).Controller);
		// You can only look at the newspaper if you're not zoomed in (in sniper mode)
		if (Player != None
			&& Player.DesiredFOV == Player.DefaultFOV)
		{
			TurnOffHints();	// When you use it, turn off the hints

			Player.RequestNews();
		}
	}
	function EndState()
	{
		Super.EndState();
		bAutoActivate=false;
	}
Begin:
	LookAtIt();
	GotoState('');
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	PickupClass=class'NewspaperPickup'
	Icon=Texture'HUDPack.Icons.Icon_Inv_Newspaper'
	InventoryGroup=103
	GroupOffset=55
	PowerupName="Paradise Times"
	PowerupDesc="Find out what the word is around town."
	bAutoActivate=true
	Hint1="Press %KEY_InventoryActivate% to read"
	Hint2="today's headlines. "
	}
