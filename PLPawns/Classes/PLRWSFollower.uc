///////////////////////////////////////////////////////////////////////////////
// PLRWSFollowers
// Copyright 2014 Running With Scissors, Inc. All Rights Reserved.
//
// Followers of the Desi Clan. They wear the same getup as RWS employees minus
// the "disciple" ballcap. Also, they're not as tough.
///////////////////////////////////////////////////////////////////////////////
class PLRWSFollower extends Bystander
	placeable;
	
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
	
defaultproperties
{
	ActorID="PLRWSFollower"

	Skins[0]=Texture'PLCharacterSkins.VD.XX__360__Avg_M_SS_Pants_D'
	Mesh=Mesh'Characters.Avg_M_SS_Pants_D'
	ChameleonOnlyHasGender=1
	ChameleonSkins[0]="PLCharacterSkins.VD.MB__362__Avg_M_SS_Pants_D"
	ChameleonSkins[1]="PLCharacterSkins.VD.MM__361__Avg_M_SS_Pants_D"
	ChameleonSkins[2]="PLCharacterSkins.VD.MW__360__Avg_M_SS_Pants_D"
	ChameleonSkins[3]="End"

	bLookForZombies=True
	bPlayerIsFriend=True
	Gang="VDClan"
	FriendDamageThreshold=50.000000
	ControllerClass=Class'AWPawns.AWRWSController'

	RandomizedBoltons(0)=BoltonDef'BoltonDefSantaHat'
	RandomizedBoltons(1)=BoltonDef'BoltonDefShades1'
	RandomizedBoltons(2)=BoltonDef'BoltonDefShades2'
	RandomizedBoltons(3)=BoltonDef'BoltonDefShades4'
	RandomizedBoltons(4)=None
	AmbientGlow=30
	bCellUser=false
 }
