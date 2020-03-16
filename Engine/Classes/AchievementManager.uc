// AchievementManager.
// One of these will be placed in Entry.fuk. Anything placed in Entry stays
// loaded throughout the entire game.
// Anything related to achievements will be handled here, except for the actual
// Steam integration part -- that'll be done in LevelInfo.
// A reference to this class can be obtained by using
// PlayerController.GetEntryLevel().GetAchievementManager()

class AchievementManager extends Info
	placeable
	config;
	
// Stat types
enum ESteamStatType
{
	STATTYPE_None,		// Dummy, should not be used
	STATTYPE_INT,		// Integer stats
	STATTYPE_FLOAT,		// Float stats
	STATTYPE_AVGRATE	// Moving Average stats
};

// Stat struct
struct SteamStat
{
	var ESteamStatType StatType;	// Type of stat (Int, Float, or AvgRate)
	var name APIName;				// API name of achievement
	// SetBy will always be Client
	var bool bIncrementOnly;		// Allow only increments, not decrements
	var int MaxChange_int;			// Maximum allowed change (int)
	var float MaxChange_float;		// Maximum allowed change (float type)
	var int MinValue_int;
	var int MaxValue_int;
	var float MinValue_float;
	var float MaxValue_float;		// Min and max for int/float types
	var int DefaultValue_int;
	var float DefaultValue_float;	// Default value
	var localized string DisplayName;	// Actual display name of stat
	var float Window;				// Window size for avgrate stats
	var int StatValue_int;			// Stat Current Value (int)
	var float StatValue_float;		// Stat Current Value (float)
	var bool bIgnore;				// If this is set to "true" then ignore this stat and don't try to update it with Steam.
	var name RelatedAchievementName;// API Name of related achievement
};

// Achievement struct
struct SteamAchievement
{
	var name APIName;				// API name of achievement
	var int ProgressStat;		// Progress stat used for achievement
	var int UnlockValue_int;		// Maximum value at which to unlock achievement (int-type stats)
	var float UnlockValue_float;	// Ditto
	
	//ErikFOV Change: for localization
	var string DisplayName;	// Display Name of achievement
	var string Description;	// Description
	//end
	
	var bool bHidden;				// Hidden from regular view
	// Icon Locked
	// Icon Unlocked
	var bool bUnlocked;				// True if achievement unlocked
	var bool bIgnore;				// If this is set to "true" then ignore this achievement and don't try to update it with Steam.
	var bool bGrindy;				// True if a "grindy" achievement
	var bool bNoComment;			// True if we don't want the dude to comment on it (Patches achievement)
	var Texture LockedTex;			// Texture of locked achievement icon
	var Texture UnlockedTex;		// Texture of unlocked achievement icon
};

// Variables
var protected array<SteamStat> Stats;
var protected array<SteamAchievement> Achievements;

var globalconfig array<SteamStat> StatValues;
var globalconfig array<SteamAchievement> AchievementValues;

//ErikFOV Change: for localization
const NameLen = 71;
var localized string AchievementsDisplayName[NameLen];
var localized string AchievementsDescription[NameLen];
//var localized array<string> AchievementsDisplayName;
//var localized array<string> AchievementsDescription;
//end
	
// DRM-free Achievement functions
// Not used in Steam builds
function UnlockAchievement(name AchievementName)
{
}
function LockAchievement(name AchievementName)
{
}
function bool GetAchievement(name AchievementName)
{
	return false;
}
function int GetStatInt(name StatName)
{
	return 0;
}
function float GetStatFloat(name StatName)
{
	return 0.0;
}
function SetStatInt(name StatName, int NewValue)
{
}
function SetStatFloat(name StatName, float NewValue)
{
}

// ============================================================================
// PreBeginPlay
// Register ourself with Entry.
// ============================================================================
event PreBeginPlay()
{
	local PlayerController P;
	local bool bDestroyed;
	
	// Don't allow to be placed into any level other than Entry.
	foreach DynamicActors(class'PlayerController',P)
		if (Level.NetMode != NM_DedicatedServer && P.GetEntryLevel() != Level)
			bDestroyed = Destroy();

	if (!bDestroyed)
	{
		// Register with Entry's LevelInfo and start stats download.
		Level.RegisterAchievementManager(self);	

		if (!Level.IsSteamBuild())
		{
			// Initialize local stats and achievement saving.
			StatsReady();
		}
	}
}

// ============================================================================
// StatsReady
// Called by Entry's LevelInfo when the stats download is complete.
// ============================================================================
event StatsReady()
{
	local int i;
	
	// just in case this is our first run
	StatValues.Length = Stats.Length;
	AchievementValues.Length = Achievements.Length;

	SaveConfig();
	
	// Initialize all stats and achievements.
	
	for (i=0; i < Stats.length; i++)
	{
		if (!Stats[i].bIgnore)
		{
			if (Stats[i].StatType == STATTYPE_Int)
			{
				if (Level.IsSteamBuild())
					Stats[i].StatValue_int = Level.RequestSteamStatInt(Stats[i].APIName);
				else
					Stats[i].StatValue_int = StatValues[i].StatValue_int;
					
				debuglog(Stats[i].APIName@Stats[i].StatValue_int);
			}
			else
			{
				if (Level.IsSteamBuild())
					Stats[i].StatValue_float = Level.RequestSteamStatFloat(Stats[i].APIName);
				else
					Stats[i].StatValue_float = StatValues[i].StatValue_float;
				
				debuglog(Stats[i].APIName@Stats[i].StatValue_float);
			}
		}
	}

	for (i=0; i < Achievements.length; i++)
	{
		if (!Achievements[i].bIgnore)
		{
			if (Level.IsSteamBuild())
				Achievements[i].bUnlocked = Level.RequestAchievementStatus(Achievements[i].APIName);
			else
				Achievements[i].bUnlocked = AchievementValues[i].bUnlocked;

			debuglog(Achievements[i].APIName@Achievements[i].bUnlocked);
		}
	}	
}

// ============================================================================
// EvaluateAchievement
// Attempt to unlock achievement. Check that cheats are disabled and that the
// necessary requirements to unlock the achievement are met.
// ============================================================================
function bool EvaluateAchievement(PlayerController Achiever, name AchievementName, optional bool bDisplayInConsole)
{
	//if (Achievements[i].bIgnore)
	//	return false;
		
	// STUB
	return false;
}

function bool IsGrindy(int AchNum)
{
	if (AchNum < Achievements.Length)
		return Achievements[AchNum].bGrindy;
	else
		return false;
}
function int GetAchievementNum(name AchName)
{
	local int i;
	
	for (i=0; i < Achievements.length; i++)
		if (Achievements[i].APIName == AchName)
			return i;
			
	return -1;
}

// ============================================================================
// GetRelatedAchievement
// Returns the related achievement for a stat.
// ============================================================================
function name GetRelatedAchievement(name StatName)
{
	local int i;
	

	for (i=0; i < Stats.length; i++)
		if (Stats[i].APIName == StatName)
			return Stats[i].RelatedAchievementName;
}

// Dude comments on achievement grinding.
function CommentOnGrinding(PlayerController Statter); // STUB

// ============================================================================
// UpdateStatInt
// Updates an int-based stat.
// ============================================================================
function UpdateStatInt(PlayerController Statter, name StatName, int Delta, optional bool bUnlockAchievement)
{
	local int i, Mark1, Mark2, Mark3, AchNum;
	
	for (i=0; i < Stats.length; i++)
	{	
		if ((Stats[i].APIName == StatName) && (!Stats[i].bIncrementOnly || Delta > 0) && (!Stats[i].bIgnore))
		{
			// If it's a grindy achievement, show a progress bar maybe.
			AchNum = GetAchievementNum(Stats[i].RelatedAchievementName);
			if (AchNum != -1 && IsGrindy(AchNum))
			{
				// Show progress bars at 1%, 50%, and 75% of achievement progress.
				Mark1 = (Achievements[AchNum].UnlockValue_int) * 0.01;
				if (Mark1 <= 0) 
					Mark1 = 1;
				Mark2 = (Achievements[AchNum].UnlockValue_int) * 0.5;
				Mark3 = (Achievements[AchNum].UnlockValue_int) * 0.75;
				
				// Decide whether to show progress
				if ((Stats[i].StatValue_int < Mark1 && Stats[i].StatValue_int + Delta >= Mark1)
					|| (Stats[i].StatValue_int < Mark2 && Stats[i].StatValue_int + Delta >= Mark2)
					|| (Stats[i].StatValue_int < Mark3 && Stats[i].StatValue_int + Delta >= Mark3))
					{
						Level.SteamIndicateAchievementProgress(string(Achievements[AchNum].APIName), Stats[i].StatValue_int + Delta, Achievements[AchNum].UnlockValue_int);
						CommentOnGrinding(Statter);
					}
			}
			
			Stats[i].StatValue_int += Delta;
			StatValues[i].StatValue_int = Stats[i].StatValue_int;
			SaveConfig();
			//log ("== DEBUG UPDATE STAT INT ==",'Debug');
			//log (StatName@Delta@Stats[i].StatValue_int,'Debug');
			//Statter.ClientMessage("=DEBUG= Stat"@StatName@"increased to"@Stats[i].StatValue_int);
			Level.RequestUpdateStatInt(Stats[i].APIName, Stats[i].StatValue_int);
			if (bUnlockAchievement)
				Level.EvaluateAchievement(Statter, GetRelatedAchievement(StatName));
		}
	}
}

// ============================================================================
// UpdateStatFloat
// Updates a float-based stat.
// ============================================================================
function UpdateStatFloat(PlayerController Statter, name StatName, float Delta, optional bool bUnlockAchievement)
{
	local int i, AchNum;
	local float Mark1, Mark2, Mark3;
	
	for (i=0; i < Stats.length; i++)
	{	
		if ((Stats[i].APIName == StatName) && (!Stats[i].bIncrementOnly || Delta > 0) && (!Stats[i].bIgnore))
		{
			// If it's a grindy achievement, show a progress bar maybe.
			AchNum = GetAchievementNum(Stats[i].RelatedAchievementName);
			if (IsGrindy(AchNum))
			{
				// Show progress bars at 1%, 50%, and 75% of achievement progress.
				Mark1 = (Achievements[AchNum].UnlockValue_float) * 0.01;
				// Make float progress bars trigger at a minimum of 1
				if (Mark1 <= 1) 
					Mark1 = 1;
				Mark2 = (Achievements[AchNum].UnlockValue_float) * 0.5;
				Mark3 = (Achievements[AchNum].UnlockValue_float) * 0.75;
				
				// Decide whether to show progress
				if ((Stats[i].StatValue_float < Mark1 && Stats[i].StatValue_float + Delta >= Mark1)
					|| (Stats[i].StatValue_float < Mark2 && Stats[i].StatValue_float + Delta >= Mark2)
					|| (Stats[i].StatValue_float < Mark3 && Stats[i].StatValue_float + Delta >= Mark3))
					{
						Level.SteamIndicateAchievementProgress(string(Achievements[AchNum].APIName), Stats[i].StatValue_float + Delta, Achievements[AchNum].UnlockValue_float);
						CommentOnGrinding(Statter);
					}
			}

			Stats[i].StatValue_float += Delta;
			StatValues[i].StatValue_float = Stats[i].StatValue_float;
			SaveConfig();
			//log ("== DEBUG UPDATE STAT FLOAT ==",'Debug');
			//log (StatName@Delta@Stats[i].StatValue_float,'Debug');
			//Statter.ClientMessage("=DEBUG= Stat"@StatName@"increased to"@Stats[i].StatValue_float);
			Level.RequestUpdateStatFloat(Stats[i].APIName, Stats[i].StatValue_float);
			if (bUnlockAchievement)
				Level.EvaluateAchievement(Statter, GetRelatedAchievement(StatName));
		}
	}
}

// ============================================================================
// ResetStatInt
// Resets an int-based stat.
// ============================================================================
function ResetStatInt(PlayerController Statter, name StatName)
{
	local int i;
	
	for (i=0; i < Stats.length; i++)
	{	
		if ((Stats[i].APIName == StatName) && (!Stats[i].bIgnore))
		{
			Stats[i].StatValue_int = 0;
			StatValues[i].StatValue_int = 0;
			SaveConfig();
			Level.RequestUpdateStatInt(Stats[i].APIName, Stats[i].StatValue_int);
		}
	}
}

// ============================================================================
// ResetStatFloat
// Resets a float-based stat.
// ============================================================================
function ResetStatFloat(PlayerController Statter, name StatName)
{
	local int i;
	
	for (i=0; i < Stats.length; i++)
	{	
		if ((Stats[i].APIName == StatName) && (!Stats[i].bIgnore))
		{
			Stats[i].StatValue_float = 0;
			StatValues[i].StatValue_float = 0;
			SaveConfig();
			Level.RequestUpdateStatFloat(Stats[i].APIName, Stats[i].StatValue_float);
		}
	}
}

function ResetAll(optional name OnlyThis)
{
	local int i;
	
	if (OnlyThis == '')
		Level.SteamResetStats(true);
	else
		Level.LockAchievement(OnlyThis);
	
	// Completely reset all achievements to what their default values should be.
	// This way, if a player winds up with an empty achievement list for some reason, we can reset it.
	StatValues.Length = Stats.Length;
	AchievementValues.Length = Achievements.Length;
	//log("reset stats length"@Stats.Length@"achievements length"@Achievements.Length,'Debug');
	
	for (i=0; i < Stats.length; i++)
	{
		if (OnlyThis == ''
			|| Stats[i].APIName == OnlyThis)
		{
			Stats[i].StatType = Default.Stats[i].StatType;
			Stats[i].APIName = Default.Stats[i].ApiName;
			Stats[i].bIncrementOnly = Default.Stats[i].bIncrementOnly;
			Stats[i].MaxChange_int = Default.Stats[i].MaxChange_int;
			Stats[i].MaxChange_float = Default.Stats[i].MaxChange_float;
			Stats[i].MinValue_int = Default.Stats[i].MinValue_int;
			Stats[i].MinValue_float = Default.Stats[i].MinValue_float;
			Stats[i].MaxValue_int = Default.Stats[i].MaxValue_int;
			Stats[i].MaxValue_Float = Default.Stats[i].MaxValue_float;
			Stats[i].DefaultValue_int = Default.Stats[i].DefaultValue_int;
			Stats[i].DefaultValue_float = Default.Stats[i].DefaultValue_float;
			Stats[i].DisplayName = Default.Stats[i].DisplayName;
			Stats[i].Window = Default.Stats[i].Window;
			Stats[i].StatValue_int = Stats[i].DefaultValue_int;
			Stats[i].StatValue_float = Stats[i].DefaultValue_float;
			Stats[i].bIgnore = Default.Stats[i].bIgnore;
			Stats[i].RelatedAchievementName = Default.Stats[i].RelatedAchievementName;
			
			StatValues[i].StatValue_int = Stats[i].StatValue_int;
			StatValues[i].StatValue_float = Stats[i].StatValue_float;
		}
	}

	for (i = 0; i < Achievements.Length; i++)
	{
		if (OnlyThis == ''
			|| Achievements[i].APIName == OnlyThis)
		{
			Achievements[i].APIName = Default.Achievements[i].APIName;
			Achievements[i].ProgressStat = Default.Achievements[i].ProgressStat;
			Achievements[i].UnlockValue_int = Default.Achievements[i].UnlockValue_int;
			Achievements[i].UnlockValue_float = Default.Achievements[i].UnlockValue_float;
			
			//ErikFOV Change: for localization
			//Achievements[i].DisplayName = Default.Achievements[i].DisplayName;
			//Achievements[i].Description = Default.Achievements[i].Description;
			AchievementsDisplayName[i] = Default.AchievementsDisplayName[i];
			AchievementsDescription[i] = Default.AchievementsDescription[i];
			//end

			Achievements[i].bHidden = Default.Achievements[i].bHidden;
			Achievements[i].bUnlocked = False;
			Achievements[i].bIgnore = Default.Achievements[i].bIgnore;
			Achievements[i].bGrindy = Default.Achievements[i].bGrindy;
			
			AchievementValues[i].bUnlocked = Achievements[i].bUnlocked;
			
			// If there's a related stat, erase it too
			if (Achievements[i].ProgressStat > 0)
				ResetAll(Stats[Achievements[i].ProgressStat].APIName);
		}
	}
		
	SaveConfig();
}

// stubby stubs
function string GetAchievementName(int i);
function string GetAchievementProgress(int i);
function Texture GetAchievementIcon(int i);

defaultproperties
{
}
