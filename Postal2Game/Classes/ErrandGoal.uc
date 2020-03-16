///////////////////////////////////////////////////////////////////////////////
// ErrandGoal
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// A goal for an errand--Not an errand itself! That's in ErrandBase.
//
// CheckForCompletion gets called on all errands for the day. If the day happens
// to have errand goals that are similar, it could misinterpret them as completing
// each other, so be very explicit with your checks. For instance, on day 5, 
// for a while, we had a ErrandGoalGiveInventory' for one errand and a 
// 'ErrandGoalKillMe' for another errand. Well when you give the woman the item
// it checks her tag and is done. That works. For the other guy, if you kill him
// that completes the errand and works. But if you kill the woman you give the
// thing too, that *also* works. The fix is sort of error prone, unfortunately,
// so be careful. bUseForErrands is set to true for guys that die and need to
// trigger and goal completion check. It's not set for the woman who you give
// the thing to. So when she dies, it will now fail on the GoalKillMe and (correctly)
// not complete that 'give her a thing' errand.
//
///////////////////////////////////////////////////////////////////////////////
class ErrandGoal extends Object
	editinlinenew;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var () name					TriggerOnCompletionTag;	// After errand is completed, all actors with this tag
													// get triggered.
var () name					HateClass;				// After the player completes this errand with this goal,
													// this class of pawns will hate the player on sight.
var() name					HateDesTex;				// Texture: description of group that hates player
var() name					HatePicTex;				// Texture: picture of group that hates player
var() name					HateComment;			// Sound: dude makes comment about hate group
var() String				ActivateErrandName;		// When completed, activates named errand

var() name					DudeCompletedComment;	// Special comment, if any, the Dude makes when completing the errand with THIS goal
var() name					UnlockAchievement;		// Unlocks this achievement if completed.

var() string				SendPlayerURL;			// URL to send player to if they complete this goal


///////////////////////////////////////////////////////////////////////////////
// Check to see if this errand is done
///////////////////////////////////////////////////////////////////////////////
function bool CheckForCompletion(Actor Other, Actor Another, Pawn ActionPawn)
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Check if Other is used by an errand
///////////////////////////////////////////////////////////////////////////////
function bool CheckForErrandUse(Actor Other)
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// For testing we need to force goals to complete instead of completing them
// the normal way.
///////////////////////////////////////////////////////////////////////////////
function ForceCompletion(P2Player CurPlayer)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
}
