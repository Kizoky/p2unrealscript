class xMutator extends DMMutator;

function bool MutatorIsAllowed()
{
	return !Level.IsDemoBuild() || Class==class'xMutator';
}

function PlayerChangedClass(Controller aPlayer)	// Should be subclassed
{
/* RWS CHANGE: We don't have stationary weapons, so this was removed
	local WarfareStationaryWeapon W;

	foreach AllActors(class 'WarfareStationaryWeapon', W)
	{
		if (W.Owner == aPlayer)	// Destroy all Stationary Weapons belonging to this player
			W.Explode(W.Location,vect(0,0,0));
	}
*/
}

defaultproperties
{

}
