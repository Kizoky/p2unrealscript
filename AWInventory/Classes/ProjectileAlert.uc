///////////////////////////////////////////////////////////////////////////////
// ProjectileAlert
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Tell people a projectile (like a flying machete) is coming so
// they can block it if they want.
///////////////////////////////////////////////////////////////////////////////
class ProjectileAlert extends Keypoint;

///////////////////////////////////////////////////////////////////////////////
// Tell things that you hit them, so they know what to do with you coming
// their way.
///////////////////////////////////////////////////////////////////////////////
function Touch(Actor Other)
{
	// If projectile hits area and it's the players, tell your owner about it
	if(PersonPawn(Other) != None
		&& Projectile(Owner) != None)
	{
		PersonPawn(Other).BlockMelee(Owner);
	}
}

defaultproperties
{
     bStatic=False
     CollisionRadius=200.000000
     CollisionHeight=80.000000
     bCollideActors=True
}
