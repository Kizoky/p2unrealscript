///////////////////////////////////////////////////////////////////////////////
// PLFanatics
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Tie-die Fanatics, they've mellowed out since the apocalypse.
///////////////////////////////////////////////////////////////////////////////
class PLKumquat extends Bystander
 	placeable;

const FRIENDLY_DAY = 5;		// Friends with the dude on Friday, when he's working for us.
	
// Try the friendly check immediately, if it fails then GameInfo will call it again for us.
event PostBeginPlay()
{
	Super.PostBeginPlay();
	GameInfoIsNowValid();
}
	
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function GameInfoIsNowValid()
{
	local String MyGang;
	local Inventory Inv;
	
	MyGang = Gang;
	
	// On the day designated as our "friendly day" we will be friends with the Dude.
	// However, if the game is in They Hate Me mode, we won't be friends but we won't attack them either.
	if (P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& P2GameInfoSingle(Level.Game).GetCurrentDay() == FRIENDLY_DAY)
	{
		bPlayerIsEnemy = false;
		bPlayerHater = false;
		// Reset our gang, too - Impossible mode sets all NPCs to the same gang so they'll all beat up on the player. We obviously don't want that
		Gang = MyGang;
		// If we're NOT in They Hate Me, set us as being friends
		if (!P2GameInfo(Level.Game).TheyHateMeMode())
		{
			bPlayerIsFriend = true;
			if (HealthMax / 4 > FriendDamageThreshold)
				FriendDamageThreshold = HealthMax / 4;
		}
		// Otherwise, take away our guns - this is a cheap way of ensuring that they won't interfere with the carnage between the player and the rest of the world
		else
		{
			// Removing inventory items breaks the chain, so we just run through the whole list each time until they have no violent weapons left.
			while (bHasViolentWeapon)
			{
				for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
				{
					if (P2Weapon(Inv) != None && P2Weapon(Inv).ViolenceRank > 0)
					{
						DeleteInventory(Inv);
						break;
					}
				}
				EvaluateWeapons();
			}
		}
	}
}
	
defaultproperties
{
	ActorID="PLKumquat"

	Skins[0]=Texture'PLCharacterSkins.Fanatic.Kumquat_PL'
	Mesh=Mesh'Characters.Fem_LS_Skirt'
	HeadSkin=Texture'PLCharacterSkins.Fanatic_Head.PL_Kumquat_Head'
	HeadMesh=Mesh'Heads.FemSHcropped'
	bRandomizeHeadScale=false
	ControllerClass=class'KumquatController'
	Gang="Fanatics"
	bIsFemale=true
	bIsHindu=true
	TalkWhileFighting=0.0
	Boltons[0]=(bone="NODE_Parent",staticmesh=staticmesh'PLCharacterMeshes.kumquort.PL_Burka',bCanDrop=false,bAttachToHead=true,Skin=Texture'PLCharacterSkins.Fanatic.TD_burka_cloth')
	RandomizedBoltons(0)=None
	RandomizedBoltons(1)=None
	RandomizedBoltons(2)=None
	RandomizedBoltons(3)=None
	RandomizedBoltons(4)=None
	RandomizedBoltons(5)=None
	RandomizedBoltons(6)=None
	RandomizedBoltons(7)=None
	AmbientGlow=30
	bCellUser=false
}
