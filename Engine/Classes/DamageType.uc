//=============================================================================
// DamageType, the base class of all damagetypes.
// this and its subclasses are never spawned, just used as information holders
//=============================================================================
class DamageType extends Actor
	native
	abstract;

	
// Used to describe the type of damage.  

const DAMAGE_None      		= 0;
const DAMAGE_Light     		= 1;
const DAMAGE_Medium	   		= 2;
const DAMAGE_Heavy     		= 4;
const DAMAGE_Fatal     		= 8;
const DAMAGE_Explosive 		= 16;
const DAMAGE_Energy	   		= 32;
const DAMAGE_ArmorKiller	= 64;

// Description of a type of damage.
var() localized string     DeathString;	 					// string to describe death by this type of damage
var() localized string		FemaleSuicide, MaleSuicide;	
var() float                ViewFlash;    					// View flash to play.
var() vector               ViewFog;      					// View fog to play.
var() class<effects>       DamageEffect; 					// Special effect.
var() string			   DamageWeaponName; 				// weapon that caused this damage
var() bool					bArmorStops;					// does regular armor provide protection against this damage
var() bool					bInstantHit;					// done by trace hit weapon
var() bool					bFastInstantHit;				// done by fast repeating trace hit weapon
var() float					GibModifier;

// these effects should be none if should use the pawn's blood effects
var() class<Effects>		PawnDamageEffect;	// effect to spawn when pawns are damaged by this damagetype
var() class<Emitter>		PawnDamageEmitter;	// effect to spawn when pawns are damaged by this damagetype
var() array<Sound>			PawnDamageSounds;	// Sound Effect to Play when Damage occurs	

var() class<Effects>		LowGoreDamageEffect; 	// effect to spawn when low gore
var() class<Emitter>		LowGoreDamageEmitter;	// Emitter to use when it's low gore
var() array<Sound>			LowGoreDamageSounds;	// Sound Effects to play with Damage occurs with low gore 	

var() class<Effects>		LowDetailEffect;		// Low Detail effect
var() class<Emitter>		LowDetailEmitter;		// Low Detail emitter	

var() float					FlashScale;		//for flashing victim's screen
var() vector				FlashFog;

var() int					DamageDesc;			// Describes the damage
var() int					DamageThreshold;	// How much damage much occur before playing effects

var() vector				DamageKick;			// How much Pitch (Z) and Yaw (X) get applied when this damage occurs.  Negative Values
												// apply.

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	return Default.DeathString;
}

static function string SuicideMessage(PlayerReplicationInfo Victim)
{
	if ( Victim != None
		&& Victim.bIsFemale )
		return Default.FemaleSuicide;
	else
		return Default.MaleSuicide;
}

static function class<Effects> GetPawnDamageEffect( vector HitLocation, float Damage, vector Momentum, Pawn Victim, bool bLowDetail )
{
	if ( class'GameInfo'.Default.GoreLevel > 0 )
	{
		if ( Default.LowGoreDamageEffect != None )
			return Default.LowGoreDamageEffect;
		else
			return Victim.LowGoreBlood;
	}
	else if ( bLowDetail )
	{

		if ( Default.LowDetailEffect != None )
			return Default.LowDetailEffect;
		else
			return Victim.LowDetailBlood;
	}
	else
	{
		if ( Default.PawnDamageEffect != None )
			return Default.PawnDamageEffect;
		else
			return Victim.BloodEffect;
	}
}

static function class<Emitter> GetPawnDamageEmitter( vector HitLocation, float Damage, vector Momentum, Pawn Victim, bool bLowDetail )
{
	if ( class'GameInfo'.Default.GoreLevel > 0 )
	{
		if ( Default.LowGoreDamageEmitter != None )
			return Default.LowGoreDamageEmitter;
		else
			return none;
	}
	else if ( bLowDetail )
	{

		if ( Default.LowDetailEffect != None )
			return Default.LowDetailEmitter;
		else
			return none;
	}
	else
	{
		if ( Default.PawnDamageEmitter != None )
			return Default.PawnDamageEmitter;
		else
			return none;
	}
}

static function Sound GetPawnDamageSound()
{
	if ( class'GameInfo'.Default.GoreLevel > 0 )
	{
		if (Default.LowGoreDamageSounds.Length>0)
			return Default.LowGoreDamageSounds[Rand(Default.LowGoreDamageSounds.Length)];
		else
			return none;
	}
	else
	{
		if (Default.PawnDamageSounds.Length>0)
			return Default.PawnDamageSounds[Rand(Default.PawnDamageSounds.Length)];
		else
			return none;
	}
}

static function bool IsOfType(int Description)
{
	local int result;
	
	result = Description & Default.DamageDesc;
	return (result == Description);
} 

defaultproperties
{
     DeathString="%o was killed by %k."
	 FemaleSuicide="%o killed herself."
	 MaleSuicide="%o killed himself."
	 bArmorStops=true
	 GibModifier=+1.0
	 FlashScale=-0.019
	 FlashFog=(X=26.500000,Y=4.500000,Z=4.500000)
	 DamageDesc=1
	 DamageThreshold=0
}
