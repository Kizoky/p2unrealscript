/**
 * ZackWard
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * What, are you gonna cry now? Come on crybaby, cry. Come on, cry!
 *
 * @author Gordon Cheng
 */
class ZackWard extends PLBossPawn
    placeable;

/** Grenade bolton stuff */
var name GrenadeBoltonBone;

var vector GrenadeRelativeLocation;
var rotator GrenadeRelativeRotation;
var StaticMesh GrenadeStaticMesh;

var vector MolotovRelativeLocation;
var rotator MolotovRelativeRotation;
var StaticMesh MolotovStaticMesh;

/** Grenade throw sounds */
var sound GrenadePinPullSound, GrenadeThrowSound;
var sound MolotovLightSound, MolotovThrowSound;

/** Various object we should keep track of */
var BoltonPart GrenadeBolton;
var Weapon LeftWeapon;
var ZackWardController ZackWardController;

/** Stores a reference to the default head mesh, so we know this is the "screwy" head mesh that has to set Skins[1] instead of Skins[0] */
var SkeletalMesh DudeHeadMesh;
var Material AlphaSkin;

var(PawnAttributes) string LieberModeWeapon;				// Weapon we should get in lieber mode

function SetOnFire(FPSPawn Doer, optional bool bIsNapalm);

/**
 * Remove the turning animations to ensure third person animations are not
 * interrupted by them
 */
simulated function SetAnimWalking() {

    super.SetAnimWalking();

    TurnLeftAnim = '';
    TurnRightAnim = '';
}

/**
 * Remove the turning animations to ensure third person animations are not
 * interrupted by them
 */
simulated function SetAnimRunning() {

    super.SetAnimRunning();

    TurnLeftAnim = '';
    TurnRightAnim = '';
}

/** Play the pin pull sound to announce we're throwing a grenade */
function PlayGrenadePinPullSound() {

    if (GrenadePinPullSound != none)
        PlaySound(GrenadePinPullSound, SLOT_Misc, 1, false, 300);
}

/** Play the grenade throwing sound */
function PlayGrenadeThrowSound() {

    if (GrenadeThrowSound != none)
        PlaySound(GrenadeThrowSound, SLOT_Misc, 1, false, 300);
}

/** Play the lighting sound to announce we're throwing a molotov */
function PlayMolotovLightSound() {

    if (MolotovLightSound != none)
        PlaySound(MolotovLightSound, SLOT_Misc, 1, false, 300);
}

/** Play the molotov throwing sound */
function PlayMolotovThrowSound() {

    if (MolotovThrowSound != none)
        PlaySound(MolotovThrowSound, SLOT_Misc, 1, false, 300);
}

/** Attaches a grenade onto Zack Ward's left hand */
function AttachGrenadeBolton() {

    if (GrenadeBoltonBone != '' && GrenadeBoltonBone != 'None' &&
        GrenadeStaticMesh != none) {

        GrenadeBolton = Spawn(class'BoltonPart');

        if (GrenadeBolton != none) {

            GrenadeBolton.SetDrawType(DT_StaticMesh);
            GrenadeBolton.SetStaticMesh(GrenadeStaticMesh);

            GrenadeBolton.SetRelativeRotation(GrenadeRelativeRotation);
		    GrenadeBolton.SetRelativeLocation(GrenadeRelativeLocation);

		    AttachToBone(GrenadeBolton, GrenadeBoltonBone);
        }
    }
}

/** Attaches a molotov onto Zack Ward's left hand */
function AttachMolotovBolton() {

    if (GrenadeBoltonBone != '' && GrenadeBoltonBone != 'None' &&
        MolotovStaticMesh != none) {

        GrenadeBolton = Spawn(class'BoltonPart');

        if (GrenadeBolton != none) {

            GrenadeBolton.SetDrawType(DT_StaticMesh);
            GrenadeBolton.SetStaticMesh(MolotovStaticMesh);

            GrenadeBolton.SetRelativeRotation(MolotovRelativeRotation);
		    GrenadeBolton.SetRelativeLocation(MolotovRelativeLocation);

		    AttachToBone(GrenadeBolton, GrenadeBoltonBone);
        }
    }
}

/** Detaches a grenade from Zack Ward's left hand */
function DetachGrenadeBolton() {

    if (GrenadeBolton != none) {

        GrenadeBolton.Destroy();
        GrenadeBolton = none;
    }
}

/** Animation notify that we should reattach our left weapon attachment */
function NotifyAttachLeftWeapon() {

    if (LeftWeapon != none)
        LeftWeapon.AttachToPawn(self);
}

/** Animation notify that we should detach our left weapon attachment */
function NotifyDetachLeftWeapon() {

    if (LeftWeapon != none)
        LeftWeapon.DetachFromPawn(self);
}

/**
 * Pass out animation notify to our Controller as it keeps track of whether
 * we should throw a grenade or throw
 */
function NotifyAttachGrenade() {

    if (ZackWardController != none)
        ZackWardController.NotifyAttachGrenade();
}

/**
 * Pass on out animation notify over to our AI Controller as it keeps track
 * enemies and stuff like that
 */
function NotifyQuickThrowGrenade() {

    if (ZackWardController != none && GrenadeBolton != none)
        ZackWardController.NotifyQuickThrowGrenade();

    DetachGrenadeBolton();
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation,
                    vector Momentum, class<DamageType> DamageType) {

    local Pickup LeftWeaponPickup;
    local rotator LeftWeaponRotation;

    super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);

    if (Health <= 0 && LeftWeapon != none) {
        LeftWeapon.DetachFromPawn(self);

        if (BaseEquipment[0].WeaponClass != none)
            LeftWeaponPickup = Spawn(BaseEquipment[0].WeaponClass.default.PickupClass);

        if (LeftWeaponPickup != none) {

            LeftWeaponPickup.SetPhysics(PHYS_Falling);

            LeftWeaponPickup.Velocity = VRand() * 512;
            LeftWeaponPickup.Velocity.Z = Abs(LeftWeaponPickup.Velocity.Z);

            LeftWeaponRotation.Yaw = int(FRand() * 65535.0);

            LeftWeaponPickup.SetRotation(LeftWeaponRotation);
        }
    }
}

// Zack has his own head now, so this stuff is no longer needed - K
/*
///////////////////////////////////////////////////////////////////////////////
// Switch to this new mesh
// Zack Ward uses the new Dude head which is not compatible with the usual
// method of setting head skins etc.
///////////////////////////////////////////////////////////////////////////////
function SwitchToNewMesh(Mesh NewMesh, 
						 Material NewSkin,
						 Mesh NewHeadMesh, 
						 Material NewHeadSkin,
						 optional Mesh NewCoreMesh)
{
	// Setup body (true means "keep anim state")
	SetMyMesh(NewMesh, NewCoreMesh, true);
	SetMySkin(NewSkin);
	LinkAnims();
	PlayWaiting();

	// Setup head
	MyHead.LinkMesh(NewHeadMesh, true);
	if (NewHeadMesh == DudeHeadMesh)
		MyHead.Skins[1] = NewHeadSkin;
	else
		MyHead.Skins[0] = NewHeadSkin;
}

///////////////////////////////////////////////////////////////////////////////
// Setup head
///////////////////////////////////////////////////////////////////////////////
function SetupHead()
{
	Super.SetupHead();
	if (MyHead.Mesh == DudeHeadMesh)
	{
		MyHead.Skins[0] = AlphaSkin;
		MyHead.Skins[1] = Headskin;
		MyHead.Skins[2] = AlphaSkin;
	}
}
*/

///////////////////////////////////////////////////////////////////////////////
// Adds all the required equipment and picks out the urethra.
// Do this here so we access to the inventory package for specific things
// like HandsWeapon and UrethraWeapon.
///////////////////////////////////////////////////////////////////////////////
function AddDefaultInventory()
{
	local bool bGotDefault;
	
	bGotDefault = bGotDefaultInventory;
	Super.AddDefaultInventory();	
	
	// Only let this be called once
	if (!bGotDefault)
	{
		// In liebermode, change us out to a regular bystander controller and give us a shovel to fight the Dude with.
		if (P2GameInfo(Level.Game).InLieberMode())
		{
			CreateInventory(LieberModeWeapon);
			PawnInitialState = EP_AttackPlayer;
			Controller.ClientSetWeapon(class'HandsWeapon');
			Controller.Destroy();
			Controller = None;
			Controller = spawn(class'BystanderController');
			// Apparently the controller automatically checks the AI script here
			/*
			if(Controller != None )
			{
				Controller.Possess(self);
				AIController(Controller).Skill += SkillModifier;
				CheckForAIScript();
			}
			*/
		}
	}
	Controller.ClientSetWeapon(class'HandsWeapon');
}

defaultproperties
{
	ActorID="ZackWard"

    GrenadeBoltonBone="MALE01 l hand"

    GrenadeRelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	GrenadeRelativeLocation=(X=0,Y=1,Z=-0.3)
    GrenadeStaticMesh=StaticMesh'TP_Weapons.Grenade3'

    MolotovRelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	MolotovRelativeLocation=(X=0,Y=1,Z=-0.3)
    MolotovStaticMesh=StaticMesh'TP_Weapons.Molotov3'

    GrenadePinPullSound=sound'WeaponSounds.grenade_pullpin'
    GrenadeThrowSound=sound'WeaponSounds.grenade_fire'

    MolotovLightSound=sound'WeaponSounds.molotov_lightstart'
    MolotovThrowSound=sound'WeaponSounds.molotov_fire'

    Mesh=SkeletalMesh'Characters.Avg_M_Jacket_Pants'

	Skins(0)=Texture'PLCharacterSkins.ZackWard.Zack_Body'
	Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'PLCharacterMeshes.ZackWard.crockett_avgmale',Skin=Texture'PLCharacterSkins.ZackWard.fur_hat',bAttachToHead=True)

	HeadSkin=Texture'PLCharacterSkins.ZackWard.Zack_Head'
    HeadMesh=SkeletalMesh'PLHeads.Head_Zack'
	DudeHeadMesh=SkeletalMesh'MoreHeads.AW_Dude'
	AlphaSkin=Texture'AW_Characters.Special.Alphatex'

	ExtraAnims(2)=MeshAnimation'PLCharacters.animZackIntro'
	ExtraAnims(10)=MeshAnimation'PLCharacters.animZackWard'

	BaseEquipment(0)=(WeaponClass=class'MachinegunWeapon')

    ControllerClass=class'ZackWardController'

	HealthMax=2000

    Gang="Farcii"
	AmbientGlow=30
	bCellUser=false
	// Pawn properties for the liebermode bystander version.
	// ZackWardController handles behavior for normal boss version
	LieberModeWeapon="Inventory.ShovelWeapon"
	DialogClass=class'DialogZackWard'
	Psychic=1.0
	Champ=1.0
	Cajones=1.0
	Temper=1.0
	Compassion=0.0
	Beg=0.0
	PainThreshold=1.0
	Rebel=1.0
	Confidence=1.0
	TalkWhileFighting=1.0
	Stomach=1.0
	WillDodge=0.85
	WillUseCover=0.0
	WillKneel=0.5
}