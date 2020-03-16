//=============================================================================
// UrethraWeapon
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Urethra weapon (first and third person).
//
//
// Giant mess in multiplayer?? Why yes! It is!
// It uses one 'simple' emitter with special collision for the fluids in single
// player.
// But in multiplayer it has to use a seperate collision only version on the
// server. By nature of the multicasting spawn function, all clients, local
// and remote get this actor. But we can't do the visuals with this, because
// only the local client making the changes would have the emitter changes to
// see it going in different directions. Plus, it takes a lot of bandwidth
// just to replicate all those functions every ticks. So that's a bad
// idea.
//
// Instead, the direction is not replicated. It's simply run in the functions
// below on the server. The server handles the collision direction updates.
//
// To do the visuals, when the collision version is spawned on all the clients,
// in PostNetBeginPlay, we spawn a client-only visual emitter for the piss stream.
// This then checks it's Pawn owner for direction, each tick. But the tick only
// happens on that client and takes up no bandwidth. (It uses the Rotation
// and ViewPitch for direction).
// To know when to do properly, the collision version on the server sets
// the owner pawn's bSteadyFiring to true when it's alive and false when it's
// dead. This value is multicasted to all clients, so the clients visual
// emitters are all able to simply check that value in the Tick and then die
// after a while if it's false.
//
// Censored bar shows up in MP for feedback, but not in SP because it covers
// up too much.
//
//=============================================================================

class UrethraWeapon extends P2WeaponStreaming;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts
///////////////////////////////////////////////////////////////////////////////

var travel bool bElephantMode;
var float ElephantPourSpeedMult;
var float ElephantParticleScaleMult;
var travel float CensorBarScale;

var FluidFeeder Urinestream;
var float ColorChangeTime;
var float PeeTime;
var bool bSighed;
var travel bool	bMentionedPee;		// Save if you need to say how you need to pee. This is
									// only if you have gonorrhea. After you pee once, this will
									// get marked so you don't keep talking about it.

var const localized string ZipPantsHint1;	// Hint as to how to pull up your pants
var const localized string ZipPantsHint2;	// Hint as to how to pull up your pants

const MAX_TIME_TILL_SIGH	=	3.0;
const GONORRHEA_DAMAGE		=	2.0;
const MENTION_DISEASE_TIME	=	40.0;
const CLINIC_ERRAND_NAME	=	"VisitClinic";
const FORCE_PICK			=	100;	// Make the auto picking code be very inclined to keep
										// this weapon while it's active. This weights it so when you
										// have the urethra out, and you walk across say.. a rocket launcher
										// it won't auto select the stronger rocket launcher. We say this is
										// stronger while using it. AutoSwitchPriority will get set back to its
										// default when we put it away

// Enhanced game - let the player pick urine type with alt-fire.
var travel int CurrentUrineType;	// Starts at 0, increments each time the player hits alt-fire.

// Actual arrays that define the various types of "urine" we can "piss" in enhanced.
var() array< class<FluidPourFeeder> > UrineFeederClassEnhanced;
var() array<Texture> HUDIconEnhanced;
var() array<Fluid.FluidTypeEnum> UrineTypeEnhanced;
//	FLUID_TYPE_None,		//0
//	FLUID_TYPE_Gas,			//1
//	FLUID_TYPE_Urine,		//2
//	FLUID_TYPE_Blood,		//3
//	FLUID_TYPE_Puke,		//4
//	FLUID_TYPE_BloodyPuke,	//5
//	FLUID_TYPE_Gonorrhea,	//6
//	FLUID_TYPE_BloodyUrine,	//7
//	FLUID_TYPE_Napalm,		//8

///////////////////////////////////////////////////////////////////////////////
// Give hints about this item
///////////////////////////////////////////////////////////////////////////////
function bool GetHints(out String str1, out String str2, out String str3,
				out byte InfiniteHintTime)
{
	if(bShowHints
		&& bAllowHints
		&& P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Pawn(Owner).Controller.bIsPlayer)
	{
		str1=HudHint3;
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ServerAltFire()
{
	TurnOffHint();
	Instigator.PlaySound(SelectSound, SLOT_Misc, 1.0);
	CurrentUrineType++;
	if (CurrentUrineType >= UrineTypeEnhanced.Length)
		CurrentUrineType = 0;

	// change the hud icon accordingly
	OverrideHUDIcon = HUDIconEnhanced[UrineTypeEnhanced[CurrentUrineType]];
}

///////////////////////////////////////////////////////////////////////////////
// AltFire - switches "firing mode"
// Enhanced only.
///////////////////////////////////////////////////////////////////////////////
simulated function AltFire( float Value )
{
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Pawn(Owner).Controller.bIsPlayer)
	{
		ServerAltFire();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Don't show the censored bar in single player
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	LowerCensoredBar();
}

///////////////////////////////////////////////////////////////////////////////
// Called after a saved game has been loaded
// Don't show the censored bar in single player
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
{
	Super.PostLoadGame();
	LowerCensoredBar();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function LowerCensoredBar()
{
	if(Level.Game != None
		&& Level.Game.bIsSinglePlayer)
	{
		default.PlayerViewOffset.X=-6;
		default.PlayerViewOffset.Y=-4;
		default.PlayerViewOffset.Z=-80;
		PlayerViewOffset = default.PlayerViewOffset;
	}
}

///////////////////////////////////////////////////////////////////////////////
//Override the base weapon version of this, to make
// sure we use AddAmmo in both spots
// When looking for available ammo, look first for gonorrhea, then
// for normal urethra
///////////////////////////////////////////////////////////////////////////////
function GiveAmmoFromPickup( Pawn Other, int AddInAmount)
{
	if ( AmmoName == None
		|| Other == None)
		return;

	// Look first for diseased ammo
	AmmoType = Ammunition(Other.FindInventoryType(class'GonorrheaAmmoInv'));
	// if not, then look for normal.
	if(AmmoType == None)
		AmmoType = Ammunition(Other.FindInventoryType(AmmoName));

	// Add in the ammo necessary on a pickup.
	if ( AmmoType != None )
	{
		AmmoType.AddAmmo(AddInAmount);
	}
	else
	{
		AmmoType = Spawn(AmmoName);	// Create ammo type required
		Other.AddInventory(AmmoType);		// and add to player's inventory
		AmmoType.AddAmmo(AddInAmount); // Use it here, even though we just made this ammotype.
	}

	// Check to set this to infinite ammo if NPC's are using this weapon
	if(P2Player(Other.Controller) == None)
	{
		if(bMakeInfiniteForNPCs)
			P2AmmoInv(AmmoType).bInfinite=true;
	}

	// If you have gonorrhea, then set timers to make the player say stuff about
	// having to pee badly.
	if(IsInfected())
	{
		SetTimer(Rand(MENTION_DISEASE_TIME) + MENTION_DISEASE_TIME, false);
	}
}

///////////////////////////////////////////////////////////////////////////////
// When looking for available ammo, look first for gonorrhea, then
// for normal urethra
///////////////////////////////////////////////////////////////////////////////
function GiveAmmo( Pawn Other )
{
	GiveAmmoFromPickup(Other, PickUpAmmoCount);
}

///////////////////////////////////////////////////////////////////////////////
// Happens after you switch levels.
//
// This was taken from Weapon.uc but modified to not need PickupAmmoCount.
//
// When looking for available ammo, look first for gonorrhea, then
// for normal urethra
///////////////////////////////////////////////////////////////////////////////
event TravelPostAccept()
{
	local Pawn powner;
	local int AmmoGive;

//	Super.TravelPostAccept();
	// To replace this we copied the internal TravelPostAccept calls from all
	// the parent classes of this. It was only from Inventory.uc.
	PickupFunction(Pawn(Owner));

	// Now call the rest of the normal function
	powner = Pawn(Owner);
	if ( powner == None )
		return;
	if ( AmmoName != None )
	{
		// Look first for diseased ammo
		AmmoType = Ammunition(powner.FindInventoryType(class'GonorrheaAmmoInv'));
		// if not, then look for normal.
		if(AmmoType == None)
			AmmoType = Ammunition(powner.FindInventoryType(AmmoName));

		if ( AmmoType == None )
		{
			AmmoType = Spawn(AmmoName);	// Create ammo type required
			powner.AddInventory(AmmoType);		// and add to player's inventory

			if(PickupClass != None)
			{
				if(Level.NetMode == NM_Standalone)
//				if(Level.Game != None
//					&& FPSGameInfo(Level.Game).bIsSinglePlayer)
					AmmoGive=class<P2WeaponPickup>(PickupClass).default.AmmoGiveCount;
				else
					AmmoGive=class<P2WeaponPickup>(PickupClass).default.MPAmmoGiveCount;
			}

			AmmoType.AmmoAmount = AmmoGive;

			AmmoType.GotoState('');
		}
	}
	if ( self == powner.Weapon )
		BringUp();
	else GotoState('');
}

///////////////////////////////////////////////////////////////////////////////
// Used to change the stream on the fly
///////////////////////////////////////////////////////////////////////////////
simulated function ChangeStream()
{
	// STUB here, used in firing
}

///////////////////////////////////////////////////////////////////////////////
// If he's got gonorrhea or not
///////////////////////////////////////////////////////////////////////////////
function bool IsInfected()
{
	return (GonorrheaAmmoInv(AmmoType) != None);
}

///////////////////////////////////////////////////////////////////////////////
// If you're not actively peeing, set it here,
// otherwise, you'll set it, and change the pee stream
// (Urethra only)
///////////////////////////////////////////////////////////////////////////////
function MakeBloodied()
{
	if(UrethraAmmoInv(AmmoType)==None)
		return;

	// can't be bloodied when like this
	if(IsInfected())
		return;

	// Don't do it again, till we're done
	if(UrethraAmmoInv(AmmoType).IsBloodied())
		return;

	UrethraAmmoInv(AmmoType).SetBloodied(true);
	// If you're peeing now, change things
	ChangeStream();
}
/*
///////////////////////////////////////////////////////////////////////////////
// If you're not actively peeing, set it here,
// otherwise, you'll set it, and change the pee stream
// (Urethra only)
///////////////////////////////////////////////////////////////////////////////
function MakeInfected()
{
	if(UrethraAmmoInv(AmmoType)==None)
		return;
	// can't be infected twice
	if(UrethraAmmoInv(AmmoType).IsInfected())
		return;

	UrethraAmmoInv(AmmoType).SetInfected(true);
	// If you're peeing now, change things
	ChangeStream();
}
*/
///////////////////////////////////////////////////////////////////////////////
// Turn you back to normal
///////////////////////////////////////////////////////////////////////////////
function MakeClean()
{
	if(UrethraAmmoInv(AmmoType)==None)
		return;
	UrethraAmmoInv(AmmoType).SetBloodied(false);
	// fix it back
	ChangeStream();
}

///////////////////////////////////////////////////////////////////////////////
// Remove VDs
///////////////////////////////////////////////////////////////////////////////
function MakeCured()
{
	// make sure we're infected first
	if(AmmoType.class != class'GonorrheaAmmoInv')
		return;

	// First remove the gonorrhea from your inventory completely.
	if ( Instigator != None )
	{
		AmmoType.DetachFromPawn(Instigator);
		Instigator.DeleteInventory(AmmoType);
		AmmoType.Destroy();
		AmmoType = None;
	}

	// Now give yourself normal pee ammo
	GiveAmmo(Instigator);

	// and set back the ready for use flag
	UrethraAmmoInv(AmmoType).bReadyForUse=true;

	// Fix the active stream
	ChangeStream();
}

///////////////////////////////////////////////////////////////////////////////
// Stub this out, because we don't shoot things
///////////////////////////////////////////////////////////////////////////////
function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Make the gas pour go to the end of the gun and orient itself
///////////////////////////////////////////////////////////////////////////////
function SnapUrineStreamToGun(optional bool bInitArc)
{
	local vector startpos, X,Y,Z;
	local vector forward;
	local float checkz;
	local Rotator userot;

	if(UrineStream != None
		&& Instigator != None)
	{
		// Orient temp gas pour and reposition
		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		// Don't call GetFireStart(X,Y,Z). That moves it too far back and looks bad.
		// We're sending in different location values for the visual part and the collision part.
		// The collision location gets sent in with the SetDir. We need this to be in the center
		// otherwise it could hit a wall behind him as he backs up.
		startpos = (Instigator.Location + Instigator.EyePosition());
		// This moves it up as he looks down, and only moves it back a little. If you put the visual
		// effect in the center, like the collision it looks back when he looks up or down.
		if(Z.z < 0.1)
			checkz  = 0.1;
		else
			checkz = Z.z;
		Z.x = Z.x*checkz;
		Z.y = Z.y*checkz;
		userot = Instigator.GetViewRotation();
		startpos = startpos + FireOffset.Z * Z;
		UrineStream.SetLocation(startpos);
		UrineStream.SetRotation(userot);
		if(P2GameInfoSingle(Level.Game) != None)
		{
			UrineStream.SetDir(Instigator.Location, vector(userot),,bInitArc);
		}
		else
		{
			UrineStream.ServerSetDir(Instigator.Location, vector(userot),,bInitArc);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// perform turn ons
///////////////////////////////////////////////////////////////////////////////
simulated function PlaySelect()
{
	Super.PlaySelect();
	SetReadyForUse(true);
	AutoSwitchPriority = FORCE_PICK;
	//log(self$" PlaySelect, AutoSwitchPriority "$AutoSwitchPriority);
}

///////////////////////////////////////////////////////////////////////////////
// play unselect sound and perform turn offs
///////////////////////////////////////////////////////////////////////////////
simulated function RemoveFromLineup()
{
	SetReadyForUse(false);
	AutoSwitchPriority = default.AutoSwitchPriority;
	//log(self$" RemoveFromLineup, AutoSwitchPriority "$AutoSwitchPriority);
}

///////////////////////////////////////////////////////////////////////////////
// Stub these out to keep it from doing them--we regenerate our ammo
// so they're not needed because we want to stay on this weapon
///////////////////////////////////////////////////////////////////////////////
function ForceFinish();
function ServerForceFinish();
simulated function ClientForceFinish();

///////////////////////////////////////////////////////////////////////////////
// terminate the pee stream
///////////////////////////////////////////////////////////////////////////////
simulated function bool ForceEndFire()
{
	if(UrineStream != None)
	{
		UrineStream.ToggleFlow(0.0, false);
		UrineStream = None;
		return Super.ForceEndFire();
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Decide and spawn the actual stream
///////////////////////////////////////////////////////////////////////////////
function SpawnStream()
{
	if(UrethraAmmoInv(AmmoType)==None)
		return;

	// Make sure the old one is done
	ForceEndFire();

	if(UrethraAmmoInv(AmmoType).IsBloodied())
	{
		// bloody urine overrides everything
		UrineStream = spawn(class'BloodyUrinePourFeeder',Instigator,,,Rotation);
	}
	else if(IsInfected())
	{
		// You've got a VD
		UrineStream = spawn(class'GonorrheaPourFeeder',Instigator,,,Rotation);
		// Reset the sighing so he comments each time you piss like this
		bSighed=true;
	}
	// In enhanced mode, piss out the fluid they've selected
	else if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Pawn(Owner).Controller.bIsPlayer)
	{
		// Spawn piss
		UrineStream = spawn(UrineFeederClassEnhanced[UrineTypeEnhanced[CurrentUrineType]], Instigator,,,Rotation);

        FluidPourFeeder(UrineStream).InitialPourSpeed=class'UrinePourFeeder'.default.InitialPourSpeed;
		FluidPourFeeder(UrineStream).InitialSpeedZPlus=class'UrinePourFeeder'.default.InitialSpeedZPlus;
		UrineStream.LifeSpan = class'UrinePourFeeder'.default.LifeSpan;

		// If it's not urine, make it use up twice as fast as normal
		// Or if the Dude wishes for an elephant sized dick
		if (UrineTypeEnhanced[CurrentUrineType] != FLUID_TYPE_Urine)
			AmmoUseRate = 2*default.AmmoUseRate;
		else
			AmmoUseRate = default.AmmoUseRate;
	}
	else
	{
		if(P2GameInfoSingle(Level.Game) != None)
			// Make normal urine
			UrineStream = spawn(class'UrinePourFeeder',Instigator,,,Rotation);
		else
		{
			UrineStream = spawn(class'UrinePourFeederMP',Instigator,,,Rotation);
		}
	}
	// Kamek 4-22
	if(Level.NetMode != NM_DedicatedServer ) PlayerController(Instigator.Controller).GetEntryLevel().EvaluateAchievement(PlayerController(Instigator.Controller),'TakeAPiss');

	// Make sure the all versions of piss can still trigger urine buckets (like in the piss on dad's grave errand)
	UrineStream.MyDamageType=class'UrinePourFeeder'.default.MyDamageType;

    if (bElephantMode) {
        // Our fire hose fires out at twice the rate
        AmmoUseRate = 2 * default.AmmoUseRate;

        FluidPourFeeder(UrineStream).InitialPourSpeed = class'UrinePourFeeder'.default.InitialPourSpeed * ElephantPourSpeedMult;

        UrineStream.Emitters[0].StartVelocityRange.X.Min *= ElephantPourSpeedMult;
        UrineStream.Emitters[0].StartVelocityRange.X.Max *= ElephantPourSpeedMult;

        UrineStream.Emitters[0].StartSizeRange.X.Min *= ElephantParticleScaleMult;
        UrineStream.Emitters[0].StartSizeRange.X.Max *= ElephantParticleScaleMult;
    }

	//UrineStream.MyOwner = Instigator;
	SnapUrineStreamToGun(true);
}

///////////////////////////////////////////////////////////////////////////////
// Always be regaining your ability to pee
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	GainAmmo(DeltaTime);
}

///////////////////////////////////////////////////////////////////////////////
// Tell the player to mention something about your gonorrhea problem
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	if(IsInfected()
		&& !bMentionedPee)
	{
		if ( P2Pawn(Instigator) != None
			&& P2Player(P2Pawn(Instigator).Controller) != None)
			P2Player(P2Pawn(Instigator).Controller).CommentOnNeedingToPee();

		SetTimer(Rand(MENTION_DISEASE_TIME) + MENTION_DISEASE_TIME, false);
	}
}

///////////////////////////////////////////////////////////////////////////////
// He noticed his disease so see if we should comment on this
///////////////////////////////////////////////////////////////////////////////
function NoticedDisease()
{
	if(!bMentionedPee)
	{
		bMentionedPee=true;
		if(P2GameInfoSingle(Level.Game) != None)
			{
			// Activate the errand and then show the new errand on the map
			P2GameInfoSingle(Level.Game).ActivateErrand(CLINIC_ERRAND_NAME);
			if (P2Player(P2Pawn(Instigator).Controller) != None)
				P2Player(P2Pawn(Instigator).Controller).DisplayMapErrands();
			}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Make sure we change our animations for each weird weapon
///////////////////////////////////////////////////////////////////////////////
simulated function BringUp()
{
	Super.BringUp();

	// reset sighs
	PeeTime=0;
	bSighed=false;
}

///////////////////////////////////////////////////////////////////////////////
// Make sure to take this weapon out of the lineup of selectable weapons
///////////////////////////////////////////////////////////////////////////////
simulated function bool PutDown()
{
	RemoveFromLineup();
	return Super.PutDown();
}

function SetCensorBarScale(float NewScale) {
    CensorBarScale = NewScale;

    if (ThirdPersonActor != none)
        ThirdPersonActor.SetDrawScale(CensorBarScale);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// normal fire
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Streaming
{
	ignores Timer;

	///////////////////////////////////////////////////////////////////////////////
	// Used to change the stream on the fly
	///////////////////////////////////////////////////////////////////////////////
	function ChangeStream()
	{
		// Cuts off old one and starts new one
		SpawnStream();
	}

	function Tick( float DeltaTime )
	{
		local bool bInfected;

		SnapUrineStreamToGun();

		bInfected = IsInfected();

		// remove some pee from your bladder
		if(ReduceAmmo(DeltaTime)
			&& bInfected)
		{
			// If you're infected, you're slowly hurt by the disease
			// as you pee
			Instigator.TakeDamage(GONORRHEA_DAMAGE, Instigator, Instigator.Location,
						vect(0,0,0), class'GonorrheaDamage');
		}

		// Record for how long you've been peeing
		PeeTime+=DeltaTime;
		// Sigh if you haven't already and aren't infected (because it feels good to pee)
		if(!bSighed)
		{
			if(FRand() < (PeeTime/MAX_TIME_TILL_SIGH))
			{
				bSighed=true;
				// Only say things like this, if you're not on fire currently
				if(P2Pawn(Instigator).MyBodyFire == None)
				{
					if(!bInfected) // normal sighing from pissing.
						P2Pawn(Instigator).Say(P2Pawn(Instigator).myDialog.lPissing);
					else // You're hurting.. say bad things.
						P2Pawn(Instigator).Say(P2Pawn(Instigator).myDialog.lDude_HasDisease);
				}
			}
		}
	}

	simulated function EndState()
	{
		Super.EndState();

		ForceEndFire();

		if(IsInfected())
			NoticedDisease();
	}

	simulated function BeginState()
	{
		Super.BeginState();
		SpawnStream();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// idle state
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Idle
{
	simulated function bool PutDown()
	{
		RemoveFromLineup();
		return Super.PutDown();
	}

	simulated function CheckToPee()
	{
		local P2Pawn p2p;

		p2p = P2Pawn(Instigator);
		if ( p2p != None
			&& p2p.PressingFire()
			&& p2p.Health > 0)
			Fire(0.0);
	}

	simulated function BeginState()
	{
		local P2Pawn p2p;
		local P2Player p2cont;

		// If it's the guy playing that hosts the listen server
		// or it's a typical client/stand alone game.
		if(NotDedOnServer())
		{
			p2p = P2Pawn(Instigator);
			if(p2p != None)
			{
				if ( p2p.PressingFire() )
				{
					if(p2p.Health > 0)
						Fire(0.0);
				}
				else
				{
					if ( Owner != None )
					{
						// stop peeing
						ForceEndFire();
					}
				}
			}
		}
	}

Begin:
	bPointing=False;
	CheckToPee();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Active
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Active
{
	simulated function bool PutDown()
	{
		RemoveFromLineup();
		return Super.PutDown();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Wait after the guy spits some after peeing on himself, or getting
// peeed on or whatever
// No firing here
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitAfterStopping
{
	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	function ServerFire() {}
	function ServerAltFire() {}

Begin:
	Sleep(UseWaitTime);
	GotoState('Idle');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// putting the weapon down
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DownWeapon
{
	///////////////////////////////////////////////////////////////////////////////
	// Make sure to take this weapon out of the lineup of selectable weapons
	///////////////////////////////////////////////////////////////////////////////
	simulated function bool PutDown()
	{
		RemoveFromLineup();
		return Super.PutDown();
	}

	simulated function BeginState()
	{
		Super.BeginState();
		TurnOffHint();
		// stop peeing
		ForceEndFire();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bElephantMode=false
	ElephantPourSpeedMult=2.0f
	ElephantParticleScaleMult=4.0f

	bNoHudReticle=true
	ItemName="Urethra"
	AmmoName=class'UrethraAmmoInv'
	AttachmentClass=class'UrethraAttachment'

	//Mesh=Mesh'FP_Weapons.FP_Dude_Urethra'
	Mesh=Mesh'MP_Weapons.MP_Urethra'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	FirstPersonMeshSuffix=""

	// Move way down so you can't see it
	PlayerViewOffset=(X=-6.0000,Y=-4.000000,Z=-20.0000)
    //PlayerViewOffset=(X=-6.0000,Y=-4.000000,Z=-80.0000)
	FireOffset=(X=0.000000,Y=0.00000,Z=-70.00000)

	PickUpAmmoCount=7

	//shakemag=0.000000
	//shaketime=0.000000
	//shakevert=(X=0.0,Y=0.0,Z=0.00000)
	//shakespeed=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetMag=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetRate=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetTime=0
	ShakeRotMag=(X=0.0,Y=0.0,Z=0.0)
	ShakeRotRate=(X=0.0,Y=0.0,Z=0.0)
	ShakeRotTime=0

	AIRating=0.01
	AutoSwitchPriority=0
	InventoryGroup=0
	GroupOffset=1
	ReloadCount=0
//	DrawScale3D=(X=0.1,Y=0.1,Z=0.1)
	ViolenceRank=0
	bCanThrow=false

	soundStart = Sound'WeaponSounds.Piss_Start'
	soundLoop1 = Sound'WeaponSounds.Piss_Loop'
	soundLoop2 = Sound'WeaponSounds.Piss_Loop'
	soundEnd = Sound'WeaponSounds.Piss_End'
	SelectSound = Sound'WeaponSounds.Piss_ZipperDown'
	HolsterSound = Sound'WeaponSounds.Piss_ZipperUp'

	WeaponSpeedHolster = 10.0
	WeaponSpeedLoad    = 10.0
	WeaponSpeedReload  = 2.0
	WeaponSpeedShoot1  = 1.0
	WeaponSpeedShoot1Rand=0.0
	WeaponSpeedShoot2  = 1.0

	AmmoGainRate=0.5

	MaxRange=300
	RecognitionDist=1000
	HudHint1="Press %KEY_Fire% to urinate."
	HudHint2="Press %KEY_UseZipper% to zip your pants up."
	DropWeaponHint1 = "You need to zip up your pants."
	DropWeaponHint2 = "Press %KEY_UseZipper% to do so."
	HudHint3="Press %KEY_AltFire% to 'enhance' your urine..."
	bDelayedStartSound=true
	bAllowHints=true
	bShowHints=true

	Begin Object Class=ConstantColor Name=ConstantColor_Gas
		Color=(A=255,B=255,G=128,R=192)
	End Object
	Begin Object Class=Combiner Name=ZipperOverlay_Gas
		CombineOperation=CO_Multiply
		Material1=Texture'Nathans.Inventory.Zipper'
		Material2=ConstantColor'ConstantColor_Gas'
		FallbackMaterial=Texture'Nathans.Inventory.Zipper'
	End Object
	Begin Object Class=ConstantColor Name=ConstantColor_Blood
		Color=(A=255,B=0,G=0,R=255)
	End Object
	Begin Object Class=Combiner Name=ZipperOverlay_Blood
		CombineOperation=CO_Multiply
		Material1=Texture'Nathans.Inventory.Zipper'
		Material2=ConstantColor'ConstantColor_Blood'
		FallbackMaterial=Texture'Nathans.Inventory.Zipper'
	End Object
	Begin Object Class=ConstantColor Name=ConstantColor_Puke
		Color=(A=255,B=0,G=128,R=255)
	End Object
	Begin Object Class=Combiner Name=ZipperOverlay_Puke
		CombineOperation=CO_Multiply
		Material1=Texture'Nathans.Inventory.Zipper'
		Material2=ConstantColor'ConstantColor_Puke'
		FallbackMaterial=Texture'Nathans.Inventory.Zipper'
	End Object
	Begin Object Class=ConstantColor Name=ConstantColor_Gonorrhea
		Color=(A=255,B=64,G=192,R=64)
	End Object
	Begin Object Class=Combiner Name=ZipperOverlay_Gonorrhea
		CombineOperation=CO_Multiply
		Material1=Texture'Nathans.Inventory.Zipper'
		Material2=ConstantColor'ConstantColor_Gonorrhea'
		FallbackMaterial=Texture'Nathans.Inventory.Zipper'
	End Object
	Begin Object Class=ConstantColor Name=ConstantColor_Napalm
		Color=(A=255,B=255,G=192,R=128)
	End Object
	Begin Object Class=Combiner Name=ZipperOverlay_Napalm
		CombineOperation=CO_Multiply
		Material1=Texture'Nathans.Inventory.Zipper'
		Material2=ConstantColor'ConstantColor_Napalm'
		FallbackMaterial=Texture'Nathans.Inventory.Zipper'
	End Object

//	FLUID_TYPE_None,		//0
//	FLUID_TYPE_Gas,			//1
//	FLUID_TYPE_Urine,		//2
//	FLUID_TYPE_Blood,		//3
//	FLUID_TYPE_Puke,		//4
//	FLUID_TYPE_BloodyPuke,	//5
//	FLUID_TYPE_Gonorrhea,	//6
//	FLUID_TYPE_BloodyUrine,	//7
//	FLUID_TYPE_Napalm,		//8
	UrineFeederClassEnhanced[0]=None
	UrineFeederClassEnhanced[1]=class'GasPourFeeder'
	UrineFeederClassEnhanced[2]=class'UrinePourFeeder'
	UrineFeederClassEnhanced[3]=class'BloodPourFeeder'
	UrineFeederClassEnhanced[4]=class'PukePourFeeder'
	UrineFeederClassEnhanced[5]=None
	UrineFeederClassEnhanced[6]=class'GonorrheaPourFeeder'
	UrineFeederClassEnhanced[7]=class'BloodyUrinePourFeeder'
	UrineFeederClassEnhanced[8]=class'NapalmPourFeeder'
	HUDIconEnhanced[0]=Texture'Nathans.Inventory.Zipper'
	HUDIconEnhanced[1]=Texture'AW7Tex.Icons.Zipper_Gas'
	HUDIconEnhanced[2]=Texture'Nathans.Inventory.Zipper'
	HUDIconEnhanced[3]=Texture'AW7Tex.Icons.Zipper_Blood'
	HUDIconEnhanced[4]=Texture'AW7Tex.Icons.Zipper_Puke'
	HUDIconEnhanced[5]=Texture'Nathans.Inventory.Zipper'
	HUDIconEnhanced[6]=Texture'AW7Tex.Icons.Zipper_Gonorrhea'
	HUDIconEnhanced[7]=Texture'AW7Tex.Icons.Zipper_Blood'
	HUDIconEnhanced[8]=Texture'AW7Tex.Icons.Zipper_Napalm'
	UrineTypeEnhanced[0]=FLUID_TYPE_Urine
	UrineTypeEnhanced[1]=FLUID_TYPE_Napalm
	UrineTypeEnhanced[2]=FLUID_TYPE_Gonorrhea
	UrineTypeEnhanced[3]=FLUID_TYPE_Blood
	UrineTypeEnhanced[4]=FLUID_TYPE_Puke
	UrineTypeEnhanced[5]=FLUID_TYPE_Gas
	CurrentUrineType=0
	OverrideHUDIcon=Texture'Nathans.Inventory.Zipper'

	CensorBarScale=0.2
	bCannotBeStolen=True
	}
