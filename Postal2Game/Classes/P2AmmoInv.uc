///////////////////////////////////////////////////////////////////////////////
// Postal 2 buffer for Ammunition. We call it AmmoInv so you know it goes in
// your inventory and the other ammo, is AmmoPickup, the kind you see sitting
// around in the level.
///////////////////////////////////////////////////////////////////////////////

class P2AmmoInv extends Ammunition
	abstract;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var float	DamageAmount;				// How much this ammo takes away from something
var float	AltDamageAmount;			// How much this alt ammo takes away from something
var float	MomentumHitMag;				// Momentum given from hit
var float	AltMomentumHitMag;			// Momentum given from alt hit
var class<DamageType>	DamageTypeInflicted;	// What type of damage you take from the thing hit
var class<DamageType>	AltDamageTypeInflicted;	// What type of altdamage you take from the thing hit
var bool    bInfinite;					// If I have infinite ammo or not
var bool	bShowAmmoOnHud;				// If we display our ammo on the hud. Most infinite things dont'
var bool	bShowMaxAmmoOnHud;			// If you are to display the max ammo on the hud
var bool	bShowAmmoAsPercent;			// If true displays ammo as a percentage of maximum instead of units
var int		AmmoCountPerShot;			// How much ammo I take with each shot
var travel bool	bReadyForUse;			// Defaults to true, for most weapons, but some use it as follows:
										// Only set to true, when someone has pressed
										// the specific key to initiate this weapon. Don't
										// allow this weapon to be selected like normal, 
										// but do put it in the inventory. (like the foot or the urethra)

// Multiplayer only values
var float	DamageAmountMP;				// How much this ammo takes away from something
var float	AltDamageAmountMP;			// How much this alt ammo takes away from something
var int		MaxAmmoMP;					// Not referenced, but simply pushed into the MaxAmmo value
										// in MP games, if it's > 0.

var const localized string TooMuchAmmoHint;

const MAX_AMMO_ENHANCED = 9999;


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	Super.PostBeginPlay();
	if (P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime())
		// Let 'em have lots and lots of ammo in enhanced mode
		MaxAmmo = MAX_AMMO_ENHANCED;
}	

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	// If it's a multiplayer game, and they have a maxammo specified, use that instead.
	if((Level.Game == None
			|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		&& MaxAmmoMP > 0)
	{
		MaxAmmo = MaxAmmoMP;
	}	
}

///////////////////////////////////////////////////////////////////////////////
// The first time this is added, this should be called, to do any extra
// setup
///////////////////////////////////////////////////////////////////////////////
function AddedToPawnInv(Pawn UsePawn, Controller UseCont)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Overrides engine version just to put up extra hud message.
// This is what gets called when you already have this ammo and it's checking
// to grab the new pickup.
///////////////////////////////////////////////////////////////////////////////
function bool HandlePickupQuery( pickup Item )
{
	if ( class == item.InventoryType ) 
	{
		if (AmmoAmount==MaxAmmo) 
		{
			if(P2Player(Instigator.Controller) != None)
				P2Player(Instigator.Controller).MyHUD.LocalizedMessage(class'PickupMessagePlus', ,,,,TooMuchAmmoHint);
			return true;
		}
		// Multiplayer has different balancing for how much ammo you get with things
		if(Level.Game != None
			&& FPSGameInfo(Level.Game).bIsSinglePlayer)
			AddAmmo(Ammo(item).AmmoAmount);
		else
			AddAmmo(P2AmmoPickup(item).MPAmmoAmount);
		item.AnnouncePickup(Pawn(Owner));
		return true;				
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

///////////////////////////////////////////////////////////////////////////////
// Default to act just like HasAmmo.
// This only gets called when the gun is finished shooting. Some weapons, like
// the shocker, can't fire again for a while, but shouldn't switch when you're
// finished shooting them.
///////////////////////////////////////////////////////////////////////////////
simulated function bool HasAmmoFinished()
{
	return HasAmmo();
}

///////////////////////////////////////////////////////////////////////////////
// Doesn't check weapon/ammo readiness, just checks if you have ammo in some
// way or another.
///////////////////////////////////////////////////////////////////////////////
simulated function bool HasAmmoStrict()
{
	return (bInfinite
			|| (AmmoAmount > 0));
}

///////////////////////////////////////////////////////////////////////////////
// Just a little randomness for the pitch, around 1.0
///////////////////////////////////////////////////////////////////////////////
function float GetRandPitch()
{
	return (0.96 + FRand()*0.08);
}

///////////////////////////////////////////////////////////////////////////////
// If it's a person using a weapon, make sure they only hurt their
// attacker. Usually used for NPC's to only hurt their attacker when they use
// a melee weapon
///////////////////////////////////////////////////////////////////////////////
function bool HurtingAttacker(FPSPawn Other)
{
	if(Other != None
		&& Instigator != None)
	{
		if(PersonController(Instigator.Controller) != None)
		{
			if(PersonController(Instigator.Controller).Attacker == Other)
				return true;	// NPC Attacking attacker
			else
				return false;
		}
		else
			return true;	// Dude/Animal attacking
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Take some ammo
///////////////////////////////////////////////////////////////////////////////
function UseAmmoForShot(optional float UseThisAmmo)
{
	if(UseThisAmmo == 0)
		UseThisAmmo = AmmoCountPerShot;
	if(!bInfinite)
		AmmoAmount-=UseThisAmmo;
}

defaultproperties
{
	TooMuchAmmoHint="You're already at full ammo."
	AmmoCountPerShot=1
	bShowAmmoOnHud=true
	bReadyForUse=true
	TransientSoundRadius=100
	bStasis=true
}