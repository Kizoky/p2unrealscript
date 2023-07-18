//=============================================================================
// MrDTNadePickup.
//=============================================================================
class MrDKNadePickup extends P2WeaponPickup;

///////////////////////////////////////////////////////////////////////////////
// Copy of Engine.Pickup function
// But now we check to make sure the player isn't starting up, if it's the player
///////////////////////////////////////////////////////////////////////////////
function AnnouncePickup( Pawn Receiver )
{
	if(P2Pawn(Receiver).bPlayer
		&& P2GameInfoSingle(Level.Game) != None)
		//P2GameInfoSingle(Level.Game).WriteCoolness();
		Level.ConsoleCommand("set" @ NutsPath @ "true");

	Super.AnnouncePickup(Receiver);
}

defaultproperties
{
     //BounceSound=Sound'WeaponSounds.grenade_bounce'
	 BounceSound=Sound'WeaponSoundsToo.KGrenade_fall'	// Change by Man Chrzan: xPatch 2.0
     ShortSleeveType=Class'MrDKNadeWeaponSS'
     bNoBotPickup=True
     MaxDesireability=-1.000000
     InventoryType=Class'MrDKNadeWeapon'
     PickupMessage="You picked up a Krotchy Grenade!"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'P2R_Meshes_D.Weapons.KrotchyPickup'
     DrawScale=0.170000
     CollisionRadius=45.000000
     CollisionHeight=30.000000
}
