/**
 * ObeseBitchController
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Insert hatred for the Postal Dude, love for her new husbands due to very
 * low standards, and love for greasy fried food here.
 *
 * Delete anything having to do with housework, exercise, and eating healthy.
 *
 * @author Gordon Cheng
 */
class ObeseBitchController extends P2EAIController;

/** Basic attack and movement variables */
var float ThinkInterval;
var float MoveReachedRadius;
var float AnimBlendTime;
var name LedgeNodeTag;

/** Basic animations */
var AnimInfo IdleAnim, WalkAnim, RunAnim;

/** Stomping sounds to play when the Bitch is running */
var sound RunSound;
var float RunSoundVolume, RunSoundRadius;

/** Banshee scream; Used to snap the Dude out of his super powered catnip high */
var float BansheeScreamTime;
var array<sound> BansheeScreamSounds;
var AnimInfo BansheeScreamAnim;

/** General effects for her hulk-like attacks */
var class<P2Emitter> ImpactEmitterClass;

/** Butt Stomp; Utilizes her gigantic ass to create a massive shockwave */
var float StompAttackRadius;
var float StompTime, StompRadius, StompDamage, StompFlyVel;
var float StompMovementSpeed, StompMomentum, StompShakeMag;
var sound StompSound;
var class<P2Emitter> StompImpactEmitter;
var class<DamageType> StompDamageType;
var AnimInfo StompAnim;
var array<Sound> DialogButtStomp;

/** Leap; Jump closer to the Dude or farther for a dash attack */
var bool bUseHigherLeapArcToDude, bUseHigherLeapArcFromDude, bUseHigherLeapArcToLedge;
var float LeapToDudeSpeed, LeapBackFromDudeSpeed, LeapToLedgeSpeed;
var float LeapTowardMinDistance, LeapBackDistance, LeapToDudeOffset;
var float LeapPrepTime, LeapLandTime;
var float LeapAnimUpdateInterval;
var float LeapLandShakeMag;
var AnimInfo LeapPrepAnim, LeapAnim, LeapLandAnim;
var float LeapStartTime;
var float LeapTimeMax;

/** Belly Flop; Jump into the air and use our spare tire to slam the ground */
var float BellyFlopStartTime, BellyFlopEndTime, BellyFlopRadius;
var float BellyFlopDamage, BellyFlopFlyVel, BellyFlopMomentum;
var float BellyFlopShakeMag;
var sound BellyFlopImpactSound;
var class<P2Emitter> BellyFlopImpactEmitter;
var class<DamageType> BellyFlopDamageType;
var AnimInfo BellyFlopStartAnim, BellyFlopAnim, BellyFlopEndAnim;
var Sound FlopSound;

/** Dash slash attack; Here we dash toward the Dude to hit him */
var float DashCooldown;
var float DashMinDistance, DashSpeed;
var float DashDamage, DashHitAngle, DashMomentum, DashHitRadius, DashHitFlyVel;
var float DashHitVelPct, DashMissVelPct, DashWallHitVelPct;
var float DashPrepTime, DashHitTime, DashWallHitTime, DashRecoverTime, DashMissTime;
var float DashWallHitSelfDamagePct;
var class<DamageType> DashDamageType;
var AnimInfo DashPrepAnim, DashRunAnim, DashHitAnim, DashWallHitAnim;
var AnimInfo DashRecoverAnim, DashMissAnim;
var Sound DashHitSound, DashHitWallSound;

/** Shockwave attack; Creates an explosive shockwave that travels along the ground */
var float ShockwaveCooldown;
var float ShockwaveTime;
var float ShockwaveDamage, ShockwaveRadius, ShockwaveMomentum, ShockwaveFlyVel;
var float ShockwaveShakeMag;
var class<DamageType> ShockwaveDamageType;
var class<ObeseBitchShockwave> ShockwaveClass;
var AnimInfo ShockwaveAnim;

/** Rock Drop attack; Punches the ground that causes stalactites to fall from the ceiling */
var bool bRockDropLeadTarget;
var float RockDropCooldown;
var float RockDropTime;
var float RockDropDamage, RockDropRadius, RockDropMomentum, RockDropFlyVel;
var float RockDropSpread, RockDropZOffset;
var float RockDropShakeMag;
var class<DamageType> RockDropDamageType;
var class<P2Projectile> RockDropProjectileClass;
var AnimInfo RockDropAnim;

/** Screen shake values */
var float MinMagForShake, MaxShakeDist;
var float WalkShakeMag, RunShakeMag;

/** Misc objects and values */
var int PathNotFoundCnt, PathNotFoundThreshold;
var Pawn PostalDude;
var ObeseBitch ObeseBitch;

var bool bCanUseDash, bEndDashWithSmash;
var bool bCanUseShockwave, bCanUseRockDrop;

var int CurrentStage;
var array<float> GrowStageScales;

var bool bOldFalling, bNewFalling;
var bool bLeapToDude, bLeapToLedge;
var vector LeapDestination;
var PathNode LeapToNode;
var PathNode LeapFromNode;

/** Breaking props */
var name BreakablePropTag;
var Sound BreakPropSound;
var class<Emitter> BreakPropEffect;

/** Prototype to be implemented in the states, here so we don't possibly get scope errors */
function PerformAttack();

/** Returns whether or not we have a Postal Dude or if he is dead
 * @return TRUE if Postal Dude exists and if he's alive; FALSE otherwise
 */
function bool IsPostalDudeValid() {
    return (PostalDude != none && PostalDude.Health > 0);
}

/** Returns whether or not the specified Actor is inside a SlimBitchArenaVolume
 * @param Other - Actor we're gonna test if its inside a SlimBitchArenaVolume
 * @return TRUE if the specified Actor is inside a SlimBitchArenaVolume; FALSE otherwise
 */
function bool IsInArenaVolume(Actor Other) {
    local SlimBitchArenaVolume ArenaVolume;

    foreach AllActors(class'SlimBitchArenaVolume', ArenaVolume)
        if (Other.IsInVolume(ArenaVolume))
            return true;

	return false;
}

/** Returns whether or not the Postal Dude is close enough for a butt stomp
 * @return TRUE if the Postal Dude is close enough; FALSE otherwise
 */
function bool IsCloseEnoughForStomp() {
    if (!IsPostalDudeValid())
        return false;

    return VSize(PostalDude.Location - Pawn.Location) <= StompAttackRadius * GetAttackScale();
}

/** Returns whether or not we're currently soaring through the air
 * @return TRUE if we're in the leaping state; FALSE otherwise
 */
function bool IsPerformingLeap() {
    return (IsInState('LeapPrep') || IsInState('Leaping') || IsInState('LeapLand'));
}

/** Returns whether or not Slim Bitch has reached the leaping PathNode
 * @return TRUE if we've reached it the leaping PathNode; FALSE otherwise
 */
function bool HasReachedLeapFromNode() {
    if (LeapFromNode == none)
        return false;

    return VSize(LeapFromNode.Location - Pawn.Location) <= MoveReachedRadius;
}

/** Returns whether or not we've reached the Postal Dude
 * @return TRUE if we're close enough to be considered reached; FALSE otherwise
 */
function bool HasReachedDude() {
    if (!IsPostalDudeValid())
        return true;

    return VSize(PostalDude.Location - Pawn.Location) <= MoveReachedRadius * GetAttackScale();
}

/** Returns whether or not we can can leap over to the specified location
 * @param Point - Location in the world we want to leap to
 * @param LeapSpeed - Speed at which you're gonna try to jump there
 * @return TRUE if we can backflip over to the point, FALSE otherwise
 */
function bool CanLeapToPoint(vector Point, float LeapSpeed) {
    return class'P2EMath'.static.CanHitTarget(Pawn.Location,
        Point, LeapSpeed, Pawn.PhysicsVolume.Gravity.Z);
}

/** Returns whether or not there's enough room to leap backwards
 * @return TRUE if there's enough room; FALSE otherwise
 */
function bool CanLeapBack() {
    local vector LeapBackDir, LeapBackDestination;
    local vector HitLocation, HitNormal;

    LeapBackDir = Pawn.Location - PostalDude.Location;
    LeapBackDir.Z = 0;

    LeapBackDestination = Pawn.Location + (Normal(LeapBackDir) * LeapBackDistance);

    return (Pawn.Trace(HitLocation, HitNormal, LeapDestination, Pawn.Location, true) == none);
}

/** Returns whether or not we should use our banshee scream attack
 * @return TRUE if we're in slowdown; FALSE otherwise
 */
function bool ShouldUseBansheeScream() {
	// Sanity check.
	if (PostalDude == None || P2Player(PostalDude.Controller) == None)
		return false;
		
	// Return true if any catnip time is left.
	return (P2Player(PostalDude.Controller).CatnipUseTime > 0);
	
    //return false;
    //return Level.TimeDilation < 1;
}

/** Returns whether or not conditions are optimal for a dash attack
 * @return TRUE if we should use a dash attack; FALSE otherwise
 */
function bool ShouldUseDashAttack() {
    if (!IsPostalDudeValid() || !bCanUseDash)
        return false;

	if (!FastTrace(PostalDude.Location, Pawn.Location))
		return false;

    return true;
    //return VSize(PostalDude.Location - Pawn.Location) >= DashSlashMinDistance;
}

/** Returns whether or not we can use our Shockwave attack
 * @return TRUE if we can use the attack again; FALSE otherwise
 */
function bool ShouldUseShockwaveAttack() {
    return bCanUseShockwave;
}

/** Returns whether or not we can use our Rock Drop attack
 * @return TRUE if we can use the attack again; FALSE otherwise
 */
function bool ShouldUseRockDropAttack() {
    return bCanUseRockDrop;
}

/** Returns whether or not Slim Bitch is close enough for the slash to connect
 * @return TRUE if the Dude is close enough to get hit; FALSE otherwise
 */
function bool IsCloseEnoughToHit() {
    if (!IsPostalDudeValid())
        return false;

    return VSize(PostalDude.Location - Pawn.Location) <= DashHitRadius * GetAttackScale();
}

/** Returns whether or not we should leap onto the raised ledges in the map
 * @return TRUE if the Postal Dude is up there but we aren't; FALSE otherwise
 */
function bool ShouldLeapOntoLedge() {
    if (!IsPostalDudeValid())
        return false;

    return (IsInArenaVolume(PostalDude) && !IsInArenaVolume(Pawn));
}

/** Returns whether or not we should, and if we can perform our leap ability
 * I didn't feel like coming up with a good elegant boolean value so I just
 * used a whole bunch of if statements.
 * @return TRUE if we should use our leap to get closer, FALSE otherwise
 */
function bool ShouldLeapTowardsDude() {
    local SlimBitchArenaVolume ArenaVolume;

    // If the Postal Dude is dead, don't
    if (!IsPostalDudeValid())
        return false;

    // If the Dude is on the ledge and we're not or vice versa, do
    if (IsInArenaVolume(PostalDude) != IsInArenaVolume(Pawn))
        return true;

    // If the Dude is far away, do
    if (VSize(PostalDude.Location - Pawn.Location) >= LeapTowardMinDistance)
        return true;

    return false;
}

/** Returns what stage this Obese Bitch is in
 * @return Stage number that this Obese Bitch is currently in
 */
function int GetCurrentStage() {
    local int i;

    if (ObeseBitch == none)
        return -1;

    for (i=0;i<GrowStageScales.length;i++)
        if (ObeseBitch.DrawScale == GrowStageScales[i])
            return i;

    return -1;
}

/** Returns the scale of all the range in which attacks should be used and
 * radius of all the impact damages with the size
 */
function float GetAttackScale() {
    return Pawn.DrawScale / Pawn.default.DrawScale;
}

/** Returns a PathNode that's closest to the Postal Dude on the raised paths
 * @return PathNode that's closest to the Postal Dude on the raised path
 */
function PathNode GetLeapToPathNode() {
    local int i, Closest;
    local float Distance, ClosestDistance;
    local PathNode PathNode;
    local array<PathNode> PathNodeList;

    foreach AllActors(class'PathNode', PathNode, LedgeNodeTag) {
        PathNodeList.Insert(PathNodeList.length, 1);
        PathNodeList[PathNodeList.length - 1] = PathNode;
    }

    Closest = -1;
    ClosestDistance = 3.4028e38;

    for (i=0;i<PathNodeList.length;i++) {
        Distance = VSize(PathNodeList[i].Location - PostalDude.Location);

        if (Distance < ClosestDistance) {
            ClosestDistance = Distance;
            Closest = i;
        }
    }

    if (Closest == -1)
        return none;
    else
        return PathNodeList[Closest];
}

/** Returns a PathNode that we should move to and leap from to get to the Dude
 * @return PathNode that should be leapt from in order to reach the Dude
 */
function PathNode GetLeapFromPathNode(Vector LeapFromVect) {
    local int i, Closest;
    local float Distance, ClosestDistance;
    local PathNode PathNode;
    local array<PathNode> PathNodeList;

    foreach AllActors(class'PathNode', PathNode) {
        if (PathNode.Tag != LedgeNodeTag) {
            PathNodeList.Insert(PathNodeList.length, 1);
            PathNodeList[PathNodeList.length - 1] = PathNode;
        }
    }

    Closest = -1;
    ClosestDistance = 3.4028e38;

    for (i=0;i<PathNodeList.length;i++) {
        Distance = VSize(PathNodeList[i].Location - PostalDude.Location);

        if (Distance < ClosestDistance && class'P2EMath'.static.CanHitTarget(LeapFromVect, PathNodeList[i].Location, LeapToLedgeSpeed, Pawn.PhysicsVolume.Gravity.Z)) {
            ClosestDistance = Distance;
            Closest = i;
        }
    }

    if (Closest == -1)
        return none;
    else
        return PathNodeList[Closest];
}

/** Sets up various values to prepare to leap to the ledge */
function SetupLeapToLedge() {
    LeapToNode = GetLeapToPathNode();
    LeapFromNode = GetLeapFromPathNode(LeapToNode.Location);
    LeapDestination = LeapToNode.Location;

    bLeapToDude = false;
    bLeapToLedge = true;

    if (CanLeapToPoint(LeapToNode.Location, LeapToLedgeSpeed))
        GotoState('LeapPrep');
    else
        GotoState('MoveToLeapNode');
}

/** Sets up various values to prepare a leap to the Postal Dude */
function SetupLeapToDude() {
    local vector LeapDir;

    LeapDir = Pawn.Location - PostalDude.Location;
    LeapDir.Z = 0;

    LeapDestination = PostalDude.Location + (Normal(LeapDir) * LeapToDudeOffset);

    if (CanLeapToPoint(LeapDestination, LeapToDudeSpeed)) {
        bLeapToDude = true;
        bLeapToLedge = false;
        GotoState('LeapPrep');
    }
}

/** Setups up various values to prepare a leap away from the Postal Dude */
function SetupLeapAwayFromDude() {
    local vector LeapBackDir;

    LeapBackDir = Pawn.Location - PostalDude.Location;
    LeapBackDir.Z = 0;

    LeapDestination = Pawn.Location + (Normal(LeapBackDir) * LeapBackDistance);

    if (CanLeapToPoint(LeapDestination, LeapBackFromDudeSpeed)) {
        bLeapToDude = false;
        bLeapToLedge = false;
        GotoState('LeapPrep');
    }
}

/** Sends the Slim Bitch into the air towards her destination
 * @param LeapSpeed - Speed in which we launch ourselves into the air
 * @param bUseHigherArc - Whether or not we use the higher trajectory arc
 */
function LeapToDestination(float LeapSpeed, bool bUseHigherArc) {
    local rotator LeapTrajectory;

    LeapTrajectory = class'P2EMath'.static.GetProjectileTrajectory(Pawn.Location,
        LeapDestination, LeapSpeed, PostalDude.Velocity, 0,
        Pawn.PhysicsVolume.Gravity.Z, true, bUseHigherArc);

    Pawn.AirSpeed = LeapSpeed * 2;
    Pawn.SetPhysics(PHYS_Falling);
    Pawn.Velocity = vector(LeapTrajectory) * LeapSpeed;
}

/** Copied over from the Elephant */
function ShakeCameraDistanceBased(float Mag) {
	local Controller con;
	local float usemag, usedist;

	for (con = Level.ControllerList;con != none;con = con.NextController) {
        if (con.bIsPlayer && con.Pawn != none) {
			usedist = VSize(con.Pawn.Location - Pawn.Location);

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

/** Given a Pawn, sends the poor bastard flying
 * Copied and modified from the EasterBunnyController
 * @param Other - Pawn to send flying into the air
 * @param FlyVelocity - The XY velocity and Z velocity to send them flying at
 * @param Radius - Max radius used to send Pawns flying. The closer they are
 *                 are to our Pawn, the farther they fly out
 */
function SendPawnFlying(Pawn Other, float FlyVelocity, float Radius) {
    local float VelocityPct;
    local vector OtherLocation, PawnLocation, OffGround;
    local vector FlyDir;

    // Let's not screw with ragdolls
    if (Other.Physics == PHYS_KarmaRagDoll)
        return;

    // Get the fly direction based only on the XY plane, not the Z
    OtherLocation = Other.Location;
    OtherLocation.Z = 0;

    PawnLocation = Pawn.Location;
    PawnLocation.Z = 0;

    OffGround = Other.Location;
    OffGround.Z += 32;

    FlyDir = Normal(OtherLocation - PawnLocation);

    VelocityPct = 1 - (VSize(Other.Location - Pawn.Location) / Radius);

    if (Other.Physics == PHYS_Walking) {
        // Send them flying only if they're walking
        Other.SetLocation(OffGround);
        Other.SetPhysics(PHYS_Falling);

        Other.Velocity = Normal(Other.Location - Pawn.Location) * FlyVelocity;
        Other.Velocity.Z = FlyVelocity;
    }
    else {
        // Otherwise if they're currently jumping just add additional velocity
        Other.SetPhysics(PHYS_Falling);

        Other.Velocity += Normal(Other.Location - Pawn.Location) * FlyVelocity * VelocityPct;
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

/** Returns whether or not we're performing a dash attack
 * @return TRUE if we're forming a dash attack; FALSE otherwise
 */
function bool IsPerformingDash() {
    return (IsInState('DashAttack') || IsInState('DashAttackEnd'));
}

/** Overriden to initialize some stuff */
function Possess(Pawn aPawn) {
    super.Possess(aPawn);

    aPawn.SetPhysics(PHYS_Falling);

    ObeseBitch = ObeseBitch(aPawn);

    if (ObeseBitch != none) {
        CurrentStage = GetCurrentStage();
        ObeseBitch.ObeseBitchController = self;
    }

    AddTimer(0.1, 'FindPostalDude', true);

	AddTimer(2.0, 'EnableDash', false);
	AddTimer(3.0, 'EnableShockwave', false);
	AddTimer(4.0, 'EnableRockDrop', false);
}

/** Overriden to implement Multi-Timer functionality */
function TimerFinished(name ID) {
    switch(ID) {
        case 'FindPostalDude':
            FindPostalDude();
            break;

        case 'EnableDash':
            bCanUseDash = true;
            break;

        case 'EnableShockwave':
            bCanUseShockwave = true;
            break;

        case 'EnableRockDrop':
            bCanUseRockDrop = true;
            break;
    }
}

/** Overriden to ensure that obese Bitch's movement speed is always reset to normal */
function SpeedInterpolationFinished() {
    if (IsPostalDudeValid()) {
        Pawn.AirSpeed = Pawn.default.AirSpeed;
        ObeseBitch.GroundSpeed = ObeseBitch.RunSpeed;
    }
    else {
        Pawn.AirSpeed = Pawn.default.AirSpeed;
        ObeseBitch.GroundSpeed = ObeseBitch.WalkSpeed;
    }
}

/** Take a look at our current situation and decide what to do next */
function DecideNextMove() {

    // If the Dude is alive, continue our attack spree
    if (IsPostalDudeValid()) {

        // We should always prioritize canceling out Catnip as soon as possible
        if (ShouldUseBansheeScream())
            GotoState('BansheeScream');

        // Next, we prioritize our more "ranged" attacks first
        else if (ShouldUseShockwaveAttack())
            GotoState('Shockwave');

        // If we can't use the shockwave, use our rock drop attack
        else if (ShouldUseRockDropAttack())
            GotoState('RockDrop');

        // Next if we can just attack the Dude since he's so close, do a butt stomp
        else if (IsCloseEnoughForStomp())
            GotoState('ButtStomp');

        // If he got sent flying away, use a dash attack to close the distance
        else if (ShouldUseDashAttack())
		    GotoState('DashAttackPrep');

        // If all else fails, simply run toward the Dude
	    else
            GotoState('MoveToDude');
    }

    // If he's dead, just stand there idly, we may include dance animations later
    else
        GotoState('Idle');
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
        DecideNextMove();
    }
}

/** Called whenever we cannot find a path to the Postal Dude */
function CantFindPathToDude() {
    GotoState('RockDrop');
}

/** Notification from our Pawn that Obese Bitch made a footstep */
function NotifyWalkingFootstep() {
    ShakeCameraDistanceBased(WalkShakeMag);
}

/** Notification from our Pawn that Obese Bitch made a footstep */
function NotifyRunningFootstep() {
    ShakeCameraDistanceBased(RunShakeMag);
}

/** Notification from our Pawn to perform our banshee scream */
function NotifyBansheeScream() {
    Pawn.PlaySound(BansheeScreamSounds[Rand(BansheeScreamSounds.length)],,Pawn.TransientSoundVolume,,Pawn.TransientSoundRadius);
}

/** Notification from our Pawn that Obese Bitch just performed a butt stomp */
function NotifyStomp() {
    local Pawn Victim;

    StompHurtRadius(StompDamage, StompRadius * GetAttackScale(), StompDamageType, 0, Pawn.Location);
	Pawn.PlaySound(StompSound,,Pawn.TransientSoundVolume,,Pawn.TransientSoundRadius);

    foreach Pawn.VisibleCollidingActors(class'Pawn', Victim, StompRadius * GetAttackScale(), Pawn.Location)
        if (Victim != Pawn) SendPawnFlying(Victim, StompFlyVel, StompRadius * GetAttackScale());

    if (ImpactEmitterClass != none)
        Spawn(ImpactEmitterClass,,, Pawn.Location);

    ShakeCameraDistanceBased(StompShakeMag);
}

function NotifyDashHit()
{
    if (IsCloseEnoughToHit() && IsInFacingAngle(PostalDude, DashHitAngle))
	{
        PostalDude.TakeDamage(DashDamage, Pawn, PostalDude.Location,
        Normal(PostalDude.Location - Pawn.Location) * DashMomentum,
        DashDamageType);
		// Add some knockback
		SendPawnFlying(PostalDude, DashHitFlyVel, DashHitRadius * GetAttackScale());
		Pawn.PlaySound(DashHitSound,,Pawn.TransientSoundVolume,,Pawn.TransientSoundRadius);
	}
}

/** Notification from our Pawn that Obese Bitch performed a belly flop */
function NotifyBellyFlop() {
    local Pawn Victim;

    StompHurtRadius(BellyFlopDamage, BellyFlopRadius * GetAttackScale(), BellyFlopDamageType, 0, Pawn.Location);
	Pawn.PlaySound(FlopSound,,Pawn.TransientSoundVolume,,Pawn.TransientSoundRadius);

    foreach Pawn.VisibleCollidingActors(class'Pawn', Victim, BellyFlopRadius * GetAttackScale(), Pawn.Location)
        if (Victim != Pawn) SendPawnFlying(Victim, BellyFlopFlyVel, BellyFlopRadius * GetAttackScale());

    if (ImpactEmitterClass != none)
        Spawn(ImpactEmitterClass,,, Pawn.Location);

    ShakeCameraDistanceBased(BellyFlopShakeMag);
}

/** Notification from our Pawn to send the shockwave out */
function NotifyShockwave() {
    local Pawn Victim;
    local ObeseBitchShockwave Shockwave;

    StompHurtRadius(ShockwaveDamage, ShockwaveRadius * GetAttackScale(), ShockwaveDamageType, 0, Pawn.Location);
	Pawn.PlaySound(StompSound,,Pawn.TransientSoundVolume,,Pawn.TransientSoundRadius);

    foreach Pawn.VisibleCollidingActors(class'Pawn', Victim, ShockwaveRadius * GetAttackScale(), Pawn.Location)
        if (Victim != Pawn) SendPawnFlying(Victim, ShockwaveFlyVel, ShockwaveRadius * GetAttackScale());

    if (ImpactEmitterClass != none)
        Spawn(ImpactEmitterClass,,, Pawn.Location);

    ShakeCameraDistanceBased(ShockwaveShakeMag);

    if (ShockwaveClass != none) {
        Shockwave = Spawn(ShockwaveClass,,, Pawn.Location);

        if (Shockwave != none)
            Shockwave.InitializeShockwave(vector(Pawn.Rotation));
    }
}

/** Notification from our Pawn to shake the ground and knock a stalactite loose */
function NotifyRockDrop() {
    local Pawn Victim;

    local vector HitLocation, HitNormal, EndTrace, StartTrace;
    local Actor Other;

    local ObeseBitchStalactiteProjectile Stalactite;
    local vector StalactiteLocation;

    if (!IsPostalDudeValid()) return;

    StartTrace = PostalDude.Location + PostalDude.Velocity;
    StartTrace.Z = PostalDude.Location.Z;

    EndTrace = StartTrace + vect(0,0,10000);
    Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);

    if (Other != none && RockDropProjectileClass != none) {
        StalactiteLocation = HitLocation;

        StalactiteLocation.X = StalactiteLocation.X + FRand() * RockDropSpread - FRand() * RockDropSpread;
        StalactiteLocation.Y = StalactiteLocation.Y + FRand() * RockDropSpread - FRand() * RockDropSpread;
        StalactiteLocation.Z += RockDropZOffset;

        Stalactite = ObeseBitchStalactiteProjectile(Spawn(RockDropProjectileClass,,, StalactiteLocation));

        if (Stalactite != none)
            Stalactite.InitializeFallVelocity();
    }

    StompHurtRadius(RockDropDamage, RockDropRadius * GetAttackScale(), RockDropDamageType, 0, Pawn.Location);
	Pawn.PlaySound(StompSound,,Pawn.TransientSoundVolume,,Pawn.TransientSoundRadius);

    foreach Pawn.VisibleCollidingActors(class'Pawn', Victim, RockDropRadius * GetAttackScale(), Pawn.Location)
        if (Victim != Pawn) SendPawnFlying(Victim, RockDropFlyVel, RockDropRadius * GetAttackScale());

    if (ImpactEmitterClass != none)
        Spawn(ImpactEmitterClass,,, Pawn.Location);

    ShakeCameraDistanceBased(RockDropShakeMag);
}

/** Notification from our Pawn that she just landed from a leap */
function NotifyLeapLand() {
    ShakeCameraDistanceBased(LeapLandShakeMag);
}

/** Overriden so we can do stuff based on stuff we bumped into */
event Bump(Actor Other) {
	local Emitter Effect;
	local Vector HitLocation, HitNormal, TraceEnd;
	// Do something special if we bump into something we can break
	if (PropBreakable(Other) != None && Other.Tag == BreakablePropTag)
	{
		// at stage 3, we break these merely by touching them
		if (CurrentStage >= 2)
		{
			Other.Trigger(Pawn, Pawn);
			Effect = spawn(BreakPropEffect,self,,Other.Location);
			TraceEnd = Other.Location;
			TraceEnd.Z -= 9001;
			// Fit effect to ground
			Trace(HitLocation, HitNormal, TraceEnd, Other.Location, false);
			Effect.SetLocation(HitLocation);
			Effect.PlaySound(BreakPropSound,,Pawn.TransientSoundVolume,,Pawn.TransientSoundRadius);
		}
		// at stage 2, we dash into these to break them. We still fall down though
		else if (CurrentStage >= 1 && IsPerformingDash())
		{
			Other.Trigger(Pawn, Pawn);
			GotoState('DashWallHit');
		}
		else if (IsPerformingDash())
			GotoState('DashWallHit');
	}
    else if (IsPerformingDash() && !FastTrace(PostalDude.Location, Pawn.Location)) {
		if (StaticMeshActor(Other) != none || Prop(Other) != None)
            GotoState('DashWallHit');
    }
}

/** Idle state */
state Idle
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        LoopAnimInfo(IdleAnim, AnimBlendTime);

        if (IsPostalDudeValid())
            SetTimer(ThinkInterval, true);
        else
            SetTimer(0, false);
    }

    function Timer() {
        DecideNextMove();
    }

Begin:
    StopMoving();
}

/** Move to a good leaping location so we can leap onto the ledges */
state MoveToLeapNode
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = none;

        LoopAnimInfo(RunAnim, AnimBlendTime);

        SetTimer(ThinkInterval, true);
    }

    function Timer() {
        local vector LeapDir;
        local PathNode RaisedPathNode;

        ObeseBitch.AirSpeed = ObeseBitch.default.AirSpeed;
        ObeseBitch.GroundSpeed = ObeseBitch.RunSpeed;

        LeapToNode = GetLeapToPathNode();
        LeapFromNode = GetLeapFromPathNode(LeapToNode.Location);
        LeapDestination = LeapToNode.Location;

        bLeapToDude = false;
        bLeapToLedge = true;

        if (ShouldUseBansheeScream())
            GotoState('BansheeScream');
        else if (!IsInArenaVolume(PostalDude))
            GotoState('MoveToDude');
        else if (HasReachedLeapFromNode() && CanLeapToPoint(LeapToNode.Location, LeapToLedgeSpeed))
            GotoState('LeapPrep');
    }

Begin:
    ObeseBitch.GroundSpeed = ObeseBitch.RunSpeed;

    while (!HasReachedLeapFromNode()) {
        if (ActorReachable(LeapFromNode))
            MoveToward(LeapFromNode);
		else {
			MoveTarget = FindPathToward(LeapFromNode);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
            else
                CantFindPathToDude();
		}
    }
}

/** Move toward the Postal Dude */
state MoveToDude
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = none;
		PathNotFoundCnt = 0;

        Pawn.AmbientSound = RunSound;
        Pawn.SoundVolume = RunSoundVolume;
	    Pawn.SoundRadius = RunSoundRadius;

        if (IsPostalDudeValid()) {
            Pawn.AirSpeed = Pawn.default.AirSpeed;
            Pawn.GroundSpeed = ObeseBitch.RunSpeed;

            LoopAnimInfo(RunAnim, AnimBlendTime);
        }
        else {
            Pawn.AirSpeed = Pawn.default.AirSpeed;
            Pawn.GroundSpeed = ObeseBitch.WalkSpeed;

            LoopAnimInfo(WalkAnim, AnimBlendTime);
        }

        SetTimer(ThinkInterval, true);
    }

    function EndState() {
        Pawn.AmbientSound = none;
        Pawn.SoundVolume = default.SoundVolume;
	    Pawn.SoundRadius = default.SoundRadius;
    }

    function Timer() {
        if (IsCloseEnoughForStomp())
            GotoState('ButtStomp');
        else if (ShouldLeapOntoLedge())
            SetupLeapToLedge();
        else if (ShouldLeapTowardsDude())
            SetupLeapToDude();
    }

Begin:
    while (!IsCloseEnoughForStomp()) {
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

                if (PathNotFoundCnt >= PathNotFoundThreshold)
                    CantFindPathToDude();
            }
		}
    }

    GotoState('ButtStomp');
}

/** Dude is cheating by slowing down time, let's snap him out of it! */
state BansheeScream
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = PostalDude;

        if (Level.TimeDilation < 1 && P2Player(PostalDude.Controller) != none)
            P2Player(PostalDude.Controller).CatnipUseTime = 0.1;

        PlayAnimByDuration(BansheeScreamAnim, BansheeScreamTime, AnimBlendTime);
        SetTimer(BansheeScreamTime, false);
    }

    function Timer() {
        DecideNextMove();
    }

Begin:
    StopMoving();
}

/** Hurt the Postal Dude using a shockwave via our gigantic ass */
state ButtStomp
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Pawn.AirSpeed = StompMovementSpeed;
        Pawn.GroundSpeed = StompMovementSpeed;

        Pawn.SetRotation(rotator(PostalDude.Location - Pawn.Location));
        FaceForward();

        PerformAttack();
    }

    function PerformAttack() {
		ObeseBitch.PlayDialogButtStomp();
        InterpolateSpeed(StompTime, 0, INTERP_SineEaseIn);
        PlayAnimByDuration(StompAnim, StompTime, AnimBlendTime);
        SetTimer(StompTime, false);
    }

    function Timer() {
        if (IsPostalDudeValid() && IsCloseEnoughForStomp())
            PerformAttack();
        else
            DecideNextMove();
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        Pawn.Velocity = vector(Pawn.Rotation) * Pawn.GroundSpeed;
    }

Begin:
    StopMoving();
}

/** Crouch down in preparation for a massive leap! */
state LeapPrep
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = none;
        FocalPoint = Pawn.Location + Normal(LeapDestination - Pawn.Location) * 32768;

        if (bLeapToDude) {
			ObeseBitch.PlayDialogBellyFlop();
            PlayAnimByDuration(BellyFlopStartAnim, BellyFlopStartTime, AnimBlendTime);
            SetTimer(BellyFlopStartTime, false);
        }
        else {
			ObeseBitch.PlayDialogLeap();
            PlayAnimByDuration(LeapPrepAnim, LeapPrepTime, AnimBlendTime);
            SetTimer(LeapPrepTime, false);
        }
    }

    function Timer() {
        GotoState('Leaping');
    }

Begin:
    StopMoving();
}

/** Soaring through the sky so fancy-free! */
state Leaping
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

		LeapStartTime = Level.TimeSeconds;
        bOldFalling = false;
        bNewFalling = false;

        if (bLeapToDude)
            LoopAnimInfo(BellyFlopAnim, AnimBlendTime);
        else
            LoopAnimInfo(LeapAnim, AnimBlendTime);

        if (bLeapToLedge)
            LeapToDestination(LeapToLedgeSpeed, bUseHigherLeapArcToLedge);
        else if (bLeapToDude)
            LeapToDestination(LeapToDudeSpeed, bUseHigherLeapArcToDude);
        else
            LeapToDestination(LeapBackFromDudeSpeed, bUseHigherLeapArcFromDude);

        if (bLeapToLedge)
            SetTimer(LeapAnimUpdateInterval, true);
    }

    function Timer() {
        bOldFalling = bNewFalling;
        bNewFalling = (Pawn.Velocity.Z < 0);

        if (bOldFalling != bNewFalling)
            LoopAnimInfo(BellyFlopAnim, AnimBlendTime);
    }
Begin:
	Sleep(LeapTimeMax);
	// Force out of the leap if she gets stuck. UGLY HACK
	Pawn.SetPhysics(PHYS_Walking);
	GotoState('LeapLand');
}

/** Play a cool three point stance and proceed to kill the crap out of the Dude */
state LeapLand
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        if (bLeapToDude || bLeapToLedge)
            PlayAnimByDuration(BellyFlopEndAnim, BellyFlopEndTime);
        else
            PlayAnimByDuration(LeapLandAnim, LeapLandTime);

        SetTimer(LeapLandTime, false);
    }

    function Timer() {
        DecideNextMove();
    }

Begin:
    StopMoving();
}

/** Strike a deadly pose before we dash toward the Dude for a slash */
state DashAttackPrep
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = PostalDude;

        PlayAnimByDuration(DashPrepAnim, DashPrepTime, AnimBlendTime);
        SetTimer(DashPrepTime, false);
		ObeseBitch.PlayDialogDash();
    }

    function Timer() {
		GotoState('DashAttack');
    }

Begin:
    StopMoving();
}

/** Here we go from our dash to our slash */
state DashAttack
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        bCanUseDash = false;
        AddTimer(DashCooldown, 'EnableDash', false);

        FaceForward();
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        if (!IsPostalDudeValid())
            GotoState('DashAttackEnd');

        Pawn.LoopAnim(DashRunAnim.Anim,, AnimBlendTime);
        Pawn.SetRotation(rotator(PostalDude.Location - Pawn.Location));

        ObeseBitch.AirSpeed = DashSpeed;
        ObeseBitch.GroundSpeed = DashSpeed;

        Pawn.Velocity = vector(Pawn.Rotation) * DashSpeed;
        Pawn.Velocity.Z = -1000;

        // If the Dude has side stepped or if he's in range
        if (!IsInFacingAngle(PostalDude, 180) || IsCloseEnoughToHit()) {
			bEndDashWithSmash = IsInFacingAngle(PostalDude, DashHitAngle);
			GotoState('DashAttackEnd');
        }
    }

Begin:
    StopMoving();
}

/** End our dash either with slashing the Dude or come to a skidding stop */
state DashAttackEnd
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        if (bEndDashWithSmash) {
            Pawn.GroundSpeed *= DashHitVelPct;
            InterpolateSpeed(DashHitTime, 0, INTERP_SineEaseIn);
            PlayAnimByDuration(DashHitAnim, DashHitTime, AnimBlendTime);
            SetTimer(DashHitTime, false);
        }
        else {
            Pawn.GroundSpeed *= DashMissVelPct;
            InterpolateSpeed(DashMissTime, 0, INTERP_SineEaseIn);
            PlayAnimByDuration(DashMissAnim, DashMissTime, AnimBlendTime);
            SetTimer(DashMissTime, false);
        }
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        Pawn.Velocity = vector(Pawn.Rotation) * Pawn.GroundSpeed;
        Pawn.Velocity.Z = -1000;
    }

    function Timer() {
        DecideNextMove();
    }
}

/** We've instead managed to hit a wall, so recoil a bit from the hit */
state DashWallHit
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        Pawn.GroundSpeed *= DashWallHitVelPct;
		Pawn.TakeDamage(int(ObeseBitch.HealthMax * DashWallHitSelfDamagePct), Pawn, Location, vect(0,0,0), class'P2Damage');
		Pawn.PlaySound(DashHitWallSound,,Pawn.TransientSoundVolume,,Pawn.TransientSoundRadius);

        InterpolateSpeed(DashWallHitTime, 0, INTERP_SineEaseIn);
        PlayAnimByDuration(DashWallHitAnim, DashWallHitTime, AnimBlendTime);
        SetTimer(DashWallHitTime, false);

        //SetTimerPauseByID('PlayCombatTauntSound', true);
    }

    function EndState() {
        //SetTimerPauseByID('PlayCombatTauntSound', false);
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        Pawn.Velocity = vector(Pawn.Rotation) * -Pawn.GroundSpeed;
        Pawn.Velocity.Z = -1000;
    }

    function Timer() {
        GotoState('DashWallHitRecover');
    }
}

/** Get back up after falling down on our gigantic ass */
state DashWallHitRecover
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        PlayAnimByDuration(DashRecoverAnim, DashRecoverTime, AnimBlendTime);
        SetTimer(DashRecoverTime, false);
    }

    function Timer() {
        DecideNextMove();
    }

Begin:
    StopMoving();
}

/** Smash the ground with both our fists creating a shockwave that travels along the ground */
state Shockwave
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        bCanUseShockwave = false;
        AddTimer(ShockwaveCooldown, 'EnableShockwave', false);

        Focus = PostalDude;

        PlayAnimByDuration(ShockwaveAnim, ShockwaveTime, AnimBlendTime);
        SetTimer(ShockwaveTime, false);
    }

    function Timer() {
        DecideNextMove();
    }

Begin:
    StopMoving();
}

/** Punches the ground to loosen some stalactites from the ceiling */
state RockDrop
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        bCanUseRockDrop = false;
        AddTimer(RockDropCooldown, 'EnableRockDrop', false);

        FaceForward();

        PlayAnimByDuration(RockDropAnim, RockDropTime, AnimBlendTime);
        SetTimer(RockDropTime, false);
    }

    function Timer() {
        DecideNextMove();
    }

Begin:
    StopMoving();
}

defaultproperties
{
    bLogDebug=false

    bControlAnimations=true

    PathNotFoundThreshold=10

    ThinkInterval=0.1
    MoveReachedRadius=128
    AnimBlendTime=0.1
    LedgeNodeTag="LedgeNode"

    IdleAnim=(Anim="fatbitch_idle",Rate=1,AnimTime=2.1)
    WalkAnim=(Anim="fatbitch_walk",Rate=1,AnimTime=1.26)
    RunAnim=(Anim="fatbitch_run",Rate=1,AnimTime=0.56)

    //--------------------------------------------------------------------------
    // Movement

    MinMagForShake=20
    MaxShakeDist=2000

    WalkShakeMag=50
    RunShakeMag=75

    RunSound=sound'AWSoundFX.Elephant.elephant_charging'
    RunSoundVolume=255
    RunSoundRadius=200

    //--------------------------------------------------------------------------
    // General effects

    ImpactEmitterClass=class'EasterBunnyGroundImpact'

    //--------------------------------------------------------------------------
    // Banshee Scream

    BansheeScreamTime=2.03

    BansheeScreamSounds(0)=sound'PLAnimalSounds.dogg.mutdog_roar'

    BansheeScreamAnim=(Anim="fatbitch_shriek",AnimTime=2.03)

    //--------------------------------------------------------------------------
    // Butt Stomp

    StompTime=1.3
    StompAttackRadius=300

    StompRadius=500
    StompDamage=100
    StompFlyVel=750
    StompMovementSpeed=750
    StompMomentum=60000

    StompShakeMag=100

    StompAnim=(Anim="fatbitch_stomp",AnimTime=1.3)
    StompDamageType=class'ObeseBitchMeleeDamage'

    //--------------------------------------------------------------------------
    // Leap

    bUseHigherLeapArcToDude=false
    bUseHigherLeapArcFromDude=true
    bUseHigherLeapArcToLedge=true

    LeapToDudeSpeed=1500
    LeapBackFromDudeSpeed=1500
    LeapToLedgeSpeed=1800

    LeapTowardMinDistance=750
    LeapBackDistance=1000
    LeapToDudeOffset=0

    LeapPrepTime=0.53
    LeapLandTime=0.7
    LeapTimeMax=3.0

    LeapLandShakeMag=200

    LeapAnimUpdateInterval=0.2

    LeapPrepAnim=(Anim="LeapStart",AnimTime=0.53)
    LeapAnim=(Anim="LeapLoop",Rate=1,AnimTime=0.36)
    LeapLandAnim=(Anim="LeapLand",AnimTime=0.7)

    //--------------------------------------------------------------------------
    // Belly Flop

    BellyFlopStartTime=0.53
    BellyFlopEndTime=1.03

    BellyFlopRadius=500
    BellyFlopDamage=100
    BellyFlopFlyVel=750
    BellyFlopMomentum=60000
    BellyFlopShakeMag=200

    BellyFlopStartAnim=(Anim="bellyflop_in",AnimTime=0.53)
    BellyFlopAnim=(Anim="bellyflop_loop",Rate=1,AnimTime=0.9)
    BellyFlopEndAnim=(Anim="bellyflop_out",AnimTime=1.03)
    BellyFlopDamageType=class'ObeseBitchMeleeDamage'

    //--------------------------------------------------------------------------
    // Dash

    DashCooldown=10

    DashMinDistance=500
    DashSpeed=1000

    DashDamage=100
    DashHitAngle=45
    DashMomentum=60000
    DashHitRadius=150
    DashHitFlyVel=300
    DashWallHitSelfDamagePct=0.2

    DashHitVelPct=0.5
    DashMissVelPct=0.75
    DashWallHitVelPct=0.3

    DashPrepTime=1.2
    DashHitTime=1.16
    DashWallHitTime=1.73
    DashRecoverTime=1.73
    DashMissTime=1.83

    DashPrepAnim=(Anim="DashPrep",AnimTime=1.2)
    DashRunAnim=(Anim="DashLoop",Rate=1,AnimTime=0.56)
    DashHitAnim=(Anim="DashHit",AnimTime=1.16)
    DashWallHitAnim=(Anim="FallDown",AnimTime=1.73)
    DashRecoverAnim=(Anim="GetUp",AnimTime=1.73)
    DashMissAnim=(Anim="DashMiss",AnimTime=1.83)
    DashDamageType=class'ObeseBitchMeleeDamage'

    //--------------------------------------------------------------------------
    // Shockwave

    ShockwaveCooldown=15
    ShockwaveTime=2.7

    ShockwaveDamage=45
    ShockwaveRadius=500
    ShockwaveMomentum=60000
    ShockwaveFlyVel=750
    ShockwaveDamageType=class'ObeseBitchMeleeDamage'

    ShockwaveShakeMag=150

    ShockwaveClass=class'ObeseBitchShockwave'

    ShockwaveAnim=(Anim="Shockwave",AnimTime=2.7)

    //--------------------------------------------------------------------------
    // Rock Drop

    RockDropCooldown=20
    RockDropTime=4.6

    RockDropDamage=9
    RockDropRadius=500
    RockDropMomentum=60000
    RockDropFlyVel=100
    RockDropDamageType=class'ObeseBitchMeleeDamage'

    RockDropSpread=500
    RockDropZOffset=-100
    RockDropProjectileClass=class'ObeseBitchStalactiteProjectile'

    RockDropShakeMag=250

    RockDropAnim=(Anim="Rock_Drop",AnimTime=4.6)

    //--------------------------------------------------------------------------
    // Grow Stage Draw Scales

    CurrentStage=0
    GrowStageScales(0)=1
    GrowStageScales(1)=1.5
    GrowStageScales(2)=2

    //--------------------------------------------------------------------------
    // Prop Break

    BreakablePropTag=ObeseBitchBreakable
    BreakPropSound=Sound'LevelSoundsToo.library.woodCrash01'
	BreakPropEffect=class'PLFX.RockExplosion'

    //--------------------------------------------------------------------------
    // Sounds

	StompSound=Sound'WeaponSounds.foot_kickwall'
	FlopSound=Sound'WeaponSounds.foot_kickhead'
	DashHitSound=Sound'WeaponSounds.foot_kickhead'
	DashHitWallSound=Sound'LevelSoundsToo.Brewery.woodCrash03'
}
