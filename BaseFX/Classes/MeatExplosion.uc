class MeatExplosion extends P2Emitter;


var float FullBlastDist;	// below this is, and you get a full blast explosion
var float VelMax;			// max starting velocity for particles
var Sound ExplodingSound;


///////////////////////////////////////////////////////////////////////////////
// Play sound on startup
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();
	PlaySound(ExplodingSound, , 1.0, , , 0.96 + FRand()*0.08);
}

///////////////////////////////////////////////////////////////////////////////
// Based on how close the hurting thing was to the cat that made this explosion
// like a shotgun blast, change the explosiveness of the effect,
// farther away==less explosive
///////////////////////////////////////////////////////////////////////////////
function ReduceMagBasedOnProx(vector FiringLoc, float mag)
{
	local int i;
	local float pct, dist;

	dist = VSize(Location - FiringLoc)/mag;

	if(dist < FullBlastDist)
		pct = 1.0;
	else
		pct = FullBlastDist/dist;

	for(i=0; i<Emitters.Length; i++)
	{
		Emitters[i].StartVelocityRange.X.Max*=pct;
		Emitters[i].StartVelocityRange.X.Min*=pct;
		Emitters[i].StartVelocityRange.Y.Max*=pct;
		Emitters[i].StartVelocityRange.Y.Min*=pct;
		Emitters[i].StartVelocityRange.Z.Max*=pct;
		Emitters[i].StartVelocityRange.Z.Min*=pct;
		Emitters[i].LifetimeRange.Max*=pct;
		Emitters[i].LifetimeRange.Min*=pct;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function FitToNormal(vector HNormal)
{
	local int i;

	// Don't do this to the last one
	for(i=0; i<Emitters.Length-1; i++)
	{
		Emitters[i].StartVelocityRange.X.Max+=HNormal.x*VelMax;
		Emitters[i].StartVelocityRange.Y.Max+=HNormal.y*VelMax;
		Emitters[i].StartVelocityRange.Z.Max+=HNormal.z*VelMax;
		Emitters[i].StartVelocityRange.X.Min-=HNormal.x*VelMax;
		Emitters[i].StartVelocityRange.Y.Min-=HNormal.y*VelMax;
		Emitters[i].StartVelocityRange.Z.Min-=HNormal.z*VelMax;
	}
}

defaultproperties
{
    SoundRadius=0
    SoundVolume=255
    SoundPitch=64
	FullBlastDist=150
	VelMax=300
    ExplodingSound=Sound'WeaponSounds.flesh_explode'
}