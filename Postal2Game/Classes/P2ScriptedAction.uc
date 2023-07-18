///////////////////////////////////////////////////////////////////////////////
// P2ScriptedAction.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Adds some useful things to a basic ScriptedAction.
//
//	History:
//		05/14/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class P2ScriptedAction extends ScriptedAction
	abstract;


///////////////////////////////////////////////////////////////////////////////
// Get player controller's pawn (assumes single-player game)
///////////////////////////////////////////////////////////////////////////////
function P2Pawn GetPlayerPawn(ScriptedController C)
	{
	local P2Player player;

	player = GetPlayer(C);
	if (player != None)
		return player.MyPawn;
	return None;
	}

///////////////////////////////////////////////////////////////////////////////
// Get player controller (assumes single-player game)
///////////////////////////////////////////////////////////////////////////////
function P2Player GetPlayer(ScriptedController C)
	{
	local Controller iter;
	local P2Player player;

	For (iter = C.Level.ControllerList; iter != None; iter = iter.nextController)
		{
		player = P2Player(iter);
		if (player != None)
			break;
		}
	return player;
	}


///////////////////////////////////////////////////////////////////////////////
// DefaultProperties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}