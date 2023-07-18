///////////////////////////////////////////////////////////////////////////////
// Check for Two Weeks In Paradise game mode
// (for Paradise Lost DLC)
///////////////////////////////////////////////////////////////////////////////
class ACTION_IsTwoWeeksGame extends ScriptedAction;

var() bool bIs;	// True means we want to trigger if the game is a 2 weeks game (Paradise Lost DLC)

function ProceedToNextAction(ScriptedController C)
{
	local P2GameInfoSingle game;

	game = P2GameInfoSingle(C.Level.Game);

	C.ActionNum += 1;
	if (game == None)
		ProceedToSectionEnd(C);
	if (game.TwoWeeksGame() != bIs)
		ProceedToSectionEnd(c);
}

function string GetActionString()
{
		return ActionString@bIs;
}

defaultproperties
{
	ActionString="If 2 weeks game is"
	bRequiresValidGameInfo=true
	bIs=true
}
