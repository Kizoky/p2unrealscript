class FootprintMaker extends SplatMaker;

var() float YawDiff;
var() float XDiff;

simulated function MakeMoreEffects()
{
	local Rotator NewRot, XAxis;
	local Vector HitLocation, HitNormal, TraceStart, TraceEnd, NewLoc;
	local Splat Spawned;

	if(mysplatclass != None)
	{
		// Get normal to ground
		TraceStart = Location;
		TraceEnd = TraceStart + Vect(0,0,-99999);
		if (Trace(HitLocation, HitNormal, TraceEnd, TraceStart) != None)
		{
			// Point at the ground and rotate based on left/right foot
			NewRot = Rotator(HitNormal);
			NewRot.Yaw = Rotation.Yaw + YawDiff;
			NewRot.Pitch -= 32768;
			XAxis = Rotation;
			XAxis.Yaw += 16384;
			NewLoc = Location;
			NewLoc += Normal(Vector(XAxis)) * XDiff;
			Spawned = Spawn(mysplatclass,Owner,,NewLoc, NewRot);	
		}
	}
}
