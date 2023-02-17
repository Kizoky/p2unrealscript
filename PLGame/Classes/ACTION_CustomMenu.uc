///////////////////////////////////////////////////////////////////////////////
// ACTION_CustomMenu
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Scripted action that pops up a custom menu.
// Each menu option can be linked to an event that goes off when that option
// is selected.
//
// This was originally made for the karaoke errand (thus the references to
// songs and shit) but works for any situation where the player needs to
// make a choice on a menu.
///////////////////////////////////////////////////////////////////////////////
class ACTION_CustomMenu extends P2ScriptedAction;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, structs, etc
///////////////////////////////////////////////////////////////////////////////
var() editinline array<P2EInteraction.ButtonInfo> Buttons;	// ButtonInfoes for song selections. Length of this array must match ButtonEvents and ButtonConditions.
var() array<Name> ButtonEvents;								// Event that each selection should fire off when chosen.
var() array<Name> ButtonConditions;							// If defined, points to the Tag of a TriggeredCondition. If that condition is true, the corresponding menu option is disabled and cannot be clicked on.
var() editinline P2EInteraction.ButtonInfo CancelButton;	// ButtonInfo for cancel selection
var() array<String> DisableSound;							// Sound(s) played when the player tries to pick a disabled selection.
var() Font DisplayFont;										// Font to use for text
var() Texture ButtonTexture;								// Texture to use for buttons

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool InitActionFor(ScriptedController C)
{	
	local P2Player P;
	local KaraokeMenu Menu;
	local int i;
	local TriggeredCondition T;
	
	P = GetPlayer(C);
	Menu = KaraokeMenu(P.Player.InteractionMaster.AddInteraction("PLGame.KaraokeMenu", P.Player));
	if (Menu != None)
	{
		// These should all be the same length.
		Menu.Buttons.Length = Buttons.Length + 1;
		Menu.SongInfos.Length = ButtonEvents.Length;
		for (i = 0; i < Buttons.Length; i++)
		{
			Menu.Buttons[i] = Buttons[i];
			Menu.SongInfos[i].EventName = ButtonEvents[i];
			// Find triggered condition for this song and see if it's been played yet
			if (i < ButtonConditions.Length)
			{
				foreach C.DynamicActors(class'TriggeredCondition', T, ButtonConditions[i])
				{
					Menu.SongInfos[i].SongDisabled = T.bEnabled;
					break;
				}
			}
		}
		// Add cancel button
		Menu.Buttons[i] = CancelButton;
		// Set up disable sounds if any.
		if (DisableSound.Length > 0)
		{
			Menu.DisabledSound.Length = DisableSound.Length;
			for (i = 0; i < DisableSound.Length; i++)
				Menu.DisabledSound[i] = DisableSound[i];
		}
	}
	else
		warn(self@"Failed to initialize karaoke menu!");
	
	return false;
}

defaultproperties
{
	ActionString="karaoke menu"

    Buttons(0)=(Pos=(X=0.025f,Y=0.025),Scale=(X=2.2f,Y=1.0f),TextOffset=(X=0.025f,Y=0.0175f),TextScale=(X=0.75f,Y=0.75f),Text="Menu Option 1")
    Buttons(1)=(Pos=(X=0.225f,Y=0.125),Scale=(X=2.2f,Y=1.0f),TextOffset=(X=0.025f,Y=0.0175f),TextScale=(X=0.75f,Y=0.75f),Text="Menu Option 2")
    Buttons(2)=(Pos=(X=0.125f,Y=0.225),Scale=(X=2.4f,Y=1.0f),TextOffset=(X=0.025f,Y=0.0175f),TextScale=(X=0.75f,Y=0.75f),Text="Menu Option 3")
    Buttons(3)=(Pos=(X=0.075f,Y=0.325),Scale=(X=1.75f,Y=1.0f),TextOffset=(X=0.025f,Y=0.0175f),TextScale=(X=0.75f,Y=0.75f),Text="Menu Option 4")
    CancelButton=(Pos=(X=0.5f,Y=0.9f),Scale=(X=1.8f,Y=1.0f),TextOffset=(X=0.035f,Y=0.0175f),TextScale=(X=0.75f,Y=0.75f),Text="Cancel Button")
	
	ButtonEvents[0]="Song1"
	ButtonEvents[1]="Song2"
	ButtonEvents[2]="Song3"
	ButtonEvents[3]="Song4"

	DisableSound[0]="DudeDialog.dude_nope"
	DisableSound[1]="DudeDialog.dude_uhuh"
	DisableSound[2]="DudeDialog.dude_oops"
	DisableSound[3]="DudeDialog.dude_idontthinkso"

    DisplayFont=Font'P2Fonts.Fancy48'

    ButtonTexture=texture'P2ETextures.VendingMachine.button_bg'
}
