/**
 * BoltonEditor
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * Basically an in game development tool designed to make adjusting and fine
 * tuning boltons in game much much easier as you can type in which aspect of
 * of the bolton you want to modify and use the mousewheel to adjust it
 *
 * @author Gordon Cheng
 */
class BoltonEditor extends P2Weapon;

/** Various properties that we can adjust about a bolton in terms of form */
enum EProperty {
    PROP_DRAWSCALE_X,
    PROP_DRAWSCALE_Y,
    PROP_DRAWSCALE_Z,

    PROP_RELATIVE_LOCATION_X,
    PROP_RELATIVE_LOCATION_Y,
    PROP_RELATIVE_LOCATION_Z,

    PROP_RELATIVE_ROTATION_PITCH,
    PROP_RELATIVE_ROTATION_YAW,
    PROP_RELATIVE_ROTATION_ROLL,
};

var float DrawScaleStep, RelativeLocationStep, RelativeRotationStep;

var texture DefaultTexture, SelectedTexture;

var EProperty CurrentProperty;

var Font DebugFont;

var Actor Bolton;

/** Short hand executable function names for switching property modes */
exec function dx() {
    CurrentProperty = PROP_DRAWSCALE_X;
}

exec function dy() {
    CurrentProperty = PROP_DRAWSCALE_Y;
}

exec function dz() {
    CurrentProperty = PROP_DRAWSCALE_Z;
}

exec function rlx() {
    CurrentProperty = PROP_RELATIVE_LOCATION_X;
}

exec function rly() {
    CurrentProperty = PROP_RELATIVE_LOCATION_Y;
}

exec function rlz() {
    CurrentProperty = PROP_RELATIVE_LOCATION_Z;
}

exec function rrp() {
     CurrentProperty = PROP_RELATIVE_ROTATION_PITCH;
}

exec function rry() {
     CurrentProperty = PROP_RELATIVE_ROTATION_YAW;
}

exec function rrr() {
     CurrentProperty = PROP_RELATIVE_ROTATION_ROLL;
}

/** Returns the current property being edited in the form of a string for rendering */
function string GetPropertyMode() {
    switch (CurrentProperty) {
        case PROP_DRAWSCALE_X:
            return "PROP_DRAWSCALE_X";

        case PROP_DRAWSCALE_Y:
            return "PROP_DRAWSCALE_Y";

        case PROP_DRAWSCALE_Z:
            return "PROP_DRAWSCALE_Z";

        case PROP_RELATIVE_LOCATION_X:
            return "PROP_RELATIVE_LOCATION_X";

        case PROP_RELATIVE_LOCATION_Y:
            return "PROP_RELATIVE_LOCATION_Y";

        case PROP_RELATIVE_LOCATION_Z:
            return "PROP_RELATIVE_LOCATION_Z";

        case PROP_RELATIVE_ROTATION_PITCH:
            return "PROP_RELATIVE_ROTATION_PITCH";

        case PROP_RELATIVE_ROTATION_YAW:
            return "PROP_RELATIVE_ROTATION_YAW";

        case PROP_RELATIVE_ROTATION_ROLL:
            return "PROP_RELATIVE_ROTATION_ROLL";
    }
}

/** Overriden so the developer can use the mouse wheel for adjustments */
simulated function bool AllowNextWeapon() {
    return false;
}

/** Overriden so the developer can use the mouse wheel for adjustments */
simulated function bool AllowPrevWeapon() {
    return false;
}

/** Overriden we can the variable upwards by a certain increment */
simulated function ZoomIn() {
    local vector VectProperty;
    local rotator RotProperty;

    if (Bolton == none)
        return;

    switch (CurrentProperty) {
        case PROP_DRAWSCALE_X:
            VectProperty = Bolton.DrawScale3D;
            VectProperty.X += DrawScaleStep;
            Bolton.SetDrawScale3D(VectProperty);
            break;

        case PROP_DRAWSCALE_Y:
            VectProperty = Bolton.DrawScale3D;
            VectProperty.Y += DrawScaleStep;
            Bolton.SetDrawScale3D(VectProperty);
            break;

        case PROP_DRAWSCALE_Z:
            VectProperty = Bolton.DrawScale3D;
            VectProperty.Z += DrawScaleStep;
            Bolton.SetDrawScale3D(VectProperty);
            break;

        case PROP_RELATIVE_LOCATION_X:
            VectProperty = Bolton.RelativeLocation;
            VectProperty.X += RelativeLocationStep;
            Bolton.SetRelativeLocation(VectProperty);
            break;

        case PROP_RELATIVE_LOCATION_Y:
            VectProperty = Bolton.RelativeLocation;
            VectProperty.Y += RelativeLocationStep;
            Bolton.SetRelativeLocation(VectProperty);
            break;

        case PROP_RELATIVE_LOCATION_Z:
            VectProperty = Bolton.RelativeLocation;
            VectProperty.Z += RelativeLocationStep;
            Bolton.SetRelativeLocation(VectProperty);
            break;

        case PROP_RELATIVE_ROTATION_PITCH:
            RotProperty = Bolton.RelativeRotation;
            RotProperty.Pitch += RelativeRotationStep;
            Bolton.SetRelativeRotation(RotProperty);
            break;

        case PROP_RELATIVE_ROTATION_YAW:
            RotProperty = Bolton.RelativeRotation;
            RotProperty.Yaw += RelativeRotationStep;
            Bolton.SetRelativeRotation(RotProperty);
            break;

        case PROP_RELATIVE_ROTATION_ROLL:
            RotProperty = Bolton.RelativeRotation;
            RotProperty.Roll += RelativeRotationStep;
            Bolton.SetRelativeRotation(RotProperty);
            break;
    }
}

/** Overriden we can the variable upwards by a certain decrement */
simulated function ZoomOut() {
    local vector VectProperty;
    local rotator RotProperty;

    if (Bolton == none)
        return;

    switch (CurrentProperty) {
        case PROP_DRAWSCALE_X:
            VectProperty = Bolton.DrawScale3D;
            VectProperty.X -= DrawScaleStep;
            Bolton.SetDrawScale3D(VectProperty);
            break;

        case PROP_DRAWSCALE_Y:
            VectProperty = Bolton.DrawScale3D;
            VectProperty.Y -= DrawScaleStep;
            Bolton.SetDrawScale3D(VectProperty);
            break;

        case PROP_DRAWSCALE_Z:
            VectProperty = Bolton.DrawScale3D;
            VectProperty.Z -= DrawScaleStep;
            Bolton.SetDrawScale3D(VectProperty);
            break;

        case PROP_RELATIVE_LOCATION_X:
            VectProperty = Bolton.RelativeLocation;
            VectProperty.X -= RelativeLocationStep;
            Bolton.SetRelativeLocation(VectProperty);
            break;

        case PROP_RELATIVE_LOCATION_Y:
            VectProperty = Bolton.RelativeLocation;
            VectProperty.Y -= RelativeLocationStep;
            Bolton.SetRelativeLocation(VectProperty);
            break;

        case PROP_RELATIVE_LOCATION_Z:
            VectProperty = Bolton.RelativeLocation;
            VectProperty.Z -= RelativeLocationStep;
            Bolton.SetRelativeLocation(VectProperty);
            break;

        case PROP_RELATIVE_ROTATION_PITCH:
            RotProperty = Bolton.RelativeRotation;
            RotProperty.Pitch -= RelativeRotationStep;
            Bolton.SetRelativeRotation(RotProperty);
            break;

        case PROP_RELATIVE_ROTATION_YAW:
            RotProperty = Bolton.RelativeRotation;
            RotProperty.Yaw -= RelativeRotationStep;
            Bolton.SetRelativeRotation(RotProperty);
            break;

        case PROP_RELATIVE_ROTATION_ROLL:
            RotProperty = Bolton.RelativeRotation;
            RotProperty.Roll -= RelativeRotationStep;
            Bolton.SetRelativeRotation(RotProperty);
            break;
    }
}

/** Overriden so we can perform a basic trace to find an Actor, any Actor */
simulated function Fire(float F) {
    local vector HitLocation, HitNormal, EndTrace, StartTrace;

    if (Bolton != none && Bolton.Skins.length > 0 && DefaultTexture != none)
        Bolton.Skins[0] = DefaultTexture;

    StartTrace = Instigator.Location + Instigator.EyePosition();
    EndTrace = StartTrace + TraceDist * vector(Instigator.GetViewRotation());
    Bolton = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

    if (Bolton != none && Bolton.Skins.length > 0 && SelectedTexture != none)
        Bolton.Skins[0] = SelectedTexture;
}

/** Overriden so we can clear our current bolton for whatever reason */
simulated function AltFire(float F) {
    if (Bolton != none && Bolton.Skins.length > 0 && DefaultTexture != none)
        Bolton.Skins[0] = DefaultTexture;

    Bolton = none;
}

/** Overriden we can display debug information */
simulated event RenderOverlays(Canvas Canvas) {
    local int i, offset;

    super.RenderOverlays(Canvas);

    Canvas.Style = 1;
    Canvas.Font = DebugFont;
    Canvas.SetDrawColor(255, 200, 145, 255);

    Canvas.SetPos(20, 20 + 20 * offset);
    Canvas.DrawText("CurrentProperty: " $ GetPropertyMode());
    offset++;
    offset++;

    Canvas.SetPos(20, 20 + 20 * offset);
    Canvas.DrawText("Bolton: " $ Bolton);
    offset++;
    offset++;

    if (Bolton != none) {
        Canvas.SetPos(20, 20 + 20 * offset);
        Canvas.DrawText("AttachmentBone: " $ Bolton.AttachmentBone);
        offset++;
        offset++;

        Canvas.SetPos(20, 20 + 20 * offset);
        Canvas.DrawText("DrawScale3D: ");
        offset++;

        Canvas.SetPos(20, 20 + 20 * offset);
        Canvas.DrawText("    X: " $ Bolton.DrawScale3D.X);
        offset++;

        Canvas.SetPos(20, 20 + 20 * offset);
        Canvas.DrawText("    Y: " $ Bolton.DrawScale3D.Y);
        offset++;

        Canvas.SetPos(20, 20 + 20 * offset);
        Canvas.DrawText("    Z: " $ Bolton.DrawScale3D.Z);
        offset++;
        offset++;

        Canvas.SetPos(20, 20 + 20 * offset);
        Canvas.DrawText("RelativeLocation: ");
        offset++;

        Canvas.SetPos(20, 20 + 20 * offset);
        Canvas.DrawText("    X: " $ Bolton.RelativeLocation.X);
        offset++;

        Canvas.SetPos(20, 20 + 20 * offset);
        Canvas.DrawText("    Y: " $ Bolton.RelativeLocation.Y);
        offset++;

        Canvas.SetPos(20, 20 + 20 * offset);
        Canvas.DrawText("    Z: " $ Bolton.RelativeLocation.Z);
        offset++;
        offset++;

        Canvas.SetPos(20, 20 + 20 * offset);
        Canvas.DrawText("RelativeRotation: ");
        offset++;

        Canvas.SetPos(20, 20 + 20 * offset);
        Canvas.DrawText("    Pitch: " $ Bolton.RelativeRotation.Pitch);
        offset++;

        Canvas.SetPos(20, 20 + 20 * offset);
        Canvas.DrawText("    Yaw: " $ Bolton.RelativeRotation.Yaw);
        offset++;

        Canvas.SetPos(20, 20 + 20 * offset);
        Canvas.DrawText("    Roll: " $ Bolton.RelativeRotation.Roll);
        offset++;
        offset++;
    }
}

defaultproperties
{
    DebugFont=Font'P2Fonts.Fancy24'

    DrawScaleStep=0.01
    RelativeLocationStep=1
    RelativeRotationStep=256

    CurrentProperty=PROP_DRAWSCALE_X

    DefaultTexture=texture'PL-KamekTex.derp.ColAlphaTex'
    SelectedTexture=texture'PL-KamekTex.derp.ColAlphaTexActive'

    bNoHudReticle=false
	bUsesAltFire=true

	ItemName="BoltonEditor"
	AmmoName=class'ClipboardAmmoInv'
	PickupClass=class'BoltonEditorPickup'
	AttachmentClass=class'ClipboardAttachment'

	bCanThrow=false

	Mesh=Mesh'MP_Weapons.MP_LS_Clipboard'
	Skins(0)=texture'MP_FPArms.LS_arms.LS_hands_dude'
	Skins(1)=texture'WeaponSkins.clipboard_timb'
	Skins(2)=texture'Timb.Misc.Invisible_timb'
	Skins(3)=texture'Timb.Misc.Invisible_timb'
	Skins(4)=texture'Timb.Misc.Invisible_timb'

	FirstPersonMeshSuffix="Clipboard"

    bDrawMuzzleFlash=false

    PlayerViewOffset=(X=5,Y=0,Z=-17)

	ShakeOffsetMag=(X=0,Y=0,Z=0)
	ShakeOffsetRate=(X=0,Y=0,Z=0)
	ShakeOffsetTime=0
	ShakeRotMag=(X=0,Y=0,Z=0)
	ShakeRotRate=(X=0,Y=0,Z=0)
	ShakeRotTime=0

	CombatRating=0.6
	AIRating=0
	AutoSwitchPriority=1
	InventoryGroup=1
	GroupOffset=10
	BobDamping=0.975
	ReloadCount=0
	TraceAccuracy=0
	ViolenceRank=0

	bBumpStartsFight=false
	bArrestableWeapon=true

	WeaponSpeedHolster=2
	WeaponSpeedLoad=2
	WeaponSpeedReload=1
	WeaponSpeedShoot1=0.7
	WeaponSpeedShoot1Rand=0
	WeaponSpeedShoot2=1
	AimError=0

	TraceDist=10000

	bAllowHints=false
	bShowHints=false

	holdstyle=WEAPONHOLDSTYLE_Toss
	switchstyle=WEAPONHOLDSTYLE_Single
	firingstyle=WEAPONHOLDSTYLE_Single

	ThirdPersonRelativeLocation=(X=6,Z=5)
	ThirdPersonRelativeRotation=(Yaw=-1600,Roll=-16384)
}