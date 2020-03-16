/**
 * LeprechaunGary
 *
 * Gary Coleman, as a Leprechaun. He's even smaller and weaker, but this little
 * guy can run like there's no tomorrow. This means you'll most likely have to
 * open fire on him in a crowded area
 */
class LeprechaunGary extends Gary;

/** TRUE if we're jumping into our pot of gold overriding the default anims */
var bool bOverrideJumpAnim;

/** Number of MoneyPickups to spawn when Leprechaun Gary is shot down */
var int   LeprechaunCashDropCount;
/** Amount of cash all the pickups will add up to */
var int   LeprechaunCashAmount;
/** Velocity in which cash flies out after Leprechaun Gary is killed */
var float LeprechaunCashDropVel;

/** Health percentage when Leprechaun Gary will collapse, but not die */
var float LeprechaunDeathCurlHealthtPct;

/** LeprechaunController currently controlling this LeprechaunGary */
var LeprechaunController LeprechaunController;

/** Overriden to give animation control over the AI Controller when Leprechaun
 * Gary needs to jump into his pot of gold with a custom animation
 */
simulated event PlayFalling() {
    if (!bOverrideJumpAnim)
        super.PlayFalling();
}

/** Overriden to give animation control over the AI Controller when Leprechaun
 * Gary needs to jump into his pot of gold with a custom animation
 */
simulated event PlayJump() {
    if (!bOverrideJumpAnim)
        super.PlayJump();
}

/** Overriden to notify our controller that limbs have been cut */
function CutThisLimb(Pawn InstigatedBy, int CutIndex, vector Momentum,
                     float DoSound, float DoBlood) {
    super.CutThisLimb(InstigatedBy, CutIndex, Momentum, DoSound, DoBlood);

    if (bMissingLegParts)
        LeprechaunController.NotifyLegsCutOff();
}

/** Overriden so our AI Controller gets notified when the player bumps into
 * Leprechaun Gary, either for becoming scared or putting him into the Dude's
 * pants
 */
event Bump(Actor Other) {
    if (Pawn(Other) != none && Pawn(Other).Controller != none &&
        Pawn(Other).Controller.bIsPlayer) {

        if (LeprechaunController != none)
            LeprechaunController.NotifyPlayerBump();
    }
}

/** Overriden to implement dropping several wads of cash when killed */
function Died(Controller Killer, class<DamageType> DamageType,
              vector HitLocation) {
    local int         i, MoneyAmount;
    local vector      SpawnVel;
    local rotator     SpawnRot;
    local MoneyPickup Money;

    SetCollision(false, false, false);

    MoneyAmount = LeprechaunCashAmount / LeprechaunCashDropCount;

    for (i=0;i<LeprechaunCashDropCount;i++) {
        SpawnVel.X = -LeprechaunCashDropVel + FRand() * 2 * LeprechaunCashDropVel;
        SpawnVel.Y = -LeprechaunCashDropVel + FRand() * 2 * LeprechaunCashDropVel;
        SpawnVel.Z = FRand() * LeprechaunCashDropVel;

        SpawnRot.Yaw = Rand(65536);

        Money = Spawn(class'MoneyPickup',,, Location, SpawnRot);

        if (Money != none) {
            Money.SetPhysics(PHYS_Falling);
            Money.AmountToAdd = MoneyAmount;
            Money.Velocity = SpawnVel;
        }
    }

    // Ensure there is always a usable pot of gold upon Leprechaun Gary's death
    if (LeprechaunController.PotOfGold != none)
        LeprechaunController.PotOfGold.bLeprechaunProtected = false;
    else
        LeprechaunController.SpawnPotOfGold().bLeprechaunProtected = false;

    super.Died(Killer, DamageType, HitLocation);

    PoofOutOfExistance();
}

/** Poof out of existance when the Leprechaun is killed. Nice and magical,
 * plus the ragdoll doesn't look right with this scaling
 */
function PoofOutOfExistance() {
    Spawn(class'LeprechaunExplosion');
    Destroy();
}

/** Overriden to implement notifying the controller */
function TakeDamage(int Damage, Pawn InstigatedBy, Vector Hitlocation,
						Vector Momentum, class<DamageType> DamageType) {
    super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);

    if (Health < HealthMax * LeprechaunDeathCurlHealthtPct &&
        LeprechaunController != none)
        LeprechaunController.NotifyFallDown();
}

defaultproperties
{
	ActorID="Leprechaun"
    LeprechaunCashDropCount=25
    LeprechaunCashAmount=250
    LeprechaunCashDropVel=512.0f

    LeprechaunDeathCurlHealthtPct=0.5f

    ControllerClass=class'LeprechaunController'
    BaseEquipment.Empty

    HealthMax=550.0f

    DrawScale=0.75f
    HeadScale=(X=0.75f,Y=0.75f,Z=0.75f)

    CollisionHeight=54.0f
    CollisionRadius=21.0f

    VoicePitch=1.5f

    HeadSkin=texture'MRT_Stpatricks.Gary_StPatrick2'

    Boltons(0)=(bone="NODE_Parent",StaticMesh=StaticMesh'StPatricksMesh.Beard1',bCanDrop=false,bAttachToHead=true)
    Boltons(1)=(bone="NODE_Parent",StaticMesh=StaticMesh'StPatricksMesh.Hair',bCanDrop=false,bAttachToHead=true)
    Boltons(2)=(bone="NODE_Parent",StaticMesh=StaticMesh'StPatricksMesh.leprechaun_gary_hat',bCanDrop=false,bAttachToHead=true)

    Skins(0)=texture'MRT_Stpatricks.gary_leprechaun'

    ExtraAnims.Empty
    ExtraAnims(0)=MeshAnimation'StPatricksAnim.gary_pot_dive_mick'

    Group="SeasonalStPatricks"

	TakesShotgunHeadShot=0.5
	TakesRifleHeadShot=0.5
	TakesOnFireDamage=0.5
	TakesAnthraxDamage=0.5
	TakesShockerDamage=0.5
	TakesPistolHeadShot=0.5
	TakesChemDamage=0.5
	TakesSledgeDamage=0.5
	TakesMacheteDamage=0.5
	TakesScytheDamage=0.5
}