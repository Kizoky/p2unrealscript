/**
 * PartnerRadioWeapon
 *
 * A specialized radio "weapon" which you can use to issue commands to your
 * partner. Commands such as follow, stay, attack that guy, etc.
 */
class PartnerRadioWeapon extends P2Weapon;

/** Struct declaring a basic 2d vector */
struct vector2d {
    /** X and Y values for the 2d vector */
    var float X, Y;
};

/** A command consisting of it's label and action */
struct Command {
    /** Name of the command */
    var string Label;
    /** Command type */
    var PartnerController.ECommand CommandType;
};

/** Struct containing basic rendering information */
struct RenderingInfo {
    /** Drawing position on the HUD in terms of percentage */
    var vector2d Pos;
    /** X and Y drawing scale for rendering both textures and text */
    var vector2d Scale;
    /** Dimensions of the texture being drawn */
    var vector2d Dimensions;
};

//-----------------------------------------------------------------------------
// Command Menu Variables

/** Currently selected command in the menu */
var int CommandMenuIndex;

/** Current command selected by the player */
var PartnerController.ECommand CurrentCommand;
/** List of commands the player can choose */
var array<Command> CommandList;

/** Texture to use for rendering the command menu box */
var texture CommandMenuBox;
/** Information reguarding the rendering of the CommandMenuBox */
var RenderingInfo CommandMenuRendering;
/** Information reguarding the rendering of the CommandMenuBox when an item has been selected */
var RenderingInfo SelectedMenuRendering;

/** How much the next item on the list is below the one on top of it */
var float CommandMenuItemPosOffset;
/** Font used for rendering the individual command menu items */
var Font CommandMenuItemFont;
/** Information reguarding the rendering of the Command Menu items */
var RenderingInfo CommandMenuItemRendering;

//-----------------------------------------------------------------------------
// General Gameplay Variables

/** How much the game slows down when the command list is in use */
var float ActiveTimeFactor;

/** Time in seconds since the level has started */
var float PartnerSpawnCurTime;
/** Time in seconds before your Partner spawns */
var float PartnerSpawnDelay;
/** Minimum distance away from the player a PathNode needs to be to Spawn your partner */
var float PartnerSpawnRadius;
/** Spawn offset from the owner's location if a suitable PathNode is not found */
var vector PartnerSpawnOffset;
/** Spawn class for your Partner */
var travel class<PartnerPawn> PartnerClass;

//-----------------------------------------------------------------------------
// Partner Variables

/** Our trusted partner pawn */
var PartnerPawn Partner;
/** Our trusted partner pawn's AI controller */
var PartnerController PartnerController;

/** Whether or not your partner has picked up a Pistol */
var travel bool bHasPistol;
/** Whether or not your partner has picked up a Shotgun */
var travel bool bHasShotgun;
/** Whether or not your partner has picked up a Machine Gun */
var travel bool bHasMachineGun;
/** Whether or not your partner has picked up a Sniper Rifle */
var travel bool bHasSniperRifle;

//-----------------------------------------------------------------------------
// Miscellaneous Variables

/** Name of the bone to attach the radio to */
var name RadioBoltonBone;
/** Actor that's bolted on in place of the grenade */
var Actor RadioBoltOn;

//-----------------------------------------------------------------------------
// Debug Variables

/** TRUE if we should display various AI variables; FALSE won't render anything */
var bool bShowAIDebugInfo;
/** Base position and scale for all the debug text */
var RenderingInfo DebugTextRendering;

// Say we're always zoomed, so we suppress PrevWeapon/NextWeapon/WeaponSelector
simulated function bool IsZoomed()
{
	return true;
}

/** Subclassed to reset the */
simulated function PostBeginPlay() {
    super.PostBeginPlay();

    PartnerSpawnCurTime = 0.0f;
    SetBoneScale(0, 0.0f, 'MESH_Grenade');

    RadioBoltOn = Spawn(class'PartnerRadioBoltOn');

    if (RadioBoltOn != none)
        AttachToBone(RadioBoltOn, RadioBoltonBone);

    //if (P2Pawn(Owner) != none) {
    //    P2Pawn(Owner).Health = 100.0f;
    //    P2Pawn(Owner).HealthMax = 100.0f;
    //    P2Pawn(Owner).TakesMachinegunDamage = 1.0f;
    //}
}

function Destroyed()
{
	if (RadioBoltOn != None)
	{
		RadioBoltOn.Destroy();
		RadioBoltOn = None;
	}
	
	Super.Destroyed();
}

/** Returns a suitable location for spawning the partner pawn
 * @return World location where the partner should spawn
 */
function vector GetPartnerSpawnLocation() {
    local int ClosestIndex, i;
    local float ClosestDistance;
    local PathNode SpawnNode;
    local array<PathNode> SpawnNodeList;

    local vector HitLocation, HitNormal, EndTrace, StartTrace;
    local Actor Other;

    foreach AllActors(class'PathNode', SpawnNode) {
        if (SpawnNode != none) {
            SpawnNodeList.Insert(SpawnNodeList.length, 1);
            SpawnNodeList[SpawnNodeList.length-1] = SpawnNode;
        }
    }

    if (SpawnNodeList.length == 0)
        return Owner.Location + GetOffset(Owner.Rotation, PartnerSpawnOffset);

    ClosestIndex = 0;
    ClosestDistance = VSize(SpawnNodeList[0].Location - Owner.Location);

    for (i=1;i<SpawnNodeList.length;i++) {
        if (VSize(SpawnNodeList[i].Location - Owner.Location) < ClosestDistance &&
            VSize(SpawnNodeList[i].Location - Owner.Location) > PartnerSpawnRadius) {
            ClosestIndex = i;
            ClosestDistance = VSize(SpawnNodeList[i].Location - Owner.Location);
        }
    }

    StartTrace = SpawnNodeList[ClosestIndex].Location;
    EndTrace = StartTrace + vect(0,0,-1024);
    Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

    if (Other != none) {
        HitLocation.Z += 72.0f;
        return HitLocation;
    }
    else
        return StartTrace;
}

/** Function spawns the partner pawn using the given location
 * @param SpawnLocation - World location where the Partner pawn should spawn
 */
function SpawnPartner(vector SpawnLocation) {
    Partner = Spawn(PartnerClass,,, SpawnLocation);

    if (Partner != none) {
        PartnerController = PartnerController(Spawn(Partner.ControllerClass));

        if (PartnerController != none) {
            PartnerController.Possess(Partner);
            PartnerController.Player = Pawn(Owner);
            PartnerController.PlayerController = Pawn(Owner).Controller;
            PartnerController.PlayerRadio = self;
        }

        if (bHasPistol)
            Partner.CreateInventoryByClass(class'PistolWeapon');

        if (bHasShotgun)
            Partner.CreateInventoryByClass(class'ShotgunWeapon');

        if (bHasMachineGun)
            Partner.CreateInventoryByClass(class'MachineGunWeapon');

        if (bHasSniperRifle)
            Partner.CreateInventoryByClass(class'RifleWeapon');
    }

    Partner.SetPhysics(PHYS_Falling);

    // Make your partner follow by default
    CurrentCommand = CM_Follow;
    MakeCommand();

    // Make your partner holster his weapon by default
    CurrentCommand = CM_HolsterWeapon;
    MakeCommand();
}

/** Returns a vector representing the offset using the given direction
 * @param Dir - rotation to base the offset calculation off of
 * @param Offset - offset values in the form of a vector
 * @return Location offset
 */
function vector GetOffset(rotator Dir, vector Offset) {
    local vector X, Y, Z;

    GetAxes(Dir, X, Y, Z);

    return X*Offset.X + Y*Offset.Y + Z*Offset.Z;
}

/** Subclassed to create a slomo effect while the player the player is
 * navigating the command menu to decide what to do. We don't want to rush
 * the player into make a decision especially while under gun fire
 */
simulated function BringUp() {
    super.BringUp();

    /*
    if (P2GameInfoSingle(Level.Game) != none)
        P2GameInfoSingle(Level.Game).SetGameSpeedNoSave(ActiveTimeFactor);

    if (Pawn(Owner) != none)
        Pawn(Owner).GroundSpeed *= ActiveTimeFactor;
    */
}

/** Subclassed to undo the slomo effect */
simulated function TweenDown() {
    super.TweenDown();

    /*
    if (P2GameInfoSingle(Level.Game) != none)
        P2GameInfoSingle(Level.Game).SetGameSpeedNoSave(1.0f);

    if (Pawn(Owner) != none)
        Pawn(Owner).GroundSpeed = Pawn(Owner).default.GroundSpeed;
    */
}

/** Subclassed to implement a command interface for the player */
simulated event RenderOverlays(Canvas Canvas) {
    super.RenderOverlays(Canvas);

    if (CurrentCommand == CM_None)
        RenderCommandList(Canvas);
    else
        RenderCurrentCommand(Canvas);

    if (bShowAIDebugInfo)
        RenderDebug(Canvas);
}

/** Renders the entire command list
 * @param Canvas - Canvas object to be used for rendering
 */
simulated function RenderCommandList(Canvas Canvas) {
    local int i;
    local vector2d CanvasScale, OrigFontScale;
    local vector2d MenuBoxPos, MenuItemPos;

    Canvas.Style = 1;
    Canvas.SetDrawColor(255, 255, 255, 255);

    CanvasScale.X = Canvas.ClipX / 1024;
    CanvasScale.Y = Canvas.ClipY / 768;

    if (CommandMenuBox != none) {
        MenuBoxPos.X = Canvas.ClipX * CommandMenuRendering.Pos.X;
        MenuBoxPos.Y = Canvas.ClipY * CommandMenuRendering.Pos.Y;

        Canvas.SetPos(MenuBoxPos.X, MenuBoxPos.Y);
        Canvas.DrawTile(CommandMenuBox, CommandMenuBox.USize*CanvasScale.Y*CommandMenuRendering.Scale.X,
                        CommandMenuBox.VSize*CanvasScale.Y*CommandMenuRendering.Scale.Y, 0, 0,
                        CommandMenuBox.USize, CommandMenuBox.VSize);
    }

    Canvas.Font = CommandMenuItemFont;

    OrigFontScale.X = Canvas.FontScaleX;
    OrigFontScale.Y = Canvas.FontScaleY;

    Canvas.FontScaleX = CommandMenuItemRendering.Scale.X * CanvasScale.Y;
    Canvas.FontScaleY = CommandMenuItemRendering.Scale.Y * CanvasScale.Y;

    MenuItemPos.X = Canvas.ClipX * CommandMenuItemRendering.Pos.X;
    MenuItemPos.Y = Canvas.ClipY * CommandMenuItemRendering.Pos.Y;

    for (i=0;i<CommandList.length;i++) {
        if (i == CommandMenuIndex)
            Canvas.SetDrawColor(255, 0, 0, 255);
        else
            Canvas.SetDrawColor(255, 255, 255, 255);

        Canvas.SetPos(MenuItemPos.X, MenuItemPos.Y + (i*CommandMenuItemPosOffset*Canvas.ClipY));
        Canvas.DrawText(CommandList[i].Label);
    }

    Canvas.FontScaleX = OrigFontScale.X;
    Canvas.FontScaleY = OrigFontScale.Y;
}

/** Renders the current command that'll be activated
 * @param Canvas - Canvas object to be used for rendering
 */
simulated function RenderCurrentCommand(Canvas Canvas) {
    local vector2d CanvasScale, OrigFontScale;
    local vector2d MenuBoxPos, MenuItemPos;

    Canvas.Style = 1;
    Canvas.SetDrawColor(255, 255, 255, 255);

    CanvasScale.X = Canvas.ClipX / 1024;
    CanvasScale.Y = Canvas.ClipY / 768;

    if (CommandMenuBox != none) {
        MenuBoxPos.X = Canvas.ClipX * CommandMenuRendering.Pos.X;
        MenuBoxPos.Y = Canvas.ClipY * CommandMenuRendering.Pos.Y;

        Canvas.SetPos(MenuBoxPos.X, MenuBoxPos.Y);
        Canvas.DrawTile(CommandMenuBox, CommandMenuBox.USize*CanvasScale.Y*SelectedMenuRendering.Scale.X,
                        CommandMenuBox.VSize*CanvasScale.Y*SelectedMenuRendering.Scale.Y, 0, 0,
                        CommandMenuBox.USize, CommandMenuBox.VSize);
    }

    Canvas.Font = CommandMenuItemFont;

    OrigFontScale.X = Canvas.FontScaleX;
    OrigFontScale.Y = Canvas.FontScaleY;

    Canvas.FontScaleX = CommandMenuItemRendering.Scale.X * CanvasScale.Y;
    Canvas.FontScaleY = CommandMenuItemRendering.Scale.Y * CanvasScale.Y;

    MenuItemPos.X = Canvas.ClipX * CommandMenuItemRendering.Pos.X;
    MenuItemPos.Y = Canvas.ClipY * CommandMenuItemRendering.Pos.Y;

    Canvas.SetPos(MenuItemPos.X, MenuItemPos.Y);
    if (CommandList[CommandMenuIndex].CommandType == CM_HostileTerritory &&
        PartnerController != none) {
        if (PartnerController.bInHostileTerritory) {
            Canvas.SetDrawColor(255, 0, 0, 255);
            Canvas.DrawText("Fire On Anyone Armed");
        }
        else {
            Canvas.SetDrawColor(0, 255, 0, 255);
            Canvas.DrawText("Fire On Threats Only");
        }
    }
    else
        Canvas.DrawText(CommandList[CommandMenuIndex].Label);

    Canvas.SetDrawColor(255, 255, 255, 255);
    Canvas.FontScaleX = OrigFontScale.X;
    Canvas.FontScaleY = OrigFontScale.Y;
}

/** Renders debug information for troubleshooting AI stuff
 * @param Canvas - Canvas object to be used for rendering
 */
simulated function RenderDebug(Canvas Canvas) {
    local vector2d CanvasScale, OrigFontScale, DebugFontPos;

    if (PartnerController == none)
        return;

    Canvas.Font = CommandMenuItemFont;
    Canvas.Style = 1;
    Canvas.SetDrawColor(0, 255, 0, 255);

    CanvasScale.X = Canvas.ClipX / 1024;
    CanvasScale.Y = Canvas.ClipY / 768;

    OrigFontScale.X = Canvas.FontScaleX;
    OrigFontScale.Y = Canvas.FontScaleY;

    Canvas.FontScaleX = DebugTextRendering.Scale.X * CanvasScale.Y;
    Canvas.FontScaleY = DebugTextRendering.Scale.Y * CanvasScale.Y;

    DebugFontPos.X = Canvas.ClipX * DebugTextRendering.Pos.X;
    DebugFontPos.Y = Canvas.ClipY * DebugTextRendering.Pos.Y;

    //Canvas.SetPos(DebugFontPos.X, DebugFontPos.Y);
    //Canvas.DrawText("Partner Damage Taken: " $ Partner.PartnerDamage);
    //DebugFontPos.Y += Canvas.ClipY * CommandMenuItemPosOffset;

    Canvas.FontScaleX = OrigFontScale.X;
    Canvas.FontScaleY = OrigFontScale.Y;
}

/** Subclassed to make menu selections and execute the command */
function ServerFire() {
    if (CurrentCommand == CM_None)
        SelectCommand();
    else
        MakeCommand();
}

/** Sets the CurrentCommand variable to the currently highlighted command */
function SelectCommand() {
    CurrentCommand = CommandList[CommandMenuIndex].CommandType;
}

/** Sends the PartnerController a command */
function MakeCommand() {
    local vector HitLocation, HitNormal, EndTrace, StartTrace;
    local Actor Other;

    StartTrace = Location;
    EndTrace = StartTrace + vector(Rotation) * 16384.0f;
    Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

    if (Other != none)
        HitLocation.Z += 72.0f;

    if (PartnerController != none)
        PartnerController.ReceiveCommand(CurrentCommand, Other, HitLocation);

    // Allow multiple instances of the Attack command, or toggling hostile territory
    if (CurrentCommand != CM_Attack && CurrentCommand != CM_HostileTerritory) {
        CommandMenuIndex = 0;
        CurrentCommand = CM_None;
    }
}

/** Subclassed to make menu cancellations */
function ServerAltFire() {
    if (CurrentCommand != CM_None) {
        CommandMenuIndex = 0;
        CurrentCommand = CM_None;
    }
}

/** Subclassed to provide functionality for menu scrolling instead */
simulated function ZoomIn() {
    if (CurrentCommand != CM_None)
        return;

    CommandMenuIndex--;

    if (CommandMenuIndex < 0)
        CommandMenuIndex = CommandList.length - 1;
}

/** Subclassed to provide functionality for menu scrolling instead */
simulated function ZoomOut() {
    if (CurrentCommand != CM_None)
        return;

    CommandMenuIndex++;

    if (CommandMenuIndex == CommandList.length)
        CommandMenuIndex = 0;
}

/** Subclassed to provide functionality for menu scrolling instead */
simulated function bool AllowNextWeapon() {
    return false;
}

/** Subclassed to provide functionality for menu scrolling instead */
simulated function bool AllowPrevWeapon() {
    return false;
}

/** Gets called by the PartnerController whenever an item has been picked up */
function NotifyPartnerPickup(Pickup PartnerPickup) {
    if (PistolPickup(PartnerPickup) != none)
        bHasPistol = true;
    else if (ShotgunPickup(PartnerPickup) != none)
        bHasShotgun = true;
    else if (MachineGunPickup(PartnerPickup) != none)
        bHasMachineGun = true;
    else if (RiflePickup(PartnerPickup) != none)
        bHasSniperRifle = true;
}

/** Subclassed to spawn your Partner after a time delay. This "timer" will be
 * independent from the default UE2 timer system as to not interfere with it
 */
event Tick(float DeltaTime) {
    super.Tick(DeltaTime);

    if (PartnerSpawnCurTime < PartnerSpawnDelay) {
        PartnerSpawnCurTime = FMin(PartnerSpawnCurTime + DeltaTime, PartnerSpawnDelay);

        if (PartnerSpawnCurTime == PartnerSpawnDelay)
            SpawnPartner(GetPartnerSpawnLocation());
    }

    if (RadioBoltOn != none)
        RadioBoltOn.SetRotation(Rotation);
}

defaultproperties
{
    CommandMenuIndex=0

    CurrentCommand=CM_None

    CommandList(0)=(Label="Regroup",CommandType=CM_Follow)
    CommandList(1)=(Label="Hold Position",CommandType=CM_HoldPosition)
    CommandList(2)=(Label="Attack",CommandType=CM_Attack)
    CommandList(3)=(Label="Hostile Territory",CommandType=CM_HostileTerritory)
    CommandList(4)=(Label="Holster Weapon",CommandType=CM_HolsterWeapon)
    CommandList(5)=(Label="Equip Weapon",CommandType=CM_EquipWeapon)
    CommandList(6)=(Label="Use Any Weapon",CommandType=CM_UseAnyWeapon)
    CommandList(7)=(Label="Use Pistol",CommandType=CM_UsePistol)
    CommandList(8)=(Label="Use Shotgun",CommandType=CM_UseShotgun)
    CommandList(9)=(Label="Use MachineGun",CommandType=CM_UseMachineGun)
    CommandList(10)=(Label="Use Sniper Rifle",CommandType=CM_UseSniperRifle)
    //CommandList(11)=(Label="Use Pecker",CommandType=CM_UsePecker)

    CommandMenuBox=texture'MpHUD.HUD.field_gray'
    CommandMenuRendering=(Pos=(X=0.0f,Y=0.0f),Scale=(X=0.5f,Y=3.5f),Dimensions=(X=512.0f,Y=128.0f))
    SelectedMenuRendering=(Pos=(X=0.0f,Y=0.0f),Scale=(X=0.6f,Y=0.5f),Dimensions=(X=512.0f,Y=128.0f))

    CommandMenuItemPosOffset=0.05f
    CommandMenuItemFont=Font'P2Fonts.Fancy48'
    CommandMenuItemRendering=(Pos=(X=0.02f,Y=0.02f),Scale=(X=0.5f,Y=0.5f))

    RadioBoltonBone="Bip01 R Hand"

    bShowAIDebugInfo=false
    DebugTextRendering=(Pos=(X=0.02f,Y=0.75f),Scale=(X=0.5f,Y=0.5f))

    ActiveTimeFactor=0.1f

    PartnerSpawnCurTime=0.0f
    PartnerSpawnDelay=0.25f
    PartnerSpawnRadius=256.0f
    PartnerSpawnOffset=(X=128.0f,Y=128.0f,Z=0.0f)
    PartnerClass=class'PLUncleDaveHelper'

    bHasPistol=true
    bHasShotgun=false
    bHasMachineGun=false
    bHasSniperRifle=false

    bUsesAltFire=false
    ViolenceRank=0
    RecognitionDist=600.000000
    ShotCountMaxForNotify=0
    holdstyle=WEAPONHOLDSTYLE_Toss
    switchstyle=WEAPONHOLDSTYLE_Toss
    firingstyle=WEAPONHOLDSTYLE_Toss
    bThrownByFiring=false
    NoAmmoChangeState="EmptyDownWeapon"
    MinRange=400.000000
    ShakeOffsetTime=2.000000
    bAllowHints=false
    bShowHints=false
    bBumpStartsFight=false
    FirstPersonMeshSuffix="Grenade"
    WeaponSpeedLoad=1.250000
    WeaponSpeedReload=1.250000
    WeaponSpeedHolster=1.500000
    WeaponSpeedShoot1Rand=0.500000
    WeaponSpeedShoot2=2.000000
    WeaponSpeedIdle=0.400000
    AmmoName=class'InfiniteAmmoInv'
    FireSound=Sound'WeaponSounds.grenade_fire'
    InventoryGroup=10
    GroupOffset=99
    PickupClass=class'PartnerRadioPickup'
    PlayerViewOffset=(X=1.0f)
    BobDamping=0.975000
    AttachmentClass=class'Inventory.GrenadeAttachment'
    ItemName="Partner Radio"
 	OverrideHUDIcon=Texture'AW7Tex.Icons.hud_copradio'
	Mesh=SkeletalMesh'MP_Weapons.MP_LS_Grenade'
    Skins(0)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
}
