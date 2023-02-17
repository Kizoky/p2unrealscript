/**
 * ZackWardController
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * AI Controller for Zack Ward. Since Zack will need to be able to dual wield,
 * quick throw grenades, and take cover, and know when to throw grenades, I'm
 * just gonna write a custom AI Controller.
 *
 * Since he's going to be a boss that's always hostile to the Dude
 *
 * @author Gordon Cheng
 */
class ZackWardController extends P2EAIController;

/** Time in seconds before we think again */
var float MoveThinkInterval, PathWaitTime;
var float AnimBlendTime;

/** Distance away from our move destination */
var float MoveReachedRadius;

/** Amount of health before Zack drops down from his high place */
var bool bJumpDown;
var float JumpDownHealthPct;

/** Firing Variables */
var bool bFireRightWeapon;

var int CurrentBurstCount, MaxBurstCount;

var float FireInterval, FiringRange, FireAccuracy;
var float RunForCoverAmmoPct;

var range BurstCount;

/** Reloading Variables */
var name CoverNodeTag;

var float ReloadTime;
var AnimInfo ReloadAnim;

var int DroppedAmmoCount;
var class<Ammo> DroppedAmmoClass;

/** Flashbang Blinding Variables */
var bool bCanBeBlinded;

var float ReblindDelay;

var float BlindStartTime, BlindTime, BlindEndTime;
var AnimInfo BlindStartAnim, BlindAnim, BlindEndAnim;

/** Grenade Throwing variables */
var bool bCanThrowGrenade;
var bool bPreppingGrenade, bDropGrenade;

var bool bLeadTarget;

var bool bGrenadesUseHigherArcsInLineOfSight;
var bool bMolotovsUseHigherArcsInLineOfSight;

var bool bGrenadesUseHigherArcsForCoverFlush;
var bool bMolotovsUseHigherArcsForCoverFlush;

var int GrenadeThrowSpread;

var float GrenadeThrowSpeed, MolotovThrowSpeed;
var float GrenadeGravity, MolotovGravity;

var float MolotovHealthPct;
var float GrenadeThrowTime;
var float GrenadeThrowCooldownTime;

var int CoverFlushGridXSize, CoverFlushGridYSize;
var float CoverFlushGridSize;

var AnimInfo GrenadeThrowAnim;
var class<GrenadeProjectile> GrenadeClass, MolotovClass;

var array<vector> PillarCheckOffsets;

/** Dialog variables */
var range PainSoundInterval;
var range StationaryTauntInterval;
var range CombatTauntInterval;

var array<sound> GrenadeThrowTaunts;
var array<sound> PainSounds;
var array<sound> StationaryTaunts;
var array<sound> CombatTaunts;
var array<sound> VictoryTaunts;

/** Gloating variables */
var float DanceAnimBlendTime;
var array<AnimInfo> GestureAnims;
var array<AnimInfo> DanceAnims;

/** Misc objects and values */
var bool bPlayPainSound;

var Actor Destination;
var Weapon LeftWeapon;
var Pawn Player;
var ZackWard ZackWard;

/** Returns whether or not we're in firing range of the player
 * @return TRUE if we're in our preferred range firing distance, FALSE otherwise
 */
function bool InFiringRangeOfPlayer() {
    if (Player == none)
        return true;

    return VSize(Player.Location - Pawn.Location) < FiringRange;
}

/** Returns whether or not the Postal Dude is in throwing range of our grenade
 * @return TRUE if we're close enough that we can hit the player with a grenade
 *         FALSE otherwise
 */
function bool InGrenadeThrowRange() {
    if (Player == none)
        return false;

    if (ShouldUseMolotov())
        return class'P2EMath'.static.CanHitTarget(Pawn.Location,
            Player.Location, MolotovThrowSpeed, MolotovGravity);
    else
        return class'P2EMath'.static.CanHitTarget(Pawn.Location,
            Player.Location, GrenadeThrowSpeed, GrenadeGravity);
}

/** Returns whether or not the Postal Dude is dead
 * @return TRUE if the player sucks; FALSE if they're good
 */
function bool IsPlayerDead() {
    if (Player == none)
        return true;

    return (Player.Health <= 0);
}

/** Returns whether or not a pillar is covering up too much of our view
 * @return TRUE if a pillar is directly in front of us and blocking our view;
 *         FALSE if our view is open and clear
 */
function bool IsPillarInWay() {
    local int i;
    local vector EndTrace;

    if (Player == none)
        return true;

    for (i=0;i<PillarCheckOffsets.length;i++) {
        EndTrace = Pawn.Location + class'P2EMath'.static.GetOffset(
            rotator(Player.Location - Pawn.Location), PillarCheckOffsets[i]);

        if (!FastTrace(EndTrace, Pawn.Location))
            return true;
    }

    return false;
}

/** Returns whether or not we can be blinded
 * @return TRUE if we can be blinded; FALSE otherwise
 */
function bool CanBeBlinded() {
    return bCanBeBlinded && !IsInState('BlindStart') && !IsInState('Blind') && !IsInState('BlindEnd');
}

/** Returns whether or not we've reached our destination
 * @return TRUE if we've reached our destination, FALSE otherwise
 */
function bool HasReachedDestination() {
    if (Destination == none)
        return true;

    return VSize(Destination.Location - Pawn.Location) < MoveReachedRadius;
}

/** Returns whether or not we've reached the Player's corpse
 * @return TRUE if we've reached our destination, FALSE otherwise
 */
function bool HasReachedPlayer() {
    if (Player == none)
        return true;

    return VSize(Player.Location - Pawn.Location) < MoveReachedRadius;
}

/** Returns whether or not we have a line of sight to the player
 * @return TRUE if we have a line of sight; FALSE otherwise
 */
function bool HasLineOfSightToPlayer() {
    if (Player == none)
        return false;

    return FastTrace(Player.Location, Pawn.Location);
}

/** Returns whether or not we should move to cover
 * @return TRUE if we're running low on ammo and should move toward cover;
 *         FALSE otherwise
 */
function bool ShouldMoveToCover() {
    return (1 - (CurrentBurstCount / MaxBurstCount)) < RunForCoverAmmoPct;
}

/** Returns whether or not conditions are optimal for a grenade throw.
 * Conditions include our grenade cooldown time, whether or not we're in range
 * of the player, and if a pillar isn't blocking most of our view.
 * @return TRUE if conditions are good; FALSE otherwise
 */
function bool ShouldThrowGrenade() {
    return bCanThrowGrenade && InGrenadeThrowRange() && !IsPillarInWay();
}

/** Returns whether or not we should throw a molotov based on how low our health
 * is. To me, they're a bit more dangerous and likely to damage the player
 * @param TRUE if we've been damaged enough to do so; FALSE otherwise
 */
function bool ShouldUseMolotov() {
    if (ZackWard == none)
        return false;

    return (ZackWard.Health / ZackWard.HealthMax) < MolotovHealthPct;
}

/** Takes a range and returns a value between the specified min and max values
 * @param r - A range value consisting of a minimum and maximum value
 * @return A value in between the specified min and max
 */
function float GetRangeValue(range r) {
    return r.Min + (r.Max - r.Min) * FRand();
}

/** Returns the closest cover node that we should move to in order to reload
 * our weapon
 * @return PathNode that we should move to reload our weapon
 */
function PathNode GetCoverNode() {
    local float Distance, ClosestDistance;
    local PathNode CurrentNode, ReturnNode;

    // On second thought, just make Zack Ward reload where he is
    return none;

    ClosestDistance = 3.4028e38;

    foreach AllActors(class'PathNode', CurrentNode, CoverNodeTag) {
        Distance = VSize(CurrentNode.Location - Pawn.Location);

        if (Distance < ClosestDistance &&
            !FastTrace(CurrentNode.Location, Player.Location)) {

            ClosestDistance = Distance;
            ReturnNode = CurrentNode;
        }
    }

    return ReturnNode;
}

/** Returns the LookTarget we should throw at in order to flush, the
 * Postal Dude out of hiding
 * @param ProjStart - Location in the world where the grenade will spawn
 * @return LookTarget that we should throw at to flush the Postal Dude out
 */
function vector GetCoverFlushLocation(vector ProjStart) {
    local bool bThrowMolotov;
    local int i, j;
    local float dx, dy, g;
    local float MaxHeight;
    local float Distance, ShortestDist;
    local vector LatStart, LatEnd;
    local vector TestFlushOffset, TestFlushLocation, HeightTestStart;
    local float TestTrajectoryPitch;

    local vector CoverFlushLoc;

    bThrowMolotov = ShouldUseMolotov();

    if (bThrowMolotov)
        g = Abs(MolotovGravity);
    else
        g = Abs(GrenadeGravity);

    ShortestDist = 3.4028e38;

    for (i=0;i<CoverFlushGridXSize;i++) {
        for (j=0;j<CoverFlushGridYSize;j++) {
            // First calculate an offset from our player to test for viability
            TestFlushOffset.X = CoverFlushGridSize * i - CoverFlushGridSize *
                (CoverFlushGridXSize / 2);

            TestFlushOffset.Y = CoverFlushGridSize * j - CoverFlushGridSize *
                (CoverFlushGridYSize / 2);

            TestFlushLocation = Player.Location + class'P2EMath'.static.GetOffset(
                Player.Rotation, TestFlushOffset);

            // Calculate the distance from the target
            Distance = VSize(TestFlushLocation - Player.Location);

            // Prune off locations that are clearly farther than an existing
            // cover flush location solution
            if (Distance >= ShortestDist)
                continue;

            // Really shitty bool here, but whatever
            // If its impossibly to hit with either the molotov or grenade
            if (!class'P2EMath'.static.CanHitTarget(ProjStart, TestFlushLocation, MolotovThrowSpeed, g) &&
                !class'P2EMath'.static.CanHitTarget(ProjStart, TestFlushLocation, GrenadeThrowSpeed, g))
                 continue;

            // Calculate the Pitch component so we can do a height check
            LatStart = ProjStart;
            LatStart.Z = 0;

            LatEnd = TestFlushLocation;
            LatEnd.Z = 0;

            dx = VSize(LatEnd - LatStart);
            dy = TestFlushLocation.Z - ProjStart.Z;

            // If we can hit it, then can calculate the trajector,
            if (bThrowMolotov)
                TestTrajectoryPitch = class'P2EMath'.static.GetTrajectoryPitch(
                    dx, dy, MolotovThrowSpeed, g,
                    bMolotovsUseHigherArcsForCoverFlush);
            else
                TestTrajectoryPitch = class'P2EMath'.static.GetTrajectoryPitch(
                    dx, dy, GrenadeThrowSpeed, g,
                    bGrenadesUseHigherArcsForCoverFlush);

            // Now that we have the throwing trajectory pitch, we can calculate
            // the maximum throwing height. Height is important for seeing
            // if the grenade can possibly hit
            if (bThrowMolotov)
                MaxHeight = class'P2EMath'.static.GetMaxProjectileHeight(
                    TestTrajectoryPitch, MolotovThrowSpeed, g);
            else
                MaxHeight = class'P2EMath'.static.GetMaxProjectileHeight(
                    TestTrajectoryPitch, GrenadeThrowSpeed, g);

            HeightTestStart = ProjStart;
            HeightTestStart.Z += MaxHeight;

            if (FastTrace(Player.Location, TestFlushLocation) &&
                FastTrace(TestFlushLocation, HeightTestStart)) {

                ShortestDist = Distance;
                CoverFlushLoc = TestFlushLocation;
            }
        }
    }

    return CoverFlushLoc;
}

/*
function LookTarget GetGrenadeTarget() {

    local float Distance, ClosestDistance;
    local LookTarget CurrentTarget, ReturnTarget;

    if (Player == none)
        return none;

    ClosestDistance = 3.4028e38;

    foreach DynamicActors(class'LookTarget', CurrentTarget, GrenadeTargetTag) {

        Distance = VSize(CurrentTarget.Location - Player.Location);

        // The LookTarget must have a line of sight to the Player so the
        // explosion can deal damage, and a line of sight to Zack Ward so we
        // can get the projectile there
        if (Distance < ClosestDistance &&
            FastTrace(Player.Location, CurrentTarget.Location) &&
            FastTrace(CurrentTarget.Location, Pawn.Location)) {

            ClosestDistance = Distance;
            ReturnTarget = CurrentTarget;
        }
    }

    return ReturnTarget;
}
*/

/** Overriden so we may perform an initalizations after a second */
function Possess(Pawn aPawn) {
    super.Possess(aPawn);

    ZackWard = ZackWard(aPawn);
	ZackWard.AddDefaultInventory();	// Call this here and now so we can be replaced properly in liebermode

    aPawn.TurnLeftAnim = '';
    aPawn.TurnRightAnim = '';

    SetTimer(3, false);

    AddTimer(GetRangeValue(StationaryTauntInterval), 'PlayStationaryTauntSound', false);
}

/** Perform the initial setup of various object references */
function Timer() {
    local Inventory Inv;
    local P2DualWieldWeapon DualWieldWeapon;
    local P2WeaponAttachment P2WeapAttachment;

    // Make our main weapon dual wield by default
    if (ZackWard != none) {
        if (ZackWard.BaseEquipment.length > 0) {
            ZackWard.AddDefaultInventory();

            Inv = Pawn.FindInventoryType(ZackWard.BaseEquipment[0].WeaponClass);

            DualWieldWeapon = P2DualWieldWeapon(Inv);

            if (Inv != none && Weapon(Inv) != none) {
                Weapon(Inv).TraceAccuracy = FireAccuracy;

                Pawn.PendingWeapon = Weapon(Inv);
                Pawn.ChangedWeapon();
            }

            if (DualWieldWeapon != none) {
                DualWieldWeapon.SetupDualWielding();
                DualWieldWeapon.GotoState('ToggleDualWielding');

                if (DualWieldWeapon.LeftWeapon != none)
                    LeftWeapon = DualWieldWeapon.LeftWeapon;
            }
        }

        ZackWard.ZackWardController = self;

        if (LeftWeapon != none)
            ZackWard.LeftWeapon = LeftWeapon;
    }

    // Find our player
    foreach DynamicActors(class'Pawn', Player)
        if (PlayerController(Player.Controller) != none)
            break;

    // Setup our initial burst count before firing
    MaxBurstCount = RandRange(BurstCount.Min, BurstCount.Max);

    Pawn.SetPhysics(PHYS_Falling);

    // Start out guns ablazing!
    GotoState('FiringDown');
}

/** Overriden so we may implement multi-timer functionality */
function TimerFinished(name ID) {
    switch (ID) {
        case 'EnableGrenadeThrow':
            bCanThrowGrenade = true;
            break;

        case 'EnablePainSound':
            bPlayPainSound = true;
            break;

        case 'PlayStationaryTauntSound':
            PlayStationaryTauntSound();
            break;

        case 'PlayCombatTauntSound':
            PlayCombatTauntSound();
            break;

        case 'EnableBlind':
            bCanBeBlinded = true;
            break;
    }
}

/** Play a throwing grenade taunt */
function PlayGrenadeThrowTaunt() {
    local sound GrenadeThrowTaunt;

    GrenadeThrowTaunt = GrenadeThrowTaunts[Rand(GrenadeThrowTaunts.length)];
    Pawn.PlaySound(GrenadeThrowTaunt, SLOT_Talk, 2, false, 500);
}

/** Play a pain sound */
function PlayPainSound() {
    local sound PainSound;

    bPlayPainSound = false;
    PainSound = PainSounds[Rand(PainSounds.length)];
    Pawn.PlaySound(PainSound, SLOT_Talk, 2, false, 500);

    AddTimer(GetRangeValue(PainSoundInterval), 'EnablePainSound', false);
}

/** Play a taunt sound while we're stationary */
function PlayStationaryTauntSound() {
    local float SoundDuration;
    local sound StationaryTaunt;

    StationaryTaunt = StationaryTaunts[Rand(StationaryTaunts.length)];
    Pawn.PlaySound(StationaryTaunt, SLOT_Talk, 2, false, 500);
    SoundDuration = GetSoundDuration(StationaryTaunt);

    AddTimer(SoundDuration + GetRangeValue(StationaryTauntInterval),
        'PlayStationaryTauntSound', false);
}

/** Play a normal combat taunt sound */
function PlayCombatTauntSound() {
    local float SoundDuration;
    local sound CombatTaunt;

    CombatTaunt = CombatTaunts[Rand(CombatTaunts.length)];
    Pawn.PlaySound(CombatTaunt, SLOT_Talk, 2, false, 500);
    SoundDuration = GetSoundDuration(CombatTaunt);

    AddTimer(SoundDuration + GetRangeValue(CombatTauntInterval),
        'PlayCombatTauntSound', false);
}

/** Play a victory taunt sound
 * @return Duration of the victory comment we played
 */
function float PlayVictoryTauntSound() {
    local sound VictoryTaunt;

    VictoryTaunt = VictoryTaunts[Rand(VictoryTaunts.length)];
    Pawn.PlaySound(VictoryTaunt, SLOT_Talk, 2, false, 500);

    return GetSoundDuration(VictoryTaunt);
}

/** Overriden so we can fire at the Postal Dude */
function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart,
                           int aimerror) {
    if (Player == none)
        return Rotation;

    return rotator(Player.Location - projStart);
}

/** Fires either the left or the right weapon */
function FireWeapons() {
    local P2DualWieldWeapon DualWieldWeapon;

    if (CurrentBurstCount == MaxBurstCount)
        return;

    if (bFireRightWeapon && Pawn.Weapon != none) {
        Pawn.Weapon.TraceFire(Pawn.Weapon.TraceAccuracy, 0, 0);
        Pawn.Weapon.LocalFire();
    }
    else if (LeftWeapon != none) {
        LeftWeapon.TraceFire(LeftWeapon.TraceAccuracy, 0, 0);
        LeftWeapon.LocalFire();
    }

    bFireRightWeapon = !bFireRightWeapon;
    CurrentBurstCount++;
}

/** Notification from our Pawn that we've just been hit */
function NotifyTakeHit(Pawn InstigatedBy, vector HitLocation, int Damage,
                       class<DamageType> DamageType, vector Momentum) {
    local int i;
    local vector AmmoDropVel;
    local Pickup AmmoPickup;

    if (ZackWard == none)
        return;

    if (bPlayPainSound)
        PlayPainSound();

    if (ClassIsChildOf(DamageType, class'FlashBangDamage') && CanBeBlinded()) {
        bCanBeBlinded = false;

        // Drop two MachineGun magazines if we're blinded while reloading
        if (IsInState('Reloading') && DroppedAmmoClass != none) {
            for (i=0;i<DroppedAmmoCount;i++) {
                AmmoPickup = Pawn.Spawn(DroppedAmmoClass);

                if (AmmoPickup != none) {
                    AmmoDropVel = VRand() * 512;
                    AmmoDropVel.Z = Abs(AmmoDropVel.Z);

                    AmmoPickup.SetPhysics(PHYS_Falling);
                    AmmoPickup.Velocity = AmmoDropVel;
                }
            }
        }

        // Drop our grenade if we were about to throw it and got blinded
        if (IsInState('ThrowGrenade') && bPreppingGrenade) {
            bDropGrenade = true;

            // Kind of an ass way to handle dropping a grenade, but whatever
            if (ZackWard.GrenadeBolton == none)
                ZackWard.NotifyAttachGrenade();

            NotifyQuickThrowGrenade();

            ZackWard.DetachGrenadeBolton();
        }

        GotoState('BlindStart');
    }

    if (!bJumpDown && (ZackWard.Health / ZackWard.HealthMax) < JumpDownHealthPct) {
        bJumpDown = true;

        RemoveTimerByID('PlayStationaryTauntSound');

        AddTimer(GetRangeValue(CombatTauntInterval), 'PlayCombatTauntSound', false);
    }
}

/** Notification from our Pawn to attach a grenade to his left hand */
function NotifyAttachGrenade() {
    if (ZackWard == none)
        return;

    if (ShouldUseMolotov())
        ZackWard.AttachMolotovBolton();
    else
        ZackWard.AttachGrenadeBolton();
}

/** Notification from our Pawn to spawn our grenade */
function NotifyQuickThrowGrenade() {

    local bool bThrowMolotov, bHasLineOfSight;
    local float GrenadeSpeed;
    local rotator GrenadeTrajectory;
    local vector CoverFlushLocation;
    //local LookTarget CoverFlushTarget;
    local GrenadeProjectile Grenade;

    local vector SpawnLoc;
    local rotator SpawnRot;

    if (Player == none || ZackWard == none || ZackWard.GrenadeBolton == none)
        return;

    SpawnLoc = ZackWard.GrenadeBolton.Location;
    SpawnRot = ZackWard.GrenadeBolton.Rotation;

    bThrowMolotov = ShouldUseMolotov();
    bHasLineOfSight = HasLineOfSightToPlayer();

    if (bThrowMolotov && MolotovClass != none) {
        Grenade = Spawn(MolotovClass,,, SpawnLoc, SpawnRot);

        GrenadeSpeed = MolotovThrowSpeed;

        if (bHasLineOfSight)
            GrenadeTrajectory = class'P2EMath'.static.GetProjectileTrajectory(
                SpawnLoc, Player.Location, MolotovThrowSpeed, Player.Velocity,
                GrenadeThrowSpread, MolotovGravity, bLeadTarget,
                bMolotovsUseHigherArcsInLineOfSight);
        else {
            CoverFlushLocation = GetCoverFlushLocation(SpawnLoc);

            if (CoverFlushLocation != vect(0,0,0))
                GrenadeTrajectory = class'P2EMath'.static.
                    GetProjectileTrajectory(
                    SpawnLoc, CoverFlushLocation, MolotovThrowSpeed,
                    vect(0,0,0), GrenadeThrowSpread,
                    MolotovGravity, bLeadTarget,
                    bMolotovsUseHigherArcsForCoverFlush);
        }

        ZackWard.PlayMolotovThrowSound();
    }
    else if (GrenadeClass != none) {
        Grenade = Spawn(GrenadeClass,,, SpawnLoc, SpawnRot);

        GrenadeSpeed = GrenadeThrowSpeed;

        if (bHasLineOfSight)
            GrenadeTrajectory = class'P2EMath'.static.GetProjectileTrajectory(
                SpawnLoc, Player.Location, GrenadeThrowSpeed, Player.Velocity,
                GrenadeThrowSpread, GrenadeGravity, bLeadTarget,
                bGrenadesUseHigherArcsInLineOfSight);
        else {
            CoverFlushLocation = GetCoverFlushLocation(SpawnLoc);

            if (CoverFlushLocation != vect(0,0,0))
                GrenadeTrajectory = class'P2EMath'.static.
                    GetProjectileTrajectory(
                    SpawnLoc, CoverFlushLocation, GrenadeThrowSpeed,
                    vect(0,0,0), GrenadeThrowSpread,
                    GrenadeGravity, bLeadTarget,
                    bGrenadesUseHigherArcsForCoverFlush);
        }

        ZackWard.PlayGrenadeThrowSound();
    }

    // If we can't find a cover flush location, ensure we still throw the
    // grenade as far as we can toward the Postal Dude
    if (GrenadeTrajectory == rot(0,0,0)) {
        GrenadeTrajectory = rotator(Player.Location - Pawn.Location);
        GrenadeTrajectory.Pitch = 8192;
    }

    if (Grenade != none) {
        Grenade.Instigator = ZackWard;
        Grenade.SetPhysics(PHYS_Projectile);
        Grenade.bBounce = true;
        Grenade.MakeSmokeTrail();
        Grenade.RandSpin(Grenade.StartSpinMag);

        if (bDropGrenade)
            Grenade.Velocity = vect(0,0,0);
        else
            Grenade.Velocity = vector(GrenadeTrajectory) * GrenadeSpeed;

        if (bThrowMolotov)
            Grenade.Acceleration.Z = -Abs(MolotovGravity);
        else
            Grenade.Acceleration.Z = -Abs(GrenadeGravity);
    }

    bPreppingGrenade = false;
    bDropGrenade = false;
}

/** Called if we cannot find a path to our destination
 * Right now, we just reload where we are if we can't find cover
 */
function CantFindPathToCover() {
    GotoState('Reloading');
}

/** Called if we cannot find a path to our Player
 * If we can't find a path to our player, simply wait where we are for the
 * player. We most likely won't ever need to go into this state
 */
function CantFindPathToPlayer() {
    if (!IsPlayerDead())
        GotoState('WaitForPlayerPath');
    else
        GotoState('TauntDeadDude');
}

/** Here, we stand at the very top firing down on the player */
state FiringDown
{
    function BeginState() {
        LogDebug("Entered FiringDown state...");

        Focus = Player;

        SetTimer(FireInterval, true);
    }

    function Timer() {
        FireWeapons();

        if (IsPlayerDead())
            GotoState('MoveToPlayer');
        else if (ShouldThrowGrenade())
            GotoState('ThrowGrenade');
        else if (CurrentBurstCount == MaxBurstCount)
            GotoState('Reloading');
        else if (bJumpDown) {
            if (ShouldMoveToCover())
                GotoState('MoveToCoverWhileFiring');
            else if (InFiringRangeOfPlayer() && HasLineOfSightToPlayer())
                GotoState('StandWhileFiring');
            else
                GotoState('MoveToPlayerWhileFiring');
        }
    }

Begin:
    StopMoving();
}

/** Zack needs to reload both his MachineGuns in order to continue firing */
state Reloading
{
    function BeginState() {
        LogDebug("Entered Reloading state...");

        Focus = Player;

        PlayAnimByDuration(ReloadAnim, ReloadTime);
        SetTimer(ReloadTime, false);
    }

    function Timer() {
        CurrentBurstCount = 0;
        MaxBurstCount = RandRange(BurstCount.Min, BurstCount.Max);

        if (!bJumpDown) {
            if (ShouldThrowGrenade())
                GotoState('ThrowGrenade');
            else
                GotoState('FiringDown');
        }
        else if (IsPlayerDead())
            GotoState('MoveToPlayer');
        else if (InFiringRangeOfPlayer() && HasLineOfSightToPlayer())
            GotoState('StandWhileFiring');
        else
            GotoState('MoveToPlayerWhileFiring');
    }

Begin:
    StopMoving();
}

/** Just got hit with a flashbang, so quickly cover our eyes */
state BlindStart
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        PlayAnimByDuration(BlindStartAnim, BlindStartTime, AnimBlendTime);
        SetTimer(BlindStartTime, false);
    }

    function Timer() {
        GotoState('Blind');
    }

Begin:
    StopMoving();
}

/** Loop our blind animation until the effect has worn off */
state Blind
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        LoopAnimInfo(BlindAnim);
        SetTimer(BlindTime, false);
    }

    function Timer() {
        GotoState('BlindEnd');
    }

Begin:
    StopMoving();
}

/** Blinding effect has finally worn off, now we get back to kicking ass */
state BlindEnd
{
    function BeginState() {
        LogDebug("Entered " $ GetStateName() $ " state...");

        FaceForward();

        PlayAnimByDuration(BlindEndAnim, BlindEndTime, AnimBlendTime);
        SetTimer(BlindEndTime, false);
    }

    function EndState() {
        AddTimer(ReblindDelay, 'EnableBlind', false);
    }

    function Timer() {
        if (!bJumpDown)
            GotoState('FiringDown');
        else if (CurrentBurstCount == MaxBurstCount)
            GotoState('Reloading');
        else if (InFiringRangeOfPlayer() && HasLineOfSightToPlayer())
            GotoState('StandWhileFiring');
        else
            GotoState('MoveToPlayerWhileFiring');
    }

Begin:
    StopMoving();
}

/** Say some closing comments about the dead Postal Dude */
state TauntDeadDude
{
    function BeginState() {
        local int i;
        local float VictoryDuration;

        LogDebug("Entered TauntDeadDude state...");

        Focus = Player;

        i = Rand(GestureAnims.length);
        VictoryDuration = PlayVictoryTauntSound();

        PlayAnimByDuration(GestureAnims[i], VictoryDuration);

        SetTimer(VictoryDuration, false);
    }

    function Timer() {
        GotoState('Dance');
    }

Begin:
    StopMoving();
}

/** We've killed the player since he or she sucks, now gloat */
state Dance
{
    function BeginState() {
        LogDebug("Entered Dance state...");

        Focus = none;
        FocalPoint = Pawn.Location + vector(Pawn.Rotation) * 256;

        Timer();
    }

    function Timer() {
        local int i;

        i = Rand(DanceAnims.length);

        PlayAnimInfo(DanceAnims[i], DanceAnimBlendTime);
        SetTimer(DanceAnims[i].AnimTime, false);
    }

Begin:
    StopMoving();
}

/** If the Postal Dude is in our line of sight and fairly close, we can just
 * stand there and shoot the crap out of him
 */
state StandWhileFiring
{
    function BeginState() {
        LogDebug("Entered StandWhileFiring state...");

        Focus = Player;

        SetTimer(FireInterval, true);
    }

    function Timer() {
        FireWeapons();

        if (IsPlayerDead())
            GotoState('MoveToPlayer');
        else if (!HasLineOfSightToPlayer()) {
            if (ShouldThrowGrenade())
                GotoState('ThrowGrenade');
            else
                GotoState('MoveToPlayerWhileFiring');
        }
        else if (CurrentBurstCount == MaxBurstCount)
            GotoState('Reloading');
        else if (!InFiringRangeOfPlayer() || !HasLineOfSightToPlayer())
            GotoState('MoveToPlayerWhileFiring');
    }

Begin:
    StopMoving();
}

/** Move to cover so we can reload our weapons */
state MoveToCover
{
    function BeginState() {
        LogDebug("Entered MoveToCover state...");

        Focus = none;

        SetTimer(MoveThinkInterval, true);
    }

    function Timer() {
        if (HasReachedDestination())
            GotoState('Reloading');
    }

Begin:
    Destination = GetCoverNode();

    if (Destination == none)
        GotoState('Reloading');

    while (!HasReachedDestination()) {
        if (ActorReachable(Destination))
            MoveToward(Destination);
		else {
			MoveTarget = FindPathToward(Destination);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
            else
                CantFindPathToCover();
		}
    }
}

/** Just move over to the player, not necessarily firing or running */
state MoveToPlayer
{
    function BeginState() {
        LogDebug("Entered MoveToPlayer state...");

        SetTimer(MoveThinkInterval, true);
    }

    function Timer() {
        if (HasReachedPlayer())
            GotoState('TauntDeadDude');
    }

Begin:
    Pawn.SetWalking(true);

    while (!HasReachedPlayer()) {
        if (ActorReachable(Player))
            MoveToward(Player, Player);
		else {
			MoveTarget = FindPathToward(Player);

            if (MoveTarget != none)
				MoveToward(MoveTarget, Player);
            else
                CantFindPathToPlayer();
		}
    }

    GotoState('Dance');
}

/** Move from cover to cover firing at the Postal Dude */
state MoveToCoverWhileFiring
{
    function BeginState() {
        LogDebug("Entered MoveToCoverWhileFiring state...");

        Focus = Player;

        SetTimer(FireInterval, true);
    }

    function Timer() {
        FireWeapons();

        if (IsPlayerDead())
            GotoState('MoveToPlayer');
        else if (ShouldThrowGrenade())
            GotoState('ThrowGrenade');
        else if (CurrentBurstCount == MaxBurstCount)
            GotoState('MoveToCover');
        else if (HasReachedDestination())
            GotoState('Reloading');
    }

Begin:
    Destination = GetCoverNode();

    if (Destination == none)
        GotoState('Reloading');

    while (!HasReachedDestination()) {
        if (ActorReachable(Destination))
            MoveToward(Destination, Player);
		else {
			MoveTarget = FindPathToward(Destination);

            if (MoveTarget != none)
				MoveToward(MoveTarget, Player);
            else
                CantFindPathToCover();
		}
    }
}

/** Move from cover to cover firing at the Postal Dude */
state MoveToPlayerWhileFiring
{
    function BeginState() {
        LogDebug("Entered MoveToPlayerWhileFiring state...");

        Focus = Player;

        SetTimer(FireInterval, true);
    }

    function Timer() {
        FireWeapons();

        if (IsPlayerDead())
            GotoState('MoveToPlayer');
        else if (ShouldThrowGrenade())
            GotoState('ThrowGrenade');
        else if (CurrentBurstCount == MaxBurstCount)
            GotoState('Reloading');
        else if (InFiringRangeOfPlayer() && HasLineOfSightToPlayer())
            GotoState('StandWhileFiring');
    }

Begin:
    while (!InFiringRangeOfPlayer() || !HasLineOfSightToPlayer()) {
        if (ActorReachable(Player))
            MoveToward(Player, Player);
		else {
			MoveTarget = FindPathToward(Player);

            if (MoveTarget != none)
				MoveToward(MoveTarget, Player);
            else
                CantFindPathToPlayer();
		}
    }
}

/**
 * Probably won't be using this state at all, but if we ever have a siutation
 * where if we can't find a path to the player, simply wait for him and try
 * moving to the player again
 */
state WaitForPlayerPath
{
    function BeginState() {
        LogDebug("Entered WaitForPlayerPath state...");

        Focus = Player;

        SetTimer(PathWaitTime, false);
    }

    function Timer() {
        GotoState('MoveToPlayerWhileFiring');
    }

Begin:
    StopMoving();
}

/** Quickly whip out a grenade to throw at the Postal Dude */
state ThrowGrenade
{
    function BeginState() {
        LogDebug("Entered ThrowGrenade state...");

        bCanThrowGrenade = false;
        bPreppingGrenade = true;

        Focus = Player;

        if (ZackWard != none) {
            if (ShouldUseMolotov())
                ZackWard.PlayMolotovLightSound();
            else
                ZackWard.PlayGrenadePinPullSound();
        }

        PlayAnimByDuration(GrenadeThrowAnim, GrenadeThrowTime);
        PlayGrenadeThrowTaunt();

        SetTimer(GrenadeThrowTime, false);

        AddTimer(GrenadeThrowCooldownTime, 'EnableGrenadeThrow', false);
    }

    function EndState() {
        bPreppingGrenade = false;
    }

    function Timer() {
        if (!bJumpDown)
            GotoState('FiringDown');
        else if (CurrentBurstCount == MaxBurstCount)
            GotoState('Reloading');
        else if (InFiringRangeOfPlayer() && HasLineOfSightToPlayer())
            GotoState('StandWhileFiring');
        else
            GotoState('MoveToPlayerWhileFiring');
    }

Begin:
    StopMoving();
}

defaultproperties
{
    bLogDebug=false

    MoveThinkInterval=0.1
    PathWaitTime=1
    AnimBlendTime=0.1

    JumpDownHealthPct=0.9

    //--------------------------------------------------------------------------
    // Dialog Intervals

    PainSoundInterval=(Min=7,Max=10)
    StationaryTauntInterval=(Min=10,Max=15)
    CombatTauntInterval=(Min=10,Max=15)

    bPlayPainSound=true
    bFireRightWeapon=true
    bCanBeBlinded=true
    bCanThrowGrenade=true

    CoverNodeTag="CoverPathNode"

    //--------------------------------------------------------------------------
    // Dual wield firing

    FireInterval=0.08
    FiringRange=1024
    FireAccuracy=10

    //--------------------------------------------------------------------------
    // Reload

    ReloadAnim=(Anim="sb3_reload",AnimTime=4.03)

    RunForCoverAmmoPct=0.5
    BurstCount=(Min=40,Max=60)

    ReloadTime=3

    DroppedAmmoCount=2
    DroppedAmmoClass=class'MachinegunAmmoPickup'

    //--------------------------------------------------------------------------
    // Flashbang Blinding

    ReblindDelay=10

    BlindStartTime=2.7
    BlindTime=2
    BlindEndTime=1.03

    BlindStartAnim=(Anim="pl_blindreaction_in",AnimTime=2.7)
    BlindAnim=(Anim="pl_blindreaction_loop",Rate=1,AnimTime=2.36)
    BlindEndAnim=(Anim="pl_blindreaction_out",AnimTime=1.03)

    //--------------------------------------------------------------------------
    // Grenade Quick Throw

    bLeadTarget=false

    bGrenadesUseHigherArcsInLineOfSight=false
    bMolotovsUseHigherArcsInLineOfSight=false

    bGrenadesUseHigherArcsForCoverFlush=false
    bMolotovsUseHigherArcsForCoverFlush=false

    GrenadeThrowSpread=0

    GrenadeThrowSpeed=1280
    MolotovThrowSpeed=1280

    GrenadeGravity=1500
    MolotovGravity=1500

    MolotovHealthPct=0.5
    GrenadeThrowTime=2
    GrenadeThrowCooldownTime=10

    CoverFlushGridXSize=5
    CoverFlushGridYSize=5
    CoverFlushGridSize=128

    GrenadeThrowAnim=(Anim="sb2_throw_quick",AnimTime=2.03)

    GrenadeClass=class'ZackWardGrenadeProjectile'
    MolotovClass=class'MolotovProjectile'

    PillarCheckOffsets(0)=(X=256,Y=-256,Z=0)
    PillarCheckOffsets(1)=(X=256,Y=-128,Z=0)
    PillarCheckOffsets(2)=(X=256,Y=0,Z=0)
    PillarCheckOffsets(3)=(X=256,Y=128,Z=0)
    PillarCheckOffsets(4)=(X=256,Y=256,Z=0)

    //--------------------------------------------------------------------------
    // Dialog

    GrenadeThrowTaunts(0)=sound'PL-Dialog.WednesdayZackBoss.Zack-Grenade-FireInTheHole1'
    GrenadeThrowTaunts(1)=sound'PL-Dialog.WednesdayZackBoss.Zack-Grenade-FireInTheHole2'
    GrenadeThrowTaunts(2)=sound'PL-Dialog.WednesdayZackBoss.Zack-Grenade-HereCatch'
    GrenadeThrowTaunts(3)=sound'PL-Dialog.WednesdayZackBoss.Zack-Grenade-HereCatch2'
    GrenadeThrowTaunts(4)=sound'PL-Dialog.WednesdayZackBoss.Zack-Grenade-IveGottaPresentForYa1'
    GrenadeThrowTaunts(5)=sound'PL-Dialog.WednesdayZackBoss.Zack-Grenade-IveGottaPresentForYa2'
    GrenadeThrowTaunts(6)=sound'PL-Dialog.WednesdayZackBoss.Zack-Grenade-ThinkFastJerk'
    GrenadeThrowTaunts(7)=sound'PL-Dialog.WednesdayZackBoss.Zack-Grenade-ThinkFastJerk2'

    PainSounds(0)=sound'PL-Dialog.WednesdayZackBoss.Zack-Pain-Ack1'
    PainSounds(1)=sound'PL-Dialog.WednesdayZackBoss.Zack-Pain-Ack2'
    PainSounds(2)=sound'PL-Dialog.WednesdayZackBoss.Zack-Pain-Ack3'
    PainSounds(3)=sound'PL-Dialog.WednesdayZackBoss.Zack-Pain-Aiee1'
    PainSounds(4)=sound'PL-Dialog.WednesdayZackBoss.Zack-Pain-Aiee2'
    PainSounds(5)=sound'PL-Dialog.WednesdayZackBoss.Zack-Pain-Augh1'
    PainSounds(6)=sound'PL-Dialog.WednesdayZackBoss.Zack-Pain-Augh2'
    PainSounds(7)=sound'PL-Dialog.WednesdayZackBoss.Zack-Pain-OhFudge'
    PainSounds(8)=sound'PL-Dialog.WednesdayZackBoss.Zack-Pain-Ow'
    PainSounds(9)=sound'PL-Dialog.WednesdayZackBoss.Zack-Pain-Ow1'
    PainSounds(10)=sound'PL-Dialog.WednesdayZackBoss.Zack-Pain-Ow2'
    PainSounds(11)=sound'PL-Dialog.WednesdayZackBoss.Zack-Pain-ShootYourEyeOut'
    PainSounds(12)=sound'PL-Dialog.WednesdayZackBoss.Zack-Pain-ShootYourEyeOut2'
    PainSounds(13)=sound'PL-Dialog.WednesdayZackBoss.Zack-Pain-Uncle'

    StationaryTaunts(0)=sound'PL-Dialog.WednesdayZackBoss.Zack-StationaryTaunts-ComeHere1'
    StationaryTaunts(1)=sound'PL-Dialog.WednesdayZackBoss.Zack-StationaryTaunts-ComeHere2'
    StationaryTaunts(2)=sound'PL-Dialog.WednesdayZackBoss.Zack-StationaryTaunts-ComeOutAndPlay'
    StationaryTaunts(3)=sound'PL-Dialog.WednesdayZackBoss.Zack-StationaryTaunts-HeresZacky'
    StationaryTaunts(4)=sound'PL-Dialog.WednesdayZackBoss.Zack-StationaryTaunts-YouBetterCome'

    CombatTaunts(0)=sound'PL-Dialog.WednesdayZackBoss.Zack-Laugher1'
    CombatTaunts(1)=sound'PL-Dialog.WednesdayZackBoss.Zack-Laugher2'
    CombatTaunts(2)=sound'PL-Dialog.WednesdayZackBoss.Zack-Laugher3'
    CombatTaunts(3)=sound'PL-Dialog.WednesdayZackBoss.Zack-Roar1'
    CombatTaunts(4)=sound'PL-Dialog.WednesdayZackBoss.Zack-Roar2'
    CombatTaunts(5)=sound'PL-Dialog.WednesdayZackBoss.Zack-Taunts-ComeOnCryBaby'
    CombatTaunts(6)=sound'PL-Dialog.WednesdayZackBoss.Zack-Taunts-CryForMe'
    CombatTaunts(7)=sound'PL-Dialog.WednesdayZackBoss.Zack-Taunts-CryForMe2'
    CombatTaunts(8)=sound'PL-Dialog.WednesdayZackBoss.Zack-Taunts-SayUncle1'
    CombatTaunts(9)=sound'PL-Dialog.WednesdayZackBoss.Zack-Taunts-SayUncle2'
    CombatTaunts(10)=sound'PL-Dialog.WednesdayZackBoss.Zack-Taunts-YouGonnaCryNow'

    VictoryTaunts(0)=Sound'PL-Dialog.WednesdayZackBoss.Zack-Victory-DifferenceBetweenADuck'
    VictoryTaunts(1)=Sound'PL-Dialog.WednesdayZackBoss.Zack-Victory-ShouldHaveSaidUncle'
    VictoryTaunts(2)=Sound'PL-Dialog.WednesdayZackBoss.Zack-Victory-SuchAnAnnoyingVoice'
    VictoryTaunts(3)=Sound'PL-Dialog.WednesdayZackBoss.Zack-Victory-SuchAnAnnoyingVoice2'

    //--------------------------------------------------------------------------
    // Taunt Gestures

    GestureAnims(0)=(Anim="s_gesture1",AnimTime=2.13)
    GestureAnims(1)=(Anim="s_gesture2",AnimTime=1.63)
    GestureAnims(2)=(Anim="s_gesture3",AnimTime=1.36)

    //--------------------------------------------------------------------------
    // Dance

    DanceAnimBlendTime=0.1
    DanceAnims(0)=(Anim="s_dance1",Rate=1,AnimTime=6.4)
    DanceAnims(1)=(Anim="s_dance2",Rate=1,AnimTime=3.4)
    DanceAnims(2)=(Anim="s_dance3",Rate=1,AnimTime=3.03)

    MoveReachedRadius=128
}
