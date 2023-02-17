///////////////////////////////////////////////////////////////////////////////
// SlimBitch
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// The dude's Hateful Wife, who appears to have slimmed down in the past
// 12 years. :O
///////////////////////////////////////////////////////////////////////////////
class SlimBitch extends PLBossPawn
	placeable;

/** Various attack and movement variables */
var float WalkSpeed, RunSpeed;

/** Objects we should keep track of */
var SlimBitchController SlimBitchController;

/** As a boss, we don't flinch play flinching animations from attacks */
function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> DamageType);

/** Slim Bitch tends to jump around a lot, so get rid of this */
function TakeFallingDamage();

/** Ignore encroachment gibs since we're a very close ranged attack person */
event EncroachedBy(Actor Other);

/** Remove the ability for bullets and melee attacks to impart momentum */
function AddVelocity(vector NewVelocity);

/** Stubbed out the existing movement centered animation code as Slim Bitch
 * tends to change movement styles a lot while maintaining the same animation
 * so it'll be easier to actually write our own
 */
simulated function name GetAnimStand();
simulated event ChangeAnimation();
simulated function SetAnimWalking();
simulated function SetAnimRunning();
simulated event PlayFalling();
simulated event PlayJump();
simulated function PlayLanded(float ImpactVel);

/** Overriden so we only linkup our animations */
simulated function SetupAnims() {
	LinkAnims();

	MovementAnims[0] = '';
    MovementAnims[1] = '';
    MovementAnims[2] = '';
    MovementAnims[3] = '';

    TurnLeftAnim = '';
    TurnRightAnim = '';
}

/** Overriden so we can transition the Controller into the landing state */
event Landed(vector HitNormal) {
    super.Landed(HitNormal);

    SetPhysics(PHYS_Walking);

    if (SlimBitchController == none)
        return;

    if (SlimBitchController.IsPerformingLeap())
        SlimBitchController.GotoState('LeapLand');
    else if (SlimBitchController.IsFinisherFalling())
        SlimBitchController.GotoState('FinisherLand');
}

/** Notify our SlimBitchController to perform a banshee scream */
function NotifyBansheeScream() {
    if (SlimBitchController != none)
        SlimBitchController.NotifyBansheeScream();
}

/** Notify our SlimBitchController that we've begun our swing */
function NotifyStartSwing() {
    if (SlimBitchController != none)
        SlimBitchController.NotifyStartSwing();
}

/** Notify our SlimBitchController to perform a horizontal slash */
function NotifyHorizontalSlash() {
    if (SlimBitchController != none)
        SlimBitchController.NotifyHorizontalSlash();
}

/** Notify our SlimBitchController to perform a vertical slash */
function NotifyVerticalSlash() {
    if (SlimBitchController != none)
        SlimBitchController.NotifyVerticalSlash();
}

/** Notify our SlimBitchController to perform slash up */
function NotifySlashUp() {
    if (SlimBitchController != none)
        SlimBitchController.NotifySlashUp();
}

/** Notify our SlimBitchController to perform aerial slash */
function NotifyAerialSlash() {
    if (SlimBitchController != none)
        SlimBitchController.NotifyAerialSlash();
}

/** Notify our SlimBitchController to perform slash down */
function NotifySlashDown() {
    if (SlimBitchController != none)
        SlimBitchController.NotifySlashDown();
}

///////////////////////////////////////////////////////////////////////////////
// Setup and destroy bolt-ons (decorative non-functional stuff)
///////////////////////////////////////////////////////////////////////////////
function SetupBoltons()
{
	// In Liebermode replace the sword with a shovel. It's funny, laugh dammit!
	if (P2GameInfo(Level.Game).InLieberMode())
		Boltons[1].StaticMesh = class'ShovelAttachment'.Default.StaticMesh;

	super.SetupBoltons();
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation,
                    vector Momentum, class<DamageType> DamageType) {

    super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);

    if (Health <= 0 && SlimBitchController != none)
        SlimBitchController.NotifyPawnDied();
}

defaultproperties
{
	ActorID="SlimBitch"

    PeacefulTakedownEvent="SlimBitchAteCake"
    ViolentTakedownEvent="SlimBitchGotShot"

    HealthMax=2000

    WalkSpeed=112
    RunSpeed=750

    GroundSpeed=750

    Mesh=SkeletalMesh'PLCharacters.SlimBitch'

	Skins(0)=Texture'PLCharacterSkins.SlimBitch.SlimBitch_Body'

	HeadSkin=Texture'PLCharacterSkins.SlimBitch.SlimBitch_Head'
	HeadMesh=Mesh'Heads.FemSH'

	Boltons[0]=(Bone="NODE_Parent",StaticMesh=StaticMesh'PLCharacterMeshes.beeyetch.FemSH_Veil',bAttachToHead=True,bCanDrop=false)
	Boltons[1]=(Bone="SORD",StaticMesh=StaticMesh'PLCharacterMeshes.beeyetch.SamuraiBlade',bCanDrop=false)

    bIsFemale=true

	ControllerClass=class'SlimBitchController'

	ExtraAnims.Empty
    ExtraAnims(0)=MeshAnimation'PLCharacters.animSlimBitch'
    ExtraAnims(1)=MeshAnimation'EasterAnims.mck_fighter_divekick'
    ExtraAnims(2)=MeshAnimation'EasterAnims.mck_fighter_grapple'
    ExtraAnims(3)=MeshAnimation'Characters.animAvg_PL'

	AmbientGlow=30
	bCellUser=false
}
