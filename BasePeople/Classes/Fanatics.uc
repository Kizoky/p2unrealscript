///////////////////////////////////////////////////////////////////////////////
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
//  Fanatics. One of the groups to end up hating the dude.
//
///////////////////////////////////////////////////////////////////////////////
class Fanatics extends Bystander
	placeable;
	
// Kamek 5-1
// If they die by grenade head explosion, award the player for juxtaposition
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	// Moved to P2Pawn/GameState
	/*
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& Killer != None
		&& Killer.bIsPlayer)
	{
		// Record him dying as a fanatic
		P2GameInfoSingle(Level.Game).TheGameState.FanaticsKilled++;
	}
	*/

	// use DudeSuicideDamage now instead of trying to hunt down a possibly-invalid Killer.
	if (damageType == class'DudeSuicideDamage')
	{
	if( Level.NetMode != NM_DedicatedServer ) 	P2GameInfoSingle(Level.Game).GetPlayer().GetEntryLevel().EvaluateAchievement(P2GameInfoSingle(Level.Game).GetPlayer(),'ReversePsychology');
	}
		
	// 5-19 fixed invincible taliban glitch
	Super.Died(Killer, DamageType, HitLocation);
}

function PreBeginPlay()
	{
	Super.PreBeginPlay();

	// Do this here because we can't use enums in default properties
	ChameleonOnlyHasGender = Gender_Male;
	}

defaultproperties
	{
	ActorID="Terrorist"
	Skins[0]=Texture'ChameleonSkins.XX__147__Avg_Dude'
	Mesh=Mesh'Characters.Avg_Dude'

	ChameleonSkins(0)="ChameleonSkins.MF__009__Avg_Dude"
	ChameleonSkins(1)="ChameleonSkins.MF__010__Avg_Dude"
	ChameleonSkins(2)="ChameleonSkins.MF__011__Avg_Dude"
	ChameleonSkins(3)="end"	// end-of-list marker (in case super defines more skins)

	// These were picked from the general pool because they look good as cops, swat, etc.
	ChamelHeadSkins(0)="ChamelHeadSkins.MFA__018__AvgFanatic"
	ChamelHeadSkins(1)="ChamelHeadSkins.MFA__019__AvgFanatic"
	ChamelHeadSkins(2)="ChamelHeadSkins.MFA__020__AvgFanatic"
	ChamelHeadSkins(3)="end"	// end-of-list marker (in case super defines more skins)

	DialogClass=class'BasePeople.DialogFanatic'

	ViolenceRankTolerance=1
	bIsTrained=true
	BaseEquipment[0]=(weaponclass=class'Inventory.MachinegunWeapon')
	Gang="Fanatics"
	HealthMax=80
	Glaucoma=0.7
	TalkWhileFighting=0.0
	TalkBeforeFighting=0.0
	PainThreshold=1.0
	Rebel=1.0
	Cajones=1.0
	Stomach=0.9
	TakesShotgunHeadShot=	0.4
	TakesRifleHeadShot=		1.0 //0.5
	TakesShovelHeadShot=	0.5
	TakesOnFireDamage=		0.1
	TakesAnthraxDamage=		0.7
	TakesShockerDamage=		0.2
	RandomizedBoltons(0)=None
	bNoChamelBoltons=True
	bCellUser=False
	BlockMeleeFreq=0.6
	ControllerClass=class'FanaticController'
	bAllowRandomGuns=True	// xPatch
	}
