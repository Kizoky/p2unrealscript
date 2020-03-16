//=============================================================================
// anthrax in some imaginary gaseous, brown/orange form
//=============================================================================
class Anth extends Wemitter;

var		float Damage;         
var		float DamageDistMag;		// How far the radius or trace should go to hurt stuff
									// Make it seperate from the official CollisionRadius 
									// because this is just for damage and the other is const
									// and this needs to change dynamically sometimes.

var	class<DamageType> MyDamageType;
var	vector CollisionLocation;

// Kamek additions -- if our instigator is disconnected, reset it
var bool bDCdInstigator;

const SHOW_LINES = 1;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	CollisionLocation = Location;
}

function CheckToHitActors(float DeltaTime)
{
	//CheckHurtRadius(DeltaTime*Damage, DamageDistMag, MyDamageType, 0, CollisionLocation );
	
	// Calls anth-form of HurtRadiusEX
	HurtRadiusEX(DeltaTime * Damage, DamageDistMag, MyDamageType, 0, CollisionLocation,,0.5);
}

///////////////////////////////////////////////////////////////////////////////
// For some reason HurtRadius is flakey, so we use this slower version to
// make sure it hits stuff
///////////////////////////////////////////////////////////////////////////////
/*
simulated final function CheckHurtRadius( float DamageAmount, float DamageRadius, 
										 class<DamageType> DamageType, float MomMag, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist, OldHealth, DamageTaken;
	local vector dir;
	local vector Momentum;
	local bool bDoHurt;
	local PlayerController PlayerLocal;
	local bool bSuicideTaliban;
	
	foreach CollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		if( (!Victims.bHidden)
			&& (Victims != self) 
			&& (Victims.Role == ROLE_Authority) )
		{
			if (Pawn(Victims) != None)				
				OldHealth = Pawn(Victims).Health;
			else
				OldHealth = 0;
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist; 
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			DamageTaken = DamageScale * DamageAmount;
			// Round it up to 1.0 if 0.5 or higher
			if (DamageTaken >= 0.5 && DamageTaken < 1.0)
				DamageTaken = 1.0;
				
			// Don't actually do any damage unless it's going to register
			if (DamageTaken >= 1.0)
			{
				//if (Pawn(Victims) != None)
				//	log(victims@"take damage"@DamageTaken);
				Victims.TakeDamage
				(
					DamageTaken,
					Instigator, 
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					Momentum,
					DamageType
				);
			}
		} 
	}
}
*/

function Tick(float DeltaTime)
{
	// deal damage
	CheckToHitActors(DeltaTime);
	
	// Kamek additions to stop log spam when cow head users disconnect
	if (!bDCdInstigator && Instigator == None)
	{
		Instigator = None;
		bDCdInstigator = True;
	}
}

simulated event RenderOverlays( canvas Canvas )
{
/*
	//local vector endline;
	local color tempcolor;

	if(SHOW_LINES==1)
	{
		// show collision radius
		//endline = Location + vect(200, 0, 200);
		tempcolor.B=255;
		Canvas.DrawColor = tempcolor;
		Canvas.Draw3Circle(CollisionLocation, DamageDistMag, 0);
	}
	*/
}

defaultproperties
{
	Damage=100
	DamageDistMag=120
    MyDamageType=Class'AnthDamage'
}