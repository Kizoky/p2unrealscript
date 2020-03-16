///////////////////////////////////////////////////////////////////////////////
// ACTION_Errand.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This action lets you control errands.
//
//	History:
//		07/16/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_Errand extends P2ScriptedAction;

enum EErrandAction
	{
	EEA_ActivateErrand_UniqueName,			// Activate an errand.  This is used to turn
											// on new errands in response to something
											// happening in the game.

	EEA_ErrandGoalMet_UniqueTag,			// An errand goal has been met.  This can be
											// used to complete errand goals that are
											// based on ErrrandGoalTag.
	};

var(Action) EErrandAction	ErrandAction;	// action to perform
var(Action) String			UniqueName;		// errand name
var(Action) Name			UniqueTag;		// tag for errand goal
var(Action) String			GoalMet_SendToURL;		// If set and ErrandAction is ErrandGoalMet, sends player to specified URL after scratching out errand


function bool InitActionFor(ScriptedController C)
	{
	switch (ErrandAction)
		{
		case EEA_ActivateErrand_UniqueName:
			P2GameInfoSingle(C.Level.Game).ActivateErrand(UniqueName);
			break;

		case EEA_ErrandGoalMet_UniqueTag:
			// An errand has been completed.  This type of errand looks for
			// an actor with a unique tag to indicate it's completion.  So
			// we spawn a temporary actor with the specified tag and pass
			// it on to the completion process.
			P2GameInfoSingle(C.Level.Game).CheckForErrandCompletion(
				C.spawn(class'RawActor', , UniqueTag),
				None,
				None,
				GetPlayer(C),
				false,
				GoalMet_SendToURL);
			break;

		default:
			break;
		}
	return false;
	}

function string GetActionString()
	{
	switch(ErrandAction)
		{
		case EEA_ActivateErrand_UniqueName:
			return ActionString@"activate errand "$UniqueName;
			break;

		case EEA_ErrandGoalMet_UniqueTag:
			return ActionString@"goal met "$UniqueTag;
			break;

		default:
			break;
		}
	return ActionString@"unknown";
	}

defaultproperties
	{
	bRequiresValidGameInfo=true
	ActionString="Errand: "
	}