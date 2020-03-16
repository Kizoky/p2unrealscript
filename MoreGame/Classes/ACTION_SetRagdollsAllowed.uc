///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
class ACTION_SetRagdollsAllowed extends P2ScriptedAction;

var(Action) bool bAllowRagdolls;		// Set to false to turn off ragdolls, true to turn on.

function bool InitActionFor(ScriptedController C)
{
	local P2GameInfoSingle game;

	game = P2GameInfoSingle(C.Level.Game);
	if(game != None)
		game.bForbidRagdolls = !bAllowRagdolls;
	return false;
}

defaultproperties
{
	bAllowRagdolls=true
	bRequiresValidGameInfo=true
}