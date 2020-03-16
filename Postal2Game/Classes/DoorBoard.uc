///////////////////////////////////////////////////////////////////////////////
//  Doorboard
// placed over doors to vaguely hold them shut
///////////////////////////////////////////////////////////////////////////////

class DoorBoard extends prop
	placeable;

// Functions --------------------------------------------------------------------------------------
simulated function HitWall (vector HitNormal, actor HitWall)
{
	local float speed;

	Velocity = 0.5*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
	speed = VSize(Velocity);
	log("hit wall in board");
	/*
	if (bFirstHit && speed<400) 
	{
		bFirstHit=False;
		bRotatetoDesired=True;
		bFixedRotationDir=False;
		DesiredRotation.Pitch=0;	
		DesiredRotation.Yaw=FRand()*65536;
		DesiredRotation.roll=0;
	}
	*/
	RotationRate.Yaw = RotationRate.Yaw*0.75;
	RotationRate.Roll = RotationRate.Roll*0.75;
	RotationRate.Pitch = RotationRate.Pitch*0.75;
/*	if ( (speed < 60) && (HitNormal.Z > 0.7) )
	{
		SetPhysics(PHYS_none);
		bBounce = false;
		GoToState('Dying');
	}
	else if (speed > 80) 
	
	{
		if (FRand()<0.5) 
			PlaySound(ImpactSound, SLOT_None, 0.5+FRand()*0.5,, 300, 0.85+FRand()*0.3);
		else 
			PlaySound(AltImpactSound, SLOT_None, 0.5+FRand()*0.5,, 300, 0.85+FRand()*0.3);
	}
	*/
}

defaultproperties
{
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Zo_Greenbelt_Meshes.Fixtures.zo_nailedplank'
    bCollideActors=False
    bBlockActors=False
    bBlockPlayers=False

}

