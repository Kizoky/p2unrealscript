/**
 * P2DualWieldWeapon
 * Copyright 2014, Running With Scissors, Inc.
 *
 * Base object for dual wieldable weapons. What this base does is basically
 * keep track of how many you picked up, and is reponsible for spawning and
 * passing controls onto a "sidekick" weapon.
 *
 * @author Gordon Cheng
 *
 * @edited by Piotr S. aka Man Chrzan aka xPatch Guy
 * Fixed some bugs and issues (as usual), added some extra stuff too. 
 */
class P2DualWieldWeapon extends P2Weapon;

/** Dual wielding variables */
var travel bool bAllowDualWielding;
var travel bool bDualWielding;
var travel byte WeaponCount;

var EWeaponHoldStyle dualholdstyle;
var EWeaponHoldStyle dualswitchstyle;
var EWeaponHoldStyle dualfiringstyle;

var vector LeftWeaponViewOffset;
var name LeftHandBoneName;
var class<P2DualWieldWeapon> LeftWeaponOverrideClass;

var P2DualWieldWeapon LeftWeapon, RightWeapon;

var Font DebugFont;

// xPatch: Sometimes we just want to disable it
// for weapons that have to extend this class...
var  bool bDisableDualWielding;	

simulated function AttachToPawn(Pawn P)
{
	Super.AttachToPawn(P);
	if (LeftWeapon != None && bDualWielding)
		LeftWeapon.AttachToPawn(P);
}
simulated function DetachFromPawn(Pawn P)
{
	Super.DetachFromPawn(P);
	if (LeftWeapon != None && bDualWielding)
		LeftWeapon.DetachFromPawn(P);	
}
///////////////////////////////////////////////////////////////////////////////
// Go through all your weapons and change out the hands texture for this new one
///////////////////////////////////////////////////////////////////////////////
simulated function ChangeHandTexture(Texture NewHandsTexture, Texture DefHandsTexture, Texture NewFootTexture)
{
	Super.ChangeHandTexture(NewHandsTexture, DefHandsTexture, NewFootTexture);
	if (LeftWeapon != None && bDualWielding)
		LeftWeapon.ChangeHandTexture(NewHandsTexture, DefHandsTexture, NewFootTexture);
}

/** Overriden to handle dual wielding setup */
simulated function PostBeginPlay() {
    super.PostBeginPlay();

    if (bAllowDualWielding && LeftWeapon == none)
        SetupDualWielding();
}

/** Sets the left arm base bone either to 0 or 1 depending on */
function SetLeftArmVisibility() {

    local int i;
	
	// Handle your primary right weapon's left hand scale
    if (bDualWielding)
        SetBoneScale(0, 0.0, LeftHandBoneName);
    else
        SetBoneScale(0, 1.0, LeftHandBoneName);

    // The left weapon will always have a missing right (left) hand
    if (RightWeapon != none)
        SetBoneScale(0, 0.0, LeftHandBoneName);
		
	// Man Chrzan: xPatch 
	// Fix for left arm skin.
	if(LeftWeapon != None)
	{
		for(i=0; i<Skins.Length; i++)
		{
			if(default.Skins[i] == class'P2Player'.default.DefaultHandsTexture)
			{
				LeftWeapon.Skins[i] = Skins[i];
			}
		}
	}
}

/** Create the left weapon for dual wielding. Like the foot, we don't add it
 * to the player's inventory so the player can't switch to it
 */
function SetupDualWielding() {
    local vector LeftWeapDrawScale;
    local Ammunition LeftWeaponAmmo;
	local int i;
	
    if (LeftWeaponOverrideClass != none)
        LeftWeapon = Spawn(LeftWeaponOverrideClass);
    else
        LeftWeapon = Spawn(class);

    if (LeftWeapon != none) {
        LeftWeapDrawScale = LeftWeapon.default.DrawScale3D;
        LeftWeapDrawScale.X *= -1;

        LeftWeapon.PlayerViewOffset = LeftWeaponViewOffset;

        if (LeftWeaponOverrideClass != none) {
            LeftWeaponAmmo = Ammunition(Instigator.FindInventoryType(LeftWeapon.AmmoName));

            if (LeftWeaponAmmo == none && LeftWeapon.AmmoName != none) {
                LeftWeaponAmmo = Spawn(LeftWeapon.AmmoName);

                if (LeftWeaponAmmo != none) {
                    Instigator.AddInventory(LeftWeaponAmmo);
                    LeftWeaponAmmo.AmmoAmount = LeftWeapon.PickUpAmmoCount;
                }
            }

            LeftWeapon.AmmoType = LeftWeaponAmmo;
        }
        else
            LeftWeapon.AmmoType = AmmoType;

        if (LeftWeapon.bMeleeWeapon)
            LeftWeapon.UseMeleeDist = PlayerMeleeDist;

        LeftWeapon.SetDrawScale3D(LeftWeapDrawScale);
        LeftWeapon.SetOwner(Instigator);

        LeftWeapon.ThirdPersonRelativeRotation.Roll = 32768;

        LeftWeapon.RightWeapon = self;
		
		// Man Chrzan: xPatch 
		LeftWeapon.ShellSpeedY *= -1;	// reverse shells
		// End

        bAllowDualWielding = true;
    }
    else
        log("ERROR: Unable to create LeftWeapon");
}

/** Toggle whether or not we use a single weapon, or two of them at once */
/*exec*/ function SwitchDualWielding() {
    if (bAllowDualWielding)
        GotoState('ToggleDualWielding');
}

/** Changes our weapon hold style depending on whether we're dual wielding */
function ChangeWeaponHoldStyle() {
    if (bDualWielding) {
        holdstyle = dualholdstyle;
        switchstyle = dualswitchstyle;
        firingstyle = dualfiringstyle;
    }
    else {
        holdstyle = default.holdstyle;
        switchstyle = default.switchstyle;
        firingstyle = default.firingstyle;
    }
    Instigator.ChangeAnimation();
    //if (bDualWielding && LeftWeapon != none) {
      //  LeftWeapon.AttachToPawn(Instigator);
    //}
}

/** Various state change functions that have been overriden to pass commands
 * over to the left weapon
 */
 simulated function BringUp() 
 {
	// xPatch: No Dual-Wielding 
	if(bDisableDualWielding)
	{
		super.BringUp();
		return;
	}
	
	// Automatically go into dual-wielding if brought up while the dude
	// is under the influence of some kind of caffeinergy sauce
	if (RightWeapon == None
		&& P2Player(Pawn(Owner).Controller) != None
		&& (P2Player(Pawn(Owner).Controller).DualWieldUseTime > 0 || P2Player(Pawn(Owner).Controller).bCheatDualWield))
	{
		if (LeftWeapon == None)
			SetupDualWielding();
		bDualWielding = true;
	}
	// xPatch: Dual-Wielding for NPCs
	else if (RightWeapon == None && P2Pawn(Owner) != None 
		&& P2Player(Pawn(Owner).Controller) == None
		&& P2Pawn(Owner).bForceDualWield)
	{
		if (LeftWeapon == None)
			SetupDualWielding();
		bDualWielding = true;
	}
	else
		bDualWielding = false;

    if (bDualWielding && LeftWeapon != none) {
        LeftWeapon.BringUp();
        //LeftWeapon.AttachToPawn(Instigator);
    }

    SetLeftArmVisibility();
	ChangeWeaponHoldStyle();

    super.BringUp();
}

simulated function bool PutDown() {
    if (bDualWielding && LeftWeapon != none) {
        LeftWeapon.PutDown();
        LeftWeapon.DetachFromPawn(Instigator);
    }

    return super.PutDown();
}

/** Notification from a WeaponPickup that we picked */
function NotifyWeaponPickup() {
    if (bAllowDualWielding)
        return;

    WeaponCount++;

    if (WeaponCount == 2)
        SetupDualWielding();
}

/** Setup things after a save has been loaded */
event PostLoadGame() {
    super.PostLoadGame();

    SetLeftArmVisibility();
}

/** Setup things after a level change */
event TravelPostAccept() {
    super.TravelPostAccept();

    if (bAllowDualWielding && LeftWeapon == none)
        SetupDualWielding();

    if (bDualWielding && LeftWeapon != none)
        LeftWeapon.BringUp();

    SetLeftArmVisibility();

    ChangeWeaponHoldStyle();
}

/** Overriden so we can adjust the weapon rotation to ensure iron sights work */
simulated event RenderOverlays(Canvas Canvas)
{
	local rotator NewRot;
	local bool bPlayerOwner;
	local int Hand;
	local  PlayerController PlayerOwner;
	local float ScaledFlash;
	local Vector Res;
	local float Aspect;

	if (bDeleteMe)
		return;

	if (Instigator == none)
		return;

	// xPatch: It's now handled with HUD by default.
	if(!P2Player(Instigator.Controller).bHUDCrosshair)
		DrawCrosshair(Canvas);

	PlayerOwner = PlayerController(Instigator.Controller);

	if (PlayerOwner != none) {
		bPlayerOwner = true;
		Hand = PlayerOwner.Handedness;

        if (Hand == 2)
			return;
	}

    // Find the correct view model FOV
    if(!bOverrideAutoFOV)
    {
        if(ControllerFOV != PlayerOwner.DefaultFOV)
	    {
			// Approximation, the old method was pulling some weird shit in lower aspect ratios. Should be more consistent across aspects now.
	        ControllerFOV = PlayerOwner.DefaultFOV;
			
			Res = PlayerOwner.GetResolution();
			Aspect = Res.X / Res.Y;
			// 4:3 (1.333333) = Standard - 65
			// 1.6 = 72.5
			// 5:3 (1.666667) = 74
			// 16:9 (1.777778) = Widescreen - 75
			// 21:9 (2.333333) = Ultra-Widescreen - 88
			// 5.333333 = Triple-Head - 121
			
			// Approximates correct display FOV based on aspect ratio.
			if (Aspect <= 1.8)
				DisplayFOV = 23.f * Aspect + 36.333333;
			else
			{
				DisplayFOV = -99.555555/Aspect + 139.666666;
				// Push the view model down a bit on ultra-wide aspect ratios
				PlayerViewOffset.Z = Default.PlayerViewOffset.Z - 2;
			}
			//log("Aspect"@Aspect@"DisplayFOV"@DisplayFOV);
        }
    }
	
	if (bMuzzleFlash && bDrawMuzzleFlash && MFTexture != none) {
		if (!bSetFlashTime) {
			bSetFlashTime = true;
			FlashTime = 0;
		}
		else if (FlashTime >= FlashMax) {
			bMuzzleFlash = false;
			bDynamicLight=false;
		}

        if (bMuzzleFlash) {
			ScaledFlash = 0.5 * MuzzleFlashSize * MuzzleScale * Canvas.ClipX/640;
			Canvas.SetPos(0.5*Canvas.ClipX - ScaledFlash + Canvas.ClipX *
                Hand * FlashOffsetX, 0.5*Canvas.ClipY - ScaledFlash +
                Canvas.ClipY * FlashOffsetY);
			DrawMuzzleFlash(Canvas);
			FlashTime += 1.0;
		}
	}
	else
		bSetFlashTime = false;
		
	// Man Chrzan: xPatch Overwrite Weapons FOV
	if(xDisplayOverwrite)
	{
		if(xPreviousFOV == 0)
			xPreviousFOV = DisplayFOV;
		
		DisplayFOV = xPreviousFOV + xDisplayFOV;
		
		PlayerViewOffset.X = Default.PlayerViewOffset.X + xOffsetX;
		PlayerViewOffset.Y = Default.PlayerViewOffset.Y + xOffsetY;
		PlayerViewOffset.Z = Default.PlayerViewOffset.Z + xOffsetZ;
	}
	// End

	// Draw our right weapon
    Canvas.DrawActor(none, false, true);
	SetLocation(Instigator.Location + Instigator.CalcDrawOffset(self));
	NewRot = Instigator.GetViewRotation();

	if (Hand == 0)
		newRot.Roll = 2 * Default.Rotation.Roll;
	else
		newRot.Roll = Default.Rotation.Roll * Hand;

	SetRotation(newRot);
	Canvas.DrawActor(self, false, false, DisplayFOV);

	if (!bDualWielding) return;

	// Draw our left weapon
    Canvas.DrawActor(none, false, true);
	LeftWeapon.SetLocation(Instigator.Location + Instigator.CalcDrawOffset(self));
	NewRot = Instigator.GetViewRotation();

	if (Hand == 0)
		newRot.Roll = 2 * Default.Rotation.Roll;
	else
		newRot.Roll = Default.Rotation.Roll * Hand;

	LeftWeapon.SetRotation(newRot);
	Canvas.DrawActor(LeftWeapon, false, false, DisplayFOV);

	//Canvas.SetPos(0,0);
	//Canvas.Font = DebugFont;
	//Canvas.DrawText("LeftWeaponState: " $ LeftWeapon.GetStateName());
}

/** Overriden to ensure our left weapon fires from the left */
simulated function vector GetFireStart(vector X, vector Y, vector Z) {
    if (RightWeapon != none)
        return (Instigator.Location + Instigator.EyePosition() +
            FireOffset.X * X + -FireOffset.Y * Y + FireOffset.Z * Z);
    else
        return (Instigator.Location + Instigator.EyePosition() + FireOffset.X *
            X + FireOffset.Y * Y + FireOffset.Z * Z);
}

/** Handle which weapon should fire depending on which mouse buttons are held */
function HandleDualFire() {

    if (Instigator.PressingFire() && (!bDualWielding || RightWeapon != none))
        Fire(0);
	else {

        // Ensure only the LeftWeapon can perform Alt Fire stuff
        if (Instigator.PressingAltFire() && RightWeapon == none) {

		    if (bDualWielding)
		        Fire(0);
            else
                AltFire(0);
		}
		else {
			PlayIdleAnim();
			GotoState('Idle');
		}
	}
	
	// xPatch: And here we do it for NPCs :D
	if(P2Player(Instigator.Controller) == None 
	&& P2Pawn(Instigator) != None && P2Pawn(Owner).bForceDualWield 
	&& LeftWeapon != None)
		LeftWeapon.Fire(0);
}

/**
 * Handles which weapon should fire depending on which mouse buttons are held
 * and when we're idle. Need this to prevent a infinite loop.
 */
function HandleDualFireFromIdle() {
    if (Instigator.PressingFire() && (!bDualWielding || RightWeapon != none))
        Fire(0);
	else if (Instigator.PressingAltFire() && RightWeapon == none) {

        if (bDualWielding)
            Fire(0);
        else
            AltFire(0);
    }
}

/** Overriden so we can cause the right weapon to fire */
/*
function Finish()
{
	local bool bForce, bForceAlt;

	if (NeedsToReload() && P2AmmoInv(AmmoType).HasAmmoFinished()) {
		GotoState('Reloading');
		return;
	}

	bForce = bForceFire;
	bForceAlt = bForceAltFire;
	bForceFire = false;
	bForceAltFire = false;

	if (bChangeWeapon) {
		GotoState('DownWeapon');
		return;
	}

	if (Instigator == none || Instigator.Controller == none) {
		GotoState('');
		return;
	}

	if (!Instigator.IsHumanControlled()) {

        if (!P2AmmoInv(AmmoType).HasAmmoFinished()) {

            Instigator.Controller.SwitchToBestWeapon();

			if (bChangeWeapon)
				GotoState('DownWeapon');
			else
				GotoState('Idle');
		}

		if (Instigator.PressingFire() && FRand() <= AmmoType.RefireRate)
			Global.ServerFire();
		else if ( Instigator.PressingAltFire() )
			CauseAltFire();
		else {
			Instigator.Controller.StopFiring();
			GotoState('Idle');
		}
		return;
	}

	if (!P2AmmoInv(AmmoType).HasAmmoFinished() &&
        Instigator.IsLocallyControlled()) {

        if (P2Player(Instigator.Controller) != none &&
            P2Player(Instigator.Controller).bAutoSwitchOnEmpty)
			P2Player(Instigator.Controller).SwitchAfterOutOfAmmo();
		else if (P2Player(Instigator.Controller) != none)
			P2Player(Instigator.Controller).SwitchToHands(true);

		if (bChangeWeapon) {
			GotoState(NoAmmoChangeState);
			return;
		}
		else
			GotoState('Idle');
	}

    if (Instigator.Weapon != self)
		GotoState('Idle');
	else if (DoServerFireAgain(bForce)) {
        Global.ServerFire();
	}
	else if (DoServerAltFireAgain(bForceAlt))
		CauseAltFire();
	else
		GotoState('Idle');
}
*/

/** Overriden so we fire the proper weapon when dual wielding */
simulated function ClientFinish() {

	//ErikFOV Change: Fix problem
	if( Level.NetMode == NM_Client )
	{
		Super(P2Weapon).ClientFinish();
		if( !bChangeWeapon )
			HandleDualFire();
		return;
	}
	//End
	
	if (Instigator == none || Instigator.Controller == none) {
		GotoState('');
		return;
	}

    if (NeedsToReload() && P2AmmoInv(AmmoType).HasAmmoFinished()) {
		GotoState('Reloading');
		return;
	}

	if (!P2AmmoInv(AmmoType).HasAmmoFinished()) {

		if (P2Player(Instigator.Controller) != none &&
            P2Player(Instigator.Controller).bAutoSwitchOnEmpty)
			Instigator.Controller.SwitchToBestWeapon();
		else if (P2Player(Instigator.Controller) != none)
			P2Player(Instigator.Controller).SwitchToHands(true);

		if (bChangeWeapon) {
			GotoState(NoAmmoChangeState);
			return;
		}
		else {
			PlayIdleAnim();
			GotoState('Idle');
			return;
		}
	}

    if (bChangeWeapon)
		GotoState('DownWeapon');
	else
	    HandleDualFire();
}

/** Overriden so we fire the proper weapon when dual wielding */
simulated function ClientIdleCheckFire() {
	HandleDualFire();

    if (Instigator.Weapon == self)
		SetTimer(REPLICATE_TIME_CHECK_IDLE, false);
}

/** Overriding the Begin section so for proper dual wielding firing */
state Idle
{

Begin:
	bPointing=False;

    if (NeedsToReload() && P2AmmoInv(AmmoType).HasAmmoFinished())
		GotoState('Reloading');

	if (!P2AmmoInv(AmmoType).HasAmmoFinished())
		Instigator.Controller.SwitchToBestWeapon();

	HandleDualFireFromIdle();

	PlayIdleAnim();
}

/**
 * Start our toggle process by pretending to put our main weapon down and if we
 * were currently dual wielding, put our left weapon down for real
 */
state ToggleDualWielding
{
    simulated function Fire(float F);
    simulated function AltFire(float F);
    /*exec*/ function SwitchDualWielding();

    function BeginState() {
		PlayDownAnim();

        if (bDualWielding && LeftWeapon != none) {
            LeftWeapon.GotoState('DownWeapon');
            LeftWeapon.DetachFromPawn(Instigator);
        }
    }

    function AnimEnd(int Channel) {
        bDualWielding = !bDualWielding;

        GotoState('EquipDualWielding');
    }
}

/**
 * Now, bring our weapon(s) back up. If we're dual wielding, bring up the left
 * weapon and remove the left arm. Otherwise we just pretend bring back up our
 * main right weapon and enable back the left arm.
 */
state EquipDualWielding
{
    simulated function Fire(float F);
    simulated function AltFire(float F);
    /*exec*/ function SwitchDualWielding();

    function BeginState() {
        ChangeWeaponHoldStyle();

        PlaySelect();

        // NOTE TO SELF: We need to put this here as we're only faking bringing
        // the weapon back up, so we need to tell the other weapon to bringup
        // for real as well.
        if (LeftWeapon != none) {

            if (bDualWielding) {

                LeftWeapon.BringUp();
                LeftWeapon.AttachToPawn(Instigator);
            }
            else
                LeftWeapon.DetachFromPawn(Instigator);
        }

        SetLeftArmVisibility();
    }

    function AnimEnd(int Channel) {
        GotoState('Idle');
    }
}

/** If we put down our weapon for real, put down the left weapon as well */
state DownWeapon
{
    simulated function BeginState() {

        if (bDualWielding && LeftWeapon != none) {
            LeftWeapon.GotoState('DownWeapon');
			
			// Turn off dual wielding when switching weapons, so it stays off if the player brings up that weapon again
			// after the energy boost expires.
			bDualWielding = false;	
            LeftWeapon.DetachFromPawn(Instigator);
			ChangeWeaponHoldStyle();
        }

        super.BeginState();
    }
}

// xPatch: Called by xMuzzleFlashEmitter
function SetupWeaponGlow(byte FlashGlow) 
{
	local int FinalGlow;
	
	// Handle flashes for left weapon
	if(bDualWielding)
	{
		if (LeftWeapon != None)
		{
			if(FlashGlow == 0)
			{
				if(P2GameInfoSingle(Level.Game).xManager.bOverwriteWeaponProperties)
					LeftWeapon.AmbientGlow = P2GameInfoSingle(Level.Game).xManager.iWeaponBrightness;
				else
					LeftWeapon.AmbientGlow = default.AmbientGlow;
			}
			else
			{
				FinalGlow = LeftWeapon.AmbientGlow + FlashGlow;
				if( FinalGlow > 250 )
					FinalGlow = 250;

				LeftWeapon.AmbientGlow = FinalGlow;
			}
		}
	}
	
	// Handle flashes for right weapon
	Super.SetupWeaponGlow(FlashGlow);
}

// xPatch: main weapon got destroyed, make sure that left weapon too! 
simulated function Destroyed()
{
	if (LeftWeapon != None)
		LeftWeapon.DetachFromPawn(Instigator);	
	
	Super.Destroyed();
}

defaultproperties
{
    LeftWeaponViewOffset=(X=0,Y=0,Z=0)
	LeftHandBoneName="Bip01 L UpperArm"

	dualholdstyle=WEAPONHOLDSTYLE_Dual
	dualswitchstyle=WEAPONHOLDSTYLE_Dual
	dualfiringstyle=WEAPONHOLDSTYLE_Dual

	WeaponCount=1

	DebugFont=Font'P2Fonts.Fancy24'
}