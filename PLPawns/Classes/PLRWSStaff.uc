///////////////////////////////////////////////////////////////////////////////
// PLRWSStaff
// Copyright 2014 Running With Scissors, Inc. All Rights Reserved.
//
// RWS employees, still loyal to Vince and friendly to the Dude
// after the apocalypse. They're part of the VD clan now.
///////////////////////////////////////////////////////////////////////////////
class PLRWSStaff extends Bystander
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
	
///////////////////////////////////////////////////////////////////////////////
// FIXME copied from AWRWSStaff
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ActorID="PLRWSStaff"

	Skins[0]=Texture'ChameleonSkins2.rws.MW__202__Avg_M_SS_Pants_D'
	Mesh=Mesh'Characters.Avg_M_SS_Pants_D'
	ChameleonOnlyHasGender=Gender_Male
	DialogClass=class'DialogMale'

	ChamelHeadSkins(0)="ChamelHeadSkins.MWA__021__AvgMaleBig"
	ChamelHeadSkins(1)="ChamelHeadSkins.MWA__035__AvgMale"
	ChamelHeadSkins(2)="ChamelHeadSkins.MWA__004__AvgMale"
	ChamelHeadSkins(3)="ChamelHeadSkins.MWA__007__AvgMale"
	ChamelHeadSkins(4)="ChamelHeadSkins.MWA__008__AvgMale"
	ChamelHeadSkins(5)="ChamelHeadSkins.MWA__010__AvgMale"
	ChamelHeadSkins(6)="ChamelHeadSkins.MWA__011__AvgMale"
	ChamelHeadSkins(7)="End"

	TakesSledgeDamage=0.100000
	TakesMacheteDamage=0.100000
	TakesScytheDamage=0.100000
	TakesZombieSmashDamage=0.300000
	bLookForZombies=True
	BlockMeleeFreq=1.000000
	bRandomizeHeadScale=False
	bIsTrained=True
	bStartupRandomization=False
	Psychic=0.400000
	Cajones=1.000000
	Glaucoma=0.300000
	PainThreshold=1.000000
	Rebel=1.000000
	Stomach=1.000000
	TakesShotgunHeadShot=0.250000
	TakesShovelHeadShot=0.350000
	TakesOnFireDamage=0.400000
	TakesAnthraxDamage=0.500000
	TakesShockerDamage=0.300000
	BaseEquipment(0)=(WeaponClass=Class'Inventory.PistolWeapon')
	BaseEquipment(1)=(WeaponClass=Class'Inventory.MachineGunWeapon')
	ViolenceRankTolerance=0
	TakesChemDamage=0.600000
	HealthMax=200.000000
	bPlayerIsFriend=True
	Gang="VDClan"
	DamageMult=2.500000
	FriendDamageThreshold=170.000000
	ControllerClass=Class'AWPawns.AWRWSController'

	Begin Object Class=BoltonDef Name=BoltonDefBallcap_RWS_PL
		UseChance=1
		Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_rws',bAttachToHead=True)
		Boltons(1)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_rws2',bAttachToHead=True)
		Boltons(2)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_rws3',bAttachToHead=True)
		Boltons(3)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_rws4',bAttachToHead=True)
		Boltons(4)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.BaseballCap_M',Skin=Texture'Boltons_Tex.baseballcap_rws5',bAttachToHead=True)
		Gender=Gender_Male
		Tag="Hat"
		ExcludeTags(0)="Hat"
	End Object

	RandomizedBoltons(0)=BoltonDef'BoltonDefSantaHat'
	RandomizedBoltons(1)=BoltonDef'BoltonDefShades1'
	RandomizedBoltons(2)=BoltonDef'BoltonDefShades2'
	RandomizedBoltons(3)=BoltonDef'BoltonDefShades4'
	RandomizedBoltons(4)=BoltonDef'BoltonDefBallcap_RWS_PL'
	RandomizedBoltons(5)=None
	AmbientGlow=30
	bCellUser=false
	bPersistent=True
	bCanTeleportWithPlayer=False
	bKeepForMovie=True
 }
