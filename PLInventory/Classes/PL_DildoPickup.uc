class PL_DildoPickup extends P2WeaponPickup;

const DongPath = "PLBase.PLPlayer bDong";

///////////////////////////////////////////////////////////////////////////////
// Copy of Engine.Pickup function
// But now we check to make sure the player isn't starting up, if it's the player
///////////////////////////////////////////////////////////////////////////////
function AnnouncePickup( Pawn Receiver )
{
	if(P2Pawn(Receiver).bPlayer
		&& P2GameInfoSingle(Level.Game) != None)
		//P2GameInfoSingle(Level.Game).WriteCoolness();
		Level.ConsoleCommand("set" @ DongPath @ "true");

	Super.AnnouncePickup(Receiver);
}

defaultproperties
{
     BounceSound=Sound'MiscSounds.Props.woodhitsground1'
     InventoryType=Class'PL_DildoWeapon'
     PickupMessage="You picked up a Dildo."
     DrawType=DT_StaticMesh
     RelativeRotation=(Roll=16383)
     StaticMesh=StaticMesh'MrD_PL_Mesh.Weapons.GimpsDildoWeapon'
     DrawScale=1.000000
}
