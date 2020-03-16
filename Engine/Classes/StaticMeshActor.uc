//=============================================================================
// StaticMeshActor.
// An actor that is drawn using a static mesh(a mesh that never changes, and
// can be cached in video memory, resulting in a speed boost).
//=============================================================================

class StaticMeshActor extends Actor
	native
	hidecategories(Karma)
	placeable;
	
// RWS Change 01/23/03	Added ability to allow static mesh actors to hurt pawns
// Because it works with Bump, this doesn't work great, but it basically imparts this much damage
// each time you bump it
var()	class<damageType>	MyDamageType;	// Damage delivered
var()	float				DamagePerHit;
var()	float				ThrowStrength;	// How hard you get thrown away from thing when you get hurt

function Bump( actor Other )
{
	local vector awayvec;
	local vector throwvec;

   If(MyDamageType != None)
	{
	if(ThrowStrength > 0)
	{
		awayvec = Other.Location - Location;
		throwvec = awayvec;
		// throw him up in the air too
		throwvec = ThrowStrength*Normal(throwvec);
		throwvec.z = 5000;
	}
	Other.TakeDamage(DamagePerHit, None, (Other.Location + Location)/2, throwvec, MyDamageType);
   }
}

defaultproperties
{
	DrawType=DT_StaticMesh
	bEdShouldSnap=True
	bStatic=True
	bStaticLighting=True
	bShadowCast=True
	bCollideActors=True
	bBlockActors=True
	bBlockPlayers=True
	bWorldGeometry=True
    CollisionHeight=+000001.000000
	CollisionRadius=+000001.000000
	bAcceptsProjectors=True

	//ShadowTextureClass=Class'Engine.RevShadow256'
	//SUpdateRate=0.030000
	//SVisibleRadius=2000.000000
	//SLightDistance=170.000000
	//STraceDistance=300.000000
	//SDirection=(X=-0.500000,Y=-1.000000,Z=2.000000)
	//SActive=false
	//bUseGlobalShadowSettings=false
}