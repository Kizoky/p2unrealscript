/**
 * MountedWeaponTrigger
 *
 * A Trigger that we use to take "use" inputs from the player when he or she
 * hits the use key. This object will then relay use inputs to the weapon.
 *
 * @author Gordon Cheng
 */
class MountedWeaponTrigger extends UseTrigger;

var MountedWeapon MountedWeapon;

/** Notify our mounted weapon that the user has pressed the "use" key near us */
function UsedBy(Pawn User) {
    if (MountedWeapon != none)
        MountedWeapon.NotifyUse(User);
}

/** Stubbed out as we don't want to send the player hints, well maybe */
function Touch(Actor Other);

defaultproperties
{
    CollisionHeight=96.0
    CollisionRadius=64.0
	Texture=Texture'PostEd.Icons_256.mountedweapon_trigger'
}