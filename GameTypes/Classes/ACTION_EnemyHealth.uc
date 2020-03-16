///////////////////////////////////////////////////////////////////////////////
// ACTION_EnemyHealth.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Find the first instance of EnemyTag in the level and tell the player.
// Then with the HudPawnIcon picture of that enemy, we'll show the health of
// him as the player fights him. Good for boss fights.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_EnemyHealth extends P2ScriptedAction;

var(Action) name	EnemyTag;			// Enemy we want the health of
var(Action) Texture HudPawnIcon;		// Picture of that enemy
var(Action) bool	bPercentageDisplay;	// If true, displays as a % instead of (number)/(max)
var(Action) bool	bHealthBar;			// If true draws a health bar instead of the blood splat (forces percentage display = true)
var(Action) string	HealthBarText;		// Text to overlay on health bar

function bool InitActionFor(ScriptedController C)
	{
	if(AWPlayer(GetPlayer(C)) != None)
		AWPlayer(GetPlayer(C)).StartKillBoss(HudPawnIcon, EnemyTag, bPercentageDisplay, bHealthBar, HealthBarText);
	else
		warn(" Tried to start action without AWPlayer");

	return false;
	}

function string GetActionString()
	{
	return ActionString$", hud icon "$HudPawnIcon$" trigger tag "$EnemyTag;
	}

defaultproperties
{
     ActionString="action enemy health"
     bRequiresValidGameInfo=True
}
