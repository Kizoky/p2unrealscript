///////////////////////////////////////////////////////////////////////////////
// TriggeredHint.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Put helpful hints in the game for the player.
//
// History:
//	10/11/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class TriggeredHint extends Trigger;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var(Trigger) localized String		HintText;
var(Trigger) float					HintLifetime;
var(Trigger) Sound					HintSound;


///////////////////////////////////////////////////////////////////////////////
// Called when something touches us
///////////////////////////////////////////////////////////////////////////////
function Touch( actor Other )
	{
	local P2Player p2p;
	local P2HUD hud;

	if (IsRelevant(Other))
		{
		if (HintText != "" 
			&& Other.Instigator != None
			&& P2GameInfo(Level.Game).AllowGameplayHints())
			{
			//Other.Instigator.ClientMessage(HintText);
			if(P2Player(Pawn(Other).Controller) != None)
				P2Player(Pawn(Other).Controller).SendHintText(HintText, HintLifetime);
			}

		if (HintSound != None)
			Other.Instigator.PlayOwnedSound(HintSound);
		}
	Super.Touch(Other);
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	HintLifetime=5.0
	Texture=Texture'PostEd.Icons_256.TriggeredHint'
	DrawScale=0.25
	}
