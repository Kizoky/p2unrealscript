///////////////////////////////////////////////////////////////////////////////
// ACTION_Notify.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This action lets you call functions below that are linked to the
// enums you pass this action. 
//
//	History:
//		07/13/02 NPF	Started.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_Notify extends P2ScriptedAction;

enum ENotifyType
	{
	ENT_ArrestPlayerInJail,			// The player has hit a trigger which we want to call a function
									// that makes all cops that see him want to arrest him. Because he's
									// either escaped jail or illegally back around the cells.
	ENT_DontArrestPlayerInJail,		// It's okay again if the player walks around in this area of the jail.
									// So set the variable back.
	};

var(Action) ENotifyType NotifyType;	// Command

function bool InitActionFor(ScriptedController C)
	{
	switch(NotifyType)
	{
		case ENT_ArrestPlayerInJail:
				P2GameInfoSingle(C.Level.Game).TheGameState.bArrestPlayerInJail=true;
			break;
		case ENT_DontArrestPlayerInJail:
				P2GameInfoSingle(C.Level.Game).TheGameState.bArrestPlayerInJail=false;
			break;
		default:
			break;
	}
	return false;
	}

function string GetActionString()
	{
	return ActionString;
	}

defaultproperties
	{
	ActionString="action notify"
	bRequiresValidGameInfo=true
	}
