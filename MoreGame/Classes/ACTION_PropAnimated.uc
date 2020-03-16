///////////////////////////////////////////////////////////////////////////////
// ACTION_PropAnimated
// Does all kinds of cool stuff with PropAnimateds
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// LIMITATIONS: PropAnimateds controlled by scripted actions cannot have their
// scripted animations carry over past the save. Ideally you'll want to use
// these only during a cinematic, not during actual gameplay. Otherwise,
// the animation will not be restored after a save and reload.
///////////////////////////////////////////////////////////////////////////////
class ACTION_PropAnimated extends P2ScriptedAction;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc
///////////////////////////////////////////////////////////////////////////////
var(Action) name AffectedActorTag;	// Tag of PropAnimated to alter (one or many)
var(Action) enum EActionType {
	EA_StartOver,					// Restarts entire AnimAction from the very beginning
	EA_RestartCurrent,				// Restarts *current* animation
	EA_NextAnim,					// Skips to the next animation. Ignores loop value
	EA_LoopCurrent,					// Loops current animation, using specified LoopCount value (0 = infinite)
	EA_LoopAll,						// Loops all animations, using specified LoopCount value (0 = infinite, -1 = infinite and pick random animations)
	EA_SetNew						// Replaces AnimAction with a new one defined here
} ActionType;
var(Action) int LoopCount;			// New LoopCount for EA_LoopCurrent and EA_LoopAll
var(Action) export editinline CustomAnimAction AnimAction;	// AnimAction to replace existing one when using EA_SetNew

function bool InitActionFor(ScriptedController C)
{
	local PropAnimated UseProp;
	
	foreach C.DynamicActors(class'PropAnimated', UseProp, AffectedActorTag)
	{
		switch ActionType
		{
			case EA_StartOver:
				UseProp.GotoState('');	// Abort current anim and finish up
				UseProp.GotoState('LoopAnims');	// Start it all over again
				break;
			case EA_RestartCurrent:
				UseProp.PlayCurrentAnimAction();	// Replays current anim from the beginning
				break;
			case EA_NextAnim:
				UseProp.FinishCurrentAnimAction();	// Finishes up current anim and starts the next one
				break;
			case EA_LoopCurrent:
				UseProp.DesiredLoopCount = LoopCount;	// Override current loop count
				break;
			case EA_LoopAll:
				UseProp.DesiredGlobalLoopCount = LoopCount;	// Override global loop count
				break;
			case EA_SetNew:
				UseProp.GotoState('');	// Abort current anim and finish up
				UseProp.CopyAnimActionFrom(AnimAction);	// Set its anim action to ours
				UseProp.GotoState('LoopAnims');	// Begin again with new anim set
				break;
		};
	}
	
	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	AffectedActorTag="PropAnimated"
	ActionType=EA_NextAnim
}
