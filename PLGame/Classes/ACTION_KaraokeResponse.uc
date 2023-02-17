///////////////////////////////////////////////////////////////////////////////
// ACTION_KaraokeResponse
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
//
// Scripted action that tells selected pawns to express displeasure and
// move far, far away from their current location.
///////////////////////////////////////////////////////////////////////////////
class ACTION_KaraokeResponse extends P2ScriptedAction;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
enum EReactionType
{
	RT_None,	// No particular reaction, just leave.
	RT_Awful,	// Make a remark like "that's awful" and then leave.
	RT_Laugh,	// Laugh and walk away.
	RT_Insult,	// Flips the bird and leaves.
	RT_Panic_Horror,	// Says something like "the horror", panics and runs.
	RT_Panic_Scream,	// Screams in panic and runs.
	RT_Panic_Puke		// Pukes and runs.
};

struct Responses
{
	var() EReactionType ReactionType;	// Type of reaction.
	var() int Weight;					// Weight of this reaction (higher-weighted reactions are more likely to occur)
};

var(Action) name AffectTag;			// Tag of affected pawns.
var(Action) array<Responses> Reactions;	// How pawns should react before leaving.
var(Action) float MinFleeDist;		// Minimum distance for selecting a place to escape to.
var(Action) float MaxFleeDist;		// Maximum distance for selecting a place to escape to.

const END_GOAL_RADIUS = 512;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool InitActionFor(ScriptedController C)
{
	local int i, j, MaxWeight, seed;
	local P2MocapPawn P;
	local PathNode EscapeNode;
	local PersonController PC;
	
	// Figure out the maximum weight
	MaxWeight = 0;
	for (i = 0; i < Reactions.Length; i++)
		MaxWeight += Reactions[i].Weight;
		
	// Go through eligible pawns
	foreach C.DynamicActors(class'P2MocapPawn', P, AffectTag)
	{
		log("Check"@P);
		// only valid for person controllers
		if (P.Controller != None
			&& PersonController(P.Controller) != None)
		{
			PC = PersonController(P.Controller);
			log("Check"@PC);
			// Find a "random" escape point
			foreach P.AllActors(class'PathNode', EscapeNode)//, MaxFleeDist, P.Location)
			{
				log("Node"@EscapeNode);
				if (FRand() < 0.25
					&& VSize(P.Location - EscapeNode.Location) > MinFleeDist
					&& VSize(P.Location - EscapeNode.Location) < MaxFleeDist)
					break;
			}
			log("End goal"@EscapeNode);
			PC.SetEndGoal(EscapeNode, END_GOAL_RADIUS);
			PC.SetNextState('Thinking');
			PC.InterestPawn = FPSPawn(GetPlayer(C).Pawn);
			PC.Focus = GetPlayer(C).Pawn;
			PC.FocalPoint = GetPlayer(C).Pawn.Location;
			PC.InterestActor = GetPlayer(C).Pawn;
			
			// Now determine how they react, before leaving.
			seed = Rand(MaxWeight);
			for (j = 0; j < Reactions.Length; j++)
			{
				seed -= Reactions[j].Weight;
				if (seed <= 0)
				{
					switch (Reactions[j].ReactionType)
					{
						case RT_None:	// Do nothing, just walk to target.
							PC.GotoStateSave('WalkToTargetNoInterest');
							break;
						case RT_Awful:	// Say that's awful
							PC.GotoStateSave('AwfulKaraoke');
							break;
						case RT_Laugh:	// Laugh at it
							PC.GotoStateSave('LaughKaraoke');
							break;
						case RT_Insult:	// Insult their bad singing
							PC.GotoStateSave('InsultKaraoke');
							break;
						case RT_Panic_Horror:	// Singing is so bad we're panicking
							PC.GotoStateSave('PanicKaraoke','TheHorror');
							break;
						case RT_Panic_Scream:
							PC.GotoStateSave('PanicKaraokeScream');
							break;
						case RT_Panic_Puke:
							PC.CheckToPuke(,true);
							break;
					}
					break;
				}
			}
		}
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	MinFleeDist=2000
	MaxFleeDist=10000
}