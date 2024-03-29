///////////////////////////////////////////////////////////////////////////////
// TriggerApocalypse.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Starts the Apocalypse. Duh. Actually the single game info does it...
// Sets everyone into riot mode and dude must make it home to his house
// at end of game. And makes new Apocalypse newspaper come up to explain it.
//
///////////////////////////////////////////////////////////////////////////////
class TriggerApocalypse extends Trigger;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Called when something touches us
///////////////////////////////////////////////////////////////////////////////
function Touch( actor Other )
	{
	local P2Player p2p;
	local P2HUD hud;

	if (IsRelevant(Other))
		{
			if(P2GameInfoSingle(Level.Game) != None)
			{
				P2GameInfoSingle(Level.Game).StartApocalypse();
			}
			// Set gamestate to Apocalypse is on.
			// Grant dude new Apocalypse newspaper and make him view it.
		}
	Super.Touch(Other);
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	Texture=Texture'PostEd.Icons_256.TriggerApocalypse'
	DrawScale=0.25
	}
