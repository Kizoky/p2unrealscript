///////////////////////////////////////////////////////////////////////////////
// CreditsGameInfo
// Stripped down version of the game for credits
///////////////////////////////////////////////////////////////////////////////
class CreditsGameInfoP2 extends GameSinglePlayer;

var texture BlackBackground;

///////////////////////////////////////////////////////////////////////////////
// The player has watched the credits and has successfully beaten the credits!
// Award them by sending them back to the main menu.
///////////////////////////////////////////////////////////////////////////////
function EndOfGame(P2Player player)
{
	P2RootWindow(player.Player.InteractionMaster.BaseMenu).EndingGame();
	
	// Send player to main menu
	ForcedLoadTex = BlackBackground;
	
	// Use the console command version here, we want to completely discard the credits gameinfo and start fresh in a PLGameInfo.
	player.ConsoleCommand("open"@MainMenuURL);
}

///////////////////////////////////////////////////////////////////////////////
// Check if we're in the "pre-game" mode (main menu, intro, etc.)
// Rigged to false so we don't block the menu.
///////////////////////////////////////////////////////////////////////////////
function bool IsPreGame()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Quit the game.
// NOTE: Player may not have a pawn if he's dead or a cinematic is playing.
///////////////////////////////////////////////////////////////////////////////
function QuitGame()
{
	local PlayerController PCon;
	PCon = GetPlayer();
	P2RootWindow(PCon.Player.InteractionMaster.BaseMenu).EndingGame();

	bQuitting = true;

	// Send player to main menu (set flag to indicate that pawn might be none)
	ForcedLoadTex = BlackBackground;
	
	// Use the console command version here, we want to completely discard the credits gameinfo and start fresh in a PLGameInfo.
	PCon.ConsoleCommand("open"@MainMenuURL);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	GameName="Credits"
	GameNameshort="Credits"
	GameDescription="Credits"
	BlackBackground=Texture'Nathans.Inventory.BlackBox64'
	bNeverDrawTime=true
}
