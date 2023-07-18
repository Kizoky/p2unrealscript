///////////////////////////////////////////////////////////////////////////////
// MutInstaKill.
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Insta-kill mutator.
//
// All damage done by someone else (eg. not falling damage) causes instant
// death.
//
///////////////////////////////////////////////////////////////////////////////
class MutInstaKill extends Mutator;

const SUPER_KILL	=	100000.0f;

///////////////////////////////////////////////////////////////////////////////
// Make all weapons super strong (also, explosions, fire, projectiles, etc)
///////////////////////////////////////////////////////////////////////////////
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local P2AmmoInv pammo;
	local Explosion exp;
	local P2Projectile proj;
	local FireEmitter firem;

	pammo = P2AmmoInv(Other);

	if(pammo != None)
	{
		if(pammo.DamageAmount > 0)
			pammo.DamageAmount=SUPER_KILL;
		if(pammo.AltDamageAmount > 0)
			pammo.AltDamageAmount=SUPER_KILL;
		if(pammo.DamageAmountMP > 0)
			pammo.DamageAmountMP=SUPER_KILL;
		if(pammo.AltDamageAmountMP > 0)
			pammo.AltDamageAmountMP=SUPER_KILL;
	}
	else
	{
		exp = Explosion(Other);
		if(exp != None)
		{
			exp.ExplosionDamage=SUPER_KILL;
			exp.ExplosionDamageMP=SUPER_KILL;
		}
		else 
		{
			proj = P2Projectile(Other);
			if(proj != None)
			{
				proj.Damage=SUPER_KILL;
				proj.DamageMP=SUPER_KILL;
			}
			else
			{
				firem = FireEmitter(Other);
				if(firem != None)
				{
					firem.Damage=SUPER_KILL;
				}
			}
		}
	}
	return true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool MutatorIsAllowed()
{
	return true;
}

defaultproperties
{
	GroupName="InstaKill"
	FriendlyName="Instant Kill"
	Description="Causes instant death by any weapon, explosion or fire."
}