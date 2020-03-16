//=============================================================================
// DeathMatch
//=============================================================================
class DeathMatch extends MPGameInfo
	config;

var globalconfig int			NetWait;				// time to wait for players in netgames w/ bNetReady (typically team games)
var globalconfig int			MinNetPlayers;			// how many players must join before net game will start
var globalconfig int			RestartWait;

var globalconfig bool			bTournament;			// number of players must equal maxplayers for game to start
var config bool					bPlayersMustBeReady;	// players must confirm ready for game to start
var config bool					bForceRespawn;
var config bool					bAdjustSkill;
var bool						bWaitForNetPlayers;		// wait until more than MinNetPlayers players have joined before starting match
var bool						bMustJoinBeforeStart;	// players can only spectate if they join after the game starts
var bool						bStartedCountDown;
var bool						bFinalStartup;
var bool						bOverTimeBroadcast;
var bool						bKillBots;
var bool						bCustomBots;

var byte						StartupStage;			// what startup message to display
var	int							RemainingTime, ElapsedTime;
var int							CountDown;
var float						AdjustedDifficulty;
var int							PlayerKills, PlayerDeaths;
var class<SquadAI>				DMSquadClass;			// squad class to use for bots in DM games (no team)
var class<LevelGameRules>		LevelRulesClass;
var LevelGameRules				LevelRules;				// level designer overriding of game settings (hook for mod authors)
var config float				SpawnProtectionTime;
var MPTeamInfo					EnemyRoster;
var string						EnemyRosterName;
var string						DefaultEnemyRosterClass;

// Bot related info
var int							RemainingBots;
var int							InitialBots;
var localized string			BotPrefix;

var NavigationPoint				LastPlayerStartSpot;	// last place player looking for start spot started from
var NavigationPoint				LastStartSpot;			// last place any player started from

var int							NameNumber;				// append to ensure unique name if duplicate player name change requested

var localized string			NextCharacterMsg;

var Sound						EndGameSound[2];        // end game sounds

var actor						EndGameFocus;
var PlayerController			StandalonePlayer;

var globalconfig bool			bUsePickedRoster;
var globalconfig string			PickedRoster;

var string						MatchIntroClassName;	// name of class to use for team intro
var class<MatchIntro>			MatchIntroClass;		// actual class for team intro


var string						ExplosionClassName;

var Sound						PartyMusic;
var float						WaitForWinnerAnnouncement;
var float						WaitForParty;
var class<Cheerleaders>			CheerleaderClass1;
var class<Cheerleaders>			CheerleaderClass2;
//var (PawnAttributes) export editinline array< class<Inventory> > GameBaseEquipment;		// base equipment is determined by game info in MP--not pawn
// This is setup in struct form, because a array<class<>> thing wouldn't work with the compiler
struct GameWeaponClassStruct
{
	var() class<Inventory> weapclass;
};
var () export editinline array<GameWeaponClassStruct> GameBaseEquipment;

var int							CountdownWaitForPlayers;		// Coutdown used when bPlayersMustBeReady is set
									// and a majority of players are ready. This is to keep assholes from keeping
									// the game from starting anyways. GrabBag defaults to bPlayersMustBeReady to true
									// so it's especially useful there. If a single person out say, six, doesn't
									// click ready but everyone else is ready to go then it will start after this
									// countdown is up.
var bool						bCountdownWaitForPlayers;	// True means the above countdown is executing
var array<string>				MutList; // dynamic list of mutator class names we want this game type to start with


function PostBeginPlay()
{
	if ( bAlternateMode )
		GoreLevel = 2;

	Super.PostBeginPlay();
	GameReplicationInfo.RemainingTime = RemainingTime;
    GetBotTeam(InitialBots);
//	if ( CurrentGameProfile == None )
		OverrideInitialBots();

	// Set Team Roster in GRI
	if(GameReplicationInfo.Teams[0] == None && EnemyRoster != None && MpGameReplicationInfo(GameReplicationInfo) != None)
		MpGameReplicationInfo(GameReplicationInfo).DMRoster = EnemyRoster;
}

function OverrideInitialBots()
{
	InitialBots = GetBotTeam().OverrideInitialBots(InitialBots,None);
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	ElapsedTime = NetWait - 3;
	bWaitForNetPlayers = ( Level.NetMode != NM_StandAlone );
	bStartedCountDown = false;
	bFinalStartup = false;
	CountDown = Default.Countdown;
	CountdownWaitForPlayers = default.CountdownWaitForPlayers;
	bCountdownWaitForPlayers=false;
	RemainingTime = 60 * TimeLimit;
    //log("Reset() RemainingTime:"$RemainingTime$" TimeLimit: "$TimeLimit); // sjs
	GotoState('PendingMatch');
}

/* CheckReady()
If tournament game, make sure that there is a valid game winning criterion
*/
function CheckReady()
{
	if ( (GoalScore == 0) && (TimeLimit == 0) )
	{
		TimeLimit = 20;
		RemainingTime = 60 * TimeLimit;
	}
}

function InitLogging()
{
	Super.InitLogging();
}

// Parse options for this game...
event InitGame( out string Options, out string Error )
{
	local string InOpt;
	local int i;

	// find Level's LevelGameRules actor if it exists
	ForEach AllActors(class'LevelGameRules', LevelRules)
		break;
	if ( LevelRules == None )
	{
		LevelRules = spawn(LevelRulesClass);
		log("DeathMatch::InitGame : No LevelGameRules in map, spawned "$LevelRules);
	}

	Super.InitGame(Options, Error);

	log(self$" Checking for game default mutators");
	// Add in our special mutators for this game
	for(i=0; i<MutList.Length; i++)
	{
		log(self$" Adding "$MutList[i]);
		AddMutator(MutList[i], false);
	}

	SetGameSpeed(GameSpeed);
    MaxLives = Max(0,GetIntOption( Options, "MaxLives", MaxLives ));
    if ( MaxLives > 0 )
		bForceRespawn = true;
    GoalScore = Max(0,GetIntOption( Options, "GoalScore", GoalScore ));
    TimeLimit = Max(0,GetIntOption( Options, "TimeLimit", TimeLimit ));

    InOpt = ParseOption( Options, "AutoFillBots");
    if ( InOpt != "" )
    {
        bAutoFillBots = bool(InOpt);
        log("DeathMatch::InitGame : bAutoFillBots: "$bAutoFillBots);
    }
    InOpt = ParseOption( Options, "AutoAdjust");
    if ( InOpt != "" )
    {
        bAdjustSkill = bool(InOpt);
        log("DeathMatch::InitGame : Adjust skill "$bAdjustSkill);
    }
    InOpt = ParseOption( Options, "PlayersMustBeReady");
    if ( InOpt != "" )
    {
        bPlayersMustBeReady = bool(InOpt);
    	log("DeathMatch::InitGame : PlayerMustBeReady: "$bPlayersMustBeReady);
    }

 	EnemyRosterName = ParseOption( Options, "DMTeam");
	if ( EnemyRosterName == "" )
	{
		if (bUsePickedRoster)
			EnemyRosterName = PickedRoster;
		else
			EnemyRosterName = LevelRules.GetRosterName();
	}
	log("DeathMatch::InitGame : EnemyRosterName="$EnemyRosterName);

	if (bAutoFillBots)
    {
/*        MaxPlayers = Level.IdealPlayerCountMax;
        MinPlayers = GetMinPlayers();

        if ((MinPlayers & 1) == 1)
            MinPlayers++;

        if( MinPlayers < 2 )
            MinPlayers = 2;
*/
        InitialBots = Max(0,MinPlayers - 1);
    }
    else
    {
		// If not using bots, override minplayers + initialbots to 0
		MinPlayers = 0;
		InitialBots = 0;
		MinPlayers = Clamp(GetIntOption( Options, "MinPlayers", MinPlayers ),0,8);
		InitialBots = Clamp(GetIntOption( Options, "NumBots", InitialBots ),0,8);
	}

	RemainingTime = 60 * TimeLimit;

    InOpt = ParseOption( Options, "WeaponStay");
    if ( InOpt != "" )
    {
        bWeaponStay = bool(InOpt);
        log("DeathMatch::InitGame : WeaponStay: "$bWeaponStay);
    }

	if ( bTournament )
		bTournament = (GetIntOption( Options, "Tournament", 1 ) > 0);
	else
		bTournament = (GetIntOption( Options, "Tournament", 0 ) > 0);

	if ( bTournament ) 
		CheckReady();
	bWaitForNetPlayers = ( Level.NetMode != NM_StandAlone );

    AdjustedDifficulty = BotDifficulty;
}

function int GetMinPlayers()
{
//	if (CurrentGameProfile == None)
		return (Level.IdealPlayerCountMax + Level.IdealPlayerCountMin)/2;

//	return Level.SinglePlayerTeamSize*2;
}

/* AcceptInventory()
Examine the passed player's inventory, and accept or discard each item
* AcceptInventory needs to gracefully handle the case of some inventory
being accepted but other inventory not being accepted (such as the default
weapon).  There are several things that can go wrong: A weapon's
AmmoType not being accepted but the weapon being accepted -- the weapon
should be killed off. Or the player's selected inventory item, active
weapon, etc. not being accepted, leaving the player weaponless or leaving
the HUD inventory rendering messed up (AcceptInventory should pick another
applicable weapon/item as current).
*/
function AcceptInventory(pawn PlayerPawn)
{
    while ( PlayerPawn.Inventory != None )
        PlayerPawn.Inventory.Destroy();

	PlayerPawn.Weapon = None;
	PlayerPawn.SelectedItem = None;
	AddDefaultInventory( PlayerPawn );
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local Controller P, NextController;
	local PlayerController Player;
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

	if ( Winner == None )
	{
		// find winner
		for ( P=Level.ControllerList; P!=None; P=P.nextController )
			if ( P.bIsPlayer && !P.PlayerReplicationInfo.bOutOfLives
				&& ((Winner == None) || (P.PlayerReplicationInfo.Score >= Winner.Score)) )
			{
				Winner = P.PlayerReplicationInfo;
			}
	}

    // check for tie
    if ( !bLastMan )
    {
		for ( P=Level.ControllerList; P!=None; P=P.nextController )
		{
			if ( P.bIsPlayer &&
				(Winner != P.PlayerReplicationInfo) &&
				(P.PlayerReplicationInfo.Score == Winner.Score)
				&& !P.PlayerReplicationInfo.bOutOfLives )
			{
				if ( !bOverTimeBroadcast )
				{
					StartupStage = 7;
					PlayStartupMessage();
					bOverTimeBroadcast = true;
				}
				return false;
			}
		}
	}

    EndTime = Level.TimeSeconds + EndTimeDelay;
	GameReplicationInfo.Winner = Winner;

    EndGameFocus = Controller(Winner.Owner).Pawn;
    if ( EndGameFocus != None )
		EndGameFocus.bAlwaysRelevant = true;
    for ( P=Level.ControllerList; P!=None; P=NextController )
	{
		Player = PlayerController(P);
		if ( Player != None )
		{
			PlayWinMessage(Player, (Player.PlayerReplicationInfo == Winner));
			Player.ClientSetBehindView(true);
            if ( EndGameFocus != None )
            {
				Player.ClientSetViewTarget(EndGameFocus);
                Player.SetViewTarget(EndGameFocus);
            }
			Player.ClientGameEnded();
		}
        NextController = P.NextController;
		P.GameHasEnded();
	}
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Party with postal babes at the end. They usually appear on the either
// side of the winner, but if some collision tests fail they can appear
// in front and behind him. 
// If this is a GrabBag game though, the party is bigger around the dude and doesn't let girls
// be in the back--in hopes that the girls don't clip with the bag.
///////////////////////////////////////////////////////////////////////////////
function PartyForTheWinner(Actor Focus)
{
	local rotator rot;
	local vector loc, starttest, endtest, gloc1, gloc2, newnormal;
	local class<actor> ExplosionClass;
	local bool bgirl1, bgirl2, bfail, bBagParty;

	const SIDE_START_CHECK	=	120;
	const SIDE_END_CHECK	=	160;
	const SIDE_DIST_USE		=	60;

	const FRONT_START_CHECK	=	160;
	const FRONT_DIST_USE	=	100;
	const UP_DOWN_TEST		=	75;

	if(Focus != None)
	{
		rot = Focus.rotation;

		if (ExplosionClassName != "")
			ExplosionClass = class<actor>(DynamicLoadObject(ExplosionClassName, class'class'));

		bBagParty = (GrabBagGame(self) != None);
		
		// Do some collision to pick the best spots to put the two girls. Try girl 1 on the left
		// and the front, girl 2 on the right and back. If they fail both tests, don't put the
		// girl at all, so it doesn't look too bad. The music will always play regardless.
		bgirl1=true;
		bgirl2=true;
		// left side/forwards
		rot.yaw += 16384;
		endtest = Focus.Location + (vector(rot) * SIDE_START_CHECK);
		if(bBagParty)
		{
			endtest = Focus.Location + (vector(rot) * SIDE_END_CHECK);
			if(Trace(loc, newnormal, endtest, Focus.Location, false) == None)
				loc = endtest;

			if(VSize(loc - Focus.Location) >= SIDE_START_CHECK)
				// Move her back a little from where we checked
				gloc1 = loc - (vector(rot) * SIDE_DIST_USE);
			else
				bfail=true;
		}
		else if(FastTrace(Focus.Location, starttest))
		{
			// Move it closer to the dude for the one we actually use
			gloc1=Focus.location + (vector(rot) * SIDE_DIST_USE);
		}
		else
			bfail=true;
		if(bfail)  // if left side didn't work, check to put her in front
		{
			// Use special Front values still his gun could be sticking into
			// the girl in certain poses.
			loc = Focus.location + (vector(Focus.Rotation) * FRONT_START_CHECK);
			if(FastTrace(Focus.Location, loc))
				// Move it closer to the dude for the one we actually use
				gloc1=Focus.location + (vector(Focus.Rotation) * FRONT_DIST_USE);
			else
				bgirl1=false;	// failed both tests, too close to make her
		}

		// right side/backwards
		bfail=false;
		rot.yaw -= 32768;
		endtest = Focus.Location + (vector(rot) * SIDE_START_CHECK);
		if(bBagParty)
		{
			endtest = Focus.Location + (vector(rot) * SIDE_END_CHECK);
			if(Trace(loc, newnormal, endtest, Focus.Location, false) == None)
				loc = endtest;
			if(VSize(loc - Focus.Location) >= SIDE_START_CHECK)
				// Move her back a little from where we checked
				gloc2 = loc - (vector(rot) * SIDE_DIST_USE);
			else
				bfail=true;
		}
		else if(FastTrace(Focus.Location, endtest))
		{
			// Move it closer to the dude for the one we actually use
			gloc2=Focus.location + (vector(rot) * SIDE_DIST_USE);
		}
		else
			bfail=true;

		if(bfail)
		{
			if(!bBagParty)
			// if right side didn't work, check to put her in back
			// but the bag party has too much in the back to have a girl
			{
				rot = Focus.rotation;
				rot.yaw += 32768;
				// Use the same values as the sides, since his weapon will
				// be facing forwards and not sticking into the girl
				loc = Focus.location + (vector(rot) * SIDE_START_CHECK);
				if(FastTrace(Focus.Location, loc))
					// Move it closer to the dude for the one we actually use
					gloc2=Focus.location + (vector(rot) * SIDE_DIST_USE);
				else
					bgirl2=false;
			}
			else
				bgirl2=false;
		}

		if(bgirl1)
		{
			// Find the floor for her, within reason. Start a little above her
			// and test to a little below her
			starttest = gloc1;
			endtest = gloc1;
			starttest.z += UP_DOWN_TEST;
			endtest.z -= UP_DOWN_TEST;
			if(Trace(loc, newnormal, endtest, starttest, false) != None)
			{
				gloc1=loc;
				gloc1.z+=UP_DOWN_TEST;
			}
			// make the girl and the explosion					
			spawn(CheerleaderClass1, EndGameFocus, , gloc1 + vect(0,0,0), Focus.rotation);
			if (ExplosionClass != None)
				spawn(ExplosionClass, EndGameFocus, , gloc1 + vect(0,0,-50), Focus.rotation);
		}

		if(bgirl2)
		{
			// Find the floor for her, within reason. Start a little above her
			// and test to a little below her
			starttest = gloc2;
			endtest = gloc2;
			starttest.z += UP_DOWN_TEST;
			endtest.z -= UP_DOWN_TEST;
			if(Trace(loc, newnormal, endtest, starttest, false) != None)
			{
				gloc2=loc;
				gloc2.z+=UP_DOWN_TEST;
			}
			// make the girl and the explosion					
			spawn(CheerleaderClass2, EndGameFocus, , gloc2 + vect(0,0,0), Focus.rotation);
			if (ExplosionClass != None)
				spawn(ExplosionClass, EndGameFocus, , gloc2 + vect(0,0,-50), Focus.rotation);
		}

		// blaring music
		spawn(class'CheerLeaderMusic',EndGameFocus,,Focus.Location);
	}
}

function PlayWinMessage(PlayerController Player, bool bWinner)
{
	if ( MpPlayer(Player) != None )
		MpPlayer(Player).PlayWinMessage(bWinner);
}

event PlayerController Login
(
	string Portal,
	string Options,
	out string Error
)
{
	local PlayerController NewPlayer;
	local Controller C;
	local string InStatsPass;

	if ( MaxLives > 0 )
	{
		// check that game isn't too far along
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if ( (C.PlayerReplicationInfo != None) && (C.PlayerReplicationInfo.NumLives > 1) )
			{
				Options = "?SpectatorOnly=true"$Options;
				break;
			}
		}
	}

	NewPlayer = Super.Login(Portal,Options,Error);
    if ( bMustJoinBeforeStart && GameReplicationInfo.bMatchHasBegun )
		MpPlayer(NewPlayer).bLatecomer = true;

	if ( Level.NetMode == NM_Standalone )
	{
		if( NewPlayer.PlayerReplicationInfo.bOnlySpectator )
		{
			// Compensate for the space left for the player
			if ( !bCustomBots )
				InitialBots++;
		}
		else
			StandalonePlayer = NewPlayer;
	}

	// For non-team game, add player to current roster to make sure his character fits the roster
	if(!NewPlayer.PlayerReplicationInfo.bOnlySpectator && NewPlayer.PlayerReplicationInfo.Team == None && (NewPlayer.PawnClass != None) && EnemyRoster != None && !EnemyRoster.BelongsOnTeam(NewPlayer.PawnClass) )
	{
		NewPlayer.PawnClass = EnemyRoster.DefaultPlayerClass;
		// Update URL and set ini values for new class
		NewPlayer.UpdateURL("Class", string(EnemyRoster.DefaultPlayerClass), True);
		NewPlayer.ConsoleCommand("set" @ "Shell.MenuMulti MultiPlayerClass" @ EnemyRoster.DefaultPlayerClass);
	}

	// RWS Change: get the stats password if there is one
	InStatsPass= ParseOption( Options, "StatsPass");
	MpPlayer(NewPlayer).StatsPassword = InStatsPass;
	log(self$" Assigning stats password as: "$InStatsPass);

	return NewPlayer;
}

event PostLogin( playercontroller NewPlayer, string Options )
{
	Super.PostLogin(NewPlayer, Options);
	MpPlayer(NewPlayer).PlayStartUpMessage(StartupStage);
	// If there's a match intro, set it up BEFORE calling player's PostLogin
	if (MatchIntroClassName != "")
        MatchIntroClass = class<MatchIntro>(DynamicLoadObject(MatchIntroClassName, class'Class'));

	// Let player know he's fully logged and pass the intro class, if there is one
	MpPlayer(NewPlayer).PlayerPostLogin(MatchIntroClass);
}

function ChangeLoadOut(PlayerController P, string LoadoutName)
{
	local class<MpPawn> NewLoadout;

	NewLoadout = class<MpPawn>(DynamicLoadObject(LoadoutName,class'Class'));
	if ( (NewLoadout != None) 
		&& ((MpTeamInfo(P.PlayerReplicationInfo.Team) == None) || MpTeamInfo(P.PlayerReplicationInfo.Team).BelongsOnTeam(NewLoadout)) )
	{
		P.PawnClass = NewLoadout;
		if (P.Pawn!=None)
			P.ClientMessage(NextCharacterMsg$P.PawnClass.Default.MenuName);
	}
}

function RestartPlayer( Controller aPlayer )	
{
	if ( bMustJoinBeforeStart && (MpPlayer(aPlayer) != None)
		&& MpPlayer(aPlayer).bLatecomer )
		return;

	if ( aPlayer.PlayerReplicationInfo.bOutOfLives )
		return;

	if ( aPlayer.IsA('Bot') && TooManyBots(aPlayer) )
	{
		aPlayer.Destroy();
		return;
	} 
	Super.RestartPlayer(aPlayer);
}

function ForceAddBot()
{
	// add bot during gameplay
	if ( Level.NetMode != NM_Standalone )
		MinPlayers = Max(MinPlayers+1, NumPlayers + NumBots + 1);
	AddBot();
}

function bool AddBot(optional string botName)
{
	local Bot NewBot;

	// RWS CHANGE: Only add a bot if bAutoFillBots is enabled
	if(!bAutoFillBots)
		return false;

	NewBot = SpawnBot(botName);
	if ( NewBot == None )
	{
		warn("Failed to spawn bot.");
		return false;
	}
	// broadcast a welcome message.
	BroadcastLocalizedMessage(GameMessageClass, 1, NewBot.PlayerReplicationInfo);

	NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;
	NumBots++;
    if ( Level.NetMode == NM_Standalone )
		RestartPlayer(NewBot);
	else
		NewBot.GotoState('Dead','MPStart');
		
	return true;
}

function AddDefaultInventory( pawn PlayerPawn )
{
	if ( MpPawn(PlayerPawn) != None )
		MpPawn(PlayerPawn).AddDefaultInventory();
	SetPlayerDefaults(PlayerPawn);
}

function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
{
    if ( ViewTarget == None )
        return false;
	if ( Controller(ViewTarget) != None )
		return ( (Controller(ViewTarget).PlayerReplicationInfo != None)
				&& !Controller(ViewTarget).PlayerReplicationInfo.bOnlySpectator );
	return ( (Level.NetMode == NM_Standalone) || bOnlySpectator );
}

function bool ShouldRespawn(Pickup Other)
{
	if(Other != None)
		return ( Other.ReSpawnTime!=0.0 );
	else
		return false;
}

function ChangeName(Controller Other, string S, bool bNameChange)
{
    local Controller APlayer,C;

	if ( S == "" )
		return;

	if (Other.PlayerReplicationInfo.playername~=S)
		return;
	
	S = Left(S,20);
    ReplaceText(S, " ", "_");

	for( APlayer=Level.ControllerList; APlayer!=None; APlayer=APlayer.nextController )
		if ( APlayer.bIsPlayer && (APlayer.PlayerReplicationInfo.playername~=S) )
		{
			if ( Other.IsA('PlayerController') )
			{
				PlayerController(Other).ReceiveLocalizedMessage( GameMessageClass, 8 );
				return;
			}
			else
			{
				S = S$"_"$NameNumber;
				NameNumber++;
				break;
			}
		}

	if( bNameChange )
		GameEvent("NameChange",s,Other.PlayerReplicationInfo);

	Other.PlayerReplicationInfo.SetPlayerName(S);
    // notify local players
	if ( bNameChange )
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
			if ( (PlayerController(C) != None) && (Viewport(PlayerController(C).Player) != None) )
				PlayerController(C).ReceiveLocalizedMessage( class'GameMessage', 2, Other.PlayerReplicationInfo );
}

function Logout(controller Exiting)
{
	Super.Logout(Exiting);
	if ( Exiting.IsA('Bot') )
		NumBots--;
    if ( !bKillBots )
		RemainingBots++;
    if ( !NeedPlayers() || AddBot() )
        RemainingBots--;
    if ( MaxLives > 0 )
         CheckMaxLives(none);
}

function bool NeedPlayers()
{
	if ( Level.NetMode == NM_Standalone )
		return ( RemainingBots > 0 );
	if ( bMustJoinBeforeStart )
		return false;
	return (NumPlayers + NumBots < MinPlayers);
}

//------------------------------------------------------------------------------
// Game Querying.

function string GetRules()
{
	local string ResultSet;
	ResultSet = Super.GetRules();

	ResultSet = ResultSet$"\\goalscore\\"$GoalScore;
	ResultSet = ResultSet$"\\timelimit\\"$TimeLimit;
	// Only send min players if bots are enabled through bAutoFillBots
	if(bAutoFillBots)
		Resultset = ResultSet$"\\minplayers\\"$MinPlayers;
	// RWS CHANGE: Not doing tournament mode
	//Resultset = ResultSet$"\\tournament\\"$bTournament;
	return ResultSet;
}

function InitGameReplicationInfo()
{
	Super.InitGameReplicationInfo();
	GameReplicationInfo.GoalScore = GoalScore;
	GameReplicationInfo.TimeLimit = TimeLimit;
}

//------------------------------------------------------------------------------

function MPTeamInfo GetBotTeam(optional int TeamBots)
{
	local class<MPTeamInfo> RosterClass;
	if ( EnemyRoster != None )
		return EnemyRoster;
/*	if ( CurrentGameProfile != None )
	{
		RosterClass = class<MPTeamInfo>(DynamicLoadObject(CurrentGameProfile.EnemyTeam,class'Class'));
		if ( RosterClass == None)
			warn("NO ENEMY ROSTER FOR THIS SINGLE PLAYER MATCH WITH ENEMY TEAM "$CurrentGameProfile.EnemyTeam);
		else
			EnemyRoster = spawn(RosterClass);
	}
	else*/ if ( EnemyRosterName != "" )
	{
		RosterClass = class<MPTeamInfo>(DynamicLoadObject(EnemyRosterName,class'Class'));
		if ( RosterClass != None)
			EnemyRoster = spawn(RosterClass);
	}
	if ( EnemyRoster == None )
	{
		RosterClass = class<MPTeamInfo>(DynamicLoadObject(DefaultEnemyRosterClass,class'Class'));
		if ( RosterClass != None)
			EnemyRoster = spawn(RosterClass);
	}
	EnemyRoster.Initialize(TeamBots);
	return EnemyRoster;
}

/* Spawn and initialize a bot
*/
function Bot SpawnBot(optional string botName)
{
	local Bot NewBot;
	local RosterEntry Chosen;
	local MpTeamInfo BotTeam;
	
	BotTeam = GetBotTeam();
	Chosen = BotTeam.ChooseBotClass();
	NewBot = Bot(Spawn(Chosen.PawnClass.default.ControllerClass));

	if ( NewBot != None )
		InitializeBot(NewBot,BotTeam,Chosen);
	return NewBot;
}

/* Initialize bot
*/
function InitializeBot(Bot NewBot, MpTeamInfo BotTeam, RosterEntry Chosen)
{
	NewBot.InitializeSkill(AdjustedDifficulty);
	NewBot.PawnClass = Chosen.PawnClass;

	BotTeam.AddToTeam(NewBot);
	// Put 'moron' etc in front of bot names
	Chosen.PlayerName = BotPrefix $ Chosen.PlayerName;
	ChangeName(NewBot, Chosen.PlayerName, false);
	Chosen.InitBot(NewBot);
	BotTeam.SetBotOrders(NewBot,Chosen);
}

/* initialize a bot which is associated with a pawn placed in the level
*/
function InitPlacedBot(Controller C, RosterEntry R)
{
    local MpTeamInfo BotTeam;

	log("Init placed bot "$C);

    BotTeam = FindTeamFor(C);
    if ( Bot(C) != None )
    {
		Bot(C).InitializeSkill(AdjustedDifficulty);
		if ( R != None )
			R.InitBot(Bot(C));
	}
	BotTeam.AddToTeam(C);
	if ( R != None )
		ChangeName(C, R.PlayerName, false);
}

function MpTeamInfo FindTeamFor(Controller C)
{
	return GetBotTeam();
}
//------------------------------------------------------------------------------
// Game States

function StartMatch()
{
    local bool bTemp;
	local int Num;

    GotoState('MatchInProgress');
    if ( Level.NetMode == NM_Standalone )
        RemainingBots = InitialBots;
    else
        RemainingBots = 0;
    GameReplicationInfo.RemainingMinute = RemainingTime;
    Super.StartMatch();
    bTemp = bMustJoinBeforeStart;
    bMustJoinBeforeStart = false;
    while ( NeedPlayers() && (Num<16) )
    {
		if ( AddBot() )
			RemainingBots--;
		Num++;
    }
    bMustJoinBeforeStart = bTemp;
    log("START MATCH");
}

function EndGame(PlayerReplicationInfo Winner, string Reason )
{
    if ( (Reason ~= "triggered") ||
         (Reason ~= "LastMan")   ||
         (Reason ~= "TimeLimit") ||
         (Reason ~= "FragLimit") ||
         (Reason ~= "TeamScoreLimit") )
    {
        Super.EndGame(Winner,Reason);
        if ( bGameEnded )
            GotoState('MatchOver');
    }
}

/* FindPlayerStart()
returns the 'best' player start for this player to start from.
*/
function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string incomingName)
{
	local NavigationPoint Best;

	if ( (Player != None) && (Player.StartSpot != None) )
		LastPlayerStartSpot = Player.StartSpot;

	Best = Super.FindPlayerStart(Player, InTeam, incomingName );
	if ( Best != None )
		LastStartSpot = Best;
	return Best;
}

function PlayEndOfMatchMessage()
{
	local controller C;

	for ( C = Level.ControllerList; C != None; C = C.NextController )
	{
		if ( C.IsA('MpPlayer') && !C.PlayerReplicationInfo.bOnlySpectator )
		{
			if (C.PlayerReplicationInfo == GameReplicationInfo.Winner)
				MpPlayer(C).PlayAnnouncement(EndGameSound[0],1,true);
			else
				MpPlayer(C).PlayAnnouncement(EndGameSound[1],1,true);
		}
	}
}

function PlayStartupMessage()
{
	local Controller P;

    // keep message displayed for waiting players
    for (P=Level.ControllerList; P!=None; P=P.NextController )
        if ( MpPlayer(P) != None )
            MpPlayer(P).PlayStartUpMessage(StartupStage);
}

auto State PendingMatch
{
	function RestartPlayer( Controller aPlayer )
	{
		if ( CountDown <= 0 )
			Super.RestartPlayer(aPlayer);
	}

    function bool AddBot(optional string botName)
	{
		if ( Level.NetMode == NM_Standalone )
			InitialBots++;
		return true;
	}
	
	function Timer()
	{
		local Controller P;
		local bool bReady;
		local float PlayersReady, PlayersTotal;

		Global.Timer();

		// first check if there are enough net players, and enough time has elapsed to give people
		// a chance to join
		if ( NumPlayers == 0 )
			bWaitForNetPlayers = true;
        if ( bWaitForNetPlayers && (Level.NetMode != NM_Standalone) )
		{
			if ( NumPlayers > 0 )
				ElapsedTime++;
			else
				ElapsedTime = 0;
			if ( (NumPlayers == MaxPlayers) 
				|| ((ElapsedTime > NetWait) && (NumPlayers >= MinNetPlayers)) )
			{
				bWaitForNetPlayers = false;
				CountDown = Default.CountDown;
			}
		}

		if ( (Level.NetMode != NM_Standalone) && (bWaitForNetPlayers || (bTournament && (NumPlayers < MaxPlayers))) )
        {
       		PlayStartupMessage();
            return;
		}

		// check if players are ready
		bReady = true;
		StartupStage = 1;
        if ( !bStartedCountDown && (bTournament || bPlayersMustBeReady || (Level.NetMode == NM_Standalone)) )
		{
			for (P=Level.ControllerList; P!=None; P=P.NextController )
			{
				if ( P.IsA('PlayerController') 
					&& (P.PlayerReplicationInfo != None)
					&& P.bIsPlayer)
				{
					PlayersTotal=PlayersTotal+1.0;
					if(P.PlayerReplicationInfo.bWaitingPlayer
						&& !P.PlayerReplicationInfo.bReadyToPlay )
						bReady = false;
					else
						PlayersReady=PlayersReady+1.0;
				}
			}
		}

		if ( bReady )
		{	
			bStartedCountDown = true;
			CountDown--;
			if ( CountDown <= 0 )
				StartMatch();
			else
                StartupStage = 5 - CountDown;
		}
		// Asshole protection--check if a majority of players are ready and you're supposed to be waiting--
		// if so, go ahead and start it the game in CountdownWaitingForPlayers (30 seconds or so)
		else if(!bCountdownWaitForPlayers)
		{
			if(PlayersTotal > 1
				&& PlayersReady > PlayersTotal/2)
			{
				bCountdownWaitForPlayers=true;
			}
		}
		else // We're in the limbo here where the majority want to play but some dicks are not pressing
			// Ready, so in a few seconds we're going to start anyways.
		{
			CountdownWaitForPlayers--;
			if(CountdownWaitForPlayers==0)
			{
				bStartedCountDown=true;
			}
		}

		PlayStartupMessage();
	}

    function beginstate()
    {
		bWaitingToStartMatch = true;
        StartupStage = 0;
    }
}

State MatchInProgress
{
	function Timer()
	{
		local Controller P;

		Global.Timer();
		if ( !bFinalStartup )
		{
			bFinalStartup = true;
			PlayStartupMessage();
		}
		if ( bForceRespawn )
			For ( P=Level.ControllerList; P!=None; P=P.NextController )
			{
				if ( (P.Pawn == None) && P.IsA('PlayerController') && !P.PlayerReplicationInfo.bOnlySpectator )
				{
					if (MpPlayer(P) != None && MpPlayer(P).CanRestartPlayer())
						PlayerController(P).ServerReStartPlayer();
				}
			}
        if ( NeedPlayers() && AddBot() && (RemainingBots > 0) )
			RemainingBots--;

        if ( bOverTime )
			EndGame(None,"TimeLimit");
		else if ( TimeLimit > 0 )
		{
			GameReplicationInfo.bStopCountDown = false;
			RemainingTime--;
			GameReplicationInfo.RemainingTime = RemainingTime;
			if ( RemainingTime % 60 == 0 )
				GameReplicationInfo.RemainingMinute = RemainingTime;
			if ( RemainingTime <= 0 )
				EndGame(None,"TimeLimit");
		}
        else if ( (MaxLives > 0) && (NumPlayers + NumBots != 1) )
			CheckMaxLives(none);

		ElapsedTime++;
		GameReplicationInfo.ElapsedTime = ElapsedTime;
	}

	function beginstate()
	{
		local PlayerReplicationInfo PRI;

		ForEach DynamicActors(class'PlayerReplicationInfo',PRI)
			PRI.StartTime = 0;
		ElapsedTime = 0;
		bWaitingToStartMatch = false;
        StartupStage = 5;
        PlayStartupMessage();
        StartupStage = 6;
	}
}

State MatchOver
{
	function RestartPlayer( Controller aPlayer ) {}
	function ScoreKill(Controller Killer, Controller Other) {}
	function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
	{
		return 0;
	}

	function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
	{
		return false;
	}

	function Timer()
	{
		local Controller C;

		Global.Timer();

        if ( !bGameRestarted && (Level.TimeSeconds > EndTime + RestartWait) )
			RestartGame();

		if ( EndGameFocus != None )
		{
			EndGameFocus.bAlwaysRelevant = true;
			for ( C = Level.ControllerList; C != None; C = C.NextController )
				if ( PlayerController(C) != None )
					PlayerController(C).ClientSetViewtarget(EndGameFocus);
		}
	}
	
	function bool NeedPlayers()
	{
		return false;
	}

    function BeginState()
    {
		local Controller C;
		local PlayerController P;

		GameReplicationInfo.bStopCountDown = true;
	}

Begin:
	Sleep(WaitForWinnerAnnouncement);
	PlayEndOfMatchMessage();
	Sleep(WaitForParty);
	PartyForTheWinner(EndGameFocus);
}

/* Rate whether player should choose this NavigationPoint as its start
*/
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
	local PlayerStart P;
	local float Score, NextDist;
	local Controller OtherPlayer;

	P = PlayerStart(N);

	if ( (P == None) || !P.bEnabled || P.PhysicsVolume.bWaterVolume )
        return -10000000;

	//assess candidate
    if ( P.bPrimaryStart )
		Score = 10000000;
	else
		Score = 5000000;
	if ( (N == LastStartSpot) || (N == LastPlayerStartSpot) )
		Score -= 10000.0;
	else
		Score += 3000 * FRand(); //randomize

	if ( Level.TimeSeconds - P.LastSpawnCampTime < 30 )
		Score = Score - (30 - P.LastSpawnCampTime + Level.TimeSeconds) * 1000;

	for ( OtherPlayer=Level.ControllerList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextController)	
		if ( OtherPlayer.bIsPlayer && (OtherPlayer.Pawn != None) )
		{
			if ( OtherPlayer.Pawn.Region.Zone == N.Region.Zone )
				Score -= 1500;
			NextDist = VSize(OtherPlayer.Pawn.Location - N.Location);
			if ( NextDist < OtherPlayer.Pawn.CollisionRadius + OtherPlayer.Pawn.CollisionHeight )
				Score -= 1000000.0;
			else if ( (NextDist < 3000) && FastTrace(N.Location, OtherPlayer.Pawn.Location) )
				Score -= (10000.0 - NextDist);
			else if ( NumPlayers + NumBots == 2 )
			{
				Score += 2 * VSize(OtherPlayer.Pawn.Location - N.Location);
				if ( FastTrace(N.Location, OtherPlayer.Pawn.Location) )
					Score -= 10000;
			}
		}
    return FMax(Score, 5);
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
                && !C.PlayerReplicationInfo.bOutOfLives
                && !C.PlayerReplicationInfo.bOnlySpectator )
            {
				if ( Living == None )
					Living = C.PlayerReplicationInfo;
				else if (C.PlayerReplicationInfo != Living)
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

/* CheckScore()
see if this score means the game ends
*/
function CheckScore(PlayerReplicationInfo Scorer)
{
	local controller C;

	if (CheckMaxLives(Scorer))
		return;

	if ( (GameRulesModifiers != None) && GameRulesModifiers.CheckScore(Scorer) )
		return;

	if ( Scorer != None )
	{
		if ( (GoalScore > 0) && (Scorer.Score >= GoalScore) )
			EndGame(Scorer,"fraglimit");
		else if ( bOverTime )
		{
			// end game only if scorer has highest score
			for ( C=Level.ControllerList; C!=None; C=C.NextController )
				if ( (C.PlayerReplicationInfo != None)
					&& (C.PlayerReplicationInfo != Scorer)
					&& (C.PlayerReplicationInfo.Score >= Scorer.Score) )
					return;
			EndGame(Scorer,"fraglimit");
		}
	}
}

function ScoreObjective(PlayerReplicationInfo Scorer, Int Score)
{
	if ( Scorer != None )
	{
		Scorer.Score += Score;
		ScoreEvent(Scorer,Score,"ObjectiveScore");
	}

	if ( GameRulesModifiers != None )
		GameRulesModifiers.ScoreObjective(Scorer,Score);
	CheckScore(Scorer);
}

function ScoreKill(Controller Killer, Controller Other)
{
	local PlayerReplicationInfo OtherPRI;

	OtherPRI = Other.PlayerReplicationInfo;
    if ( OtherPRI != None )
    {
        OtherPRI.NumLives++;
        if ( (MaxLives > 0) && (OtherPRI.NumLives >=MaxLives) )
            OtherPRI.bOutOfLives = true;
    }

	Super.ScoreKill(Killer,Other);

	if ( (killer == None) || (Other == None) )
		return;
		
	if ( bAdjustSkill && (killer.IsA('PlayerController') || Other.IsA('PlayerController')) )
	{
        if ( killer.IsA('AIController') )
            AdjustSkill(AIController(killer), PlayerController(Other),true);
        if ( Other.IsA('AIController') )
            AdjustSkill(AIController(Other), PlayerController(Killer),false);
	}
}

function AdjustSkill(AIController B, PlayerController P, bool bWinner)
{
	local float BotSkill;

	BotSkill = B.Skill;

	if ( bWinner )
	{
		PlayerKills += 1;
		AdjustedDifficulty = FMax(0, AdjustedDifficulty - 2/Min(PlayerKills, 10));
		if ( BotSkill > AdjustedDifficulty )
			B.Skill = AdjustedDifficulty;
	}
	else
	{
		PlayerDeaths += 1;
        AdjustedDifficulty = FMin(10,AdjustedDifficulty + 2/Min(PlayerDeaths, 10));	// CRK: Changed from FMin(7... to 10
		if ( BotSkill < AdjustedDifficulty )
			B.Skill = AdjustedDifficulty;
	}
	if ( abs(AdjustedDifficulty - BotDifficulty) >= 1 )
	{
		BotDifficulty = AdjustedDifficulty;
		SaveConfig();
	}
}

function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
	local float InstigatorSkill;

// We don't want spawn protection, because it really never helps much and causes more bugs than is worth.
//	if ( (instigatedBy != None) && (InstigatedBy != Injured) && (Level.TimeSeconds - injured.SpawnTime < SpawnProtectionTime) )
/* RWS FIXME: Add a flag to P2Damage to differentiate weapon versus other damage
		&& (class<WeaponDamageType>(DamageType) != None) ) */
//		return 0;

	Damage = Super.ReduceDamage( Damage, injured, InstigatedBy, HitLocation, Momentum, DamageType );

	if ( instigatedBy == None)
		return Damage;

	if ( BotDifficulty <= 3 )
	{
		if ( injured.IsPlayerPawn() && (injured == instigatedby) && (Level.NetMode == NM_Standalone) )
			Damage *= 0.5;

		//skill level modification
		if ( AIController(instigatedBy.Controller) != None )
		{
			InstigatorSkill = AIController(instigatedBy.Controller).Skill;
			if ( (InstigatorSkill <= 3) && injured.IsHumanControlled() )
			{
				if ( ((instigatedBy.Weapon != None) && instigatedBy.Weapon.bMeleeWeapon) 
					|| ((injured.Weapon != None) && injured.Weapon.bMeleeWeapon && (VSize(injured.location - instigatedBy.Location) < 600)) )
					Damage = Damage * (0.76 + 0.08 * InstigatorSkill);
				else
					Damage = Damage * (0.25 + 0.15 * InstigatorSkill);
			}
		}
	} 
	return (Damage * instigatedBy.DamageScaling);
}

// Kill all or num bots
exec function KillBots(int num)
{
    local Controller c, nextC;

    if (num == 0)
        num = NumBots;

    c = Level.ControllerList;
    if ( Level.NetMode != NM_Standalone )
		MinPlayers = 0;
    bKillBots = true;
    while (c != None && num > 0)
    {
        nextC = c.NextController;
        if (KillBot(c))
            --num;
        c = nextC;
    }
    bKillBots = false;
}

function bool KillBot(Controller c)
{
    local Bot b;

    b = Bot(c);
    if (b != None)
    {
        if (Level.NetMode != NM_Standalone)
            MinPlayers = Max(MinPlayers - 1, NumPlayers + NumBots - 1);

        if (b.Pawn != None)
            b.Pawn.KilledBy( b.Pawn );
		if (b != None)
			b.Destroy();
        return true;
    }
    return false;
}

defaultproperties
{
	DMSquadClass=class'MultiBase.DMSquad'
	GoalScore=25
	bLoggingGame=true
	bTournament=false
	CountDown=4
	GameName="DeathMatch"
	InitialBots=0
	bRestartLevel=False
	bPauseable=False
	bPlayersMustBeReady=false
	BeaconName="DM"
	// Instead of the traditional 16, make it 8, so keep network performance good
	MaxPlayers=8
	NetWait=2
	RestartWait=15
	bDelayedStart=true
	MutatorClass="MultiBase.DMMutator"
	MinNetPlayers=1
	bWaitForNetPlayers=true
	SpawnProtectionTime=+2.0
	LevelRulesClass=class'LevelGameRules'
	NextCharacterMsg="Your next character is "
	BotPrefix="Moronic"

	//	BotMenuType
	SettingsMenuType="UTBrowser.UTDMSettingsSClient"

	ExplosionClassName="FX.BabeExplosion"

	EndGameSound(0)=Sound'MpAnnouncer.AnnouncerYouWon'
	EndGameSound(1)=Sound'MpAnnouncer.AnnouncerYouLost'

	WaitForWinnerAnnouncement=2.0
	WaitForParty=2.0
	PartyMusic=Sound'AmbientSounds.hornyClub'
	CheerleaderClass1=class'CheerleadersBlue'
	CheerleaderClass2=class'CheerleadersBlue2'

	TimeLimit=25

	CountdownWaitForPlayers=30
}
