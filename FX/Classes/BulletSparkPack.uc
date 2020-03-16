///////////////////////////////////////////////////////////////////////////////
// BulletSparkPack
//
///////////////////////////////////////////////////////////////////////////////
class BulletSparkPack extends BulletHitPack;

simulated function MakeMoreEffects()
{
	local P2Emitter thesparks;

	if(mysparkclass != None)
	{
		thesparks = Spawn(mysparkclass,Owner,,Location,Rotation);
		thesparks.PlaySound(RicHit[Rand(ArrayCount(RicHit))],,,,,GetRandPitch());
	}
}

defaultproperties
{
	mysparkclass=Fx.SparkHitMachineGun
}
