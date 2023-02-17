///////////////////////////////////////////////////////////////////////////////
// Ensmallen Ammo
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Ensmallen ammo
///////////////////////////////////////////////////////////////////////////////
class EnsmallenAmmoInv extends InfiniteAmmoInv;

///////////////////////////////////////////////////////////////////////////////
// ProcessTraceHit
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local EnsmallenHelper MyHelper;
	local EnsmallenTrigger ET;
	local bool bDontShrink;

	Other.TakeDamage(0, Pawn(Owner), HitLocation, vect(0,0,0), DamageTypeInflicted);

	// Cheap shrink for testing
	if (P2Pawn(Other) != None && P2Pawn(Owner) != None && !Other.IsA('MutantChamp'))
	{
		// Check to see if any Ensmallen Triggers want to do anything
		foreach DynamicActors(class'EnsmallenTrigger', ET)
			bDontShrink = bDontShrink || ET.MaybeTrigger(Pawn(Other), Pawn(Owner));

		// If we didn't spawn a cutscene, shrink the target normally
		if (!bDontShrink)
		{
			MyHelper = Spawn(class'EnsmallenHelper', Owner);
			if (MyHelper != None)
			{
				MyHelper.Setup(P2Pawn(Owner), P2Pawn(Other));
				EnsmallenWeapon(W).MyHelper = MyHelper;
			}
		}
	}
}

defaultproperties
{
	Texture=Texture'PLHud.Icons.Icon_Weapon_Ensmallen'
	DamageTypeInflicted=class'EnsmallenDamage'
}