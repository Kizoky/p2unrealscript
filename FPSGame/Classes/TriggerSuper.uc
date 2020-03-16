///////////////////////////////////////////////////////////////////////////////
// TriggerSuper
//
// Put anything in here we don't feel like putting into the lower level Trigger
// that Epic may have forgotten.
//
// First thing being, to make TT_Shoot, filter damage types to make it more generally
// useful.
//
///////////////////////////////////////////////////////////////////////////////
class TriggerSuper extends Trigger;

var() class<DamageType> DamageFilter;// Damage type we're concerned about.
									// To allow all damage types, have this be none (default)
var() bool bBlockFilter;			// true means you'll accept all damages except DamageFilter
									// false means you'll only accept DamageFilter.(default is false)


///////////////////////////////////////////////////////////////////////////////
// If DamageFilter is set, 
// and bBlockFilter is false only allow this damage
// else don't allow only this damage
///////////////////////////////////////////////////////////////////////////////
function bool AcceptThisDamage(class<DamageType> damageType)
{
	if(damageType == None)
		return true;

	if(DamageFilter != None)
	{
		// accept only filter
		if(!bBlockFilter)
		{
			if(!ClassIsChildOf(damageType, DamageFilter))
				return false;
		}
		else	// block the filter type
		{
			if(ClassIsChildOf(damageType, DamageFilter))
				return false;
		}
	}

	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Make sure to filter damages first
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	if(AcceptThisDamage(damageType))
	{
		Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
	}
}

defaultproperties
{
	Texture=Texture'Engine.S_Trigger'
	DrawScale=0.25
}
