class Armor extends Powerups
	abstract;

var() class<DamageType>		  ProtectionType;	  // Protects against DamageType (None if non-armor).
var() int		  ArmorAbsorption;	  // Percent of damage item absorbs 0-100.
var() int		  AbsorptionPriority; // Which items absorb damage first (higher=first).
var   armor		  NextArmor;		  // Temporary list created by Armors to prioritize damage absorption.

//
// Absorb damage.
//
function int ArmorAbsorbDamage(int Damage, class<DamageType> DamageType, vector HitLocation)
{
	local int ArmorDamage;

	if ( DamageType.default.bArmorStops )
		ArmorImpactEffect(HitLocation);
	if( (DamageType!=None) && (ProtectionType==DamageType) )
		return 0;
	
	if ( !DamageType.default.bArmorStops ) Return Damage;
	
	ArmorDamage = (Damage * ArmorAbsorption) / 100;
	if( ArmorDamage >= Charge )
	{
		ArmorDamage = Charge;
		Destroy();
	}
	else 
		Charge -= ArmorDamage;
	return (Damage - ArmorDamage);
}

//
// Return armor value.
//
function int ArmorPriority(class<DamageType> DamageType)
{
	if ( DamageType.default.bArmorStops )
		return 0;
	if( (DamageType!=None) && (ProtectionType==DamageType) )
		return 1000000;

	return AbsorptionPriority;
}

//
// This function is called by ArmorAbsorbDamage and displays a visual effect 
// for an impact on an armor.
//
function ArmorImpactEffect(vector HitLocation);

state Activated
{
	function BeginState()
	{
		Super.BeginState();
		if ( ProtectionType != None )
			Pawn(Owner).ReducedDamageType = ProtectionType;
	}

	function EndState()
	{
		Super.EndState();
		if ( (Pawn(Owner) != None) && (ProtectionType != Pawn(Owner).ReducedDamageType) )
			Pawn(Owner).ReducedDamageType = None;
	}
}

//
// Return the best armor to use.
//
function armor PrioritizeArmor( int Damage, class<DamageType> DamageType, vector HitLocation )
{
	local Armor FirstArmor, InsertAfter;

	if ( Inventory != None )
		FirstArmor = Inventory.PrioritizeArmor(Damage, DamageType, HitLocation);
	else
		FirstArmor = None;

	if ( FirstArmor == None )
	{
		nextArmor = None;
		return self;
	}

	// insert this armor into the prioritized armor list
	if ( FirstArmor.ArmorPriority(DamageType) < ArmorPriority(DamageType) )
	{
		nextArmor = FirstArmor;
		return self;
	}
	InsertAfter = FirstArmor;
	while ( (InsertAfter.nextArmor != None) 
		&& (InsertAfter.nextArmor.ArmorPriority(DamageType) > ArmorPriority(DamageType)) )
		InsertAfter = InsertAfter.nextArmor;

	nextArmor = InsertAfter.nextArmor;
	InsertAfter.nextArmor = self;

	return FirstArmor;
}

defaultproperties
{
}