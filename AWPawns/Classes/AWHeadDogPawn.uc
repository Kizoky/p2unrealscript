///////////////////////////////////////////////////////////////////////////////
// AWHeadDogPawn for Postal 2 AW
//
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
// Eats zombie heads, invincible.
// They're meant as an aid to the player so they don't always have to hunt
// down decapped zombie heads and blow them up--this dog will do it for them
// Supposed to ignore as many things as possible
//
// Removed in the end, near the end of the game. The thought is, he's a little
// buggy and looks bad, climbing up and down ladders, and the player (now)
// has so many different ways to blow up, cut up, shoot up decapitated zombie
// heads that the dog could be removed. 
//
///////////////////////////////////////////////////////////////////////////////
class AWHeadDogPawn extends AWDogPawn;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// consts
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
// Head dogs are invicible
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
					Vector momentum, class<DamageType> ThisDamage)
{
	// STUB
}

defaultproperties
{
     bIgnoresSenses=True
     bIgnoresHearing=True
     ControllerClass=Class'AWPawns.AWHeadDogController'
     Skins(0)=Texture'AnimalSkins.Cow'
}
