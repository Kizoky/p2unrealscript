/**
 * P2EWeedActor
 *
 * Turn on, tune in, drop out
 */
class P2EWeedActor extends Actor
    placeable;

/** Whether or not this weed is good enough to overheal the Dude */
var(Weed) bool bCanOverheal;

/** Percent of either HealthMax or WeedOverhealPct to heal at each interval */
var(Weed) float WeedHealPct;
/** Percent of the Pawn's HealthMax for overheal, 2.0f would mean twice normal health */
var(Weed) float WeedOverhealPct;
/** Time in seconds between health adding */
var(Weed) float WeedHealInterval;
/** Radius from the burning weed to recieve it's healing effect */
var(Weed) float WeedHealRadius;
/** Time in seconds until the weed has been completely used up */
var(Weed) float WeedBurnTime;

/** Offset from the weed actor's perspective to check for pawns to heal */
var(Weed) vector WeedHealOffset;
/** Offset from the weed actor's perspective to spawn the fire */
var(Weed) vector WeedFireOffset;

/** Time in seconds since the last heal */
var float HealCurTime;
/** Time in seconds this weed has been burning so far */
var float BurnCurTime;
/** Fire Emitter to spawn */
var P2EWeedFireEmitter WeedFireEmitter;

/** Subclassed to ensure the WeedHealInterval is a valid number */
simulated function PostBeginPlay() {
    super.PostBeginPlay();

    SetTimer(WeedHealInterval / 2, false);
}

/** Can't disable tick in PostBeginPlay, so we do it here */
function Timer() {
    HealCurTime = 0.0f;
    BurnCurtime = 0.0f;
    WeedHealInterval = FMax(0.01f, WeedHealInterval);

    Disable('Tick');
}

/** Subclassed to implement functionality from getting touched by */
function Touch(Actor Other) {
    if (FireMatch(Other) != none && BurnCurTime < WeedBurnTime)
        EnableWeed();
}

/** Subclassed to implement catching on fire when it takes fire damage */
function TakeDamage(int Damage, Pawn instigatedBy, vector hitlocation, vector momentum, class<DamageType> damageType) {
    if (ClassIsChildOf(damageType, class'BurnedDamage') && BurnCurTime < WeedBurnTime)
        EnableWeed();
}

/** Sets the weed on fire */
function EnableWeed() {
    Enable('Tick');

    if (WeedFireEmitter == none) {
        WeedFireEmitter = Spawn(class'P2EWeedFireEmitter',,, Location + class'P2EMath'.static.GetOffset(Rotation, WeedFireOffset));

        if (WeedFireEmitter != none) {
            WeedFireEmitter.GotoState('Burning');
            WeedFireEmitter.Lifespan = WeedBurnTime;
            WeedFireEmitter.SetTimer(WeedBurnTime - (WeedFireEmitter.FadeTime + WeedFireEmitter.WaitAfterFadeTime), false);
            //WeedFireEmitter.SetupLifetime(WeedBurnTime);
        }
    }
}

/** Heals all pawns in the given WeedHealRadius assuming they have a line of sight */
function HealPawns() {
    local float HealAmount, OverhealAmount;
    local FPSPawn FPSP;

    foreach VisibleCollidingActors(class'FPSPawn', FPSP, WeedHealRadius, Location + class'P2EMath'.static.GetOffset(Rotation, WeedHealOffset)) {
        HealAmount = FPSP.HealthMax * WeedHealPct;
        OverhealAmount = FPSP.HealthMax * WeedOverhealPct;

        if (bCanOverheal)
            FPSP.Health = FMin(FPSP.Health + HealAmount, OverhealAmount);
        else
            FPSP.Health = FMin(FPSP.Health + HealAmount, FPSP.HealthMax);
    }
}

/** Subclassed to implement the adding of health */
function Tick(float DeltaTime) {
    HealCurTime += DeltaTime;
    BurnCurTime += DeltaTime;

    while (HealCurTime >= WeedHealInterval) {
        HealPawns();
        HealCurTime -= WeedHealInterval;
    }

    if (BurnCurTime >= WeedBurnTime)
        Disable('Tick');
}

defaultproperties
{
    bEdShouldSnap=true

    bAcceptsProjectors=true

    DrawType=DT_StaticMesh

    StaticMesh=StaticMesh'Zo_poundmesh.Other.zo_weed_forreal'

    bShadowCast=true
    bStaticLighting=true

    CollisionRadius=1.0f
    CollisionHeight=1.0f

    bCollideActors=true
    bBlockActors=true
    bBlockPlayers=true

    bEdShouldSnap=true

    bCanOverheal=true

    WeedHealPct=0.01f
    WeedOverhealPct=2.0f

    WeedHealInterval=0.2f
    WeedHealRadius=256.0f

    WeedBurnTime=20.0f

    WeedFireOffset=(X=0.0f,Y=0.0f,Z=48.0f)
    WeedHealOffset=(X=0.0f,Y=0.0f,Z=48.0f)
}