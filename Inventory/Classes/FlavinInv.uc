///////////////////////////////////////////////////////////////////////////////
// FlavinInv
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Flavin inventory item.
//
//	Thing that's picked up in MP GrabBag games to give you super powers.
// 
///////////////////////////////////////////////////////////////////////////////

class FlavinInv extends OwnedInv;

///////////////////////////////////////////////////////////////////////////////
// Do what you want if the drop failed--most things don't care that much
///////////////////////////////////////////////////////////////////////////////
function DropFailed()
{
	// We actually want this to be sent home for absolutely assuredly being made
	FindHome(1);
}

///////////////////////////////////////////////////////////////////////////////
// Like SendHome in FlavinPickup, but it doesn't have a pickup already (becuase
// it should be in the process of being made--coming out of the player. 
// Put as many as we need back in appropriate places--don't put them
// all back in one spot.
///////////////////////////////////////////////////////////////////////////////
function FindHome(int AddAmount)
{
	local FlavinPickup fp;
	local bool bFoundHome;

	foreach DynamicActors(class'FlavinPickup', fp)
	{
		if(!fp.bDropped
			&& fp.IsInState('Sleeping'))
		{
			fp.GotoState('Pickup');
			ReduceAmount(1); // Remove them from his inventory
			bFoundHome=true;
			break;
		}
	}

	if(!bFoundHome)
		warn(self$" could not find home for me.");
}

///////////////////////////////////////////////////////////////////////////////
// Change val
///////////////////////////////////////////////////////////////////////////////
function SyncVal(int Val)
{
	local MpPawn mpn;
	local int oldval, change, i;

	mpn = MpPawn(Instigator);
	if(mpn != None)
	{
		oldval = mpn.FlavinNum;
		mpn.FlavinNum = Val;
		change = mpn.FlavinNum - oldval;
		if(change > 0)
		{
			GrabBagGame(Level.Game).ScoreBag(Instigator.Controller, change);
			for(i=0; i<change; i++)
			{
				spawn(class'FlavinClientInc',Instigator);
			}
		}
		else if(change < 0)
		{
			GrabBagGame(Level.Game).ScoreBag(Instigator.Controller, change);
			for(i=0; i<-change; i++)
			{
				spawn(class'FlavinClientDec',Instigator);
			}
		}
		// This ensures the anyone who has a bag can always be sought so people
		// don't lose their way/focus when all the bags are grabbed by other people.
		// This makes sure anyone with a bag will show up on the radar no matter what. 
		// Generally no more than 3 people ever have any bags.
		if(mpn.FlavinNum > 0)
			mpn.bAlwaysRelevant=true;
		else // turn it back off to ease network requirements. 
			mpn.bAlwaysRelevant=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Add this in
// We can send in the skin of the new types being added.
///////////////////////////////////////////////////////////////////////////////
function AddAmount(int AddThis, 
				   optional Texture NewSkin, 
				   optional StaticMesh NewMesh,
				   optional int IsTainted)
{
	Super.AddAmount(AddThis, NewSkin, NewMesh, IsTainted);
	SyncVal(Amount);
}

///////////////////////////////////////////////////////////////////////////////
// Make the amount this much
///////////////////////////////////////////////////////////////////////////////
function SetAmount(int SetThis)
{
	Super.SetAmount(SetThis);
	SyncVal(Amount);
}

///////////////////////////////////////////////////////////////////////////////
// Add this in
///////////////////////////////////////////////////////////////////////////////
function ReduceAmount(int UseAmount, 
					  optional out Texture NewSkin, 
					  optional out StaticMesh NewMesh,
					  optional out int IsTainted,
					  optional bool bNoUsedUp)
{
	Super.ReduceAmount(UseAmount, NewSkin, NewMesh, IsTainted, bNoUsedUp);
	SyncVal(Amount);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function DetachFromPawn(Pawn P)
{
	Super.DetachFromPawn(P);
	SyncVal(0);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bReplicateInstigator=true
	PickupClass=class'FlavinPickup'
	Icon=Texture'MP_Misc.MoneyBag_Icon'
	InventoryGroup=103
	GroupOffset=57
	PowerupName="Grab Bag"
	PowerupDesc="Collect enough of these to win!"
	bThrowIndividually=true
	bMustBeDropped=true
	TossVel=1200
	}
