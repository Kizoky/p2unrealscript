///////////////////////////////////////////////////////////////////////////////
//
// BarrelExplodable
//
// Karma object that blows up when hit by somethings
// (it's filled with gasoline)
//
///////////////////////////////////////////////////////////////////////////////
class BarrelExplodable extends KActorExplodable;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Modify the hit information, so it ridiculously flies up into the air
// and falls back over, while on fire
// put it below the object
///////////////////////////////////////////////////////////////////////////////
function CalcExplosionPhysics(out vector HitLocation, 
							  out vector Momentum)
{
	local float exp;

	HitLocation = Location;
	HitLocation.x += (FRand()*CollisionRadius) - CollisionRadius/2;
	HitLocation.y += (FRand()*CollisionRadius) - CollisionRadius/2;
	HitLocation.z -= CollisionRadius;

	Momentum.z = ExplosionMag;
	exp = ExplosionMag*0.4;
	Momentum.x=FRand()*exp - exp/2;
	Momentum.y=FRand()*exp - exp/2;
}


defaultproperties
{
    Begin Object Class=KarmaParams Name=KarmaParams0
        Name="KarmaParams0"
        KFriction=0.90000
    End Object
    KParams=KarmaParams'KarmaParams0'

	Health=5
	CollisionRadius=30
	CollisionHeight=50
	ExplosionMag=80000
	BurningEmitterClass=class'FireSizeableEmitter'
	ExplosionEmitterClass=class'SizeableWoof'
	WoofConversion=0.0015
	StaticMesh=StaticMesh'Zo_Meshes.Karma.zo_barrel1'
	BrokenStaticMesh=StaticMesh'Zo_Meshes.Karma.zo_barrel_exploded'
}

