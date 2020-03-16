/**
 * EasterBunny
 *
 * Easter Bunny, Martial Arts Master. Pissed off at the Dude for his shitty
 * behavior in the past
 */
class EasterBunny extends Bystander
    placeable;

//var config float DefaultGroundSpeed;
//var config float MaxHealth;

var float BludgeonDamageCoef;

var float CloneMaxHealth;

var float GrappleRunAnimCoef;
var float FinisherRunAnimCoef;

var() name EntrancePathNodeTag;
var() name EntranceMatineeEvent;
var() name KnockoutTriggerEvent;

var EasterBunnyController EasterBunnyController;

/** Hurts like hell, but we don't flinch for shit! */
function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> DamageType);

/** Ignore encroachment gibs since we're a very close ranged attack person */
event EncroachedBy(Actor Other);

/** Stubbing this out prevents the Easter Bunny from moving when getting
 * punched while he's grappling you
 */
function AddVelocity(vector NewVelocity);

/** The Easter Bunny cannot be set on fire due to one of his attacks leaving
 * a fire trail
 */
function SetOnFire(FPSPawn Doer, optional bool bIsNapalm);

function ExplodeHead(vector HitLocation, vector Momentum) {
    if (Health <= 0) super.ExplodeHead(HitLocation, Momentum);
}

function PopOffHead(vector HitLocation, vector Momentum) {
    if (Health <= 0) super.PopOffHead(HitLocation, Momentum);
}

function CutThisLimb(Pawn InstigatedBy, int CutIndex, vector Momentum,
                     float DoSound, float DoBlood) {

    if (Health <= 0) super.CutThisLimb(InstigatedBy, CutIndex, Momentum,
        DoSound, DoBlood);
}
function ChopInHalf(Pawn InstigatedBy, class<DamageType> DamageType,
                    out vector Momentum, out int Damage,
                    out vector TrueHitLoc) {

    if (Health <= 0) super.ChopInHalf(InstigatedBy, DamageType, Momentum,
        Damage, TrueHitLoc);
}

/** Overriden to change values */
simulated function PostBeginPlay() {
    super.PostBeginPlay();

    //HealthMax = MaxHealth;
    //Health = MaxHealth;

    //GroundSpeed = DefaultGroundSpeed;
}

/** Set our health to clone levels of health */
function SetClone() {
    HealthMax = CloneMaxHealth;
    Health = CloneMaxHealth;
}

/** Animation notify from our animated Mesh which is sent to our Controller */
function NotifySmokeBombTeleport() {
    if (EasterBunnyController != none)
        EasterBunnyController.NotifySmokeBombTeleport();
}

/** Animation notify from our animated Mesh which is sent to our Controller */
function NotifyCloneSummon() {
    if (EasterBunnyController != none)
        EasterBunnyController.NotifyCloneSummon();
}

/** Animation notify from our animated Mesh which is sent to our Controller */
function NotifyGroundAttack() {
    if (EasterBunnyController != none)
        EasterBunnyController.NotifyGroundAttack();
}

/** Animation notify from our animated Mesh which is sent to our Controller */
function NotifyWallPushoff() {
    if (EasterBunnyController != none)
        EasterBunnyController.NotifyWallPushoff();
}

/** Animation notify from our animated Mesh which is sent to our Controller */
function NotifyGrapplePunch() {
    if (EasterBunnyController != none)
        EasterBunnyController.NotifyGrapplePunch();
}

/** Animation notify from our animated Mesh which is sent to our Controller */
function NotifyGrappleUppercut() {
    if (EasterBunnyController != none)
        EasterBunnyController.NotifyGrappleUppercut();
}

/** Animation notify from our animated Mesh which is sent to our Controller */
function NotifyFinisherFlurryPunch() {
    if (EasterBunnyController != none)
        EasterBunnyController.NotifyFinisherFlurryPunch();
}

/** Animation notify from our animated Mesh which is sent to our Controller */
function NotifyFinisherDownPunch() {
    if (EasterBunnyController != none)
        EasterBunnyController.NotifyFinisherDownPunch();
}

/** Animation notify from our animated Mesh which is sent to our Controller */
function NotifyPlayGrappleSwooshSound() {
    if (EasterBunnyController != none)
        EasterBunnyController.NotifyPlayGrappleSwooshSound();
}

/** Animation notify from our animated Mesh which is sent to our Controller */
function NotifyPlayFlurryPunchSwoosh() {
    if (EasterBunnyController != none)
        EasterBunnyController.NotifyPlayFlurryPunchSwoosh();
}

/** Animation notify from our animated Mesh which is sent to our Controller */
function NotifyCrapOnDudesFace() {
    if (EasterBunnyController != none)
        EasterBunnyController.NotifyCrapOnDudesFace();
}

/** Overriden to perform the animation in the Controller since the Controller
 * has attack setting information to help sync them
 */
simulated event PlayFalling();

/** Overriden to remove the turn animations among other stuff */
simulated function SetAnimWalking() {
    TurnLeftAnim = '';
    TurnRightAnim = '';

    BaseMovementRate = EasterBunnyController.HumiliationWalkSpeed;

    MovementAnims[0] = 's_walk1';
    MovementAnims[1] = 's_walk1';
    MovementAnims[2] = 's_walk1';
    MovementAnims[3] = 's_walk1';
}

/** Overriden to remove the turn animations among other stuff */
simulated function SetAnimRunning() {
    TurnLeftAnim = '';
    TurnRightAnim = '';

    if (EasterBunnyController != none) {
        if (EasterBunnyController.bGrappleAttack) {
            BaseMovementRate = default.GroundSpeed * GrappleRunAnimCoef;

            MovementAnims[0] = EasterBunnyController.GrappleRunAnim.Anim;
            MovementAnims[1] = EasterBunnyController.GrappleRunAnim.Anim;
            MovementAnims[2] = EasterBunnyController.GrappleRunAnim.Anim;
            MovementAnims[3] = EasterBunnyController.GrappleRunAnim.Anim;
        }
        else if (EasterBunnyController.bFinisherAttack) {
            BaseMovementRate = default.GroundSpeed * FinisherRunAnimCoef;

            MovementAnims[0] = EasterBunnyController.FinisherRunAnim.Anim;
            MovementAnims[1] = EasterBunnyController.FinisherRunAnim.Anim;
            MovementAnims[2] = EasterBunnyController.FinisherRunAnim.Anim;
            MovementAnims[3] = EasterBunnyController.FinisherRunAnim.Anim;
        }
        else {
            BaseMovementRate = default.GroundSpeed;

            MovementAnims[0] = 's_run2';
            MovementAnims[1] = 's_run2';
            MovementAnims[2] = 's_run2';
            MovementAnims[3] = 's_run2';
        }
    }
}

/** Prevent the Easter Bunny from taking percentage based damage */
function int ModifyDamageByBodyLocation( int Damage, Pawn InstigatedBy,
						  vector HitLocation, vector Momentum,
						  out class<DamageType> ThisDamage,
						  out byte HeadShot) {
    return Damage;
}

function TakeDamage(int Damage, Pawn InstigatedBy, vector Hitlocation,
                    vector Momentum, class<DamageType> DamageType) {

	// Prevent damage until our controller possesses us
	if (EasterBunnyController(Controller) == None)
		return;
					
    // Ignore damage from other Easter Bunnies
    if (EasterBunny(InstigatedBy) != none)
        return;

    // In the case of the Rifle and default shotgun, change damage types so
    // Bullet to ignore instant kills
    if (ClassIsChildOf(DamageType, class'RifleDamage') ||
        ClassIsChildOf(DamageType, class'ShotGunDamage'))
        DamageType = class'BulletDamage';

    // For the Super Shotgun, we only want to get dealt the default shotgun's
    // damage amount, not the insane instant kill kind
    if (ClassIsChildOf(DamageType, class'SuperShotgunDamage') ||
        ClassIsChildOf(DamageType, class'SuperShotgunBodyDamage')) {
        Damage = 11;
        DamageType = class'BulletDamage';
    }
	
	// Ignore anthrax damage; the Bunny's martial arts training ensures he can
	// hold his breath in poisonous gas clouds
	if (ClassIsChildOf(DamageType, class'AnthDamage'))
		return;
		
	// Reduce damage from chainsaw to prevent instant cheese kills
	if (ClassIsChildOf(DamageType, class'ChainSawBodyDamage')
		|| ClassIsChildOf(DamageType, class'ChainSawDamage'))
		Damage = 1;

    if (ClassIsChildOf(DamageType, class'BludgeonDamage'))
        super.TakeDamage(Damage * BludgeonDamageCoef, InstigatedBy,
            HitLocation, Momentum, DamageType);
    else
        super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum,
            DamageType);
}

/** Overriden so the AI Controller gets a notification when he dies */
function Died(Controller Killer, class<DamageType> DamageType,
              vector HitLocation) {
    if (EasterBunnyController != none)
        EasterBunnyController.NotifyDied();

    super.Died(Killer, DamageType, HitLocation);
}

defaultproperties
{
	ActorID="EasterBunny"
    BludgeonDamageCoef=5

    CloneMaxHealth=75

    GrappleRunAnimCoef=0.33
    FinisherRunAnimCoef=0.46

    ExtraAnims.Empty
    ExtraAnims(0)=MeshAnimation'EasterAnims.mck_fighter_dashpunch'
    ExtraAnims(1)=MeshAnimation'EasterAnims.mck_fighter_dashkick'
    ExtraAnims(2)=MeshAnimation'EasterAnims.mck_fighter_groundpunch'
    ExtraAnims(3)=MeshAnimation'EasterAnims.mck_fighter_axekick'
    ExtraAnims(4)=MeshAnimation'EasterAnims.mck_fighter_divekick'
    ExtraAnims(5)=MeshAnimation'EasterAnims.mck_fighter_grapple'
    ExtraAnims(6)=MeshAnimation'EasterAnims.mck_fighter_finisher'
    ExtraAnims(7)=MeshAnimation'EasterAnims.mck_fighter_ko'
    ExtraAnims(8)=MeshAnimation'EasterAnims.mck_fighter_smokeclone'
    ExtraAnims(9)=MeshAnimation'MP_Characters.Anim_MP'

    RotationRate=(Pitch=0,Yaw=48000,Roll=0)

    GroundSpeed=750

    HealthMax=3000

    ControllerClass=class'EasterBunnyController'

    TakesShotgunHeadShot=0.5
	TakesRifleHeadShot=0.5
	TakesOnFireDamage=0
	TakesAnthraxDamage=0.5
	TakesShockerDamage=0.5
	TakesPistolHeadShot=0.5
	TakesChemDamage=0.5
	TakesSledgeDamage=0.5
	TakesMacheteDamage=0.5
	TakesScytheDamage=0.5

	bKeepForMovie=true
	bCanTeleportWithPlayer=false

	HeadSkin=texture'EasterTextures.ninjarabbithead'
	HeadMesh=Mesh'EasterAnims.Rabbit_Head'

	Mesh=Mesh'EasterAnims.Avg_Rabbit'

	Skins(0)=texture'EasterTextures.NinjaRabbitBody'

	DialogClass=class'BasePeople.DialogVince'

	ControllerClass=class'EasterBunnyController'

	bRandomizeHeadScale=false
	bStartupRandomization=false
	bNoChamelBoltons=true
}