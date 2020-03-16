// ============================================================================
// Action Unlock Achievement
// Unlocks an achievement. Most of these are going to be based on specific
// areas or people, such as discovering Tora Bora or killing Vince or something.
// ============================================================================
class ACTION_UnlockAchievement extends P2ScriptedAction;

var() name AchievementAPIName;	// API Name of achievement to unlock. See P2AchievementManager for list of APINames.

function bool InitActionFor(ScriptedController C)
{
	local P2Player OurPlayer;
	
	if (C.Level.NetMode != NM_DedicatedServer)
	{
		OurPlayer = GetPlayer(C);
		return OurPlayer.GetEntryLevel().EvaluateAchievement(OurPlayer, AchievementAPIName);
	}
	else
	{
		return false;
	}
}

function string GetActionString()
{
	return ActionString @ String(AchievementAPIName);
}

defaultproperties
{
	ActionString="Unlock Achievement:"
}