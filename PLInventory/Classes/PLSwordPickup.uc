class PLSwordPickup extends P2WeaponPickup;

const SordPath = "PLBase.PLPlayer bSord";

///////////////////////////////////////////////////////////////////////////////
// Copy of Engine.Pickup function
// But now we check to make sure the player isn't starting up, if it's the player
///////////////////////////////////////////////////////////////////////////////
function AnnouncePickup( Pawn Receiver )
{
	if(P2Pawn(Receiver).bPlayer
		&& P2GameInfoSingle(Level.Game) != None)
		//P2GameInfoSingle(Level.Game).WriteCoolness();
		Level.ConsoleCommand("set" @ SordPath @ "true");

	Super.AnnouncePickup(Receiver);
}

defaultproperties
	{
	InventoryType=class'PLSwordWeapon'
	PickupMessage="You picked up the Bitch's katana!"
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'PLPickupMesh.Weapons.PU_PLSword'
	BounceSound=Sound'AWSoundFX.Machete.machetehitground'
	}