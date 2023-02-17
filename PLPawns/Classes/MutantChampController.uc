/**
 * MutantChampController
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * Our love for pissing on the Dude has been replaced by a love for pissing
 * napalm on the Dude
 *
 * @author Gordon Cheng
 */
class MutantChampController extends P2EAIController;

struct CollisionBolton {
    var float DamageMult;
    var vector Scale3D, RelLoc;
    var rotator RelRot;
    var name BoneName;

    var PeoplePart Bolton;
};

struct CureStage {
    var float StageRunSpeed, StageRunAnimRate;
    var float StageScale, StageZPivot;
};

/** Basic attack and movement variables */
var float ThinkInterval;
var float AnimBlendTime;
var float DudeReachedRadius, DestinationReachedRadius;

var AnimInfo IdleAnim, WalkAnim, RunAnim;

var name MouthBone, FLPawBone, FRPawBone, BLPawBone, BRPawBone;

/** Roar attack */
var float RoarTime;
var AnimInfo RoarAnim;
var sound RoarSound;

/** Fireball homing projectile attack */
var float FireballCooldown, FireballTime;
var vector FireballOffset;
var rotator FireballRotationOffset;
var class<P2Projectile> FireballProjectileClass;
var AnimInfo FireballAnim;
var Sound FireballSound;

/** Flamethrower attack */
var float FlamethrowerStartAngle;
var float FlamethrowerCooldown, FlamethrowerTime;
var float FlamethrowerRange;
var vector FlamethrowerRelativeLocation;
var rotator FlamethrowerRelativeRotation;
var class<P2Emitter> FlamethrowerEmitterClass;
var AnimInfo FlamethrowerAnim;

/** Napalm Piss attack */
var float NapalmPissCooldown, NapalmPissTime;
var float NapalmPissRange;
var class<FluidPourFeeder> NapalmPissPourFeederClass;
var AnimInfo NapalmPissAnim;

/** Bite attack */
var float BiteTime;
var float BiteRange;
var vector BiteLocationOffset;
var float BiteRadius, BiteAngle;
var float BiteDamage, BiteFlyVel, BiteMomentum;
var class<DamageType> BiteDamageType;
var AnimInfo BiteAnim;
var Sound BiteSound;

/** Flail attack */
var float FlailCooldown, FlailTime, FlailReleaseTime;
var vector FlailLocationOffset;
var rotator FlailRotationOffset;
var float FlailDamage, FlailReleaseVel;
var vector FlailRelativeLocation;
var class<DamageType> FlailDamageType;
var AnimInfo FlailAnim, FlailReleaseAnim;
var Sound FlailSound;

/** Stomp attack */
var float StompCooldown, StompTime;
var float StompRange;
var float StompDamage, StompRadius, StompFlyVel, StompMomentum;
var float StompShakeMag;
var class<DamageType> StompDamageType;
var class<P2Emitter> StompImpactEmitterClass;
var AnimInfo StompAnim;
var sound StompSound;

/** Jump stomp attack */
var float JumpStompTime;
var float JumpStompRange;
var float JumpStompDamage, JumpStompRadius, JumpStompFlyVel, JumpStompMomentum;
var float JumpStompShakeMag;
var class<DamageType> JumpStompDamageType;
var AnimInfo JumpStompAnim;

/** Footstep */
var float FootstepRadius, FootstepDamage;
var float FootstepFlyVel, FootstepMomentum;
var float FootstepShakeMag;
var class<DamageType> FootstepDamageType;

/** Screen shake values */
var float MinMagForShake, MaxShakeDist;

/** Stunned state */
var float StunHealthPct, CureFailedHealthPct;
var float StunStartTime, StunTime, StunRecoverTime, StunShotTime;
var AnimInfo StunStartAnim, StunAnim, StunRecoverAnim, StunShotAnim;
var Sound StunnedSound;

var float StunCollapseRadius, StunCollapseShakeMag, StunCollapseFlyVel;

/** Shrinking */
var float ShrinkExponent;
var EInterpStyle ShrinkInterpStyle;

/** Lay Down */
var float LayDownStartTime;
var AnimInfo LayDownStartAnim, LayDownAnim;

/** Size scale and collision radius and height for cure stages */
var int FreeMovementStage;

var array<CureStage> CureStages;

/** List of collision boltons we'll use attach to Mutant Champ */
var class<PeoplePart> CollisionBoltonClass;
var array<CollisionBolton> CollisionBoltons;

/** Misc objects and values */
var bool bCanUseFireball, bCanUseFlamethrower, bCanUseNapalmPiss, bCanUseFlail;
var bool bCanUseStomp;

var bool bCureStunRecover;

var int PathNotFoundCnt, PathNotFoundThreshold;

var int CurrentStage;

var float HealthRegenTime;

var bool bInterpSize;
var float InterpSizeTime, InterpSizeEndTime;
var float InterpSizeExponent;

var PathNode Destination;
var Pawn PostalDude, FlailVictim;
var MutantChamp MutantChamp;

var P2Emitter FlamethrowerEmitter;

var vector OldFlailLoc, NewFlailLoc;

var FluidPourFeeder NapalmPissPourFeeder;

/** Function prototype declared here so we don't have scope problems later */
function PerformAttack();

/** Returns whether or not the Postal Dude is still a valid target
 * @return TRUE if he still exists and is alive; FALSE otherwise
 */
function bool IsPostalDudeValid() {
    return (PostalDude != none && PostalDude.Health > 0);
}

/** Returns whether or not we're facing the Postal Dude. The flamethrower attack
 * features Mutant Champ standing still, so this is a must
 * @return TRUE if we're facing him; FALSE otherwise
 */
function bool IsFacingPostalDudeForFlamethrower() {
    local vector PostalDudeDir;

    PostalDudeDir = PostalDude.Location;
    PostalDudeDir.Z = Pawn.Location.Z;

    return IsLocationInFacingAngle(PostalDudeDir, FlamethrowerStartAngle);
}

/** Returns whether or not Mutant Champ is at his final cure stage
 * @return TRUE if we're at our final cure stage; FALSE otherwise
 */
function bool IsAtFinalCureStage() {
    return CurrentStage == (CureStages.length - 1);
}

/** Returns whether or not the next cure stage is going to be the final one
 * @return TRUE if the next stage is the final cure state; FALSE otherwise
 */
function bool IsNextStageFinal() {
    return (CurrentStage + 1) == (CureStages.length - 1);
}

/** Returns whether or not we're in one of the stunned states
 * @return TRUE if we're currently stunned; FALSE otherwise
 */
function bool IsStunned() {
    return IsInState('StunStart') || IsInState('Stunned') || IsInState('StunRecover');
}

/** Returns whether or not we can freely move between the pillars
 * @return TRUE if we've shrunk down far enough; FALSE otherwise
 */
function bool CanUseFreeMovement() {
    return CurrentStage >= FreeMovementStage;
}

/** Returns whether or not we should move to the Postal Dude
 * @return TRUE if we should move closer; FALSE otherwise
 */
function bool ShouldMoveToDude() {
    return VSize(PostalDude.Location - Pawn.Location) > DudeReachedRadius;
}

/** Returns whether or not we should move to our Destination
 *
 */
function bool ShouldMoveToDestination() {
    if (Destination == none)
        return false;

    return VSize(Destination.Location - Pawn.Location) > DestinationReachedRadius;
}

/** Returns whether or not we should use our roar
 * @return TRUE if the Dude is currently under the effects of catnip; FALSE otherwise
 */
function bool ShouldUseRoar() {
    return Level.TimeDilation < 1;
}

/** Returns whether or not we should use our fireball attack
 * @return TRUE if our attack has cooled down; FALSE otherwise
 */
function bool ShouldUseFireball() {
    return bCanUseFireball;
}

/** Returns whether or not we should use our flamethrower attack
 * @return TRUE if our attack has cooled down and we're in range; FALSE otherwise
 */
function bool ShouldUseFlamethrower() {
    return bCanUseFlamethrower && VSize(PostalDude.Location - Pawn.Location) < FlamethrowerRange * GetAttackScale();
}

/** Returns whether or not we should use our napalm piss attack
 * @return TRUE if our attack has cooled down and we're in range; FALSE otherwise
 */
function bool ShouldUseNapalmPiss() {
    return bCanUseNapalmPiss && VSize(PostalDude.Location - Pawn.Location) < NapalmPissRange * GetAttackScale();
}

/** Returns whether or not we should use our bite attack
 * @return TRUE if we're in range; FALSE otherwise
 */
function bool ShouldUseBite() {
    return VSize(PostalDude.Location - Pawn.Location) < BiteRange * GetAttackScale() && !ShouldUseJumpStomp();
}

/** Returns whether or not we transition over to a flail attack
 * @return TRUE if our attack has cooled down; FALSE otherwise
 */
function bool ShouldUseFlail() {
    return bCanUseFlail && CurrentStage < FreeMovementStage;
}

/** Returns whether or not we can use our stomp attack
 * @return TRUE if our attack has cooled down and we're in range; FALSE otherwise
 */
function bool ShouldUseStomp() {
    return bCanUseStomp && VSize(PostalDude.Location - Pawn.Location) < StompRange * GetAttackScale();
}

/** Returns whether or not we should use a jump stomp attack
 * @return TRUE if we should flush the Dude out from under us; FALSE otherwise
 */
function bool ShouldUseJumpStomp() {
    return VSize(PostalDude.Location - Pawn.Location) < JumpStompRange * GetAttackScale();
}

/** Returns the location in the world where the mouth of Mutant Champ is
 * @return Location in the world where Mutant Champ's mouth is at
 */
function vector GetMouthLocation() {
    if (MouthBone == '' || MouthBone == 'None' || Pawn == none)
        return vect(0,0,0);

    return Pawn.GetBoneCoords(MouthBone).Origin;
}

/** Returns the rotation of the mouth bone so that it points outward
 * @return Rotation of the mouth bone so it points outward
 */
function rotator GetMouthRotation() {
    if (MouthBone == '' || MouthBone == 'None' || Pawn == none)
        return rot(0,0,0);

    return Pawn.GetBoneRotation(MouthBone);
}

/** Returns the draw scale given the interpolation percentage
 * @param Pct - Current progress from 0.0 to 1.0 of the current interpolation
 * @return DrawScale at the current shrinking interpolation percent
 */
function float GetShrinkScale(float Pct) {
    local float PrevScale, NextScale;

    PrevScale = CureStages[CurrentStage].StageScale;
    NextScale = CureStages[CurrentStage + 1].StageScale;

    return NextScale + (PrevScale - NextScale) * (1 - Pct);
}

/** Returns the Z pivot given the interpolation percentage
 * @param Pct - Current progress from 0.0 to 1.0 of the current interpolation
 * @return Z pivot at the current shrinking interpolation percent
 */
function float GetShrinkZPivot(float Pct) {
    local float PrevPivot, NextPivot;

    PrevPivot = CureStages[CurrentStage].StageZPivot;
    NextPivot = CureStages[CurrentStage+1].StageZPivot;

    return NextPivot + (PrevPivot - NextPivot) * (1 - Pct);
}

/** Returns the scale of all the range in which attacks should be used and
 * radius of all the impact damages with the size
 */
function float GetAttackScale() {
    return CureStages[CurrentStage].StageScale / CureStages[0].StageScale;
}

/** Interpolates a Pawn's size based on the given time */
function InterpolateSize() {
    bInterpSize = true;
    InterpSizeTime = 0;
}

/** Given a Pawn, sends the poor bastard flying, Copied from the EasterBunnyController
 * @param ImpactLoc - Location in the world where the impact happens
 * @param Other - Pawn to send flying into the air
 * @param FlyVelocity - The XY velocity and Z velocity to send them flying at
 * @param Radius - Max radius used to send Pawns flying. The closer they are
 *                 are to our Pawn, the farther they fly out
 */
function SendPawnFlying(vector ImpactLoc, Pawn Other, float FlyVelocity, float Radius) {
    local float VelocityPct;
    local vector OtherLocation, ImpactLocation, OffGround;
    local vector FlyDir;

    // Let's not screw with ragdolls
    if (Other.Physics == PHYS_KarmaRagDoll)
        return;

    // Get the fly direction based only on the XY plane, not the Z
    OtherLocation = Other.Location;
    OtherLocation.Z = 0;

    ImpactLocation = ImpactLoc;
    ImpactLocation.Z = 0;

    OffGround = Other.Location;
    OffGround.Z += 32;

    FlyDir = Normal(OtherLocation - ImpactLocation);

    VelocityPct = 1 - (VSize(Other.Location - ImpactLoc) / Radius);

    if (Other.Physics == PHYS_Walking) {
        // Send them flying only if they're walking
        Other.SetLocation(OffGround);
        Other.SetPhysics(PHYS_Falling);

        Other.Velocity = Normal(Other.Location - ImpactLoc) * FlyVelocity;
        Other.Velocity.Z = FlyVelocity;
    }
    else {
        // Otherwise if they're currently jumping just add additional velocity
        Other.SetPhysics(PHYS_Falling);

        Other.Velocity += Normal(Other.Location - ImpactLoc) * FlyVelocity * VelocityPct;
        Other.Velocity.Z += FlyVelocity * VelocityPct;
    }
}

/** Copied and modified from Actor */
//!! FIXME: Update to native form
simulated function StompHurtRadius(float DamageAmount, float DamageRadius,
                                   class<DamageType> DamageType,
                                   float Momentum, vector HitLocation) {
	local Actor Victims;
	local float DamageScale, Dist;
	local vector Dir;

	if (bHurtEntry) return;

	bHurtEntry = true;

    foreach VisibleCollidingActors(class 'Actor', Victims, DamageRadius, HitLocation) {
		if (Victims != Pawn && Victims.Physics != PHYS_Falling) {
			Dir = Victims.Location - HitLocation;
			Dist = FMax(1, VSize(Dir));
			Dir = Dir / Dist;
			DamageScale = 1 - FMax(0,(Dist - Victims.CollisionRadius) / DamageRadius);
			Victims.TakeDamage
			(
				Max(DamageScale * DamageAmount, 1),
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * Dir,
				(DamageScale * Momentum * Dir),
				DamageType
			);
		}
	}

	bHurtEntry = false;
}

/** Copied over from the Elephant */
function ShakeCameraDistanceBased(float Mag, vector ImpactLocation) {
	local Controller con;
	local float usemag, usedist;

	for (con = Level.ControllerList;con != none;con = con.NextController) {
        if (con.bIsPlayer && con.Pawn != none) {
			usedist = VSize(con.Pawn.Location - ImpactLocation);

            if (usedist > MaxShakeDist)
			    usedist = MaxShakeDist;

			usemag = ((MaxShakeDist - usedist) / MaxShakeDist) * Mag;

			if (usemag < MinMagForShake)
				return;

			con.ShakeView((usemag * 0.2 + 1) * vect(1, 1, 3),
                vect(1000, 1000, 1000), 1 + usemag * 0.02,
                (usemag * 0.3 + 1.0) * vect(1, 1, 2), vect(800,800,800),
                1 + usemag * 0.02);
		}
	}
}

/** Simple method that goes through all of our collision bolton information
 * and creates all the corresponding collision boltons
 */
function SetupBoltons() {
    local int i;
    local PeoplePart NewCollisionBolton;

    if (CollisionBoltonClass == none) {
        LogDebug("ERROR: No CollisionBoltonClass found");
        return;
    }

    if (MutantChamp == none)
        return;

    for (i=0;i<CollisionBoltons.length;i++) {
        if (CollisionBoltons[i].BoneName == '' || CollisionBoltons[i].BoneName == 'None')
            continue;

        NewCollisionBolton = Spawn(CollisionBoltonClass);

        if (NewCollisionBolton != none) {
            if (MutantChampCollision(NewCollisionBolton) != none) {
                MutantChampCollision(NewCollisionBolton).MutantChamp = MutantChamp;
                MutantChampCollision(NewCollisionBolton).DamageMult = CollisionBoltons[i].DamageMult;
            }

            Pawn.AttachToBone(NewCollisionBolton, CollisionBoltons[i].BoneName);

            NewCollisionBolton.SetDrawScale3D(CollisionBoltons[i].Scale3D);
            NewCollisionBolton.SetRelativeLocation(CollisionBoltons[i].RelLoc);
            NewCollisionBolton.SetRelativeRotation(CollisionBoltons[i].RelRot);

            CollisionBoltons[i].Bolton = NewCollisionBolton;
        }
    }
}

/** Reattaches all the CollisionBoltons for when Mutant Champ is mobile again */
function ReattachCollisionBoltons() {
    local int i;

    for (i=0;i<CollisionBoltons.length;i++) {
        if (CollisionBoltons[i].Bolton != none) {
            CollisionBoltons[i].Bolton.SetCollision(true, true, false);
            Pawn.AttachToBone(CollisionBoltons[i].Bolton, CollisionBoltons[i].BoneName);
        }
    }
}

/** Detaches all the CollisionBoltons for when Mutant Champ is stunned */
function DettachCollisionBoltons() {
    local int i;

    for (i=0;i<CollisionBoltons.length;i++) {
        if (CollisionBoltons[i].Bolton != none) {
            CollisionBoltons[i].Bolton.SetCollision(true, true, true);
            Pawn.DetachFromBone(CollisionBoltons[i].Bolton);
        }
    }
}

/** Iterates through all the CollisionBoltons and removes them */
function DestroyCollisionBoltons() {
    local int i;

    for (i=0;i<CollisionBoltons.length;i++)
        if (CollisionBoltons[i].Bolton != none)
            CollisionBoltons[i].Bolton.Destroy();
}

/** Overriden to initialize some stuff */
function Possess(Pawn aPawn) {
    super.Possess(aPawn);

    MutantChamp = MutantChamp(aPawn);

    if (MutantChamp != none) {
        MutantChamp.MutantChampController = self;
        SetupBoltons();
    }
    else
        LogDebug("ERROR: MutantChamp not found");

    aPawn.SetPhysics(PHYS_Falling);

    InterpSizeEndTime = StunShotTime + StunRecoverTime;

    AddTimer(0.1, 'FindPostalDude', true);
}

// Overridden to destroy collision boxes when killed
simulated event Destroyed()
{
	local MutantChampCollision M;
	
	// Destroy collision boltons here
	DettachCollisionBoltons();
	DestroyCollisionBoltons();
	
	// Now force them to be destroyed
	foreach DynamicActors(class'MutantChampCollision', M)
		M.Destroy();
	
	Super.Destroyed();
}

/** Overriden to implement Multi-Timer functionality */
function TimerFinished(name ID) {
    switch(ID) {
        case 'FindPostalDude':
            FindPostalDude();
            break;

        case 'EnableFireball':
            bCanUseFireball = true;
            break;

        case 'EnableFlamethrower':
            bCanUseFlamethrower = true;
            break;

        case 'EnableNapalmPiss':
            bCanUseNapalmPiss = true;
            break;

        case 'EnableFlail':
            bCanUseFlail = true;
            break;

        case 'EnableStomp':
            bCanUseStomp = true;
            break;
    }
}

/** Take a look at our current situation and decide what to do next */
function DecideNextMove() {
    // Does the Postal Dude exist, and if he does, is he alive?
    if (IsPostalDudeValid()) {

        // First and foremost, break catnip, otherwise all of our attacks and
        // movement are essentially rendered useless
        if (ShouldUseRoar())
            GotoState('Roar');

        // Next, make sure the player is not hiding under Mutant Champ
        else if (ShouldUseJumpStomp())
            GotoState('JumpStomp');

        // Next, prioritize the fireball as they're independent from Mutant Champ
        else if (ShouldUseFireball())
            GotoState('Fireball');

        // Next use our flamethrower attack as it's our most damaging attack
        else if (ShouldUseFlamethrower() && IsFacingPostalDudeForFlamethrower())
            GotoState('Flamethrower');

        // Next, use our more indirect area restricting attack, our Napalm piss
        //if (ShouldUseNapalmPiss())
        //    GotoState('NapalmPiss');

        // If we're out of special firebased moves, just use our brute force Stomp
        else if (ShouldUseStomp())
            GotoState('Stomp');

        // If we're all out of firebased moves and we're tired, just use our standard bite
        else if (ShouldUseBite())
            GotoState('Bite');

        // Move closer to the Postal Dude if we're out of special attacks
        else if (ShouldMoveToDude()) {

            // If we've shrunked down far enough to move between the pillars
            if (CanUseFreeMovement())
                GotoState('MoveToDude');

            // Otherwise stick to the paths exclusively
            else
                GotoState('MoveToDudePathed');
        }

        else
            GotoState('Idle');
    }

    // Otherwise perform some death stuff here
    else
        GotoState('StartLayDown');
}

/** Same as DecideNextMove, only here we only focus on which attack to use */
function DecideNextAttack() {
    // Does the Postal Dude exist, and if he does, is he alive?
    if (IsPostalDudeValid()) {

        // First and foremost, break catnip, otherwise all of our attacks and
        // movement are essentially rendered useless
        if (ShouldUseRoar())
            GotoState('Roar');

        // Next, make sure the player is not hiding under Mutant Champ
        else if (ShouldUseJumpStomp())
            GotoState('JumpStomp');

        // Prioritize the fireball as they're independent from Mutant Champ
        else if (ShouldUseFireball())
            GotoState('Fireball');

        // Next use our flamethrower attack as it's our most damaging attack
        else if (ShouldUseFlamethrower() && IsFacingPostalDudeForFlamethrower())
            GotoState('Flamethrower');

        // Next, use our more indirect area restricting attack, our Napalm piss
        //if (ShouldUseNapalmPiss())
        //    GotoState('NapalmPiss');

        // If we're out of special firebased moves, just use our brute force Stomp
        else if (ShouldUseStomp())
            GotoState('Stomp');

        // If we're all out of firebased moves and we're tired, just use our standard bite
        else if (ShouldUseBite())
            GotoState('Bite');
    }

    // Otherwise perform some death stuff here
    else
        GotoState('StartLayDown');
}

/** Iterates through the Pawns in the map until we find the player */
function FindPostalDude() {
    local Pawn Pawn;

    foreach DynamicActors(class'Pawn', Pawn) {
        if (Pawn.Controller != none && Pawn.Controller.bIsPlayer) {
            PostalDude = Pawn;
            break;
        }
    }

    if (PostalDude != none) {
        RemoveTimerByID('FindPostalDude');
        AddTimer(FireballCooldown, 'EnableFireball', false);

        DecideNextMove();
    }
}

/** Called whenever we can't find a path to the Postal Dude */
function CantFindPathToDude() {
	// Draw out dude with fireballs
	GotoState('Fireball');
    //DecideNextMove();
}

/** Called whenever we can't find a path to our Destination */
function CantFindPathToDestination() {
    DecideNextMove();
}

/** Notification from our Pawn that we just took damage */
function NotifyTakeHit(Pawn InstigatedBy, vector HitLocation, int Damage,
                       class<DamageType> DamageType, vector Momentum) {
    if (MutantChamp == none)
        return;

    if (MutantChamp.Health <= MutantChamp.HealthMax * StunHealthPct && !IsStunned())
        GotoState('StunStart');
}

/** Notification from our Pawn to spawn a homing fireball projectile */
function NotifyFireball() {
    local vector MouthLocation;
    local rotator MouthRotation;
    local GaryHeadHomingProjectile FireballProj;

    MouthRotation = GetMouthRotation() + FireballRotationOffset;

    MouthLocation = GetMouthLocation() + class'P2EMath'.static.GetOffset(MouthRotation, FireballOffset);

    if (FireballProjectileClass != none) {
        FireballProj = GaryHeadHomingProjectile(Spawn(FireballProjectileClass, self,, MouthLocation, MouthRotation));

        if (FireballProj != none) {
            FireballProj.PrepVelocity(FireballProj.default.Speed * vector(MouthRotation));

            if (IsPostalDudeValid())
                FireballProj.SetTarget(PostalDude);
        }
		Pawn.PlaySound(FireballSound,,Pawn.TransientSoundVolume,,Pawn.TransientSoundRadius);
    }
}

/** Notification from our Pawn to create the flames coming out of our mouth */
function NotifyFlamethrowerStart() {
    if (MouthBone == '' || MouthBone == 'None')
        return;

    if (FlamethrowerEmitterClass != none)
        FlamethrowerEmitter = Spawn(FlamethrowerEmitterClass,,, GetMouthLocation());

    if (FlamethrowerEmitter != none) {
        Pawn.AttachToBone(FlamethrowerEmitter, MouthBone);

        FlamethrowerEmitter.SetRelativeLocation(FlamethrowerRelativeLocation);
        FlamethrowerEmitter.SetRelativeRotation(FlamethrowerRelativeRotation);
    }
}

/** Notification from our Pawn to stop the stream of flames */
function NotifyFlamethrowerEnd() {
    if (FlamethrowerEmitter != none) {
        FlamethrowerEmitter.Destroy();
        FlamethrowerEmitter = none;
    }
}

/** Notification from our Pawn to start the Napalm Piss */
function Notify_PissStart() {
    // TODO: Implement me
}

/** ONotification from our Pawn to end the Napalm Piss */
function Notify_PissStop() {
    // TODO: Implement me
}

/** Notification from our Pawn to deal bite damage */
function NotifyBite() {
    local float ScaledBiteRadius;

    local vector MouthLocation;

    local float MinAngle;
    local vector TargetDir;

    local Pawn Victim;

    ScaledBiteRadius = BiteRadius * GetAttackScale();

    MouthLocation = GetMouthLocation() + class'P2EMath'.static.GetOffset(Pawn.Rotation, BiteLocationOffset);

    foreach Pawn.VisibleCollidingActors(class'Pawn', Victim, ScaledBiteRadius, MouthLocation) {
        TargetDir = Normal(Victim.Location - MouthLocation);
        MinAngle = 1.0 - BiteAngle / 180.0;

        if (TargetDir dot vector(Pawn.Rotation) >= MinAngle) {
            if (ShouldUseFlail()) {
                FlailVictim = Victim;

                if (FlailVictim != none) {
                    GotoState('Flail');
                    return;
                }
            }
            else {
                Victim.TakeDamage(BiteDamage, Pawn, Victim.Location, TargetDir * BiteMomentum, BiteDamageType);
                SendPawnFlying(Victim.Location, Victim, BiteFlyVel, ScaledBiteRadius);
            }
        }
    }
}

/** Notification from our Pawn to deal a bite flail damage */
function NotifyFlailDamage() {
    FlailVictim.TakeDamage(FlailDamage, Pawn, PostalDude.Location, vect(0,0,0), FlailDamageType);
	Pawn.PlaySound(FlailSound,,Pawn.TransientSoundVolume,,Pawn.TransientSoundRadius);
}

/** Notification from our Pawn to release the Dude from our bite */
function NotifyFlailRelease() {
    FlailVictim.TakeDamage(FlailDamage, Pawn, PostalDude.Location, vect(0,0,0), FlailDamageType);
    FlailVictim.SetPhysics(PHYS_Falling);
    FlailVictim.Velocity = Normal(NewFlailLoc - OldFlailLoc) * FlailReleaseVel;

    FlailVictim = none;
}

/** Notification from our Pawn to perform the stomp attack */
function NotifyStomp() {
    local float ScaledStompRadius;

    local vector PawLocation;
    local Pawn Victim;
	local Emitter StompEmitter;

    ScaledStompRadius = StompRadius * GetAttackScale();

    if (FLPawBone != '' && FLPawBone != 'None') {
        PawLocation = Pawn.GetBoneCoords(FLPawBone).Origin;
        StompHurtRadius(StompDamage, ScaledStompRadius, StompDamageType, StompMomentum, PawLocation);
        ShakeCameraDistanceBased(StompShakeMag, PawLocation);

        foreach Pawn.VisibleCollidingActors(class'Pawn', Victim, ScaledStompRadius, PawLocation)
            if (Victim != Pawn) SendPawnFlying(PawLocation, Victim, StompFlyVel, ScaledStompRadius);

        if (StompImpactEmitterClass != none)
            StompEmitter = Spawn(StompImpactEmitterClass,,, PawLocation);
		if (StompSound != None && StompEmitter != None)
			StompEmitter.PlaySound(StompSound,,Pawn.TransientSoundVolume,,Pawn.TransientSoundRadius);
    }

    if (FRPawBone != '' && FRPawBone != 'None') {
        PawLocation = Pawn.GetBoneCoords(FRPawBone).Origin;
        StompHurtRadius(StompDamage, ScaledStompRadius, StompDamageType, StompMomentum, PawLocation);
        ShakeCameraDistanceBased(StompShakeMag, PawLocation);

        foreach Pawn.VisibleCollidingActors(class'Pawn', Victim, ScaledStompRadius, PawLocation)
            if (Victim != Pawn) SendPawnFlying(PawLocation, Victim, StompFlyVel, ScaledStompRadius);

        if (StompImpactEmitterClass != none)
            StompEmitter = Spawn(StompImpactEmitterClass,,, PawLocation);
		if (StompSound != None && StompEmitter != None)
			StompEmitter.PlaySound(StompSound,,Pawn.TransientSoundVolume,,Pawn.TransientSoundRadius);
    }
}

/** Notification from our Pawn to shake and damage the ground of our front left paw */
function NotifyFLFootstep() {
    local float ScaledFootstepRadius;

    local vector PawLocation;
    local Pawn Victim;

    if (CanUseFreeMovement()) return;

    ScaledFootstepRadius = FootstepRadius * GetAttackScale();

    if (FLPawBone != '' && FLPawBone != 'None') {
        PawLocation = Pawn.GetBoneCoords(FLPawBone).Origin;
        StompHurtRadius(FootstepDamage, ScaledFootstepRadius, FootstepDamageType, FootstepMomentum, PawLocation);
        ShakeCameraDistanceBased(FootstepShakeMag, PawLocation);

        foreach Pawn.VisibleCollidingActors(class'Pawn', Victim, ScaledFootstepRadius, PawLocation)
            if (Victim != Pawn) SendPawnFlying(PawLocation, Victim, FootstepFlyVel, ScaledFootstepRadius);

        if (StompImpactEmitterClass != none)
            Spawn(StompImpactEmitterClass,,, PawLocation);
    }
}

/** Notification from our Pawn to shake and damage the ground of our front right paw */
function NotifyFRFootstep() {
    local float ScaledFootstepRadius;

    local vector PawLocation;
    local Pawn Victim;

    if (CanUseFreeMovement()) return;

    ScaledFootstepRadius = FootstepRadius * GetAttackScale();

    if (FRPawBone != '' && FRPawBone != 'None') {
        PawLocation = Pawn.GetBoneCoords(FRPawBone).Origin;
        StompHurtRadius(FootstepDamage, ScaledFootstepRadius, FootstepDamageType, FootstepMomentum, PawLocation);
        ShakeCameraDistanceBased(FootstepShakeMag, PawLocation);

        foreach Pawn.VisibleCollidingActors(class'Pawn', Victim, ScaledFootstepRadius, PawLocation)
            if (Victim != Pawn) SendPawnFlying(PawLocation, Victim, FootstepFlyVel, ScaledFootstepRadius);

        if (StompImpactEmitterClass != none)
            Spawn(StompImpactEmitterClass,,, PawLocation);
    }
}

/** Notification from our Pawn to shake and damage the ground of our back left paw */
function NotifyBLFootstep() {
    local float ScaledFootstepRadius;

    local vector PawLocation;
    local Pawn Victim;

    if (CanUseFreeMovement()) return;

    ScaledFootstepRadius = FootstepRadius * GetAttackScale();

    if (BLPawBone != '' && BLPawBone != 'None') {
        PawLocation = Pawn.GetBoneCoords(BLPawBone).Origin;
        StompHurtRadius(FootstepDamage, ScaledFootstepRadius, FootstepDamageType, FootstepMomentum, PawLocation);
        ShakeCameraDistanceBased(FootstepShakeMag, PawLocation);

        foreach Pawn.VisibleCollidingActors(class'Pawn', Victim, ScaledFootstepRadius, PawLocation)
            if (Victim != Pawn) SendPawnFlying(PawLocation, Victim, FootstepFlyVel, ScaledFootstepRadius);

        if (StompImpactEmitterClass != none)
            Spawn(StompImpactEmitterClass,,, PawLocation);
    }
}

/** Notification from our Pawn to shake and damage the ground of our back right paw */
function NotifyBRFootstep() {
    local float ScaledFootstepRadius;

    local vector PawLocation;
    local Pawn Victim;

    if (CanUseFreeMovement()) return;

    ScaledFootstepRadius = FootstepRadius * GetAttackScale();

    if (BRPawBone != '' && BRPawBone != 'None') {
        PawLocation = Pawn.GetBoneCoords(BRPawBone).Origin;
        StompHurtRadius(FootstepDamage, ScaledFootstepRadius, FootstepDamageType, FootstepMomentum, PawLocation);
        ShakeCameraDistanceBased(FootstepShakeMag, PawLocation);

        foreach Pawn.VisibleCollidingActors(class'Pawn', Victim, ScaledFootstepRadius, PawLocation)
            if (Victim != Pawn) SendPawnFlying(PawLocation, Victim, FootstepFlyVel, ScaledFootstepRadius);

        if (StompImpactEmitterClass != none)
            Spawn(StompImpactEmitterClass,,, PawLocation);
    }
}

/** Notification from our Pawn that Mutant Champ had just collapsed */
function NotifyStunCollapse() {
    local vector PawLocation;
    local Pawn Victim;

    if (CanUseFreeMovement()) return;

    ShakeCameraDistanceBased(StunCollapseShakeMag, Pawn.Location);

    foreach Pawn.VisibleCollidingActors(class'Pawn', Victim, StunCollapseRadius, Pawn.Location)
        if (Victim != Pawn) SendPawnFlying(Pawn.Location, Victim, StunCollapseFlyVel, StunCollapseRadius);

    if (StompImpactEmitterClass == none) return;

    Spawn(StompImpactEmitterClass,,, Pawn.Location);

    if (FLPawBone != '' && FLPawBone != 'None') {
        PawLocation = Pawn.GetBoneCoords(FLPawBone).Origin;
        Spawn(StompImpactEmitterClass,,, PawLocation);
    }

    if (FRPawBone != '' && FRPawBone != 'None') {
        PawLocation = Pawn.GetBoneCoords(FRPawBone).Origin;
        Spawn(StompImpactEmitterClass,,, PawLocation);
    }

    if (BLPawBone != '' && BLPawBone != 'None') {
        PawLocation = Pawn.GetBoneCoords(BLPawBone).Origin;
        Spawn(StompImpactEmitterClass,,, PawLocation);
    }

    if (BRPawBone != '' && BRPawBone != 'None') {
        PawLocation = Pawn.GetBoneCoords(BRPawBone).Origin;
        Spawn(StompImpactEmitterClass,,, PawLocation);
    }
}

/** Notification from our Pawn to perform jump stomp damage on the front paws */
function NotifyJumpStompFront() {
    local float ScaledStompRadius;

    local vector PawLocation;
    local Pawn Victim;
	local Emitter StompEmitter;

    ScaledStompRadius = JumpStompRadius * GetAttackScale();

    if (FLPawBone != '' && FLPawBone != 'None') {
        PawLocation = Pawn.GetBoneCoords(FLPawBone).Origin;
        HurtRadius(JumpStompDamage, ScaledStompRadius, JumpStompDamageType, JumpStompMomentum, PawLocation);
        ShakeCameraDistanceBased(JumpStompShakeMag, PawLocation);

        foreach Pawn.VisibleCollidingActors(class'Pawn', Victim, ScaledStompRadius, PawLocation)
            if (Victim != Pawn) SendPawnFlying(PawLocation, Victim, JumpStompFlyVel, ScaledStompRadius);

        if (StompImpactEmitterClass != none)
            StompEmitter = Spawn(StompImpactEmitterClass,,, PawLocation);
		if (StompSound != None && StompEmitter != None)
			StompEmitter.PlaySound(StompSound,,Pawn.TransientSoundVolume,,Pawn.TransientSoundRadius);
    }

    if (FRPawBone != '' && FRPawBone != 'None') {
        PawLocation = Pawn.GetBoneCoords(FRPawBone).Origin;
        HurtRadius(JumpStompDamage, ScaledStompRadius, JumpStompDamageType, JumpStompMomentum, PawLocation);
        ShakeCameraDistanceBased(JumpStompShakeMag, PawLocation);

        foreach Pawn.VisibleCollidingActors(class'Pawn', Victim, ScaledStompRadius, PawLocation)
            if (Victim != Pawn) SendPawnFlying(PawLocation, Victim, JumpStompFlyVel, ScaledStompRadius);

        if (StompImpactEmitterClass != none)
            StompEmitter = Spawn(StompImpactEmitterClass,,, PawLocation);
		if (StompSound != None && StompEmitter != None)
			StompEmitter.PlaySound(StompSound,,Pawn.TransientSoundVolume,,Pawn.TransientSoundRadius);
    }
}

/** Notification from our Pawn to perform jump stomp damage on the back legs */
function NotifyJumpStompBack() {
    local float ScaledStompRadius;

    local vector PawLocation;
    local Pawn Victim;
	local Emitter StompEmitter;

    ScaledStompRadius = JumpStompRadius * GetAttackScale();

    if (BLPawBone != '' && BLPawBone != 'None') {
        PawLocation = Pawn.GetBoneCoords(BLPawBone).Origin;
        HurtRadius(JumpStompDamage, ScaledStompRadius, JumpStompDamageType, JumpStompMomentum, PawLocation);
        ShakeCameraDistanceBased(JumpStompShakeMag, PawLocation);

        foreach Pawn.VisibleCollidingActors(class'Pawn', Victim, ScaledStompRadius, PawLocation)
            if (Victim != Pawn) SendPawnFlying(PawLocation, Victim, JumpStompFlyVel, ScaledStompRadius);

        if (StompImpactEmitterClass != none)
            StompEmitter = Spawn(StompImpactEmitterClass,,, PawLocation);
		if (StompSound != None && StompEmitter != None)
			StompEmitter.PlaySound(StompSound,,Pawn.TransientSoundVolume,,Pawn.TransientSoundRadius);
    }

    if (BRPawBone != '' && BRPawBone != 'None') {
        PawLocation = Pawn.GetBoneCoords(BRPawBone).Origin;
        HurtRadius(JumpStompDamage, ScaledStompRadius, JumpStompDamageType, JumpStompMomentum, PawLocation);
        ShakeCameraDistanceBased(JumpStompShakeMag, PawLocation);

        foreach Pawn.VisibleCollidingActors(class'Pawn', Victim, ScaledStompRadius, PawLocation)
            if (Victim != Pawn) SendPawnFlying(PawLocation, Victim, JumpStompFlyVel, ScaledStompRadius);

        if (StompImpactEmitterClass != none)
            StompEmitter = Spawn(StompImpactEmitterClass,,, PawLocation);
		if (StompSound != None && StompEmitter != None)
			StompEmitter.PlaySound(StompSound,,Pawn.TransientSoundVolume,,Pawn.TransientSoundRadius);
    }
}

/** Notification from our Pawn to perform our roar */
function NotifyRoar() {
    if (RoarSound != none)
        Pawn.PlaySound(RoarSound, SLOT_Talk, 2, false, 500);
}

/** Overriden so we may include the interpolation of size as well */
event Tick(float DeltaTime) {
    super.Tick(DeltaTime);

    if (bInterpSize && !IsAtFinalCureStage())
        UpdateSizeInterpolation(DeltaTime);
}

/** Using the given delta time, updates the current interpolation size
 * @param DeltaTime - Tick in seconds since the last Tick call
 */
function UpdateSizeInterpolation(float DeltaTime) {
    local float InterpPct;

    InterpSizeTime = FMin(InterpSizeTime + DeltaTime, InterpSizeEndTime);

    switch (ShrinkInterpStyle) {
        case INTERP_Linear:
            InterpPct = InterpSizeTime / InterpSizeEndTime;
            break;
        case INTERP_SineEaseIn:
            InterpPct = class'P2EMath'.static.SineEaseIn(InterpSizeTime,
                InterpSizeEndTime);
            break;
        case INTERP_SineEaseOut:
            InterpPct = class'P2EMath'.static.SineEaseOut(InterpSizeTime,
                InterpSizeEndTime);
            break;
        case INTERP_EaseIn:
            InterpPct = class'P2EMath'.static.FInterpEaseIn(0, 1,
                InterpSizeTime / InterpSizeEndTime, InterpSpeedExponent);
            break;
        case INTERP_EaseOut:
            InterpPct = class'P2EMath'.static.FInterpEaseOut(0, 1,
                InterpSizeTime / InterpSizeEndTime, InterpSpeedExponent);
            break;
    }

    Pawn.PrePivot.Z = GetShrinkZPivot(InterpPct);

    Pawn.SetDrawScale(GetShrinkScale(InterpPct));

    UpdateCollisionBoltonSize(InterpPct);

    if (InterpSizeTime == InterpSizeEndTime) {
        bInterpSize = false;

        if (!IsAtFinalCureStage())
            CurrentStage++;

        if (IsAtFinalCureStage()) {
            DestroyCollisionBoltons();
            TriggerEvent(Pawn.Event, self, PostalDude);
        }
    }
}

/** Updates all the collision boltons size given the current interpolation percent */
function UpdateCollisionBoltonSize(float Pct) {
    local int i;
    local float PrevScale, NextScale, InterpScale;

    PrevScale = CureStages[CurrentStage].StageScale / CureStages[0].StageScale;
    NextScale = CureStages[CurrentStage + 1].StageScale / CureStages[0].StageScale;
    InterpScale = NextScale + (PrevScale - NextScale) * (1 - Pct);

    for (i=0;i<CollisionBoltons.length;i++) {
        if (CollisionBoltons[i].Bolton != none) {
            CollisionBoltons[i].Bolton.SetDrawScale3D(CollisionBoltons[i].Scale3D * InterpScale);
            CollisionBoltons[i].Bolton.SetRelativeLocation(CollisionBoltons[i].RelLoc * InterpScale);
        }
    }
}

state Idle
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        Pawn.LoopAnim('lay_in', 0.1);
        SetTimer(ThinkInterval, true);
    }

    function Timer() {
        DecideNextMove();
    }

Begin:
    StopMoving();
}

/** Move to the Postal Dude normally via Paths and running directly to him */
state MoveToDude
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Pawn.GroundSpeed = CureStages[CurrentStage].StageRunSpeed;

        if (CurrentStage >= FreeMovementStage)
            Pawn.LoopAnim(RunAnim.Anim, CureStages[CurrentStage].StageRunAnimRate);
        else
            Pawn.LoopAnim(WalkAnim.Anim, CureStages[CurrentStage].StageRunAnimRate);

        SetTimer(ThinkInterval, true);
    }

    function Timer() {
        DecideNextAttack();
    }

Begin:
    while (ShouldMoveToDude()) {
        if (ActorReachable(PostalDude)) {
            PathNotFoundCnt = 0;
            MoveToward(PostalDude);
        }
		else {
			MoveTarget = FindPathToward(PostalDude);

            if (MoveTarget != none) {
                PathNotFoundCnt = 0;
				MoveToward(MoveTarget);
            }
            else {
                PathNotFoundCnt++;
                Sleep(0.1);

                if (PathNotFoundCnt == PathNotFoundThreshold)
                    CantFindPathToDude();
            }
		}
    }

    DecideNextAttack();

    // Called if we somehow don't have an attack
    GotoState('Idle');
}

/** Move to the Postal Dude using only Paths to get around the pillars */
state MoveToDudePathed
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Pawn.GroundSpeed = CureStages[CurrentStage].StageRunSpeed;

        if (CurrentStage >= FreeMovementStage)
            Pawn.LoopAnim(RunAnim.Anim, CureStages[CurrentStage].StageRunAnimRate);
        else
            Pawn.LoopAnim(WalkAnim.Anim, CureStages[CurrentStage].StageRunAnimRate);

        SetTimer(ThinkInterval, true);
    }

    function Timer() {
        DecideNextAttack();
    }

Begin:
    Destination = GetClosestPathnode(PostalDude, false);

    while (ShouldMoveToDestination()) {
        Destination = GetClosestPathnode(PostalDude, false);
        MoveTarget = FindPathToward(Destination);

        if (MoveTarget != none) {
            PathNotFoundCnt = 0;
            MoveToward(MoveTarget);
        }
        else {
            PathNotFoundCnt++;
            Sleep(0.1);

            if (PathNotFoundCnt == PathNotFoundThreshold)
                CantFindPathToDestination();
        }
    }

    DecideNextAttack();

    // called if we somehow don't have an attack
    //GotoState('Idle');
	CantFindPathToDude();
}

/** Give a deafening roar to knock the Dude out of his Catnip high */
state Roar
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        if (Level.TimeDilation < 1 && P2Player(PostalDude.Controller) != none)
            P2Player(PostalDude.Controller).CatnipUseTime = 0.1;

        PlayAnimByDuration(RoarAnim, RoarTime, AnimBlendTime);
        SetTimer(RoarTime, false);
    }

    function Timer() {
        DecideNextMove();
    }

Begin:
    StopMoving();
}

/** Fire out some homing fireballs into the air */
state Fireball
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        bCanUseFireball = false;
        AddTimer(FireballCooldown, 'EnableFireball', false);

        FaceForward();

        PlayAnimByDuration(FireballAnim, FireballTime, AnimBlendTime);
        SetTimer(FireballTime, false);
    }

    function Timer() {
        DecideNextMove();
    }

Begin:
    StopMoving();
}

/** Mutant champ has a serious case of bad doggy breath */
state Flamethrower
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        bCanUseFlamethrower = false;
        AddTimer(FlamethrowerCooldown, 'EnableFlamethrower', false);

        FaceForward();

        PlayAnimByDuration(FlamethrowerAnim, FlamethrowerTime, AnimBlendTime);
        SetTimer(FlamethrowerTime, false);
    }

    function EndState() {
        if (FlamethrowerEmitter != none) {
            FlamethrowerEmitter.Destroy();
            FlamethrowerEmitter = none;
        }
    }

    function Timer() {
        DecideNextMove();
    }

Begin:
    StopMoving();
}

/** Eat lava, piss napalm. Piss in a circle and try to trap the Dude */
state NapalmPiss
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        bCanUseNapalmPiss = false;
        AddTimer(NapalmPissCooldown, 'EnableNapalmPiss', false);

        PlayAnimByDuration(NapalmPissAnim, NapalmPissTime, AnimBlendTime);
        SetTimer(NapalmPissTime, false);
    }

    function Timer() {
        DecideNextMove();
    }

Begin:
    StopMoving();
}

/** Bite grab the Dude and if we can, flail him around */
state Bite
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = PostalDude;

        PerformAttack();
    }

    function PerformAttack() {
        PlayAnimByDuration(BiteAnim, BiteTime, AnimBlendTime);
		Pawn.PlaySound(BiteSound,,Pawn.TransientSoundVolume,,Pawn.TransientSoundRadius);
        SetTimer(BiteTime, false);
    }

    function Timer() {
        if (ShouldUseBite())
            PerformAttack();
        else
            DecideNextMove();
    }

Begin:
    StopMoving();
}

/** Now that we have the Dude in our mouth, flail him around a bit */
state Flail
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        bCanUseFlail = false;
        AddTimer(FlailCooldown, 'EnableFlail', false);

        FaceForward();

        PlayAnimByDuration(FlailAnim, FlailTime, AnimBlendTime);

        SetTimer(FlailTime, false);
    }

    function Timer() {
        GotoState('FlailRelease');
    }

    event Tick(float DeltaTime) {
        local vector MouthLocation;
        local rotator MouthRotation;

        super.Tick(DeltaTime);

        if (FlailVictim != none) {
            MouthRotation = GetMouthRotation() + FlailRotationOffset;

            MouthLocation = GetMouthLocation() +
                class'P2EMath'.static.GetOffset(MouthRotation, FlailLocationOffset);

            FlailVictim.SetPhysics(PHYS_None);
            FlailVictim.SetLocation(MouthLocation);
        }
    }

Begin:
    StopMoving();
}

/** Now that we're done shaking him around, let's throw the Dude away */
state FlailRelease
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        PlayAnimByDuration(FlailReleaseAnim, FlailReleaseTime, AnimBlendTime);
        SetTimer(FlailReleaseTime, false);
    }

    function Timer() {
        DecideNextMove();
    }

    event Tick(float DeltaTime) {
        local vector MouthLocation;
        local rotator MouthRotation;

        super.Tick(DeltaTime);

        if (FlailVictim != none) {
            MouthRotation = GetMouthRotation() + FlailRotationOffset;

            MouthLocation = GetMouthLocation() +
                class'P2EMath'.static.GetOffset(MouthRotation, FlailLocationOffset);

            OldFlailLoc = NewFlailLoc;
            NewFlailLoc = MouthLocation;

            FlailVictim.SetPhysics(PHYS_None);
            FlailVictim.SetLocation(MouthLocation);
        }
    }

Begin:
    StopMoving();
}

/** Stomp down on the Dude with our front two paws */
state Stomp
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        bCanUseStomp = false;
        AddTimer(StompCooldown, 'EnableStomp', false);

        Focus = PostalDude;

        PlayAnimByDuration(StompAnim, StompTime, AnimBlendTime);
        SetTimer(StompTime, false);
    }

    function Timer() {
        DecideNextMove();
    }

Begin:
    StopMoving();
}

/** Variation of the stomp attack where we get the Dude out from under us */
state JumpStomp
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        PerformAttack();
    }

    function PerformAttack() {
        PlayAnimByDuration(JumpStompAnim, JumpStompTime, AnimBlendTime);
        SetTimer(JumpStompTime, false);
    }

    function Timer() {
        if (ShouldUseJumpStomp())
            PerformAttack();
        else
            DecideNextMove();
    }

Begin:
    StopMoving();
}

/** Mutant Champ has been shot pretty bad, so he now falls to the floor */
state StunStart
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        PlayAnimByDuration(StunStartAnim, StunStartTime, AnimBlendTime);
        SetTimer(StunStartTime, false);
    }

    function Timer() {
        GotoState('Stunned');
    }

Begin:
    StopMoving();
}

/** Mutant Champ leaves himself opened to being hit with the cure needle */
state Stunned
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        DettachCollisionBoltons();

        PlayAnimByDuration(StunAnim, StunTime, AnimBlendTime);
        SetTimer(StunTime, false);

		// Tell the dude it's his chance
		if (P2Player(PostalDude.Controller) != None)
			P2Player(PostalDude.Controller).ShouldUseCure();
    }

    function EndState() {
        ReattachCollisionBoltons();
    }

    function Timer() {
        GotoState('StunRecover');
    }

Begin:
    StopMoving();
WhimperLoop:
	Pawn.PlaySound(StunnedSound,,Pawn.TransientSoundVolume,,Pawn.TransientSoundRadius);
	Sleep(3.0);
	Goto('WhimperLoop');
}

/** We've just been shot with the cure syringe, so recoil a bit */
state StunShot
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        bCureStunRecover = true;

        FaceForward();

        PlayAnimByDuration(StunShotAnim, StunShotTime, AnimBlendTime);
        SetTimer(StunShotTime, false);
        InterpolateSize();
    }

    function Timer() {
        if (IsNextStageFinal())
            GotoState('Incapacitated');
        else
            GotoState('StunRecover');
    }

Begin:
    StopMoving();
}

/** Mutant Champ is now recovering from being shot up really bad */
state StunRecover
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        HealthRegenTime = 0.0;

        PlayAnimByDuration(StunRecoverAnim, StunRecoverTime, AnimBlendTime);
        SetTimer(StunRecoverTime, false);
    }

    function EndState() {
        bCureStunRecover = false;
    }

    function Timer() {
        DecideNextMove();
    }


    event Tick(float DeltaTime) {
        local float HealthRegenPct, StunnedHealth;

        super.Tick(DeltaTime);

        if (MutantChamp == none)
            return;

        HealthRegenTime = FMin(HealthRegenTime + DeltaTime, StunRecoverTime);
        HealthRegenPct = HealthRegenTime / StunRecoverTime;

        StunnedHealth = MutantChamp.HealthMax * StunHealthPct;

        if (bCureStunRecover)
            MutantChamp.Health = StunnedHealth + (MutantChamp.HealthMax - StunnedHealth) * HealthRegenPct;
        else
            MutantChamp.Health = StunnedHealth + (MutantChamp.HealthMax * CureFailedHealthPct - StunnedHealth) * HealthRegenPct;
    }

Begin:
    StopMoving();
}

/** Basically just our stunned stage, except this is a trap state for when
 * the player turns champ back to normal
 */
state Incapacitated
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        DettachCollisionBoltons();

        LoopAnimInfo(StunAnim, AnimBlendTime);
    }

Begin:
    StopMoving();
}

/** Play our lay down animation */
state StartLayDown
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        PlayAnimByDuration(LayDownStartAnim, LayDownStartTime, AnimBlendTime);
        SetTimer(LayDownStartTime, false);
    }

    function Timer() {
        GotoState('LayDown');
    }

Begin:
    StopMoving();
}

/** Simply loop our laydown animation now that the Dude is dead */
state LayDown
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        LoopAnimInfo(LayDownAnim, AnimBlendTime);
    }

Begin:
    StopMoving();
}

defaultproperties
{
    bLogDebug=false

    bCanUseFireball=false
    bCanUseFlamethrower=true
    bCanUseNapalmPiss=true
    bCanUseFlail=true
    bCanUseStomp=true

    PathNotFoundThreshold=10

    CurrentStage=0

    ThinkInterval=0.1
    AnimBlendTime=0.1

    DudeReachedRadius=128
    DestinationReachedRadius=128

    IdleAnim=(Anim="stand",Rate=1,AnimTime=10.53)
    WalkAnim=(Anim="Walk",Rate=1,AnimTime=1.06)
    RunAnim=(Anim="Run",Rate=1,AnimTime=1.03)

    MouthBone="Bip001 Ponytail1Nub"

    FLPawBone="Bip001 L Finger0"
    FRPawBone="Bip001 R Finger0"
    BLPawBone="Bip001 L Toe0"
    BRPawBone="Bip001 R Toe0"

    //--------------------------------------------------------------------------
    // Roar

    RoarTime=3.53
    RoarAnim=(Anim="Roar",AnimTime=3.53)
    RoarSound=sound'PLAnimalSounds.dogg.mutdog_roar'

    //--------------------------------------------------------------------------
    // Fireball

    FireballCooldown=60
    FireballTime=4.6

    FireballOffset=(X=0,Y=15,Z=0)
    FireballRotationOffset=(Pitch=-16384,Yaw=-32768,Roll=0)

    FireballProjectileClass=class'MutantChampHomingProjectile'
    FireballAnim=(Anim="bark",AnimTime=2.3)

    //--------------------------------------------------------------------------
    // Flamethrower

    FlamethrowerStartAngle=30

    FlamethrowerCooldown=15
    FlamethrowerTime=2.7
    FlamethrowerRange=750

    FlamethrowerRelativeLocation=(X=0,Y=15,Z=0)
    FlamethrowerRelativeRotation=(Pitch=0,Yaw=-24576,Roll=0)

    FlamethrowerEmitterClass=class'MutantChampFlamethrower'
    FlamethrowerAnim=(Anim="Flamethrower",AnimTime=2.7)

    //--------------------------------------------------------------------------
    // Napalm Piss (Not Used)

    NapalmPissCooldown=1
    NapalmPissTime=3.36
    NapalmPissRange=1500

    NapalmPissAnim=(Anim="piss",AnimTime=3.36)

    //--------------------------------------------------------------------------
    // Bite

    BiteTime=1.36
    BiteRange=600

    BiteLocationOffset=(X=-120,Y=0,Z=0)

    BiteRadius=300
    BiteAngle=45
    BiteDamage=30
    BiteFlyVel=250
    BiteMomentum=60000

    BiteDamageType=class'MutantChampBiteDamage'
    BiteAnim=(Anim="Bite",AnimTime=1.36)

    //--------------------------------------------------------------------------
    // Flail (Bite Followup)

    FlailCooldown=30
    FlailTime=1.16
    FlailReleaseTime=1.36
    FlailDamage=15
    FlailReleaseVel=2000

    FlailLocationOffset=(X=0,Y=140,Z=0)
    FlailRotationOffset=(Pitch=-16384,Yaw=-32768,Roll=0)

    FlailDamageType=class'MutantChampBiteDamage'
    FlailAnim=(Anim="attack",AnimTime=1.16)
    FlailReleaseAnim=(Anim="AttackRelease",AnimTime=1.36)

    //--------------------------------------------------------------------------
    // Stomp

    StompCooldown=10
    StompTime=2.18
    StompRange=750
    StompDamage=60
    StompRadius=500
    StompFlyVel=750
    StompShakeMag=150
    StompMomentum=60000

    StompDamageType=class'MutantChampMeleeDamage'
    StompImpactEmitterClass=class'EasterBunnyGroundImpact'
    StompAnim=(Anim="Stomp",AnimTime=4.36)

    //--------------------------------------------------------------------------
    // Jump Stomp

    JumpStompTime=0.86
    JumpStompRange=300
    JumpStompDamage=60
    JumpStompRadius=500
    JumpStompFlyVel=750
    JumpStompMomentum=60000
    JumpStompShakeMag=150

    JumpStompDamageType=class'MutantChampMeleeDamage'
    JumpStompAnim=(Anim="pounce",AnimTime=0.86)

    //--------------------------------------------------------------------------
    // Footsteps

    FootstepRadius=500
    FootstepDamage=15
    FootstepFlyVel=500
    FootstepMomentum=60000
    FootstepShakeMag=75

    MinMagForShake=20
    MaxShakeDist=2000

    FootstepDamageType=class'MutantChampMeleeDamage'

    //--------------------------------------------------------------------------
    // Cure Stages

    FreeMovementStage=2

    CureStages(0)=(StageRunSpeed=650,StageRunAnimRate=1.5,StageScale=5,StageZPivot=265)
    CureStages(1)=(StageRunSpeed=650,StageRunAnimRate=2.5,StageScale=3,StageZPivot=135)
    CureStages(2)=(StageRunSpeed=650,StageRunAnimRate=2,StageScale=1.75,StageZPivot=55)
    CureStages(3)=(StageRunSpeed=450,StageRunAnimRate=1,StageScale=1,StageZPivot=5)

    ShrinkExponent=2
    ShrinkInterpStyle=INTERP_Linear

    //--------------------------------------------------------------------------
    // Stunned State

    StunHealthPct=0.1

    CureFailedHealthPct=0.4

    StunStartTime=2.7
    StunTime=5
    StunRecoverTime=2.7
    StunShotTime=0.7

    StunCollapseRadius=1000
    StunCollapseShakeMag=150
    StunCollapseFlyVel=750

    StunStartAnim=(Anim="StunStart",AnimTime=2.7)
    StunAnim=(Anim="StunLoop",Rate=1,AnimTime=6.7)
    StunRecoverAnim=(Anim="StunEnd",AnimTime=2.7)
    StunShotAnim=(Anim="StunShotReaction",AnimTime=0.7)

    //--------------------------------------------------------------------------
    // Laying Down

    LayDownStartTime=2.03

    LayDownStartAnim=(Anim="lay_in",AnimTime=2.03)
    LayDownAnim=(Anim="lay_on",AnimTime=2.03)

    //--------------------------------------------------------------------------
    // Collision

    CollisionBoltonClass=class'MutantChampCollision'

    CollisionBoltons(0)=(DamageMult=2.0,Scale3D=(X=0.31,Y=0.52,Z=0.31),RelLoc=(X=3,Y=-14,Z=0),RelRot=(Pitch=0,Yaw=-1536,Roll=0),BoneName="Bip001 Head")
    //CollisionBoltons(1)=(DamageMult=2.0,Scale3D=(X=0.09,Y=0.28,Z=0.28),RelLoc=(X=0,Y=5,Z=0),BoneName="Bip001 Ponytail1Nub")
    CollisionBoltons(1)=(DamageMult=2.0,Scale3D=(X=0.58,Y=0.45,Z=0.41),RelLoc=(X=6,Y=0,Z=0),BoneName="Bip001 Neck1")

    CollisionBoltons(2)=(DamageMult=0.75,Scale3D=(X=0.85,Y=0.45,Z=0.36),RelLoc=(X=4,Y=0,Z=-2),RelRot=(Pitch=0,Yaw=1024,Roll=0),BoneName="Bip001 L UpperArm")
    CollisionBoltons(3)=(DamageMult=0.75,Scale3D=(X=0.85,Y=0.45,Z=0.36),RelLoc=(X=4,Y=0,Z=2),RelRot=(Pitch=0,Yaw=1024,Roll=0),BoneName="Bip001 R UpperArm")

    CollisionBoltons(4)=(DamageMult=0.5,Scale3D=(X=0.8,Y=0.2,Z=0.16),RelLoc=(X=12,Y=0,Z=0),BoneName="Bip001 L Forearm")
    CollisionBoltons(5)=(DamageMult=0.5,Scale3D=(X=0.8,Y=0.2,Z=0.16),RelLoc=(X=12,Y=0,Z=0),BoneName="Bip001 R Forearm")

    CollisionBoltons(6)=(DamageMult=0.5,Scale3D=(X=0.36,Y=0.13,Z=0.2),RelLoc=(X=5,Y=0,Z=0),BoneName="Bip001 L Hand")
    CollisionBoltons(7)=(DamageMult=0.5,Scale3D=(X=0.36,Y=0.13,Z=0.2),RelLoc=(X=5,Y=0,Z=0),BoneName="Bip001 R Hand")

    //CollisionBoltons(9)=(DamageMult=0.75,Scale3D=(X=0.27,Y=0.75,Z=0.71),RelLoc=(X=0,Y=-2,Z=0),RelRot=(Pitch=0,Yaw=-3328,Roll=0),BoneName="Bip001 Spine3")
    //CollisionBoltons(10)=(DamageMult=0.75,Scale3D=(X=0.35,Y=0.7,Z=0.67),RelRot=(Pitch=0,Yaw=-2048,Roll=0),BoneName="Bip001 Spine2")
    CollisionBoltons(8)=(DamageMult=0.75,Scale3D=(X=1.71,Y=0.70,Z=0.67),RelRot=(Pitch=0,Yaw=256,Roll=0),BoneName="Bip001 Spine2")
    //CollisionBoltons(11)=(DamageMult=0.75,Scale3D=(X=0.2,Y=0.65,Z=0.6),RelLoc=(X=1,Y=2,Z=0),RelRot=(Pitch=0,Yaw=-1280,Roll=0),BoneName="Bip001 Spine1")
    //CollisionBoltons(12)=(DamageMult=0.75,Scale3D=(X=0.65,Y=0.61,Z=0.69),RelLoc=(X=-5,Y=1,Z=0),RelRot=(Pitch=0,Yaw=-256,Roll=0),BoneName="Bip001 Spine")

    CollisionBoltons(9)=(DamageMult=0.75,Scale3D=(X=0.58,Y=0.41,Z=0.28),RelLoc=(X=22,Y=0,Z=0),RelRot=(Pitch=0,Yaw=1536,Roll=0),BoneName="Bip001 L Thigh")
    CollisionBoltons(10)=(DamageMult=0.75,Scale3D=(X=0.58,Y=0.41,Z=0.28),RelLoc=(X=22,Y=0,Z=0),RelRot=(Pitch=0,Yaw=1536,Roll=0),BoneName="Bip001 R Thigh")

    CollisionBoltons(11)=(DamageMult=0.5,Scale3D=(X=0.37,Y=0.20,Z=0.13),RelLoc=(X=10,Y=0,Z=0),RelRot=(Pitch=0,Yaw=-1536,Roll=0),BoneName="Bip001 L Calf")
    CollisionBoltons(12)=(DamageMult=0.5,Scale3D=(X=0.37,Y=0.20,Z=0.13),RelLoc=(X=10,Y=0,Z=0),RelRot=(Pitch=0,Yaw=-1536,Roll=0),BoneName="Bip001 R Calf")

    //CollisionBoltons(17)=(DamageMult=0.5,Scale3D=(X=0.28,Y=0.2,Z=0.1),RelLoc=(X=7,Y=1,Z=0),BoneName="Bip001 L HorseLink")
    //CollisionBoltons(18)=(DamageMult=0.5,Scale3D=(X=0.28,Y=0.2,Z=0.1),RelLoc=(X=7,Y=1,Z=0),BoneName="Bip001 R HorseLink")

    CollisionBoltons(13)=(DamageMult=0.5,Scale3D=(X=0.6,Y=0.2,Z=0.12),RelLoc=(X=-3,Y=1,Z=0),RelRot=(Pitch=0,Yaw=-2304,Roll=0),BoneName="Bip001 L Foot")
    CollisionBoltons(14)=(DamageMult=0.5,Scale3D=(X=0.6,Y=0.2,Z=0.12),RelLoc=(X=-3,Y=1,Z=0),RelRot=(Pitch=0,Yaw=-2304,Roll=0),BoneName="Bip001 R Foot")
    //CollisionBoltons(19)=(DamageMult=0.5,Scale3D=(X=0.27,Y=0.2,Z=0.12),RelLoc=(X=3,Y=1,Z=0),RelRot=(Pitch=0,Yaw=-2304,Roll=0),BoneName="Bip001 L Foot")
    //CollisionBoltons(20)=(DamageMult=0.5,Scale3D=(X=0.27,Y=0.2,Z=0.12),RelLoc=(X=3,Y=1,Z=0),RelRot=(Pitch=0,Yaw=-2304,Roll=0),BoneName="Bip001 R Foot")

    //CollisionBoltons(21)=(DamageMult=0.25,Scale3D=(X=0.28,Y=0.16,Z=0.15),RelLoc=(X=5,Y=-1,Z=0),BoneName="Bip001 Tail")
    //CollisionBoltons(22)=(DamageMult=0.25,Scale3D=(X=0.3,Y=0.11,Z=0.13),RelLoc=(X=3,Y=0,Z=0),BoneName="Bip001 Tail1")
    //CollisionBoltons(23)=(DamageMult=0.25,Scale3D=(X=0.32,Y=0.1,Z=0.11),RelLoc=(X=3,Y=0,Z=0),BoneName="Bip001 Tail2")
    //CollisionBoltons(24)=(DamageMult=0.25,Scale3D=(X=0.39,Y=0.07,Z=0.08),RelLoc=(X=5,Y=0,Z=0),BoneName="Bip001 Tail3")

	//--------------------------------------------------------------------------
	// Sounds

    StompSound=Sound'WeaponSounds.foot_kickwall'
	BiteSound=Sound'PLAnimalSounds.dogg.mutdog_biting3'
	FlailSound=Sound'PLAnimalSounds.dogg.mutdog_meanbark2'
	StunnedSound=Sound'PLAnimalSounds.dogg.mutdog_whimper2'
	FireballSound=Sound'PLAnimalSounds.dogg.mutdog_biting2'
}
