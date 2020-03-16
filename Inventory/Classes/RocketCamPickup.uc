///////////////////////////////////////////////////////////////////////////////
// RocketCamPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Camera that attaches to the rocket as it travels
//
///////////////////////////////////////////////////////////////////////////////

class RocketCamPickup extends GunRadarPlugPickup;


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	InventoryType=class'RocketCamInv'
	PickupMessage="You picked up some Rocket Cameras."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Josh_mesh.signs.Fish_Cartridge'
	Skins[0]=Texture'Josh-textures.Skins.RocketCam_pack'
	BounceSound=Sound'MiscSounds.PickupSounds.gun_bounce'
	}
