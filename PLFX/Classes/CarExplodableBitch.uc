///////////////////////////////////////////////////////////////////////////////
// CarExplodableBitch
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
//
// Same as the car explodable but it explodes on contact with anything, especially the dude
///////////////////////////////////////////////////////////////////////////////
class CarExplodableBitch extends CarExplodable;

// Explode on contact.
event KImpact(actor other, vector pos, vector impactVel, vector impactNorm)
{
	if (!bBlownUp)
		BlowThisUp(Location, ImpactVel);
	else
		Super.KImpact(Other, Pos, ImpactVel, ImpactNorm);
}

event Touch(actor Other)
{
	//log(self@"TOUCH"@Other);
	Other.Touch(self);
	Super.Touch(Other);
}