//=============================================================================
// AWHeadCow
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
//=============================================================================
class AWHeadMadCow extends AWHeadCow
	placeable;

var AWCowPawn MyZombie;		// Same as MyBody but we keep it becuase
							// zombie cows don't die till the head is dead (usually)
var Pawn LastHurter;		// Person who last hurt us


///////////////////////////////////////////////////////////////////////////////
// Move around or explode
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
					Vector momentum, class<DamageType> ThisDamage)
{
	if(Dam > 0)
		// Save who last hurt you
		LastHurter = instigatedBy;

	Super.TakeDamage(Dam, InstigatedBy, HitLocation, momentum, ThisDamage);
}

///////////////////////////////////////////////////////////////////////////////
// When I blow up, kill my zombie body, unless we're floating
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	if(MyZombie != None)
		MyZombie.TakeDamage(MyZombie.Health, LastHurter, MyZombie.Location, vect(0,0,0), class'HeadKillDamage');

	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     HeadBounce(0)=Sound'MiscSounds.People.head_bounce'
     HeadBounce(1)=Sound'MiscSounds.People.head_bounce2'
     Skins(0)=Texture'AW_Characters.Zombie_Cows.AW_Cow1'
}
