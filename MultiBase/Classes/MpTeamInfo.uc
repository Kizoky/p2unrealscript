//=============================================================================
// includes list of bots on team for multiplayer games
//=============================================================================

class MpTeamInfo extends TeamInfo
	placeable;

var localized string TeamDescription;
var Texture TeamTexture;		// replicated
var Texture TeamTextureNoMips;	// recplicated
var Sound TeamWinSound;
var Sound TeamScoreSound;

var() RosterEntry DefaultRosterEntry;
var() export editinline array<RosterEntry> Roster;
var() class<MpPawn> AllowedTeamMembers[32];	// This exceeds our max team size, but it allows us to have lots of AVAILABLE characters
var() byte TeamAlliance;
var int DesiredTeamSize;
var TeamAI AI;

var array<string> RosterNames;  // promoted from Team/DM rosters
var bool bSuitableForTeamGames;		// some teams aren't suitable for team games (they're intended for deathmatch only)
var bool bHighlyHomogeneous;		// some teams are homogenous (cops, swat, gary) and some aren't (the man, hood)

struct TeamIntInfo
{
	var string				ClassName;
	var class<MpTeamInfo>	Class;
	var string				Grudges;
};

replication
{
	// Variables the server should send to the client.
	reliable if ( bNetInitial && (Role==ROLE_Authority) )
		TeamTexture, TeamTextureNoMips;
}

simulated function string GetHumanReadableName()
{
	return TeamName;
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	if ( !MPGameInfo(Level.Game).bTeamScoreRounds )
		Score = 0;
}

function int OverrideInitialBots(int N, MpTeamInfo T)
{
	return N;
}
	
function bool AllBotsSpawned()
{
	return false;
}

function Initialize(int TeamBots);

simulated function class<Pawn> NextLoadOut(class<Pawn> CurrentLoadout)
{
	local int i;
	local class<Pawn> Result;

	Result = AllowedTeamMembers[0];

	for ( i=0; i<ArrayCount(AllowedTeamMembers) - 1; i++ )
	{
		if ( AllowedTeamMembers[i] == CurrentLoadout )
		{
			if ( AllowedTeamMembers[i+1] != None )
				Result = AllowedTeamMembers[i+1];
			break;
		}
		else if ( AllowedTeamMembers[i] == None )
			break;
	}

	return Result;
}

function bool NeedsBotMoreThan(MpTeamInfo T)
{
	return ( (DesiredTeamSize - Size) > (T.DesiredTeamSize - T.Size) );
}

function RosterEntry ChooseBotClass(optional string botName)
{
    if (botName == "")
        return GetNextBot();

    return GetNamedBot(botName);
}

function RosterEntry GetRandomPlayer();

function bool AlreadyExistsEntry(string CharacterName, bool bNoRecursion)
{
	return false;
}

function AddRandomPlayer()
{
	local int j;

	j = Roster.Length;
	Roster.Length = Roster.Length + 1;
	Roster[j] = GetRandomPlayer();
	Roster[j].PrecacheRosterFor(self);
}

function RosterEntry GetNextBot()
{
	local int i;

	for ( i=0; i<Roster.Length; i++ )
		if ( !Roster[i].bTaken )
		{
			Roster[i].bTaken = true;
			return Roster[i];
		}
	i = Roster.Length;
	Roster.Length = Roster.Length + 1;
	Roster[i] = GetRandomPlayer();
	Roster[i].bTaken = true;
	return Roster[i];
}

function RosterEntry GetNamedBot(string botName)
{
    return GetNextBot();
}

function bool AddToTeam( Controller Other )
{
	local bool bResult;

	bResult = Super.AddToTeam(Other);

	if ( bResult && (Other.PawnClass != None) && !BelongsOnTeam(Other.PawnClass) )
	{
		Other.PawnClass = DefaultPlayerClass;
		// CRK:  Update URL and set ini values for new class
		if(PlayerController(Other) != None)
		{
			PlayerController(Other).UpdateURL("Class", string(DefaultPlayerClass), True);
			PlayerController(Other).ConsoleCommand("set" @ "Shell.MenuMulti MultiPlayerClass" @ DefaultPlayerClass);
		}
	}
	return bResult;
}

/* BelongsOnTeam()
returns true if PawnClass is allowed to be on this team
*/
function bool BelongsOnTeam(class<Pawn> PawnClass)
{
	local int i;

	for ( i=0; i<ArrayCount(AllowedTeamMembers); i++ )
		if ( PawnClass == AllowedTeamMembers[i] )
			return true;

	return false;
}

function SetBotOrders(Bot NewBot, RosterEntry R) 
{
    if( AI != None ) // gam
	    AI.SetBotOrders( NewBot, R );
}

function RemoveFromTeam(Controller Other)
{
	Super.RemoveFromTeam(Other);
	if ( AI != None )
		AI.RemoveFromTeam(Other);
/*
	for ( i=0; i<Roster.Length; i++ )
	FIXME- clear bTaken for the roster entry
*/	
}

// Returns true if the two specified teams represent a grudge match
static function bool IsGrudgeMatch(Actor Any, string Team1ClassName, string Team2ClassName)
{
	return
		TestGrudgeMatchDesc(
			Team1ClassName, GetIntDescForTeam(Any, Team1ClassName),
			Team2ClassName, GetIntDescForTeam(Any, Team2ClassName));
}

static function bool TestGrudgeMatchDesc(string Team1ClassName, string Team1Desc, string Team2ClassName, string Team2Desc)
{
	if (Team1Desc != "" && InStr(Team1Desc, Team2ClassName) != -1)
		return true;
	if (Team2Desc != "" && InStr(Team2Desc, Team1ClassName) != -1)
		return true;
	return false;
}

// Get the description associated with the specified team
static function string GetIntDescForTeam(Actor Any, string TeamClassName)
{
	local string NextTeam;
	local string NextDesc;
	local int i;

	Any.GetNextIntDesc("MultiBase.MpTeamInfo", 0, NextTeam, NextDesc); 
	while (NextTeam != TeamClassName)
	{
		i++;
		Any.GetNextIntDesc("MultiBase.MpTeamInfo", i, NextTeam, NextDesc);
	}

	return NextDesc;
}

// Find random teams
static function FindRandomTeams(Actor Any, bool bWantGrudgeMatch, out string Team1ClassName, out string Team2ClassName)
{
	local string NextTeam;
	local string NextDesc;
	local class<MpTeamInfo> NextClass;
	local array<TeamIntInfo> Teams;
	local int i, j, count;
	local bool bGrudge;
	
	Any.GetNextIntDesc("MultiBase.MpTeamInfo", 0, NextTeam, NextDesc); 
	while (NextTeam != "")
	{
		NextClass = class<MpTeamInfo>(DynamicLoadObject(NextTeam, class'class'));
		if (NextClass != None && NextClass.default.bSuitableForTeamGames && NextClass.default.bHighlyHomogeneous)
		{
			j = Teams.Length;
			Teams.insert(j, 1);
			Teams[j].ClassName = NextTeam;
			Teams[j].Class = NextClass;
			Teams[j].Grudges = NextDesc;
		}
		i++;
		Any.GetNextIntDesc("MultiBase.MpTeamInfo", i, NextTeam, NextDesc);
	}

	if (Teams.length >= 2)
	{
		while (count < 500)
		{
			i = Rand(Teams.length);
			j = Rand(Teams.length);
			if (bWantGrudgeMatch)
			{
				if (TestGrudgeMatchDesc(Teams[i].ClassName, Teams[i].Grudges, Teams[j].ClassName, Teams[j].Grudges))
					if (!AnySharedCharacters(Teams[i].Class, Teams[j].Class))
						break;
			}
			else
			{
				if (!AnySharedCharacters(Teams[i].Class, Teams[j].Class))
					break;
			}
			count++;
		}
	}
	else
	{
		Warn("Not enough teams available to choose two different ones!");
		i = 0;
		j = 0;
	}
	Team1ClassName = Teams[i].ClassName;
	Team2ClassName = Teams[j].ClassName;
}


// Fill the specified combo box with team names and classes that are compatible with the specified other team.
// If no other team is specified (use "") then all teams are added.
// Return value indicates whether any teams were filtered out.
static function bool FillComboWithCompatibleTeams(Actor Any, UWindowComboControl Combo, string OtherTeam, bool bTeamGame)
{
	local string NextTeam;
	local class<MpTeamInfo> NextClass;
	local class<MpTeamInfo> OtherTeamClass;
	local int i;
	local bool bFiltered;

	if (OtherTeam != "")
		OtherTeamClass = class<MpTeamInfo>(DynamicLoadObject(OtherTeam, class'class'));

	Combo.Clear();
	NextTeam = Any.GetNextInt("MultiBase.MpTeamInfo", 0); 
	while (NextTeam != "")
	{
		NextClass = class<MpTeamInfo>(DynamicLoadObject(NextTeam, class'class'));
		if (NextClass != None)
		{
			if (!(bTeamGame && !NextClass.default.bSuitableForTeamGames))
			{
				if (OtherTeamClass == None || !AnySharedCharacters(OtherTeamClass, NextClass))
					Combo.AddItem(NextClass.default.TeamName, NextTeam);
				else
					bFiltered = true;
			}
		}
		i++;
		NextTeam = Any.GetNextInt("MultiBase.MpTeamInfo", i);
	}
	Combo.Sort();

	return bFiltered;
}

// Returns true if the two specified teams share any characters
static function bool AnySharedCharacters(class<MpTeamInfo> Team1, class<MpTeamInfo> Team2)
{
	local int i, j;

	for (i = 0; i < ArrayCount(Team1.default.AllowedTeamMembers); i++)
	{
		if (Team1.default.AllowedTeamMembers[i] != None)
		{
			for (j = 0; j < ArrayCount(Team2.default.AllowedTeamMembers); j++)
			{
				if (Team1.default.AllowedTeamMembers[i] == Team2.default.AllowedTeamMembers[j])
					return true;
			}
		}
	}

	for (i = 0; i < Team1.default.Roster.length; i++)
	{
		if (Team1.default.Roster[i] != None && Team1.default.Roster[i].PawnClass != None)
		{
			for (j = 0; j < Team2.default.Roster.length; j++)
			{
				if (Team2.default.Roster[j] != None)
					if (Team1.default.Roster[i].PawnClass == Team2.default.Roster[j].PawnClass)
						return true;
			}
		}
	}

	return false;
}

defaultproperties
{
	TeamDescription="No description"
	TeamName="NoName"
	DesiredTeamSize=8
	bSuitableForTeamGames=true
	bHighlyHomogeneous=true
}
