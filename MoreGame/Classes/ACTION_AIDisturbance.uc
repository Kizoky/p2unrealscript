///////////////////////////////////////////////////////////////////////////////
// ACTION_AIDisturbance.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Generates a marker that is usually only generated programatically. It can
// tell AI all sorts of things like a guy just got his head blown off, or
// a gunshot happened here, or a window broke.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_AIDisturbance extends P2ScriptedAction;

var (Action) class<TimedMarker> DisturbanceMarker;
var (Action) bool bPlayerDidIt;		// Player did this
var (Action) name NPCDidItTag;		// Other guy who did it
var (Action) name ThingDoneToTag;	// Thing that this effect originates from (window broken, guy killed)


function bool InitActionFor(ScriptedController C)
{
	local P2GameInfoSingle game;
	local FPSPawn didItPawn;
	local Actor Other;
	local TimedMarker ADanger;

	// Get who's done this
	game = P2GameInfoSingle(C.Level.Game);
	if(game != None)
	{
		if(!bPlayerDidIt)
		{
			ForEach C.AllActors(class'FPSPawn', didItPawn, NPCDidItTag)
				break;
		}
		else
			didItPawn = game.GetPlayer().MyPawn;
	}

	if(didItPawn == None)
		warn(ActionString@" Error! No DidIt pawn");
	else
	{
		// Get what they did it too (could be anything)
		ForEach C.AllActors(class'Actor', Other, ThingDoneToTag)
			break;

		if(DisturbanceMarker != None
			&& Other != None)
		{
			// Spawn it
			ADanger = game.spawn(DisturbanceMarker,Other,,Other.Location);
			ADanger.CreatorPawn = didItPawn;
			ADanger.OriginActor = Other;

			// Blipmarker handles itself, but TimedMarker must be made and destroyed
			if(BlipMarker(ADanger) == None) // Checking for a timedmarker only (blipmarker inherits from this)
				ADanger.NotifyAndDie();
		}
		else
			warn(ActionString@" Error! No disturbance or ThingDoneItTo!");
	}

	return false;
}

function string GetActionString()
{
	return ActionString$DisturbanceMarker;
}

defaultproperties
	{
	ActionString="AI Disturbance: "
	}
