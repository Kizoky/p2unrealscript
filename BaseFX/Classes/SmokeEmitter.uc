///////////////////////////////////////////////////////////////////////////////
// SmokeEmitter. (base smoke class)
///////////////////////////////////////////////////////////////////////////////
class SmokeEmitter extends Wemitter;

var	int		OrigLifeSpan;
var float	WindCheckDist;
var float	WindXPosDist;
var float	WindXNegDist;
var float	WindYPosDist;
var float	WindYNegDist;
var float	FadeTime;


const WIND_CHECK_DIST_MIN	=	200;
const SHOW_LINES=0;

replication
{
	// functions sent from server to client
	unreliable if(Role == ROLE_Authority)
		ClientGotoState, ClientSetupLifetime;
}

///////////////////////////////////////////////////////////////////////////////
// setup lifetimes
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	SetupLifetime(LifeSpan);
	Super.PostBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// Server uses this to force client into NewState
///////////////////////////////////////////////////////////////////////////////
simulated function ClientGotoState(name NewState, optional name NewLabel)
{
	if(Role != ROLE_Authority)
	    GotoState(NewState,NewLabel);
}

///////////////////////////////////////////////////////////////////////////////
// setup lifetimes
///////////////////////////////////////////////////////////////////////////////
function SetupLifetime(float uselife)
{
	OrigLifeSpan=uselife;
	LifeSpan = uselife + (FadeTime);
	// update timer
	SetTimer(OrigLifeSpan, false);
	// Bring the client up to speed
	if(Level.NetMode == NM_DedicatedServer)
		ClientSetupLifetime(uselife);
}

///////////////////////////////////////////////////////////////////////////////
// setup lifetimes
///////////////////////////////////////////////////////////////////////////////
simulated function ClientSetupLifetime(float uselife)
{
	OrigLifeSpan=uselife;
	LifeSpan = uselife + (FadeTime);
	// update timer
	SetTimer(OrigLifeSpan, false);
}

///////////////////////////////////////////////////////////////////////////////
// A wall has been detected in a certain direction, restrict spawning in that dir
///////////////////////////////////////////////////////////////////////////////
function InitialWallHitX(float X)
{
	// STUB
}
function InitialWallHitY(float Y)
{
	// STUB
}


function CheckWallsForWind()
{
	local vector EndPos, newhit, newnormal;

	// Check the four directions away from the center of the smoke
	EndPos = Location;
	EndPos.x += WindCheckDist;
	if(Trace(newhit, newnormal, EndPos, Location, false) != None)
	{
		InitialWallHitX(1);
		WindXPosDist = newhit.x - Location.x;
//		log("WindXPosDist "$WindXPosDist);
	}
	else WindXPosDist = WindCheckDist;

	EndPos.x -= 2*WindCheckDist;
	if(Trace(newhit, newnormal, EndPos, Location, false) != None)
	{
		InitialWallHitX(-1);
		WindXNegDist = Location.x - newhit.x;
//		log("WindXNegDist "$WindXNegDist);
	}
	else WindXNegDist = WindCheckDist;
	EndPos = Location;
	EndPos.y += WindCheckDist;
	if(Trace(newhit, newnormal, EndPos, Location, false) != None)
	{
		InitialWallHitY(1);
		WindYPosDist = newhit.y - Location.y;
//		log("WindYPosDist "$WindYPosDist);
	}
	else WindYPosDist = WindCheckDist;
	EndPos.y -= 2*WindCheckDist;
	if(Trace(newhit, newnormal, EndPos, Location, false) != None)
	{
		InitialWallHitY(-1);
		WindXNegDist = Location.y - newhit.y;
//		log("WindYNegDist "$WindYNegDist);
	}
	else WindYNegDist = WindCheckDist;
}

function CheckToMakeCeilingEmitter()
{
}

function vector ConvertWindAcc(vector Acc)
{
//	log("Acc in "$Acc);
//	log(" WindXPosDist "$WindXPosDist);
	if(Acc.x > 0)
	{
//		log("start Acc.x "$Acc.x);
		Acc.x = (WindXPosDist*Acc.x)/WindCheckDist;
//		log("Acc.x "$Acc.x);
//		log(" top "$(WindXPosDist*Acc.x));
//		log("WindCheckDist "$WindCheckDist);
	}
	else if(Acc.x < 0)
	{
		Acc.x = (WindXNegDist*Acc.x)/WindCheckDist;
	}
	if(Acc.y > 0)
		Acc.y = (WindYPosDist*Acc.y)/WindCheckDist;
	else if(Acc.y < 0)
		Acc.y = (WindYNegDist*Acc.y)/WindCheckDist;
//	log("Acc out "$Acc);

	return Acc;
//	Emitters[num].Acceleration.x += Acc.x/2;
//	Emitters[num].Acceleration.y += Acc.y/2;
}

auto simulated state Smoking
{
	simulated function Timer()
	{
		GotoState('Fading');
		// Tell all clients so visually all emitters will be in synch
		spawn(class'FireEmitterTalk', self);
	}
}

simulated state Fading
{
	simulated function BeginState()
	{
		Emitters[0].InitialParticlesPerSecond=0;
		Emitters[0].ParticlesPerSecond=0;
		Emitters[0].RespawnDeadParticles=False;
		AutoDestroy=true;
	}
}

defaultproperties
{
     LifeSpan=20.000000
	 FadeTime=4.0
}
