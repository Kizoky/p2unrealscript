///////////////////////////////////////////////////////////////////////////////
// SplatMaker
// 
// This is a non-visual actor that simply makes effects. These effects
// all need to know about the rotation. Instead of replicating the rotation
// for several different things, we spawn this. It sends the rotation, then
// it spawns all the different effects and uses that same rotation for all.
//
// This sets it's draw type to Mesh, so it's rotation will be replicated.
//
// This only to get it to work more smoothly for multiplayer games.. single
// player games can be done like normal (bullet hits something, spawn
// smoke, spawn sparks, make sounds...)
//
///////////////////////////////////////////////////////////////////////////////
class SplatMaker extends Actor;

var class<Splat>		mysplatclass;

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	// If we're not the dedicated server, let's make more effects
	if(Level.NetMode != NM_DedicatedServer)
		MakeMoreEffects();
}

///////////////////////////////////////////////////////////////////////////////
// Just a little randomness for the pitch, around 1.0
///////////////////////////////////////////////////////////////////////////////
simulated function float GetRandPitch()
{
	return (0.96 + FRand()*0.08);
}

simulated function MakeMoreEffects()
{
	local Rotator NewRot;

	if(mysplatclass != None)
	{
		// randomly orient the splat on the wall (rotate around the normal)
		NewRot = Rotator(-vector(Rotation));
		NewRot.Roll=(65536*FRand());
		Spawn(mysplatclass,Owner,,Location, NewRot);
	}
}

defaultproperties
{
	LifeSpan=5
	bNetOptional=true
	DrawType=DT_Mesh	// Use mesh type here so our rotation will be replicated
	Mesh=None
}
