//=============================================================================
// ScriptedSequence
// used for setting up scripted sequences for pawns.
// A ScriptedController is spawned to carry out the scripted sequence.
//=============================================================================
class ScriptedSequence extends AIScript
	hidecategories(Collision,Lighting,LightColor,Karma,Force,Shadow,Sound)
	native;
	
cpptext
{
	UBOOL AScriptedSequence::MatchesEvent(FName EventName);
}

var(AIScript) export editinline Array<ScriptedAction> Actions;
var class<ScriptedController>  ScriptControllerClass;
// RWS CHANGE - flag indicates that one or more actions require a valid GameInfo
var bool bRequiresValidGameInfo;

// RWS CHANGE
// Some scripted actions require a valid GameInfo, so we check to see if that's
// the case, and if so we set a flag.  ScriptedController's will later use that
// flag to determine whether they need to wait for the GameInfo to become valid.
function PostBeginPlay()
	{
	local int i;
	
	Super.PostBeginPlay();
	
	// Set flag if any actions require a valid GameInfo
	for (i = 0; i < Actions.Length; i++)
		{
		if (Actions[i] != None && Actions[i].bRequiresValidGameInfo)
			{
			bRequiresValidGameInfo = true;
			break;
			}
		}
	}

/* SpawnController()
Spawn and initialize an AI Controller (called by a non-player controlled Pawn at level startup)
*/
function SpawnControllerFor(Pawn P)
	{
	Super.SpawnControllerFor(P);
	TakeOver(P);
	}

/* TakeOver()
Spawn a scripted controller, which temporarily takes over the actions of the pawn,
unless pawn is currently controlled by a scripted controller - then just change its script
*/
function TakeOver(Pawn P)
	{
	local ScriptedController C;

	// RWS CHANGE
	// Our controllers are ScriptedControllers, but because they do a lot of higher-level
	// thinking, they are difficult to control in a predictable manner.  Instead, we
	// want to force a new controller to be created and let the original controller
	// be restore after the script has finished.
//	if ( ScriptedController(P.Controller) != None )
//		C = ScriptedController(P.Controller);
//	else
//		{
		C = spawn(ScriptControllerClass);
		
		C.PendingController = P.Controller;
		if ( C.PendingController != None )
			C.PendingController.PendingStasis();
//		}
	
	// RWS CHANGE
	// Despite spending a lot of time on this, I couldn't find a good way of having a
	// ScriptedSequence wait for the GameInfo to become valid because the process is
	// initiated by the Pawn.  I finally settled on putting a warning here so I can
	// find out if this theoretical problem ever occurs in practice.  If it does then
	// I'll deal with it then.
	if (!FPSGameInfo(Level.Game).bIsValid && bRequiresValidGameInfo)
		Warn(GetLogPrefix(C)$"starting without valid GameInfo even though one or more actions require it");

	if ( bLoggingEnabled )
		Log(GetLogPrefix(C)$"TakeOver() Pawn="$P$" PendingController="$C.PendingController);

	C.MyScript = self;
	C.TakeControlOf(P);
	C.SetNewScript(self);
	}

//*****************************************************************************************
// Script Changes

function bool ValidAction(Int N)
	{
	return true;
	}

function SetActions(ScriptedController C)
	{
	local ScriptedSequence NewScript;
	local bool bDone;
	
	if ( C.CurrentAnimation != None )
		C.CurrentAnimation.SetCurrentAnimationFor(C);
	while ( !bDone )
		{
		if ( C.ActionNum < Actions.Length )
			{
			if ( ValidAction(C.ActionNum) )
				NewScript = Actions[C.ActionNum].GetScript(self);
			else
				{
				NewScript = None;
				warn(GetItemName(string(self))$" action "$C.ActionNum@Actions[C.ActionNum].GetActionString()$" NOT VALID!!!");
				}
			}
		else 
			{
			NewScript = None;
			}
		if ( NewScript == None )
			{
			// RWS CHANGE: added useful log
			if ( bLoggingEnabled )
				Log(GetLogPrefix(C)$"reached end of script");
			C.CurrentAction = None;
			return;
			}
		if ( NewScript != self )
			{
			// RWS CHANGE: added useful log
			if ( bLoggingEnabled )
				Log(GetLogPrefix(C)$"switched to new script "$NewScript);
			C.SetNewScript(NewScript);
			return;
			}

		if ( Actions[C.ActionNum] == None )
			{
			Warn(self$" no action "$C.ActionNum$"!!!");
			C.CurrentAction = None;
			return;
			}
		
		// RWS CHANGE: Log the action BEFORE it happens (so much easier on the brain when reading logs)
		if ( bLoggingEnabled )
			Log(GetLogPrefix(C)$"action["$C.ActionNum$"]="$Actions[C.ActionNum].GetActionString());
		bDone = Actions[C.ActionNum].InitActionFor(C);

		// RWS CHANGE: The action may result in the controller getting destroyed
		if ( C == None || C.bDeleteMe || C.bPendingDestroy)
			return;

		if ( !bDone )
			{
			if ( Actions[C.ActionNum] == None )
				{
				Warn(self$" has no action "$C.ActionNum$"!!!");
				C.CurrentAction = None;
				return;
				}
			Actions[C.ActionNum].ProceedToNextAction(C);
			}
		}
	}

// RWS CHANGE
// Helper function to generate standardized log prefix
function String GetLogPrefix(optional ScriptedController C)
	{
	local Pawn P;
	if (C == None)
		return self @ "("$Tag$"): ";
	else if (ScriptedTriggerController(C) != None)
		return C @ "Script="$self$" ("$Tag$"): ";
	else
		return C @ "Script="$self$" ("$Tag$") Pawn="$C.Pawn$": ";
	}

defaultproperties
	{
	bStatic=false
	ScriptControllerClass=class'ScriptedController'
	bCollideWhenPlacing=true
	CollisionRadius=+00050.000000
	CollisionHeight=+00100.000000
	bDirectional=true
	bNavigate=false
	bLoggingEnabled=true
	}

