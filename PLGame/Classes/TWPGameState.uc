///////////////////////////////////////////////////////////////////////////////
// TWPGameState
// by Man Chrzan
//
// Game state for Two Weeks Game. Contains two weeks-specific stuff.
///////////////////////////////////////////////////////////////////////////////
class TWPGameState extends PLGameState;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////

var travel float FirstWeekTime;	// Record time when we beat the first week 

const TWP_DAY_APOCALYPSE = 13;
const TWP_DAY_MONDAY2 = 7;

// Pardise Lost Speed Run times.
const PL_SPEEDRUN_ACHIEVEMENT = 6300.00;	// 1:45:00 for Aderall achievement
const PL_SPEED_RUN = 6300.00;				// 1:45:00 to get the speedrunner ranking.
const PL_SUPER_SPEED_RUN = 5400.00;		// 1:30:00 to get the super speedrunner ranking.
const PL_ULTRA_SPEED_RUN = 4500.00;		// 1:15:00 minutes to get the ultra speedrunner ranking.
const PL_MEGA_SPEED_RUN = 3600.00;			// If they do it in under an hour, suggest they submit a run to SDA

// POSTAL 2 Speed Run times.
const P2_SPEEDRUN_ACHIEVEMENT = 5400.00;	// 1.5 hours to get the speedrun achievement.
const P2_SPEED_RUN = 5400.00;				// 1.5 hours to get the speedrunner ranking.
const P2_SUPER_SPEED_RUN = 3600.00;		// 1 hour to get the super speedrunner ranking.
const P2_ULTRA_SPEED_RUN = 2700.00;		// 45 minutes to get the ultra speedrunner ranking.
const P2_MEGA_SPEED_RUN = 1800.00;			// If they do it in under 30, suggest they submit a run to SDA

///////////////////////////////////////////////////////////////////////////////
// Get the player's speedrunning ranking
///////////////////////////////////////////////////////////////////////////////
function string GetPlayerRankingSpeedRun()
{
	if (!DidPlayerCheat())
	{
		// If you're a speedrunning god
		if (TimeElapsed <= PL_MEGA_SPEED_RUN + P2_MEGA_SPEED_RUN)
			return MegaSpeedRanking;
			
		// If you beat the game extremely quickly
		if(TimeElapsed <= PL_ULTRA_SPEED_RUN + P2_ULTRA_SPEED_RUN)
			return UltraSpeedRanking;

		// If you beat the game very quickly
		if(TimeElapsed <= PL_SUPER_SPEED_RUN + P2_SUPER_SPEED_RUN)
			return SuperSpeedRanking;

		// If you beat the game quickly
		if(TimeElapsed <= PL_SPEED_RUN + P2_SPEED_RUN)
			return SpeedRanking;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Starting a new day should forget several of the persistent lists
// and forget things like crack addiction, catnip time, etc.
///////////////////////////////////////////////////////////////////////////////
function RemovePersistanceForNewDay(P2Pawn PlayerPawn)
{
	Super.RemovePersistanceForNewDay(PlayerPawn);
	if (CurrentDay == TWP_DAY_MONDAY2 
		|| CurrentDay == TWP_DAY_APOCALYPSE)
		CurrentHaters.Length = 0;
}

defaultproperties
{
}
