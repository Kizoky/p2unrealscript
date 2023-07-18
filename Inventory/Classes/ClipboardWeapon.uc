///////////////////////////////////////////////////////////////////////////////
// ClipboardWeapon
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Clipboard 'weapon' (first and third person).
//
// It uses altfire, but it doesn't ALLOW alt fire. This means,
// it overrides the altfire function so the altfire is a 'have npc sign it'
// called by code, not directly by the player.
//
///////////////////////////////////////////////////////////////////////////////

class ClipboardWeapon extends P2Weapon;

var ()bool bMoneyGoesToCharity;		// Defaults true. This means the money goes to an errand and
									// not to your wallet.
var float	AskRadius;				// Radius in which people could hear you ask for money
var int     PendingMoney;			// How much money someone is going to give us
var int     AskingState;			// Where we're at in the asking process
var Texture NameTextures[3];		// Textures of names to be written on the clipboard
var Sound   WritingSound;			// Sound for when things are signed
var bool    bSwappedBack;			// For destructions purpose, make sure we don't try to swap back twice

const SIG_SKIN_OFFSET	=	2;

const CB_ASKING_NOW		=	1;
const CB_WALKED_AWAY	=	2;
const CB_GOT_SIG		=	3;

///////////////////////////////////////////////////////////////////////////////
// If this is important, then you can't throw it, otherwise, you can
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(bMoneyGoesToCharity)
		bCanThrow=false;
}

///////////////////////////////////////////////////////////////////////////////
// Play firing animation/sound/etc
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
{
	PlayAnim('Gesture', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
}

///////////////////////////////////////////////////////////////////////////////
// Play anim to grab money
///////////////////////////////////////////////////////////////////////////////
simulated function PlayAltFiring()
{
	PlayAnim('GetSignature', WeaponSpeedShoot1, 0.05);
}

///////////////////////////////////////////////////////////////////////////////
// If you have out a clipboard with full ammo, put it back away--we're done
// with it
///////////////////////////////////////////////////////////////////////////////
simulated function PlayIdleAnim()
{
	local P2Player p2p;
	local P2GameInfoSingle checkg;

	if(AmmoType != None
		&& AmmoType.AmmoAmount >= AmmoType.MaxAmmo)
	{
		// Even though we might have already completed the errand, check to make
		// sure it's done. We don't want to swap away the clipboard if, in the event
		// of a cheat, they've gotten full ammo (signatures) and it goes away. Make
		// sure to complete the errand.
		checkg = P2GameInfoSingle(Level.Game);
		p2p = P2Player(Instigator.Controller);
		if(checkg != None)
			checkg.CheckForErrandCompletion(self, None, None, p2p, false);

		SwapBackToHands();
	}
	else
		Super.PlayIdleAnim();
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: Lets the player use middle finger by alt fire.
///////////////////////////////////////////////////////////////////////////////
simulated function Fire( float Value )
{
	// Three hands glitch fix
	if (P2Player(Instigator.Controller) != None && P2Player(Instigator.Controller).bStillTalking)
		return;
	
	Super.Fire(Value);
}
simulated function AltFire( float Value )
{
	if (P2Player(Instigator.Controller) != None && !bOldHands)
		P2Player(Instigator.Controller).FlipMiddleFinger();
}

///////////////////////////////////////////////////////////////////////////////
// Point at which a noise is played and signature is written to clipboard
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_PetitionSigned()
{
	local P2Player p2p;
	local byte StateChange;

	if(Instigator != None)
		p2p = P2Player(Instigator.Controller);
		
	//log(self@"notify signed"@p2p@p2p.interestpawn@PersonController(p2p.InterestPawn.Controller));

	if(p2p != None
		&& p2p.InterestPawn != None
		&& PersonController(p2p.InterestPawn.Controller) != None)
		PersonController(p2p.InterestPawn.Controller).CheckTalkerAttention(StateChange);
	else
		StateChange = 1;

	if(StateChange == 0)
	{
		Instigator.PlayOwnedSound(WritingSound, SLOT_Misc, 1.0, , , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));

		// These weren't showing up well, so they were removed at the end
		// You could barely see them anyway
		/*
		log(self$" before value "$AmmoType.AmmoAmount + SIG_SKIN_OFFSET$" before skin "$Skins[AmmoType.AmmoAmount + SIG_SKIN_OFFSET]);
		// Add a new signature
		if(AmmoType.AmmoAmount + SIG_SKIN_OFFSET < Skins.Length)
			Skins[AmmoType.AmmoAmount + SIG_SKIN_OFFSET] = NameTextures[AmmoType.AmmoAmount];
		log(self$" after skin "$Skins[AmmoType.AmmoAmount + SIG_SKIN_OFFSET]$" name skin "$NameTextures[AmmoType.AmmoAmount]);
		*/
		AskingState = CB_GOT_SIG;
	}
	else
		AskingState = CB_WALKED_AWAY;
}

///////////////////////////////////////////////////////////////////////////////
// we don't shoot things
///////////////////////////////////////////////////////////////////////////////
function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	local P2Player p2p;
	local vector StartTrace, EndTrace, X,Y,Z, HitNormal;
	local actor Other;

	TurnOffHint();

	// Generate the directions as usual, but don't fire off with a trace,
	// use a radius test for people who might hear you talking
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z);
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
	EndTrace = StartTrace + (YOffset + Accuracy * (FRand() - 0.5 ) ) * Y * 1000
		+ (ZOffset + Accuracy * (FRand() - 0.5 )) * Z * 1000;
	X = vector(AdjustedAim);
	EndTrace += (TraceDist * X);

	p2p = P2Player(Instigator.Controller);

	if(p2p != None)
	{
		// Trace forward, and if we hit something stop at it, and use that
		// as the new end point
		Other = Trace(LastHitLocation,HitNormal,EndTrace,StartTrace,true);

		if(Other != None)
		{
			EndTrace = LastHitLocation;
		}

		AskingState=CB_ASKING_NOW;
		p2p.DudeAskForMoney(EndTrace, AskRadius, Other, bMoneyGoesToCharity);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check to invalidate the hands when you get added, so the clipboard is the
// only hands option
///////////////////////////////////////////////////////////////////////////////
function GiveTo(Pawn Other)
{
	local P2Player p2p;

	Super.GiveTo(Other);

	// Check to invalidate the hands
	if(P2Pawn(Other).bPlayer)
	{
		p2p = P2Player(Other.Controller);

		if(P2AmmoInv(AmmoType) != None
			&& P2AmmoInv(AmmoType).bReadyForUse)
			p2p.SetWeaponUseability(false, p2p.MyPawn.HandsClass);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Turn off the clipboard as being the basic hands
///////////////////////////////////////////////////////////////////////////////
function SwapBackToHands()
{
	local P2Player p2p;

	if(!bSwappedBack)
	{
		bSwappedBack=true;

		// Now remove it completely from your inventory.
		if (P2AmmoInv(AmmoType).bReadyForUse
			&& Instigator != None)
		{
			p2p = P2Player(Instigator.Controller);
			p2p.SetWeaponUseability(true, p2p.MyPawn.HandsClass);
			if(p2p != None)
			{
				// Turn clipboard off
				//log(self@"Set Ready For Use False");
				SetReadyForUse(false);
				// Switch to them
				//log(self@"Goto State DownWeapon");
				GotoState('DownWeaponRemove');
				//log(self@p2p@"Switch To Hands True");				
				//p2p.SwitchToThisWeapon(class'HandsWeapon'.Default.InventoryGroup,class'HandsWeapon'.Default.GroupOffset);
				//p2p.SwitchToHands(true);
				//p2p.ConsoleCommand("SwitchToHands true");
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Just to make sure (on day warps this can get called instead of the normal process)
// always swap back to your hands
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	SwapBackToHands();

	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Normal fire
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state NormalFire
{
	function AnimEnd(int Channel)
	{
		local P2Player p2p;

		if(bAltFiring)
		{
			bAltFiring=false;

			p2p = P2Player(Instigator.Controller);

			if(p2p != None
				&& AskingState == CB_GOT_SIG)
			{
				p2p.DudeTakeDonationMoney(PendingMoney, bMoneyGoesToCharity);
				PendingMoney=0;
			}
		}

		Super.AnimEnd(Channel);
	}
}

/*
///////////////////////////////////////////////////////////////////////////////
// Finish a sequence
///////////////////////////////////////////////////////////////////////////////
function Finish()
{
	local bool bOldSwappedBack;

	bOldSwappedBack = bSwappedBack;

	if(AmmoType.AmmoAmount == AmmoType.MaxAmmo)
	{
		// Send the clipboard weapon to a state that will put it down, then
		// remove it forever from your inventory
		SwapBackToHands();
//		GotoState('EmptyDownWeapon');
	}
	//else

	if(bOldSwappedBack==bSwappedBack)
		Super.Finish();
}
*/

///////////////////////////////////////////////////	////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// EmptyDownWeapon
// For grenades, thrown things, napalm launcher, where he must put away
// and empty or non-existant weapon (like he's got nothing in his hands)
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DownWeaponRemove extends DownWeapon
{
	simulated function AnimEnd(int Channel)
	{
		P2Player(Instigator.Controller).SwitchToThisWeapon(class'HandsWeapon'.Default.InventoryGroup,class'HandsWeapon'.Default.GroupOffset);
		Super.AnimEnd(Channel);
		GotoState('');
	}

	function EndState()
	{
		P2Player(Instigator.Controller).SwitchToThisWeapon(class'HandsWeapon'.Default.InventoryGroup,class'HandsWeapon'.Default.GroupOffset);
		//SwapBackToHands();
	}

}

// xPatch: Make sure that this gun is not extension!
function bool CanSwapHands()
{
	return (Class == Class'ClipboardWeapon');
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	bNoHudReticle=true
	bUsesAltFire=true
	ItemName="Clipboard"
	AmmoName=class'ClipboardAmmoInv'
	PickupClass=class'ClipboardPickup'
	AttachmentClass=class'ClipboardAttachment'

	// JWB 10/04/13 - Quick fix for widescreen users.
	// DisplayFOV=60

	bCanThrow=false

	OldMesh=Mesh'FP_Weapons.FP_Dude_Clipboard'
	Mesh=Mesh'MP_Weapons.MP_LS_Clipboard'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	Skins[1]=Texture'WeaponSkins.clipboard_timb'
	Skins[2]=Texture'Timb.Misc.Invisible_timb'
	Skins[3]=Texture'Timb.Misc.Invisible_timb'
	Skins[4]=Texture'Timb.Misc.Invisible_timb'

	NameTextures[0]=FinalBlend'WeaponSkins.signature_1_neg'
	NameTextures[1]=FinalBlend'WeaponSkins.signature_2_neg'
	NameTextures[2]=FinalBlend'WeaponSkins.signature_3_neg'

	FirstPersonMeshSuffix="Clipboard"

    bDrawMuzzleFlash=false

	//shakemag=100.000000
	//shaketime=0.200000
	//shakevert=(X=0.0,Y=0.0,Z=4.00000)
	ShakeOffsetMag=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetRate=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetTime=0
	ShakeRotMag=(X=0.0,Y=0.0,Z=0.0)
	ShakeRotRate=(X=0.0,Y=0.0,Z=0.0)
	ShakeRotTime=0

	//FireSound=Sound'WeaponSounds.pistol'
	CombatRating=0.6
	AIRating=0.0
	AutoSwitchPriority=1
	InventoryGroup=0
	GroupOffset=4
//	BobDamping=0.975000
	BobDamping=1.12 
	ReloadCount=0
	TraceAccuracy=0.0
	ViolenceRank=0
	bBumpStartsFight=false
	bArrestableWeapon=true

	WeaponSpeedHolster = 1.5
	WeaponSpeedLoad    = 1.0
	WeaponSpeedReload  = 1.0
	WeaponSpeedShoot1  = 0.7
	WeaponSpeedShoot1Rand=0.5
	WeaponSpeedShoot2  = 1.0
	AimError=0

	TraceDist=215.0
	AskRadius=512
	bMoneyGoesToCharity=true
	WritingSound=Sound'MiscSounds.Map.CheckMark'
	
	bAllowMiddleFinger=true

	bAllowHints=true
	bShowHints=true
	HudHint1="Press %KEY_Fire% to bother"
	HudHint2="someone to sign petition."
	HudHint3="Keep asking if they say no!"

	DropWeaponHint1="They've seen your weapon!"
	DropWeaponHint2="Press %KEY_ThrowWeapon% to drop it."

	holdstyle=WEAPONHOLDSTYLE_Toss
	switchstyle=WEAPONHOLDSTYLE_Single
	firingstyle=WEAPONHOLDSTYLE_Single

	ThirdPersonRelativeLocation=(X=6,Z=5)
	ThirdPersonRelativeRotation=(Yaw=-1600,Roll=-16384)
	PlayerViewOffset=(X=2,Y=0,Z=-8)
	}
