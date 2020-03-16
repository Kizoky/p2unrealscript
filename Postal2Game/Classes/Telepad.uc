///////////////////////////////////////////////////////////////////////////////
// Telepad.
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Enhanced version of teleporter that brings along nearby actors and also
// allows you to specify an offset from the teleporter at the destination.
//
//	History:
//		07/09/02 MJR	Lots of changes to clean up how it all works.
//
///////////////////////////////////////////////////////////////////////////////
//
// When linking to another level use this format for the URL:
//
//		NextLevelName#TelepadInThereTag1?peer
//
///////////////////////////////////////////////////////////////////////////////
class Telepad extends Teleporter;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var(Teleporter) name TelemarketerTag;	// Tag of the telemarketer associated with me
var(Teleporter) float TravelRadius;		// All pawns within this radius will travel with the player
var(Teleporter) name LinkpadTag;		// Linkpad I connect to. 
var(Teleporter) bool bRealLevelExit;	// Teleporter for a true level exit (things that link
										// to building interiors would have this false)

var Telemarketer TMarker;				// Telemarketer associated with me
var Linkpad	MyLinkpad;					// Linkpad actor I link to.


///////////////////////////////////////////////////////////////////////////////
// Link to the proper telemarketer
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
	{
	Super.PostBeginPlay();
	
	if ( TelemarketerTag != '' )
		{
		ForEach AllActors(class'Telemarketer', TMarker, TelemarketerTag )
			break;
		}
	if ( LinkpadTag != '' )
		{
		ForEach AllActors(class'Linkpad', MyLinkpad, LinkpadTag )
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Trigger switch when hit
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, pawn EventInstigator )
	{
	local Actor A;

	bEnabled = !bEnabled;
	if ( bEnabled ) //teleport any pawns already in my radius
		ForEach TouchingActors(class'Actor', A)
		Touch(A);
	}

///////////////////////////////////////////////////////////////////////////////
// Teleporter was touched by an actor.
///////////////////////////////////////////////////////////////////////////////
simulated function Touch( actor Other )
	{
	local P2Pawn PlayerPawn;

	if (bEnabled)
		{
		// Wake up
		bStasis=false;

		if(Other.bCanTeleport && (Other.PreTeleport(Self) == false))
			{
			// Make sure URL refers to another level (we don't support same-level telepads)
			if((InStr(URL, "/") >= 0) || (InStr(URL, "#") >= 0))
				{
				PlayerPawn = P2Pawn(Other);
				// Make sure you only send the player, and only send him once!
				if(Role == ROLE_Authority
					&& PlayerPawn != None 
					&& PlayerPawn.IsHumanControlled()
					&& P2GameInfoSingle(Level.Game).TheGameState != None)
					{
					// Only send pawns to next level with player if he's not being diverted home
					if(!P2GameInfoSingle(Level.Game).WillPlayerBeDivertedHome(URL, bRealLevelExit))
					{
						// Send along any nearby pawns
						SaveNearbyPawns(PlayerPawn, TravelRadius, PlayerPawn.Location);
						SaveAnimalFriends(PlayerPawn);
					}

					// Go through your links to linkpads and make them all send their contents.
					if(MyLinkpad != None)
						MyLinkpad.SaveNearbyPawns(PlayerPawn, MyLinkpad.CollisionRadius, MyLinkpad.Location);

					// Send player to next level (or he may be diverted home)
					P2GameInfoSingle(Level.Game).SendPlayerLevelTransition(PlayerController(PlayerPawn.Controller), 
																			URL, 
																			bRealLevelExit);
					}
				}
			}
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Save any nearby pawns so they'll travel with the player to the next level.
///////////////////////////////////////////////////////////////////////////////
function SaveNearbyPawns(P2Pawn PlayerPawn, float UseRadius, vector UseLoc)
{
	local FPSPawn NearbyPawn;

	// Find pawns within specified radius of the player and save essential
	// information so they can be respawned at the other side.
	ForEach CollidingActors(class'FPSPawn', NearbyPawn,	UseRadius, UseLoc)
	{
		// if they're not the player, if they can teleport (e.g., Gary can't), and if they
		// are alive, then transport them.
		if(NearbyPawn != PlayerPawn 
			&& NearbyPawn.bCanTeleportWithPlayer
			&& NearbyPawn.Health > 0)
		{
			P2GameInfoSingle(Level.Game).TheGameState.SavePawnForTeleport(NearbyPawn, PlayerPawn);
			// For each pawn that is allowed to travel and is persistent, mark him as
			// dead, so the persistence code in GameState will save him as 'gone' from the
			// level. That way, if you take a persistent pawn through, but kill him on the other
			// side, the original pawn in the original level will still think the correct pawn
			// is gone or dead, when you return to that level.
			if(NearbyPawn.bPersistent)
				NearbyPawn.Health = 0;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Manually transfer our animal friends
// Only transport our animal friends, if they don't currently hate us (we could
// be in the process of making a mean dog slowly like us, in which case, he
// could still hate us, so don't bring that kind)
///////////////////////////////////////////////////////////////////////////////
function SaveAnimalFriends(P2Pawn PlayerPawn)
{
	local AnimalPawn apawn;
	local int i;
	local P2Player p2p;

	log(self$"sending animal friends ");
	p2p = P2Player(PlayerPawn.Controller);
	if(p2p != None)
	{
		for(i=0; i<p2p.AnimalFriends.Length; i++)
		{
			apawn = p2p.AnimalFriends[i];
			log(self$" checking to send animal friend "$apawn);
			if(apawn != None
				&& apawn.Health > 0
				&& AnimalController(apawn.Controller) != None
				&& AnimalController(apawn.Controller).Attacker != PlayerPawn)
			{
				log(self$" sending animal friend "$apawn);
				P2GameInfoSingle(Level.Game).TheGameState.SavePawnForTeleport(apawn, 
							PlayerPawn);
			}
		}
	}
}

/*
///////////////////////////////////////////////////////////////////////////////
// Draw radius
///////////////////////////////////////////////////////////////////////////////
simulated event RenderOverlays( canvas Canvas )
	{
	local color tempcolor;
	
	if(SHOW_LINES==1)
		{
		// show collision radius
		tempcolor.R=255;
		Canvas.DrawColor = tempcolor;
		Canvas.Draw3Circle(Location, CollisionRadius, 0);
		}
	}
*/

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	CollisionRadius=40.000000
	CollisionHeight=80.000000
	TravelRadius=400
	bStatic=false	// this allows the telepad to be triggered
	bRealLevelExit=true
	bStasis=true
	Texture=Texture'PostEd.Icons_256.Telepad'
	DrawScale=0.125
	}
