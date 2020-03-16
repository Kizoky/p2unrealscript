//=============================================================================
// Parent class of all weapons.
// FIXME - should bReplicateInstigator be true???
//=============================================================================
class Weapon extends Inventory
	abstract
	native
	nativereplication;

#exec Texture Import File=Textures\Weapon.pcx Name=S_Weapon Mips=Off MASKED=1

//-----------------------------------------------------------------------------
// Weapon ammo information:
var		class<ammunition> AmmoName;     // Type of ammo used.
var		int     PickupAmmoCount;		// Amount of ammo initially in pick-up item.
var		travel ammunition	AmmoType;	// Inventory Ammo being used.
var		travel byte    ReloadCount;			// Amount of ammo depletion before reloading. 0 if no reloading is done.

//-----------------------------------------------------------------------------
// Weapon firing/state information:

var		bool	  bPointing;		// Indicates weapon is being pointed
var		bool	  bWeaponUp;		// Used in Active State
var		bool	  bChangeWeapon;	// Used in Active State
var		bool	  bCanThrow;		// if true, player can toss this weapon out
var		bool	  bRapidFire;		// used by pawn animations in determining firing animation, and for net replication
var		bool	  bForceReload;

var		float	StopFiringTime;	// repeater weapons use this
var		int		AutoSwitchPriority;
var     vector	FireOffset;			// Offset from first person eye position for projectile/trace start
var		texture	CrossHair;
var		Powerups Affector;			// powerup chain currently affecting this weapon

// RWS Change 01/06/03 start.
// from vr. 2141
// camera shakes //
var() vector ShakeRotMag;           // how far to rot view
var() vector ShakeRotRate;          // how fast to rot view
var() float  ShakeRotTime;          // how much time to rot the instigator's view
var() vector ShakeOffsetMag;        // max view offset vertically
var() vector ShakeOffsetRate;       // how fast to offset view vertically
var() float  ShakeOffsetTime;       // how much time to offset view
// vr. 927
/*
var 	float	ShakeMag;
var 	float	ShakeTime;
var 	vector  ShakeVert;
var		vector  ShakeSpeed;
*/
// RWS Change 01/06/03 end. 

var		float	TraceAccuracy;

//-----------------------------------------------------------------------------
// AI information
var		bool	bMeleeWeapon;   // Weapon is only a melee weapon
var		bool	bSniping;		// weapon useful for sniping
var		float	AimError;		// Aim Error for bots (note this value doubled if instant hit weapon)
var		float	AIRating;
var		float	TraceDist;		// how far instant hit trace fires go
var		float   MaxRange;		// max range of weapon for non-trace hit attacks
var		Rotator AdjustedAim;

//-----------------------------------------------------------------------------
// Sound Assignments
var() sound 	FireSound;
var() sound 	SelectSound;

// messages
var() Localized string MessageNoAmmo;
var   Localized string WeaponDescription;
var   Color NameColor;	// used when drawing name on HUD

var		bool	bSteadyToggle;
var		bool bForceFire, bForceAltFire;

var string	LeftHandedMesh;	// string of name of left-handed view mesh (if different)
var float DisplayFOV;		// FOV for drawing the weapon in first person view

//-----------------------------------------------------------------------------
// first person Muzzle Flash
// weapon is responsible for setting and clearing bMuzzleFlash whenever it wants the
// MFTexture drawn on the canvas (see RenderOverlays() )

var					float	FlashTime;			// time when muzzleflash will be cleared (set in RenderOverlays())
var(MuzzleFlash)	float	MuzzleScale;		// scaling of muzzleflash
var(MuzzleFlash)	float	FlashOffsetY;		// flash center offset from centered Y (as pct. of Canvas Y size) 
var(MuzzleFlash)	float	FlashOffsetX;		// flash center offset from centered X (as pct. of Canvas X size) 
var(MuzzleFlash)	float	FlashLength;		// How long muzzle flash should be displayed in seconds
var(MuzzleFlash)	float	MuzzleFlashSize;	// size of (square) texture
var					texture MFTexture;			// first-person muzzle flash sprite
var					byte	FlashCount;			// when incremented, draw muzzle flash for current frame
var					bool	bAutoFire;			// when changed, draw muzzle flash for current frame
var					bool	bMuzzleFlash;		// if !=0 show first-person muzzle flash
var					bool	bSetFlashTime;		// reset FlashTime clock when false
var					bool	bDrawMuzzleFlash;	// enable first-person muzzle flash

//-----------------------------------------------------------------------------
// third person muzzleflash

var		bool	bMuzzleFlashParticles;
var		mesh	MuzzleFlashMesh;
var		float	MuzzleFlashScale;
var	ERenderStyle MuzzleFlashStyle;
var		texture MuzzleFlashTexture;

var float FireAdjust;

var float InstFlash;	// one frame view flash when firing weapon
var vector InstFog;		// one frame view fog when firing weapon

// Network replication
//
replication
{
	// Things the server should send to the client.
	reliable if( bNetOwner && bNetDirty && (Role==ROLE_Authority) )
		AmmoType, Affector, ReloadCount;

	// Functions called by server on client
	reliable if( Role==ROLE_Authority )
		ClientWeaponEvent, ClientWeaponSet, ClientForceReload;

	// functions called by client on server
	reliable if( Role<ROLE_Authority )
		ServerForceReload, ServerFire, ServerAltFire, ServerRapidFire, ServerStopFiring;
}

// Native functions.
native function Actor GetAssistedAimTarget(Vector StartTrace, Float TraceDist);

// AI Functions
function bool SplashDamage()
{
	return AmmoType.bSplashDamage;
}

function float GetDamageRadius()
{
	return AmmoType.GetDamageRadius();
}

function float RefireRate()
{
	return AmmoType.RefireRate;
}

function bool RecommendSplashDamage()
{
	return AmmoType.bRecommendSplashDamage;
}

// fixme - make IsFiring() weapon state based
function bool IsFiring()
{
	return ((Instigator != None) && (Instigator.Controller != None)
		&& ((Instigator.Controller.bFire !=0) || (Instigator.Controller.bAltFire != 0)));
}

/* IncrementFlashCount()
Tell WeaponAttachment to cause client side weapon firing effects
*/
simulated function IncrementFlashCount()
{
	FlashCount++;
	if ( WeaponAttachment(ThirdPersonActor) != None )
	{
		WeaponAttachment(ThirdPersonActor).FlashCount = FlashCount;
		WeaponAttachment(ThirdPersonActor).ThirdPersonEffects();
	}
}

simulated event PostNetBeginPlay()
{
	if ( Role == ROLE_Authority )
		return;
	if ( (Instigator == None) || (Instigator.Controller == None) )
		SetHand(0);
	else
		SetHand(Instigator.Controller.Handedness);
}

/* Force reloading even though clip isn't empty.  Called by player controller exec function,
and implemented in idle state */
simulated function ForceReload();

function ServerForceReload()
{
	bForceReload = true;
}

simulated function ClientForceReload()
{
	bForceReload = true;
	GotoState('Reloading');
}

/* DisplayDebug()
list important controller attributes on canvas
*/
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string T;
	local name Anim;
	local float frame,rate;

	Canvas.SetDrawColor(0,255,0);
	Canvas.DrawText("WEAPON "$GetItemName(string(self)));
	YPos += YL;
	Canvas.SetPos(4,YPos);

	T = "     STATE: "$GetStateName()$" Timer: "$TimerCounter;

	if ( Default.ReloadCount > 0 )
		T = T$" Reload Count: "$ReloadCount;

	Canvas.DrawText(T, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	
	if ( DrawType == DT_StaticMesh )		
		Canvas.DrawText("     StaticMesh "$StaticMesh$" AmbientSound "$AmbientSound, false);
	else 
		Canvas.DrawText("     Mesh "$Mesh$" AmbientSound "$AmbientSound, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	if ( Mesh != None )
	{
		// mesh animation
		GetAnimParams(0,Anim,frame,rate);
		T = "     AnimSequence "$Anim$" Frame "$frame$" Rate "$rate;
		if ( bAnimByOwner )
			T= T$" Anim by Owner";
		
		Canvas.DrawText(T, false);
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}

	if ( AmmoType == None )
	{
		Canvas.DrawText("ERROR - NO AMMUNITION");
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
	else
		AmmoType.DisplayDebug(Canvas,YL,YPos);

}

//=============================================================================
// Inventory travelling across servers.

event TravelPostAccept()
{
	Super.TravelPostAccept();
	if ( Pawn(Owner) == None )
		return;
	if ( AmmoName != None )
	{
		AmmoType = Ammunition(Pawn(Owner).FindInventoryType(AmmoName));
		if ( AmmoType == None )
		{		
			AmmoType = Spawn(AmmoName);	// Create ammo type required		
			Pawn(Owner).AddInventory(AmmoType);		// and add to player's inventory
			AmmoType.AmmoAmount = PickUpAmmoCount; 
			AmmoType.GotoState('');
		}
	}
	if ( self == Pawn(Owner).Weapon )
		BringUp();
	else GotoState('');
}

function Destroyed()
{
	if( (Pawn(Owner)!=None) && (Pawn(Owner).Weapon == self) )
		Pawn(Owner).Weapon = None;
	// RWS CHANGE: Safer at end of function
	Super.Destroyed();
}

function GiveTo(Pawn Other)
{
	Super.GiveTo(Other);
	bTossedOut = false;
	Instigator = Other;
	GiveAmmo(Other);
	ClientWeaponSet(true);
}

//=============================================================================
// Weapon rendering
// Draw first person view of inventory
simulated event RenderOverlays( canvas Canvas )
{
	local rotator NewRot;
	local bool bPlayerOwner;
	local int Hand;
	local  PlayerController PlayerOwner;
	local float ScaledFlash;

	DrawCrosshair(Canvas);

	if ( Instigator == None )
		return;

	PlayerOwner = PlayerController(Instigator.Controller);

	if ( PlayerOwner != None )
	{
		bPlayerOwner = true;
		Hand = PlayerOwner.Handedness;
		if (  Hand == 2 )
			return;
	}

	if ( bMuzzleFlash && bDrawMuzzleFlash && (MFTexture != None) )
	{
		if ( !bSetFlashTime )
		{
			bSetFlashTime = true;
			FlashTime = Level.TimeSeconds + FlashLength;
		}
		else if ( FlashTime < Level.TimeSeconds )
		{
			bMuzzleFlash = false;
			// RWS Change 06/03/02
			// This is so guns with flashes will turn off their dynamic light
			// when the flash is supposed to be over--this is for first-person mode only.
			// The actual setup for the lighting and all is handled usually in SetupMuzzleFlash in the
			// weapons.
			// Also, I added it to here, because it's only one line, easy to move around and keep track of
			// instead of overriding this giant function and copying everything over, just to add this line.
			bDynamicLight=false;
			// RWS Change 06/03/02
		}
		if ( bMuzzleFlash )
		{
			ScaledFlash = 0.5 * MuzzleFlashSize * MuzzleScale * Canvas.ClipX/640.0;
			Canvas.SetPos(0.5*Canvas.ClipX - ScaledFlash + Canvas.ClipX * Hand * FlashOffsetX, 0.5*Canvas.ClipY - ScaledFlash + Canvas.ClipY * FlashOffsetY);
			DrawMuzzleFlash(Canvas);
		}
	}
	else
		bSetFlashTime = false;

	SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );
	NewRot = Instigator.GetViewRotation();

	if ( Hand == 0 )
		newRot.Roll = 2 * Default.Rotation.Roll;
	else
		newRot.Roll = Default.Rotation.Roll * Hand;

	setRotation(newRot);
	Canvas.DrawActor(self, false, false, DisplayFOV);
}

simulated function DrawCrossHair( canvas Canvas)
{
	local float XLength, PickDiff;

	if ( CrossHair == None )
		return;
	XLength = 32.0;
	Canvas.bNoSmooth = False;
	Canvas.SetPos(0.503 * (Canvas.ClipX - XLength), 0.504 * (Canvas.ClipY - XLength));
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.SetDrawColor(255,255,255);
	Canvas.DrawTile(CrossHair, XLength, XLength, 0, 0, 32, 32);
	Canvas.bNoSmooth = True;
	Canvas.Style = Style;
}

/* DrawMuzzleFlash()
Default implementation assumes that flash texture can be drawn inverted in X and/or Y direction to increase apparent
number of flash variations
*/
simulated function DrawMuzzleFlash(Canvas Canvas)
{
	local float Scale, ULength, VLength, UStart, VStart;

	Scale = MuzzleScale * Canvas.ClipX/640.0;
	Canvas.Style = ERenderStyle.STY_Translucent;
	ULength = MFTexture.USize;
	if ( FRand() < 0.5 )
	{
		UStart = ULength;
		ULength = -1 * ULength;
	}
	VLength = MFTexture.VSize;
	if ( FRand() < 0.5 )
	{
		VStart = VLength;
		VLength = -1 * VLength;
	}

	Canvas.DrawTile(MFTexture, Scale * MFTexture.USize, Scale * MFTexture.VSize, UStart, VStart, ULength, VLength);
	Canvas.Style = ERenderStyle.STY_Normal;
}

//-------------------------------------------------------
// AI related functions

/* CanAttack()
return true if other is in range of this weapon
*/
function bool CanAttack(Actor Other)
{
	local float MaxDist, CheckDist;
	local vector HitLocation, HitNormal,X,Y,Z, projStart;
	local actor HitActor;

	if ( (Instigator == None) || (Instigator.Controller == None) )
		return false;

	// check that target is within range
	MaxDist = MaxRange;
	if ( AmmoType.bInstantHit )
		MaxDist = TraceDist;
	if ( VSize(Instigator.Location - Other.Location) > MaxDist )
		return false;

	// check that can see target
	if ( !Instigator.Controller.LineOfSightTo(Other) )
		return false;

	// check that would hit target, and not a friendly
	GetAxes(Instigator.Controller.Rotation,X,Y,Z);
	projStart = GetFireStart(X,Y,Z);
	if ( AmmoType.bInstantHit )
		HitActor = Trace(HitLocation, HitNormal, Other.Location + Other.CollisionHeight * vect(0,0,0.7), projStart, true);
	else
	{
		// for non-instant hit, only check partial path (since others may move out of the way)
		CheckDist = FClamp(AmmoType.ProjectileClass.Default.Speed,600, VSize(Other.Location - Location));
		HitActor = Trace(HitLocation, HitNormal, 
				projStart + CheckDist * Normal(Other.Location + Other.CollisionHeight * vect(0,0,0.7) - Location), 
				projStart, true);
	}

	if ( (HitActor == None) || (HitActor == Other) ||
		((Pawn(HitActor) != None) && (Instigator.Controller.AttitudeTo(Pawn(HitActor)) < ATTITUDE_Ignore)) )
		return true;

	return false;
}

/* AmmoStatus()
return percent of full ammo (0 to 1 range)
*/
function float AmmoStatus()
{
	return float(AmmoType.AmmoAmount)/AmmoType.MaxAmmo;
}

simulated function bool HasAmmo()
{
	return AmmoType.HasAmmo();
}

function bool SplashJump()
{
	return false;
}

/* GetRating()
returns rating of weapon based on its current configuration (no configuration change)
*/
function float GetRating()
{
	return RateSelf(); // don't do this if RateSelf() changes weapon configuration
}
	
/* RateSelf()
sets appropriate weapon configuration, and returns rating based on that configuration
*/
function float RateSelf()
{
	if ( !HasAmmo() )
		return -2;
	return (AIRating + FRand() * 0.05);
}

// return delta to combat style
function float SuggestAttackStyle()
{
// FIXME - implement
//	if ( VSize(Instigator.Target.Location - Instigator.Location) > MaxRange )
//		return 1.0;
	return 0.0;
}

function float SuggestDefenseStyle()
{
	return 0.0;
}

//-------------------------------------------------------

function ClientWeaponEvent(name EventType);

/* HandlePickupQuery()
If picking up another weapon of the same class, add its ammo.
If ammo count was at zero, check if should auto-switch to this weapon.
*/
function bool HandlePickupQuery( Pickup Item )
{
	local int OldAmmo, NewAmmo;
	local Pawn P;

	if (Item.InventoryType == Class)
	{
		if ( WeaponPickup(item).bWeaponStay && ((item.inventory == None) || item.inventory.bTossedOut) )
			return true;
		P = Pawn(Owner);
		if ( AmmoType != None )
		{
			OldAmmo = AmmoType.AmmoAmount;
			if ( Item.Inventory != None )
				NewAmmo = Weapon(Item.Inventory).PickupAmmoCount;
			else
				NewAmmo = class<Weapon>(Item.InventoryType).Default.PickupAmmoCount;
			if ( AmmoType.AddAmmo(NewAmmo) && (OldAmmo == 0) 
				&& (P.Weapon.class != item.InventoryType) )
					ClientWeaponSet(true);
		}
		Item.AnnouncePickup(Pawn(Owner));
		return true;
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

// set which hand is holding weapon
simulated function setHand(float Hand)
{
	if ( Hand == 2 )
	{
		PlayerViewOffset.Y = 0;
		FireOffset.Y = 0;
		return;
	}

// RWS CHANGE: Make this easier to extend by calling function instead of doing it here
//	LinkMesh(Default.Mesh);
	SetRightHandedMesh();
// RWS CHANGE: Make this easier to extend by calling function instead of doing it here
	if ( Hand == 0 )
	{
		PlayerViewOffset.X = Default.PlayerViewOffset.X * 0.88;
		PlayerViewOffset.Y = -0.2 * Default.PlayerViewOffset.Y;
		PlayerViewOffset.Z = Default.PlayerViewOffset.Z * 1.12;
	}
	else
	{
		PlayerViewOffset.X = Default.PlayerViewOffset.X;
		PlayerViewOffset.Y = Default.PlayerViewOffset.Y * Hand;
		PlayerViewOffset.Z = Default.PlayerViewOffset.Z;
		if ( (Hand == -1) && (LeftHandedMesh != "") )
		{
// RWS CHANGE: Make this easier to extend by calling function instead of doing it here
//			// load left handed mesh
//			LinkMesh(mesh(DynamicLoadObject(LeftHandedMesh, class'Mesh')));
			setLeftHandedMesh();
// RWS CHANGE: Make this easier to extend by calling function instead of doing it here
		}
	}
	FireOffset.Y = Default.FireOffset.Y * Hand;
}

// RWS CHANGE: add functions so derived classes can easily change this stuff
// This is called to set the right handed weapon mesh
simulated function SetRightHandedMesh()
{
	LinkMesh(Default.Mesh);
}

// This is called to set the left-handed weapon mesh
simulated function setLeftHandedMesh()
{
	LinkMesh(mesh(DynamicLoadObject(LeftHandedMesh, class'Mesh')));
}
// RWS CHANGE: add functions so derived classes can easily change this stuff

//
// Change weapon to that specificed by F matching inventory weapon's Inventory Group.
simulated function Weapon WeaponChange( byte F )
{	
	local Weapon newWeapon;
	 
	if ( InventoryGroup == F )
	{
		//log(self$" WeaponChange, has ammo "$AmmoType.AmmoAmount);
		if ( !AmmoType.HasAmmo() )
		{
			if ( Inventory == None )
				newWeapon = None;
			else
				newWeapon = Inventory.WeaponChange(F);
			if ( (newWeapon == None) && Instigator.IsHumanControlled() )
				Instigator.ClientMessage( ItemName$MessageNoAmmo );		
			return newWeapon;
		}		
		else 
			return self;
	}
	else if ( Inventory == None )
		return None;
	else
		return Inventory.WeaponChange(F);
}

// Find the previous weapon (using the Inventory group)
simulated function Weapon PrevWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
	if ( AmmoType.HasAmmo() )
	{
		if ( (CurrentChoice == None) )
		{
			if ( CurrentWeapon != self )
				CurrentChoice = self;
		}
		else if ( InventoryGroup == CurrentChoice.InventoryGroup )
		{
			if ( InventoryGroup == CurrentWeapon.InventoryGroup )
			{
				if ( (GroupOffset < CurrentWeapon.GroupOffset)
					&& (GroupOffset > CurrentChoice.GroupOffset) )
					CurrentChoice = self;
			}
			else if ( GroupOffset > CurrentChoice.GroupOffset )
				CurrentChoice = self;
		}
		else if ( InventoryGroup > CurrentChoice.InventoryGroup )
		{
			if ( (InventoryGroup < CurrentWeapon.InventoryGroup)
				|| (CurrentChoice.InventoryGroup > CurrentWeapon.InventoryGroup) )
				CurrentChoice = self;
		}
		else if ( (CurrentChoice.InventoryGroup > CurrentWeapon.InventoryGroup)
				&& (InventoryGroup < CurrentWeapon.InventoryGroup) )
			CurrentChoice = self;
	}
	if ( Inventory == None )
		return CurrentChoice;
	else
		return Inventory.PrevWeapon(CurrentChoice,CurrentWeapon);
}

simulated function Weapon NextWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
	if ( AmmoType.HasAmmo() )
	{
		if ( (CurrentChoice == None) )
		{
			if ( CurrentWeapon != self )
				CurrentChoice = self;
		}
		else if ( InventoryGroup == CurrentChoice.InventoryGroup )
		{
			if ( InventoryGroup == CurrentWeapon.InventoryGroup )
			{
				if ( (GroupOffset > CurrentWeapon.GroupOffset)
					&& (GroupOffset < CurrentChoice.GroupOffset) )
					CurrentChoice = self;
			}
			else if ( GroupOffset < CurrentChoice.GroupOffset )
				CurrentChoice = self;
		}

		else if ( InventoryGroup < CurrentChoice.InventoryGroup )
		{
			if ( (InventoryGroup > CurrentWeapon.InventoryGroup)
				|| (CurrentChoice.InventoryGroup < CurrentWeapon.InventoryGroup) )
				CurrentChoice = self;
		}
		else if ( (CurrentChoice.InventoryGroup < CurrentWeapon.InventoryGroup)
				&& (InventoryGroup > CurrentWeapon.InventoryGroup) )
			CurrentChoice = self;
	}
	if ( Inventory == None )
		return CurrentChoice;
	else
		return Inventory.NextWeapon(CurrentChoice,CurrentWeapon);
}

simulated function AnimEnd(int Channel)
{
	if ( Level.NetMode == NM_Client )
		PlayIdleAnim();
}

function GiveAmmo( Pawn Other )
{
	if ( AmmoName == None )
		return;
	AmmoType = Ammunition(Other.FindInventoryType(AmmoName));
	if ( AmmoType != None )
		AmmoType.AddAmmo(PickUpAmmoCount);
	else
	{
		AmmoType = Spawn(AmmoName);	// Create ammo type required		
		Other.AddInventory(AmmoType);		// and add to player's inventory
		AmmoType.AmmoAmount = PickUpAmmoCount; 
	}
}	

// Return the switch priority of the weapon (normally AutoSwitchPriority, but may be
// modified by environment (or by other factors for bots)
simulated function float SwitchPriority() 
{
	local float temp;

	if ( !Instigator.IsHumanControlled() )
		return RateSelf();
	else if ( !AmmoType.HasAmmo() )
	{
		if ( Pawn(Owner).Weapon == self )
			return -0.5;
		else
			return -1;
	}
	else 
		return default.AutoSwitchPriority;
}

// Compare self to current weapon.  If better than current weapon, then switch
simulated function ClientWeaponSet(bool bOptionalSet)
{
	local weapon W;

//log(self$" ClientWeaponSet 1");
	Instigator = Pawn(Owner); //weapon's instigator isn't replicated to client
	if ( Instigator == None )
	{
		GotoState('PendingClientWeaponSet');
		return;
	}
	else if ( IsInState('PendingClientWeaponSet') )
		GotoState('');
	if ( Instigator.Weapon == self )
		return;

	if ( Instigator.Weapon == None )
	{
		Instigator.PendingWeapon = self;
		Instigator.ChangedWeapon();
		return;	
	}
	if ( bOptionalSet && (Instigator.IsHumanControlled() && PlayerController(Instigator.Controller).bNeverSwitchOnPickup) )
		return;
//log(self$" ClientWeaponSet 4 inst weapon "$Instigator.Weapon$" my switch "$SwitchPriority()$" inst switch "$Instigator.Weapon.SwitchPriority());
	if ( Instigator.Weapon.SwitchPriority() < SwitchPriority() ) 
	{
		W = Instigator.PendingWeapon;
		Instigator.PendingWeapon = self;
		GotoState('');

		if ( !Instigator.Weapon.PutDown() )
		{
			Instigator.PendingWeapon = W;
		}
		return;
	}
	GotoState('');
}

simulated function Weapon RecommendWeapon( out float rating )
{
	local Weapon Recommended;
	local float oldRating, oldFiring;
	local int oldMode;

	if ( Instigator.IsHumanControlled() )
		rating = SwitchPriority();
	else
	{
		rating = RateSelf();
		if ( (self == Instigator.Weapon) && (Instigator.Controller.Enemy != None) 
			&& AmmoType.HasAmmo() )
			rating += 0.21; // tend to stick with same weapon
			rating += Instigator.Controller.WeaponPreference(self);
	}
	if ( inventory != None )
	{
		Recommended = inventory.RecommendWeapon(oldRating);
		if ( (Recommended != None) && (oldRating > rating) )
		{
			rating = oldRating;
			return Recommended;
		}
	}
	return self;
}

// Toss this weapon out
function DropFrom(vector StartLocation)
{
	AIRating = Default.AIRating;
	bMuzzleFlash = false;
	if ( AmmoType != None )
	{
		PickupAmmoCount = AmmoType.AmmoAmount;
		AmmoType.AmmoAmount = 0;
	}
	Super.DropFrom(StartLocation);
}

//**************************************************************************************
//
// Firing functions and states
//
simulated function bool RepeatFire()
{
	return bRapidFire;
}

function ServerStopFiring()
{
	StopFiringTime = Level.TimeSeconds;
}

function ServerRapidFire()
{
	ServerFire();
	if ( IsInState('NormalFire') )
		StopFiringTime = Level.TimeSeconds + 0.6;
}
	
function ServerFire()
{
	if ( AmmoType == None )
	{
		// ammocheck
		log("WARNING "$self$" HAS NO AMMO!!!");
		GiveAmmo(Pawn(Owner));
	}

	//log(self$" serverfire, ammo "$AmmoType.AmmoAmount$" get state "$GetStateName());

	if ( AmmoType.HasAmmo() )
	{
		GotoState('NormalFire');
		ReloadCount--;
		if ( AmmoType.bInstantHit )
			TraceFire(TraceAccuracy,0,0);
		else
			ProjectileFire();
		LocalFire();
	}
}

simulated function Fire( float Value )
{
	//log(self$" Fire, ammo "$AmmoType.AmmoAmount);

	if ( !AmmoType.HasAmmo() )
		return;

	if ( !RepeatFire() )
		ServerFire();
	else if ( StopFiringTime < Level.TimeSeconds + 0.3 )
	{
		StopFiringTime = Level.TimeSeconds + 0.6;
		ServerRapidFire();
	}
	if ( Role < ROLE_Authority )
	{
		//log(self$" going to client firing");
		ReloadCount--;
		LocalFire();
		GotoState('ClientFiring');
	}
}
	
simulated function LocalFire()
{
	local PlayerController P;

	bPointing = true;

	if ( (Instigator != None) && Instigator.IsLocallyControlled() )
	{
		P = PlayerController(Instigator.Controller);
		if (P!=None)
		{
			if ( InstFlash != 0.0 )
				P.ClientInstantFlash( InstFlash, InstFog);
				
			P.ShakeView(ShakeRotMag, ShakeRotRate, ShakeRotTime, 
						ShakeOffsetMag, ShakeOffsetRate, ShakeOffsetTime);
		}
	}
	if ( Affector != None )
		Affector.FireEffect();
	PlayFiring();
}		

function ServerAltFire()
{
	if ( !IsInState('Idle') )
		GotoState('Idle');
}

/* AltFire()
Weapon mode change.
*/
simulated function AltFire( float Value )
{
	if ( !IsInState('Idle') )
		GotoState('Idle');
	ServerAltFire();
}

simulated function PlayFiring()
{
	//Play firing animation and sound
}

simulated function vector GetFireStart(vector X, vector Y, vector Z)
{
	return (Instigator.Location + Instigator.EyePosition() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z); 
}

function ProjectileFire()
{
	local Vector Start, X,Y,Z;

	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	Start = GetFireStart(X,Y,Z); 
	AdjustedAim = Instigator.AdjustAim(AmmoType, Start, AimError);	
	AmmoType.SpawnProjectile(Start,AdjustedAim);	
}

function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z); 
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);	
	EndTrace = StartTrace + (YOffset + Accuracy * (FRand() - 0.5 ) ) * Y * 1000
		+ (ZOffset + Accuracy * (FRand() - 0.5 )) * Z * 1000;
	X = vector(AdjustedAim);
	EndTrace += (TraceDist * X); 
	Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
	AmmoType.ProcessTraceHit(self, Other, HitLocation, HitNormal, X,Y,Z);
}

simulated function bool NeedsToReload()
{
	return ( bForceReload || (Default.ReloadCount > 0) && (ReloadCount == 0) );
}

/* BotFire()
called by NPC firing weapon.  Weapon chooses appropriate firing mode to use (typically no change)
bFinished should only be true if called from the Finished() function
FiringMode can be passed in to specify a firing mode (used by scripted sequences)
*/
function bool BotFire(bool bFinished, optional name FiringMode)
{
	if ( !bFinished && !IsIdle() )
		return false;
	Instigator.Controller.bFire = 1;
	Instigator.Controller.bAltFire = 0;
	if ( !RepeatFire() )
		Global.ServerFire();
	else if ( StopFiringTime < Level.TimeSeconds + 0.3 )
	{
		StopFiringTime = Level.TimeSeconds + 0.6;
		Global.ServerRapidFire();
	}
	// in some situations, weapon might want to call CauseAltFire() instead, and set bAltFire=1
	return true;
}

function bool IsIdle()
{
	return false;
}

// Finish a sequence
function Finish()
{
	local bool bForce, bForceAlt;

	if ( NeedsToReload() && AmmoType.HasAmmo() )
	{
		GotoState('Reloading');
		return;
	}

	bForce = bForceFire;
	bForceAlt = bForceAltFire;
	bForceFire = false;
	bForceAltFire = false;

	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}

	if ( (Instigator == None) || (Instigator.Controller == None) )
	{
		GotoState('');
		return;
	}

	if ( !Instigator.IsHumanControlled() )
	{
		if ( !AmmoType.HasAmmo() )
		{
			Instigator.Controller.SwitchToBestWeapon();
			if ( bChangeWeapon )
				GotoState('DownWeapon');
			else
				GotoState('Idle');
			return;
		}
		if ( AIController(Instigator.Controller) != None )
		{
			if ( !AIController(Instigator.Controller).WeaponFireAgain(AmmoType.RefireRate,true) )
			{
				if ( bChangeWeapon )
					GotoState('DownWeapon');
				else
					GotoState('Idle');
			}
			return;
		}
	}
	if ( !AmmoType.HasAmmo() && Instigator.IsLocallyControlled() )
	{
		SwitchToWeaponWithAmmo();
		return;
	}
	if ( Instigator.Weapon != self )
		GotoState('Idle');
	else if ( (StopFiringTime > Level.TimeSeconds) || bForce || Instigator.PressingFire() )
		Global.ServerFire();
	else if ( bForceAlt || Instigator.PressingAltFire() )
		CauseAltFire();
	else 
		GotoState('Idle');
}

function SwitchToWeaponWithAmmo()
	{
	// if local player, switch weapon
	Instigator.Controller.SwitchToBestWeapon();
	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}
	else
		GotoState('Idle');
}

function CauseAltFire()
{
	Global.ServerAltFire();
}

simulated function ClientFinish()
{
	if ( (Instigator == None) || (Instigator.Controller == None) )
	{
		GotoState('');
		return;
	}
	if ( NeedsToReload() && AmmoType.HasAmmo() )
	{
		GotoState('Reloading');
		return;
	}
	if ( !AmmoType.HasAmmo() )
	{
		Instigator.Controller.SwitchToBestWeapon();
		if ( !bChangeWeapon )
		{
			PlayIdleAnim();
			GotoState('Idle');
			return;
		}
	}
	if ( bChangeWeapon )
		GotoState('DownWeapon');
	else if ( Instigator.PressingFire() )
		Global.Fire(0);
	else
	{
		if ( Instigator.PressingAltFire() )
			Global.AltFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('Idle');
		}
	}
}

function CheckAnimating();

///////////////////////////////////////////////////////
state NormalFire
{
	function CheckAnimating()
	{
		if ( !IsAnimating() )
			warn(self$" stuck in NormalFire and not animating!");
	}

	function ServerFire()
	{
		//log(self$" severfire, state "$GetStateName());
		bForceFire = true;
	}

	function ServerAltFire()
	{
		bForceAltFire = true;
	}

	function Fire(float F) {}
	function AltFire(float F) {} 

	function AnimEnd(int Channel)
	{
		Finish();
		CheckAnimating();
	}

	function BeginState()
	{
		if (Role == ROLE_Authority)
			Instigator.SpawnTime = -100000;
	}

	function EndState()
	{
		StopFiringTime = Level.TimeSeconds;
	}

Begin:
	Sleep(0.0);
}

/*
Weapon is up and ready to fire, but not firing.
*/
state Idle
{
	function bool IsIdle()
	{
		return true;
	}

	simulated function ForceReload()
	{
		ServerForceReload();
	}

	function ServerForceReload()
	{
		if ( AmmoType.HasAmmo() )
			GotoState('Reloading');
	}	
	
	simulated function AnimEnd(int Channel)
	{
		PlayIdleAnim();
	}

	simulated function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

Begin:
	bPointing=False;
	if ( NeedsToReload() && AmmoType.HasAmmo() )
		GotoState('Reloading');
	if ( !AmmoType.HasAmmo() ) 
		Instigator.Controller.SwitchToBestWeapon();  //Goto Weapon that has Ammo
	if ( Instigator.PressingFire() ) Fire(0.0);
	if ( Instigator.PressingAltFire() ) AltFire(0.0);	
	PlayIdleAnim();
}

state Reloading
{
	function ServerForceReload() {}
	function ClientForceReload() {}
	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	function ServerFire()
	{
		bForceFire = true;
	}

	function ServerAltFire()
	{
		bForceAltFire = true;
	}

	simulated function bool PutDown()
	{
		bChangeWeapon = true;
		return True;
	}

	simulated function BeginState()
	{
		if ( !bForceReload )
		{
			if ( Role < ROLE_Authority )
				ServerForceReload();
			else
				ClientForceReload();
		}
		bForceReload = false;
		PlayReloading();
	}

	simulated function AnimEnd(int Channel)
	{
		ReloadCount = Default.ReloadCount;
		if ( Role < ROLE_Authority )
			ClientFinish();
		else
			Finish();
		CheckAnimating();
	}

	function CheckAnimating()
	{
		if ( !IsAnimating() )
			warn(self$" stuck in Reloading and not animating!");
	}
}

/* Active
Bring newly active weapon up.
The weapon will remain in this state while its selection animation is being played (as well as any postselect animation).
While in this state, the weapon cannot be fired.
*/
state Active
{
	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	function ServerFire()
	{
		//log(self$" severfire, state "$GetStateName());
		bForceFire = true;
	}

	function ServerAltFire()
	{
		bForceAltFire = true;
	}

	simulated function bool PutDown()
	{
		local name anim;
		local float frame,rate;
		GetAnimParams(0,anim,frame,rate);
		if ( bWeaponUp || (frame < 0.75) )
			GotoState('DownWeapon');
		else
			bChangeWeapon = true;
		return True;
	}

	simulated function BeginState()
	{
		Instigator = Pawn(Owner);
		bForceFire = false;
		bForceAltFire = false;
		bWeaponUp = false;
		bChangeWeapon = false;
	}

	simulated function EndState()
	{
		bForceFire = false;
		bForceAltFire = false;
	}

	simulated function AnimEnd(int Channel)
	{
		if ( bChangeWeapon )
			GotoState('DownWeapon');
		if ( Owner == None )
		{
			//log(self$" no owner");
			Global.AnimEnd(0);
			GotoState('');
		}
		else if ( bWeaponUp )
		{
			if ( Role == ROLE_Authority )
				Finish();
			else
				ClientFinish();
		}
		else
		{
			PlayPostSelect();
			bWeaponUp = true;
		}
		CheckAnimating();
	}

	function CheckAnimating()
	{
		if ( !IsAnimating() )
			warn(self$" stuck in Active and not animating!");
	}
}

/* DownWeapon
Putting down weapon in favor of a new one.  No firing in this state
*/
State DownWeapon
{
	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	function ServerFire() {}
	function ServerAltFire() {}

	simulated function bool PutDown()
	{
		return true; //just keep putting it down
	}

	simulated function AnimEnd(int Channel)
	{
		Pawn(Owner).ChangedWeapon();
	}

	simulated function BeginState()
	{
		bChangeWeapon = false;
		bMuzzleFlash = false;
		TweenDown();
	}
}

/* 
Fire on the client side. This state is only entered on the network client of the player that is firing this weapon. 
*/
state ClientFiring
{
	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	simulated function AnimEnd(int Channel)
	{
		ClientFinish();
		CheckAnimating();
	}

	function CheckAnimating()
	{
		if ( !IsAnimating() )
			warn(self$" stuck in ClientFiring and not animating!");
	}

	simulated function EndState()
	{
		AmbientSound = None;
		if ( RepeatFire() && !bPendingDelete )
			ServerStopFiring();
	}
}

/* PendingClientWeaponSet
Weapon on network client side may be set here by the replicated function ClientWeaponSet(), to wait,
if needed properties have not yet been replicated.  ClientWeaponSet() is called by the server to 
tell the client about potential weapon changes after the player runs over a weapon (the client 
decides whether to actually switch weapons or not.
*/
State PendingClientWeaponSet
{
	simulated function Timer()
	{
		if ( Pawn(Owner) != None )
			ClientWeaponSet(false);
	}

	simulated function BeginState()
	{
		SetTimer(0.05, true);
	}

	simulated function EndState()
	{
		SetTimer(0.0, false);
	}
}

simulated function BringUp()
{
	if ( Instigator.IsHumanControlled() )
	{
		SetHand(PlayerController(Instigator.Controller).Handedness);
		PlayerController(Instigator.Controller).EndZoom();
	}	
	bWeaponUp = false;
	PlaySelect();
	GotoState('Active');
}

simulated function bool PutDown()
{
	bChangeWeapon = true;
	return true; 
}

simulated function TweenDown()
{
	local name Anim;
	local float frame,rate;

	if ( IsAnimating() && AnimIsInGroup(0,'Select') )
	{
		GetAnimParams(0,Anim,frame,rate);
		TweenAnim( Anim, frame * 0.4 );
	}
	else
		PlayAnim('Down', 1.0, 0.05);
}

simulated function PlayReloading()
{
	AnimEnd(0);
}

simulated function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	if ( !IsAnimating() || !AnimIsInGroup(0,'Select') )
		PlayAnim('Select',1.0,0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, 1.0);	
}

simulated function PlayPostSelect()
{
	GotoState('Idle');
	AnimEnd(0);
}

simulated function PlayIdleAnim()
{
}

simulated function zoom();

// vr 927
     //shakemag=300.000000
     //shaketime=0.100000
     //shakevert=(X=0.0,Y=0.0,Z=5.00000)
	 //shakespeed=(X=100.0,Y=100.0,Z=100.0)
defaultproperties
{
	AttachmentClass=class'WeaponAttachment'
	bReplicateInstigator=true
	DisplayFOV=+85.0
	drawtype=DT_Mesh
	FireAdjust=1.0
	 bCanThrow=true
     aimerror=550.000000
     AIRating=0.500000
	 ItemName="Weapon"
     MessageNoAmmo=" has no ammo."
     AutoSwitchPriority=1
     InventoryGroup=1
     PlayerViewOffset=(X=30.000000,Z=-5.000000)
	 MuzzleScale=1.0
	 FlashLength=+0.1
	 Icon=Texture'S_Weapon'
	 NameColor=(R=255,G=255,B=255,A=255)
	 TraceDist=+10000.0
	 MaxRange=+8000.0
	 // vr 2141
	ShakeOffsetMag=(X=1.0,Y=1.0,Z=1.0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=2
	ShakeRotMag=(X=50.0,Y=50.0,Z=50.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=2
}
