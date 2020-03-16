//////////////////////////////////////////////////////////////////////////////
// GrenadeAltProjectile.
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// This is the actual grenade that is dropped on the ground as mine/pickup
//
///////////////////////////////////////////////////////////////////////////////
class DynamiteAltProjectile extends DynamiteProjectile;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

function SetFuseTime(int fusetime)
{
	DetonateTime=DetonateTime;
}


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(DetonateTime > 0)
	{
		// Arm the grenade
		SetTimer(DetonateTime,false);

	}
	

///////////////////////////////////////////////////////////////////////////
 	// Call this on client or single player
	if ( Level.NetMode != NM_DedicatedServer)
	{
		wickfire = spawn(class'DynamiteSparkler', self,,Location);
		wickfire.SetBase(self);
		fusesound1();
	}
//////////////////////////////////////////////////////////////////////////




}

defaultproperties
{
     bArmed=False
     DetonateTime=0.000000
}
