///////////////////////////////////////////////////////////////////////////////
// ErrandBase
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Describes an errand.
//
///////////////////////////////////////////////////////////////////////////////
class ErrandBase extends Object
	editinlinenew;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

// These vars change at runtime and are preserved via the GameState
var	bool					bCompleted;				// Whether errand was successfully completed
var bool					bActivated;				// Whether errand was actived

// Thses vars change at runtime but are NOT preserved via the GameState
var	bool					bPremature;				// When you completed it, you didn't do it in the best manner

// These vars don't change at runtime
var() const String			UniqueName;				// Unique name so script and level designers can refer to this errand

var() /*const*/ bool			bInitiallyActive;		// Whether errand is initially active (otherwise gets activated during gameplay)
var() bool					bLocationTexActive;		// Whether or not the location texture is initially active

var() const name			NameTex;				// Texture to use for name

var() const name			LocationTex;			// (optional) Texture to use for location
var() const float			LocationX;				// (optional) X coord on map for location texture
var() const float			locationY;				// (optional) Y coord on map for location texture

var() const name			LocationCrossTex;		// (optional) Texture to use to crossout location
var() const float			LocationCrossX;			// (optional) X coord on map for location crossout texture
var() const float			LocationCrossY;			// (optional) Y coord on map for location crossout texture

var() const name			IgnoreTag;				// What actor tag to ignore before/after your complete
var() const bool			bIgnoreAfterCompletion;	// Ignore the IgnoreTag actor only after this errand is complete

var() const name			DudeStartComment;		// What dude says when writing the errand
var() const name			DudeWhereComment;		// (optional) What dude says when he's looking for the errand location
var() const name			DudeFoundComment;		// (optional) What dude says when he found the errand location
var() /*const*/ name		DudeCompletedComment;	// What dude says when crossing out the errand

var() const String			SendPlayerURL;			// URL to send player to if they accomplish this errand

var() const bool			bCompletionCallsTime;	// If true this errand completes the game and calls time for speedruns.

var() editinline array<ErrandGoal>	Goals;			// Ways the errand can be completed


///////////////////////////////////////////////////////////////////////////////
// After traveling this is called to reset this object to it's "normal" state.
// This is necessary because this object is NOT destroyed by traveling.
///////////////////////////////////////////////////////////////////////////////
function PostTravelReset()
	{
	bCompleted = false;
	bActivated = bInitiallyActive;
	bPremature = false;
	}

///////////////////////////////////////////////////////////////////////////////
// Check to make sure at least every errand has one goal
// Only to be called in an init.
///////////////////////////////////////////////////////////////////////////////
function bool CheckForValidErrandGoals()
	{
	if(Goals.Length == 0)
		{
		Warn("ERROR: goal list must have at least one goal "$self);
		return false;
		}
	return true;
	}

///////////////////////////////////////////////////////////////////////////////
// Check if this errand has been completed as the result of some action.
///////////////////////////////////////////////////////////////////////////////
function bool CheckForCompletion(
	 Actor Other,
	 Actor Another,
	 Pawn ActionPawn,
	 GameState CurGameState,
	 out name CompletionTrigger,		// OUT: name of trigger that occurs when 
	 out string SendPlayerTo			// OUT: URL to send player
	 )
	{
	local int i;
	
	// Only check if active and not yet completed
	if(IsActive() && !bCompleted)
		{
		for(i = 0; i < Goals.Length; i++)
			{
			if(Goals[i].CheckForCompletion(Other, Another, ActionPawn))
				{
				// Return trigger
				CompletionTrigger = Goals[i].TriggerOnCompletionTag;
				
				// Add to hate list
				if (Goals[i].HateClass != '')
					CurGameState.AddHaters(Goals[i].HateClass, Goals[i].HateDesTex, Goals[i].HatePicTex, Goals[i].HateComment);
					
				// Activate linked errand
				if (Goals[i].ActivateErrandName != "")
					P2GameInfoSingle(CurGameState.Level.Game).ActivateErrand(Goals[i].ActivateErrandName);
					
				// Get goal-specific completion comment, if any
				if (Goals[i].DudeCompletedComment != '')
					DudeCompletedComment = Goals[i].DudeCompletedComment;
					
				// Unlock achievement, if any
				if (Goals[i].UnlockAchievement != '')
				{
					if (CurGameState.Level.NetMode != NM_DedicatedServer) P2GameInfoSingle(CurGameState.Level.Game).GetPlayer().GetEntryLevel().EvaluateAchievement(P2GameInfoSingle(CurGameState.Level.Game).GetPlayer(), Goals[i].UnlockAchievement);
				}
					
				// Send Player, if any (URL stated in errand goal overrides URL stated in errand base)
				if (Goals[i].SendPlayerURL != "")
					SendPlayerTo = Goals[i].SendPlayerURL;
				else if (SendPlayerURL != "")
					SendPlayerTo = SendPlayerURL;
					
				// If true completion calls time. Set time in the game state
				if (bCompletionCallsTime)
					CurGameState.TimeStop = CurGameState.Level.GetMillisecondsNow();
				
				return true;
				}
			}
		}
	return false;
	}

///////////////////////////////////////////////////////////////////////////////
// Check to ignore this thing by tag
///////////////////////////////////////////////////////////////////////////////
function bool IgnoreThisTag(Actor Other)
	{
	// Check first if we have the right actor--most of the time
	// ignoretag is blank.
	if(IgnoreTag != Other.Tag)
		return false;
	
	// default--only ignore if the errand's been completed
	if(bIgnoreAfterCompletion)
		{
		if(bCompleted)
			return true;
		}
	else // ignore BEFORE the errand's complete
		{
		if(!bCompleted)
			return true;
		}
	return false;
	}

///////////////////////////////////////////////////////////////////////////////
// Check if Other is used by an errand
///////////////////////////////////////////////////////////////////////////////
function bool CheckForErrandUse(Actor Other)
	{
	local int i;
	local bool bUse;
	
	// Go through the errands and ask if any of them have been satisfied
	for(i=0; i<Goals.Length; i++)
		{
		if(Goals[i].CheckForErrandUse(Other))
			bUse=true;
		}
	
	return bUse;
	}

///////////////////////////////////////////////////////////////////////////////
// Check whether errand is complete
///////////////////////////////////////////////////////////////////////////////
function bool IsComplete()
	{
	return bCompleted;
	}

///////////////////////////////////////////////////////////////////////////////
// Set errand as completed
///////////////////////////////////////////////////////////////////////////////
function SetComplete(bool bPrematureIn)
	{
	bCompleted = true;
	bPremature = bPrematureIn;
	}

///////////////////////////////////////////////////////////////////////////////
// Check whether errand is active
///////////////////////////////////////////////////////////////////////////////
function bool IsActive()
	{
	return bInitiallyActive || bActivated;
	}

///////////////////////////////////////////////////////////////////////////////
// Activate errand
///////////////////////////////////////////////////////////////////////////////
function Activate()
	{
	bActivated = true;
	}
///////////////////////////////////////////////////////////////////////////////
// DEActivate errand
///////////////////////////////////////////////////////////////////////////////
function DeActivate()
	{
	bActivated = false;
	bInitiallyActive = false;
	}

///////////////////////////////////////////////////////////////////////////////
// Check whether errand is active
///////////////////////////////////////////////////////////////////////////////
function bool IsLocationTexActive()
	{
	return bLocationTexActive;
	}

///////////////////////////////////////////////////////////////////////////////
// Activate errand
///////////////////////////////////////////////////////////////////////////////
function ActivateLocationTex()
	{
	bLocationTexActive = true;
	}
///////////////////////////////////////////////////////////////////////////////
// DEActivate errand
///////////////////////////////////////////////////////////////////////////////
function DeActivateLocationTex()
	{
	bLocationTexActive = false;
	}

///////////////////////////////////////////////////////////////////////////////
// After the player travels to a new level, we need to reset the flags for
// the errands that were already completed.
// Also turns on all hate-player-groups associated with the errand
///////////////////////////////////////////////////////////////////////////////
function PostTravelSetComplete()
	{
	bCompleted = true;
	}

///////////////////////////////////////////////////////////////////////////////
// Just add the haters for this errand
///////////////////////////////////////////////////////////////////////////////
function AddMyHaters(GameState CurGameState, P2Player CurPlayer)
	{
	local int i;
	
	for(i = 0; i < Goals.Length; i++)
		{
		// Add to hate list
		if (Goals[i].HateClass != '')
			CurGameState.AddHaters(Goals[i].HateClass, Goals[i].HateDesTex, Goals[i].HatePicTex, Goals[i].HateComment);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// For testing we need to force errands to complete instantly instead of
// completing them the normal way.
///////////////////////////////////////////////////////////////////////////////
function ForceCompletion(GameState CurGameState, P2Player CurPlayer)
	{
	local int i;
	
	bCompleted = true;
	
	// This does not accurately mimic what happens with a normal errand completion
	// because this results in *ALL* goals being completed!
	for(i = 0; i < Goals.Length; i++)
		{
		// Set goal as complete
		Goals[i].ForceCompletion(CurPlayer);
		
		// Add to hate list
		if (Goals[i].HateClass != '')
			CurGameState.AddHaters(Goals[i].HateClass, Goals[i].HateDesTex, Goals[i].HatePicTex, Goals[i].HateComment);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// For testing we need to force errands to un-complete.
///////////////////////////////////////////////////////////////////////////////
function ForceUnCompletion(GameState CurGameState)
	{
	local int i;
	
	bCompleted = false;
	
	// This does not accurately mimic what happens with a normal errand completion
	// because this results in *ALL* goals being un-completed!
	for(i = 0; i < Goals.Length; i++)
		{
		// Remove from hate list
		if (Goals[i].HateClass != '')
			CurGameState.RemoveHaters(Goals[i].HateClass);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	bInitiallyActive=true
	bIgnoreAfterCompletion=true
	bLocationTexActive=true
}
