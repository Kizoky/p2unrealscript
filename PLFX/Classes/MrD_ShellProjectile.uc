/// MrD - Projectile class for shooting shells out of weapons
class MrD_ShellProjectile extends GrenadeAltProjectile;

#exec AUDIO IMPORT NAME=ShellHit FILE=Sounds/ShellHit.wav

var Sound ShellBounce;


///////////////////////////////////////////////////////////////////////////////
// Bounces off walls
///////////////////////////////////////////////////////////////////////////////
simulated function HitWall( vector HitNormal, actor Wall )
{
	local vector newhit, newnormal, EndPt;
	local bool bStopped;
	local float speed;
	local SmokeHitPuff smoke1;

	if(bBounce == true)
	{
		speed = VSize(Velocity);
		// Check for a slowed z
		if(speed < MinSpeedForBounce)
		{
			// Check for possible stop by seeing if we're stopped in z and
			// on the ground.
			EndPt = Location;
			EndPt.z-=DIST_CHECK_BELOW;
			// If there is a hit below (ground) then you are stopped.
			if(Trace(newhit, newnormal, EndPt, Location, false) != None)
				bStopped=true;
		}
		// If we've stopped, zero out the appropriate entries
		if(bStopped)
		{
			bBounce=false;
			Acceleration = vect(0, 0, 0);
			Velocity = vect(0, 0, 0);
			RotationRate.Pitch=0;
			RotationRate.Yaw=0;
			RotationRate.Roll=0;
		}
		else	// do bouncing
			BounceRecoil(HitNormal);

		// Throw out some hit effects
		//smoke1 = spawn(class'MrD_Modz_FX.ShellSmoke',Owner,,Location, rotator(HitNormal));
		//if(!bStopped)
			// play a noise
			PlaySound(ShellBounce,,,,TransientSoundRadius,GetRandPitch());
	}
}

defaultproperties
{
     ShellBounce=Sound'MrD_PL_FX.ShellHit'
     TossZ=15.000000
     MyDamageType=None
     bNetTemporary=True
     LifeSpan=30
	
     StaticMesh=StaticMesh'MrD_PL_Mesh.FX.Shell'
     DrawScale=20.000000
     AmbientGlow=62
     SoundVolume=128
     bCollideActors=False
}
