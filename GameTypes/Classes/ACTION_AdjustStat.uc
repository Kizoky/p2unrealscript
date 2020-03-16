// ============================================================================
// Action Adjust Stat
// Adjusts a Steam stat. We only use these for achievements, so this is just
// going to keep track of things like jail escapes, etc.
// Optionally unlock the achievement when the correct threshold is reached.
// ============================================================================
class ACTION_AdjustStat extends P2ScriptedAction;

var() name StatAPIName;						// API Name of stat to adjust. See P2AchievementManager for list of APINames.
var() int Delta_int;					// Amount to adjust stat by (int-based stats)
var() float Delta_float;				// Amount to adjust stat by (float-based stats)
var() bool bUnlockRelatedAchievement;	// If true, attempts to unlock related achievement

function bool InitActionFor(ScriptedController C)
{
	local P2Player OurPlayer;
	local AchievementManager AM;
	
	if(C.Level.NetMode != NM_DedicatedServer )
	{
		OurPlayer = GetPlayer(C);
		AM = OurPlayer.GetEntryLevel().GetAchievementManager();
		if (AM != None)
		{
			if (Delta_int != 0)
				AM.UpdateStatInt(OurPlayer, StatAPIName, Delta_int, bUnlockRelatedAchievement);
			else if (Delta_float != 0)
				AM.UpdateStatFloat(OurPlayer, StatAPIName, Delta_float, bUnlockRelatedAchievement);
				
			return true;
		}
		else
			return false;
	}
	return false;
}

function string GetActionString()
{
	return ActionString @ String(StatAPIName)@Delta_int@Delta_float;
}

defaultproperties
{
	ActionString="Adjust Stat:"
}