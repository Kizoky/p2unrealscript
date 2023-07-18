///////////////////////////////////////////////////////////////////////////////
// CopClothesInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Clothing inventory item. You're not wearing this, you have it
// folded up right now, so it's not active.
//
// This is the dudes original clothes for when he's wearing some other
// outfit.
//
///////////////////////////////////////////////////////////////////////////////

class CopClothesInv extends ClothesInv;

var mesh ActualDefaultHeadMesh;	// Some Player Mutators do change the clothes default mesh so we need some way to tell if it was changed.

///////////////////////////////////////////////////////////////////////////////
// Record that we used dressed up like a cop
///////////////////////////////////////////////////////////////////////////////
function ChangeWorked(P2Player p2p)
{
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None)
	{
		P2GameInfoSingle(Level.Game).TheGameState.DressedAsCop++;
		// Kamek 5-1 give them an achievement
		if (P2GameInfoSingle(Level.Game).TheGameState.DressedAsGimp >= 1)
		{
				if(Level.NetMode != NM_DedicatedServer ) p2p.GetEntryLevel().EvaluateAchievement(p2p,'Fabulous');
		}
		p2p.BecomingCop();
	}
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: Don't allow the new boltons for classic game / workshop player mods
// it's a "ducktape fix" but it can look bad with player models not designed for it 
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	BoltonsCheck();
	Super.PostBeginPlay();
}
event PostLoadGame()
{
	BoltonsCheck();	
	Super.PostLoadGame();
}
function BoltonsCheck()
{
	if(P2GameInfoSingle(Level.Game) != None
		&& !P2GameInfoSingle(Level.Game).GetChameleon().UseExtendedBoltons() 
		|| HeadMesh != ActualDefaultHeadMesh)
	{
		default.xBoltons[1] = xBoltons[0];
		default.xBoltons[2] = xBoltons[0];
		default.xBoltons[3] = xBoltons[0];
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	PickupClass=class'CopClothesPickup'
	Icon=Texture'HUDPack.Icon_Inv_CopUniform'
	InventoryGroup=103
	GroupOffset=2
	PowerupName="Police Uniform"
	PowerupDesc="Gee, I wonder what you could do with this?"
	Price=0
	bPaidFor=true
	LegalOwnerTag=""
	HudSplats[0]=Texture'nathans.Inventory.b_Star_Shield'
	HudSplats[1]=Texture'nathans.Inventory.b_Star_Shield'
	HudSplats[2]=Texture'nathans.Inventory.b_Star_Shield'
	HandsTexture=Texture'MP_FPArms.LS_hands_robber'
	FootTexture = Texture'ChameleonSkins.Dude_Cop'
	BodyMesh = SkeletalMesh'Characters.Avg_M_SS_Pants'
	BodySkin = Texture'ChameleonSkins.Dude_Cop'
	HeadMesh = SkeletalMesh'Heads.AvgDude'
	HeadSkin = Texture'ChamelHeadSkins.Special.Dude'
	Hint1="Press %KEY_InventoryActivate% to wear"
	Hint2="police uniform."
	Hint3=""
	bAllowKeep=false
	bIsCopUniform=true
	
	// xPatch:
	ActualDefaultHeadMesh = SkeletalMesh'Heads.AvgDude'
	xBoltons[0]=(bone="",StaticMesh=None)
	xBoltons[1]=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Cops.CopHat_M_Avg',Skin=Texture'Boltons_Tex.CopHat_Black_M',bCanDrop=false,bAttachToHead=true)
    xBoltonsRelativeLocation[1]=(Y=-2.450000,Z=0.300000)
	xBoltons[2]=(Bone="cop_badge",StaticMesh=StaticMesh'boltons.cop_badge',bCanDrop=false)
	xBoltons[3]=(bone="MALE01 spine",StaticMesh=StaticMesh'Boltons_Package.Cops.Gunbelt_M_Avg',bCanDrop=false)
	}
