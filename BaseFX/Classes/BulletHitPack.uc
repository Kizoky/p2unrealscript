///////////////////////////////////////////////////////////////////////////////
// BulletHitPack
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
class BulletHitPack extends Actor;

var class<Splat>		mysplatclass;
var class<P2Emitter>	mysmokeclass;
var class<P2Emitter>	mysparkclass;
var class<P2Emitter>	mydirtclass;
var class<P2Emitter>    mytracerclass;

var Sound WallHit[2];
var Sound RicHit[2];

var float RandSpark; // frequency (0-1.0) with which these things are made
var float RandDirt;
var float RandSmokeSound;
var float RandSparkSound;



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
	local P2Emitter thesmoke, thesparks;
	local Rotator NewRot;
	local vector newloc;

	if(mysmokeclass != None)
		thesmoke = Spawn(mysmokeclass,Owner,,Location, Rotation);
	// Only make bullet hole projectors in single player--don't do this
	// in MP, it slows down things horribly
	if(mysplatclass != None
		&& Level.Game != None
		&& Level.Game.bIsSinglePlayer)
	{
		// randomly orient the splat on the wall (rotate around the normal)
		NewRot = Rotator(-vector(Rotation));
		NewRot.Roll=(65536*FRand());
		Spawn(mysplatclass,Owner,,Location, NewRot);
	}

	if(mydirtclass != None
		&& FRand() < RandDirt)
	{
		Spawn(mydirtclass,Owner,,Location, Rotation);
	}
	if(mysparkclass != None
		&& FRand() < RandSpark)
	{
		thesparks = Spawn(mysparkclass,Owner,,Location,Rotation);
		if(FRand() < RandSparkSound)
			thesparks.PlaySound(RicHit[Rand(ArrayCount(RicHit))],,,,,GetRandPitch());
	}
	
	if(FRand() < RandSmokeSound)
		thesmoke.PlaySound(WallHit[Rand(ArrayCount(WallHit))],,,,,GetRandPitch());

	// Only make this inferior tracer during MP (putting it here saves bandwidth)
	if((Level.Game == None
			|| !Level.Game.bIsSinglePlayer)
		&& mytracerclass != None)
	{
		if(Owner != None)
		{
			newloc = (Location + Owner.Location)/2;
			Spawn(mytracerclass,Owner,,newloc, rotator(Location - Owner.Location));
		}
	}
}

defaultproperties
{
	LifeSpan=5
	bNetOptional=true
	DrawType=DT_Mesh	// Use mesh type here so our rotation will be replicated
	Mesh=None

	WallHit[0]=Sound'WeaponSounds.bullet_hitwall1'
	WallHit[1]=Sound'WeaponSounds.bullet_hitwall2'
	RicHit[0]=Sound'WeaponSounds.bullet_ricochet1'
	RicHit[1]=Sound'WeaponSounds.bullet_ricochet2'
	RandDirt=0.3
	RandSpark=0.3
	RandSparkSound=1.0
	RandSmokeSound=1.0
}
