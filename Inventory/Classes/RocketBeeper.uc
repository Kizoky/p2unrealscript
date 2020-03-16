///////////////////////////////////////////////////////////////////////////////
// Beeping noise, played with a timer, only on the client
// who is saught by the seeking rocket.
//
// After INIT_TIME, it goes and hooks itself to it's rocket. It plays the sound
// through the rocket because SetBase caused this to not play sounds. It checks
// before it plays the sound to see if the rocket is already dead or not. If so,
// it kills itself.
///////////////////////////////////////////////////////////////////////////////
class RocketBeeper extends Actor;


var LauncherSeekingProjectileTrad RocketOwner;	// Rocket I beep with
var Sound RocketBeeping;	// Sound it makes when it's after someone, but only on their machine

const INIT_TIME	=	1.0;
const BEEP_TIME	=	1.7;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto simulated state Initting
{
	simulated function Timer()
	{
		local LauncherSeekingProjectileTrad checkrocket, newrocket;
		local float newlife;

		// Find the one farthert from dying, probably the one you just shot
		newlife = 0;
		foreach DynamicActors(class'LauncherSeekingProjectileTrad', checkrocket)
		{
			//log(self$" dyn seeing this rocket "$checkrocket$" lifespan "$checkrocket.LifeSpan);
			if(checkrocket.LifeSpan > newlife)
			{
				newlife = checkrocket.LifeSpan;
				newrocket = checkrocket;
			}
		}
		if(newrocket != None)
		{
			RocketOwner = newrocket;
			//log(self$" going to beep "$Role);
			GotoState('Beeping');
		}
		else
			Destroy();
	}

	simulated function BeginState()
	{
		//log(self$" Initting ");
		SetTimer(INIT_TIME, false);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated state Beeping
{
	simulated function Timer()
	{
		//log(self$" beeped! "$Role$" rocket owner deleted "$RocketOwner.bDeleteMe);
		if(RocketOwner == None
			|| RocketOwner.bDeleteMe)
			Destroy();
		else
		{
			// SetBase caused it to only play the sound once, and never again. So for some
			// reason it didn't work, so we won't do it again.
			RocketOwner.PlaySound(RocketBeeping,SLOT_Interact,,,100);
			SetTimer(BEEP_TIME, false);
		}
	}
	simulated function BeginState()
	{
		Timer();
	}
}


defaultproperties
{
	 bHidden=true
     bCollideActors=True
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
	 bBlockNonZeroExtentTraces=False
	 bBlockZeroExtentTraces=False
	 LifeSpan=60
	 RemoteRole=ROLE_None
	 RocketBeeping=Sound'MiscSounds.Bleep'
	//RocketBeeping=Sound'LevelSounds.dingDingBell'
	//RocketBeeping=Sound'MiscSounds.Bleep'
	// 0-3
}
