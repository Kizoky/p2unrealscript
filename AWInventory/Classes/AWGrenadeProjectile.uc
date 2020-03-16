//////////////////////////////////////////////////////////////////////////////
// AWGrenadeProjectile.
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This is the actual grenade that goes flying through the air.
//
// Ensures you can kick them back and it hits the original thrower on contact
//
///////////////////////////////////////////////////////////////////////////////
class AWGrenadeProjectile extends GrenadeProjectile;

///////////////////////////////////////////////////////////////////////////////
// Save our instigator
///////////////////////////////////////////////////////////////////////////////
function SetDropper(Pawn NewP)
{
	//log(Self$" set dropper, inst "$instigator);
	// Save our new instigator
	if(NewP != None)
		Dropper = Instigator.Controller;
	SetOwner(Instigator);
	// Save his team too.
	if(Dropper != None
		&& Dropper.PlayerReplicationInfo != None
		&& Dropper.PlayerReplicationInfo.Team != None)
		TeamIndex = Dropper.PlayerReplicationInfo.Team.TeamIndex;
	//log(self$" saved team "$TeamIndex$" saved controller "$Dropper);
}

///////////////////////////////////////////////////////////////////////////////
// Take damage or be force around
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
{
	// Don't do anything if there's no damage
	if(Dam <= 0)
		return;
	// If you're moving, you can't take damage (unless it's
	// kicking/bludgeoning from anyone or bullet damage from an npc damage, then you can take it anytime)
	if(Physics == PHYS_Projectile
		&& !(ClassIsChildOf(damageType, class'BludgeonDamage')
			|| (ClassIsChildOf(damageType, class'BulletDamage')
				&& P2Player(Instigator.Controller) == None)))
		return;

	// Make sure the one that blew it up gets the points for doing it.
	// Not for kicking, but still for scissors.
	if(!ClassIsChildOf(damageType, class'BludgeonDamage')
		|| damageType == class'CuttingDamage')
	{
	}

	//log(Self$" take damage "$instigatedby);
	// Make sure to transfer the instigator if it's a player
	if(instigatedBy != None
		&& P2Player(instigatedBy.Controller) != None)
	{
		//log(Self$" setting dropper ");
		Instigator = instigatedBy;
		SetDropper(Instigator);
	}

	Super.TakeDamage(Dam, InstigatedBy, hitlocation, momentum, damageType);
}

defaultproperties
{
}
