///////////////////////////////////////////////////////////////////////////////
// LambController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// High-level RWS AI Controllers for singular characters. 
// (SheepController Handles the team AI)
///////////////////////////////////////////////////////////////////////////////
class LambController extends FPSController
	config;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
// User set vars

// Internal vars
var Actor	EndGoal;		// My copy of movetarget (in case movetarget gets overwritten)
var Actor	OldEndGoal;		// Last thing that was my target;
var Actor   ApproxGoal;		// Goal found when you specified a point that was not reachable
							// but this pathnode was nearby and returned to you as a last resort.
var FPSGameInfo.HomeListInfo HomeList;	// Node for list of home nodes we're allowed to pick from. We start 
							// with this node, then progress through the looped list a ways, till we find one we
							// like. We'll use that in idle time to walk to.
							// Also includes the length of that looped list.
var FPSGameInfo.PathListInfo PathList;	// Links into all the path nodes in the level that aren't home nodes
							// and can randomly pick from them for a new point to walk to.
var vector	EndPoint;		// What MovePoint is heading towards
var vector	OldEndPoint;	// Last place you were going before new target
var float	EndRadius;		// Radius we want to have around the end goal (point or actor)
var float	UseEndRadius;	// radius to use on actual checks (the EndRadius or the default CollisionRadius)
var bool	bDontSetFocus;	// If we should face the direction we're heading. This should be explicitly
							// set each time you want it, and should reset (to false) with the end of each move or walk.
var bool	bStraightPath;	// Try to run/walk/crawl to where you are going by the straightest
							// path. Sometimes this means disregarding pathnodes.
var bool	bPreserveMotionValues;	// For functions that might clear the next state
var FPSPawn	Attacker;		// Who just attacked me (but may not be my 'enemy')
var FPSPawn InterestPawn;	// Junk pawn used to see who I'm dealing with
var int     LegMotionCaughtCount; // How many times leg motion has gotten hung up
var byte	LegMotionCaughtMax;	// Max number of times we're allowed to hang up before we change states
var vector	MovePoint;		// What you move to when there is no MoveTarget
var Actor   OldMoveTarget;	// Where you last were
var Actor	InterestActor;  // Trash actor--make sure to cast it to see if it's what you want.
var bool	bMovePointValid;// Say if the MovePoint is valid
var float	UseAttribute;	// A temp state attribute that can get modified inside the current
var float	UseSafeRangeMin;// Current safety min I've determined.
var	float	PersonalSpace;	// Closest distance you care to stand next to people
var int		statecount;		// how many times you've been through a loop or Begin in this state
var int		firecount;		// how often you've fired
var float	CurrentFloat;	// used to pass a certain radius around inside states
var float	CurrentDist;	// Generic distance or distance ratio used inside states.
var name	MyNextState;	// The thing I want to do after this state I'm heading to. Used mostly
							// with generic intermediate states like RunToTarget
var name	MyNextLabel;	// This goes with MyNextState. Defaults to Begin and gets
							// cleared each time it's used
var name	MyOldState;		// What I was doing before the state i'm in now
var bool	bRepeatingSameState;// If we've already done this state just before, it's marked by GotoStateSave
var vector  DangerPos;		// Where the danger happened
var NavigationPoint CurrentPathNode;	// Current path node we're on
var InterestPoint	CurrentInterestPoint;	// interest point you're currently messing with
var InterestPoint	LastInterestPoint;	// Last interest point you actioned
var ProtestorInfo	MyProtestInfo;	// Info controlling marching and protesting for me.
var bool	bImportantDialog;	// Make your dialog important so it's easier to hear (usually
								// set when we're dealing with the dude
var FPSPawn Hero;				// Who I love best. Guard him, attack who attack him, that sort of thing
var Actor	LastBumpStaticMesh;	// Last static mesh we bumped.

// effects
var TimedEmitter MySteam;	// steam rising from me when hit by a Shocker

var Sound TermSound;		// Very hacky way of stopping the dialog from dying people. We play this sound (
							// exact sound doesn't matter) at 0 volume, interrupting (hopefully) the last thing
							// they were saying.. not sure how to stop sounds otherwise.

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////
const LEG_MOTION_CAUGHT_MAX=0;

const GROUND_CHECK_Z	=	1024;

const MIN_VELOCITY_FOR_REAL_MOVEMENT = 50;

const BIG_END_RADIUS		= 190;
const DEFAULT_END_RADIUS	= 70;
const PROTEST_END_RADIUS	= 80;
const TIGHT_END_RADIUS		= 50;

//const CAN_SEE_VIEW_CONE =	0.75;
const CAN_SEE_WEAPON_CONE=	-0.7;
const CAN_GET_SHOT_CONE =   0.995;

const PAWN_RADIUS_VISUAL_FUZZ=0.6;
const PAWN_RADIUS_FUZZ	=	0.8;

const SEEK_PLAYER_BASE	=	1024;
const SEEK_PLAYER_RAND	=	1024;

const STEP_HEIGHT_MAX	=	30.0;

const GOAL_COST_BASE	=	100;
const GOAL_COST_ADD		=	5000;
const GOAL_COST_MAX		=	20000;

const BUFFER_RADIUS_RATIO	=	1.3;

const TARGET_PATHNODE_RADIUS = 512;

const MIN_DIST_FROM_PLAYERS_FOR_STASIS	=	1000; // All players must be at least this far from an AI character
		// before he'll try to go into stasis, if he's wanting to go into stasis.

const MAX_RAND_CHECK	= 32;

// AW stubs
function StartInHalf();
function StartClimbLadder();
function RestartAfterUnRagdoll();
function RestartAfterUnRagdollWait();
function HookHero(FPSPawn NewHero, optional out byte Worked); // stock dog and aw zombie
function DoLiveRagdoll();
function WeaponDropped(P2WeaponPickup grabme);
function bool SeeWeaponDrop(P2WeaponPickup grabme);

///////////////////////////////////////////////////////////////////////////////
// Return false so we don't do underlying script things when we don't want to.
// A good example is doing our own thing when getting destroyed, instead of
// letting ScriptedController do it's thing also.
///////////////////////////////////////////////////////////////////////////////
function bool UsingScript()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Given the max number of nodes to traverse forward (since this loop is closed
// know it will wrap around for us), traverse to a random node within the max.
// bUseFullList lets it search the whole list... otherwise it won't go past
// MAX_RAND_CHECK, this time through
///////////////////////////////////////////////////////////////////////////////
function PathNode FindRandomNode(PathNode cur, int Max, optional bool bUseFullList)
{
	local int i;

	if(bUseFullList)
	{
		if(Max > MAX_RAND_CHECK)
			Max = MAX_RAND_CHECK;
	}

	i = Rand(Max);

	while(i > 0)
	{
		cur = cur.NextNode;
		i--;
	}

	return cur;
}

///////////////////////////////////////////////////////////////////////////////
// Possess the pawn
// Record that he's in the slider pawn group here--not during postbeginplay
// for the pawn itself. That's because we only remove pawns through the controller
// so we should only add them through it also. They're removed in Destroyed below.
///////////////////////////////////////////////////////////////////////////////
function Possess(Pawn aPawn)
{
	Super.Possess(aPawn);
	// Add me to the slider if necessary
	if(FPSPawn(aPawn) != None
		&& !FPSPawn(aPawn).bPersistent
		&& FPSPawn(aPawn).bUsePawnSlider)
	{
		P2GameInfo(Level.Game).SliderPawnsActive++;
		P2GameInfo(Level.Game).SliderPawnsTotal++;
	}
	if(P2GameInfo(Level.Game).LogStasis == 1)
		log(self$" i was pawn number "$P2GameInfo(Level.Game).PawnsActive$" and slider number "$P2GameInfo(Level.Game).SliderPawnsActive);
}

///////////////////////////////////////////////////////////////////////////////
// Called before this pawn is "teleported" with the player so it can save
// essential information that will later be passed to PostTeleportWithPlayer().
///////////////////////////////////////////////////////////////////////////////
function PreTeleportWithPlayer(out FPSGameState.TeleportedPawnInfo info, P2Pawn PlayerPawn)
{
	info.ClassName = String(Pawn.Class);
	info.Tag = Pawn.Tag;
	info.Offset = Pawn.Location - PlayerPawn.Location;
	info.Health = Pawn.Health;
	info.CurrentSkin = Pawn.Skins[0];
	info.CurrentMesh = Pawn.Mesh;
	info.bPersistent = FPSPawn(Pawn).bPersistent;
	info.DialogClass = P2Pawn(Pawn).DialogClass;
	// Save this as our original level (unless we've been travelled here
	// and it's probably not our original level then)
	if(!FPSPawn(Pawn).bTravelledWithPlayer
		&& FPSPawn(Pawn).OrigLevelName == "")
	{
		FPSPawn(Pawn).OrigLevelName = P2GameInfo(Level.Game).ParseLevelName(Level.GetLocalURL());
		log(self$" saving this as my original level "$FPSPawn(Pawn).OrigLevelName);
	}
	else
		log(self$" travelled.. this was my original level "$FPSPawn(Pawn).OrigLevelName);
	info.OrigLevelName = FPSPawn(Pawn).OrigLevelName;
}

///////////////////////////////////////////////////////////////////////////////
// Called after this pawn was "teleported" with the player so it can restore
// itself using the previously-saved information.  See PreTeleportWithPlayer().
///////////////////////////////////////////////////////////////////////////////
function PostTeleportWithPlayer(FPSGameState.TeleportedPawnInfo info, P2Pawn PlayerPawn)
{
	Pawn.Health = info.Health;
	Pawn.Skins[0] = info.CurrentSkin;
	Pawn.LinkMesh(info.CurrentMesh, false);
	FPSPawn(Pawn).bPersistent = info.bPersistent;
	FPSPawn(Pawn).OrigLevelName = info.OrigLevelName;
	log(self$" PostTeleportWithPlayer.. this was my original level "$FPSPawn(Pawn).OrigLevelName);
	log(info.CurrentSkin@info.CurrentMesh);
	// Mark that they travelled with the player.
	FPSPawn(Pawn).bTravelledWithPlayer=true;
	P2Pawn(Pawn).DialogClass = class<P2Dialog>(info.DialogClass);
}

///////////////////////////////////////////////////////////////////////////////
// Prints out the state we're and who did it, in if the debug mode is on
///////////////////////////////////////////////////////////////////////////////
function PrintThisState()
{
	if(P2GameInfo(Level.Game).LogStates == 1)
		log("***in state "$GetStateName()$" for "$Pawn$" and "$self);
}

///////////////////////////////////////////////////////////////////////////////
// When they die, remove me from my q
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	//log(self$" Destroyed, i was pawn number "$P2GameInfo(Level.Game).PawnsActive$" and sliders active "$P2GameInfo(Level.Game).SliderPawnsActive$" and slider max "$P2GameInfo(Level.Game).SliderPawnsTotal);
	P2GameInfo(Level.Game).PawnsActive--;
	if(FPSPawn(Pawn) != None
		&& !FPSPawn(Pawn).bPersistent
		&& FPSPawn(Pawn).bUsePawnSlider)
	{
		if(!FPSPawn(Pawn).bSliderStasis)
			P2GameInfo(Level.Game).SliderPawnsActive--;
		P2GameInfo(Level.Game).SliderPawnsTotal--;
	}

	// Send him to a 'nothing' state so that he at least calls his
	// EndState function for whatever state he's in, and gets cleaned up
	// as necessary
	GotoState('Destroying');

	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// There was an error, so print a log of it with state info
///////////////////////////////////////////////////////////////////////////////
function PrintStateError(String infostr)
{
	log(Pawn$" and "$self$" ERROR: in "$GetStateName()$": "$infostr);
}

///////////////////////////////////////////////////////////////////////////////
// If this pawn is the in the same gang as the pawn for my controller
///////////////////////////////////////////////////////////////////////////////
function bool SameGang(FPSPawn Other)
{
	return (Other.Gang != ""
		&& Other.Gang == FPSPawn(Pawn).Gang);
}

///////////////////////////////////////////////////////////////////////////
// Default is same as gangs, though cops have more complex friend system
///////////////////////////////////////////////////////////////////////////
function bool FriendWithMe(FPSPawn Other)
{
	return (Other.Gang != ""
		&& Other.Gang == FPSPawn(Pawn).Gang);
}

///////////////////////////////////////////////////////////////////////////////
// Determines how much a threat to the player this pawn is
///////////////////////////////////////////////////////////////////////////////
function float DetermineThreat()
{
	return 0.1;
}

///////////////////////////////////////////////////////////////////////////////
// Use nearest pathnode that isn't where I already am
///////////////////////////////////////////////////////////////////////////////
function UseNearestPathNode(float UseRad, optional float usesize)
{
	local PathNode nextpnode;
	local vector HitNormal, HitLocation, checkpoint;

	if(usesize == 0)
		usesize = DEFAULT_END_RADIUS;

	checkpoint = Pawn.Location;
	checkpoint.z += Pawn.CollisionHeight;

	foreach RadiusActors(class'PathNode', nextpnode, UseRad, Pawn.Location)
	{
		if(nextpnode != None
			&& nextpnode != PathNode(Pawn.Anchor)
			&& nextpnode != EndGoal)
		{
			if(FastTrace(nextpnode.Location, checkpoint))
			{
				SetEndGoal(nextpnode, usesize);
				return;
			}
		}
	}

	// If you didn't find anything, do it right here
	if(Pawn.Anchor != None)
		SetEndGoal(Pawn.Anchor, usesize);
	else
		SetEndPoint(Pawn.Location, usesize);
}

///////////////////////////////////////////////////////////////////////////////
// Used in LegMotion states
///////////////////////////////////////////////////////////////////////////////
function DodgeThinWall()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Do things after you reach a crappy goal, not your end goal
///////////////////////////////////////////////////////////////////////////////
function IntermediateGoalReached()
{
	// STUB--Used in LegMotion states
}

///////////////////////////////////////////////////////////////////////////////
// Dude just complete an errand
///////////////////////////////////////////////////////////////////////////////
function DudeErrandComplete()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// True if this pawn is the postal dude masquerading as a cop
///////////////////////////////////////////////////////////////////////////////
function bool DudeDressedAsDude(FPSPawn CheckP)
{
	local P2Player p2p;

	if(CheckP != None)
	{
		p2p = P2Player(CheckP.Controller);
		if(p2p != None 
		   && p2p.DudeIsDude())
			return true;
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// True if this pawn is the postal dude masquerading as a cop
///////////////////////////////////////////////////////////////////////////////
function bool DudeDressedAsCop(FPSPawn CheckP)
{
	local P2Player p2p;

	if(CheckP != None)
	{
		p2p = P2Player(CheckP.Controller);
		if(p2p != None 
		   && p2p.DudeIsCop())
			return true;
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// True if this pawn is the postal dude dressed up as the gimp
///////////////////////////////////////////////////////////////////////////////
function bool DudeDressedAsGimp(FPSPawn CheckP)
{
	local P2Player p2p;

	if(CheckP != None)
	{
		p2p = P2Player(CheckP.Controller);
		if(p2p != None 
			&& p2p.DudeIsGimp())
			return true;
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// True if this pawn is the anyone (dude or otherwise) dressed up as the gimp
///////////////////////////////////////////////////////////////////////////////
function bool PersonDressedAsGimp(FPSPawn CheckP)
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// match this tag to its actor
///////////////////////////////////////////////////////////////////////////////
function Actor FindNearestActorByTag(Name UseTag)
{
	local Actor CheckA, LastValid;
	local float dist, keepdist;

	if(UseTag != 'None')
	{
		dist = 100000;
		keepdist = dist;

		ForEach AllActors(class'Actor', CheckA, UseTag)
		{
			if(!CheckA.bDeleteMe
				&& (Pawn(CheckA) == None
					|| Pawn(CheckA).Health > 0))
			{
				dist = VSize(CheckA.Location - Pawn.Location);
				if(dist < keepdist)
				{
					LastValid = CheckA;
					dist = keepdist;
				}
			}
		}

		return LastValid;
	}
	return None;
}

///////////////////////////////////////////////////////////////////////////////
// match this tag to its actor
///////////////////////////////////////////////////////////////////////////////
function Actor FindActorByTag(Name UseTag)
{
	local Actor CheckA, LastValid;
	if(UseTag != 'None')
	{
		ForEach AllActors(class'Actor', CheckA, UseTag)
		{
			if(!CheckA.bDeleteMe)
				return CheckA;
		}
	}
	return None;
}

///////////////////////////////////////////////////////////////////////////////
// Go into a stasis, trying to conserve processor speed
///////////////////////////////////////////////////////////////////////////////
function GoIntoStasis(optional name StasisName)
{
	local name UseName;

	if(IsInState('LegMotionToTarget'))
		bPreserveMotionValues=true;

	if(StasisName != '')
		UseName = StasisName;
	else
		UseName = 'StasisState';

	GotoStateSave(UseName);
}

///////////////////////////////////////////////////////////////////////////////
// exit a stasis
///////////////////////////////////////////////////////////////////////////////
event ComeOutOfStasis(bool bDontRenew)
{
	GotoState(MyOldState);
}

///////////////////////////////////////////////////////////////////////////
// More advanced than ComeOutOfStasis because it brings him out
// but also resets him for a while to not go back into stasis at least for a bit
///////////////////////////////////////////////////////////////////////////
event ReviveFromStasis()
{
//	log(self$" revived");
	bPendingStasis=false;
	ComeOutOfStasis(false);
	// Setting this will allow him to walk around a little at least, and if
	// he stops but is still out of view, then he'll rightfully get put back into stasis
	FPSPawn(Pawn).TimeTillStasis=0;
}

///////////////////////////////////////////////////////////////////////////////
// Force going into normal stasis, and set your slider stasis, which means
// you're totally out of play, and are invisible.
///////////////////////////////////////////////////////////////////////////////
function GoIntoSliderStasis()
{
	if(!FPSPawn(Pawn).bSliderStasis)
	{
		GoIntoStasis('SliderStasis');
		FPSPawn(Pawn).bSliderStasis=true;
		// Make him invisible
		FPSPawn(Pawn).bHidden=true;
		// Turn off all collision
		bCollideWorld=false;
		FPSPawn(Pawn).SetCollision(false, false, false);
		// Record that we lost another to slider stasis (but he's not dead, of course)
		if(P2GameInfo(Level.Game).LogStasis == 1)
			log(self$" GoIntoSliderStasis, i was pawn number "$P2GameInfo(Level.Game).PawnsActive$" and sliders active "$P2GameInfo(Level.Game).SliderPawnsActive$" and slider max "$P2GameInfo(Level.Game).SliderPawnsTotal$" slider goal "$P2GameInfo(Level.Game).SliderPawnGoal);
		P2GameInfo(Level.Game).SliderPawnsActive--;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Try to put him back to his normal mode. This only works if the collision
// can be turned back on properly.
// Tell him to start doing what he
// was doing before, again, and become visible.
///////////////////////////////////////////////////////////////////////////////
function ComeOutOfSliderStasis()
{
	local vector useloc;

	//log(Pawn$" trying ComeOutOfSliderStasis");

	if(FPSPawn(Pawn).bSliderStasis)
	{
		bCollideWorld=true;
		FPSPawn(Pawn).SetCollision(true, true, true);
		// Make sure after the collision switch, that he can be placed in the same
		// spot, ensuring he's not stuck in something.
		useloc = Pawn.Location;
		useloc.z+=1;
		if(Pawn.SetLocation(useloc))
		{
			//log(Pawn$" success! turning him back on");
			FPSPawn(Pawn).bSliderStasis=false;
			// Make him visible
			FPSPawn(Pawn).bHidden=false;
			ComeOutOfStasis(false);
			// Count him again as active
			P2GameInfo(Level.Game).SliderPawnsActive++;
			if(P2GameInfo(Level.Game).LogStasis == 1)
				log(self$" Active again! i was pawn number "$P2GameInfo(Level.Game).PawnsActive$" and sliders active "$P2GameInfo(Level.Game).SliderPawnsActive$" and slider max "$P2GameInfo(Level.Game).SliderPawnsTotal);
		}
		else
		{
			//log(Pawn$" failure, keeping him off");
			// Re-turn off all collision
			bCollideWorld=false;
			FPSPawn(Pawn).SetCollision(false, false, false);
		}
	}
}

///////////////////////////////////////////////////////////////////////////
// You're not doing anything important enough to keep you from walking to
// the player (to get into some of the action). If you're bound by home nodes
// you won't do this. And only a few states allow this
///////////////////////////////////////////////////////////////////////////
function bool FreeToSeekPlayer()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////
// More advanced than ComeOutOfStasis because it brings him out
// but also resets him for a while to not go back into stasis at least for a bit
// This also tries to make him walk to the player so he'll be seen again
// before going back into stasis
///////////////////////////////////////////////////////////////////////////
function PartnerReviveFromStasis(FPSPawn Reviver)
{
	local P2Player p2p;

	return;	// Temporarily removed until we figure out a better thing to do on stasis revival.
	/*
	if(!FPSPawn(Pawn).bSliderStasis)
	{
		log(Reviver$" partner waking "$Pawn);

		bPendingStasis=false;
		// Default to your old state
		GotoState(MyOldState);
		// But you may be able to seek the player--That is--where the player *is currently* he
		// could easily have moved since then, but it'll at least shuffle things around a lot more.
		// See if you'll let yourself be brought out of stasis and sent to walk towards the player
		if(FreeToSeekPlayer()
			&& FPSPawn(Pawn).HomeTag != '')
		{
			p2p = GetRandomPlayer();
			if(p2p != None)
			{
				SetEndPoint(p2p.MyPawn.Location, SEEK_PLAYER_BASE + Rand(SEEK_PLAYER_RAND));
				SetNextState('Thinking');
				GotoState('WalkToTarget');
			}
		}
		// Setting this will allow him to walk around a little at least, and if
		// he stops but is still out of view, then he'll rightfully get put back into stasis
		FPSPawn(Pawn).TimeTillStasis=0;
	}
	*/
}

///////////////////////////////////////////////////////////////////////////
// Don't let a guy be in stasis anymore
///////////////////////////////////////////////////////////////////////////
function DisallowStasis()
{
//	log(self$" DisallowStasis");
	FPSPawn(Pawn).bAllowStasis=false;
	bPendingStasis=false;
	if(bStasis)
		ComeOutOfStasis(true);
}

///////////////////////////////////////////////////////////////////////////
// Let this guy be in stasis anymore if he needs to be
///////////////////////////////////////////////////////////////////////////
function ReallowStasis()
{
//	log(self$" ReallowStasis");
	FPSPawn(Pawn).bAllowStasis=true;
}

///////////////////////////////////////////////////////////////////////////
// Handle stasis changes here, that is, try to go in or out of it here
// depending on the pending state
///////////////////////////////////////////////////////////////////////////
function HandleStasisChange()
{
	local controller con;

	// If wanting to go into stasis
	if(bPendingStasis)
	{
		if(!bStasis)
		{
			/*
			// Do a proximity test to see if the player is around me
			// if so, don't go into stasis yet, but keep your pending status
			// Do this for all the player pawns versus this guy
			for(con = Level.ControllerList; con != None; con=con.NextController)
			{
				// Found a player
				if(con.bIsPlayer && con.Pawn!=None)
				{
					// Check distance between this player and this character
					if(VSize(con.Pawn.Location - Pawn.Location) < MIN_DIST_FROM_PLAYERS_FOR_STASIS)
					{
						if(P2GameInfo(Level.Game).LogStasis == 1)
							log("too close to "$con.Pawn$" at "$VSize(con.Pawn.Location - Pawn.Location));
						return; // interrupt try, and leave now
					}
				}
			}*/
			
			// Moved to native code
			if (!SafeToGoIntoStasis(MIN_DIST_FROM_PLAYERS_FOR_STASIS))
			{
				if(P2GameInfo(Level.Game).LogStasis == 1)
					log(self@"Too close to player to go into stasis.");
				return;
			}

			// Apparently we're far enough from any players, so try it
			GoIntoStasis();
		}

		// If it worked, then turn off the pending status
		if(bStasis)
			bPendingStasis=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set the pending status of the Stasis for this controller. 
// Stasis will only be set in certain states like Thinking, to ensure
// important states aren't wiped out.
///////////////////////////////////////////////////////////////////////////////
function MakeStasisPending(bool bPending)
{
	bPendingStasis=bPending;
}

///////////////////////////////////////////////////////////////////////////////
// Find a random player--FIX ME make me more evenly random
///////////////////////////////////////////////////////////////////////////////
function P2Player GetRandomPlayer()
{
	local P2Player checkp, keepp, firstp;
	
	// ErikFOV Change: For Nick's coop
	local P2Player ThisPlayer;

	if( Level.Game != None && P2GameInfo(Level.Game) != None )
		ThisPlayer = P2GameInfo(Level.Game).xGetValidPlayerFor(self);

	if( ThisPlayer != None )
		return ThisPlayer;
	//End

	// try to halfway pick one randomly
	foreach AllActors(class'P2Player', checkp)
	{
		if(checkp != None)
		{
			if(firstp == None)
				firstp = checkp;
			if(FRand() <= 0.3)
				keepp = checkp;
		}
	}

	if(P2GameInfo(Level.Game).LogStates == 1)
		log(Pawn$" get me a random player "$keepp$" first "$firstp);

	// if we missed, get the first one for sure
	if(keepp == None)
		return firstp;
	else
		return keepp;
}

///////////////////////////////////////////////////////////////////////////////
// setup the next state and label
///////////////////////////////////////////////////////////////////////////////
function SetNextState(name ANewState, optional name ANewLabel)
{
	MyNextState=ANewState;
	if(ANewLabel == '')
		MyNextLabel = 'Begin';
	else
		MyNextLabel = ANewLabel;
}

///////////////////////////////////////////////////////////////////////////////
// go to state but save what you just were in before you leave
///////////////////////////////////////////////////////////////////////////////
function GotoStateSave(name ANewState, optional name ANewLabel)
{
	local name oldone;
	oldone = GetStateName();

	if(AllowOldState())
	{
		if(MyOldState != oldone)
		{
			MyOldState = oldone;
			bRepeatingSameState=false;
		}
		else
			bRepeatingSameState=true;
	}

	GotoState(ANewState, ANewLabel);
}

///////////////////////////////////////////////////////////////////////////////
// Save the old state, go to MyNextState, and clear it afterwards
///////////////////////////////////////////////////////////////////////////////
function GotoNextState(optional bool bDontSave)
{
	if(MyNextLabel == 'Begin')
	{
		if(bDontSave)
			GotoState(MyNextState);
		else
			GotoStateSave(MyNextState);
	}
	else
		GotoState(MyNextState, MyNextLabel);

	MyNextState='';
	MyNextLabel='';
}

///////////////////////////////////////////////////////////////////////////////
// Default to return true so you allow the old state return. Ignore this
// function to not allow entry to old state. Usually, if you can't go 
// back to your old state, just to go thinking.
///////////////////////////////////////////////////////////////////////////////
function bool AllowOldState()
{
//	if((IsInState('OnePassMove')
//			&& MyOldState == GetStateName())
//		|| (IsInState('WaitOnOtherGuy')
//			&& MyOldState == GetStateName()))
//		return false;
//	else
		return true;
}

///////////////////////////////////////////////////////////////////////////////
// clear out all things having to do with moving places
///////////////////////////////////////////////////////////////////////////////
function ClearGoals()
{
	bMovePointValid=false;
	MoveTarget=None;
}

///////////////////////////////////////////////////////////////////////////////
// Save what you last cared about
///////////////////////////////////////////////////////////////////////////////
function RememberEndTarget()
{
	if(EndGoal != None)
		OldEndGoal = EndGoal;
	else
	{
		OldEndGoal = None;
		OldEndPoint = EndPoint;
	}
	log(Pawn$" end goal "$EndGoal$" old goal "$OldEndGoal);
}

///////////////////////////////////////////////////////////////////////////////
// Local spot to set my target, only assigns old when not none.
///////////////////////////////////////////////////////////////////////////////
function SetEndGoal(Actor NewTarget, float SetRadius)
{
	if(EndGoal != NewTarget)
	{
//		if(EndGoal != None)
//			OldEndGoal = EndGoal;

		EndGoal = NewTarget;
	}
	EndRadius = SetRadius;
}

///////////////////////////////////////////////////////////////////////////////
// Local spot to set my target, only assigns old when not none.
///////////////////////////////////////////////////////////////////////////////
function SetEndPoint(vector newpoint, float SetRadius)
{
	EndGoal = None;
	if(EndPoint != newpoint)
	{
		//OldEndPoint = EndPoint;
		EndPoint = newpoint;
	}
	EndRadius = SetRadius;
}

///////////////////////////////////////////////////////////////////////////////
// aiming up and down
///////////////////////////////////////////////////////////////////////////////
function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
	local Rotator checkrot;
	local vector TargetPoint, hitline;
	local float fdist, disterror, pterror, pthalf;

	if(Enemy == None)
	{
		return Rotation; // shoot straight ahead
	}

	// Trying to actually hit someone, so aim at them
	TargetPoint = Enemy.Location;

	hitline = TargetPoint - ProjStart;
	fdist = VSize(hitline);

	if(fdist < Pawn.SightRadius)
		disterror = fdist/Pawn.SightRadius;
	else
		disterror = 1.0;

	pterror = disterror*3*Enemy.CollisionRadius;
	//log("pterror "$pterror);

	pthalf = pterror/2;
	TargetPoint.x += (pterror*FRand() - pthalf);
	TargetPoint.y += (pterror*FRand() - pthalf);
	TargetPoint.z += (pterror*FRand() - pthalf);

	hitline = TargetPoint - ProjStart;

	checkrot = Rotator(hitline);

	return checkrot;
}

///////////////////////////////////////////////////////////////////////////////
// Check for things like fire in the way, and see what to do about it.
///////////////////////////////////////////////////////////////////////////////
function CheckForObstacles()
{
	local float damageScale, dist;
	local vector HitNormal, HitLocation, EndLoc;
	local Actor HitActor;
	local bool bHitFire;
	
	if(FPSPawn(Pawn).MyBodyFire != None)
		return;

	if(MoveTarget != None)
		EndLoc = MoveTarget.Location;
	else
		EndLoc = MovePoint;

	//log("check for obstacles");
	foreach TraceActors( class 'Actor', HitActor, HitLocation, HitNormal, EndLoc, Pawn.Location )
	{
		if( HitActor != self && HitActor != MoveTarget)
		{
			if(FireEmitter(HitActor) != None)
			{
				//log("there is fire in my way"$HitActor);
				HandleFireInWay(FireEmitter(HitActor));
				return; // leave now that you've hit the closest fire
			}
			//log("Actor in my way!"$HitActor);
		} 
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check for fire a long a line
///////////////////////////////////////////////////////////////////////////////
function FireEmitter CheckForFire(vector startpt, vector endpt)
{
	local vector HitNormal, HitLocation;
	local FireEmitter HitActor;

	foreach TraceActors( class 'FireEmitter', HitActor, HitLocation, HitNormal, endpt, startpt )
	{
		return HitActor;
	}
	return None;
}

///////////////////////////////////////////////////////////////////////////
// A rocket is chasing me! Run!
///////////////////////////////////////////////////////////////////////////
function RocketIsAfterMe(FPSPawn Shooter, Actor therocket)
{
	// STUB-- only persons know when a rocket is after them
}

///////////////////////////////////////////////////////////////////////////////
// Determine what to do after this
///////////////////////////////////////////////////////////////////////////////
function NextStateAfterGoal()
{
	// STUB -- used in LegMotion functions
}

///////////////////////////////////////////////////////////////////////////////
// Determine what to do after you got hung up on something
///////////////////////////////////////////////////////////////////////////////
function NextStateAfterHangUp()
{
	// STUB -- used in LegMotion functions
}

///////////////////////////////////////////////////////////////////////////////
// Decide what to do if you bump a static mesh
///////////////////////////////////////////////////////////////////////////////
function BumpStaticMesh(Actor Other)
{
	// STUB -- used in LegMotion functions
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function CheckBumpStaticMesh(Actor Other)
{
	local vector checkvec, StartTrace, EndTrace, HitLoc, HitNorm;
	//log(Pawn$" CheckBumpStaticMesh "$Other);

	if(LastBumpStaticMesh != Other)
	{
		LastBumpStaticMesh = Other;

		checkvec = Pawn.Location + (Pawn.CollisionRadius + 5)*vector(Rotation);
		StartTrace = checkvec;
		StartTrace.z = checkvec.z + Pawn.CollisionHeight;
		EndTrace = checkvec;
		EndTrace.z -= Pawn.CollisionHeight;
		//log(Pawn$" trace "$StartTrace$" end "$EndTrace$" my pos "$Pawn.Location);
		if(Other == Trace(HitLoc, HitNorm, EndTrace, StartTrace, false))
		{
			//log(self$" hit it at "$HitLoc$" norm "$HitNorm$" zdiff "$(Pawn.CollisionHeight - (Pawn.Location.z - HitLoc.z)));
			if((Pawn.CollisionHeight - (Pawn.Location.z - HitLoc.z)) > STEP_HEIGHT_MAX)
			{
				//log(Pawn$" too high");
				LegMotionCaughtCount++;
				if(LegMotionCaughtCount > LegMotionCaughtMax)
				{
					//log(Pawn$" resetting after bump DodgeThinWall, endgoal was "$EndGoal$" current "$MoveTarget$" move point "$MovePoint$" end point "$EndPoint);
					NextStateAfterHangUp();
				}
			}
		}
	}
	//else
	//	log(Pawn$" already hit this ");
}

///////////////////////////////////////////////////////////////////////////////
// setup a simple side step
///////////////////////////////////////////////////////////////////////////////
function SetupSideStep(float goright)
{
	// STUB, real is in LegMotion functions
}

///////////////////////////////////////////////////////////////////////////////
// Setup a move out of the way
///////////////////////////////////////////////////////////////////////////////
function SetupMoveForRunner(P2Pawn Asker)
{
	// STUB, real is in personcontroller
}

///////////////////////////////////////////////////////////////////////////////
// setup a simple back step
///////////////////////////////////////////////////////////////////////////////
function SetupBackStep(float BaseDist, float RandDist)
{
	// STUB, real is in LegMotion functions
}

///////////////////////////////////////////////////////////////////////////////
// Things to do while you're in locomotion
///////////////////////////////////////////////////////////////////////////////
function InterimChecks()
{
	// STUB, real is in LegMotion functions
}

///////////////////////////////////////////////////////////////////////////////
// Get out of the way of the door
///////////////////////////////////////////////////////////////////////////////
function MoveAwayFromDoor(DoorMover TheDoor)
{
}

///////////////////////////////////////////////////////////////////////////////
// Check if we want to talk to this person
///////////////////////////////////////////////////////////////////////////////
function StartConversation( P2Pawn Other, optional out byte StateChange )
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Check if we're able to start conversations, most of the times, no,
// statechange == 1, means yes
///////////////////////////////////////////////////////////////////////////////
function CanStartConversation( P2Pawn Other, optional out byte StateChange )
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Check if we're allowed to be mugged right now, statechange == 1, means yes
///////////////////////////////////////////////////////////////////////////////
function CanBeMugged( P2Pawn Other, optional out byte StateChange )
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// See if you care about using a door
///////////////////////////////////////////////////////////////////////////////
function CheckToUseDoor(out byte StateChange)
{
	// STUB, real is in WaitAroundDoor functions
	StateChange = 0;
}

///////////////////////////////////////////////////////////////////////////////
// Most of the time you'll handle the door nicely
///////////////////////////////////////////////////////////////////////////////
function bool CheckForNormalDoorUse()
{
	// STUB, real is in LegMotion functions
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// See if you really want to wait on a door, to go through it
///////////////////////////////////////////////////////////////////////////////
function bool PrepToWaitOnDoor(DoorBufferPoint thisdoor)
{
	// STUB, real is in LegMotion functions
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// The door doesn't want you
///////////////////////////////////////////////////////////////////////////////
function TryToSendAway()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// In the mean time, just look for a roof to determine to use the straight
// path code
///////////////////////////////////////////////////////////////////////////////
function bool UseStraightPath()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Set new target and pick path
///////////////////////////////////////////////////////////////////////////////
function bool HasStraightPath(vector HerePoint, vector DestPoint, float userad,
							  bool bStrictCheck)
{
	local vector startp, endp;
	local vector st1, end1, st2, end2;
	local vector startdir, checkdir;

//	log("check straight path");
/*
	// left 
	checkdir.x = -startdir.y;
	checkdir.y = startdir.x;
	// right
	checkdir.x = startdir.y;
	checkdir.y = -startdir.x;
*/
	if(!FastTrace(DestPoint, HerePoint))
		return false;

	startdir = Normal(DestPoint - HerePoint);

	//log("start check "$startdir);

	// left 
	checkdir.x = -startdir.y;
	checkdir.y = startdir.x;
	checkdir.z = startdir.z;
	// move to the left by the radius and then test forward
	checkdir = userad*checkdir;
	startp = HerePoint + checkdir;
	endp = DestPoint + checkdir;
	//log("left start "$startp);
	//log("left end "$endp);
	// check to the left
	if(!FastTrace(endp, startp))
		return false;

	// record these for strict checks
	st1 = startp;
	end1 = endp;

	// It worked on the left, so check on the right
	// right
	checkdir.x = startdir.y;
	checkdir.y = -startdir.x;
	checkdir.z = startdir.z;
	// move to the left by the radius and then test forward
	checkdir = userad*checkdir;
	startp = HerePoint + checkdir;
	endp = DestPoint + checkdir;

	//log("right start "$startp);
	//log("right end "$endp);
	// now check for no obstructions to the right
	if(!FastTrace(endp, startp))
		return false;

	// if we're strict, also check in a X-shape over the path you're looking
//	if(bStrictCheck)
//	{
//		log("PERFORMING STRICT TEST");
		// record these for strict checks
		st2 = startp;
		end2 = endp;
		// If either of these hit something, also fail here
		// check from end 2 to start 1
		if(!FastTrace(end2, st1))
			return false;
		// check from end 1 to start 2
		if(!FastTrace(end1, st2))
			return false;
//	}

	// It worked! A straight path from HerePoint to DestPoint!
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// a line of sight test
///////////////////////////////////////////////////////////////////////////////
function bool CanSeeAnyPart(Pawn Looker, Pawn Other)
{
	local vector startp, endp;
	local vector startdir, checkdir;
	local float userad;

	if(FastTrace(Other.Location, Looker.Location))
		return true;	// we could see you through here

	userad = PAWN_RADIUS_VISUAL_FUZZ*Other.CollisionRadius;

	startdir = Normal(Other.Location - Looker.Location);

	//log("start check "$startdir);

	// left 
	checkdir.x = -startdir.y;
	checkdir.y = startdir.x;
	checkdir.z = startdir.z;
	// move to the left by the radius and then test forward
	checkdir = userad*checkdir;
	startp = Looker.Location + checkdir;
	endp = Other.Location + checkdir;
	//log("left start "$startp);
	//log("left end "$endp);
	// check to the left

	if(FastTrace(endp, startp))
		return true;	// we could see you through here

	// It worked on the left, so check on the right
	// right
	checkdir.x = startdir.y;
	checkdir.y = -startdir.x;
	checkdir.z = startdir.z;
	// move to the left by the radius and then test forward
	checkdir = userad*checkdir;
	startp = Looker.Location + checkdir;
	endp = Other.Location + checkdir;
	//log("right start "$startp);
	//log("right end "$endp);
	// now check for no obstructions to the right
	if(FastTrace(endp, startp))
		return true;	// we could see you through here

	// We're completely hidden!
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// See if there is something in the way
///////////////////////////////////////////////////////////////////////////////
function bool TestPath(vector DestPoint, optional bool bStrictCheck)
{
	if(PointReachable(DestPoint)
		||	// if you want a straight path and there's nothing in the way
		HasStraightPath(Pawn.Location, DestPoint, PAWN_RADIUS_FUZZ*Pawn.CollisionRadius, bStrictCheck))
		return true;
	else
	{
		if(FindPathTo(DestPoint) != None)
			return true;
	}
	return false;
	// Check for things in the way
//	CheckForObstacles();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Pathnode TargetClosestPathnode(vector DestPoint)
{
	local PathNode pn, closepn;
	local float closest, dist;

	closest = TARGET_PATHNODE_RADIUS;
	foreach RadiusActors(class'PathNode', pn, TARGET_PATHNODE_RADIUS, DestPoint)
	{
		dist = VSize(pn.Location - DestPoint);
		if(dist < closest)
		{
			//if(FastTrace(pn.Location, DestPoint))
			//{
				closest = dist;
				closepn = pn;
				//break;
			//}
		}
	}
	return closepn;
}

///////////////////////////////////////////////////////////////////////////////
// If the SetActorTarget functions below can't find a proper path and end up
// just setting the next move target as the destination itself, this function
// will be called, so you can possibly exit your state and do something else instead.
///////////////////////////////////////////////////////////////////////////////
function CantFindPath(Actor Dest, optional vector DestPoint)
{
}

///////////////////////////////////////////////////////////////////////////////
// Set new target and pick path
///////////////////////////////////////////////////////////////////////////////
function SetActorTarget(Actor Dest, optional bool bStrictCheck)
{
	local Actor DestResult;

	bMovePointValid = false;
	if(MoveTarget != None)
		OldMoveTarget = MoveTarget;
	//log(Pawn$" SetActorTarget checking " $Dest);
	MoveTarget = None;

	// Don't use the actor reachable test to walking to pathnodes--
	// always use the path system when walking to pathnodes. Otherwise,
	// test to possibly just walk there.
	if(PathNode(Dest) == None
		&& ActorReachable(Dest))
	{
		DestResult = Dest;
		MoveTarget = Dest;
		//log(Pawn$" actor was reachable, "$Dest);
	}
	else
	{
		DestResult = FindPathToward(Dest);
		MoveTarget = DestResult;
		//log(Pawn$" trying to find path toward, dest "$Dest$", move target "$MoveTarget);
	}

	//log(Pawn$" SetActorTarget, move target is "$MoveTarget$" actor dest "$Dest);

	if(MoveTarget == None)
	{
		// Only try to approximate it if we haven't already once this round
		if(ApproxGoal == None)
		{
			ApproxGoal = TargetClosestPathnode(Dest.Location);
			if(ApproxGoal != None
				&& ApproxGoal != Dest)
			{
				//log(Pawn$" +++++++++++++++ using this pathnode instead "$ApproxGoal$" at "$ApproxGoal.Location$" found path? "$FindPathToward(ApproxGoal));
				MoveTarget = FindPathToward(ApproxGoal);
			}
		}

		// If we still couldn't find anything, go straight there.
		if(MoveTarget == None
			|| DestResult == None)
		{
			MoveTarget = Dest;

			CantFindPath(Dest);

			//log(Pawn$" sending him straight there, SetActorTarget "$Dest$" me at "$Pawn.Location);
			if(Dest == None)
				PrintStateError("SetActorTarget Dest is null");
		}
	}
	//else
	//{
	//	log("set movetarget in SetActorTarget "$MoveTarget);
	//}

	if(!bDontSetFocus)
		Focus = MoveTarget;

	// If we're heading to our target, then make it the end radius,
	// otherwise, pick the normal collision radius
	if(MoveTarget == Dest)
		UseEndRadius = EndRadius;
	else
		UseEndRadius = MoveTarget.CollisionRadius;

	CheckForObstacles();
}

///////////////////////////////////////////////////////////////////////////////
// Set new target point and pick path
///////////////////////////////////////////////////////////////////////////////
function SetActorTargetPoint(vector DestPoint, optional bool bStrictCheck)
{
	local Actor DestResult;

	bMovePointValid = false;
	MoveTarget=None;

	//log(Pawn$" SetActorPoint checking " $DestPoint);
	if(PointReachable(DestPoint))
	{
		//log("setting target point");
		MovePoint = DestPoint;
		bMovePointValid = true;
		UseEndRadius = EndRadius;
	}
	else
	{
		DestResult = FindPathTo(DestPoint);
		MoveTarget = DestResult;
		// Only if we're going to the last point, do we want the real end radius.
		// Generally just use the collision radius of the object
		if(MoveTarget != None)
		{
			UseEndRadius = MoveTarget.CollisionRadius;
			//log("move target picked "$MoveTarget);
		}
		else // We don't know how to get there, so do a quick test around this area to 
			// find a close by path node
		{
			// Only try to approximate it if we haven't already once this round
			if(ApproxGoal == None)
			{
				ApproxGoal = TargetClosestPathnode(DestPoint);
				if(ApproxGoal != None)
				{
					//log(Pawn$" ***************** using this pathnode instead "$ApproxGoal$" at "$ApproxGoal.Location$" found path? "$FindPathToward(ApproxGoal));
					MoveTarget = FindPathToward(ApproxGoal);
				}
			}

			// If we still couldn't find anything, go straight there.
			if(MoveTarget == None
				|| (DestResult == None
					&& !bMovePointValid))
			{
				CantFindPath(None, DestPoint);
				//log(Pawn$" sending him straight there, SetActorTargetPoint "$DestPoint$" me at "$Pawn.Location);
				MovePoint = DestPoint;
				bMovePointValid = true;
				UseEndRadius = EndRadius;
			}
		}
	}

	if(!bDontSetFocus)
	{
		if(MoveTarget == None)
		{
			FocalPoint = DestPoint;
			Focus = None;
		}
		else
			Focus = MoveTarget;
	}
	// Check for things in the way
	CheckForObstacles();
}

///////////////////////////////////////////////////////////////////////////////
// Already have one collision and move it from the wall.
// This 'wall' for the most part will be a conventional wall, so we're fine.
// We'll just take the normal of the wall and move our point out by the collision
// radius of the pawn. The problem comes when the wall is tilted in slightly,
// with a normal of say, (0.98, 0, 0.19). This would cause the conventional method
// to project the point upwards some, and not far enough away from the wall. The
// worst part is, the 'wall' could be something as bad as (0.19, 0, 0.98)--completely
// backwards, but still just tipped up enough to be seen as a wall, and picked.
// In that case, it would take several more checks to find the edges of the wall.
// So we wouldn't want to spend that time, but we could do a simple, crappy job of
// adding the absolute value of the Z component to the direction of the X,Y of the
// normal to get us away from the edge, and not be pushed up into the air.
///////////////////////////////////////////////////////////////////////////////
function MovePointFromWall(out vector HitLocation, vector HitNormal, Pawn UsePawn)
{
	local vector minorNormal;

	if(HitNormal.z != 0)
	{
		//log(Pawn$" MovePointFromWall, normal "$HitNormal$" start point "$HitLocation$" Usepawn loc "$UsePawn.Location);

		minorNormal.x=HitNormal.x;
		minorNormal.y=HitNormal.y;
		minorNormal = Normal(minorNormal);
		//log(Pawn$" minor normal "$minorNormal);
		// Find direction of just the x,y, then make it of the HitNormal z magnitude
		minorNormal = abs(HitNormal.z)*minorNormal;
		//log(Pawn$" finished minor normal "$minorNormal);
		// Now take this new vector and add it on to the original HitNormal
		HitNormal.z = 0;
		HitNormal = HitNormal + minorNormal;
		//log(Pawn$" new HitNormal "$HitNormal);
		HitLocation = HitLocation + BUFFER_RADIUS_RATIO*UsePawn.CollisionRadius*HitNormal;
		//log(Pawn$" MovePointFromWall, use point "$HitLocation);
	}
	else
		HitLocation = HitLocation + BUFFER_RADIUS_RATIO*UsePawn.CollisionRadius*HitNormal;
}

///////////////////////////////////////////////////////////////////////////////
// Collision or not, we have to raise this up from the ground, or find the ground?
///////////////////////////////////////////////////////////////////////////////
function RaisePointFromGround(out vector startpoint, Pawn ThisPawn)
{
	local vector checkpoint, HitLocation, HitNormal;
	local Actor HitActor;

	checkpoint = startpoint;
	checkpoint.z -= GROUND_CHECK_Z; // check down for the ground
	HitActor = Trace(HitLocation, HitNormal, checkpoint, startpoint, false);

	if(HitActor != None)
	{
		// raise it up by his height
		startpoint.z = HitLocation.z + ThisPawn.CollisionRadius*HitNormal.z;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check this direction for walking
///////////////////////////////////////////////////////////////////////////////
function CheckMoveDest(out vector endpoint, vector startpoint, 
					   out float disttothere, bool bCheckActors)
{
	local vector HitLocation, HitNormal;
	local Actor HitActor;

	HitActor = Trace(HitLocation, HitNormal, endpoint, startpoint, bCheckActors);
	if(HitActor != None)
	{
		MovePointFromWall(HitLocation, HitNormal, Pawn);
		endpoint = HitLocation;
	}

	disttothere = VSize(startpoint - endpoint);
}

///////////////////////////////////////////////////////////////////////////////
// Try to get a point where we say, but run down the walls if you
// fail (are already too close)
///////////////////////////////////////////////////////////////////////////////
function bool GetMovePointOrHugWalls(out vector destpoint, vector startpoint, float checkdist,
								bool bCheckActors)
{
	local vector HitLocation, HitNormal;
	local Actor HitActor;
	local vector dir, startdir, rightpoint, leftpoint;
	local float rightdist, leftdist, maindist;
	local bool bClearActor;
	
	HitActor = Trace(HitLocation, HitNormal, destpoint, startpoint, bCheckActors);

	// Check for walls behind me
	if(HitActor != None)
	// we've hit something like the world or another pawn
	{
		bClearActor=true;

		MovePointFromWall(HitLocation, HitNormal, Pawn);

		maindist = VSize(HitLocation - startpoint);

		checkdist-=maindist;

		if(checkdist > (DEFAULT_END_RADIUS + Pawn.CollisionRadius))
		{
/*
		// Move it away from the wall
		// If we're already too close to that wall, think about
		// running along it, one way or the other
		if(VSize(HitLocation - startpoint) <= (DEFAULT_END_RADIUS + Pawn.CollisionRadius))
		{
		*/
			// We're too close, so try along the sides
			// Setup new normal
			//log("TOO CLOSE, CHECK SIDES");
			startdir.x=HitNormal.x;
			startdir.y=HitNormal.y;
			startdir.z=0;
			startdir = Normal(startdir);
			// check 'right' side
			dir.x = startdir.y;
			dir.y = -startdir.x;

			rightpoint = HitLocation + (checkdist*dir);
			CheckMoveDest(rightpoint, HitLocation, rightdist, true);
			// check 'left' side
			dir.x = -startdir.y;
			dir.y = startdir.x;

			leftpoint = HitLocation + (checkdist*dir);
			CheckMoveDest(leftpoint, HitLocation, leftdist, true);

			//log("right dist "$rightdist);
			//log("left dist "$leftdist);

			// pick farthest one to run to
			if(rightdist > leftdist)
			{
				//log("picked right");
				destpoint = rightpoint;
			}
			else if(rightdist < leftdist)
			{
				//log("picked left");
				destpoint = leftpoint;
			}
			else // equal, then randomly pick one
			{
				if(FRand() <= 0.5)
					destpoint = leftpoint;
				else
					destpoint = rightpoint;
				//log("picked random");
			}
		}
		else
		{
			destpoint = HitLocation;
		}
	}

	// raise it up from the ground (to normal person height)
	RaisePointFromGround(destpoint, Pawn);

	return bClearActor;
}

///////////////////////////////////////////////////////////////////////////////
// The q said to move up
///////////////////////////////////////////////////////////////////////////////
function QPointSaysMoveUpInLine()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Uses LineOfSightTo and a general angle of view toward target
// usecone of 1.0 is seeing nothing, 0.0 sees 180 degrees, -1 sees everything
///////////////////////////////////////////////////////////////////////////////
function bool CanSeePawn(Pawn Looker, Pawn Other, optional float usecone)
{
	// If someone didn't specify a range, then use the pawn's default
	// Yucky, but if you wanted 0.0, then set something really close to that, instead.
	if(usecone == 0)
		usecone = FPSPawn(Looker).SeeViewCone;

	if((Normal(Other.Location - Looker.Location) Dot vector(Looker.Rotation)) > usecone
		&& Looker.Controller != None)
	{
		return Looker.Controller.LineOfSightTo(Other);
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Check if the point is in our view
// usecone of 1.0 is seeing nothing, 0.0 sees 180 degrees, -1 sees everything
///////////////////////////////////////////////////////////////////////////////
function bool CanSeePoint(Pawn Looker, vector CheckLoc, optional float usecone)
{
	// If someone didn't specify a range, then use the pawn's default
	// Yucky, but if you wanted 0.0, then set something really close to that, instead.
	if(usecone == 0)
		usecone = FPSPawn(Looker).SeeViewCone;

	// check if in view
	if((Normal(CheckLoc - Looker.Location) Dot vector(Looker.Rotation)) > usecone
		&& Looker.Controller != None
		// check if no obstructions
		&& FastTrace(Looker.Location, CheckLoc))
	{
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Assuming we're already looking at him, see if his weapon is within
// our view. If GunPointer is aiming closely enough at Other, then
// return true.
///////////////////////////////////////////////////////////////////////////////
function bool WeaponTurnedToUs(Pawn GunPointer, Pawn Other)
{
	local float dotcheck;

	if(GunPointer.Controller == None)
		return false;

	dotcheck = (Normal(Other.Location - GunPointer.Location) Dot vector(GunPointer.Rotation));
	//log("weapn turn dot check "$dotcheck);
	if(dotcheck > CAN_SEE_WEAPON_CONE)
	{
		return GunPointer.Controller.LineOfSightTo(Other);
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Assuming we're already looking at him, see if he's is pointing the gun
// very closely to directly at us
///////////////////////////////////////////////////////////////////////////////
function bool WeaponPointedDirectlyAtUs(Pawn GunPointer, Pawn Other)
{
	local float dotcheck;

	dotcheck = (Normal(Other.Location - GunPointer.Location) Dot vector(GunPointer.Rotation));
	if(dotcheck > CAN_GET_SHOT_CONE)
	{
		return true;//GunPointer.Controller.LineOfSightTo(Other);
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// This doesn't take occlusion into account, it's merely a distance
// check with respect to the weapon type. He needs to be closer
// to the gun pointer, to see a grenade, than he does to see he's
// got a pistol/rifle/launcher.
///////////////////////////////////////////////////////////////////////////////
function bool CloseEnoughToMakeOutDangerousWeapon(Pawn GunPointer, Pawn Other)
{
	if(P2Weapon(GunPointer.Weapon) != None)
	{
		return (VSize(Other.Location - GunPointer.Location) <= P2Weapon(GunPointer.Weapon).RecognitionDist);
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Uses LineOfSightTo and a general angle of view toward target
///////////////////////////////////////////////////////////////////////////////
function bool PawnsSeeEachOther(Pawn Looker, Pawn Other)
{
	// Looker is looking at Other
	if((Normal(Other.Location - Looker.Location) Dot vector(Looker.Rotation))
		> FPSPawn(Looker).SeeViewCone)
	{
		// Other is looking at Looker
		if((Normal(Looker.Location - Other.Location) Dot vector(Other.Rotation))
			> FPSPawn(Looker).SeeViewCone)
			return Looker.Controller.LineOfSightTo(Other);
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Called by the interest points to see if we're interested in doing this
///////////////////////////////////////////////////////////////////////////////
function PerformInterestAction(InterestPoint IPoint, out byte AllowFlow)
{
	AllowFlow=1;
}

///////////////////////////////////////////////////////////////////////////////
// Pick a point a distance away in an odd direction and stare
///////////////////////////////////////////////////////////////////////////////
function LookInRandomDirection()
{
	local vector checkpos;
	local Rotator userot;

	userot = Pawn.Rotation;
	userot.Yaw+=((FRand()*32768) - 16384);
	userot.Yaw = userot.Yaw & 65535;

	checkpos = 4096*vector(userot) + Pawn.Location;

	Focus = None;
	FocalPoint = checkpos;
}

///////////////////////////////////////////////////////////////////////////
// When attacked, just short circuit
///////////////////////////////////////////////////////////////////////////
function damageAttitudeTo(pawn Other, float Damage)
{
	PrintStateError("USING DEFAULT DAMAGE");
}

///////////////////////////////////////////////////////////////////////////////
// Don't send the message if it's by you, or less than or equal to zero (very important)
// Negative damage represents damage that you didn't take, but blocked by your
// natural 'Takes...Damage' values in P2Pawn.
///////////////////////////////////////////////////////////////////////////////
function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, 
					   class<DamageType> damageType, vector Momentum)
{
	if ( instigatedBy != pawn 
		&& Damage > 0)
		damageAttitudeTo(instigatedBy, Damage);
	// If damaged by flashbangs, ask the controller what to do
	if (ClassIsChildOf(Damagetype, class'FlashBangDamage'))
		BlindedByFlashBang(P2Pawn(InstigatedBy));
	ShortCircuit();
} 

///////////////////////////////////////////////////////////////////////////////
// Give a home tag to search for, go to the P2GameInfo and point our HomeList
// to somewhere in a list of looped home nodes. 
///////////////////////////////////////////////////////////////////////////////
function FindHomeList(name UseTag)
{
	local P2GameInfo checkg;

	checkg = P2GameInfo(Level.Game);
	if(checkg != None)
	{
		checkg.FindHomeListInfo(UseTag, HomeList);
		//log(Pawn$" new home list node is "$HomeList.node$" length "$HomeList.Length$" tag is "$HomeList.node.Tag$" my htag is "$FPSPawn(Pawn).HomeTag);
		// Start him at a random point in the list
		HomeList.node = HomeNode(FindRandomNode(HomeList.node, HomeList.Length, true));
	}
}

///////////////////////////////////////////////////////////////////////////////
// Link to the gameinfo list of pathnodes to be used for random pathnodes.
///////////////////////////////////////////////////////////////////////////////
function FindPathList()
{
	local P2GameInfo checkg;

	checkg = P2GameInfo(Level.Game);
	checkg.FindPathListInfo(PathList);
	//log(Pawn$" new path list node is "$PathList.node$" list length "$PathList.Length);
	// Start him at a random point in the list
	PathList.node = FindRandomNode(PathList.node, PathList.Length, true);
	//log(self$" FindPathList "$pathlist.node);
}

///////////////////////////////////////////////////////////////////////////////
// Might not be the end goal, but the actor hit what he was going for.
///////////////////////////////////////////////////////////////////////////////
event HitPathGoal(Actor Goal, vector Dest)
{
	//log("hit goal %%%%%%%%%%%"$Goal);
	if(EndGoal != None)
	{
		if(Goal == EndGoal)
		{
			MoveTarget=None;
			FPSPawn(Pawn).StopAcc();
		}
	}
	else
	{
		if(Dest == EndPoint)
		{
			bMovePointValid=false;
			FPSPawn(Pawn).StopAcc();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Decide what to do about this danger
///////////////////////////////////////////////////////////////////////////////
function GetReadyToReactToDanger(class<TimedMarker> dangerhere, 
								FPSPawn CreatorPawn, 
								Actor OriginActor,
								vector blipLoc,
								optional out byte StateChange)
{
	//PrintStateError("USING DEFAULT GETREADY");
	return;
}

///////////////////////////////////////////////////////////////////////////////
// Some danger occurred
///////////////////////////////////////////////////////////////////////////////
function MarkerIsHere(class<TimedMarker> bliphere,
					  FPSPawn CreatorPawn, 
					 Actor OriginActor,
					  vector blipLoc)
{
	if(bliphere == class'HeadExplodeMarker')
	{
		//WatchHeadExplode(bliphere.OriginPawn);
	}
	else if(ClassIsChildOf(bliphere, class'DeadBodyMarker'))
	{
		//CheckDeadBody(bliphere.OriginPawn);
	}
	else if(ClassIsChildOf(bliphere, class'DesiredThingMarker'))
	{
		//CheckDesiredThing(bliphere.OriginPawn);
	}
	else if(blipLoc != Pawn.Location)
	{
		GetReadyToReactToDanger(bliphere, CreatorPawn, OriginActor, blipLoc);
	}
}

///////////////////////////////////////////////////////////////////////////
// This function shouldn't be ignored (though it's counterpart below certainly
// may be). This registers with the pawn that 
///////////////////////////////////////////////////////////////////////////
function HitWithFluid(Fluid.FluidTypeEnum ftype, vector HitLocation)
{
}

///////////////////////////////////////////////////////////////////////////
// Piss is hitting me, decide what to do
// Used the cheesy bool bPuke so we wouldn't have another
// function to ignore in all the states
///////////////////////////////////////////////////////////////////////////
function BodyJuiceSquirtedOnMe(P2Pawn Other, bool bPuke)
{
}

///////////////////////////////////////////////////////////////////////////
// Something annoying, but not really gross or life threatening
// has been done to me, so check to maybe notice
///////////////////////////////////////////////////////////////////////////
function InterestIsAnnoyingUs(Actor Other, bool bMild)
{
}

///////////////////////////////////////////////////////////////////////////
// A bouncing, disembodied head (or dead body) just hit us, decide what to do
///////////////////////////////////////////////////////////////////////////
function GetHitByDeadThing(Actor BounceHead, FPSPawn KickerPawn)
{
}

///////////////////////////////////////////////////////////////////////////
// Hit by a dead body
///////////////////////////////////////////////////////////////////////////
function HitByDeadBody()
{
}

///////////////////////////////////////////////////////////////////////////
// Gas is hitting me, decide what to do
///////////////////////////////////////////////////////////////////////////
function GettingDousedInGas(P2Pawn Other)
{
}

///////////////////////////////////////////////////////////////////////////////
// You've just caught on fire.. how do you feel about it?
///////////////////////////////////////////////////////////////////////////////
function CatchOnFire(FPSPawn Doer, optional bool bIsNapalm)
{
}

///////////////////////////////////////////////////////////////////////////////
// You've just run into a cloud of deadly anthrax. You'll probably die
///////////////////////////////////////////////////////////////////////////////
function AnthraxPoisoning(P2Pawn Doer)
{
}

///////////////////////////////////////////////////////////////////////////////
// You've just be infected by some chemical plague. Not good.
///////////////////////////////////////////////////////////////////////////////
function ChemicalInfection(FPSPawn Doer)
{
}

///////////////////////////////////////////////////////////////////////////////
// You just got beat up Rodney King style
///////////////////////////////////////////////////////////////////////////////
function HitByBaton(P2Pawn Doer)
{
}

///////////////////////////////////////////////////////////////////////////////
// You just got kicked in the balls
///////////////////////////////////////////////////////////////////////////////
function TookNutShot(P2Pawn Doer)
{
}

///////////////////////////////////////////////////////////////////////////////
// You've been blinded by a flash grenade
///////////////////////////////////////////////////////////////////////////////
function BlindedByFlashBang(P2Pawn Doer)
{
}

///////////////////////////////////////////////////////////////////////////////
// Go into a state to say hi to people
// Requires focus set to the passerby
///////////////////////////////////////////////////////////////////////////////
function TryToGreetPasserby(FPSPawn Passerby, bool bIsGimp, bool bIsCop, optional out byte StateChange)
{
}

///////////////////////////////////////////////////////////////////////////////
// Make steam for peeing out fires
///////////////////////////////////////////////////////////////////////////////
function MakeShockerSteam(vector HitLocation, optional name PelvisBone, optional bool bPreserveOffset)
{
	if(MySteam == None
		|| MySteam.GetStateName() == 'FinishingUp'
		|| MySteam.bDeleteMe)
	{
		MySteam = spawn(class'ShockerSteamEmitter',Pawn,,Pawn.Location);
		if(bPreserveOffset)
			MySteam.SetBase(Pawn);
		else
			Pawn.AttachToBone(MySteam, PelvisBone);
	}

	MySteam.Refresh();

	if(bPreserveOffset)
		MySteam.SetRelativeLocation(HitLocation - Pawn.Location);
}

///////////////////////////////////////////////////////////////////////////////
// You're getting electricuted
///////////////////////////////////////////////////////////////////////////////
function GetShocked(P2Pawn Doer, vector HitLocation)
{
}

///////////////////////////////////////////////////////////////////////////////
// No headshot by the rifle, but you've been hurt by it.
///////////////////////////////////////////////////////////////////////////////
function WingedByRifle(P2Pawn Doer, vector HitLocation)
{
}

///////////////////////////////////////////////////////////////////////////////
// There was fire in our way, decide what to do
///////////////////////////////////////////////////////////////////////////////
function HandleFireInWay(FireEmitter ThisFire)
{
	/*
	local float disttofire;
	local byte DoRun;

	InterestActor = ThisFire;

	SetupWatchFire(DoRun);
	GotoState('');// clear out of walking, maybe
	SetNextState('WatchFireFromSafeRange', 'LookAtFire');
	if(DoRun==1)
		GotoStateSave('RunToFireSafeRange');
	else
		GotoStateSave('WalkToFireSafeRange');
	*/
}

///////////////////////////////////////////////////////////////////////////////
// Setup the person to check about donating money.. someone is talking
// to me about donating money, see if I care
///////////////////////////////////////////////////////////////////////////////
function DonateSetup(Pawn Talker, out byte StateChange)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Someone might have shouted get down, said hi, or asked for money.. see what to do
// Go to state to see if we care to get down after someone told us to
///////////////////////////////////////////////////////////////////////////////
function RespondToTalker(Pawn Talker, Pawn AttackingShouter, ETalk TalkType, out byte StateChange)
{
	//STUB PrintStateError(" default RespondToTalker called");
}

///////////////////////////////////////////////////////////////////////////////
// Go to state to see if we care to get down after someone told us to
///////////////////////////////////////////////////////////////////////////////
function ForceGetDown(Pawn Shouter, Pawn AttackingShouter)
{
	PrintStateError(" default ForceGetDown called");
}

///////////////////////////////////////////////////////////////////////////////
// This is the innards for the real versions of NoticePersonBeforeYouInLine
// which only get used in a few spots, but I didn't want to duplicate code
// to update.
///////////////////////////////////////////////////////////////////////////////
function CheckForLineCutter(P2Pawn Other, int YourNewSpot, optional out byte Cutter)
{
	/*
	if(InterestPawn != Other)
	{
		//log("my next pawn "$InterestPawn);
		//log("my new next pawn "$Other);
		//log("statecount "$statecount$" and my new spot "$YourNewSpot);

		if(Other != None
			&& (statecount < YourNewSpot
			|| InterestPawn != Other))
		{
			PrintDialogue("Hey, watch it buddy!");
			Say(MyPawn.myDialog.lWhatThe);
		}
		InterestPawn = Other;
	}
	*/
}

///////////////////////////////////////////////////////////////////////////////
// Look at the person in front of you, perhaps they're the wrong person
///////////////////////////////////////////////////////////////////////////////
function NoticePersonBeforeYouInLine(P2Pawn Other, int YourNewSpot)
{
	/*
	//PrintStateError();
	InterestPawn = Other;
	//InterestPawn2 = Other;
	statecount = YourNewSpot;
	//log(MyPawn$" my new spot "$statecount);
	*/
}

///////////////////////////////////////////////////////////////////////////////
// If the guy in front of us is still in line and 
// he's already moved again, then keep up with him.
///////////////////////////////////////////////////////////////////////////////
function bool CheckToMoveUpInLine()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// People are busy doing deals
///////////////////////////////////////////////////////////////////////////////
function bool ExchangingAtCashRegister()
{
	/*
	// I'm doing business or the person I'm heading too/talking to is a cashier
	if(IsInState('ExchangeGoodsAndServices')
//		|| 
//		(InterestPawn != None
//		&& CashierController(InterestPawn.Controller) != None)
		)
	{
		return true;
	}
*/
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Cashier's use this to handle customers
///////////////////////////////////////////////////////////////////////////////
function HandleThisPerson(P2Pawn CheckA)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Set who is last in line
///////////////////////////////////////////////////////////////////////////////
function SetLastInLine(Pawn LastOne)
{
}
/*
function PathNode GetRandomPathNode()
{
	local int count, picknum;
	local NavigationPoint Navpt;

	for ( Navpt=Level.NavigationPointList; Navpt!=None; Navpt=Navpt.NextNavigationPoint )
	{
		count++;
//		log(self$"nav point "$navpt);
	}
	picknum = FRand()*count;
//	log(self$"count is "$count$" pick num "$picknum);

	count=0;
	for ( Navpt=Level.NavigationPointList; Navpt!=None; Navpt=Navpt.NextNavigationPoint )
	{
		if(picknum == count)
			return PathNode(NavPt);
		count++;
	}
	return None;
}
*/

///////////////////////////////////////////////////////////////////////////////
// Look at our current hiding point and make sure it's still good
///////////////////////////////////////////////////////////////////////////////
function bool CheckForValidSafePoint(bool bStartUp)
{
	// STUB -- in person controller
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Say something and also possibly gesture
///////////////////////////////////////////////////////////////////////////////
function TalkSome(out P2Dialog.SLine line, optional P2Pawn Speaker, 
						optional bool bIsGreeting,
						optional bool bIsGiving,
						optional bool bIsTaking)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////
// Use the simple group of pathnodes gathered up the gameinfo to determine
// a random point to walk to. The problem is we then have to test it
// and handle not having it return a good path node every time--different
// but more random than the engine.FindRandomDest.
///////////////////////////////////////////////////////////////////////////
function PathNode FindRandomPathNodeDest()
{
	local PathNode usenode;

	//log(self$" FindRandomPathNodeDest "$pathlist.node);
	if(PathList.node != None)
	{
		usenode = FindRandomNode(PathList.node, PathList.Length);
		//log(self$" try usenode "$usenode);
		if(FindPathToward(usenode) != None)
		{
			return usenode;
		}
	}
	return None;
}

///////////////////////////////////////////////////////////////////////////
// Pick a random spot not through a wall
///////////////////////////////////////////////////////////////////////////
function bool PickRandomDest(optional float UseDestRad)
{
	local NavigationPoint nextpnode;
	local HomeNode hnode;

	if(HomeList.node != None)
	{
		hnode = HomeNode(FindRandomNode(HomeList.node, HomeList.Length));
		nextpnode = hnode;
		// Move our saved home node along to the new one so when we pick from
		// the random one's next time, we'll pick from a different area. The loop automatically wraps for us
		// and the length remains the same
		// It's safe to move from the 'start' of the list also, because P2GameInfo keeps this for us
		// in a list.
		HomeList.node = hnode;
		//log(Pawn$" home node list "$HomeList.node$" hnode "$hnode);
	}
	else
	{
		nextpnode = FindRandomPathNodeDest();
		if(nextpnode == None)
			nextpnode = FindRandomDest();
	}

	// Never pick door node points to walk to 
	// and don't use homenodes if you're not supposed to.
	hnode = HomeNode(nextpnode);
	//log(Pawn$" home node picked "$hnode$" tag "$nextpnode.Tag$" my htag "$FPSPawn(Pawn).HomeTag$" can enter "$FPSPawn(Pawn).bCanEnterHomes);

	if(nextpnode == None
		// if is an autodoor
		|| AutoDoor(nextpnode) != None
		// or if is a home node and you can't enter homes OR not you're home and you have specified home
		|| (hnode != None
			&& (!FPSPawn(Pawn).bCanEnterHomes
				|| (FPSPawn(Pawn).HomeTag != 'None' 
					&& hnode.Tag != FPSPawn(Pawn).HomeTag)))
		// or if is not a home node and you're only supposed to enter homes
		|| (hnode == None
			&& FPSPawn(Pawn).bCanEnterHomes))
	{
		//log(Pawn$" trying again ");
		return false;
	}
	else
	{
		if(UseDestRad == 0)
			UseDestRad = DEFAULT_END_RADIUS;
		//log(Pawn$" picked "$nextpnode);
		SetEndGoal(nextpnode, UseDestRad);
	}

	return true;
}

///////////////////////////////////////////////////////////////////////////
// This is to set a few special people types, with attributes that are specific
// to the controller, not the person. So the controller can hand set a few
// pawn attributes, that way different people can be effected by the same controller
///////////////////////////////////////////////////////////////////////////
function ForceInitPawnAttributes()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////
// A protestor in a group has been disrupted, so do something about it.
///////////////////////////////////////////////////////////////////////////
function ProtestingDisrupted(FPSPawn NewAttacker, FPSPawn NewInterestPawn, optional bool bKnowAttacker)
{
	// STUB--leave as stub.. only defined for protesting/marching people in BystanderController
}

///////////////////////////////////////////////////////////////////////////////
// Link up the info 
///////////////////////////////////////////////////////////////////////////////
function LinkToProtestInfo(ProtestorInfo newinfo)
{
	MyProtestInfo = newinfo;
}

///////////////////////////////////////////////////////////////////////////////
// Leg motion exit function
///////////////////////////////////////////////////////////////////////////////
function DoLeaveState()
{
}

///////////////////////////////////////////////////////////////////////////////
// Increase the goal of this 'used' pathnode so we try to keep people from using
// it. They'll then use other paths more and look more natural. Eventually the
// cost on the is path will wrap so it will be low cost again
///////////////////////////////////////////////////////////////////////////////
function UpGoalCost(PathNode hitgoal)
{
	if(hitgoal != None
		&& !hitgoal.bNoRandomCost)
	{
		hitgoal.ExtraCost += (Rand(GOAL_COST_ADD) + GOAL_COST_BASE);
		// wrap cost
		if(hitgoal.ExtraCost >= (hitgoal.default.ExtraCost + GOAL_COST_MAX))
		{
			hitgoal.ExtraCost = hitgoal.default.ExtraCost;
		}
		//log(Pawn$" 1new extra cost for "$hitgoal$" is "$hitgoal.ExtraCost$" normal cost is "$hitgoal.cost);
	}
}

///////////////////////////////////////////////////////////////////////////////
// If true, then PostLoad game will call ChangeAnimation (animals usually
// only use this) to get their anims going again after a load
///////////////////////////////////////////////////////////////////////////////
function bool ChangeAnimationOnLoad()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// initialize physics by falling to the ground
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state InitFall
{
	ignores MarkerIsHere, damageAttitudeTo;

	///////////////////////////////////////////////////////////////////////////////
	// If true, then PostLoad game will call ChangeAnimation (animals usually
	// only use this) to get their anims going again after a load
	///////////////////////////////////////////////////////////////////////////////
	function bool ChangeAnimationOnLoad()
	{
		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Decide what to start doing
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		ForceInitPawnAttributes();

		FPSPawn(Pawn).PrepInitialState();

		if(MyNextState != 'None'
			&& MyNextState != '')
		{
			GotoStateSave(MyNextState);
			SetNextState('Thinking');
		}
		else
			GotoStateSave('Thinking');
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Wait till we've landed to take off running
	///////////////////////////////////////////////////////////////////////////////
	function bool NotifyLanded(vector HitNormal)
	{
		Pawn.ChangeAnimation();
		GotoState(GetStateName(), 'End');
		return true;
	}

Begin:
	PrintThisState();
	Pawn.ChangeAnimation();
	OldMoveTarget = FindRandomDest();
	//log("old move target "$OldMoveTarget);
	Sleep(0.1);
	Goto('Begin'); // repeat state
End:
	DecideNextState();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Handles stasis change for me.
// If we switch this state to something else, it automatically switches out
// of stasis
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state StasisState
{
	ignores GoIntoStasis;

	function EndState()
	{
		local FPSGameInfo checkg;

		// Bring it all back out
		bStasis = false;
		if(FPSPawn(Pawn) != None)
		{
			// Also put the head in stasis of the pawn
			FPSPawn(Pawn).PrepAfterStasis();

			if(P2GameInfo(Level.Game).LogStasis == 1)
				log(Pawn$": turning controller "$self$" back on and going to state "$MyOldState$" dont renew is ");

			checkg = FPSGameInfo(Level.Game);
			checkg.PawnOutOfStasis(Pawn);
		}

		// Since we're leaving stasis, don't allow anyone to send us back here,
		// in a reflexive 'gotostate oldstate' call. Make sure our oldstate is not this
		// and something valid
		MyOldState='Thinking';
	}

	function BeginState()
	{
		local FPSGameInfo checkg;

		PrintThisState();

		// Also put the head in stasis of the pawn
		FPSPawn(Pawn).PrepBeforeStasis();
		// Put the *controller* in stasis.. the pawn will handle coming out of stasis for us
		bStasis = true;

		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		FPSPawn(Pawn).StopAcc();
		if(P2GameInfo(Level.Game).LogStasis == 1)
			log(Pawn$": turning off controller "$self$" and saving state "$MyOldState);

		checkg = FPSGameInfo(Level.Game);
		checkg.PawnInStasis(Pawn);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Handles stasis change for me.
// If we switch this state to something else, it automatically switches out
// of stasis
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state SliderStasis extends StasisState
{
	ignores Trigger;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Decide what to do next
// Fill out in bystander, police, etc.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Thinking
{
	///////////////////////////////////////////////////////////////////////////
	// Default stasis changes here
	///////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
	}

Begin:
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Just before getting destroyed, the beginstate here is executed, and the
// Endstate in the previous function is executed for a clean up.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Destroying
{
	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		// Stop all sounds you're making
		if(Pawn != None)
			Pawn.PlaySound(TermSound, SLOT_Talk, 0.01);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// When protesting around in a loop
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Protesting
{
	ignores RespondToTalker, TryToGreetPasserby;

	///////////////////////////////////////////////////////////////////////////////
	// If true, then PostLoad game will call ChangeAnimation (animals usually
	// only use this) to get their anims going again after a load
	///////////////////////////////////////////////////////////////////////////////
	function bool ChangeAnimationOnLoad()
	{
		return true;
	}

	function BeginState()
	{
		PrintThisState();
	}
Begin:
	//log("current loop point and target "$FPSPawn(Pawn).MyLoopPoint$" next one is "$FPSPawn(Pawn).MyLoopPoint.NextPoint);
	bStraightPath=true;
	SetNextState('ProtestToTarget');
	SetEndGoal(FPSPawn(Pawn).MyLoopPoint, PROTEST_END_RADIUS);
	GotoStateSave('ProtestToTarget');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// When marching around in a loop
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state BeginMarching extends Protesting
{
Begin:
	log("current loop point and target "$FPSPawn(Pawn).MyLoopPoint$" next one is "$FPSPawn(Pawn).MyLoopPoint.NextPoint);
	bStraightPath=true;
	SetNextState('MarchToTarget');
	SetEndGoal(FPSPawn(Pawn).MyLoopPoint, PROTEST_END_RADIUS);
	GotoStateSave('MarchToTarget');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Decide what to do when attacked
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ReactToAttack
{
	///////////////////////////////////////////////////////////////////////////////
	//	Set up the targets
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// OnePassMove
//
// Only send here if you're already in a walking/running state!
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state OnePassMove
{
	ignores PerformInterestAction, TryToGreetPasserby, TryToSendAway;

	///////////////////////////////////////////////////////////////////////////////
	// Decide what to do if you bump a static mesh
	///////////////////////////////////////////////////////////////////////////////
	function BumpStaticMesh(Actor Other)
	{
		CheckBumpStaticMesh(Other);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Move to the left or right, if we notice we're hung up, when we should be 
	// moving
	///////////////////////////////////////////////////////////////////////////////
	function DodgeThinWall()
	{
		// If we're stopped or in the same spot.
		if(VSize(Pawn.Velocity) < MIN_VELOCITY_FOR_REAL_MOVEMENT)
		{
			// Never allow a hang up--always exit on first hang up
			DoLeaveState();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Go to next state
	///////////////////////////////////////////////////////////////////////////////
	function DoLeaveState()
	{
		SetRotation(Pawn.Rotation);
		GotoState(MyOldState);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Might not be the end goal, but the actor hit what he was going for.
	///////////////////////////////////////////////////////////////////////////////
	event HitPathGoal(Actor Goal, vector Dest)
	{
		DoLeaveState();
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Set up the targets
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		//log(Pawn$" my pos "$Pawn.Location$" go to here "$MovePoint);
		LastBumpStaticMesh = None;

		// We hope MyNextState was set to something useful, before we start
		SetRotation(Pawn.Rotation);
		LegMotionCaughtCount=0;
		// Do more internal checks when moving like this
		FPSPawn(Pawn).PathCheckTimePoint = 1.0;
		// Stand up
		Pawn.ShouldCrouch(false);
	}

	function EndState()
	{
		bDontSetFocus=false;
		Super.EndState();
		FPSPawn(Pawn).PathCheckTimePoint = FPSPawn(Pawn).default.PathCheckTimePoint;
	}

Begin:
	if(Pawn.Physics == PHYS_FALLING)
		WaitForLanding();
	else
	{
		if(MoveTarget != None)
			MoveTowardWithRadius(MoveTarget,Focus,TIGHT_END_RADIUS,,,,Pawn.bIsWalking);
		else
			MoveToWithRadius(MovePoint,Focus,TIGHT_END_RADIUS,,Pawn.bIsWalking);
		DodgeThinWall();
		Sleep(0.0);
	}
	Goto('Begin');// run this state again
//	}

//	DoLeaveState();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// LegMotionToTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state LegMotionToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// If true, then PostLoad game will call ChangeAnimation (animals usually
	// only use this) to get their anims going again after a load
	///////////////////////////////////////////////////////////////////////////////
	function bool ChangeAnimationOnLoad()
	{
		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Decide what to do if you bump a static mesh
	///////////////////////////////////////////////////////////////////////////////
	function BumpStaticMesh(Actor Other)
	{
		CheckBumpStaticMesh(Other);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Move to the left or right, if we notice we're hung up, when we should be 
	// moving
	///////////////////////////////////////////////////////////////////////////////
	function DodgeThinWall()
	{
		local vector startdir, usevect;

		//log("pos "$Pawn.Location);
		//log("vel "$Pawn.Velocity);
		//log("acc "$Pawn.Acceleration);

		// If we're stopped or in the same spot.
		if(VSize(Pawn.Velocity) < MIN_VELOCITY_FOR_REAL_MOVEMENT)
			//|| Pawn.Location == MyOldPos)
		{
			LegMotionCaughtCount++;
			if(LegMotionCaughtCount > LegMotionCaughtMax)
			{
				//log(Pawn$" resetting after bump DodgeThinWall, endgoal was "$EndGoal$" current "$MoveTarget$" move point "$MovePoint$" end point "$EndPoint);
				NextStateAfterHangUp();
			}
			else
			{
				//log("bumping him------------------===========+++++++++++++++++++++++++++++++++++++++++++++++");
				FPSPawn(Pawn).StopAcc();
				// Reset his path finding, this might find a better way there
				// or see that he was hitting things on his way there
				if(EndGoal != None)
					SetActorTarget(EndGoal, true);
				else
					SetActorTargetPoint(EndPoint, true);

				startdir = vector(Pawn.Rotation);
				// pick left
				if(FRand() <= 0.5)
				{
					//log("picking left");
					usevect.x = -startdir.y;
					usevect.y = startdir.x;
				}
				else // pick right
				{
					//log("picking right");
					usevect.x = startdir.y;
					usevect.y = -startdir.x;
				}
				usevect.z = startdir.z;

				// Add in some velocity in this new direction
				Pawn.Velocity+=((Pawn.GroundSpeed*0.5)*usevect);
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after you got hung up on something
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterHangUp()
	{
		// Default to just going to the next state
		NextStateAfterGoal();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after this
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterGoal()
	{
		FPSPawn(Pawn).StopAcc();
		//log(Pawn$" NextStateAfterGoal goal was "$MoveTarget$" move point "$MovePoint);
		GotoState(MyNextState, MyNextLabel);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Might not be the end goal, but the actor hit what he was going for.
	///////////////////////////////////////////////////////////////////////////////
	event HitPathGoal(Actor Goal, vector Dest)
	{
		local bool bfinaltarget;
		local Vector zerovec;
		
		SetRotation(Pawn.Rotation);

		UpGoalCost(PathNode(Goal));

		//log(Pawn$" hit goal %%%%%%%%%%%"$Goal$" end goal "$EndGoal$" my dest "$dest$" endpoint "$endpoint);
		/*
		if(ApproxGoal == Goal
			&& ApproxGoal != None)
		{
			log(Pawn$" HITTTTTTTTTTTTTTTING APPROX ");
		}
		*/
		if(EndGoal != None)
		{
			if((Goal == EndGoal 
					|| Goal == ApproxGoal)
				&& !bMovePointValid)
			{
				//log("found my legtarget target ----------");
				ClearGoals();
				EndGoal=None;
				bfinaltarget = true;
				//log("legtotarget to mynextstate "$MyNextState);
			}
			else
				SetActorTarget(EndGoal);
		}
		else
		{
			if((Dest == EndPoint
					|| Goal == ApproxGoal)
				&& bMovePointValid)
			{
				//log("found my legtarget point ----------");
				ClearGoals();
				bfinaltarget = true;
				//log("legtotarget to mynextstate "$MyNextState);
			}
			else if (EndPoint != zerovec)
				SetActorTargetPoint(EndPoint);
			else
				// Short-circuit. Goal is missing.
				NextStateAfterGoal();
		}

		if(bfinaltarget)
		{
			NextStateAfterGoal();
		}
		else
			IntermediateGoalReached();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		DodgeThinWall();
		CheckForObstacles();
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Stop us when we land
	///////////////////////////////////////////////////////////////////////////////
	function bool NotifyLanded(vector HitNormal)
	{
		FPSPawn(Pawn).StopAcc();
		Pawn.ChangeAnimation();
		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Make sure we stand up first
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		Pawn.ShouldCrouch(false);
		LastBumpStaticMesh=None;
	}

	///////////////////////////////////////////////////////////////////////////////
	//	Make sure you're not focussing on the direction anymore (it must
	// be explictly set at all times, and defaults to false)
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		ApproxGoal=None;
		LegMotionCaughtCount=0;
		LegMotionCaughtMax=0;	// Always reset the max which forces given states
								// to set it, if they want it
		bDontSetFocus=false;
		if(!bPreserveMotionValues)
		{
			bStraightPath=false;
			SetNextState('');
		}
		else
			bPreserveMotionValues=false;
	}

Begin:
	if(Pawn.Physics == PHYS_FALLING)
		WaitForLanding();
	else
	{
		//log("use end radius "$UseEndRadius);
		if(MoveTarget != None)
			MoveTowardWithRadius(MoveTarget,Focus,UseEndRadius);
		else //if(bMovePointValid)
			MoveToWithRadius(MovePoint,Focus,UseEndRadius);
		InterimChecks();
		Sleep(0.0);
	}
	Goto('Begin');// run this state again
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// If the Term(inate) sound is the same as the sound he's currently playing, then 
// the trick we use to play it at 0 volume to get it to stop won't work--it will
// continue to play loud. So we pick a sound we know he won't be playing.
defaultproperties
{
	MyOldState='Thinking'
	TermSound = Sound'WeaponSounds.Match_Light'
}
