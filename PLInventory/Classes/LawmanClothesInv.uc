///////////////////////////////////////////////////////////////////////////////
// LawmanClothesInv
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
class LawmanClothesInv extends ClothesInv;

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
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	PickupClass=class'LawmanClothesPickup'
	Icon=Texture'PLHud.Icons.Icon_Inv_CowboyDisguise'
	InventoryGroup=103
	GroupOffset=5
	PowerupName="Lawman Clothes"
	PowerupDesc="Gee, I wonder what you can do with these?"
	Price=0
	bPaidFor=true
	LegalOwnerTag=""
	HudSplats[0]=Texture'nathans.Inventory.b_Star_Shield'
	HudSplats[1]=Texture'nathans.Inventory.b_Star_Shield'
	HudSplats[2]=Texture'nathans.Inventory.b_Star_Shield'
	HandsTexture=Texture'PLCharacterSkins.Dude.LS_hands_CowboyDisguise'
	FootTexture = Texture'PLCharacterSkins.Dude.Dude_CowboyDisguise'
	BodyMesh = SkeletalMesh'Characters.Avg_M_LS_Pants'
	BodySkin = Texture'PLCharacterSkins.Dude.Dude_CowboyDisguise'
    HeadSkin=Texture'AW_Characters.Special.Dude_AW_Bandage'
    HeadMesh=SkeletalMesh'MoreHeads.AW_Dude'
	Hint1="Press %KEY_InventoryActivate% to wear"
	Hint2="Lawman disguise."
	Hint3=""
	bAllowKeep=false
	bIsCopUniform=true
	Bolton=(bone="NODE_PARENT",StaticMesh=StaticMesh'Boltons_Package.Hats.CowboyHat02_M',bCanDrop=false,bAttachToHead=true)
	BoltonRelativeLocation=(Y=-3,Z=2)
}
