//=============================================================================
// ScriptedTrigger
// replaces Counter, Dispatcher, SpecialEventTrigger
//=============================================================================
class ScriptedTrigger extends ScriptedSequence;

// RWS CHANGE: Added vars to support triggering
var(AIScript) bool bWaitForTrigger;	// Wait to be triggered before starting
var(AIScript) bool bOneTimeOnly;	// Only respond to first trigger (ignore others)

// RWS CHANGE
// Added ability to wait for a trigger before script starts running
function PostBeginPlay()
	{
	Super.PostBeginPlay();
	
	if (bWaitForTrigger)
		{
		if (bLoggingEnabled)
			Log(GetLogPrefix()$"waiting for trigger");
		}
	else
		ReadyToStart();
	}

// RWS CHANGE
// Trigger can be used to start script
function Trigger(Actor Other, Pawn EventInstigator)
	{
	if (bWaitForTrigger)
		{
		if (bOneTimeOnly)
			bWaitForTrigger = false;
		ReadyToStart();
		}
	}

// RWS CHANGE
// Ready to start, now check if we need to wait for GameInfo to be valid
function ReadyToStart()
	{
	// If the GameInfo is not valid and the script requires it to be...
	if (!FPSGameInfo(Level.Game).bIsValid && bRequiresValidGameInfo)
		{
		// Add to waiting list so we'll get notified when it's valid
		FPSGameInfo(Level.Game).AddToWaitingList(self);
		if (bLoggingEnabled)
			Log(GetLogPrefix()$"waiting for valid GameInfo");
		}
	else
		{
		StartUp();
		}
	}

// RWS CHANGE
// GameInfo will call this function when it becomes valid
function GameInfoIsNowValid()
	{
	StartUp();
	}

// RWS CHANGE
// Handles the actual startup (what used to be done in PostBeginPlay)
function StartUp()
{
	local ScriptedTriggerController TriggerController;
	if (bLoggingEnabled)
		Log(GetLogPrefix()$"starting up now");
	TriggerController = Spawn(class'ScriptedTriggerController');
	TriggerController.InitializeFor(self);
}

function bool ValidAction(Int N)
{
	return Actions[N].bValidForTrigger;
}

defaultproperties
{
//	Texture=Texture'Engine.S_SpecialEvent'	// RWS CHANGE: Texture was missing so comment it out
	bWaitForTrigger = true;
	Texture=Texture'PostEd.Icons_256.ScriptedTrigger'
	DrawScale=0.25
}