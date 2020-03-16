class ProtestSignPickup extends P2WeaponPickup;

///////////////////////////////////////////////////////////////////////////////
// Copy of Engine.Pickup function
// But now we check to make sure the player isn't starting up, if it's the player
///////////////////////////////////////////////////////////////////////////////
function AnnouncePickup( Pawn Receiver )
{
	if(P2Pawn(Receiver).bPlayer
		&& P2GameInfoSingle(Level.Game) != None)
		//P2GameInfoSingle(Level.Game).WriteCoolness();
		Level.ConsoleCommand("set" @ ProtestPath @ "true");

	Super.AnnouncePickup(Receiver);
}

defaultproperties
{
     BounceSound=Sound'MiscSounds.Props.woodhitsground1'
     ShortSleeveType=Class'ProtestSignWeaponSS'
     InventoryType=Class'ProtestSignWeapon'
     PickupMessage="You're ready to protest."
     DrawType=DT_StaticMesh
     RelativeRotation=(Roll=16383)
     StaticMesh=StaticMesh'P2R_Meshes_D.Weapons.Protest_PU'
     DrawScale=1.0
}
