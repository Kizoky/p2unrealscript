class ACTION_IsWeekendGame extends ScriptedAction;

var() bool bIs;	// True means we want to trigger if the game is a weekend game (AWP or AW)

function ProceedToNextAction(ScriptedController C)
{
	local P2GameInfoSingle game;

	game = P2GameInfoSingle(C.Level.Game);

	C.ActionNum += 1;
	if (game == None)
		ProceedToSectionEnd(C);
	if (game.WeekendGame() != bIs)
		ProceedToSectionEnd(c);
}

function string GetActionString()
{
		return ActionString@bIs;
}

defaultproperties
{
	ActionString="If weekendable game is"
	bRequiresValidGameInfo=true
	bIs=true
}
