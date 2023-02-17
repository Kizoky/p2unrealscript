///////////////////////////////////////////////////////////////////////////////
// CanWeapon
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
///////////////////////////////////////////////////////////////////////////////
class CanWeapon extends ClipboardWeapon;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
struct DonationAmounts
{
	var() name PawnClass;		// Name of pawn class
	var() range MoneyGiven;		// How much money they should give
};

var() array<DonationAmounts> DonationTable;		// Table of pawn class donations
var() Sound MoneyReceivedLots;					// Sound played when a lot of money received
var() Sound MoneyReceivedLittle;				// Sound played when a bit of money received

var travel int DonationsReceived;

var bool bWasFiring;
var P2MoCapPawn AskedPawn;

const CAN_ERRAND_NAME = "CollectCharityMoney";		// Name of errand (Zack not displayed on the map)
const MONEY_LOTS = 100;								// How much money they have to donate for it to be considered "a lot" and play the multiple coin drop

///////////////////////////////////////////////////////////////////////////////
// Play firing animation/sound/etc
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
{
	PlayAnim('Gesture_Begin', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
}
simulated function PlayFiringIdle()
{
	PlayAnim('Gesture_Loop', WeaponSpeedShoot1, 0.05);
}

///////////////////////////////////////////////////////////////////////////////
// CheckForFinishedErrand
// Put away the can when we complete the errand one way or another
///////////////////////////////////////////////////////////////////////////////
function CheckForFinishedErrand()
{
	// Put away the can if the dude completes the errand, regardless of the means.
	if (P2GameInfoSingle(Level.Game).IsErrandCompleted(CAN_ERRAND_NAME))
		SwapBackToHands();
}

///////////////////////////////////////////////////////////////////////////////
// If you have out a clipboard with full ammo, put it back away--we're done
// with it
///////////////////////////////////////////////////////////////////////////////
simulated function PlayIdleAnim()
{
	local P2Player p2p;
	local P2GameInfoSingle checkg;
	
	if (bWasFiring)
	{
		PlayAnim('Gesture_End', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
		bWasFiring = false;
	}
	else if(AmmoType != None
		&& AmmoType.AmmoAmount >= AmmoType.MaxAmmo)
	{
		// Even though we might have already completed the errand, check to make
		// sure it's done. We don't want to swap away the clipboard if, in the event
		// of a cheat, they've gotten full ammo (signatures) and it goes away. Make
		// sure to complete the errand.
		checkg = P2GameInfoSingle(Level.Game);
		p2p = P2Player(Instigator.Controller);
		if(checkg != None)
		{
			checkg.CheckForErrandCompletion(self, None, None, p2p, false);
			if(Level.NetMode != NM_DedicatedServer ) p2p.GetEntryLevel().EvaluateAchievement(p2p, 'PLCollectMoney', true);
		}

		SwapBackToHands();
	}
	else
		Super.PlayIdleAnim();
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

		// Record who we asked, so we can determine how much money they'll give
		AskedPawn = P2MocapPawn(p2p.InterestPawn);
	}
	
	bWasFiring = true;
}

///////////////////////////////////////////////////////////////////////////////
// CauseAltFire
// Overridden to simply add one to the "ammo" count.
///////////////////////////////////////////////////////////////////////////////
function CauseAltFire()
{
	//AmmoType.AddAmmo(DonationAmount);
	//P2GameInfoSingle(Level.Game).CheckForErrandCompletion(Self, None, None, P2Player(Pawn(Owner).Controller), false);

	GotoState('ReceiveMoney');
}

///////////////////////////////////////////////////////////////////////////////
// Point at which a noise is played and signature is written to clipboard
///////////////////////////////////////////////////////////////////////////////
simulated function Notify_PetitionSigned()
{
	local P2Player p2p;
	local byte StateChange;

	local int i,DonationAmount;	

	// Determine how much money they donate
	// This quits at the first match, so put subclasses first (Bums etc) before general parent classes (Bystander)
	for (i = 0; i < DonationTable.Length; i++)
	{
		log(AskedPawn@"vs"@DonationTable[i].PawnClass@DonationTable[i].MoneyGiven.Min@DonationTable[i].MoneyGiven.Max);
		if (AskedPawn.IsA(DonationTable[i].PawnClass))
		{
			DonationAmount = int(RandRange(DonationTable[i].MoneyGiven.Min, DonationTable[i].MoneyGiven.Max));
			break;
		}
	}
	
	log(self@"cause alt fire asked pawn"@askedpawn@"adding"@DonationAmount);
	PendingMoney = DonationAmount;

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
		if (PendingMoney >= MONEY_LOTS)
			Instigator.PlayOwnedSound(MoneyReceivedLots, SLOT_Misc, 1.0, , , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));
		else
			Instigator.PlayOwnedSound(MoneyReceivedLittle, SLOT_Misc, 1.0, , , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));
		AmmoType.AddAmmo(PendingMoney);
		DonationsReceived++;

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
// We're pissed off with these shitty donations so let's go find Zack
///////////////////////////////////////////////////////////////////////////////
exec function ActivateZackErrandNow()
{
	// Activate the errand and then show the new errand on the map
	P2GameInfoSingle(Level.Game).ActivateLocationTex(CAN_ERRAND_NAME);
	if (P2Player(P2Pawn(Instigator).Controller) != None)
		P2Player(P2Pawn(Instigator).Controller).DisplayMapErrands();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Statedefs
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state NormalFire
{
	///////////////////////////////////////////////////////////////////////////
	// Don't force finish on anim end... the bystander will come and force us
	// out of NormalFire when they scream and run.
	///////////////////////////////////////////////////////////////////////////
	event AnimEnd(int Channel)
	{
        // However, do force finish if we didn't "hit" anything with our shot.
        // Also exit if we don't have a Controller to base our "back to idle"
        // delay off of
        if (P2Player(Instigator.Controller).InterestPawn == None
			|| P2Player(Instigator.Controller).InterestPawn.Controller == None
			|| !P2Player(Instigator.Controller).InterestPawn.Controller.IsInState('CheckToDonate'))
		    super.AnimEnd(Channel);
		else
			PlayFiringIdle();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Statedefs
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ReceiveMoney extends NormalFire
{
	function SayThanks()
	{
		//ActivateZackErrand();
		switch (DonationsReceived)
		{
			case 1:
				P2Player(Instigator.Controller).MyPawn.Say(P2Player(Instigator.Controller).MyPawn.MyDialog.lDude_CanReceived1);
				break;
			case 2:
				P2Player(Instigator.Controller).MyPawn.Say(P2Player(Instigator.Controller).MyPawn.MyDialog.lDude_CanReceived2);
				break;
			case 3:
				P2Player(Instigator.Controller).MyPawn.Say(P2Player(Instigator.Controller).MyPawn.MyDialog.lDude_CanReceived3);
				break;
			case 4:
				P2Player(Instigator.Controller).MyPawn.Say(P2Player(Instigator.Controller).MyPawn.MyDialog.lDude_CanReceived4);
				break;
			case 5:
				P2Player(Instigator.Controller).MyPawn.Say(P2Player(Instigator.Controller).MyPawn.MyDialog.lDude_CanReceived5);
				break;
			case 6:
				P2Player(Instigator.Controller).MyPawn.Say(P2Player(Instigator.Controller).MyPawn.MyDialog.lDude_CanReceived6);
				break;
			case 7:
				P2Player(Instigator.Controller).MyPawn.Say(P2Player(Instigator.Controller).MyPawn.MyDialog.lDude_CanReceived7);
				break;
			case 8:
				GotoState('ActivateZackErrand');
				break;
			default:
				P2Player(Instigator.Controller).MyPawn.Say(P2Player(Instigator.Controller).MyPawn.MyDialog.lDude_CanReceived_SeeZack2);
				break;
		}
	}
	event EndState()
	{
		P2GameInfoSingle(Level.Game).CheckForErrandCompletion(Self, None, None, P2Player(Pawn(Owner).Controller), false);
		Super.EndState();
	}
Begin:
	Sleep(1.0);
	Notify_PetitionSigned();
	Sleep(1.0);
	SayThanks();
	GotoState('Idle');
}

state ActivateZackErrand extends Idle
{
	ignores Fire;
	
Begin:
	Sleep(P2Player(Instigator.Controller).MyPawn.Say(P2Player(Instigator.Controller).MyPawn.MyDialog.lDude_CanReceived_SeeZack1));
	Sleep(0.5);
	ActivateZackErrandNow();
	GotoState('Idle');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Weapon is up and ready to fire, but not firing.
// extends original, to keep track of shot count
// Uses the same code below it's Begin:, except we use HasAmmoFinished for
// special weapons (like the shocker) that never want to switch, but need
// to recharge eventually.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Idle
{
Begin:
	bPointing=False;
	if ( NeedsToReload() && P2AmmoInv(AmmoType).HasAmmoFinished() )
		GotoState('Reloading');
	if ( !P2AmmoInv(AmmoType).HasAmmoFinished() )
		Instigator.Controller.SwitchToBestWeapon();  //Goto Weapon that has Ammo
	if ( Instigator.PressingFire() )
	{
		Fire(0.0);
	}
	if ( Instigator.PressingAltFire() ) AltFire(0.0);
	PlayIdleAnim();
CheckLoop:
	CheckForFinishedErrand();
	Sleep(1.0);
	Goto('CheckLoop');
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	DonationTable[0]=(PawnClass="P2MoCapPawn",MoneyGiven=(Min=75,Max=125))
	ItemName="Collection Can"
	AmmoName=class'CanAmmoInv'
	PickupClass=class'CanPickup'
	AttachmentClass=class'CanAttachment'

	//Mesh=Mesh'FP_Weapons.FP_Dude_Clipboard'
	Mesh=SkeletalMesh'MrD_PL_Anims.Collection_SM'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	Skins[1]=Shader'MrD_PL_Tex.Misc.CollectionCupRusty_Shader'

	FirstPersonMeshSuffix="Collection_SM"

	bMoneyGoesToCharity=true
	WritingSound=Sound'MiscSounds.Map.CheckMark'

	bAllowHints=true
	bShowHints=true
	HudHint1="Press %KEY_Fire% to bother"
	HudHint2="someone to donate money."
	HudHint3="Keep asking if they say no!"

	DropWeaponHint1="They've seen your weapon!"
	DropWeaponHint2="Press %KEY_ThrowWeapon% to drop it."

	holdstyle=WEAPONHOLDSTYLE_Toss
	switchstyle=WEAPONHOLDSTYLE_Single
	firingstyle=WEAPONHOLDSTYLE_Single

	ThirdPersonRelativeLocation=(X=6,Z=5)
	ThirdPersonRelativeRotation=(Yaw=-1600,Roll=-16384)
	
	MoneyReceivedLittle=Sound'PL_WeaponSnd.CC-SingleCoin03'
	MoneyReceivedLots=Sound'PL_WeaponSnd.CC-MultiCoin11'
	
	PlayerViewOffset=(X=2,Y=0,Z=-8)
}
