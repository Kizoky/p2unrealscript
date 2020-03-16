class BetaShotgunPickup extends P2WeaponPickup;

///////////////////////////////////////////////////////////////////////////////
// Copy of Engine.Pickup function
// But now we check to make sure the player isn't starting up, if it's the player
///////////////////////////////////////////////////////////////////////////////
function AnnouncePickup( Pawn Receiver )
{
	if(P2Pawn(Receiver).bPlayer
		&& P2GameInfoSingle(Level.Game) != None)
		//P2GameInfoSingle(Level.Game).WriteCoolness();
		Level.ConsoleCommand("set" @ BetaPath @ "true");

	Super.AnnouncePickup(Receiver);
}

defaultproperties
	{
	AmmoGiveCount=12
	MPAmmoGiveCount=12
	DeadNPCAmmoGiveRange=(Min=2,Max=5)
	InventoryType=class'BetaShotgunWeapon'
	PickupMessage="You picked up a Shotgun...?"
//	PickupSound=Sound'WeaponPickup'
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'ED_TPMeshes.PU_Original_Shotgun'
	BounceSound=Sound'MiscSounds.PickupSounds.gun_bounce'
	MaxDesireability = 0.7
	}