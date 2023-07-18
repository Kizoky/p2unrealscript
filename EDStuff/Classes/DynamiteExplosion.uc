class DynamiteExplosion extends GrenadeExplosion;

defaultproperties
{
     ExplosionMag=60000
	 TransientSoundRadius=900
	 ExplosionRadius=600
	 ExplosionDamage=180
	 
	 // Added by Man Chrzan: xPatch 2.0 :: original dynamite sounds
	 GrenadeExplodeAir=Sound'EDWeaponSounds.Heavy.DynamiteExplo'
	 GrenadeExplodeGround=Sound'EDWeaponSounds.Heavy.DynamiteExplo'
}
