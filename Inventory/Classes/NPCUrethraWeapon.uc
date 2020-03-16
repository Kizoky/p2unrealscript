//=============================================================================
// Non Playable Character Urethra Weapon
// This is a special urethra weapon made for NPCs for cinemtaic sequences. NPCs
// press the fire but they don't hold it. This weapon was made to work in
// tandem with the ACTION_Piss. ACTION_Piss sets this weapons timer and fires.
// Gamefan74
// August 20th, 2008
//=============================================================================
class NPCUrethraWeapon extends P2WeaponStreaming;

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
var float LeakTime;
// Non playable characters don't take a piss long enough, we made it
// configurable for cinetmatics or just so John can get pissed on accidently.
var bool bGonorrheaPiss;
// Whether or not we have gonorrhea piss.
var bool bFinishPissing;
// Whether or not we should stop peeing.


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
		default.PlayerViewOffset.Z=-20;
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
	return bGonorrheaPiss;
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
		// Bump it forward just a bit so the stream's not poking out his ass
		startpos = startpos + Vector(Instigator.GetViewRotation()) * 30;
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
	else
	{
		if(P2GameInfoSingle(Level.Game) != None
			&& P2GameInfoSingle(Level.Game).VerifySeqTime())
		{
			// Piss napalm
			UrineStream = spawn(class'NapalmPourFeeder', Instigator,,,Rotation);
			NapalmPourFeeder(UrineStream).InitialPourSpeed=class'UrinePourFeeder'.default.InitialPourSpeed;
			NapalmPourFeeder(UrineStream).InitialSpeedZPlus=class'UrinePourFeeder'.default.InitialSpeedZPlus;
			// Use it twice as fast as normal
			AmmoUseRate=2*default.AmmoUseRate;
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
	}

	// Make sure the all versions of piss can still trigger urine buckets (like in the piss on dad's grave errand)
	UrineStream.MyDamageType=class'UrinePourFeeder'.default.MyDamageType;

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

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// normal fire
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Streaming
{
    simulated function AnimEnd(int Channel)
	{
		if(NotDedOnServer())
		{
			if(!bFinishPissing)
			{
				PlayFiring();
				bFinishPissing = false;
			}
			else
			{
				EndStreaming();
				ServerEndStreaming();
			}
		}
	}

    ///////////////////////////////////////////////////////////////////////////////
	// Used to change the stream on the fly
	///////////////////////////////////////////////////////////////////////////////
	function ChangeStream()
	{
		// Cuts off old one and starts new one
		SpawnStream();
	}

	function Timer()
	{
	    bFinishPissing = true;
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
		SetTimer(LeakTime, False);
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
     soundStart=Sound'WeaponSounds.Piss_Start'
     soundLoop1=Sound'WeaponSounds.Piss_Loop'
     soundLoop2=Sound'WeaponSounds.Piss_Loop'
     soundEnd=Sound'WeaponSounds.Piss_End'
     AmmoGainRate=0.500000
     bDelayedStartSound=True
     RecognitionDist=1000.000000
     HolsterSound=Sound'WeaponSounds.piss_ZipperUp'
     bNoHudReticle=True
     ShakeOffsetTime=0.000000
	HudHint1="Press %KEY_Fire% to urinate."
	HudHint2="Press %KEY_UseZipper% to zip your pants up."
	DropWeaponHint1 = "You need to zip up your pants."
	DropWeaponHint2 = "Press %KEY_UseZipper% to do so."
     WeaponSpeedLoad=10.000000
     WeaponSpeedReload=2.000000
     WeaponSpeedHolster=10.000000
     AmmoName=Class'Inventory.UrethraAmmoInv'
     PickupAmmoCount=7
     bCanThrow=False
     AutoSwitchPriority=0
     FireOffset=(Z=-70.000000)
     ShakeRotMag=(X=0.000000,Y=0.000000,Z=0.000000)
     ShakeRotRate=(X=0.000000,Y=0.000000,Z=0.000000)
     ShakeRotTime=0.000000
     ShakeOffsetMag=(X=0.000000,Y=0.000000,Z=0.000000)
     ShakeOffsetRate=(X=0.000000,Y=0.000000,Z=0.000000)
     AIRating=0.010000
     MaxRange=300.000000
     SelectSound=Sound'WeaponSounds.piss_ZipperDown'
     InventoryGroup=0
     GroupOffset=1
     AttachmentClass=Class'Inventory.UrethraAttachment'
     ItemName="Urethra"
     Mesh=SkeletalMesh'MP_Weapons.MP_Urethra'
     Skins(0)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
}
