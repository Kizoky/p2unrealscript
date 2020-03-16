///////////////////////////////////////////////////////////////////////////////
// Postal2 Damage
//
///////////////////////////////////////////////////////////////////////////////
class P2Damage extends DamageType
	abstract;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var bool bCanKill;		//	Most things default to true. But some things like
						// window damage default to false so you don't have cheap kills
var bool bNonLethal;	// Unlike bCanKill, this is for specific weapons like the bean bag that
						// are designed not to inflict bodily harm, but cause a knockout.
var bool bNoKillPlayers;//	Similar to above, but defaults to false. When true, it will kill
						// NPCs if necessary, but *won't* allow players to die by this damage.

var bool bMeleeDamage;	// If it's something like kicking, shovel hit, that sort of thing
var bool bAllowZThrow;	// Allow the momentum of the damage to throw a person in the air.
var bool bIgnoreTeams;  // If true then this thing hurts people regardless of being on the same
						// team or not
						
var bool bDamageStopsPiss;	// True if this damage type should stop the Dude for peeing. False for things like fire, gonorrhea etc.					


///////////////////////////////////////////////////////////////////////////////
// Override the emitter dependent stuff
///////////////////////////////////////////////////////////////////////////////
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

defaultproperties
{
	bCanKill=true
	bDamageStopsPiss=true
}
