///////////////////////////////////////////////////////////////////////////////
// ClothesInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Clothing inventory item. You're not wearing this, you have it
// folded up right now, so it's not active.
//
///////////////////////////////////////////////////////////////////////////////

class ClothesInv extends OwnedInv;

var Texture HandsTexture;	// Texture for the dudes hand's when he's wearing this outfit
							// in 1st person mode
var Texture	FootTexture;	// New skin for foot in fps mode with these clothes
var Mesh	BodyMesh;		// New mesh for the body that has these clothes on in 3rd person mode
var Texture	BodySkin;		// Skin for BodyMesh
var Mesh	HeadMesh;		// New mesh for the head that has these clothes on in 3rd person mode
var Texture	HeadSkin;		// Skin for HeadMesh
var array<Material> HudSplats;		// Array of backer images for hud categories like health and weapons.
							// This changes to different images to let you know easier, what outfit you have on.
var bool	bAllowSwap;		// If this is true, when the player uses this outfit, they'll
							// have their old one put back into their inventory 
var bool	bAllowKeep;		// If this is true, when the player changes outfits, if the
							// first one has AllowSwap set to true, then it has to check
							// this to see if it can actually put this outfit back
var bool	bIsCopUniform;	// If true, game considers this a police outfit.							
var float	WaitTime;		// Time before actual change (in case dude is talking)

var P2MoCapPawn.SBoltOn	Bolton;	// Optional bolton to set. Always goes in slot 7
								// (dude doesn't have any boltons so it could probably go anywhere, but choosing 7 in case modders want to add boltons to their player pawns)
var Vector BoltonRelativeLocation;	// Relative location for bolton								

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ChangeWorked(P2Player p2p)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
state Activated
{
	///////////////////////////////////////////////////////////////////////////////
	// Setup a swap of our current clothes out for these
	///////////////////////////////////////////////////////////////////////////////
	function StartChangeClothes()
	{
		local P2Player p2p;
		local P2Pawn CheckPawn;

		if(Owner != None)
		{
			p2p = P2Player(Pawn(Owner).Controller);

			if(p2p != None)
			{
				// See if we can change our clothes
				if(p2p.CheckForChangeClothes(class))
				{
					TurnOffHints();	// When you use it, turn off the hints

					p2p.SayTime = 0;
					ChangeWorked(p2p);
					WaitTime = p2p.SayTime;
					GotoState('Activated', 'DoChange');
					return;
				}
			}
		}
		GotoState('Activated', 'Failed');
	}
	///////////////////////////////////////////////////////////////////////////////
	// Swap our current clothes out for these
	///////////////////////////////////////////////////////////////////////////////
	function DoChangeClothes()
	{
		local P2Player p2p;
		local P2Pawn CheckPawn;

		if(Owner != None)
		{
			p2p = P2Player(Pawn(Owner).Controller);

			if(p2p != None)
			{
				// And put them on
				p2p.RequestClothes();
				// We can! So take them from our inventory
				UsedUp();
			}
		}
	}

Begin:
	// If we put these clothes on, then take them from our inventory
	StartChangeClothes();
DoChange:
	Sleep(WaitTime);
	DoChangeClothes();
	Sleep(0.1);
	GotoState('');
Failed:
	GotoState('');
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	HandsTexture=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	FootTexture= Texture'ChameleonSkins.Special.Dude'
	BodyMesh = SkeletalMesh'Characters.Avg_Dude'
	BodySkin = Texture'ChameleonSkins.Special.Dude'
	HeadMesh = SkeletalMesh'Heads.AvgDude'
	HeadSkin = Texture'ChamelHeadSkins.Special.Dude'
	HudSplats[0]=Texture'nathans.Inventory.bloodsplat-1'
	HudSplats[1]=Texture'nathans.Inventory.bloodsplat-2'
	HudSplats[2]=Texture'nathans.Inventory.bloodsplat-3'
	bAllowSwap=true
	bAllowKeep=true
	MaxAmount=1
	}
