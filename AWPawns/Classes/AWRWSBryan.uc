//=============================================================================
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
// 
// This is the one and only Bryan in the Vince's House level in AW. There should
// only be one of him in the whole game.
//=============================================================================
class AWRWSBryan extends AWRWSStaff
	placeable;

const STOP_VAL = 5;

///////////////////////////////////////////////////////////////////////////////
//	PostBeginPlay
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(1.0,false);
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	// Redo some variables
	AWGameState(AWGameSP(Level.Game).TheGameState).BryanSurvived=1;
	log(Self$" cheattest new multi cast "$AWGameSP(Level.Game).MultCast);
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	// When you die, tell the gamestate you died so it can count it for the summary.
	AWGameState(AWGameSP(Level.Game).TheGameState).BryanSurvived=0;
	AWGameSP(Level.Game).MultCast = STOP_VAL - 1;
	log(Self$" cheattest, died, setting multi cast "$AWGameSP(Level.Game).MultCast);
	
	// Normal death stuff
	Super.Died(Killer, damageType, HitLocation);
}

defaultproperties
{
	ActorID="Bryan"
	HeadSkin=Texture'ChamelHeadSkins.Male.MWA__021__AVgMaleBig'
	BaseEquipment(0)=(WeaponClass=Class'Inventory.PistolWeapon')
	BaseEquipment(1)=(WeaponClass=Class'Inventory.MachineGunWeapon')
	HealthMax=5.000000
	//Mesh=SkeletalMesh'Characters.Avg_M_SS_Shorts'
	//Skins(0)=Texture'ChameleonSkins.Special.RWS_Shorts'
	ChameleonSkins[2]="ChameleonSkins2.RWS.MW__206__Avg_M_SS_Shorts"
}
