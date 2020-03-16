/**
 * GaryGhostController
 *
 * AI Controller for the Gary Ghost.
 * Wanders aimlessly until approached by the Dude, then fades out.
 */
class GaryGhostController extends P2EAIController;

/** Distance away from the MoveTarget that's considered reached */
var float DestReachedRange;

/** Time in econds before Gary Ghost "thinks" while Idle */
var float IdleThinkInterval;
/** Time in seconds before Gary Ghost "thinks" while Wandering */
var float WanderThinkInterval;
var float IdleSoundInterval;

/** List of idle animations for Gary Ghost */
var array<AnimInfo> IdleAnims;

/** Fade-out anim */
var AnimInfo FadeAnim;

/** Sound to play when fading out */
var array<String> FadeSounds;

/** Sound to play when roaming */
var array<String> IdleSounds;

/** Random PathNode to walk to */
var PathNode WanderDest;

/** Speed that Gary Ghost will move at when just wandering around */
var float WalkSpeed;

/** Fadeout vars */
var float FadeOutStartTime, FadeOutDuration;

/** Returns whether or not Gary Ghost has reached his wander destination
 * @return TRUE if Gary has reached his destination; FALSE otherwise
 */
function bool HasReachedWanderDest() {
    return VSize(WanderDest.Location - Pawn.Location) < DestReachedRange;
}

/** Overriden to grab variables from */
function Possess(Pawn aPawn) {
	LogDebug(Self@"Possess"@aPawn);
    super.Possess(aPawn);

    aPawn.SetPhysics(PHYS_Falling);

    GotoState('Idle');
	LogDebug(Self@"Going to Idle");
}

/** Overriden to implement the proper function calls */
function TimerFinished(name ID) {
    switch (ID) {
        case 'IdleThink':
            IdleThink();
            break;
        case 'WanderThink':
            WanderThink();
            break;
		case 'FadeOutEarly':
			if (!IsInState('FadeOut'))
				GotoState('FadeOut');
			break;
		case 'IdleSound':
			PlayIdleSound();
			break;
    }
}

/** Think logic for Gary Ghost should use while idle. He'll basically be
 * looking at the surrounding Pawns for the Postal Dude
 */
function IdleThink() {
    LogDebug("IdleThink() method called...");

    CheckSurroundingPawns();
}

/** Think logic for Gary Ghost should use while wandering around. While
 * wandering, he'll basically check if he's reached his destination yet and
 * look out for the player
 */
function WanderThink() {
    LogDebug("WanderThink() method called...");

    CheckSurroundingPawns();

    if (HasReachedWanderDest())
        GotoState('Idle');
}

/** Overriden to implement what Gary Ghost should do when he sees a
 * particular Pawn
 */
function PawnSeen(Pawn Other) {
	FacePlayerAndFadeOut(Other);
}

/** Notification from our Pawn that the player has bumped into me */
event bool NotifyBump(Actor Other) {
	if (Pawn(Other) != None)
		FacePlayerAndFadeOut(Pawn(Other));
	return false;
}

/** If we haven't already, turn to face the player and fade out */
function FacePlayerAndFadeOut(Pawn FaceMe)
{
	// Don't do it if it's not the player
	if (FaceMe.Controller == None || !FaceMe.Controller.bIsPlayer)
		return;
		
	// Don't do it if we're already turning/fading
	if (IsInState('TurnToFacePlayer') || IsInState('FadeOut'))
		return;
		
	// Not if we're unseen
	if (!Pawn.PlayerCanSeeMe())
		return;
		
	// Otherwise, set focus and face the player
	Focus = FaceMe;
	GotoState('TurnToFacePlayer');
}

/** Poof out of existance when the Leprechaun is killed. Nice and magical,
 * plus the ragdoll doesn't look right with this scaling
 */
function PoofOutOfExistance() {
    //LeprechaunGary.PoofOutOfExistance();
	Pawn.Destroy();
    Destroy();
}

/** Scream at the top of our tiny lungs at the sight of the Dude */
function float PlayFadeSound() {
	local Sound UseSound;
	
	UseSound = Sound(DynamicLoadObject(FadeSounds[Rand(FadeSounds.Length)],class'Sound'));
	if (UseSound != None)
	{
		Pawn.PlaySound(UseSound, SLOT_Talk, 1.0f, false, 300.0f, 1.0);
		return GetSoundDuration(UseSound);
	}
	return -1;
}
function float PlayIdleSound() {
	local Sound UseSound;
	
	UseSound = Sound(DynamicLoadObject(IdleSounds[Rand(IdleSounds.Length)],class'Sound'));
	if (UseSound != None)
	{
		Pawn.PlaySound(UseSound, SLOT_Talk, 1.0f, false, 300.0f, 1.0);
		return GetSoundDuration(UseSound);
	}
	return -1;
}

/** Gary Ghost has reached his detination and contemplates what to do next
 * while playing a little idle animation
 */
state Idle
{
    function BeginState() {
        local int i;

        LogDebug("Entered Idle state...");

        i = Rand(IdleAnims.length);
        PlayAnimInfo(IdleAnims[i]);
        SetTimer(GetAnimDefaultDuration(IdleAnims[i]), false);

        AddTimer(IdleThinkInterval, 'IdleThink', true);
		AddTimer(IdleSoundInterval, 'IdleSound', true);
    }

    function EndState() {
        LogDebug("Exiting Idle state...");

        RemoveTimerByID('IdleThink');
    }

    function Timer() {
        // We're a Leprechaun, we don't give a shit if we go inside homes
        WanderDest = GetRandomPathNode(true);

        LogDebug("WanderDest: " $ string(WanderDest));

        if (WanderDest != none)
            GotoState('Wander');
        else
            BeginState();
    }

Begin:
    StopMoving();
}

/** Gary Ghost is simply walking to his wander destination */
state Wander
{
    function BeginState() {
        LogDebug("Entered Wander state...");

        Pawn.GroundSpeed = WalkSpeed;
        Pawn.BaseMovementRate = WalkSpeed * Pawn.DrawScale;

        P2MocapPawn(Pawn).SetAnimWalking();

        AddTimer(WanderThinkInterval, 'WanderThink', true);
    }

    function EndState() {
        LogDebug("Exiting Wander state...");

        RemoveTimerByID('WanderThink');
    }

Begin:
    while (!HasReachedWanderDest()) {
        if (ActorReachable(WanderDest))
            MoveToward(WanderDest);
		else {
			MoveTarget = FindPathToward(WanderDest);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
            else
                GotoState('Idle');
		}
    }
}

/** Gary turns to face the player before fading out */
state TurnToFacePlayer
{
Begin:
	RemoveTimerByID('IdleSound');
	StopMoving();
	FinishRotation();
	if (!IsInState('FadeOut'))
		GotoState('FadeOut');
	// After so long just fade out anyway (in case the dude decides to be an ass and circle Gary while he's trying to focus on him)
	AddTimer(3.f, 'FadeOutEarly', false);
}

/** Gary Ghost fades out of existence */
state FadeOut
{
    function BeginState() {
        LogDebug("Entered FadeOut state...");

        PlayAnimByDuration(FadeAnim, GetAnimDefaultDuration(FadeAnim));
		FadeOutStartTime = Level.TimeSeconds;
		FadeOutDuration = PlayFadeSound();
        SetTimer(FadeOutDuration, false);
		
		// Ghost out
		Pawn.SetCollision(False, False, False);
    }

    function Timer() {
        PoofOutOfExistance();
    }
	
	/* Tick away the alpha layer of the skin */
	event Tick(float dT)
	{
		local int i;
		
		for (i = 0; i < Pawn.Skins.Length; i++)
			if (ColorModifier(Pawn.Skins[i]) != None)				
				ColorModifier(Pawn.Skins[i]).Color.A = 128 * (1.0 - ((Level.TimeSeconds - FadeOutStartTime) / FadeOutDuration));
				
		Super.Tick(dT);
	}
}

defaultproperties
{
    bControlAnimations=true

    DestReachedRange=128.0f

    IdleThinkInterval=0.1f
    WanderThinkInterval=0.1f
	
	IdleSoundInterval=20.f

    IdleAnims(0)=(Anim="s_base1",Rate=1.0f,AnimTime=1.00f)
	FadeAnim=(Anim="s_base1",Rate=1.0f,AnimTime=1.00f)
	FadeSounds[0]="GaryDialog.gary_ghost_ghostlaugh"
	IdleSounds[0]="GaryDialog.gary_ghost_boo1"
	IdleSounds[1]="GaryDialog.gary_ghost_boo2"
	IdleSounds[2]="GaryDialog.gary_ghost_boo3"
	IdleSounds[3]="GaryDialog.gary_ghost_boofail"
	IdleSounds[4]="GaryDialog.gary_ghost_greatlaugh"
	IdleSounds[5]="GaryDialog.gary_ghost_returnedfromdead"

    WalkSpeed=112.0f
 
    VisionFOV=90.0f
    VisionRange=512.0f

    bLogDebug=false
}
