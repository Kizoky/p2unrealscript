class RWSMikeJController extends RWSController;

var() string DiscoMusic;	// Music to play when pissed on
var int MusicHandle;
var int TimesDanced;

const TIMES_DANCED_MAX = 5;

///////////////////////////////////////////////////////////////////////////
// Piss is hitting me, decide what to do
// Used the cheesy bool bPuke so we wouldn't have another
// function to ignore in all the states
///////////////////////////////////////////////////////////////////////////
function BodyJuiceSquirtedOnMe(P2Pawn Other, bool bPuke)
{
	// Only none-turrets use this
	if(MyPawn.PawnInitialState != MyPawn.EPawnInitialState.EP_Turret)
	{
		InterestPawn=Other;

		if(bPuke)
		{
			// Definitely throw up from puke on me
			GetAngryFromDamage(PISS_FAKE_DAMAGE);
			MakeMoreAlert();
			CheckToPuke(, true);
		}
		else if (!IsInState('DanceWhenPissedOn'))
		{
			SetNextState(GetStateName());
			GotoStateSave('DanceWhenPissedOn');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Play dance animation and then try for your next state, if you have one
// if not, dance again
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DanceWhenPissedOn extends DanceHere
{
	ignores SetupTellDude;
	
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	event BeginState()
	{
		Super.BeginState();
		if (MusicHandle == 0)
			MusicHandle = FPSGameInfo(Level.Game).PlayMusicAttenuateExt(MyPawn, DiscoMusic, 0.0, 0.75, 100.0, 1.0);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Get out of your dance anim
	///////////////////////////////////////////////////////////////////////////////
	event EndState()
	{
		Super.EndState();
		if (MusicHandle != 0)
		{
			FPSGameInfo(Level.Game).StopMusicExt(MusicHandle, 0.0);
			MusicHandle = 0;
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Find the next state to use
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		// Dance facing the same direction
		if(Frand() < DANCE_AGAIN
			&& TimesDanced < TIMES_DANCED_MAX)
		{
			TimesDanced++;
			GotoState(GetStateName(), 'DanceAgain');
		}
		// Go to my next state
		else if(MyNextState != 'None'
			&& MyNextState != '')
		{
			TimesDanced = 0;
			GotoNextState();
		}
		else 
		{
			TimesDanced = 0;
			GotoState('Thinking');
		}
	}
}

defaultproperties
{
	DiscoMusic="gay_club.ogg"
}