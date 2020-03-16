class GasCanPickup extends P2WeaponPickup;


///////////////////////////////////////////////////////////////////////////////
// Make it lie on the ground, sort of
///////////////////////////////////////////////////////////////////////////////
function FitToGround()
{
	local Actor HitActor;
	local vector HitLocation, HitNormal, checkpos;
	local Rotator userot;

	//log("physics in fit to ground "$Physics);
	//log("latching ");
	// Snap to the ground below you
	//log("loc "$Location);
	checkpos = Location;
	checkpos.z -= CHECK_FOR_GROUND_DIST;

	HitActor = Trace(HitLocation, HitNormal, checkpos, Location, false);
	if(HitActor != None)
	{
		HitLocation+=CollisionHeight*HitNormal;
		//log("set with loc "$HitLocation);
		SetLocation(HitLocation);
		//log("now using "$Location);
		// Fit to the ground
		userot = Rotator(HitNormal);
		userot.Pitch-=16383;
		userot.Pitch = userot.Pitch & 65535;
		if(!Level.bStartup)
		{
			userot.Yaw = Rotation.Yaw;
			userot.Yaw = userot.Yaw & 65535;
		}
		SetRotation(userot);
		//log("after rotation"$Location);
	}
}

defaultproperties
	{
	AmmoGiveCount=10
	MPAmmoGiveCount=10
	DeadNPCAmmoGiveRange=(Min=5,Max=10)
	Rotation=(Pitch=48000))
	InventoryType=class'GasCanWeapon'
	PickupMessage="You picked up a Can of Gasoline."
//	PickupSound=Sound'WeaponPickup'
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.GasCan'
	CollisionHeight=23.000000
	}