/**
 * PotOfGold
 *
 * The Pot of Gold that Leprechaun Gary will run towards and disappear into. If
 * Leprechaun Gary has been shot down or killed before reaching the pot of gold
 * then the Dude can break to create and explosion of cash
 */
class PotOfGold extends Actor;

/** Number of MoneyPickups to spawn when the Pot of Gold has been destroyed */
var int PotOfGoldCashDropCount;
/** Amount of cash in total that will drop */
var int PotOfGoldCashAmount;
/** Maximum velocity of the cash pickups will fly out */
var int PotOfGoldCashDropVel;
/** Z offet from the Pot of Gold's location to spawn the cash from */
var float PotOfGoldCashOffset;
/** Duration in seconds the Pot of Gold will be spewing our money */
var float PotOfGoldCashDropTime;

/** Z Offset from the Pot of Gold's location to spawn our rainbow beacon */
var float PotOfGoldBeaconOffset;

/** Whether or not we're currently spawning cash */
var bool bSpawningCash;
/** Whether or not Leprechaun Gary's magic is protecting his loot */
var bool bLeprechaunProtected;
/** Current number of MoneyPickup spawned */
var int CashDropCount;
/** End of the rainbow where our pot of gold is */
var PotOfGoldBeacon Rainbow;

/** Create our rainbow beacon when we first spawn */
simulated function PostBeginPlay() {
    local vector RainbowLocation;

    super.PostBeginPlay();

    RainbowLocation = Location;
    RainbowLocation.Z += PotOfGoldBeaconOffset;
    Rainbow = Spawn(class'PotOfGoldBeacon',,, RainbowLocation);
}

/** Overriden to implement the spewing of cash */
event Bump(Actor Other) {
    if (bLeprechaunProtected || bSpawningCash) return;

    bSpawningCash = true;
    SetTimer(PotOfGoldCashDropTime / PotOfGoldCashDropCount, true);
}

/** Overriden to implement the spawning of money pickups */
function Timer() {
    local int         i, MoneyAmount;
    local vector      SpawnLoc, SpawnVel;
    local rotator     SpawnRot;
    local MoneyPickup Money;

    MoneyAmount = PotOfGoldCashAmount / PotOfGoldCashDropCount;

    SpawnLoc = Location;
    SpawnLoc.Z += PotOfGoldCashOffset;

    SpawnVel.X = -PotOfGoldCashDropVel + FRand() * 2 * PotOfGoldCashDropVel;
    SpawnVel.Y = -PotOfGoldCashDropVel + FRand() * 2 * PotOfGoldCashDropVel;
    SpawnVel.Z = FRand() * PotOfGoldCashDropVel;

    SpawnRot.Yaw = Rand(65536);

    Money = Spawn(class'MoneyPickup',,, SpawnLoc, SpawnRot);

    if (Money != none) {
        Money.SetPhysics(PHYS_Falling);
        Money.AmountToAdd = MoneyAmount;
        Money.Velocity = SpawnVel;

        CashDropCount++;
    }

    if (CashDropCount == PotOfGoldCashDropCount) {
        Spawn(class'LeprechaunExplosion');
        Destroy();
    }
}

/** Overriden to take damage and explode in a shower of cash */
function TakeDamage(int Damage, Pawn InstigatedBy, vector Hitlocation,
                    vector Momentum, class<DamageType> DamageType) {
    if (bLeprechaunProtected || bSpawningCash) return;

    bSpawningCash = true;
    SetTimer(PotOfGoldCashDropTime / PotOfGoldCashDropCount, true);
}

/** When we're destroyed, remove our rainbow beacon as well */
event Destroyed() {
    super.Destroyed();

    if (Rainbow != none)
        Rainbow.Destroy();
}

defaultproperties
{
    bLeprechaunProtected=true

    PotOfGoldCashDropCount=100
    PotOfGoldCashAmount=500
    PotOfGoldCashDropVel=768.0f
    PotOfGoldCashOffset=96.0f
    PotOfGoldCashDropTime=5.0f

    PotOfGoldBeaconOffset=64.0f

    bCollideActors=true
	bBlockActors=true
	bBlockPlayers=true
    bUseCylinderCollision=true

	DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'StPatricksMesh.potofgold_state01'

    CollisionHeight=80.0f
    CollisionRadius=48.0f
}