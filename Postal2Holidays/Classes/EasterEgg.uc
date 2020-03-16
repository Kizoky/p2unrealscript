/**
 * EasterEgg
 *
 * Not the fun kind where you find in games, but the kind where you smash them
 * open to get stuff
 */
class EasterEgg extends Actor
    placeable;

struct ItemPolicy {
    var() class<Ammunition> AmmoType;
    var() class<Ammo> AmmoPickup;
    var() float AmmoDropThresholdPct;
    var() float AmmoDropChance;
    var() int AmmoDropCount;
};

struct HealthPolicy {
    var() class<P2PowerupPickup> HealthPickup;
    var() float HealthDropThreshold;
    var() float HealthDropChance;
    var() int HealthDropCount;
};

struct EasterEggFracture {
    var StaticMesh EggFragmentMesh;
    var vector EggFragmentPrePivot;
    var vector EggFragmentOffset;
};

var() int Health;
var() float RespawnTime;

var() int EasterEggIndex;
var() array<Texture> EasterEggSkins;

var array<EasterEggFracture> EasterEggFragments;

var() sound BreakSound;
var() class<Emitter> BreakEmitter;

var() float ItemDropRange;
var() float ItemDropVelocity;
var() array<ItemPolicy> ItemDrops;
var() array<HealthPolicy> HealthDrops;

/** Overriden to implement the initialize this egg with a skin */
simulated function PostBeginPlay() {
    super.PostBeginPlay();

    SetRandomSkin();
}

/** Have the egg reappear after a set amount of time has passed */
function SpawnEgg() {
    SetDrawType(DT_StaticMesh);
    SetCollision(true, true, true);

    Health = default.Health;
}

/** "Destroy" the egg by having it disappear, but not deleted */
function DespawnEgg() {
    local int i;
    local vector EggFragmentLoc;
    local EasterEggFragment EggFragment;

    SetDrawType(DT_None);
    SetCollision(false, false, false);

    for (i=0;i<EasterEggFragments.length;i++) {
        EggFragmentLoc = Location + class'P2EMath'.static.GetOffset(Rotation,
                             EasterEggFragments[i].EggFragmentOffset);
        EggFragment = Spawn(class'EasterEggFragment',,, EggFragmentLoc);

        if (EggFragment != none) {
            EggFragment.InitializeFragment(EasterEggFragments[i].EggFragmentMesh, Skins[0]);
            EggFragment.PrePivot = EasterEggFragments[i].EggFragmentPrePivot;
        }
    }

    if (BreakEmitter != none)
        Spawn(BreakEmitter);

    if (BreakSound != none)
        PlaySound(BreakSound, SLOT_None, 1, false, 300);

    SetTimer(RespawnTime, false);
}

/** Overriden so we can "respawn" the egg after a set amount of time */
function Timer() {
    SpawnEgg();
}

/** Spawn some items depending on how low the player's supplies are
 * @param Breaker - FPSPawn in the world that broke this Easter Egg
 */
function SpawnItems(FPSPawn Breaker) {
    local int i, j, DropCount;
    local Ammunition Ammo;
    local Pickup ItemPickup;

    for (i=0;i<ItemDrops.length;i++) {
        Ammo = Ammunition(Breaker.FindInventoryType(ItemDrops[i].AmmoType));

        if (Ammo != none &&
            Ammo.AmmoAmount < Ammo.MaxAmmo * ItemDrops[i].AmmoDropThresholdPct &&
            FRand() < ItemDrops[i].AmmoDropChance) {

            // Ensure we drop a minimum of 1 item
            DropCount = Rand(ItemDrops[i].AmmoDropCount - 1) + 1;

            for (j=0;j<DropCount;j++) {
                ItemPickup = Spawn(ItemDrops[i].AmmoPickup);

                if (ItemPickup != none) {
                    ItemPickup.SetPhysics(PHYS_Falling);

                    ItemPickup.Velocity.X = FRand() * ItemDropVelocity - FRand() * ItemDropVelocity;
                    ItemPickup.Velocity.Y = FRand() * ItemDropVelocity - FRand() * ItemDropVelocity;
                    ItemPickup.Velocity.Z = ItemDropVelocity;
                }
            }
        }

        Ammo = none;
    }

    for (i=0;i<HealthDrops.length;i++) {
        if (Breaker.Health < Breaker.HealthMax * HealthDrops[i].HealthDropThreshold &&
            FRand() < HealthDrops[i].HealthDropChance) {
            ItemPickup = Spawn(HealthDrops[i].HealthPickup);

            // Ensure we drop a minimum of 1 item
            DropCount = Rand(HealthDrops[i].HealthDropCount - 1) + 1;

            for (j=0;j<DropCount;j++) {
                if (ItemPickup != none) {
                    ItemPickup.SetPhysics(PHYS_Falling);

                    ItemPickup.Velocity.X = FRand() * ItemDropVelocity - FRand() * ItemDropVelocity;
                    ItemPickup.Velocity.Y = FRand() * ItemDropVelocity - FRand() * ItemDropVelocity;
                    ItemPickup.Velocity.Z = ItemDropVelocity;
                }
            }
        }
    }
}

/** Grabs a random skin from our array of textures */
function SetRandomSkin() {
    EasterEggIndex = Rand(EasterEggSkins.length);

    Skins[0] = EasterEggSkins[EasterEggIndex];
}

/** Once we take enough damage, crack open and spawn stuff */
function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation,
                    vector Momentum, class<DamageType> DamageType) {

    // Ignore damage after we've been broken
    if (Health == 0) return;

    // Ignore damage done by the Easter Bunny
    if (EasterBunny(EventInstigator) != none) return;

    Health = Max(Health - Damage, 0);

    if (Health == 0) {
        DespawnEgg();

        if (FPSPawn(EventInstigator) != none)
            SpawnItems(FPSPawn(EventInstigator));
    }
}

defaultproperties
{
    Health=3
    RespawnTime=30

    EasterEggSkins(0)=texture'MRT_Easter.egg1'
    EasterEggSkins(1)=texture'MRT_Easter.egg2'
    EasterEggSkins(2)=texture'MRT_Easter.egg3'
    EasterEggSkins(3)=texture'MRT_Easter.egg4'
    EasterEggSkins(4)=texture'MRT_Easter.egg5'
    EasterEggSkins(5)=texture'MRT_Easter.egg6'
    EasterEggSkins(6)=texture'MRT_Easter.egg7'
    EasterEggSkins(7)=texture'MRT_Easter.egg8'
    EasterEggSkins(8)=texture'MRT_Easter.egg9'
    EasterEggSkins(9)=texture'MRT_Easter.egg10'
    EasterEggSkins(10)=texture'MRT_Easter.egg11'
    EasterEggSkins(11)=texture'MRT_Easter.egg12'
    EasterEggSkins(12)=texture'MRT_Easter.egg13'
    EasterEggSkins(13)=texture'MRT_Easter.egg14'
    EasterEggSkins(14)=texture'MRT_Easter.egg15'
    EasterEggSkins(15)=texture'MRT_Easter.egg16'

    EasterEggFragments(0)=(EggFragmentMesh=StaticMesh'MRT_Easterprops.egg_top',EggFragmentPrePivot=(X=0,Y=0,Z=25),EggFragmentOffset=(X=0,Y=0,Z=27))
    EasterEggFragments(1)=(EggFragmentMesh=StaticMesh'MRT_Easterprops.egg_bottom',EggFragmentPrePivot=(X=0,Y=0,Z=20),EggFragmentOffset=(X=0,Y=0,Z=-11))

    BreakSound=sound'MiscSounds.Props.plastichitsground1'
    //BreakEmitter=class'EasterBunnyDashSmoke'

    ItemDropRange=32
    ItemDropVelocity=400

    ItemDrops(0)=(AmmoType=class'PistolBulletAmmoInv',AmmoPickup=class'PistolAmmoPickup',AmmoDropThresholdPct=0.75,AmmoDropChance=0.75,AmmoDropCount=5)
    ItemDrops(1)=(AmmoType=class'ShotGunBulletAmmoInv',AmmoPickup=class'ShotgunAmmoPickup',AmmoDropThresholdPct=0.5,AmmoDropChance=0.75,AmmoDropCount=3)
    ItemDrops(2)=(AmmoType=class'MachineGunBulletAmmoInv',AmmoPickup=class'MachinegunAmmoPickup',AmmoDropThresholdPct=0.5,AmmoDropChance=0.75,AmmoDropCount=3)
    ItemDrops(3)=(AmmoType=class'LauncherAmmoInv',AmmoPickup=class'LauncherAmmoPickup',AmmoDropThresholdPct=0.25,AmmoDropChance=0.1,AmmoDropCount=1)
    ItemDrops(4)=(AmmoType=Class'EDStuff.GSelectAmmoInv',AmmoPickup=Class'EDStuff.GSelectAmmoPickup',AmmoDropThresholdPct=0.5,AmmoDropChance=0.75,AmmoDropCount=5)
    ItemDrops(5)=(AmmoType=Class'EDStuff.MP5AmmoInv',AmmoPickup=Class'EDStuff.MP5AmmoPickup',AmmoDropThresholdPct=0.5,AmmoDropChance=0.75,AmmoDropCount=5)

    HealthDrops(0)=(HealthPickup=class'DonutPickup',HealthDropThreshold=0.75,HealthDropChance=0.75,HealthDropCount=5)
    HealthDrops(1)=(HealthPickup=class'PizzaPickup',HealthDropThreshold=0.75,HealthDropChance=0.5,HealthDropCount=4)
    HealthDrops(2)=(HealthPickup=class'FastFoodPickup',HealthDropThreshold=0.5,HealthDropChance=0.75,HealthDropCount=3)
    HealthDrops(3)=(HealthPickup=class'CrackPickup',HealthDropThreshold=0.25,HealthDropChance=0.1,HealthDropCount=1)

    bEdShouldSnap=true

    DrawScale=1.05
    DrawType=DT_StaticMesh

    StaticMesh=StaticMesh'MRT_Easterprops.Egg_Static'

    PrePivot=(X=0,Y=0,Z=34)

    Skins(0)=texture'MRT_Easter.egg1'

    bCollideActors=true
	bBlockActors=true
	bBlockPlayers=true

	Group="None,SeasonalEaster"
}