/**
 * LeprechaunExplosion
 *
 * Just a harmless POOF! type explosion for when the Leprechaun is either
 * killed or has jumped into his Pot of Gold
 */
class LeprechaunExplosion extends NapalmExplosion;

defaultproperties
{
    ExplosionRadius=0.0f
	ExplosionDamage=0.0f

	MyDamageType=class'GrenadeDamage'
}