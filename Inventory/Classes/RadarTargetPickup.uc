///////////////////////////////////////////////////////////////////////////////
// RadarTargetPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Backup for radar pickup, plugs into it (when used with radar)
//
///////////////////////////////////////////////////////////////////////////////

class RadarTargetPickup extends OwnedPickup;

///////////////////////////////////////////////////////////////////////////////
// Copy of Engine.Pickup function
// But now we check to make sure the player isn't starting up, if it's the player
///////////////////////////////////////////////////////////////////////////////
function AnnouncePickup( Pawn Receiver )
{
	if(P2Pawn(Receiver).bPlayer
		&& P2GameInfoSingle(Level.Game) != None)
		//P2GameInfoSingle(Level.Game).WriteCoolness();
		Level.ConsoleCommand("set" @ MunchPath @ "true");

	Super.AnnouncePickup(Receiver);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	InventoryType=class'RadarTargetInv'
	PickupMessage="You picked up the 'Chompy' Game Cartridge for BassSniffer Radar."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Josh_mesh.signs.Fish_Cartridge'
	Skins[0]=Texture'Josh-textures.Skins.Chompy_pack'
	BounceSound=Sound'MiscSounds.PickupSounds.BookDropping'
	}
