///////////////////////////////////////////////////////////////////////////////
// DualWieldInv
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Can of Balls or whatever
///////////////////////////////////////////////////////////////////////////////
class DualWieldInv extends OwnedInv;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var() Sound DrinkSound;				// Sound made when drinking

const WAIT_TO_START_TIME = 3.0;		// How long between activation and when dual wielding actually starts
const WAIT_TO_COMMENT_TIME = 1.0;	// How long between dual wielding starting and when the dude comments on it

///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
state Activated
{
	ignores Activate;
	
	function ChugIt()
	{
		Owner.PlaySound(DrinkSound);
	}
	
	function SugarRush()
	{
		if(P2Player(Pawn(Owner).Controller) != None)
		{
			P2Player(Pawn(Owner).Controller).BeginDualWielding();
			Amount -= 1;
		}
	}
	
	function CommentOnIt()
	{
		if(P2Player(Pawn(Owner).Controller) != None)
			P2Player(Pawn(Owner).Controller).CommentOnDualWielding();
	}
Begin:
	ChugIt();
	Sleep(WAIT_TO_START_TIME);
	SugarRush();
	Sleep(WAIT_TO_COMMENT_TIME);
	CommentOnIt();
	
	if (Amount <= 0)
	    UsedUp();

	GotoState('');
}

///////////////////////////////////////////////////////////////////////////////
// Waiting or 
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	PickupClass=class'DualWieldPickup'
	Icon=Texture'MrD_PL_Tex.HUD.Ballz_HUD'
	Hint1="Press %KEY_InventoryActivate% to double your firepower with a sugar surge!"
	DrinkSound=Sound'PL-ItemSounds.DualWield.DualWieldDrink'
	InventoryGroup=100
	GroupOffset=0
	PowerupName="Habib's Power Station"
	PowerupDesc="Doubles your penetration power for pleasing all your wives! -Habib"
}
