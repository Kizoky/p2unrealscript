///////////////////////////////////////////////////////////////////////////////
// CatnipPickup
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Tin of ultra-powered, psychotic-episode inducing catnip, as a pickup
// 
///////////////////////////////////////////////////////////////////////////////

class CatnipPickup extends OwnedPickup;

var StaticMesh NipLidMesh, NipBottomMesh;	// Mesh for catnip that's been used

///////////////////////////////////////////////////////////////////////////////
// This catnip has been used and can't be hit anymore
///////////////////////////////////////////////////////////////////////////////
function ConvertToUsed()
{
	local BouncyProjectile niplid;

	// Make sure we only do this once
	if(StaticMesh != NipBottomMesh)
	{
		// Top
		niplid = spawn(class'BouncyProjectile',,,Location,Rotation);
		niplid.SetStaticMesh(NipLidMesh);
		niplid.SetDrawType(DT_StaticMesh);
		// setup linear speed
		niplid.Velocity = VRand()*niplid.Speed;
		if(niplid.Velocity.z < 0)
			niplid.Velocity.z = -niplid.Velocity.z;
		niplid.Velocity.z += niplid.TossZ;
		// setup spin
		niplid.RotationRate.Pitch = Rand(niplid.RotationRate.Yaw);
		niplid.RotationRate.Roll = Rand(niplid.RotationRate.Yaw);

		// Bottom
		SetStaticMesh(NipBottomMesh);
		SetDrawType(DT_StaticMesh);
		bPersistent=false;
		SetCollision(false, false, false);
		// Make green dust around it
		spawn(class'CatnipPuff',,,Location);
		// Make no one want it any more (because it's used)
		if(DesireMarker != None)
		{
			DesireMarker.Destroy();
			DesireMarker = None;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	InventoryType=class'CatnipInv'
	PickupMessage="You picked up a tin of Catnip."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.Catnip'

	NipLidMesh=StaticMesh'stuff.stuff1.Catnip_lid'
	NipBottomMesh=StaticMesh'stuff.stuff1.Catnip_dish'
	
	DesireMarkerClass=class'CatnipMarker'
	BounceSound=Sound'MiscSounds.PickupSounds.BookDropping'
	}
