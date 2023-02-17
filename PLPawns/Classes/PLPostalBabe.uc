///////////////////////////////////////////////////////////////////////////////
// PLPostalBabe
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
//
// Now part of the VD Clan.
///////////////////////////////////////////////////////////////////////////////
class PLPostalBabe extends PLRWSFollower;

const FRIENDLY_DAY = 1;		// Friends with the dude on Tuesday, when he's working for us.
	
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

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ActorID="PLPostalBabe"

	ChameleonOnlyHasGender=2
	
	// Postal Babes are hardened fighters just like the staff
	bIsTrained=true
	BaseEquipment[0]=(weaponclass=class'Inventory.PistolWeapon')
	BaseEquipment[1]=(weaponclass=class'Inventory.ShotgunWeapon')
	HealthMax=200
	PainThreshold=1.0
	Rebel=1.0
	DamageMult=2.5
	Cajones=1.0
	Stomach=1.0
	Psychic=0.4
	Glaucoma=0.3
	ViolenceRankTolerance=0
	FriendDamageThreshold=170
	
	TakesShotgunHeadShot=	0.25
	TakesShovelHeadShot=	0.35
	TakesOnFireDamage=		0.4
	TakesAnthraxDamage=		0.5
	TakesShockerDamage=		0.3
	TakesChemDamage=		0.6
	
	BlockMeleeFreq=1.0
	
	Skins[0]=Texture'PLCharacterSkins.VD.XX__360__Fem_SS_Shorts_02_D'
	Mesh=SkeletalMesh'Characters.Fem_SS_Shorts_02_D'
	ChameleonSkins[0]="PLCharacterSkins.VD.FW__365__Fem_SS_Shorts_02_D"
	ChameleonSkins[1]="End"
	bCellUser=false
	AmbientGlow=30
}