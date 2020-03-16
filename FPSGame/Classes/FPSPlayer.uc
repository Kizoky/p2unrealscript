//=============================================================================
// FPSPlayer.
//=============================================================================
class FPSPlayer extends PlayerController
	native
	config(user);


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

const DebugMenuPath = "FPSGame.FPSPlayer bEnableDebugMenu"; // ini path
var globalconfig bool bEnableDebugMenu;	// Whether to enable the debug menu

var globalconfig string DefEmptySay;	// What you say when you just press enter with no string in it
var globalconfig string DefEmptyTeamSay;// What you say when you just press enter with no string in it

var localized string EmptySayDone; 
var localized string EmptyTeamSayDone; 
var localized string SayDoneStart; 
var localized string SayDoneEnd; 
var localized string TeamSayDoneStart; 
var localized string TeamSayDoneEnd; 

// Preset Say and TeamSay messages
var globalconfig string SExtra[8];
var globalconfig string TSExtra[8];

// This has to match the same string in fpshud, except for the space at the beginning
// of this one 
// This HAS to match FPSConsoleExt's also!
const TEAM_STR_LOCK_PLAYER	 = " (-*Team..)";
// This HAS to match FPSConsoleExt's also!

///////////////////////////////////////////////////////////////////////////////
// Joystick input crap
///////////////////////////////////////////////////////////////////////////////
var() class<JoyMouseInteraction> 		JoyMouseInteractionClass;			// Class of JoyMouseInteraction to use
var() class<InputTrackerInteraction> 	InputTrackerInteractionClass;	// Class of InputTrackerInteraction to use

var transient JoyMouseInteraction		JoyMouse;
var transient InputTrackerInteraction 	InputTracker;

///////////////////////////////////////////////////////////////////////////////
// Add joystick mouse controller thingy
///////////////////////////////////////////////////////////////////////////////
function Possess (Pawn aPawn)
{
	Super.Possess(aPawn);

	SetupInteractions();
}

///////////////////////////////////////////////////////////////////////////////
// Called after a saved game has been loaded
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
{
	Super.PostLoadGame();
	
	SetupInteractions();	
}

///////////////////////////////////////////////////////////////////////////////
// Set up our interactions
///////////////////////////////////////////////////////////////////////////////
function SetupInteractions()
{
	local int i;
	
	// Search for existing screens
	for (i = 0; i < Player.LocalInteractions.Length; i++)
	{
		if (JoyMouseInteraction(Player.LocalInteractions[i]) != None)
			JoyMouse = JoyMouseInteraction(Player.LocalInteractions[i]);
		else if (InputTrackerInteraction(Player.LocalInteractions[i]) != None)
			InputTracker = InputTrackerInteraction(Player.LocalInteractions[i]);
	}
	if (JoyMouse == None)
		JoyMouse = JoyMouseInteraction(Player.InteractionMaster.AddInteraction(String(JoyMouseInteractionClass), Player));
	if (InputTracker == None)
		InputTracker = InputTrackerInteraction(Player.InteractionMaster.AddInteraction(String(InputTrackerInteractionClass), Player));
}

///////////////////////////////////////////////////////////////////////////////
// Write to the ini, your new default sayings
// Just type 
// SetEmptySay my new empty string
// in the tab.. so that would
// make it say "my new empty string", 
// Which will only show up if you type Say, but then 
// press Enter and add nothing else. This is for that case only.
//
// If you want the Say and console to just go away and not send
// anything, make the DefEmptySay *also* "". So...
// type 
// SetEmptySay
// and press Enter. Then, when you accidentially hit Say and press
// Enter too early, nothing will be sent, and you'll be spared looking
// like you just learned how to use a keyboard.
///////////////////////////////////////////////////////////////////////////////
exec function SetEmptySay(string msg)
{
	// Make sure it only happens in MP
	if(FPSGameInfo(Level.Game) == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
	{
		DefEmptySay = msg;
		SaveConfig();
		// tell them it worked
		ClientMessage(EmptySayDone$DefEmptySay);
	}
}
exec function SetEmptyTeamSay(string msg)
{
	// Make sure it only happens in MP
	if(FPSGameInfo(Level.Game) == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
	{
		DefEmptyTeamSay = msg;
		SaveConfig();
		// tell them it worked
		ClientMessage(EmptyTeamSayDone$DefEmptyTeamSay);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Pre-set messages to make it quicker to say things you'd often
// say. Typically only for team games.
// These should get put into the user.ini, like this
//
// F2=ExtraTeamSay 1
// to call index 0, to make it easier for people changing them
// in the ini file, also. 
///////////////////////////////////////////////////////////////////////////////
exec function ExtraTeamSay(int index)
{
	// Make sure it only happens in MP
	if(FPSGameInfo(Level.Game) == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
	{
		index = index-1;
		if(index >= 0
			&& index < ArrayCount(TSExtra))
		{
			TeamSay("(-*Team..) "$TSExtra[index]);
		}
	}
}
exec function ExtraSay(int index)
{
	// Make sure it only happens in MP
	if(FPSGameInfo(Level.Game) == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
	{
		index = index-1;
		if(index >= 0
			&& index < ArrayCount(SExtra))
		{
			Say(SExtra[index]);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Way to set each of the preset messages
// Team versions
// Format for team messages to set them is as such
// ex: setteamsay 1 guard the door
// Makes index 0, set to "guard the door"
// or
// setteamsay 6 fight now!
// Makes index 5, set to "fight now!"
// Automatically lowers index by one to make it more human friendly.
///////////////////////////////////////////////////////////////////////////////
exec function SetTeamSay(int index, string msg)
{
	index = index-1;
	if(index >= 0
		&& index < ArrayCount(TSExtra))
	{
		TSExtra[index] = msg;
		SaveConfig();
		// tell them it worked
		ClientMessage(TeamSayDoneStart$(index+1)$TeamSayDoneEnd$TSExtra[index]);
	}
}
///////////////////////////////////////////////////////////////////////////////
// Just like SetTeamSay, except you type "SetSay" first instead.
// ex: SetSay 1 I rule!
// makes index 0 set to "I rule!"
///////////////////////////////////////////////////////////////////////////////
exec function SetSay(int index, string msg)
{
	index = index-1;
	if(index >= 0
		&& index < ArrayCount(SExtra))
	{
		SExtra[index] = msg;
		SaveConfig();
		// tell them it worked
		ClientMessage(SayDoneStart$(index+1)$SayDoneEnd$SExtra[index]);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Start up the debug menu
///////////////////////////////////////////////////////////////////////////////
exec function EnableDebugMenu()
{
	bEnableDebugMenu=!bEnableDebugMenu;
	ConsoleCommand("set" @ DebugMenuPath @ bEnableDebugMenu);
	if (bEnableDebugMenu)	
		ClientMessage("Warning: Debug menu disables achievements and flags all saves as cheated until disabled. For modding only!");
	else
		ClientMessage("Debug menu disabled. Disable cheats and reload game to re-enable achievements.");
}
function ForceDebugMenu()
{
	bEnableDebugMenu = true;
	ConsoleCommand("set" @ DebugMenuPath @ bEnableDebugMenu);
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if debug menu/mode is enabled
///////////////////////////////////////////////////////////////////////////////
function bool DebugEnabled()
{
	return bEnableDebugMenu;
}

///////////////////////////////////////////////////////////////////////////////
// Tell dude he got some health
///////////////////////////////////////////////////////////////////////////////
function NotifyGotHealth(int howmuch)
{
}
	
///////////////////////////////////////////////////////////////////////////////
// Simple movie test functions
///////////////////////////////////////////////////////////////////////////////
exec function MoviePlay(string MovieName, optional bool bDirect)
{
	local float Height;

	Log("PlayMovie: MovieName="$MovieName$", bDirect="$bDirect);

	if(bDirect)
	{
		// Play movie directly to frame buffer with no size change
		myHud.PlayMovieDirect(MovieName, 0, 0, false, false); 
	}
	else
	{
		// Play movie scaled up so to fill the screen
		myHud.PlayMovieScaled(MovieTexture(DynamicLoadObject("MovieTextures.Generic", class'MovieTexture')), MovieName, 0, 0, 1, 1, false, false); 
		ViewTarget.PlaySound(Sound(DynamicLoadObject("Movies.Movie_EndOfDay2", class'Sound')));
//		Height = 384.0f / 480.0f;
//		myHud.PlayMovieScaled(MovieTexture(DynamicLoadObject("MovieTextures.Generic", class'MovieTexture')), 0, (1.0 - Height) / 2, 1, Height, false, false); 
	}
}

exec function MoviePause()
{
	myHud.PauseMovie(!myHud.IsMoviePaused());
}

exec function MovieStop()
{
	myHud.StopMovie();
}


defaultproperties
{
	FovAngle=+00085.000000
	PlayerReplicationInfoClass=Class'Engine.PlayerReplicationInfo'
	DefEmptySay=""
	DefEmptyTeamSay=""
	
	EmptySayDone="Empty Say is: "
	EmptyTeamSayDone="Empty TeamSay is: "

	SayDoneStart="Say"
	SayDoneEnd=" is now: "
	TeamSayDoneStart="TeamSay"
	TeamSayDoneEnd=" is now: "

	SExtra[0]="I rule."
	SExtra[1]="gg"
	SExtra[2]="Yup"
	SExtra[3]="Player, change your name."
	SExtra[4]="Time for some pain."
	SExtra[5]="Here comes the bride."
	SExtra[6]="Can someone spare a health pipe?"
	SExtra[7]="I seem to be missing my face."
	TSExtra[0]="Meet in our base to prep for attack."
	TSExtra[1]="Getting ready to charge their base."
	TSExtra[2]="I have the Babe!  Need support!"
	TSExtra[3]="I'm attacking via the Main Entrance!"
	TSExtra[4]="I'm attacking via the Back Entrance!"
	TSExtra[5]="Enemy in the Bedroom!"
	TSExtra[6]="Enemy at Main Entrance!"
	TSExtra[7]="Enemy at Back Entrance!"
	
	JoyMouseInteractionClass="UWindow.JoyMouseInteraction"
	InputTrackerInteractionClass="FPSGame.InputTrackerInteraction"
}