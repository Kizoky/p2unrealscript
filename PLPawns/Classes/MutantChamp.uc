/**
 * MutantChamp
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * Huh, they meat chunks dog food I've been feeding Champ all these years
 * were actually pretty good. Either that or the radiation
 *
 * @author Gordon Cheng
 */
class MutantChamp extends DogPawn
    placeable;

/** Misc objects and values */
var bool bAcceptDamage;
var MutantChampController MutantChampController;

/** Stubbed out so we don't have weird stuff happening like having grenades
 * sending Mutant Champ flying into the air or being split in half from */
function AddVelocity(vector NewVelocity);
function SwapToBurnVictim();
function SetInfected(FPSPawn Doer);
simulated function ChunkUp(int Damage);
function SplitInHalf(Pawn EventInstigator, vector HitLoc, class<DamageType> DamageType);

/** Stubbed out as we handle the animations in the AI Controller and to help
 * ensure previous animation code doesn't interferre with new actions */
simulated event ChangeAnimation();
simulated function SetupAnims();
simulated function SetAnimStanding();
simulated function SetAnimWalking();
simulated function SetAnimRunning();
simulated function SetAnimRunningScared();
simulated function SetAnimTrotting();
simulated function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc);
function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType);
function PlayAnimStanding();
function PlayAnimLimping();
function PlayGetAngered();
function PlayGetScared();
function PlayAttack1();
function PlayAttack2();
function PlayInvestigate();
function PlaySitDown();
function PlaySitting();
function PlayStandUp();
function PlayLayDown();
function PlayLaying();
function PlayPissing(float AnimSpeed);
function PlayGrabPickupOnGround();
simulated event PlayJump();
function PlayGetBackUp();
function PlayFalling();
simulated function PlayShockedAnim();

/** Overriden so the Dude's damage multiplier doesn't affect damage taken */
function int ModifyDamageByBodyLocation( int Damage, Pawn InstigatedBy,
						  vector HitLocation, vector Momentum,
						  out class<DamageType> ThisDamage,
						  out byte HeadShot) {
    return Damage;
}

/** Overriden so we can implement multiple "immunities" unique to this boss*/
event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType) {
    local float MaxDamage;

    // Only accept one damage call per game Tick, used for explosions
    if (!bAcceptDamage || MutantChampController == none)
        return;

    // Most important part is ignoring out own damage
    if (ClassIsChildOf(DamageType, class'MutantChampBiteDamage') ||
        ClassIsChildOf(DamageType, class'MutantChampMeleeDamage') ||
        ClassIsChildOf(DamageType, class'MutantChampFireballDamage') ||
        ClassIsChildOf(DamageType, class'BurnedDamage'))
        return;

    bAcceptDamage = false;

    // Cap the amount of damage so we don't go below our stun health percent
    if ((Health - Damage) < (HealthMax * MutantChampController.StunHealthPct))
        Damage = Health - HealthMax * MutantChampController.StunHealthPct;

    if (MutantChampController.IsStunned()) {
        if (ClassIsChildOf(DamageType, class'EnsmallenDamage'))
            MutantChampController.GotoState('StunShot');
    }
    else
        super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
}

event Tick(float DeltaTime) {
    super.Tick(DeltaTime);

    // Implement Rick's one damage per game Tick fix for explosions
    bAcceptDamage = true;
}

/** Notification to send to our AI Controller */
function NotifyFireball() {
    if (MutantChampController != none)
        MutantChampController.NotifyFireball();
}

/** Notification to send to our AI Controller */
function NotifyFlamethrowerStart() {
    if (MutantChampController != none)
        MutantChampController.NotifyFlamethrowerStart();
}

/** Notification to send to our AI Controller */
function NotifyFlamethrowerEnd() {
    if (MutantChampController != none)
        MutantChampController.NotifyFlamethrowerEnd();
}

/** Overriden so we can implement Napalm Piss */
simulated function Notify_PissStart() {
    if (MutantChampController != none)
        MutantChampController.Notify_PissStart();
}

/** Overriden so we can implement Napalm Piss */
simulated function Notify_PissStop() {
    if (MutantChampController != none)
        MutantChampController.Notify_PissStop();
}

/** Notification to send to our AI Controller */
function NotifyBite() {
    if (MutantChampController != none)
        MutantChampController.NotifyBite();
}

/** Notification to send to our AI Controller */
function NotifyFlailDamage() {
    if (MutantChampController != none)
        MutantChampController.NotifyFlailDamage();
}

/** Notification to send to our AI Controller */
function NotifyFlailRelease() {
    if (MutantChampController != none)
        MutantChampController.NotifyFlailRelease();
}

/** Notification to send to our AI Controller */
function NotifyStomp() {
    if (MutantChampController != none)
        MutantChampController.NotifyStomp();
}

/** Notification to send to our AI Controller */
function NotifyFLFootstep() {
    if (MutantChampController != none)
        MutantChampController.NotifyFLFootstep();
}

/** Notification to send to our AI Controller */
function NotifyFRFootstep() {
    if (MutantChampController != none)
        MutantChampController.NotifyFRFootstep();
}

/** Notification to send to our AI Controller */
function NotifyBLFootstep() {
    if (MutantChampController != none)
        MutantChampController.NotifyBLFootstep();
}

/** Notification to send to our AI Controller */
function NotifyBRFootstep() {
    if (MutantChampController != none)
        MutantChampController.NotifyBRFootstep();
}

/** Notification to send to our AI Controller */
function NotifyStunCollapse() {
    if (MutantChampController != none)
        MutantChampController.NotifyStunCollapse();
}

/** Notification to send to our AI Controller */
function NotifyJumpStompFront() {
    if (MutantChampController != none)
        MutantChampController.NotifyJumpStompFront();
}

/** Notification to send to our AI Controller */
function NotifyJumpStompBack() {
    if (MutantChampController != none)
        MutantChampController.NotifyJumpStompBack();
}

/** Notification to send to our AI Controller */
function NotifyRoar() {
    if (MutantChampController != none)
        MutantChampController.NotifyRoar();
}

defaultproperties
{
    bNoDismemberment=true

    bCanBeBaseForPawns=true

    bBlockZeroExtentTraces=false
	bBlockNonZeroExtentTraces=true

    ControllerClass=class'MutantChampController'

    DrawScale=5

    HealthMax=1250

    Mesh=SkeletalMesh'PLAnimals.meshDog_Mutant'

    Skins(0)=texture'PLAnimalSkins.PLDog.MutantDog_baseCHAMP'
	Skins(1)=texture'PLAnimalSkins.PLDog.teethclaws'

    CollisionHeight=60
    CollisionRadius=35

    PrePivot=(Z=265)
	
	TransientSoundVolume=255
	TransientSoundRadius=600
	AmbientGlow=30
}
