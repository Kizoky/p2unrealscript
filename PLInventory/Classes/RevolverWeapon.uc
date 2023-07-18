/**
 * RevolverWeapon
 * Copyright 2014, Running With Scissors, Inc.
 *
 * A special revolver that makes the Postal Dude's inner gunslinger come out.
 * Killing enemies with the Revolver builds up a skill meter, which can then
 * be spent on performing instant killed, perfectly aimed headshots.
 *
 * @author Gordon Cheng
 */
class RevolverWeapon extends DualCatableWeapon;//PLDualWieldWeapon;

/** Execution level variables */
var bool bExecuting;

var travel int ExecutionLevel;
var int MaxExecutionLevel;

var int ExecutionCount;
var int MinExecutionCountForTaunt;

var texture ExecutionReticle;
var texture ExecutionBarIcon;

var Font ExecutionFont;
var color ExecutionBarColor;

var bool bHintGainingExecution;
var localized string HudHint_GainExecution1;
var localized string HudHint_GainExecution2;
var localized string HudHint_GainExecution3;

var bool bHintMarkingTargets;
var localized string HudHint_MarkTargets1;
var localized string HudHint_MarkTargets2;
var localized string HudHint_MarkTargets3;

var bool bHintExecutionCost;
var localized string HudHints_ExecutionCost1;
var localized string HudHints_ExecutionCost2;
var localized string HudHints_ExecutionCost3;

var array<name> ExceptionClassNames;

var int ExecutionCost, ExecutionKillGain;

/** List of marked targets for execution */
var int MarkedTargetsPtr;
var array<P2MoCapPawn> MarkedTargets;

/** Lightnight quick, and precise aiming variables, quick draw! */
var float CurAimTime, ExecutionAimTime;
var vector StartAimLoc, EndAimLoc;

var bool bPlayTaunt;
var float TauntDelayTime;

var float WeaponSpeedReload;
var float WeaponSpeedTaunt;

/** Muzzle flash and bone names */
var name MuzzleBoneName;
var class<P2Emitter> MuzzleSmokeEmitterClass;
var P2Emitter MuzzleSmokeEmitter;

var() Sound TauntSound;

const BONE_HEAD = 'MALE01 head';

// Added by Man Chrzan: xPatch
var() vector ThirdPersonRelativeLocationLeft;
var() rotator ThirdPersonRelativeRotationLeft;
var() int ExecutionDisplayMode;		// 0 - Simple bar, 1 - Original bar, 3 - Percent
var bool bModeChecked;

event PostBeginPlay()
{
	// Revolver has infinite ExecutionLevel in enhanced game
	if (P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Pawn(Owner).Controller.bIsPlayer)
	{
		ExecutionLevel = MaxExecutionLevel;
	}
}
// End

/** Returns whether or not the specified Actor is in our Pawn's FOV
 * @param Other - P2MoCapPawn object to check if it's in our field of vision
 * @return TRUE if the P2MoCapPawn is in our Pawn's FOV; FALSE otherwise
 */
function bool IsInFieldOfVision(P2MoCapPawn Other) {
    local float MinAngle;
    local vector TargetDir;

    if (Instigator == none || PlayerController(Instigator.Controller) == none)
        return false;

    TargetDir = Normal(GetHeadLocation(Other) - Instigator.Location);
    MinAngle = PlayerController(Instigator.Controller).FOVAngle / 180.0;

    return (TargetDir dot vector(Rotation) >= MinAngle);
}

/**
 * Returns whether or not a given P2MoCapPawn is a valid target. This includes
 * whether or not we have enough ammunition, enough execution level saved up,
 * and whether or not they even have a head to begin with!
 *
 * @param Other - P2MoCapPawn to fully check if they're valid targets
 * @return TRUE if the P2MoCapPawn passes all the valid target checks;
 *         FALSE otherwise
 */
function bool IsPawnAValidTarget(P2MoCapPawn Other) {
    return (Other.Health > 0 && Other.myHead != none && !IsPawnMarked(Other) &&
            ExecutionLevel >= ExecutionCost && AmmoType != none &&
           ((MarkedTargets.length + 1) <= AmmoType.AmmoAmount));
}

/** Returns whether or not the specified Pawn has already been marked
 * @param Other - Pawn to check whether it has been marked or not
 * @return TRUE if the Pawn is already in the list; FALSE otherwise
 */
function bool IsPawnMarked(P2MoCapPawn Other) {
    local int i;

    for (i=0;i<MarkedTargets.length;i++)
        if (Other == MarkedTargets[i])
            return true;

    return false;
}

/** Returns whether or not a given Pawn is an exception to being instantly killed
 * @param Other - Pawn to check whether or not he or she is an exception
 * @return TRUE if the Pawn is an exception; FALSE otherwise
 */
function bool IsException(Pawn Other) {
    local int i;

    for (i=0;i<ExceptionClassNames.length;i++)
        if (Other.IsA(ExceptionClassNames[i]))
            return true;

    return false;
}

/** Overriden so we can teach players how to use the Revolver */
function bool GetHints(out String str1, out String str2, out String str3, out byte InfiniteHintTime) {
    if (!bShowHints || !bAllowHints)
        return false;

    if (bHintGainingExecution) {
        str1 = HudHint_GainExecution1;
		str2 = HudHint_GainExecution2;
		str3 = HudHint_GainExecution3;
        return true;
    }

    if (bHintMarkingTargets) {
        str1 = HudHint_MarkTargets1;
		str2 = HudHint_MarkTargets2;
		str3 = HudHint_MarkTargets3;
        return true;
    }

    if (bHintExecutionCost) {
        str1 = HudHints_ExecutionCost1;
		str2 = HudHints_ExecutionCost2;
		str3 = HudHints_ExecutionCost3;
        return true;
    }

    return false;
}

/** Returns the location of a Pawn's head
 * @param Other - Pawn to return the location of their head
 * @return Location in the world where their head is
 */
function vector GetHeadLocation(Pawn Other) {
    return Other.GetBoneCoords(BONE_HEAD).Origin;
}

/**
 * Returns whether or not there is a Pawn at the top of the MarkedTargets stack
 * @return TRUE if we have a Pawn at the top of the stack; FALSE otherwise
 */
function bool HasPawnAtTopOfStack() {
    local int topPtr;

    topPtr = MarkedTargets.length - 1;

    return (topPtr >= 0 && topPtr < MarkedTargets.length &&
        MarkedTargets[topPtr] != none && MarkedTargets[topPtr].myHead != none);
}

/** Mark a target for execution by pushing him or her onto the Stack
 * @param Other - Pawn to push onto our target stack
 */
function PushTarget(P2MoCapPawn Other) {
    MarkedTargets.Insert(MarkedTargets.length, 1);
    MarkedTargets[MarkedTargets.length-1] = Other;
	
	// Revolver has infinite ExecutionLevel in enhanced game
	if (!P2GameInfoSingle(Level.Game).VerifySeqTime())
		ExecutionLevel -= ExecutionCost;
}

/** Empties our entire marked target list of all the targets */
function EmptyMarkedTargets() {
    while (MarkedTargets.length > 0)
        MarkedTargets.Remove(MarkedTargets.length-1, 1);
}

/** Overriden to remove the muzzle smoke emitter when firing */
simulated function LocalFire() {
    if (MuzzleSmokeEmitter != none) {
        MuzzleSmokeEmitter.Destroy();
        MuzzleSmokeEmitter = none;
    }

    super.LocalFire();
}

/** Overriden to remove the muzzle smoke emitter when firing */
simulated function LocalAltFire() {
    if (MuzzleSmokeEmitter != none) {
        MuzzleSmokeEmitter.Destroy();
        MuzzleSmokeEmitter = none;
    }

    super.LocalAltFire();
}

simulated function PlayFiring() {
    super.PlayFiring();

    bPlayTaunt = false;
}

simulated function PlayAltFiring() {
// Added by Man Chrzan: xPatch 2.0
	local float UsePitch;
	
	SetupMuzzleFlashEmitter();
	
	// If the cat is on the gun and we want it to fly off, then set it up to fly off,
	// by switching the animation
	if(CatOnGun==1)
		{
		// Switch to special sound
		AltFireSound=CatFireSound;
		// Pitch higher with each consecutive shot
		UsePitch = WeaponFirePitchStart + (CAT_PITCH_INCREASE*(StartShotsWithCat - CatAmmoLeft));

		// xCatSilencer plays fire anim.
		if( Cat != None )
			Cat.PlayAnim(CatFireAnim);
		
		//if (CatAmmoLeft==0
		if (CatAmmoLeft==0
			|| !AmmoType.HasAmmo())
			{
			// Remove our cat and shoot him off, unless we have a cheat set to
			// keep shooting them off
			if(RepeatCatGun == 0)
				{
				SwapCatOff();
				ShootOffCat();
				CatOnGun=0;
				}
			else // Cheat
				{
				CatAmmoLeft=1;
				ShootOffCat();
				}
			}
		}
	else
		{
		// Use normal firing sound
		AltFireSound=Default.AltFireSound;
		UsePitch = WeaponFirePitchStart + (FRand()*WeaponFirePitchRand);
		}
//end
	IncrementFlashCount();
	
	if (Level.Game == none || !FPSGameInfo(Level.Game).bIsSinglePlayer)
		PlayOwnedSound(AltFireSound,SLOT_Interact,1.0,,,WeaponFirePitchStart +
            (FRand()*WeaponFirePitchRand),false);
	else
		Instigator.PlaySound(AltFireSound, SLOT_None, 1, true,,
            WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));

	PlayAnim('Shoot2', WeaponSpeedShoot2);

	bPlayTaunt = false;
}

/*
exec function Reload() {
    PlayReloading();
}
*/

function PlayReloading() {
    PlayAnim('Reload', WeaponSpeedReload, 0.05);
}

function PlayTaunt() {
    PlayAnim('Taunt', WeaponSpeedTaunt, 0.05);
}

function Notify_PlayTauntSound()
{
	PlayOwnedSound(TauntSound, SLOT_Interact, 1.0);
}

function Notify_PlayHolsterSound()
{
	PlayOwnedSound(HolsterSound, SLOT_Interact, 1.0);
}

/** Copied and modified from P2Weapon */
function TraceFire(float Accuracy, float YOffset, float ZOffset) {
	local vector markerpos, markerpos2;
	local bool secondary;
	local BulletTracer bullt;
	local vector usev;
	local Rotator newrot;

	local vector HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

	local bool bWasAlive;
	
	// Added by Man Chrzan: xPatch 2.0 
	// Reduce the cat ammo if we're using one
	if(CatOnGun == 1)
		CatAmmoLeft--;

	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z);
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
	EndTrace = StartTrace + (YOffset + Accuracy * (FRand() - 0.5 ) ) * Y * 1000
		+ (ZOffset + Accuracy * (FRand() - 0.5 )) * Z * 1000;
	X = vector(AdjustedAim);
	EndTrace += (TraceDist * X);
	Other = Trace(LastHitLocation,HitNormal,EndTrace,StartTrace,true);

	if (Pawn(Other) != none)
	    bWasAlive = Pawn(Other).Health > 0;

	// xPatch Change: Brand new ProcessExecutionTraceHit function was added to RevolverAmmoInv
	if(bExecuting && RevolverAmmoInv(AmmoType) != None)
		RevolverAmmoInv(AmmoType).ProcessExecutionTraceHit(self, Other, LastHitLocation, HitNormal, X,Y,Z);
	else // End
		AmmoType.ProcessTraceHit(self, Other, LastHitLocation, HitNormal, X,Y,Z);
	ShotCount++;

	if (Pawn(Other) != none && Pawn(Other).Health <= 0 && bWasAlive) {
	    if (RightWeapon != none && RevolverWeapon(RightWeapon) != none)
	        RevolverWeapon(RightWeapon).NotifyPawnKilled();
        else
            NotifyPawnKilled();
    }

    // xPatch Change: ExecutionKills++ moved to NotifyPawnKilled() so it records IsException pawns killed with it too.
	if (bExecuting && P2MoCapPawn(Other) != none && P2AmmoInv(AmmoType) != none) 
	{
		if(!IsException(Pawn(Other))) {
			P2MoCapPawn(Other).ExplodeHead(LastHitLocation, vect(0,0,0));
			P2MoCapPawn(Other).Died(Instigator.Controller, P2AmmoInv(AmmoType).DamageTypeInflicted, LastHitLocation);
		}
    }

	if (P2GameInfo(Level.Game).bShowTracers) {
		usev = (LastHitLocation - StartTrace);

        if (Level.Game != none && FPSGameInfo(Level.Game).bIsSinglePlayer) {
			bullt = spawn(class'BulletTracer',Owner,,(LastHitLocation + StartTrace)/2);
			bullt.SetDirection(Normal(usev), VSize(usev));
		}
	}

	if (P2Player(Instigator.Controller) != none && FPSPawn(Other) != none)
		P2Player(Instigator.Controller).Enemy = FPSPawn(Other);

	if (ShotCount >= ShotCountMaxForNotify && Instigator.Controller != none) {
		ShotCount -= ShotCountMaxForNotify;
		markerpos = Instigator.Location;
		markerpos2 = LastHitLocation;
		secondary = true;

		if (ShotMarkerMade != none)
			ShotMarkerMade.static.NotifyControllersStatic(Level, ShotMarkerMade,
				FPSPawn(Instigator), FPSPawn(Instigator),
                ShotMarkerMade.default.CollisionRadius, markerpos);

		if (P2Pawn(Other) != none && PawnHitMarkerMade != none)
			PawnHitMarkerMade.static.NotifyControllersStatic(Level,
                PawnHitMarkerMade, FPSPawn(Instigator), FPSPawn(Other),
				PawnHitMarkerMade.default.CollisionRadius,
				markerpos2);
		else if(secondary && BulletHitMarkerMade != none)
			BulletHitMarkerMade.static.NotifyControllersStatic(Level,
				BulletHitMarkerMade, FPSPawn(Instigator), none,
				BulletHitMarkerMade.default.CollisionRadius, markerpos2);
    }
}

/** Render additional info such as our execution level and marked targets */
simulated event RenderOverlays(Canvas Canvas) {
    local int i;
    local float CanvasScale;
    local vector HeadDrawPos;

    local float InnerWidth, InnerHeight;
    local float ScreenX, ScreenY, Width, Height, Border, Perc;

    super.RenderOverlays(Canvas);
	
	// xPatch: new execution bar options
	if(!bModeChecked) 
	{
		if(P2GameInfoSingle(Level.Game) != None && P2GameInfoSingle(Level.Game).xManager != None)
			ExecutionDisplayMode = P2GameInfoSingle(Level.Game).xManager.iRevolverMode;
		bModeChecked = true;
	}
	
	ScreenX = Canvas.SizeX / 2;
	if(ExecutionDisplayMode == 1) 
		ScreenY = Canvas.SizeY * 4 / 5;
	else
		ScreenY = Canvas.SizeY * 4 / 4.5;
		
	if(ExecutionDisplayMode == 1) {
		Width = Canvas.SizeX / 4;
		Height = Canvas.SizeY / 20; 
	}
	else {
		Width = Canvas.SizeX / 8;
		Height = Canvas.SizeY / 40;
	}
		
	Border = 2;

	Perc = float(ExecutionLevel) / float(MaxExecutionLevel);
	CanvasScale = Canvas.ClipY / 768;

	Canvas.Style = ERenderStyle.STY_Alpha;

	// Draw the bar
	if ( ExecutionDisplayMode != 2 && !P2GameInfoSingle(Level.Game).VerifySeqTime())
	{
		// Draw the badge (why?) icon.
		if(ExecutionDisplayMode == 1) {
			if (ExecutionBarIcon != none) {
				Canvas.SetDrawColor(255, 255, 255, 255);
				Canvas.SetPos(ScreenX - (Width / 2) - 64 * CanvasScale, ScreenY - 40 * CanvasScale);
				Canvas.DrawIcon(ExecutionBarIcon, CanvasScale);
			}
		}
		
		Canvas.SetPos(ScreenX - (Width / 2), ScreenY);
		Canvas.SetDrawColor(0, 0, 0, ExecutionBarColor.A);

		if (Canvas.DrawColor.A > 0)
			Canvas.DrawRect(Texture'engine.WhiteSquareTexture', Width, Height);

		InnerWidth = Width - 2 * Border;
		InnerHeight = Height - 2 * Border;

		Canvas.SetPos(ScreenX - (InnerWidth / 2), ScreenY + Border);
		Canvas.DrawColor = ExecutionBarColor;

		if (Canvas.DrawColor.A > 0)
			Canvas.DrawRect(Texture'engine.WhiteSquareTexture', InnerWidth * Perc, InnerHeight);
	}
	
	// Draw the execution mark
    if (ExecutionReticle != none) {

        for (i=0;i<MarkedTargets.length;i++) {

            if (MarkedTargets[i] != none && MarkedTargets[i].myHead != none &&
                IsInFieldOfVision(MarkedTargets[i])) {

                HeadDrawPos = Canvas.WorldToScreen(MarkedTargets[i].myHead.Location);
				Canvas.SetDrawColor(255, 255, 255, 200);
                Canvas.SetPos(HeadDrawPos.X - 32 * CanvasScale, HeadDrawPos.Y - 32 * CanvasScale);
                Canvas.DrawIcon(ExecutionReticle, CanvasScale);
            }
        }
    }
}

/** Render our execution level on the HUD icon above ammo*/
simulated function string GetFiringMode()
{
	local float fPerc;
	local int iPerc;
	
	fPerc = float(ExecutionLevel) / float(MaxExecutionLevel);
	iPerc = fPerc * 100;
	
	if (ExecutionDisplayMode == 2 && !P2GameInfoSingle(Level.Game).VerifySeqTime())
		return iPerc$"%";
	else
		return "";
}

/** Mark targets for execution depending on how full our bar is */
function Tick(float DeltaTime) {
    local float AimPct;
    local vector AimLoc;
    local rotator AimRot;

    local vector HitLocation, HitNormal, EndTrace, StartTrace;
    local Actor Other;

    super.Tick(DeltaTime);

    if (AmmoType == none || AmmoType.AmmoAmount == 0 ||
       ((LeftWeapon != none && LeftWeapon.bDualWielding) ||
       (RightWeapon != none && RightWeapon.bDualWielding)))
        return;

    if (bPlayTaunt) {
        TauntDelayTime = FMax(TauntDelayTime - DeltaTime, 0);

        if (TauntDelayTime == 0) {
            PlayTaunt();
            bPlayTaunt = false;
        }
    }

    if (bExecuting && MarkedTargetsPtr > -1) {

        CurAimTime = FMin(CurAimTime + DeltaTime, ExecutionAimTime);

        EndAimLoc = GetHeadLocation(MarkedTargets[MarkedTargetsPtr]);

        AimPct = CurAimTime / ExecutionAimTime;
        AimLoc = (EndAimLoc - StartAimLoc) * AimPct + StartAimLoc;
        AimRot = rotator(AimLoc - (Instigator.Location + Instigator.EyePosition()));

        Instigator.SetViewRotation(AimRot);

        if (CurAimTime == ExecutionAimTime) {
            TraceFire(0,0,0);
            LocalAltFire();
            MarkedTargetsPtr--;

            if (MarkedTargetsPtr > -1) {
                StartAimLoc = EndAimLoc;
                EndAimLoc = GetHeadLocation(MarkedTargets[MarkedTargetsPtr]);
                CurAimTime = 0.0;
            }
            else {
                bExecuting = false;
                ExecutionFinished();
            }
        }
    }
    else {
        if (IsInState('Idle') && Instigator.PressingAltFire()) {

            StartTrace = Instigator.Location + Instigator.EyePosition();
            EndTrace = StartTrace + vector(Rotation) * 8192;
            Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

            if (P2MoCapPawn(Other) != none &&
                IsPawnAValidTarget(P2MoCapPawn(Other)))
                PushTarget(P2MoCapPawn(Other));
        }
        else if (MarkedTargets.length > 0) {

            MarkedTargetsPtr = MarkedTargets.length - 1;

            StartAimLoc = Instigator.Location + Instigator.EyePosition() + vector(Rotation) * 256;
            EndAimLoc = GetHeadLocation(MarkedTargets[MarkedTargetsPtr]);
            CurAimTime = 0.0;

            ExecutionCount = MarkedTargets.length;
            bExecuting = true;
        }
    }
}

/** Called whenever a Pawn has been killed so we can build up our momentum */
function NotifyPawnKilled() {
    if (!bExecuting)
        ExecutionLevel = Min(ExecutionLevel + ExecutionKillGain, MaxExecutionLevel);
			
    if (PLBaseGameState(P2GameInfoSingle(Level.Game).TheGameState) != None)
		PLBaseGameState(P2GameInfoSingle(Level.Game).TheGameState).ExecutionKills++;

    if (bHintGainingExecution && ExecutionLevel == MaxExecutionLevel) {
        bHintGainingExecution = false;
        UpdateHudHints();
    }
}

function ExecutionFinished() {
    local vector MuzzleLoc;

    EmptyMarkedTargets();

    if (MuzzleSmokeEmitterClass != none && MuzzleBoneName != '') {

        MuzzleLoc = GetBoneCoords(MuzzleBoneName).Origin;

        MuzzleSmokeEmitter = Spawn(MuzzleSmokeEmitterClass,,, MuzzleLoc);
    }

    if (MuzzleSmokeEmitter != none)
        AttachToBone(MuzzleSmokeEmitter, MuzzleBoneName);

    // Change by Man Chrzan: Don't lick cat's ass lol.
	//if (ExecutionCount >= MinExecutionCountForTaunt) {
	 if (ExecutionCount >= MinExecutionCountForTaunt && CatOnGun==0) {
        bPlayTaunt = true;
        TauntDelayTime = ExecutionAimTime;
    }

    if (bHintMarkingTargets) {
        bHintMarkingTargets = false;
        UpdateHudHints();
    }
	
	// Added by Man Chrzan: Holster the Revolver when we are out of ammo.
	if (!AmmoType.HasAmmo())
		Finish();
}

// Added by Man Chrzan: xPatch 2.0  
// Left Revolver location fix
function SetupDualWielding()
{
	Super.SetupDualWielding();
	
	LeftWeapon.ThirdPersonRelativeLocation = ThirdPersonRelativeLocationLeft;
	LeftWeapon.ThirdPersonRelativeRotation = ThirdPersonRelativeRotationLeft;
}

// Added by Man Chrzan: xPatch 2.0  
// Fix for Catable Weapon and Revolver execution marker compability.
state Idle
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Tick(float DeltaTime) 
	{
		global.Tick(DeltaTime);
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		ResetMoanVals();
	}
}

defaultproperties
{
	ExceptionClassNames(0)="PLBossPawn"
	ExceptionClassNames(1)="BigMcWillis"
	ExceptionClassNames(2)="CoreyDude"
	ExceptionClassNames(3)="Gary_Stilts"
	ExceptionClassNames(4)="PLHabib"
	ExceptionClassNames(5)="PLKrotchy"
	ExceptionClassNames(6)="PLOsama"
	ExceptionClassNames(7)="PLRWSVince"
	ExceptionClassNames(8)="PLUncleDave"
	// added by Man Chrzan: xPatch 2.0
	ExceptionClassNames(9)="Krotchy"
	ExceptionClassNames(10)="Gary"	
	ExceptionClassNames(11)="BanditLeader"
	
    //MuzzleFlashBone="dummy_muzzle"
    //MuzzleFlashEmitterClass=class'RevolverMuzzleFlashEmitter'
	MFBoneName="dummy_muzzle"
	MFScale=(Min=0.8,Max=0.8) 
	MFClass=class'xMuzzleFlashEmitter'
	MFTex=texture'Timb.muzzleflash.pistol_corona'
	bSpawnMuzzleFlash=True

    WeaponSpeedReload=1
    WeaponSpeedTaunt=1

    MuzzleBoneName="dummy_muzzle"
    MuzzleSmokeEmitterClass=class'RevolverMuzzleSmoke'

    ExecutionAimTime=0.2

    ExecutionLevel=0
    MaxExecutionLevel=100

    ExecutionCost=15
    ExecutionKillGain=20

    MinExecutionCountForTaunt=3

	ExecutionReticle=texture'P2Misc.Reticle.Reticle_Crosshair_Redline'
    ExecutionBarIcon=texture'nathans.Inventory.b_Star_Shield'
    ExecutionFont=Font'P2Fonts.Fancy24'
    ExecutionBarColor=(R=180,G=10,B=10,A=120)

    bHintGainingExecution=true
    HudHint_GainExecution1="Take out enemies with the Revolver"
    HudHint_GainExecution2="to fill up the execution bar."
    HudHint_GainExecution3=""

    bHintMarkingTargets=true
    HudHint_MarkTargets1="Hold the %KEY_AltFire% and highlight"
    HudHint_MarkTargets2="targets to mark them for execution."
    HudHint_MarkTargets3="Let go to perform a wild west quick draw."

    bHintExecutionCost=true
    HudHints_ExecutionCost1="Remember, not all enemies can"
    HudHints_ExecutionCost2="be marked for execution, but"
    HudHints_ExecutionCost3="most can!"

    bAllowHints=true
	bShowHints=true

    ItemName="Revolver"
	AmmoName=class'RevolverAmmoInv'
	PickupClass=class'RevolverPickup'
	AttachmentClass=class'RevolverAttachment'

	Mesh=SkeletalMesh'PL_Revolver_Mesh.pl_revolver_viewmodel'
	FirstPersonMeshSuffix="Pistol"

	AmbientGlow=90 //128
	PlayerViewOffset=(X=0) //(X=0,Z=-10)

    bDrawMuzzleFlash=false
	MuzzleScale=1
	FlashOffsetY=0.15
	FlashOffsetX=0.215
	FlashLength=0.01
	MuzzleFlashSize=128
    MFTexture=texture'Timb.muzzleflash.pistol_corona'

	MuzzleFlashStyle=STY_Normal
    MuzzleFlashScale=2.4

	holdstyle=WEAPONHOLDSTYLE_Single
	switchstyle=WEAPONHOLDSTYLE_Single
	firingstyle=WEAPONHOLDSTYLE_Single

	ShakeOffsetMag=(X=10,Y=2,Z=2)
	ShakeOffsetRate=(X=1000,Y=1000,Z=1000)
	ShakeOffsetTime=2.2
	ShakeRotMag=(X=220,Y=30,Z=30)
	ShakeRotRate=(X=10000,Y=10000,Z=10000)
	ShakeRotTime=2.2

	FireSound=sound'PLWeapons.Revolver.Revolver_shoot1'
	//sound'WeaponSounds.pistol_fire'
	AltFireSound=sound'PLWeapons.Revolver.Revolver_shoot2'
	//sound'WeaponSounds.pistol_fire'
    SoundRadius=255
	CombatRating=3
	AIRating=0.2
	AutoSwitchPriority=2
	InventoryGroup=2
	GroupOffset=3
	BobDamping=1.12 //0.975
	ReloadCount=0
	TraceAccuracy=0.15
	ShotMarkerMade=class'GunfireMarker'
	BulletHitMarkerMade=class'BulletHitMarker'
	AI_BurstCountExtra=3
	AI_BurstTime=0.8
	ViolenceRank=3

	WeaponSpeedHolster=1
	WeaponSpeedLoad=1
	WeaponSpeedReload=1
	WeaponSpeedShoot1=1.5
	WeaponSpeedShoot1Rand=0
	WeaponSpeedShoot2=0.75
	AimError=400
	RecognitionDist=900

	MaxRange=1024
	MinRange=250

	bUsesAltFire=false
	SelectSound=Sound'PLWeapons.Revolver.Revolver_load1'
	HolsterSound=Sound'PLWeapons.Revolver.Revolver_holster1'

	OverrideHUDIcon=Texture'RevolverTex.hud_Revolver' //'MrD_PL_Tex.HUD.Revolver_HUD'
	ThirdPersonRelativeLocation=(X=15,Z=6)
	ThirdPersonRelativeRotation=(Pitch=16384,Yaw=16384)
	
	// Added by Man Chrzan: xPatch 2.0
	TauntSound=sound'PLWeapons.Revolver.Revolver_taunt1'
	ThirdPersonRelativeLocationLeft=(X=15,Y=-3,Z=-6)
    ThirdPersonRelativeRotationLeft=(Pitch=-16384,Yaw=16384)
	Skins[0]=Texture'RevolverTex.magnum_diffuse'
	Skins[1]=Texture'RevolverTex.gungrip_diffuse'
	Skins[2]=Texture'RevolverTex.magnum_bullets'
	Skins[3]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	
	// Meow! 
	bAttachCat=True
	CatFireSound=Sound'WeaponSounds.machinegun_catfire'
	CatBoneName="dummy_muzzle"
	CatRelativeLocation=(X=0,Y=0,Z=3)
	CatRelativeRotation=(Pitch=0,Roll=0,Yaw=16384)
	StartShotsWithCat=9
	
	bAllowMiddleFinger=True
}
