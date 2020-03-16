/**
 * HotBitch
 *
 * A hot bitch to chomp on your nuts! Get it? Cause it's a female dog and it
 * hates you so it goes for your family jewels... ah forget it.
 */
class HotBitch extends DogPawn;

/** Overriden so we don't change the animation, HotBitches like the fire */
function SetOnFire(FPSPawn Doer, optional bool bIsNapalm)
{
	local FireTorsoEmitter tfire;

	if (MyBodyFire == none) {
		tfire = Spawn(TorsoFireClass, self,, Location);
		tfire.SetPawns(self, Doer);
		tfire.SetFireType(bIsNapalm);
	}
}

/** Overriden so that HotBitches ignore fire damage */
function TakeDamage(int Damage, Pawn InstigatedBy, vector Hitlocation,
                    vector Momentum, class<DamageType> DamageType) {
    if (ClassIsChildOf(DamageType, class'BurnedDamage') ||
        ClassIsChildOf(DamageType, class'OnFireDamage') ||
		ClassIsChildOf(DamageType, class'UrineDamage'))
        return;

    super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
}

defaultproperties
{
    TorsoFireClass=class'HotBitchFireEmitter'
	HealthMax=160
	CatchProjFreq=0.750000
}