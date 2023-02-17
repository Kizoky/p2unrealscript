/**
 * ObeseBitch
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Oh no! She's beome too large and unstable! Normally this only happens after
 * the wedding.
 *
 * @author Gordon Cheng
 */
class ObeseBitch extends PLBossPawn
    placeable;

struct CollisionBolton {
    var float DamageMult;
    var vector Scale3D, RelLoc;
    var rotator RelRot;
    var name BoneName;

    var PeoplePart Bolton;
};

// Bone names
const BONE_INVENTORY		= 'Bip001 R Hand';
const BONE_HEAD				= 'Bip001 head';
const BONE_BLENDFIRING		= 'Bip001 spine1';
const BONE_BLENDTAKEHIT		= 'Bip001 spine2';
const BONE_NECK				= 'Bip001 neck';
const BONE_PELVIS			= 'Bip001 pelvis';
const BONE_TOP_SPINE		= 'Bip001 spine1';
const BONE_MID_SPINE		= 'Bip001 spine2';
const BONE_RTHIGH			= 'Bip001 R thigh';
const BONE_RCALF			= 'Bip001 R calf';
const BONE_RFOOT			= 'Bip001 R foot';

const BONE_LEFT_HAND		= 'Bip001 L hand';

const BITCH_SKEL			= 'BitchDress';

/** Various attack and movement variables */
var float WalkSpeed, RunSpeed;

/** List of collision boltons we'll use attach to Obese Bitch */
var class<PeoplePart> CollisionBoltonClass;
var array<CollisionBolton> CollisionBoltons;

/** Misc objects and values */
var bool bAcceptDamage;

var ObeseBitchController ObeseBitchController;

// Dialog
var float SayTime;					// Amount of time we have left to talk
var array<Sound> DialogButtStomp;
var array<Sound> DialogBellyFlop;
var array<Sound> DialogLeap;
var array<Sound> DialogDash;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Dialog
// Could probably use the P2Dialog system for this instead, but we don't have
// many lines.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PlayDialog(Sound Line, optional bool bForce)
{
	if (SayTime <= 0 || bForce)
	{
		SayTime = GetSoundDuration(Line);
		PlaySound(Line, SLOT_Talk);
	}
}
function PlayDialogButtStomp(optional bool bForce)
{
	if (FRand() < 0.5)
		PlayDialog(DialogButtStomp[Rand(DialogButtStomp.Length)], bForce);
}
function PlayDialogBellyFlop(optional bool bForce)
{
	if (FRand() < 0.5)
		PlayDialog(DialogBellyFlop[Rand(DialogBellyFlop.Length)], bForce);
}
function PlayDialogLeap(optional bool bForce)
{
	PlayDialog(DialogLeap[Rand(DialogLeap.Length)], bForce);
}
function PlayDialogDash(optional bool bForce)
{
	PlayDialog(DialogDash[Rand(DialogDash.Length)], bForce);
}

simulated function PostBeginPlay() {
    super.PostBeginPlay();

    SetupCollisionBoltons();
}

///////////////////////////////////////////////////////////////////////////////
// Setup and destroy head
///////////////////////////////////////////////////////////////////////////////
function SetupHead()
{
	local rotator rot;
	local vector v;

	Super(MpPawn).SetupHead();

	// Create head and attach to body
	if (HeadClass != None)
	{
		if (myHead == None)
		{
			myHead = spawn(HeadClass, self,,Location);
			if (myHead != None)
			{
				// Attach to body
				log("Attaching bitch head to"@BONE_HEAD);
				AttachToBone(myHead, BONE_HEAD);
			}
		}

		if (myHead != None)
		{
			// Setup the head
			myHead.Setup(HeadMesh, HeadSkin, HeadScale, AmbientGlow);

			// Rotate head so it looks right (this is temporary until the editor's
			// animation browser supports attachment sockets)
			rot.Pitch = 0;
			rot.Yaw = -16384;	// -18000 looks better but leaves a gap at back of neck!
			rot.Roll = 16384;
			myHead.SetRelativeRotation(rot);

			// Push the heads down a hair to hide the seam
			v.x = ADJUST_RELATIVE_HEAD_X;
			v.y = ADJUST_RELATIVE_HEAD_Y;
			v.z = ADJUST_RELATIVE_HEAD_Z;
			myHead.SetRelativeLocation(v);
		}
	}
	else
		Warn("No HeadClass defined for "$self);
}

/** Simple method that goes through all of our collision bolton information
 * and creates all the corresponding collision boltons
 */
function SetupCollisionBoltons() {
    local int i;
    local PeoplePart NewCollisionBolton;

    if (CollisionBoltonClass == none) {
        log("ERROR: No CollisionBoltonClass found");
        return;
    }

    for (i=0;i<CollisionBoltons.length;i++) {
        if (CollisionBoltons[i].BoneName == '' || CollisionBoltons[i].BoneName == 'None')
            continue;

        NewCollisionBolton = Spawn(CollisionBoltonClass);

        if (NewCollisionBolton != none) {
            if (ObeseBitchCollision(NewCollisionBolton) != none) {
                ObeseBitchCollision(NewCollisionBolton).ObeseBitch = self;
                ObeseBitchCollision(NewCollisionBolton).DamageMult = CollisionBoltons[i].DamageMult;
            }

            AttachToBone(NewCollisionBolton, CollisionBoltons[i].BoneName);

            NewCollisionBolton.SetDrawScale3D(CollisionBoltons[i].Scale3D * (DrawScale / default.DrawScale));
            NewCollisionBolton.SetRelativeLocation(CollisionBoltons[i].RelLoc * (DrawScale / default.DrawScale));
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
            AttachToBone(CollisionBoltons[i].Bolton, CollisionBoltons[i].BoneName);
        }
    }
}

/** Detaches all the CollisionBoltons for when Mutant Champ is stunned */
function DettachCollisionBoltons() {
    local int i;

    for (i=0;i<CollisionBoltons.length;i++) {
        if (CollisionBoltons[i].Bolton != none) {
            CollisionBoltons[i].Bolton.SetCollision(true, true, true);
            DetachFromBone(CollisionBoltons[i].Bolton);
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

///////////////////////////////////////////////////////////////////////////////
// GetKarmaSkeleton
// Use a lawman ragdoll
///////////////////////////////////////////////////////////////////////////////
function GetKarmaSkeleton()
{
	local P2GameInfo checkg;
	local name skelname;
	local P2Player p2p, cont;
	
	skelname=BITCH_SKEL;

	if(Level.NetMode != NM_DedicatedServer)
	{
		// Go through all the player controllers till you find the one on
		// your computer that has a valid viewport and has your ragdolls
		foreach DynamicActors(class'P2Player', Cont)
		{
			if (ViewPort(Cont.Player) != None)
			{
				p2p = Cont;
				break;
			}
		}
		if(p2p != None
			&& KParams == None)
		{
			KParams = p2p.GetNewRagdollSkel(self, skelname);
		}
	}
}

function bool AllowRagdoll(class<DamageType> DamageType)
{
	return false;
}
simulated function name GetAnimDeathFallForward()
{
	return 'FallDown';
}

/** As a boss, we don't flinch play flinching animations from attacks */
function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> DamageType);

/** Obese Bitch tends to jump around a lot, so get rid of this */
function TakeFallingDamage();

/** Ignore encroachment gibs since we're a very close ranged attack person */
event EncroachedBy(Actor Other);

/** Remove the ability for bullets and melee attacks to impart momentum */
function AddVelocity(vector NewVelocity);

/** Stubbed out the existing movement centered animation code as Obese Bitch
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
}

/** Overriden so we can transition the Controller into the landing state */
event Landed(vector HitNormal) {
    super.Landed(HitNormal);

    SetPhysics(PHYS_Walking);

    if (ObeseBitchController == none)
        return;

    if (ObeseBitchController.IsPerformingLeap())
        ObeseBitchController.GotoState('LeapLand');
}

/** Overriden so we can ignore our own damage */
event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType) {
    // Only accept one damage call per game Tick, used for explosions
    if (!bAcceptDamage || ObeseBitchController == none)
        return;

    // Most important part is ignoring out own damage
    if (ClassIsChildOf(DamageType, class'ObeseBitchMeleeDamage'))
        return;

    bAcceptDamage = false;

    super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
}

/** Cleanup our collision boltons if we're removed from the game */
event Destroyed() {
    super.Destroyed();

	DettachCollisionBoltons();
    DestroyCollisionBoltons();
}

/** Notification to send to our AI Controller */
function NotifyWalkingFootstep() {
    if (ObeseBitchController != none)
        ObeseBitchController.NotifyWalkingFootstep();
}

/** Notification to send to our AI Controller */
function NotifyRunningFootstep() {
    if (ObeseBitchController != none)
        ObeseBitchController.NotifyRunningFootstep();
}

/** Notification to send to our AI Controller */
function NotifyBansheeScream() {
    if (ObeseBitchController != none)
        ObeseBitchController.NotifyBansheeScream();
}

/** Notification to send to our AI Controller */
function NotifyStomp() {
    if (ObeseBitchController != none)
        ObeseBitchController.NotifyStomp();
}

/** Notification to send to our AI Controller */
function NotifyBellyFlop() {
    if (ObeseBitchController != none)
        ObeseBitchController.NotifyBellyFlop();
}

/** Notification to send to our AI Controller */
function NotifyLeapLand() {
    if (ObeseBitchController != none)
        ObeseBitchController.NotifyLeapLand();
}

/** Notification to send to our AI Controller */
function NotifyDashHit() {
    if (ObeseBitchController != none)
        ObeseBitchController.NotifyDashHit();
}

/** Notification to send to our AI Controller */
function NotifyShockwave() {
    if (ObeseBitchController != none)
        ObeseBitchController.NotifyShockwave();
}

/** Notification to send to our AI Controller */
function NotifyRockDrop() {
    if (ObeseBitchController != none)
        ObeseBitchController.NotifyRockDrop();
}

// Same as super but we skip reporting to the stats/game.
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if ( bDeleteMe )
		return; //already destroyed

	// If I'm used for an errand, check to see if I did anything important
	CheckForErrandCompleteOnDeath(Killer);

	// mutator hook to prevent deaths
	// WARNING - don't prevent bot suicides - they suicide when really needed
	if ( Level.Game.PreventDeath(self, Killer, damageType, HitLocation) )
	{
		Health = max(Health, 1); //mutator should set this higher
		return;
	}
	Health = Min(0, Health);

	Level.Game.Killed(Killer, Controller, self, damageType);

	if ( Killer != None )
		TriggerEvent(Event, self, Killer.Pawn);
	else
		TriggerEvent(Event, self, None);

	// This was from the engine. I changed it to a constant at least.
	// It apparently bumps up a person who's moving when they die, to make it
	// a little more dramatic.
	Velocity.Z *= DIE_Z_MULT;

	if ( IsHumanControlled() )
		PlayerController(Controller).ForceDeathUpdate();

	PlayDying(DamageType, HitLocation);

	if ( Level.Game.bGameEnded )
		return;
	if ( !bPhysicsAnimUpdate && !IsLocallyControlled() )
		ClientDying(DamageType, HitLocation);
}

///////////////////////////////////////////////////////////////////////////////
// Living
///////////////////////////////////////////////////////////////////////////////
auto simulated state Living
{
	event Tick(float dT)
	{
		Super.Tick(dT);
		if (SayTime > 0)
			SayTime = FMin(SayTime - dT, 0.f);

		bAcceptDamage = true;
	}
}

defaultproperties
{
	ActorID="ObeseBitch"

    PeacefulTakedownEvent="ObeseBitchTakenDown"
    ViolentTakedownEvent="ObeseBitchTakenDown"

    Mesh=SkeletalMesh'PLCharacters.ObeseBitch'

	Skins[0]=Texture'PLCharacterSkins.ObeseBitch.ObeseBitch_Body'
	Skins[1]=Texture'PLCharacterSkins.ObeseBitch.ObeseBitch_Dress_Clean'
    HeadSkin=texture'PLCharacterSkins.ObeseBitch.ObeseBitch_Head'
	HeadMesh=SkeletalMesh'heads.FatFem'
	HeadScale=(X=1.5,Y=1.5,Z=1.5)
	ADJUST_RELATIVE_HEAD_X=10

	HealthMax=1250

	WalkSpeed=112
    RunSpeed=750

    bBlockZeroExtentTraces=false

    CollisionHeight=106
    CollisionRadius=35

    bIsFemale=true
	bNoDismemberment=true

    ControllerClass=class'ObeseBitchController'

    CoreMeshAnim=MeshAnimation'PLCharacters.animObeseBitch'
    AW_SPMeshAnim=None
	ExtraAnims(0)=None
	ExtraAnims(1)=None
	ExtraAnims(2)=None
	ExtraAnims(3)=None
	ExtraAnims(4)=None
	ExtraAnims(5)=None
	ExtraAnims(6)=None

	CollisionBoltonClass=class'ObeseBitchCollision'

    CollisionBoltons(0)=(DamageMult=2,Scale3D=(X=0.16,Y=0.16,Z=0.12),RelLoc=(X=-13,Y=2,Z=0),RelRot=(Pitch=0,Yaw=0,Roll=0),BoneName="Bip001 HeadNub")

    CollisionBoltons(1)=(DamageMult=0.75,Scale3D=(X=0.12,Y=0.1,Z=0.1),RelLoc=(X=15,Y=-3,Z=0),RelRot=(Pitch=0,Yaw=0,Roll=0),BoneName="Bip001 R UpperArm")
    CollisionBoltons(2)=(DamageMult=0.75,Scale3D=(X=0.12,Y=0.1,Z=0.1),RelLoc=(X=15,Y=-3,Z=0),RelRot=(Pitch=0,Yaw=0,Roll=0),BoneName="Bip001 L UpperArm")

    CollisionBoltons(3)=(DamageMult=0.75,Scale3D=(X=0.12,Y=0.08,Z=0.08),RelLoc=(X=11,Y=0,Z=0),RelRot=(Pitch=0,Yaw=0,Roll=0),BoneName="Bip001 R Forearm")
    CollisionBoltons(4)=(DamageMult=0.75,Scale3D=(X=0.12,Y=0.08,Z=0.08),RelLoc=(X=11,Y=0,Z=0),RelRot=(Pitch=0,Yaw=0,Roll=0),BoneName="Bip001 L Forearm")

    CollisionBoltons(5)=(DamageMult=0.75,Scale3D=(X=0.1,Y=0.04,Z=0.06),RelLoc=(X=10,Y=0,Z=0),RelRot=(Pitch=0,Yaw=0,Roll=0),BoneName="Bip001 R Hand")
    CollisionBoltons(6)=(DamageMult=0.75,Scale3D=(X=0.1,Y=0.04,Z=0.06),RelLoc=(X=10,Y=0,Z=0),RelRot=(Pitch=0,Yaw=0,Roll=0),BoneName="Bip001 L Hand")

    CollisionBoltons(7)=(DamageMult=1,Scale3D=(X=0.1,Y=0.14,Z=0.28),RelLoc=(X=-4,Y=4,Z=0),RelRot=(Pitch=0,Yaw=0,Roll=0),BoneName="Bip001 Neck")
    CollisionBoltons(8)=(DamageMult=1,Scale3D=(X=0.1,Y=0.22,Z=0.23),RelLoc=(X=0,Y=-6,Z=0),RelRot=(Pitch=0,Yaw=0,Roll=0),BoneName="Bip001 Spine2")
    CollisionBoltons(9)=(DamageMult=1,Scale3D=(X=0.1,Y=0.26,Z=0.22),RelLoc=(X=0,Y=-5,Z=0),RelRot=(Pitch=0,Yaw=-2048,Roll=0),BoneName="Bip001 Spine1")
    CollisionBoltons(10)=(DamageMult=1,Scale3D=(X=0.1,Y=0.27,Z=0.29),RelLoc=(X=-6,Y=0,Z=0),RelRot=(Pitch=0,Yaw=0,Roll=0),BoneName="Bip001 Spine")

    CollisionBoltons(11)=(DamageMult=0.75,Scale3D=(X=0.12,Y=0.14,Z=0.14),RelLoc=(X=18,Y=0,Z=0),RelRot=(Pitch=0,Yaw=0,Roll=0),BoneName="Bip001 R Thigh")
    CollisionBoltons(12)=(DamageMult=0.75,Scale3D=(X=0.12,Y=0.14,Z=0.14),RelLoc=(X=18,Y=0,Z=0),RelRot=(Pitch=0,Yaw=0,Roll=0),BoneName="Bip001 L Thigh")

    CollisionBoltons(13)=(DamageMult=0.75,Scale3D=(X=0.16,Y=0.1,Z=0.1),RelLoc=(X=13,Y=3,Z=0),RelRot=(Pitch=0,Yaw=0,Roll=0),BoneName="Bip001 R Calf")
    CollisionBoltons(14)=(DamageMult=0.75,Scale3D=(X=0.16,Y=0.1,Z=0.1),RelLoc=(X=13,Y=3,Z=0),RelRot=(Pitch=0,Yaw=0,Roll=0),BoneName="Bip001 L Calf")

    CollisionBoltons(15)=(DamageMult=0.75,Scale3D=(X=0.16,Y=0.08,Z=0.06),RelLoc=(X=12,Y=-7,Z=0),RelRot=(Pitch=0,Yaw=-8192,Roll=0),BoneName="Bip001 R Foot")
    CollisionBoltons(16)=(DamageMult=0.75,Scale3D=(X=0.16,Y=0.08,Z=0.06),RelLoc=(X=12,Y=-7,Z=0),RelRot=(Pitch=0,Yaw=-8192,Roll=0),BoneName="Bip001 L Foot")

	TransientSoundVolume=255
	TransientSoundRadius=400
	DialogButtStomp[0]=Sound'PL-Dialog2.FridayShowdownBitchBoss.TheBitch-1CrushYourSkinnyAss'
	DialogButtStomp[1]=Sound'PL-Dialog2.FridayShowdownBitchBoss.TheBitch-1IllBreakYouInHalf'
	DialogBellyFlop[0]=Sound'PL-Dialog2.FridayShowdownBitchBoss.TheBitch-1CrushYourSkinnyAss'
	DialogBellyFlop[1]=Sound'PL-Dialog2.FridayShowdownBitchBoss.TheBitch-1GetOverHere'
	DialogBellyFlop[2]=Sound'PL-Dialog2.FridayShowdownBitchBoss.TheBitch-1YouCantRun'
	DialogLeap[0]=Sound'PL-Dialog2.FridayShowdownBitchBoss.TheBitch-1GetOverHere'
	DialogLeap[1]=Sound'PL-Dialog2.FridayShowdownBitchBoss.TheBitch-1YouBastard'
	DialogLeap[2]=Sound'PL-Dialog2.FridayShowdownBitchBoss.TheBitch-1YouCantRun'
	DialogDash[0]=Sound'PL-Dialog2.FridayShowdownBitchBoss.TheBitch-1GetOverHere'
	DialogDash[1]=Sound'PL-Dialog2.FridayShowdownBitchBoss.TheBitch-1ImGoingToFixYou'
	DialogDash[2]=Sound'PL-Dialog2.FridayShowdownBitchBoss.TheBitch-1YouCantRun'	
	AmbientGlow=30
	bCellUser=false
}