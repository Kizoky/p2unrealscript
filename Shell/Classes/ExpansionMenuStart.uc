///////////////////////////////////////////////////////////////////////////////
// Sample Menu Start
// An example of how to make your own "start game" menu with Workshop.
///////////////////////////////////////////////////////////////////////////////
class ExpansionMenuStart extends BaseMenuBig;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var ShellMenuChoice		StartGameChoice;		// This is the choice the player will select to actually start the game.
var localized string	StartGameText;

var ShellMenuChoice		QuitGameChoice;			// This is the choice the player will select to quit and go back to POSTAL 2 Complete.
var localized string	QuitGameText;

var Texture DefaultLoadingTexture;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	Super.CreateMenuContents();

	// Add title texture
	// You don't need to define it in this menu -- BaseMenuBig will pull the proper texture from your gameinfo if it's defined.
	AddTitleBitmap(TitleTexture);
	
	// Add menu options
	StartGameChoice		= AddChoice(StartGameText,	"",									ItemFont, ItemAlign);
	QuitGameChoice		= AddChoice(QuitGameText,	"",									ItemFont, ItemAlign);
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
			if (C != None)
			{
				switch(C)
				{
					case StartGameChoice:
						// Actually start the game
						StartGameNow();
						break;
					case QuitGameChoice:
						// User pussed out -- send them back to POSTAL 2 Complete
						QuitGameNow();
						break;
				}
			}
	}
}

///////////////////////////////////////////////////////////////////////////////
// StartGameNow
// Actually start the game.
///////////////////////////////////////////////////////////////////////////////
function StartGameNow()
{
	local string StartGameURL;
	local Texture LoadTex;
	local P2GameInfoSingle usegame;
	local P2Player p2p;

	// All the difficulty things have already been set by the Workshop Browser.
	// All you need to do here is actually start the game proper.

	usegame = GetGameSingle();
	p2p = usegame.GetPlayer();
	StartGameURL = usegame.Static.GetStartURL(true);

	// Tell the root window we're ready to start
	P2RootWindow(Root).StartingGame();

	// Stop any active SceneManager so player will have a pawn
	usegame.StopSceneManagers();
	
	// Get rid of any things in his inventory before a new game starts
	P2Pawn(p2p.pawn).DestroyAllInventory();
	usegame.TheGameState.HudArmorClass = None;
	p2p.MyPawn.Armor = 0;

	// Game doesn't actually start until player is sent to first day,
	// which *should* happen at the end of the intro sequence.
	usegame.TheGameState.bChangeDayPostTravel = true;
	usegame.TheGameState.NextDay = 0;
	
	// Set our loading texture
	// Reach into the new game class and get the first day's loading screen.
	LoadTex = usegame.Days[0].GetLoadTexture();
	
	// If none, revert to default
	if (LoadTex == None)	
		LoadTex = DefaultLoadingTexture;

	usegame.bShowDayDuringLoad = True;
	usegame.ForcedLoadTex = LoadTex;
	
	// Actually start the game
	usegame.bQuitting = true;	// discard gamestate
	usegame.SendPlayerTo(p2p, StartGameURL);	
}

///////////////////////////////////////////////////////////////////////////////
// QuitGameNow
// User pussied out -- send them back to the POSTAL 2 Complete menu.
///////////////////////////////////////////////////////////////////////////////
function QuitGameNow()
{
	local class<P2GameInfoSingle> useclass;
	local string StartGameURL;	
	local P2Player p2p;
	
	//FIXME useclass = class<P2GameInfoSingle>(DynamicLoadObject(string(class'Engine.Engine'.default.DefaultGame),class'Class'));
	useclass = class'AWPGameInfo';
	
	StartGameURL = UseClass.Default.MainMenuURL $ "?Game=GameTypes.AWPGameInfo";	// FIXME
	//GetGameSingle().bQuitting = true;	// discard gamestate
	p2p = GetGameSingle().GetPlayer();
	GetGameSingle().SendPlayerTo(p2p, StartGameURL);
	HideMenu();
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	StartGameText="Start Game"
	QuitGameText="Quit"
	DefaultLoadingTexture=Texture'p2misc_full.Load.loading-screen'
}