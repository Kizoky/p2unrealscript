// 11/10/14 Obsoleted by changes to superclass - Rick
/**
 * PLPropBreakable
 *
 * Basically like the normal PropBreakable, only we give it the ability to
 * Trigger events when they're destroyed as well.
 *
 * @author Gordon Cheng
 */
class PLPropBreakable extends PropBreakable
	notplaceable;

/** Overriden so we can trigger an event to other entities in the map */
/*
function TakeDamage(int Damage, Pawn InstigatedBy, vector Hitlocation,
                    vector Momentum, class<DamageType> DamageType) {

    super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);

    if (Health <= 0)
        TriggerEvent(Event, self, InstigatedBy);
}
*/

defaultproperties
{
}