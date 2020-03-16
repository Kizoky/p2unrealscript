///////////////////////////////////////////////////////////////////////////////
// PropAnimated
// Copyright 2014, Running With Scissors, Inc. All rights reserved, yadda yadda
//
// Animated prop actor. Can be configured using the same AnimActionAction
// system as InterestPoint, SelfInitialState etc.
///////////////////////////////////////////////////////////////////////////////
class PropAnimated extends Prop;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, structs, enums, whatever
///////////////////////////////////////////////////////////////////////////////
var() export editinline CustomAnimAction AnimAction;	// List of animations to use
var() array<MeshAnimation> ExtraAnims;					// These animation sets will be linked and available to AnimActions in addition to the mesh's default animations.
var() bool bDestroyOnCompletion;						// Destroy this actor if we run out of animations to play

var CustomAnimAction TempAnimAction;

var int CCurrentAction, CTotalLoopCount, CCurrentLoopCount, CurrentFloat;
var int DesiredLoopCount, DesiredGlobalLoopCount;

function dlog( coerce string S, optional name Tag, optional bool bTimestamp )
{
	if (false)
		log(S, Tag, bTimestamp);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();
	
	// Link our extra animation sets, if any.
	for (i=0; i<ExtraAnims.Length; i++)
		LinkSkelAnim(ExtraAnims[i]);
}

///////////////////////////////////////////////////////////////////////////////
// Stub functions so we can access them in ACTION_PropAnimated
///////////////////////////////////////////////////////////////////////////////
function PlayCurrentAnimAction();
function FinishCurrentAnimAction();
function SetupForNextAnimAction();
function TurnOffCollidingStaticMeshes();

///////////////////////////////////////////////////////////////////////////////
// PreSaveGame
// The game barfs if we have any references to transient animactions.
///////////////////////////////////////////////////////////////////////////////
/*
event PreSaveGame()
{
	if (AnimAction.Outer.Name == 'Transient')
	{
		AnimAction = None;
		GotoState('');
	}
}
*/

///////////////////////////////////////////////////////////////////////////////
// To change the anim action of a PropAnimated, we need to copy the
// animaction's properties into the propanimated's animaction. Otherwise it
// gets linked to Transient and that opens up a whole other can of worms.
// Except instead of being full of worms it's full of bees instead, and the
// bees eat the save data and cause the game to crash. Into a train full of bees.
// In short, it's very bad news.
///////////////////////////////////////////////////////////////////////////////
function CopyAnimActionFrom(CustomAnimAction A)
{
	local int i;
	
	// Create a new temp anim action if it doesn't exist already.
	if (TempAnimAction == None)
		// Make sure it's tied to Level and not something stupid like Transient
		// That would put us right back to square one with the can of bees crashing
		// the game into the train full of bees and that's a Bad Thing (TM)
		TempAnimAction = new(Level) class'CustomAnimAction';
	
	// Copy over the properties from the other anim action
	TempAnimAction.BoltOn = A.BoltOn;
	TempAnimAction.LoopCount = A.LoopCount;
	TempAnimAction.PreTrigger = A.PreTrigger;
	TempAnimAction.PostTrigger = A.PostTrigger;
	TempAnimAction.ExitTrigger = A.ExitTrigger;
	TempAnimAction.CollidingStaticMeshTag = A.CollidingStaticMeshTag;
	TempAnimAction.CollidingStaticMeshRadius = A.CollidingStaticMeshRadius;
	TempAnimAction.Actions.Length = A.Actions.Length;
	
	for (i = 0; i < A.Actions.Length; i++)
	{
		TempAnimAction.Actions[i].AnimName = A.Actions[i].AnimName;
		TempAnimAction.Actions[i].AnimRate = A.Actions[i].AnimRate;
		TempAnimAction.Actions[i].TweenTime = A.Actions[i].TweenTime;
		TempAnimAction.Actions[i].Duration = A.Actions[i].Duration;
		TempAnimAction.Actions[i].LoopCount = A.Actions[i].LoopCount;
		TempAnimAction.Actions[i].PreTrigger = A.Actions[i].PreTrigger;
		TempAnimAction.Actions[i].PostTrigger = A.Actions[i].PostTrigger;
		TempAnimAction.Actions[i].bAddBolton = A.Actions[i].bAddBolton;
		TempAnimAction.Actions[i].bDestroyBolton = A.Actions[i].bDestroyBolton;
	}
	
	AnimAction = TempAnimAction;
}

///////////////////////////////////////////////////////////////////////////////
// DestroyActor
// Clear up any references to Transient.
// We shouldn't have these any more but it's better to be safe than sorry.
///////////////////////////////////////////////////////////////////////////////
event Destroyed()
{
	AnimAction = None;
	TempAnimAction = None;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Play animations
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state LoopAnims
{
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		//dlog(self@"AnimEnd decide what next");
		// One loop complete, decide what to do next.
		CCurrentLoopCount++;
		// If both the loop count and duration have been satisfied, consider it done
		if (DesiredLoopCount > 0
			&& CCurrentLoopCount >= DesiredLoopCount
			&& CurrentFloat == 0)
			// Get next custom anim going
			FinishCurrentAnimAction();
		else
			// Start over
			PlayCurrentAnimAction();
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		//dlog(self@"BEGIN STATE INIT");

		// reset our custom anim vars
		CCurrentAction = -1;
		CTotalLoopCount = 0;
		// get bolton from custom
		/*
		TempBolton.bone = AnimAction.Bolton.bone;
		TempBolton.Mesh = AnimAction.Bolton.Mesh;
		TempBolton.StaticMesh = AnimAction.Bolton.StaticMesh;
		TempBolton.Skin = AnimAction.Bolton.Skin;
		TempBolton.bCanDrop = True;
		TempBolton.bAttachToHead = AnimAction.Bolton.bAttachToHead;
		TempBolton.DrawScale = AnimAction.Bolton.DrawScale;
		*/
	}
	///////////////////////////////////////////////////////////////////////////////
	// Get out of your dance anim
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		//dlog(self@"ENDING STATE CLEANUP");
		// Cleanup from the custom anim stuff
		/*
		// Remove boltons if there were any
		DestroyTempBolton();
		*/
		// Trigger post-trigger event
		TriggerEvent(AnimAction.Actions[CCurrentAction].PostTrigger, Self, None);
		TriggerEvent(AnimAction.ExitTrigger, Self, None);
		TriggerEvent(AnimAction.CollidingStaticMeshTag, Self, None);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Play whatever custom anim we're on
	///////////////////////////////////////////////////////////////////////////////
	function PlayCurrentAnimAction()
	{
		local float AnimRate, TweenTime;

		// put in some sane defaults
		if (AnimAction.Actions[CCurrentAction].AnimRate == 0)
			AnimRate = 1.0;
		else
			AnimRate = AnimAction.Actions[CCurrentAction].AnimRate;			
		if (AnimAction.Actions[CCurrentAction].TweenTime == 0)
			TweenTime = 0.15;
		else
			TweenTime = AnimAction.Actions[CCurrentAction].TweenTime;

		PlayAnim(AnimAction.Actions[CCurrentAction].AnimName, AnimRate, TweenTime);
		DesiredLoopCount = AnimAction.Actions[CCurrentAction].LoopCount;
		//dlog(self@"Playing"@AnimAction.Actions[CCurrentAction].AnimName@AnimRate@TweenTime);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Finish up current custom anim and go to the next
	///////////////////////////////////////////////////////////////////////////////
	function FinishCurrentAnimAction()
	{
		//dlog(self@"Finishing current custom anim cleanup and return to start");
		// Set up our PostTrigger
		TriggerEvent(AnimAction.Actions[CCurrentAction].PostTrigger, Self, None);
		/*
		// Add bolton if necessary
		if (AnimAction.Actions[CCurrentAction].bDestroyBolton)
			DestroyTempBolton();
		*/
		GotoState(GetStateName(), 'BeginAgain');
	}
	///////////////////////////////////////////////////////////////////////////////
	// Setup for next custom anim
	///////////////////////////////////////////////////////////////////////////////
	function SetupForNextAnimAction()
	{
		//dlog(self@"Setup for next custom anim");
		if (DesiredGlobalLoopCount == -1)
		{
			// Random loop
			CCurrentAction = Rand(AnimAction.Actions.Length);
			//dlog("Picked random action"@CCurrentAction);
		}
		else
		{
			// Increment current action
			CCurrentAction++;
			//dlog("Picked next action"@CCurrentAction);
		}
		if (CCurrentAction >= AnimAction.Actions.Length)
		{
			// All actions complete, decide what to do next.
			CTotalLoopCount++;
			//dlog("All anims exhausted. Loop count:"@CTotalLoopCount@"Max loops allowed:"@DesiredGlobalLoopCount);
			TriggerEvent(AnimAction.PostTrigger, Self, None);
			if (DesiredGlobalLoopCount > 0
				&& CTotalLoopCount >= DesiredGlobalLoopCount)
			{
				// All done, go back to thinking.
				//dlog("ALL DONE");
				GotoState('');
				if (bDestroyOnCompletion)
					Destroy();
				return;
			}
			// Not done looping, reset to beginning.
			CCurrentAction = 0;			
		}
		// reset loop count
		CCurrentLoopCount = 0;
		// Set up our PreTrigger
		TriggerEvent(AnimAction.Actions[CCurrentAction].PreTrigger, Self, None);
		/*
		// Add bolton if necessary
		//if (AnimAction.Actions[CCurrentAction].bAddBolton)
			SetupTempBolton();
		*/
		// Start anim
		PlayCurrentAnimAction();
		// If we play for a duration, set it now
		CurrentFloat = AnimAction.Actions[CCurrentAction].Duration;
		//dlog(self@"anim setup complete");
	}
	///////////////////////////////////////////////////////////////////////////////
	// Turn Off Colliding Static Meshes
	///////////////////////////////////////////////////////////////////////////////
	function TurnOffCollidingStaticMeshes()
	{
		local SitAssist sit;
		
		sit = Spawn(class'SitAssist');
		sit.SetupFor(AnimAction.CollidingStaticMeshTag, AnimAction.CollidingStaticMeshRadius);
	}

Begin:
	// Play next custom animation
	//dlog(self@"--- BEGIN");
	TriggerEvent(AnimAction.PreTrigger, Self, None);
	DesiredGlobalLoopCount = AnimAction.LoopCount;
	// Turn off collision for any interfering static meshes
	TurnOffCollidingStaticMeshes();
BeginAgain:
	//dlog(self@"--- BEGIN AGAIN");
	SetupForNextAnimAction();
	// Wait for duration, if any. AnimEnd will handle it afterward.
	//dlog(self@"--- SLEEP"@CurrentFloat);
	Sleep(CurrentFloat);
	CurrentFloat = 0;	
	//dlog(self@"--- CurrentFloat = "@CurrentFloat);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	DrawType=DT_Mesh
	Mesh=SkeletalMesh'MP_Strippers.MP_PostalBabe_Thong'
    Begin Object Class=CustomAnimAction Name=CustomAnimAction_PBabeDefault
        Actions(0)=(AnimName="s_cheer1",TweenTime=0.400000,LoopCount=1)
        Actions(1)=(AnimName="s_cheer2",TweenTime=0.400000,LoopCount=1)
        Actions(2)=(AnimName="s_cheer3",TweenTime=0.400000,LoopCount=1)
        LoopCount=-1
    End Object
    AnimAction=CustomAnimAction'CustomAnimAction_PBabeDefault'
}
