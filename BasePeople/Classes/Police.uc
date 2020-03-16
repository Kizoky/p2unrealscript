///////////////////////////////////////////////////////////////////////////////
// Police
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for all police characters.
//
//	BaseEquipment[0]=(weaponclass=class'Inventory.HandCuffsWeapon')
//	BaseEquipment[1]=(weaponclass=class'Inventory.BatonWeapon')
//	BaseEquipment[2]=(weaponclass=class'Inventory.PistolWeapon')
///////////////////////////////////////////////////////////////////////////////
class Police extends AuthorityFigure
	notplaceable
	Abstract;
	
const GUNBELT_INDEX = 1;			// Index for the gunbelt
const GUNBELT_PISTOL_INDEX = 1;		// Skin index of the gun to turn off in the gunbelt
var Material InvisiblePistolTex;	// Material to use for the pistol when it's invisible
var Material VisiblePistolTex;		// Material to use when the pistol's turned back on

// Turns off the pistol in our gunbelt
function TurnOffPistol()
{	
	local PeoplePart GunbeltPistol;
	
	GunbeltPistol = Boltons[GUNBELT_INDEX].Part;

	// Skip if not assigned yet
	if (GunbeltPistol.StaticMesh == None)
		return;

	if (VisiblePistolTex == None)
		VisiblePistolTex = GunbeltPistol.Skins[GUNBELT_PISTOL_INDEX];

	GunbeltPistol.Skins[GUNBELT_PISTOL_INDEX] = InvisiblePistolTex;
	//log(self@"turn off pistol, gunbelt skin now"@GunbeltPistol.Skins[GUNBELT_PISTOL_INDEX]);
}

// Turn back on the pistol in our gunbelt
function TurnOnPistol()
{
	local PeoplePart GunbeltPistol;
	
	GunbeltPistol = Boltons[GUNBELT_INDEX].Part;
	// Skip if not assigned yet
	if (GunbeltPistol.StaticMesh == None)
		return;
		
	if (VisiblePistolTex != None)
		GunbeltPistol.Skins[GUNBELT_PISTOL_INDEX] = VisiblePistolTex;
	//log(self@"turn on pistol, gunbelt skin now"@GunbeltPistol.Skins[GUNBELT_PISTOL_INDEX]);
}

// Just changed to pendingWeapon
function ChangedWeapon()
{	
	Super.ChangedWeapon();
	
	//log(self@"changed weapon pending"@pendingweapon@"weapon"@weapon);

	// Turn off the pistol in the gunbelt if they're holding it
	if (PistolWeapon(Weapon) != None)
		TurnOffPistol();
	else // Turn it back on if they switch back to hands or to the baton, etc
		TurnOnPistol();
}

// toss out the weapon currently held
function TossWeapon(vector TossVel)
{
	// If they toss their pistol for whatever reason, turn the gunbelt pistol off
	if (PistolWeapon(Weapon) != None)
	{
		//log(self@"toss weapon"@weapon);
		// It ain't coming back if they toss it, set both skins to the "invisible" texture.
		VisiblePistolTex = InvisiblePistolTex;
		TurnOffPistol();
	}
	
	Super.TossWeapon(TossVel);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
	{
	Super.PostBeginPlay();

	Cowardice=0.0;
	
	/*
	log(self@"boltons"
		@"gunbelt"@Boltons[Gunbelt_Index].Part
		@"skin"@Boltons[Gunbelt_Index].Part.Skins[Gunbelt_Pistol_Index]);
	*/
	}

///////////////////////////////////////////////////////////////////////////////
// Set dialog class
///////////////////////////////////////////////////////////////////////////////
function SetDialogClass()
	{
	if (bIsFemale)
		DialogClass=class'BasePeople.DialogFemaleCop';
	else
		DialogClass=class'BasePeople.DialogMaleCop';
	}


defaultproperties
	{
	ActorID="Cop"
	bHasRadio=true
	bFriendWithAuthority=true
	ViolenceRankTolerance=0
	HealthMax=140
	Psychic=0.2
	Rat=1.0
	Compassion=1.0
	WarnPeople=1.0
	Conscience=1.0
	Reactivity=0.4
	Champ=0.5
	Cajones=0.6
	PainThreshold=1.0
	TalkWhileFighting=0.0
	TalkBeforeFighting=0.0
	Glaucoma=0.8
	Rebel=1.0
	Temper=0.12
	WillDodge=0.3
	WillKneel=0.1
	WillUseCover=0.6
	DonutLove=0.75
	Fitness=0.55
	AttackRange=(Min=256,Max=4096)
    ControllerClass=class'PoliceController'
	Gang="Police"
	BaseEquipment[0]=(weaponclass=class'Inventory.HandCuffsWeapon')
	BaseEquipment[1]=(weaponclass=class'Inventory.BatonWeapon')
	BaseEquipment[2]=(weaponclass=class'Inventory.PistolWeapon')
	CloseWeaponIndex=2
	FarWeaponIndex=3
	TakesShotgunHeadShot=	0.2
	TakesRifleHeadShot=		1.0
	TakesShovelHeadShot=	1.0
	TakesOnFireDamage=		1.0
	TakesAnthraxDamage=		1.0
	TakesShockerDamage=		0.7
	FriendDamageThreshold=0.0
	// give all cops badges
	Boltons[0]=(bone="cop_badge",staticmesh=staticmesh'boltons.cop_badge',bCanDrop=false)
	// Give cops a gunbelt
	Boltons[1]=(bone="MALE01 spine",StaticMesh=StaticMesh'Boltons_Package.Cop.Gunbelt_M_Avg',bCanDrop=false)
	InvisiblePistolTex=Shader'AW7Tex.Weapons.InvisiblePistol'
	VisiblePistolTex=Texture'WeaponSkins.desert_eagle_timb'
	}
