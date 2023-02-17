/**
 * MountedWeaponPawnController
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * A special AI Controller that knows how to make use of mounted weapons
 *
 * @author Gordon Cheng
 */
class MountedWeaponPawnController extends P2EAIController;

/** Basic attack and movement variables */
var float ThinkInterval;
var float MoveReachedRadius;
var float AnimBlendTime;

/** Firing parameters */
var bool bTargetPlayerImmediately;
var float EnemyAbandonRadius;
var float NormalFireInterval;
var range FireDuration, TrackingDuration;

var vector MountedWeaponAttachOffset;

/** Misc objects and values */
var int PathNotFoundCnt, PathNotFoundThreshold;

var bool bOldStrafing, bNewStrafing;
var float StrafeDelta, StrafeDeltaSinceStart;
var vector OldStrafeLoc, NewStrafeLoc;

var PLMountedWeaponPawn MountedWeaponPawn;
var MountedWeapon MountedWeapon;
var PathNode FiringPathNode;
var PathNode MountedWeaponPathNode;

var array<PathNode> FiringPathNodes;

/** Function prototypes */
function DecideNextMove();

/** Returns whether or not we're currently using a mounted weapon
 * @return TRUE if we're currently using a mounted weapon; FALSE otherwise
 */
function bool IsUsingMountedWeapon() {
    return IsInState('IdleMounted') || IsInState('TrackEnemyMounted') || IsInState('FireAtEnemyMounted');
}

/** Returns whether or not a given Pawn is a valid target
 * @param Other - FPSPawn to check whether or not it qualifies as a target
 * @return TRUE if the target should be shot; FALSE otherwise
 */
function bool IsValidTarget(FPSPawn Other) {
    if (MountedWeaponPawn == none)
        return false;

    return (Other.Controller != none && Other.Gang != MountedWeaponPawn.Gang && Other.Health > 0);
}

/** Returns whether or not the given Pawn is closer than our current Enemy
 * @param Other - Pawn to check whether or not is closer than our Enemy
 * @return TRUE if the Pawn is currently closer than our current enemy; FALSE otherwise
 */
function bool IsCloserThanEnemy(Pawn Other) {
    if (Enemy == none)
        return false;

    return VSize(Other.Location - Pawn.Location) < VSize(Enemy.Location - Pawn.Location);
}

/** Returns whether or not a given Pawn is in the mounted weapon's turning angle
 * @return TRUE if our Enemy is still in our firing angle; FALSE otherwise
 */
function bool IsEnemyInSwivelAngle() {
    if (Enemy == none)
        return false;

    // Temporary solution
    return true;
}

/** Returns whether or not we've reached our firing location
 * @return TRUE if we've reached a PathNode we can fire from; FALSE otherwise
 */
function bool HasReachedFiringPoint() {
    if (FiringPathNode == none)
        return false;

    return VSize(FiringPathNode.Location - Pawn.Location) <= MoveReachedRadius;
}

/** Returns whether or not we've reached our mounted weapon and can mount it
 * @return TRUE if we've reached our mounted weapon PathNode; FALSE otherwise
 */
function bool HasReachedMountedWeapon() {
    if (MountedWeaponPathNode == none)
        return false;

    return VSize(MountedWeaponPathNode.Location - Pawn.Location) <= MoveReachedRadius;
}

/** Returns whether or not we should abandon our enemy has he is too far
 * @return TRUE if our enemy is too far and just abandon; FALSE otherwise
 */
function bool ShouldAbandonEnemy() {
    if (bTargetPlayerImmediately)
        return false;

    if (Enemy == none)
        return true;

    return VSize(Enemy.Location - Pawn.Location) > EnemyAbandonRadius;
}

/** Returns a random value between the specified range
 * @param r - A minimum and maximum value range
 * @return A random float value between the specified range
 */
function float GetRangeValue(range r) {
    return r.Min + FRand() * (r.Max - r.Min);
}

/** Iterates through the dynamic Actors in the world to find our mounted weapon
 * @return MountedWeapon object whose tag matches our Pawn
 */
function MountedWeapon GetMountedWeapon() {
    local MountedWeapon MountedWeap;

    if (MountedWeaponPawn == none)
        return none;

    foreach DynamicActors(class'MountedWeapon', MountedWeap, MountedWeaponPawn.MountedWeaponTag)
        if (MountedWeap != none)
            return MountedWeap;

    return none;
}

/** Returns the Pawn object in the world controlled by the Player
 * @return Pawn object currently controlled by the Player
 */
function Pawn GetPlayer() {
    local Pawn PlayerPawn;

    foreach DynamicActors(class'Pawn', PlayerPawn)
        if (PlayerPawn.Controller != none && PlayerPawn.Controller.bIsPlayer)
            return PlayerPawn;

    return none;
}

/** Returns the PathNode that the AI should run to to mount the weapon
 * @return PathNode where the AI should be allowed to mounted the weapon
 */
function PathNode GetMountedWeaponPathNode() {
    local PathNode MountedWeaponNode;

    foreach AllActors(class'PathNode', MountedWeaponNode, MountedWeaponPawn.MountedWeaponPathNodeTag)
        if (MountedWeaponNode != none)
            return MountedWeaponNode;

    return none;
}

/** Returns the PathNode closest to the player for firing our normal weapon
 * @return PathNode closest to the player from the FiringPathNodes list
 */
function PathNode GetFiringPathNode() {
    local int i;
    local float Distance, ClosestDistance;
    local PathNode ClosestFiringNode;

    if (Enemy == none)
        return none;

    ClosestDistance = 3.4028e38;

    for (i=0;i<FiringPathNodes.length;i++) {
        Distance = VSize(Enemy.Location - FiringPathNodes[i].Location);

        if (Distance < ClosestDistance) {
            ClosestFiringNode = FiringPathNodes[i];
            ClosestDistance = Distance;
        }
    }
}

/** Returns the location in the world where the mounted weapon user should be
 * bound so he can hold onto the mounted weapon's handle and strafe properly
 * @return Location in the world that's relative to the weapon's location and rotation
 */
function vector GetMountedWeaponOffset() {
    local rotator BaseWeaponRotation;

    if (MountedWeapon == none || MountedWeaponPawn == none)
        return vect(0,0,0);

    BaseWeaponRotation = MountedWeapon.Rotation;
    BaseWeaponRotation.Pitch = 0;

    return MountedWeapon.Location + class'P2EMath'.static.GetOffset(
        BaseWeaponRotation, MountedWeaponAttachOffset);
}

/** Populates the firing path node list iterating through later */
function PopulateNormalFiringNodes() {
    local PathNode FiringNode;

    foreach AllActors(class'PathNode', FiringNode, MountedWeaponPawn.NormalFiringPathNodeTag) {
        if (FiringNode != none) {
            FiringPathNodes.Insert(FiringPathNodes.length, 1);
            FiringPathNodes[FiringPathNodes.length-1] = FiringNode;
        }
    }
}

/** Causes the Pawn to get onto the mounted weapon */
function MountMountedWeapon() {
    Pawn.bCollideWorld = false;

    if (MountedWeapon != none)
        MountedWeapon.MountedWeaponTrigger.UsedBy(Pawn);

    if (MountedWeaponPawn != none)
        MountedWeaponPawn.bUsingMountedWeapon = true;
}

/** Causes the Pawn to get off from the mounted weapon */
function DismountFromMountedWeapon() {
    Pawn.bCollideWorld = true;

    if (MountedWeapon != none)
        MountedWeapon.MountedWeaponTrigger.UsedBy(Pawn);

    if (MountedWeaponPawn != none)
        MountedWeaponPawn.bUsingMountedWeapon = false;
}

/** Overriden to initialize some stuff */
function Possess(Pawn aPawn) {
    super.Possess(aPawn);

    aPawn.SetPhysics(PHYS_Walking);

    MountedWeaponPawn = PLMountedWeaponPawn(aPawn);
	MountedWeaponPawn.AddDefaultInventory();	// Call this here and now so we can be replaced properly in liebermode
    MountedWeapon = GetMountedWeapon();
    MountedWeaponPathNode = GetMountedWeaponPathNode();

    PopulateNormalFiringNodes();

    if (bTargetPlayerImmediately)
        AddTimer(0.1, 'GetPlayerPawn', false);

    if (MountedWeaponPawn != none && MountedWeaponPawn.PawnInitialState == EP_Turret)
        GotoState('MoveToMountedWeapon');
    else
        GotoState('IdleNormal');
}

/** Overriden so we can implement seeing and deciding what to do with Pawns */
function PawnSeen(Pawn Other) {
    if (bTargetPlayerImmediately || Enemy != none || FPSPawn(Other) == none)
        return;

    if (IsValidTarget(FPSPawn(Other)) && (Enemy == none || (Enemy != none && IsCloserThanEnemy(Other))))
        Enemy = Other;
}

/** Overriden to implement Multi-Timer functionality */
function TimerFinished(name ID) {
    switch(ID) {
        case 'GetPlayerPawn':
            Enemy = GetPlayer();
            break;

        case 'DecideNextMove':
            DecideNextMove();
            break;
    }
}

/** Called whenever we can't find a path to our mounted weapon */
function CantFindPathToMountedWeapon() {
    GotoState('IdleNormal');
}

/** Called whenever we can't find a path to our firing point */
function CantFindPathToFiringPoint() {
    GotoState('IdleMounted');
}

/** Updates and returns the distance since the last game tick the mounted
 * weapon user has moved strafe wise. Used for animating the strafing
 */
function UpdateStrafeDelta() {
    OldStrafeLoc = NewStrafeLoc;
    NewStrafeLoc = Pawn.Location;

    StrafeDelta = VSize(NewStrafeLoc - OldStrafeLoc);

    bOldStrafing = bNewStrafing;
    bNewStrafing = (StrafeDelta > 0);

    if (bOldStrafing != bNewStrafing) {
        if (bNewStrafing)
            MountedWeaponPawn.LoopIfNeeded('Minigun_Idle', 1.0);
        else
            MountedWeaponPawn.LoopIfNeeded('Minigun_Idle', 1.0);
    }
}

/** We're on our mounted weapon panning back and forth for targets */
state IdleMounted
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        SetTimer(ThinkInterval, true);
    }

    function Timer() {
        if (!bTargetPlayerImmediately)
            CheckSurroundingPawns();

        if (Enemy != none)
            GotoState('TrackEnemyMounted');
    }

    event Tick(float DeltaTime) {
        super.Tick(DeltaTime);

        Pawn.SetLocation(GetMountedWeaponOffset());
        Pawn.Velocity = vect(0,0,0);
    }

Begin:
    StopMoving();
}

/** We're idle and we have our normal weapon out */
state IdleNormal
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        SetTimer(ThinkInterval, true);
    }

    function Timer() {
        if (!bTargetPlayerImmediately)
            CheckSurroundingPawns();

        if (Enemy != none)
            GotoState('TrackEnemyNormal');
    }

Begin:
    StopMoving();
}

/** We've spotted an enemy, quickly, run back to our mounted weapon */
state MoveToMountedWeapon
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = none;

        SetTimer(ThinkInterval, true);
    }

    function Timer() {
        if (HasReachedMountedWeapon()) {
            MountMountedWeapon();
            GotoState('IdleMounted');
        }
    }

Begin:
    while (!HasReachedMountedWeapon()) {
        if (ActorReachable(MountedWeaponPathNode)) {
            PathNotFoundCnt = 0;
            MoveToward(MountedWeaponPathNode);
        }
		else {
			MoveTarget = FindPathToward(MountedWeaponPathNode);

            if (MoveTarget != none) {
                PathNotFoundCnt = 0;
				MoveToward(MoveTarget);
            }
            else {
                PathNotFoundCnt++;
                Sleep(0.1);

                if (PathNotFoundCnt == PathNotFoundThreshold)
                    CantFindPathToMountedWeapon();
            }
		}
    }

    MountMountedWeapon();
    GotoState('IdleMounted');
}

/** Enemy is too close, disengage and fire at them with our normal weapon */
state MoveToFiringPoint
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = none;

        DismountFromMountedWeapon();

        SetTimer(ThinkInterval, true);
    }

    function Timer() {
        if (HasReachedFiringPoint())
            GotoState('IdleNormal');
    }

Begin:
    while (!HasReachedFiringPoint()) {
        if (ActorReachable(FiringPathNode)) {
            PathNotFoundCnt = 0;
            MoveToward(FiringPathNode);
        }
		else {
			MoveTarget = FindPathToward(FiringPathNode);

            if (MoveTarget != none) {
                PathNotFoundCnt = 0;
				MoveToward(MoveTarget);
            }
            else {
                PathNotFoundCnt++;
                Sleep(0.1);

                if (PathNotFoundCnt == PathNotFoundThreshold)
                    CantFindPathToFiringPoint();
            }
		}
    }

    GotoState('IdleNormal');
}

/** Track our enemy normally from our fire point */
state TrackEnemyNormal
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = Enemy;

        MountedWeaponPawn.RotationRate = MountedWeaponPawn.default.RotationRate;
        SetTimer(GetRangeValue(TrackingDuration), false);
    }

    function Timer() {
        GotoState('FireAtEnemyNormal');
    }

Begin:
    StopMoving();
}

/** Fire at our enemy normally with small arms */
state FireAtEnemyNormal
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        Focus = Enemy;
        MountedWeaponPawn.RotationRate = MountedWeaponPawn.default.RotationRate;

        SetTimer(NormalFireInterval, true);
        AddTimer(GetRangeValue(FireDuration), 'DecideNextMove', false);
    }

    function DecideNextMove() {
        GotoState('TrackEnemyNormal');
    }

    function Timer() {
        if (Pawn.Weapon != none) {
            Pawn.Weapon.TraceFire(Pawn.Weapon.TraceAccuracy, 0, 0);
            Pawn.Weapon.LocalFire();
        }
    }

Begin:
    StopMoving();
}

/** Pause from firing our mounted weapon to do stuff */
state TrackEnemyMounted
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        OldStrafeLoc = Pawn.Location;
        NewStrafeLoc = Pawn.Location;

        MountedWeaponPawn.LoopIfNeeded('Minigun_Idle', 1.0);

        Focus = Enemy;
        MountedWeaponPawn.RotationRate = MountedWeaponPawn.MountedWeaponRotationRate;

        SetTimer(GetRangeValue(TrackingDuration), false);
    }

    function Timer() {
        GotoState('FireAtEnemyMounted');
    }

    event Tick(float DeltaTime) {
        local float StrafeDelta;

        super.Tick(DeltaTime);

        Pawn.SetLocation(GetMountedWeaponOffset());
        Pawn.Velocity = vect(0,0,0);

        //StrafeDelta = UpdateStrafeDelta();
    }

Begin:
    StopMoving();
}

/** We've found our enemy, so we're gonna fire down on him */
state FireAtEnemyMounted
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        OldStrafeLoc = Pawn.Location;
        NewStrafeLoc = Pawn.Location;

        MountedWeaponPawn.LoopIfNeeded('Minigun_Idle', 1.0);

        Focus = Enemy;
        MountedWeaponPawn.RotationRate = MountedWeaponPawn.MountedWeaponRotationRate;

        MountedWeaponPawn.SetPressingFire(true);

        SetTimer(GetRangeValue(FireDuration), true);
    }

    function EndState() {
        MountedWeaponPawn.SetPressingFire(false);
    }

    function Timer() {
        GotoState('TrackEnemyMounted');
    }

    event Tick(float DeltaTime) {
        local float StrafeDelta;

        super.Tick(DeltaTime);

        Pawn.SetLocation(GetMountedWeaponOffset());
        Pawn.Velocity = vect(0,0,0);

        //StrafeDelta = UpdateStrafeDelta();
    }

Begin:
    StopMoving();
}

defaultproperties
{
    bLogDebug=false

    ThinkInterval=0.1
    MoveReachedRadius=64
    AnimBlendTime=0.1

    PathNotFoundThreshold=10

    EnemyAbandonRadius=3072

    NormalFireInterval=0.2
    FireDuration=(Min=5,Max=6)
    TrackingDuration=(Min=2,Max=3)

    MountedWeaponAttachOffset=(X=-57,Z=-13)

    VisionFOV=90
    VisionRange=1024
}
