///////////////////////////////////////////////////////////////////////////////
// LauncherPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class NukePickup extends P2WeaponPickup;

///////////////////////////////////////////////////////////////////////////////
// Copy of Engine.Pickup function
// But now we check to make sure the player isn't starting up, if it's the player
///////////////////////////////////////////////////////////////////////////////
function AnnouncePickup( Pawn Receiver )
{
	if(P2Pawn(Receiver).bPlayer
		&& P2GameInfoSingle(Level.Game) != None)
		//P2GameInfoSingle(Level.Game).WriteCoolness();
		Level.ConsoleCommand("set" @ RadPath @ "true");

	Super.AnnouncePickup(Receiver);
}

defaultproperties
{
	AmmoGiveCount=1
	MPAmmoGiveCount=1
	BounceSound=Sound'MiscSounds.Props.MetalCrateDoor'
	InventoryType=Class'NukeWeapon'
	RespawnTime=120.000000
	PickupMessage="You picked up a Mini-Nuke Launcher."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.Launcher'
	Skins(0)=Texture'AW7Tex.Nuke.nuclear_launcher_256'
	Skins(1)=ConstantColor'ConstantBlack'
	Skins(2)=ConstantColor'ConstantBlack'
	CollisionRadius=60.000000
	CollisionHeight=20.000000
}
