///////////////////////////////////////////////////////////////////////////////
// MenuImageBusted
// Copyright 2014 Running With Scissors, Inc. All Rights Reserved
//
// Menu shown when the player gets arrested in a sandbox game.
///////////////////////////////////////////////////////////////////////////////
class MenuImageBusted extends MenuImage;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var ShellMenuChoice		RestartChoice;
var ShellMenuChoice 	QuitChoice;

var localized string 	RestartText;
var localized string 	QuitText;

var() Sound				JailDoorClosingSound;
var() Sound				JailDoorClosedSound;

var float TimeBegin, TimeEnd;

///////////////////////////////////////////////////////////////////////////////
// Appears to be a post-creation event for adding children and stuff.
///////////////////////////////////////////////////////////////////////////////
function Created()
{
	local string CurrentRes;
	local int ScreenHeight, ScreenWidth;

	// Grab the "Busted" image from the game definition.
	TextureImageName = GetGameSingle().ArrestedScreenTex;
	
	CurrentRes = GetPlayerOwner().ConsoleCommand("GETCURRENTRES");
	ScreenHeight = int(Right(CurrentRes, Len(CurrentRes) - InStr(CurrentRes, "x") - 1));
	ScreenWidth = int(Left(CurrentRes, InStr(CurrentRes, "x")));
	
	MenuWidth = ScreenWidth;
	MenuHeight = ScreenHeight;

	Super.Created();
}

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	Super.CreateMenuContents();

	ItemAlign  = TA_Left;
	ItemFont = F_FancyL;

	RestartChoice	= AddChoice(RestartText,	"", ItemFont, ItemAlign);
	QuitChoice 		= AddChoice(QuitText,		"", ItemFont, ItemAlign, true);

	TimeBegin = GetPlayerOwner().Level.TimeSecondsAlways + 0.1;
}

///////////////////////////////////////////////////////////////////////////////
// Handle a key event
///////////////////////////////////////////////////////////////////////////////
function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	// Override default handling, don't let them escape out.		
	if (Action == IST_Release)
		{
		switch (Key)
			{
			case IK_ESCAPE:
				ShellRootWindow(root).QuitCurrentGame();
				return true;
			}
		}
	
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
	switch(E)
	{
		case DE_Click:
			switch (C)
			{
				case RestartChoice:
					GetGameSingle().LoadMostRecentGame();
					break;
				case QuitChoice:
					ShellRootWindow(root).QuitCurrentGame();
					break;
			}
			break;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Play sound
///////////////////////////////////////////////////////////////////////////////
function Actor GetSoundActor()
{
	local P2Player p2p;
	local Actor a;

	// Always try to play sound via the player's pawn.  Use MyPawn because it
	// will be valid more often thatn Pawn (for instance, during cinematics).
	// If all else fails, play sound via the player controller, although that
	// will sometimes sound weird if the controller isn't near the pawn/viewport.
	p2p = P2Player(GetPlayerOwner());
	if (p2p != None && p2p.MyPawn != None)
		a = p2p.MyPawn;
	else
		a = ViewportOwner.Actor;

	return a;
}

///////////////////////////////////////////////////////////////////////////////
// Play sound
///////////////////////////////////////////////////////////////////////////////
function float GetSoundDuration(Sound snd)
{
	return GetPlayerOwner().GetSoundDuration(snd);
}

///////////////////////////////////////////////////////////////////////////////
// Default tick function.
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
{
	if (TimeBegin != 0
		&& GetPlayerOwner().Level.TimeSecondsAlways >= TimeBegin)
	{
		//log("play sound"@JailDoorClosingSound);
		LookAndFeel.PlayThisLocalSound(self, JailDoorClosingSound, 1.0);
		TimeBegin = 0;
		TimeEnd = GetPlayerOwner().Level.TimeSecondsAlways + GetSoundDuration(JailDoorClosingSound);
	}
	else if (TimeEnd != 0
		&& GetPlayerOwner().Level.TimeSecondsAlways >= TimeEnd)
	{
		//log(self@"play sound"@jaildoorclosedsound);
		LookAndFeel.PlayThisLocalSound(self, JailDoorClosedSound, 1.0);
		bRequiresTick = false;
		TimeEnd = 0;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	RestartText="Load previous save"
	QuitText="Quit"
	JailDoorClosingSound=Sound'jail.door_prison_cell_LP'
	JailDoorClosedSound=Sound'jail.door_prison_cell_close'
//	bDarkenBackground=true
	bRequiresTick=true

	aregButtons[0]=(X=530,Y=430,W=120,H=30)	// Using 640x480 locations to determine percentages.
	aregButtons[1]=(X=530,Y=450,W=120,H=30)	// Using 640x480 locations to determine percentages.
}
