///////////////////////////////////////////////////////////////////////////////
// PhotoWeapon
// Copyright 2014 Running With Scissors Inc, All Rights Reserved
//
// A photo of Champ the dude carries around. Works like the Clipboard.
// Fire: dude points at targeted bystander, then flips the photo around
// and asks "have you seen this dog". Bystander runs away screaming.
// As the Dude asks more and more people he gets more and more annoyed,
// eventually asking "Hey fuckhead, are you going to run screaming if I show you
// this picture?"
// On the 9th firing, dude simply threatens to kill the bystander's dog, who
// responds by telling him to go see the Wise Man, completing the errand.
///////////////////////////////////////////////////////////////////////////////
class PhotoWeapon extends ClipboardWeapon;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var bool bHasAskedSomeone, bPreviouslyAsked;

var range PhotoGestureEndDelay;

var array<sound> ReactionSounds, SamePersonSounds;

var Controller AskedPawnController;
var array<FPSPawn> AskedPawns;

var float CurrentAskTime, AskTime;

var Font DebugFont;

function bool HavePreviouslyAsked(FPSPawn Other) {
    local int i;

    for (i=0;i<AskedPawns.length;i++)
        if (Other == AskedPawns[i])
            return true;

    return false;
}

function AddToAskedList(FPSPawn Other) {
    AskedPawns.Insert(AskedPawns.length, 1);
    AskedPawns[AskedPawns.length-1] = Other;
}

///////////////////////////////////////////////////////////////////////////////
// Play firing animation/sound/etc
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring()
{
	PlayAnim('Gesture_Begin', WeaponSpeedShoot1, 0.05);
}

simulated function PlayGestureLoop()
{
	LoopAnim('Gesture_Loop', WeaponSpeedShoot1, 0.05);
}

simulated function PlayGestureEnd()
{
    PlayAnim('Gesture_End', WeaponSpeedShoot1, 0.05);
}

///////////////////////////////////////////////////////////////////////////////
// Yo Rick, if you wanna perform a different style of playing sounds other
// than my half-assed method below, override this function
///////////////////////////////////////////////////////////////////////////////
simulated function PlayReactionDialog() {
	switch (AmmoType.AmmoAmount)
	{
		case 2:
			P2Player(Instigator.Controller).MyPawn.Say(P2Player(Instigator.Controller).MyPawn.MyDialog.lPhoto_DudeReact1);
			break;
		case 3:
			P2Player(Instigator.Controller).MyPawn.Say(P2Player(Instigator.Controller).MyPawn.MyDialog.lPhoto_DudeReact2);
			break;
		case 4:
			P2Player(Instigator.Controller).MyPawn.Say(P2Player(Instigator.Controller).MyPawn.MyDialog.lPhoto_DudeReact3);
			break;
		case 5:
			P2Player(Instigator.Controller).MyPawn.Say(P2Player(Instigator.Controller).MyPawn.MyDialog.lPhoto_DudeReact4);
			break;
		case 6:
			P2Player(Instigator.Controller).MyPawn.Say(P2Player(Instigator.Controller).MyPawn.MyDialog.lPhoto_DudeReact5);
			break;
		case 7:
			P2Player(Instigator.Controller).MyPawn.Say(P2Player(Instigator.Controller).MyPawn.MyDialog.lPhoto_DudeReact6);
			break;
		default:
			P2Player(Instigator.Controller).MyPawn.Say(P2Player(Instigator.Controller).MyPawn.MyDialog.lPhoto_DudeReact7);
			break;
	}

	/*
    local sound ReactionSound;

    ReactionSound = ReactionSounds[Rand(ReactionSounds.length)];

    if (ReactionSound != none)
        Instigator.PlaySound(ReactionSound, SLOT_Talk, 1, false, 300);
	*/
}

simulated function PlaySamePersonDialog() {
	P2Player(Instigator.Controller).MyPawn.Say(P2Player(Instigator.Controller).MyPawn.MyDialog.lPhoto_DudeAskSomeoneElse);
	/*
    local sound SamePersonSound;

    SamePersonSound = SamePersonSounds[Rand(SamePersonSounds.length)];

    if (SamePersonSound != none)
        Instigator.PlaySound(SamePersonSound, SLOT_Talk, 1, false, 300);
	*/
}

///////////////////////////////////////////////////////////////////////////////
// CauseAltFire
// Overridden to simply add one to the "ammo" count.
///////////////////////////////////////////////////////////////////////////////
function CauseAltFire()
{
	//log("CauseAltFire method called...");

    AmmoType.AddAmmo(1);
	P2GameInfoSingle(Level.Game).CheckForErrandCompletion(Self, None, None, P2Player(Pawn(Owner).Controller), false);

    // Only go back to idle immediately if we were told about the Wise Wang
    if (AmmoType != none && AmmoType.AmmoAmount == AmmoType.MaxAmmo)
        GotoState('ReturnToIdle');
}

exec function wisewang()
{
    AmmoType.AddAmmo(999);
	P2GameInfoSingle(Level.Game).CheckForErrandCompletion(Self, None, None, P2Player(Pawn(Owner).Controller), false);
}

///////////////////////////////////////////////////////////////////////////////
// We need this here to prevent the player from going on an asking loop after
// he or she has heard of the wise wang and is still holding down the Fire key
///////////////////////////////////////////////////////////////////////////////
simulated function Fire(float F)
{
    if (AmmoType.AmmoAmount < AmmoType.MaxAmmo)
        super.Fire(F);
}

///////////////////////////////////////////////////////////////////////////////
// Redefining so we can differentiate between having asked someone and losing
// them, or having an InterestPawn that runs away in fear
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

        bHasAskedSomeone = (p2p.InterestPawn != none);

		if (bHasAskedSomeone) {

            if (p2p.InterestPawn.Controller != none)
                AskedPawnController = p2p.InterestPawn.Controller;

            bPreviouslyAsked = HavePreviouslyAsked(p2p.InterestPawn);

		    if (!bPreviouslyAsked)
                AddToAskedList(p2p.InterestPawn);
        }
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Statedefs
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state NormalFire
{
    ///////////////////////////////////////////////////////////////////////////
    // Stubbed out to ensure the player can't screw with the firing
    ///////////////////////////////////////////////////////////////////////////
    simulated function Fire(float F);
    simulated function AltFire(float F);

    ///////////////////////////////////////////////////////////////////////////
    // Setup our alternate Timer
    ///////////////////////////////////////////////////////////////////////////
    function BeginState() {

        CurrentAskTime = 0;
        AskTime = 98.0 / (30.0 * WeaponSpeedShoot1);
    }

    ///////////////////////////////////////////////////////////////////////////
    // Alright, you're probably wondering why the hell I'm using the Tick
    // function to create a Timer as opposed to using the normal Timer() or the
    // AnimEnd() functions.
    //
    // If Player holds the the fire button, then when the weapon hits Idle, it
    // will instantly go into the NormalFire state.
    //
    // If the AnimEnd() function is used to direct the PhotoWeapon to the next
    // state, then it instantly gets Triggered by the end of the bring up
    // animation which causes it to go directly to putting the photo back
    // down, or in other words the ReturnToIdle state
    //
    // If we have it governed by the Timer() function, apparently there's a
    // a previous Timer running or something, I dunno, that causes it to go
    // into the ReturnToIdle state about half a second after the asking
    // animation starts so that doesn't work.
    //
    // So I used the Tick function to make a makeshift Timer that's independent
    // from those two to tell this bug to fuck off.
    ///////////////////////////////////////////////////////////////////////////
    function Tick(float DeltaTime) {
        CurrentAskTime = FMin(CurrentAskTime + DeltaTime, AskTime);

        if (CurrentAskTime == AskTime)
            DecideNextState();
    }

    ///////////////////////////////////////////////////////////////////////////
	// If we weren't able to ask anyone, put the Photo back down, otherwise
	// wait for the Bystander's response
	///////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
        // However, do force finish if we didn't "hit" anything with our shot.
        // Also exit if we don't have a Controller to base our "back to idle"
        // delay off of
        if (!bHasAskedSomeone || AskedPawnController == none)
		    GotoState('ReturnToIdle');
        else
            GotoState('WaitForResponse');
	}
}

state WaitForResponse
{
    ///////////////////////////////////////////////////////////////////////////
    // Stubbed out to ensure the player can't screw with the firing
    ///////////////////////////////////////////////////////////////////////////
    simulated function Fire(float F);
    simulated function AltFire(float F);

    ///////////////////////////////////////////////////////////////////////////
    // Loop our wait gesture animation
    ///////////////////////////////////////////////////////////////////////////
    function BeginState()
    {
        PlayGestureLoop();

        SetTimer(0.1, false);
    }

    ///////////////////////////////////////////////////////////////////////////
    // Put down our photo after they're done looking at the photo or they're
    // finished screaming at the picture along with a short delay after that
    ///////////////////////////////////////////////////////////////////////////
    function Timer()
    {
		if ((!AskedPawnController.IsInState('CheckToDonate') &&
             !AskedPawnController.IsInState('ScreamingStill')) ||
             AskedPawnController == none)
             GotoState('ReturnToIdleDelay');
        else
            SetTimer(0.1, false);
    }
}

state ReturnToIdleDelay
{
    ///////////////////////////////////////////////////////////////////////////
    // Stubbed out to ensure the player can't screw with the firing
    ///////////////////////////////////////////////////////////////////////////
    simulated function Fire(float F);
    simulated function AltFire(float F);

    ///////////////////////////////////////////////////////////////////////////
    // Set a timer so we can implement a short delay before going back to idle
    ///////////////////////////////////////////////////////////////////////////
    function BeginState()
    {
        SetTimer(RandRange(PhotoGestureEndDelay.Min,
            PhotoGestureEndDelay.Max), false);
    }

    ///////////////////////////////////////////////////////////////////////////
    // After a set amount of time, we transition back to Idle
    ///////////////////////////////////////////////////////////////////////////
    function Timer()
    {
        GotoState('ReturnToIdle');
    }
}

state ReturnToIdle
{
    ///////////////////////////////////////////////////////////////////////////
    // Stubbed out to ensure the player can't screw with the firing
    ///////////////////////////////////////////////////////////////////////////
    simulated function Fire(float F);
    simulated function AltFire(float F);

    ///////////////////////////////////////////////////////////////////////////
    // Begin by playing the gesture end animation
    ///////////////////////////////////////////////////////////////////////////
    function BeginState()
    {
        PlayGestureEnd();

        if (AmmoType.AmmoAmount < AmmoType.MaxAmmo) {
            if (bPreviouslyAsked)
                PlaySamePersonDialog();
            else if (bHasAskedSomeone)
                PlayReactionDialog();
        }

        AskedPawnController = none;
    }

    ///////////////////////////////////////////////////////////////////////////
    // At the end of the animation, finally go back to Idle
    ///////////////////////////////////////////////////////////////////////////
    event AnimEnd(int Channel)
    {
        GotoState('Idle');
    }
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	DebugFont=Font'P2Fonts.Fancy24'

	PhotoGestureEndDelay=(Min=0.5,Max=0.75)

    ReactionSounds(0)=sound'DudeDialog.dude_fuck'
	ReactionSounds(1)=sound'DudeDialog.dude_fuck2'
	ReactionSounds(2)=sound'DudeDialog.dude_fuck3'
	ReactionSounds(3)=sound'DudeDialog.dude_fuck4'

	SamePersonSounds(0)=sound'DudeDialog.dude_oops'

    ItemName="Photo"
	AmmoName=class'PhotoAmmoInv'
	PickupClass=class'PhotoPickup'
	AttachmentClass=class'PhotoAttachment'

	Mesh=Mesh'PL_Weapons_Anims.PL_LostDog'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	Skins[1]=Texture'MrD_PL_Tex.Weapons.photo_back'
	Skins[2]=Shader'MrD_PL_Tex.Weapons.Photo_Shader'
	WritingSound=None

	HudHint1="Press %KEY_Fire% to"
	HudHint2="ask someone about Champ."
	HudHint3=""

	WeaponSpeedHolster = 3.5
	WeaponSpeedLoad    = 1.5
	WeaponSpeedReload  = 1.5
	WeaponSpeedShoot1  = 1.2
	WeaponSpeedShoot1Rand=0.3
	WeaponSpeedShoot2  = 1.0
	
	PlayerViewOffset=(X=2,Y=0,Z=-7)
}
