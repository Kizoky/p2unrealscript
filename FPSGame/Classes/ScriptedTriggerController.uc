//=============================================================================
// ScriptedTriggerController
// used for playing ScriptedTrigger scripts
// A ScriptedTriggerController never has a pawn
//=============================================================================
class ScriptedTriggerController extends ScriptedController;

function InitializeFor(ScriptedTrigger T)
{
	SequenceScript = T;
	ActionNum = 0;
	SequenceScript.SetActions(self);
	if (!bPendingDestroy)
		GotoState('Scripting');
}

// RWS CHANGE: Merged ingoring of game end from UT2003
function GameHasEnded() {}
function ClientGameEnded() {}

function DestroyPawn()
{
	if ( Instigator != None )
		Instigator.Destroy();
}

function ClearAnimation() {}

function SetNewScript(ScriptedSequence NewScript)
{
	SequenceScript = NewScript;
	ActionNum = 0;
	Focus = None;
	SequenceScript.SetActions(self);
}

state Scripting
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		Instigator = EventInstigator;
		Super.Trigger(Other,EventInstigator);
	}

	function LeaveScripting()
	{
		Destroy();
	}

Begin:
	InitforNextAction();
	if ( bBroken )
		GotoState('Broken');
	if ( CurrentAction.TickedAction() )
		enable('Tick');
}

// Broken scripted sequence - for debugging
State Broken
{
Begin:
	warn(" Trigger Scripted Sequence BROKEN "$SequenceScript$" ACTION "$CurrentAction);
}