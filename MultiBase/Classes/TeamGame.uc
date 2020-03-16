//=============================================================================
// TeamGame.
//=============================================================================
class TeamGame extends DeathMatch
	config;
	
var	MpTeamInfo				Teams[2];
var string BlueTeamName;
var string RedTeamName;

var bool					bScoreTeamKills;
var globalconfig bool		bBalanceTeams;			// bots balance teams
var globalconfig bool		bPlayersBalanceTeams;	// players balance teams

var globalconfig int		TeamSelectionMode;		// 0 = random teams, 1 = picked teams, anything else = map teams
var globalconfig string		PickedRedTeam;
var globalconfig string		PickedBlueTeam;

var bool					bSpawnInTeamArea;		// players spawn in marked team playerstarts

var config int				MaxTeamSize;
var config float			FriendlyFireScale;		//scale friendly fire damage by this value
var class<TeamAI>			TeamAIType[2];

function InitGameReplicationInfo()
{
	Super.InitGameReplicationInfo();

	if (MpGameReplicationInfo(GameReplicationInfo) != None)
		MpGameReplicationInfo(GameReplicationInfo).bGrudgeMatch = class'MpTeamInfo'.static.IsGrudgeMatch(self, RedTeamName, BlueTeamName);
}

function PostBeginPlay()
{
	local int i;

	if ( InitialBots > 0 )
	{
		Teams[0] = GetRedTeam(0.5 * InitialBots + 1);
		Teams[1] = GetBlueTeam(0.5 * InitialBots + 1);
	}
	else
	{
		Teams[0] = GetRedTeam(0);
		Teams[1] = GetBlueTeam(0);
	}
	for (i=0;i<2;i++)
	{
		Teams[i].TeamIndex = i;
		Teams[i].AI = Spawn(TeamAIType[i]);
		Teams[i].AI.Team = Teams[i];
		GameReplicationInfo.Teams[i] = Teams[i];
		log(Teams[i].TeamName$" AI is "$Teams[i].AI);
	}
	Teams[0].AI.EnemyTeam = Teams[1];
	Teams[1].AI.EnemyTeam = Teams[0];
	Teams[0].AI.SetObjectiveLists();
	Teams[1].AI.SetObjectiveLists();
	Super.PostBeginPlay();
}

// check if all other players are out
function bool CheckMaxLives(PlayerReplicationInfo Scorer)
{
    local Controller C;
    local PlayerReplicationInfo Living;
    local bool bNoneLeft;

    if ( MaxLives > 0 )
    {
		if ( (Scorer != None) && !Scorer.bOutOfLives )
			Living = Scorer;
        bNoneLeft = true;
        for ( C=Level.ControllerList; C!=None; C=C.NextController )
            if ( (C.PlayerReplicationInfo != None) && C.bIsPlayer
                && !C.PlayerReplicationInfo.bOutOfLives )
            {
				if ( Living == None )
					Living = C.PlayerReplicationInfo;
				else if ( (C.PlayerReplicationInfo != Living) && (C.PlayerReplicationInfo.Team != Living.Team) )
			   	{
    	        	bNoneLeft = false;
	            	break;
				}
            }
        if ( bNoneLeft )
        {
			if ( Living != None )
				EndGame(Living,"LastMan");
			else
				EndGame(Scorer,"LastMan");
			return true;
		}
    }
    return false;
}

function TeamInfo OtherTeam(TeamInfo Requester)
{
	if ( Requester == Teams[0] )
		return Teams[1];
	return Teams[0];
}

function OverrideInitialBots()
{
	InitialBots = Teams[0].OverrideInitialBots(InitialBots,Teams[1]);
}

function PreLoadBot()
{
	if ( Teams[0].Roster.Length < 0.5 * InitialBots + 1 )
		Teams[0].AddRandomPlayer();
	if ( Teams[1].Roster.Length < 0.5 * InitialBots + 1 )
		Teams[1].AddRandomPlayer();
}

/* create a player team, and fill from the team roster
*/
function MpTeamInfo GetBlueTeam(int TeamBots)
{
	local class<MpTeamInfo> RosterClass;
	local MpTeamInfo Roster;

/*    if ( CurrentGameProfile != None )
	{
		RosterClass = class<MpTeamInfo>(DynamicLoadObject(DefaultEnemyRosterClass,class'Class'));
		Roster = Spawn(RosterClass);
		Roster.FillPlayerTeam(CurrentGameProfile);
		return Roster;
	}
	else*/ if ( BlueTeamName != "" )
		RosterClass = class<MpTeamInfo>(DynamicLoadObject(BlueTeamName,class'Class'));
	else
		RosterClass = class<MpTeamInfo>(DynamicLoadObject(DefaultEnemyRosterClass,class'Class'));
	Roster = spawn(RosterClass);
	Roster.Initialize(TeamBots);
	return Roster;
}

function MpTeamInfo GetRedTeam(int TeamBots)
{
	EnemyRosterName = RedTeamName;
	return Super.GetBotTeam(TeamBots);
}

// Parse options for this game...
event InitGame( out string Options, out string Error )
{
	local string InOpt;
	local class<TeamAI> InType;
	local string RedOpt, BlueOpt;

	Super.InitGame(Options, Error);

	bSpawnInTeamArea = bSpawnInTeamArea || LevelRules.GetSpawnInTeamArea();

	InOpt = ParseOption( Options, "RedTeamAI");
	if ( InOpt != "" )
	{
		log("RedTeamAI: "$InOpt);
		InType = class<TeamAI>(DynamicLoadObject(InOpt, class'Class'));
		if ( InType != None )
			TeamAIType[0] = InType;
	}

	InOpt = ParseOption( Options, "BlueTeamAI");
	if ( InOpt != "" )
	{
		log("BlueTeamAI: "$InOpt);
		InType = class<TeamAI>(DynamicLoadObject(InOpt, class'Class'));
		if ( InType != None )
			TeamAIType[1] = InType;
	}

	// teams specified in options override any team config settings
	RedOpt = ParseOption( Options, "RedTeam");
	BlueOpt = ParseOption( Options, "BlueTeam");
	if (RedOpt != "" && BlueOpt != "")
	{
		// Use teams specified in options
		RedTeamName = RedOpt;
		BlueTeamName = BlueOpt;
	}
	else if (TeamSelectionMode == 1)
	{
		// Use picked teams
		RedTeamName = PickedRedTeam;
		BlueTeamName = PickedBlueTeam;
	}
	else if (TeamSelectionMode == 2)
	{
		// Use map teams
		RedTeamName = LevelRules.GetTeamRosterName(0);
		BlueTeamName = LevelRules.GetTeamRosterName(1);
	}
	if (TeamSelectionMode == 0 || RedTeamName == "" || BlueTeamName == "")
	{
		// Use random teams, choose a grudge match every so often
		class'MpTeamInfo'.static.FindRandomTeams(self, FRand() < 0.3, RedTeamName, BlueTeamName);
	}
	log("TeamGame::InitGame : RedTeamName="$RedTeamName$" BlueTeamName="$BlueTeamName);

	InOpt = ParseOption( Options, "FF");
	if ( InOpt != "" )
		FriendlyFireScale = FMin(1.0,float(InOpt));
//	if ( CurrentGameProfile != None )
//	{
//		FriendlyFireScale = 0.0;
//	}

	InOpt = ParseOption( Options, "FriendlyFireScale");
	if ( InOpt != "" )
		FriendlyFireScale = FMin(1.0,float(InOpt));
//	if ( CurrentGameProfile != None )
//	{
//		FriendlyFireScale = 0.0;
//	}

	InOpt = ParseOption(Options, "BalanceTeams");
	if ( InOpt != "")
	{
		bBalanceTeams = bool(InOpt);
		bPlayersBalanceTeams = bBalanceTeams;
	}
	log("TeamGame::InitGame : bBalanceTeams"@bBalanceTeams);
}

function bool CanShowPathTo(PlayerController P, int TeamNum)
{
	return true;
}

function RestartPlayer( Controller aPlayer )
{
	local TeamInfo BotTeam, OtherTeam;

	if ( bBalanceTeams && (Bot(aPlayer) != None) && (!bCustomBots || (Level.NetMode != NM_Standalone)) )
	{
		BotTeam = aPlayer.PlayerReplicationInfo.Team;
		if ( BotTeam == Teams[0] )
			OtherTeam = Teams[1];
		else
			OtherTeam = Teams[0];

		if ( OtherTeam.Size < BotTeam.Size - 1 )
		{
			aPlayer.Destroy();
			return;
		}
	}
	Super.RestartPlayer(aPlayer);
}

/* For TeamGame, tell teams about kills rather than each individual bot
*/
function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn)
{
	Teams[0].AI.NotifyKilled(Killer,Killed,KilledPawn);
	Teams[1].AI.NotifyKilled(Killer,Killed,KilledPawn);
}

function class<Pawn> GetDefaultPlayerClass(Controller C)
{
	return MpTeamInfo(C.PlayerReplicationInfo.Team).DefaultPlayerClass;
}

function IncrementGoalsScored(PlayerReplicationInfo PRI)
{
	PRI.GoalsScored += 1;
// RWS CHANGE: Not doing this
//	if ( (PRI.GoalsScored == 3) && (MpPlayer(PRI.Owner) != None) )
//		MpPlayer(PRI.Owner).ClientDelayedAnnouncement(HatTrickSound,30);
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local Controller P;
	local PlayerController player;
    local bool bLastMan;

	if ( bOverTime )
	{
		if ( Numbots + NumPlayers == 0 )
			return true;
		bLastMan = true;
		for ( P=Level.ControllerList; P!=None; P=P.nextController )
			if ( (P.PlayerReplicationInfo != None) && !P.PlayerReplicationInfo.bOutOfLives )
			{
				bLastMan = false;
				break;
			}
		if ( bLastMan )
			return true;
	}

    bLastMan = ( Reason ~= "LastMan" );

	if ( !bLastMan && (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
		return false;

	if ( bTeamScoreRounds )
	{
		if ( Winner != None )
			Winner.Team.Score += 1;
	}
	else if ( !bLastMan && (Teams[1].Score == Teams[0].Score) )
	{
		// tie
		if ( !bOverTimeBroadcast )
		{
			StartupStage = 7;
			PlayStartupMessage();
			bOverTimeBroadcast = true;
		}
		return false;
	}
	if ( bLastMan )
		GameReplicationInfo.Winner = Winner.Team;
	else if ( Teams[1].Score > Teams[0].Score )
		GameReplicationInfo.Winner = Teams[1];
	else
		GameReplicationInfo.Winner = Teams[0];

	if ( Winner == None )
	{
		for ( P=Level.ControllerList; P!=None; P=P.nextController )
			if ( (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == GameReplicationInfo.Winner)
				&& ((Winner == None) || (P.PlayerReplicationInfo.Score > Winner.Score)) )
			{
				Winner = P.PlayerReplicationInfo;
			}
	}

	EndTime = Level.TimeSeconds + EndTimeDelay;

	if ( Winner != None )
	{
		EndGameFocus = Controller(Winner.Owner).Pawn;
		if (MpTeamInfo(GameReplicationInfo.Winner).TeamIndex == 0)
		if (Winner.Team.TeamIndex == 0)
		{
			CheerleaderClass1 = class'CheerleadersRed';
			CheerleaderClass2 = class'CheerleadersRed2';
		}
		else
		{
			CheerleaderClass1 = class'CheerleadersBlue';
			CheerleaderClass2 = class'CheerleadersBlue2';
		}
	}
	if ( EndGameFocus != None )
		EndGameFocus.bAlwaysRelevant = true;

	for ( P=Level.ControllerList; P!=None; P=P.nextController )
	{
		player = PlayerController(P);
		if ( Player != None )
		{
			PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == GameReplicationInfo.Winner));
			player.ClientSetBehindView(true);
			if ( EndGameFocus != None )
            {
				Player.ClientSetViewTarget(EndGameFocus);
                Player.SetViewTarget(EndGameFocus);
            }
			player.ClientGameEnded();
//			if ( CurrentGameProfile != None )
//				CurrentGameProfile.bWonMatch = (Player.PlayerReplicationInfo.Team == GameReplicationInfo.Winner);
		}
		P.GameHasEnded();
	}
	return true;
}

function Logout(Controller Exiting)
{
	Super.Logout(Exiting);
	if ( Exiting.PlayerReplicationInfo.bOnlySpectator )
		return;
	ClearOrders(Exiting);
}

function ClearOrders(Controller Leaving)
{
	Teams[0].AI.ClearOrders(Leaving);
	Teams[1].AI.ClearOrders(Leaving);
}

//-------------------------------------------------------------------------------------
// Level gameplay modification

function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
{
	if ( ViewTarget == None )
		return false;
	if ( bOnlySpectator )
	{
		if ( Controller(ViewTarget) != None )
			return ( (Controller(ViewTarget).PlayerReplicationInfo != None)
				&& !Controller(ViewTarget).PlayerReplicationInfo.bOnlySpectator );
		return true;
	}
	if ( Controller(ViewTarget) != None )
		return ( (Controller(ViewTarget).PlayerReplicationInfo != None)
				&& !Controller(ViewTarget).PlayerReplicationInfo.bOnlySpectator
				&& (Controller(ViewTarget).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team) );
	return ( (Pawn(ViewTarget) != None) && Pawn(ViewTarget).IsPlayerPawn() 
		&& (Pawn(ViewTarget).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team) );
}

//------------------------------------------------------------------------------
// Game Querying.

function string GetRules()
{
	local string ResultSet;
	ResultSet = Super.GetRules();

	// Only send bots balance teams if they're enabled through bAutoFillBots
	if(bAutoFillBots)
		ResultSet = ResultSet$"\\balanceteams\\"$bBalanceTeams;
	ResultSet = ResultSet$"\\playersbalanceteams\\"$bPlayersBalanceTeams;
	ResultSet = ResultSet$"\\friendlyfire\\"$int(FriendlyFireScale*100)$"%";

	return ResultSet;
}

//------------------------------------------------------------------------------

function MpTeamInfo GetBotTeam(optional int TeamBots)
{
	local int first, second;

	if ( (Level.NetMode == NM_Standalone) || !bBalanceTeams )
	{
	    if ( Teams[0].AllBotsSpawned() )
	    {
			bBalanceTeams = false;
		    if ( !Teams[1].AllBotsSpawned() )
			    return Teams[1];
	    }
	    else if ( Teams[1].AllBotsSpawned() )
	    {
			bBalanceTeams = false;
		    return Teams[0];
		}
	}

	second = 1;

	// always imbalance teams in favor of bot team in single player
	if ( (StandalonePlayer != None ) && (StandalonePlayer.PlayerReplicationInfo.Team.TeamIndex == 1) )
	{
		first = 1;
		second = 0;
	}
	if ( Teams[first].Size < Teams[second].Size )
		return Teams[first];
	else
		return Teams[second];
}

function MpTeamInfo FindTeamFor(Controller C)
{
	if ( Teams[0].BelongsOnTeam(C.Pawn.Class) )
		return Teams[0];
	if ( Teams[1].BelongsOnTeam(C.Pawn.Class) )
		return Teams[1];
	return GetBotTeam();
}

/* Return a picked team number if none was specified
*/
function byte PickTeam(byte num, Controller C)
{
	local MpTeamInfo SmallTeam, BigTeam, NewTeam;
	local Controller B;
	local bool bForceSmall;
	
	SmallTeam = Teams[0];
	BigTeam = Teams[1];

	if ( SmallTeam.Size > BigTeam.Size )
	{
		SmallTeam = Teams[1];
		BigTeam = Teams[0];
	}

	if ( num < 2 )
		NewTeam = Teams[num];

	if ( bPlayersBalanceTeams && (SmallTeam.Size < BigTeam.Size) && ((Level.NetMode != NM_Standalone) || (PlayerController(C) == None)) )
	{
		bForceSmall = true;
		// if any bots on big team, no need to go on small team
		for ( B=Level.ControllerList; B!=None; B=B.NextController )
		{
			if ( (B.PlayerReplicationInfo != None) && B.PlayerReplicationInfo.bBot && (B.PlayerReplicationInfo.Team == BigTeam) )
			{
				bForceSmall = false;
				break;
			}
		}
		if ( bForceSmall )
			NewTeam = SmallTeam;
	}
	else if ( bPlayersBalanceTeams && (SmallTeam.Size == BigTeam.Size) && ((Level.NetMode != NM_Standalone) || (PlayerController(C) == None)) )
	{	// check case of even teams - if so, dont switch teams
		if(num == 0)
			NewTeam = Teams[1];
		if(num == 1)
			NewTeam = Teams[0];
	}

	if ( (NewTeam == None) || (NewTeam.Size >= MaxTeamSize) )
		NewTeam = SmallTeam;

	return NewTeam.TeamIndex;
}

/* ChangeTeam()
*/
function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
	local MpTeamInfo NewTeam;

	if ( bMustJoinBeforeStart && GameReplicationInfo.bMatchHasBegun )
		return false;	// only allow team changes before match starts

	if ( Other.IsA('PlayerController') && Other.PlayerReplicationInfo.bOnlySpectator )
	{
		Other.PlayerReplicationInfo.Team = None;
		return true;
	}

	NewTeam = Teams[PickTeam(num, Other)];

	if ( NewTeam.Size >= MaxTeamSize )
		return false;	// no room on either team

	// check if already on this team
	if ( Other.PlayerReplicationInfo.Team == NewTeam )
		return false;

	Other.StartSpot = None;

	if ( Other.PlayerReplicationInfo.Team != None )
		Other.PlayerReplicationInfo.Team.RemoveFromTeam(Other);

	if ( NewTeam.AddToTeam(Other) )
	{
		BroadcastLocalizedMessage( GameMessageClass, 3, Other.PlayerReplicationInfo, None, NewTeam );

		if ( bNewTeam && PlayerController(Other)!=None )
			GameEvent("TeamChange",""$num,Other.PlayerReplicationInfo);
	}
	// CRK: Write new team to ini to remember it
	if(Other.IsA('PlayerController'))
		PlayerController(Other).UpdateURL("Team", string(NewTeam.TeamIndex), True);
	return true;
}

/* Rate whether player should choose this NavigationPoint as its start
*/
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
	local PlayerStart P;

	P = PlayerStart(N);
	if ( P == None )
		return -10000000;
	if ( bSpawnInTeamArea && (Team != P.TeamNumber) )
		return -9000000;

	return Super.RatePlayerStart(N,Team,Player);
}

/* CheckScore()
see if this score means the game ends
*/
function CheckScore(PlayerReplicationInfo Scorer)
{
	if ( CheckMaxLives(Scorer) )
		return;

    if ( (GameRulesModifiers != None) && GameRulesModifiers.CheckScore(Scorer) )
		return;

    if (  !bOverTime && (GoalScore == 0) )
		return;
    if ( (Scorer != None) && (Scorer.Team != None) && (Scorer.Team.Score >= GoalScore) )
		EndGame(Scorer,"teamscorelimit");

    if ( (Scorer != None) && bOverTime )
		EndGame(Scorer,"timelimit");
}

function ScoreKill(Controller Killer, Controller Other)
{
	local Pawn Target;
	local int OldOtherScore;

	// Store for later check because the following ScoreKill may reduce it
	if(Other != None
		&& Other.PlayerReplicationInfo != None)
		OldOtherScore = Other.PlayerReplicationInfo.Score;

	if ( (Killer == None) || (Killer == Other) || !Other.bIsPlayer || !Killer.bIsPlayer
		|| (Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team) )
	{
		Super.ScoreKill(Killer, Other);
	}
	else
		GameRulesModifiers.ScoreKill(Killer, Other);

	if ( !bScoreTeamKills )
	{
		if ( Other.bIsPlayer && (Killer != None) && Killer.bIsPlayer && (Killer != Other)
			&& (Killer.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) )
		{
			Killer.PlayerReplicationInfo.Score -= 1;
			ScoreEvent(Killer.PlayerReplicationInfo, -1, "team_frag");
		}
		if ( MaxLives > 0 )
			CheckScore(Killer.PlayerReplicationInfo);
		return;
	}
	if ( Other.bIsPlayer )
	{
		// Suicide--decrement Other team
		// Don't count suicides for bots--it makes our team scores go negative
		// as they log out and other people log in--very annoying.
		if (Bot(Other) == None
			&& ((Killer == None) 
				|| (Killer == Other)) )
		{
			Other.PlayerReplicationInfo.Team.Score -= 1;
			TeamScoreEvent(Other.PlayerReplicationInfo.Team.TeamIndex, 1, "team_frag");
		}
		// One guy kills the other side--credit Killer team and decrease Other team
		// if their positive.
		else if ( Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team )
		{
			Killer.PlayerReplicationInfo.Team.Score += 1;
			// Only in the case of non-suicides, when we actually got killed by someone (other
			// getting killed by Killer) do we decrement the team score of Other, if it's above
			// 0, because like DM, negative scores suck for the most part. (explained in MpGameInfo)
			// Also, make sure to only lower the score if a player who's *not negative* dies. 
			// If a sucky player has 0 and keeps dying and a good player has scored some frags, 
			// then the sucky player will pull all the points out of the team score, otherwise.
			if (Other.PlayerReplicationInfo.Team.Score > 0
				&& OldOtherScore > 0)	// Store this earlier because Super.ScoreKill may reduce it
				Other.PlayerReplicationInfo.Team.Score -= 1;
			TeamScoreEvent(Killer.PlayerReplicationInfo.Team.TeamIndex, 1, "tdm_frag");
		}
		// Friendly fire--decrement Killer side when you kill your own.
		else if ( FriendlyFireScale > 0 )
		{
			Killer.PlayerReplicationInfo.Score -= 1;
			Killer.PlayerReplicationInfo.Team.Score -= 1;
			TeamScoreEvent(Killer.PlayerReplicationInfo.Team.TeamIndex, 1, "team_frag");
		}
	}

	// check score again to see if team won
    if ( (Killer != None) && bScoreTeamKills )
		CheckScore(Killer.PlayerReplicationInfo);
}

function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
	local TeamInfo InjuredTeam, InstigatorTeam;

	if ( instigatedBy == None )
		return Super.ReduceDamage( Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );

	InjuredTeam = Injured.GetTeam();
// Originally bIgnoreTeams was implemented because at the office we didn't like friendlyfire, 
// but we felt like splash damaged weapons like grenades and anthrax should hurt everyone. 
// We put this check in so that even with FriendlyFire at 0, you still hurt someone with
// a rocket. Big mistake.. because that let the asshole teamkillers to run around and harass
// people on servers trying to play legitimate games. In the end, we're taking it out
// and linking splash damage *and* bullet damage weapons to the FriendlyFire slider. 
// Now if it's at 0, nothing hurts your teammate, but at 100, all weapons hurt
// with 100% damage, and so forth. 
//	if(class<P2Damage>(DamageType) == None)
//		|| !class<P2Damage>(DamageType).default.bIgnoreTeams)
		InstigatorTeam = InstigatedBy.GetTeam();
	if ( instigatedBy != injured )
	{
		if ( (InjuredTeam != None) && (InstigatorTeam != None) )
		{
			if ( InjuredTeam == InstigatorTeam )
			{
				// We like the momentum to be the same on either side regardless of teams kills/not
				//Momentum *= 0.3;
				if ( Bot(injured.Controller) != None )
					Bot(Injured.Controller).YellAt(instigatedBy);
				if ( FriendlyFireScale==0.0 )
				{
					if ( GameRulesModifiers != None )
						return GameRulesModifiers.NetDamage( Damage, 0,injured,instigatedBy,HitLocation,Momentum,DamageType );
					else
						return 0;
				}
				Damage *= FriendlyFireScale;
			}
			else if ( !injured.IsHumanControlled() && (injured.Controller != None)
					&& (injured.PlayerReplicationInfo != None) && (injured.PlayerReplicationInfo.HasFlag != None) )
				injured.Controller.SendMessage(None, 'OTHER', injured.Controller.GetMessageIndex('INJURED'), 15, 'TEAM');
		}
	}
	return Super.ReduceDamage( Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
}

function bool SameTeam(Controller a, Controller b)
{
    if(( a == None ) || ( b == None ))
        return( false );

    return (a.PlayerReplicationInfo.Team.TeamIndex == b.PlayerReplicationInfo.Team.TeamIndex);
}

function bool TooManyBots(Controller botToRemove)
{
	if ( (botToRemove.PlayerReplicationInfo != None)
		&& (botToRemove.PlayerReplicationInfo.Team != None) )
	{
		if ( botToRemove.PlayerReplicationInfo.Team == Teams[0] )
		{
			if ( Teams[0].Size < Teams[1].Size )
				return false;
		}
		else if ( Teams[1].Size < Teams[0].Size )
			return false;
	}
    return Super.TooManyBots(botToRemove);
}

function PlayEndOfMatchMessage()
{
	local controller C;
	local int team, otherteam;

	for ( C = Level.ControllerList; C != None; C = C.NextController )
	{
		if ( C.IsA('MpPlayer') )
		{
			if (C.PlayerReplicationInfo.Team != None)
			{
				if (Teams[0].Score > Teams[1].Score)
					MpPlayer(C).PlayAnnouncement(Teams[0].default.TeamWinSound,1,true);
				else
					MpPlayer(C).PlayAnnouncement(Teams[1].default.TeamWinSound,1,true);
			}
		}
	}
}

event PostLogin( PlayerController NewPlayer, string Options )
{
	Super.PostLogin( NewPlayer, Options );

	if ( NewPlayer.PlayerReplicationInfo.Team != None )
		GameEvent("TeamChange",""$NewPlayer.PlayerReplicationInfo.Team.TeamIndex,NewPlayer.PlayerReplicationInfo);
}

defaultproperties
{
	GoalScore=60
	bPlayersBalanceTeams=true
	//bWeaponStay=true  // we don't like this in our team games, plus false helps stop cheating with pickups
	bScoreTeamKills=true
	bBalanceTeams=true
	bMustJoinBeforeStart=false
	MaxTeamSize=16
	bCanChangeSkin=False
	bTeamGame=True
	BeaconName="Team"
	GameName="Team Deathmatch"
    NetWait=2
	TeamAIType(0)=class'MultiBase.TeamAI'
	TeamAIType(1)=class'MultiBase.TeamAI'
	MaxLives=0
	SettingsMenuType="UTBrowser.UTTDMSettingsSClient"
	TeamSelectionMode=0
}
