/**
 * P2EHandsWeapon
 *
 * An improved version of the originally HandsWeapon that allows the player
 * to pick stuff up such as corpses, body parts, and KActors
 *
 * In enhanced mode, the player can pickup practically anything that isn't
 * nailed down from living pawns, to elephants, to cars, to rockets!
 */
class P2EHandsWeapon extends HandsWeapon;

/** Struct defining what classes we can hold and how to handle them */
struct ActorPolicy {
    /** Class of the object that we can hold */
    var class<Actor> ActorClass;
    /** Whether or not we can only hold this item in enhanced mode */
    var bool bEnhancedModeOnly;
    /** Whether or not we need to hold the object in a special way such as ragdolls */
    var bool bSpecialHold;
    /** Whether or not we should perform additional handling of said object */
    var bool bSpecialThrow;
    /** Distance in front of the player to hold the object */
    var float HoldDistance;
    /** Velocity to throw the object, or the velocity component of Impulse for KActors */
    var float ThrowVelocity;
};

/** A list of Actor policies defining what and how to interact with them */
var array<ActorPolicy> ActorPolicies;

/** Distance away from the player to hold the item */
var float ActorCheckDistance;

/** Strength of the imaginary "spring" used to hold ragdolls */
var float RagdollSpringConstant;
/** Velocity component of the impulse to apply to the ragdoll */
var float RagdollThrowVelocity;
/** Time in seconds to continuously add force to a ragdoll */
var float RagdollThrowDuration;
/** Elapsed time in seconds the ragdoll has had Impulse applied */
var float RagdollThrowTime;
/** Direction the ragdoll should be thrown */
var vector RagdollThrowDir;
/** Actor object to continously apply Impulse to simulate "throwing" */
var P2Pawn Ragdoll;

/** Actor policy that contains the throw velocity component of the Impulse */
var int KActorThrowPolicy;
/** Time in seconds the impulse to the KActor */
var float KActorThrowDuration;
/** Elapsed time in seconds the KActor has had Impulse applied */
var float KActorThrowTime;
/** Direction the KActor should be thrown */
var vector KActorThrowDir;
/** KActor object to continuously apply Impulse to */
var KActor KActor;

/** Object that is currently being held */
var Actor HeldActor;
/** Index of the policy we use to handle said held object */
var int HeldActorPolicy;

/** Font used for Canvas debug text rendering */
var Font DebugFont;

var travel bool bShowHint1;

const MAX_CHARGE_TIME = 1.0;
const CHARGE_FACTOR = 2.0;
var float ChargeTime;
var float ChargeStart;
var color ProgressBarColor;

///////////////////////////////////////////////////////////////////////////////
// Give hints about this item
///////////////////////////////////////////////////////////////////////////////
function bool GetHints(out String str1, out String str2, out String str3,
				out byte InfiniteHintTime)
{
	if(bAllowHints)
	{
		if(bShowHint1)
			str1=HudHint1;
		else
			str2=HudHint2;
		return true;
	}
	return false;
}
///////////////////////////////////////////////////////////////////////////////
// Allow hints again
///////////////////////////////////////////////////////////////////////////////
function RefreshHints()
{
	Super.RefreshHints();
	bShowHint1=true;
}

/** Returns whether or not we are currently holding an Actor
 * @return TRUE if we are currently holding an Actor; FALSE otherwise
 */
function bool HasHeldActor() {
    return (HeldActor != none && HeldActorPolicy >= 0);
}

/** Returns whether or not an object is holdable considering enhanced mode as
 *  well as putting in consideration for special cases
 *
 * @param Index - Index of the Actor Policy list of whether or not it's
 *                holdable-ness is exlusive to enhanced mode
 * @param Other - Actor to use to check for it's specific class
 * @return TRUE if the Actor can be held; FALSE otherwise
 */
function bool IsHoldableWithEnhancedMode(int Index, Actor Other) {
    local bool bEnhancedMode;

    bEnhancedMode = P2GameInfoSingle(Level.Game).VerifySeqTime();

    // For debugging purposes, allow everything to be picked up
    return true;

    // If we're not in enhanced mode, enforce restrictions and more
    // complicated rules
    if (!bEnhancedMode) {

        // All Pawns can only be picked up when dead
        if (ClassIsChildOf(Other.class, class'Pawn') && Pawn(Other).Health > 0.0f)
            return false;

        // And finally if the Actor can only be picked up in Enhanced mode
        if (ActorPolicies[Index].bEnhancedModeOnly)
            return false;
    }

    // If we're in enhanced, just let them pickup anything
    return true;
}

/** Returns whether or not the Actor is a holdable class
 * @param Other - Object to get the policy index for
 * @return Index of the Actor policy to use; -1 if the Actor is not a holdable class
 */
function int GetPolicyIndex(Actor Other) {
    local int i;

    if (Other == none) return -1;

    for (i=0;i<ActorPolicies.length;i++)
        if (ClassIsChildOf(Other.class, ActorPolicies[i].ActorClass))
            return i;

    return -1;
}

// Returns true if Other is constrained via KHinge, etc
function bool IsConstrained(KActor Other)
{
	local KConstraint KC;

	foreach DynamicActors(class'KConstraint', KC)
		if (KC.KConstraintActor1 == Other || KC.KConstraintActor2 == Other)
			return true;

	return false;
}

/** Returns a vector location in the world where the HeldActor should be held at
 * @return Location in the world where the HeldActor should be held at
 */
function vector GetHoldLocation() {
    if (HeldActorPolicy < 0) return vect(0,0,0);

    return Instigator.Location + Instigator.EyePosition() +
           vector(Rotation) * ActorPolicies[HeldActorPolicy].HoldDistance;
}

/** Perform a standard hold used for most Actors */
function HoldActor() {
    HeldActor.SetLocation(GetHoldLocation());
    HeldActor.Velocity = Instigator.Velocity;
}

/** Perform a standard throw used for most Actors
 * @param bDrop - Whether or not we're dropping the held actor or throwing it
 */
function ThrowActor(bool bDrop) {
    if (KActor(HeldActor) != none) {
        HeldActor.SetPhysics(PHYS_Karma);
        HeldActor.KWake();

        if (!bDrop) {
            KActorThrowPolicy = HeldActorPolicy;
            KActorThrowTime = 0.0f;
            KActorThrowDir = vector(Rotation);
            KActor = KActor(HeldActor);
        }
		if (KActorExplodable(HeldActor) != None)
			KActorExplodable(HeldActor).bReadyForImpact=true;
		HeldActor.KAddImpulse(KActorThrowDir * ActorPolicies[HeldActorPolicy].ThrowVelocity * GetTossMult(), HeldActor.Location);
    }
    else {
        HeldActor.SetPhysics(PHYS_Falling);

        if (!bDrop)
            HeldActor.Velocity = vector(Rotation) * ActorPolicies[HeldActorPolicy].ThrowVelocity * GetTossMult();
    }
	if (!bDrop)
		Instigator.PlaySound(FireSound, SLOT_None, 1.0, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));
	TurnOffHint();
}

/** Perform any special function calls when we first initially take hold */
function SpecialHoldPrep() {
    // Be sure to check whether or not the P2Pawn is alive or a ragdoll
    if (P2Pawn(HeldActor) != none) {
        if (P2Pawn(HeldActor).Health > 0.0f)
            HeldActor.SetPhysics(PHYS_Projectile);
        else
		{
			// If their skeleton was taken away, give it back
			if (P2MoCapPawn(HeldActor) != None)
			{
				if (HeldActor.KParams == None)
					// "kick" it back to life
					HeldActor.TakeDamage(1, Instigator, HeldActor.Location, vect(0,0,0), class'P2Damage');
				else
					HeldActor.KWake();
			}
            else
				HeldActor.KWake();
		}
    }
	
	// For living pawns, make them know that you're dragging them around
	if (P2Pawn(HeldActor) != None
		&& P2Pawn(HeldActor).Controller != None)
	{
		HeldActor.Instigator = Instigator;
		HeldActor.SetPhysics(PHYS_Falling);
		if (LambController(Pawn(HeldActor).Controller) != None)
		{
			// If it's a cop, you're not gonna take any crap from the dude
			if (P2Pawn(HeldActor).bAuthorityFigure)
				LambController(Pawn(HeldActor).Controller).DamageAttitudeTo(Instigator, 1);
			// otherwise, get annoyed
			else
				LambController(Pawn(HeldActor).Controller).InterestIsAnnoyingUs(Instigator, false);
		}
	}

    // Transfer owners for projectiles
    if (P2Projectile(HeldActor) != none)
        P2Projectile(HeldActor).TransferInstigator(Instigator);
}

/** Perform unique form of holding on Actors that need it */
function SpecialHoldActor() {
    local float k;
    local vector x;
    // Be sure to check whether or not the P2Pawn is alive or a ragdoll
    if (P2Pawn(HeldActor) != none) {
        if (P2Pawn(HeldActor).Health > 0.0f)
            HoldActor();
        else {
            // Note to self: Hooke's Law: F = kx
            // For all the physics guys saying my implementation it's wrong,
            // it's close enough!
            k = RagdollSpringConstant * VSize(GetHoldLocation() - HeldActor.Location);
            x = Normal(GetHoldLocation() - HeldActor.Location);
            HeldActor.KAddImpulse(k * x, HeldActor.Location);
        }
    }

    // After Prep has been done on special projectiles, hold them normally
    if (P2Projectile(HeldActor) != none)
        HoldActor();
}

/** Perform a special throw for the object we're holding
 * @param bDrop - Whether or not we're dropping the held actor or throwing it
 */
function SpecialThrowActor(bool bDrop) {
    // Be sure to check whether or not the P2Pawn is alive or a ragdoll
    if (P2Pawn(HeldActor) != none) {
        if (P2Pawn(HeldActor).Health > 0.0f)
            ThrowActor(bDrop);
        else if (!bDrop) {
            Ragdoll = P2Pawn(HeldActor);
            RagdollThrowDir = vector(Rotation);
            RagdollThrowTime = 0.0f;
			Instigator.PlaySound(FireSound, SLOT_None, 1.0, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));
        }
    }

    // For PeopleParts, call the GiveMomentum to get them acting like they were
    // kicked or something
    if (PeoplePart(HeldActor) != none) {
        if (bDrop)
            PeoplePart(HeldActor).GiveMomentum(vect(0,0,0));
        else {
            PeoplePart(HeldActor).GiveMomentum(vect(0,0,0));
            HeldActor.Velocity = vector(Rotation) * ActorPolicies[HeldActorPolicy].ThrowVelocity * GetTossMult();
        }
    }

    // Just like PeopleParts, get them behaving as if they were kicked
    if (GrenadeProjectile(HeldActor) != none) {
        HeldActor.SetPhysics(PHYS_Projectile);
        GrenadeProjectile(HeldActor).bBounce = true;
        GrenadeProjectile(HeldActor).MakeSmokeTrail();
        HeldActor.Acceleration = HeldActor.default.Acceleration;
        HeldActor.Velocity = vector(Rotation) * ActorPolicies[HeldActorPolicy].ThrowVelocity * GetTossMult();
    }

    // Erase a seeking projectile's ability to seek and just go where you throw it
    if (LauncherSeekingProjectileTrad(HeldActor) != none) {
        LauncherSeekingProjectileTrad(HeldActor).SeekingAccelerationMag = 0.0f;
        LauncherSeekingProjectileTrad(HeldActor).GravAccZ = 0.0f;
        LauncherSeekingProjectileTrad(HeldActor).BounceMax = 0;

        HeldActor.SetPhysics(PHYS_Projectile);
        HeldActor.Acceleration = vect(0,0,0);
        HeldActor.Velocity = vector(Rotation) * ActorPolicies[HeldActorPolicy].ThrowVelocity * GetTossMult();
    }
	
	HeldActor.Instigator = Instigator;

	TurnOffHint();
}

/** Resets the HeldActor and HeldActorPolicy variables */
function ResetHeldActor() {
    HeldActor = none;
    HeldActorPolicy = -1;
}

/** Attempts to find a holdable Actor */
function FindHoldableActor() {
    local int    ActorPolicyIndex;
    local vector HitLocation, HitNormal, EndTrace, StartTrace;
    local Actor  Other;

    StartTrace = Instigator.Location + Instigator.EyePosition();
    EndTrace = StartTrace + vector(Rotation) * ActorCheckDistance;
    Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
    ActorPolicyIndex = GetPolicyIndex(Other);

    if (Other != none && ActorPolicyIndex >= 0 &&
        IsHoldableWithEnhancedMode(ActorPolicyIndex, Other)
		&& KActorExplodable(Other) == None
		&& (KActor(Other) == None || !IsConstrained(KActor(Other)))
		) {
        HeldActor = Other;
        HeldActorPolicy = ActorPolicyIndex;
		bShowHint1=false;
		UpdateHudHints();

        // Might need to perform some physics changes
        if (ActorPolicies[HeldActorPolicy].bSpecialHold)
            SpecialHoldPrep();
        else
            HeldActor.SetPhysics(PHYS_Projectile);

        //log(self$": Holding Actor: " $ HeldActor);
    }
    //else
        //log(self$": No Holdable Actor found");
}

/** Throws the currently held Actor, or drops it
 * @param bDrop - Whether or not we should throw
 */
function ThrowHeldActor(bool bDrop) {
    if (ActorPolicies[HeldActorPolicy].bSpecialThrow)
        SpecialThrowActor(bDrop);
    else
        ThrowActor(bDrop);

    //log(self$": Thrown held Actor: " $ HeldActor);
    ResetHeldActor();
}

/** Modified to perform a holdable Actor check */
function ServerFire() {
	if (!Level.Game.bIsSinglePlayer) {
		P2MocapPawn(Instigator).ServerFollowMe();
		PlayFiring();
		GotoState('NormalFire');
	}
	else {
	    if (HeldActor != none)
	        ThrowHeldActor(true);
        else
            FindHoldableActor();
	}
}

/** Modified to perform a throw */
function ServerAltFire() {
	if (!Level.Game.bIsSinglePlayer) {
		P2MocapPawn(Instigator).ServerStayHere();

		bAltFiring=true;

		PlayAltFiring();
		GotoState('NormalFire');
	}
	else {
	    if (HeldActor != none) {
            //ThrowHeldActor(false);
			GotoState('ChargingThrow');
        }
	}
}

/** Modified so it'll call ServerFire() reguardless */
simulated function Fire(float Value) {
    ServerFire();

    if (Role < ROLE_Authority) {
        PlayFiring();
        GotoState('ClientFiring');
    }
}

/** Modified so it'll call AltFire() reguardless */
simulated function AltFire(float Value) {
	ServerAltFire();

    if (Role < ROLE_Authority) {
        PlayAltFiring();
        GotoState('ClientFiring');
    }
}

/** Render debug information to streamline developement */
/*
simulated event RenderOverlays(Canvas Canvas) {
    local float DebugTextY;
    local vector HoldLocation;

    if (HeldActorPolicy >= 0)
        HoldLocation = Instigator.Location + Instigator.EyePosition() +
                   vector(Rotation) * ActorPolicies[HeldActorPolicy].HoldDistance;

    super.RenderOverlays(Canvas);

    Canvas.SetPos(0, 0);
    Canvas.SetDrawColor(255, 255, 255, 255);
    Canvas.Font = DebugFont;

    Canvas.DrawText("KActor: " $ KActor);
    DebugTextY += 20.f;

    Canvas.SetPos(0, DebugTextY);
    Canvas.DrawText("KActorThrowTime: " $ KActorThrowTime);
    DebugTextY += 20.f;
}
*/

/** Subclassed so update held objects */
function Tick(float DeltaTime) {
    super.Tick(DeltaTime);

    // Kinda expensive with the constant variable setting here unfortunately
    // Might need to refine this if-else statement... later!
    if (HasHeldActor()) {
        if (ActorPolicies[HeldActorPolicy].bSpecialHold)
            SpecialHoldActor();
        else
            HoldActor();
    }
    else
        ResetHeldActor();

    if (Ragdoll != none) {
        RagdollThrowTime += DeltaTime;

        if (RagdollThrowTime < RagdollThrowDuration)
            Ragdoll.KAddImpulse(RagdollThrowDir * RagdollThrowVelocity * Ragdoll.Mass * DeltaTime, Ragdoll.Location);
        else
            Ragdoll = none;
    }

    if (KActor != none) {
        KActorThrowTime += DeltaTime;

        if (KActorThrowTime < KActorThrowDuration)
            KActor.KAddImpulse(KActorThrowDir * ActorPolicies[KActorThrowPolicy].ThrowVelocity * KActor.Mass * DeltaTime, KActor.Location);
        else
            KActor = none;
    }
}

state Idle
{
	/** Override these two functions so the Hands never go into bStasis */
	function EndState();
	function BeginState();

Begin:
}

// DownWeapon
// Drop anything we're carrying before we switch to some other weapon, usually a firearm to handle attackers
state DownWeapon
{
	simulated function BeginState()
	{
		ThrowHeldActor(true);
		Super.Beginstate();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Draw percentage bar
///////////////////////////////////////////////////////////////////////////////
simulated function DrawPercBar(Canvas Canvas, float ScreenX, float ScreenY, float Width, float Height, float Border, Color Fore, float Perc)
{
	local float InnerWidth;
	local float InnerHeight;

	Canvas.Style = ERenderStyle.STY_Alpha;

	Canvas.SetPos(ScreenX - (Width/2), ScreenY);
	Canvas.SetDrawColor(0,0,0,byte(float(Fore.A)*0.75));
	if (Canvas.DrawColor.A > 0)
		Canvas.DrawRect(Texture'engine.WhiteSquareTexture', Width, Height);

	InnerWidth = Width - 2 * Border;
	InnerHeight = Height - 2 * Border;

	Canvas.SetPos(ScreenX - (InnerWidth/2), ScreenY + Border);
	Canvas.DrawColor = Fore;
	if (Canvas.DrawColor.A > 0)
		Canvas.DrawRect(Texture'engine.WhiteSquareTexture', InnerWidth * Perc, InnerHeight);
}

function float GetTossMult()
{
	if (ChargeTime != 0)
		return ChargeTime * CHARGE_FACTOR;
	else
		return 1;
}

state ChargingThrow extends Idle
{
	ignores Fire, AltFire, ServerFire, ServerAltFire, TraceFire, TraceAltFire;

	simulated function RenderOverlays(Canvas Canvas)
	{
		local float ScreenX, ScreenY, Width, Height, Border, Perc;
		
		ScreenX = Canvas.SizeX/2;
		ScreenY = Canvas.SizeY*4/5;
		Width = Canvas.SizeX/4;
		Height = Canvas.SizeY/20;
		Border = 2;
		Perc = (Level.TimeSeconds-ChargeStart)/MAX_CHARGE_TIME;
		DrawPercBar(Canvas, ScreenX, ScreenY, Width, Height, Border, ProgressBarColor, Perc);
		Super.RenderOverlays(Canvas);
	}

	simulated event BeginState()
	{
		ChargeStart = Level.TimeSeconds;
	}
	simulated function FinishShot()
	{
		if (NotDedOnServer())
		{
			ChargeTime = Level.TimeSeconds - ChargeStart;
			ThrowHeldActor(False);
			ChargeTime = 0;
		}
		GotoState('Idle');
	}
	simulated event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);
		if (NotDedOnServer() && !Instigator.PressingAltFire() || Level.TimeSeconds-ChargeStart >= MAX_CHARGE_TIME)
			FinishShot();
	}
}

defaultproperties
{
    /** Put subclasses first so the Karma Gun will handle specific cases before
     * handling more general cases
     */
    ActorPolicies(0)=(ActorClass=class'PeoplePart',bSpecialThrow=true,HoldDistance=64.0f,ThrowVelocity=1024.0f)
    ActorPolicies(1)=(ActorClass=class'CarExplodable',bEnhancedModeOnly=true,HoldDistance=256.0f,ThrowVelocity=10000.0f)
    ActorPolicies(2)=(ActorClass=class'BarrelExplodable',bEnhancedModeOnly=true,HoldDistance=128.0f,ThrowVelocity=1024.0f)
    ActorPolicies(3)=(ActorClass=class'KActor',HoldDistance=128.0f,ThrowVelocity=100000.0f)
    ActorPolicies(4)=(ActorClass=class'GrenadeProjectile',bSpecialHold=true,bSpecialThrow=true,HoldDistance=128.0f,ThrowVelocity=1024.0f)
    ActorPolicies(5)=(ActorClass=class'LauncherSeekingProjectileTrad',bEnhancedModeOnly=true,bSpecialThrow=true,HoldDistance=128.0f,ThrowVelocity=2048.0f)
    ActorPolicies(6)=(ActorClass=class'GaryHeadHomingProjectile',bEnhancedModeOnly=true,bSpecialHold=true,bSpecialThrow=true,HoldDistance=64.0f,ThrowVelocity=1024.0f)
    ActorPolicies(7)=(ActorClass=class'P2Projectile',bEnhancedModeOnly=true,bSpecialHold=true,HoldDistance=64.0f,ThrowVelocity=1024.0f)
    ActorPolicies(8)=(ActorClass=class'ElephantPawn',bEnhancedModeOnly=true,HoldDistance=512.0f,ThrowVelocity=2048.0f)
    ActorPolicies(9)=(ActorClass=class'AnimalPawn',bEnhancedModeOnly=true,HoldDistance=128.0f,ThrowVelocity=1024.0f)
    ActorPolicies(10)=(ActorClass=class'P2Pawn',bSpecialHold=true,bSpecialThrow=true,HoldDistance=128.0f,ThrowVelocity=1024.0f)

    ActorCheckDistance=192.0f

    RagdollSpringConstant=1024.0f
    RagdollThrowVelocity=10000.0f
    RagdollThrowDuration=0.25f

    KActorThrowDuration=0.25f

    HeldActorPolicy=-1

    DebugFont=Font'P2Fonts.Fancy24'

    bNoHudReticle=false
	bAllowMiddleFinger=True
	FireSound=Sound'AW7Sounds.KarmaGun.object_throw'

	bAllowHints=true
	bShowHints=true
	bShowHint1=true
	HudHint1="Press %KEY_Fire% to pick some objects up."
	HudHint2="Press %KEY_Fire% to drop or %KEY_AltFire% to throw."

	ProgressBarColor=(R=255,G=0,B=0,A=192)
	}