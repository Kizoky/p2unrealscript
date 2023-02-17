///////////////////////////////////////////////////////////////////////////////
// WeedPickup
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
class WeedPickup extends P2WeaponPickup;

const WeedPath = "PLBase.PLPlayer bWeed";

///////////////////////////////////////////////////////////////////////////////
// Copy of Engine.Pickup function
// But now we check to make sure the player isn't starting up, if it's the player
///////////////////////////////////////////////////////////////////////////////
function AnnouncePickup( Pawn Receiver )
{
	if(P2Pawn(Receiver).bPlayer
		&& P2GameInfoSingle(Level.Game) != None)
		//P2GameInfoSingle(Level.Game).WriteCoolness();
		Level.ConsoleCommand("set" @ WeedPath @ "true");

	Super.AnnouncePickup(Receiver);
}

defaultproperties
{
	AmmoGiveCount=10
	DeadNPCAmmoGiveRange=(Min=5.000000,Max=10.000000)
	BounceSound=Sound'MiscSounds.Props.MetalCrateDoor'
	ShortSleeveType=Class'WeedWeapon'
	InventoryType=Class'WeedWeapon'
	PickupMessage="You picked up a weed whacker."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'PL_WeedWhackerStatics.weedeater_static'
	DrawScale=1.0
	Rotation=(Yaw=-16384)
}
