///////////////////////////////////////////////////////////////////////////////
// PLFanatics
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Tie-die Fanatics, they've mellowed out since the apocalypse.
///////////////////////////////////////////////////////////////////////////////
class PLFanatics extends Bystander
	placeable;
	
const FRIENDLY_DAY = 4;		// Friends with the dude on Friday, when he's working for us.
	
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

function PreBeginPlay()
{
	Super.PreBeginPlay();

	// Do this here because we can't use enums in default properties
	ChameleonOnlyHasGender = Gender_Male;
}

defaultproperties
{
	ActorID="PLFanatics"

	Skins[0]=Texture'PLCharacterSkins.Fanatic.XX__330__Avg_Dude'
	Mesh=Mesh'Characters.Avg_Dude'

	ChameleonSkins(0)="PLCharacterSkins.Fanatic.MF__330__Avg_Dude"
	ChameleonSkins(1)="PLCharacterSkins.Fanatic.MF__331__Avg_Dude"
	ChameleonSkins(2)="PLCharacterSkins.Fanatic.MF__332__Avg_Dude"
	ChameleonSkins(3)="end"	// end-of-list marker (in case super defines more skins)
	ChamelHeadSkins(0)="PLCharacterSkins.Fanatic_Head.MFA__330__AvgFanatic"
	ChamelHeadSkins(1)="PLCharacterSkins.Fanatic_Head.MFA__331__AvgFanatic"
	ChamelHeadSkins(2)="PLCharacterSkins.Fanatic_Head.MFA__332__AvgFanatic"
	ChamelHeadSkins(3)="end"	// end-of-list marker (in case super defines more skins)

	DialogClass=class'DialogFanaticPL'

	ViolenceRankTolerance=1
	Gang="Fanatics"
	RandomizedBoltons(0)=None
	bNoChamelBoltons=True
	bCellUser=False
	ControllerClass=class'FanaticController'
	AmbientGlow=30
}
