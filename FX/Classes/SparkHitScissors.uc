//=============================================================================
// SparkHitProjectile.
//
// Most smaller projectiles should use this for hits
//=============================================================================
class SparkHitScissors extends SparkHitProjectile;

var Sound	ScissorsBounce;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	PlaySound(ScissorsBounce,,1.0,false,200.0,GetRandPitch());
}

defaultproperties
{
	 ScissorsBounce=Sound'WeaponSounds.scissors_bounce'
}
