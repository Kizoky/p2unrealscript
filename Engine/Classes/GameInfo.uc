//=============================================================================
// GameInfo.
//
// The GameInfo defines the game being played: the game rules, scoring, what actors 
// are allowed to exist in this game type, and who may enter the game.  While the 
// GameInfo class is the public interface, much of this functionality is delegated 
// to several classes to allow easy modification of specific game components.  These 
// classes include GameInfo, AccessControl, Mutator, BroadcastHandler, and GameRules.  
// A GameInfo actor is instantiated when the level is initialized for gameplay (in 
// C++ UGameEngine::LoadMap() ).  The class of this GameInfo actor is determined by 
// (in order) either the DefaultGameType if specified in the LevelInfo, or the 
// DefaultGame entry in the game's .ini file (in the Engine.Engine section), unless 
// its a network game in which case the DefaultServerGame entry is used.  
//
//=============================================================================
class GameInfo extends Info
	native;

//-----------------------------------------------------------------------------
// Variables.

// RWS CHANGE: Added single player flag
var	bool                      bIsSingleplayer;			// Whether this is a singleplayer game
var bool				      bRestartLevel;			// Level should be restarted when player dies
var bool				      bPauseable;				// Whether the game is pauseable.
// RWS CHANGE: Renamed bCoopWeaponMode to this per UT2003
var config bool				  bWeaponStay;              // Whether or not weapons stay when picked up.
var	bool				      bCanChangeSkin;			// Allow player to change skins in game.
var bool				      bTeamGame;				// This is a team game.
var	bool					  bGameEnded;				// set when game ends
var	bool					  bOverTime;
var localized bool			  bAlternateMode;
var	bool					  bCanViewOthers;
var bool					  bDelayedStart;
var bool					  bWaitingToStartMatch;
var globalconfig bool		  bChangeLevels;
var	bool					  bAlreadyChanged;
// RWS CHANGE: Merged new log/stat stuff from UT2003
var bool					  bLoggingGame;				// Does this gametype log?
var globalconfig bool		  bEnableStatLogging;		// If True, games will log
// RWS CHANGE: Merged behind view flag from UT2003
var config bool				  bAllowBehindView;
// RWS CHANGE: Merged restart flag from UT2003
var bool					  bGameRestarted;

// RWS CHANGE: Renamed Difficulty to this per UT2003
var globalconfig float        GameDifficulty;
var globalconfig int		  GoreLevel;				// 0=Normal, increasing values=less gore
var globalconfig float		  AutoAim;					// How much autoaiming to do (1 = none, 0 = always).

var   globalconfig float	  GameSpeed;				// Scale applied to game rate.
var   float                   StartTime;

var   string				  DefaultPlayerClassName;

// user interface
var   string                  ScoreBoardType;           // Type of class<Menu> to use for scoreboards. (gam)
var   string			      BotMenuType;				// Type of bot menu to display.
var   string			      RulesMenuType;			// Type of rules menu to display.
var   string				  SettingsMenuType;			// Type of settings menu to display.
var   string				  GameUMenuType;			// Type of Game dropdown to display.
var   string				  MultiplayerUMenuType;		// Type of Multiplayer dropdown to display.
var   string				  GameOptionsMenuType;		// Type of options dropdown to display.
var   string				  HUDType;                  // HUD class this game uses. (gam)
var   string				  MapListType;				// Maplist this game uses.
var   string			      MapPrefix;				// Prefix characters for names of maps for this game type.
var   string			      BeaconName;				// Identifying string used for finding LAN servers.

var   globalconfig int	      MaxSpectators;			// Maximum number of spectators.
var	  int					  NumSpectators;			// Current number of spectators.
var   globalconfig int		  MaxPlayers; 
var   int					  NumPlayers;				// number of human players
var	  int					  NumBots;					// number of non-human players (AI controlled but participating as a player)
var   int					  CurrentID;
var localized string	      DefaultPlayerName;
var localized string	      GameName;

var config int                GoalScore;                // what score is needed to end the match
var config int                MaxLives;	                // max number of lives for match, unless overruled by level's GameDetails
var config int                TimeLimit;                // time limit in minutes

// RWS CHANGE Added our own version of High Detail
var globalconfig bool		  bGameHighDetail;

// Message classes.
var class<LocalMessage>		  DeathMessageClass;
var class<GameMessage>		  GameMessageClass;
var	name					  OtherMesgGroup;

//-------------------------------------
// GameInfo components
var string MutatorClass;
var Mutator BaseMutator;				// linked list of Mutators (for modifying actors as they enter the game)
var globalconfig string AccessControlClass;
var AccessControl AccessControl;		// AccessControl controls whether players can enter and/or become admins
var GameRules GameRulesModifiers;		// linked list of modifier classes which affect game rules
var string BroadcastHandlerClass;
var BroadcastHandler BroadcastHandler;	// handles message (text and localized) broadcasts

var class<PlayerController> PlayerControllerClass;	// type of player controller to spawn for players logging in
var string PlayerControllerClassName;

// ReplicationInfo
var() class<GameReplicationInfo> GameReplicationInfoClass;
var GameReplicationInfo GameReplicationInfo;

// RWS CHANGE: Merged new log/stat stuff from UT2003
// Stats - jmw
var GameStats                   	GameStats;				// Holds the GameStats actor
var globalconfig string				GameStatsClass;			// Type of GameStats actor to spawn

// shadows
var globalconfig bool				bUseDynamicShadows;

// Matinee fast-forward feature
var globalconfig float				MatineeFastForwardSpeed;	// Speed at which to playback matinee if player is holding bWantsToSkip
var globalconfig bool				bAllowMatineeFastForward;	// Defaulting to FALSE for now.

//------------------------------------------------------------------------------
// Engine notifications.

function PreBeginPlay()
{
	StartTime = 0;
	SetGameSpeed(GameSpeed);
	GameReplicationInfo = Spawn(GameReplicationInfoClass);
	InitGameReplicationInfo();
	// RWS CHANGE: Merged new log/stats stuff from UT2003
	// Create stat logging actor.
    InitLogging();
}

function PostBeginPlay()
{
	if ( bAlternateMode )
		GoreLevel = 2;
	// RWS CHANGE: Merged new log/stats stuff from UT2003
	if (GameStats!=None)
	{
		GameStats.NewGame();
		GameStats.ServerInfo();
	}
	Super.PostBeginPlay();
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	bGameEnded = false;
	bOverTime = false;
	bWaitingToStartMatch = true;
	InitGameReplicationInfo();
}

/* InitLogging()
Set up statistics logging
*/
function InitLogging()
{
	// RWS CHANGE: Merged new log/stats stuff from UT2003
	local class <GameStats> MyGameStatsClass;

    if ( !bEnableStatLogging || !bLoggingGame || (Level.NetMode == NM_Standalone) )
		// We allow listen server logging--if people think it's unfair to get stats on a listen
		// server--don't run one! Run a dedicated server instead!
		//|| (Level.NetMode == NM_ListenServer) )
        return;

	MyGameStatsClass=class<GameStats>(DynamicLoadObject(GameStatsClass,class'class'));
    if (MyGameStatsClass!=None)
    {
		GameStats = spawn(MyGameStatsClass);
        if (GameStats==None)
        	log("Could not create Stats Object");
    }
    else
    	log("Error loading GameStats ["$GameStatsClass$"]");
}

function Timer()
{
	BroadcastHandler.UpdateSentText();
}

// Called when game shutsdown.
event GameEnding()
{
	EndLogging("serverquit");
}

//------------------------------------------------------------------------------
// Replication

function InitGameReplicationInfo()
{
	GameReplicationInfo.bTeamGame = bTeamGame;
	GameReplicationInfo.GameName = GameName;
	GameReplicationInfo.GameClass = string(Class);
    GameReplicationInfo.MaxLives = MaxLives;
}

native function string GetNetworkNumber();

//------------------------------------------------------------------------------
// Game Querying.

function string GetInfo()
{
	local string ResultSet;

	// World logging enabled and working
	if ( GameStats != None )
		ResultSet = "\\worldlog\\true";
	else
		ResultSet = "\\worldlog\\false";

	// World logging activated
	if ( GameStats != None )
		ResultSet = ResultSet$"\\wantworldlog\\true";
	else
		ResultSet = ResultSet$"\\wantworldlog\\false";

	// RWS Change: Whether the server is password protected.
	if( Level.Game.AccessControl != None && Level.Game.AccessControl.RequiresPassword() )
		ResultSet = ResultSet$"\\password\\true";
	else
		ResultSet = ResultSet$"\\password\\false";

	return ResultSet;
}

function int GetNumPlayers()
{
	return NumPlayers;
}

function string GetRules()
{
	local string ResultSet;
	local Mutator M;
	local string NextMutator, NextDesc;
	local string EnabledMutators;
	local int Num, i;

	ResultSet = "";

	EnabledMutators = "";
	for (M = BaseMutator.NextMutator; M != None; M = M.NextMutator)
	{
		Num = 0;
		NextMutator = "";
		GetNextIntDesc("Engine.Mutator", 0, NextMutator, NextDesc);
		while( (NextMutator != "") && (Num < 50) )
		{
			if(NextMutator ~= string(M.Class))
			{
				i = InStr(NextDesc, ",");
				if(i != -1)
					NextDesc = Left(NextDesc, i);

				if(EnabledMutators != "")
					EnabledMutators = EnabledMutators $ ", ";
				 EnabledMutators = EnabledMutators $ NextDesc;
				 break;
			}
			
			Num++;
			GetNextIntDesc("Engine.Mutator", Num, NextMutator, NextDesc);
		}
	}
	if(EnabledMutators != "")
		ResultSet = ResultSet $ "\\mutators\\"$EnabledMutators;

	ResultSet = ResultSet $ "\\listenserver\\"$string(Level.NetMode==NM_ListenServer);
	// RWS CHANGE: ChangeLevels is always 'on'
	//Resultset = ResultSet$"\\changelevels\\"$bChangeLevels;
	if ( GameRulesModifiers != None )
		ResultSet = ResultSet$GameRulesModifiers.GetRules();

	return ResultSet;
}

//------------------------------------------------------------------------------
// Misc.

// Return the server's port number.
function int GetServerPort()
{
	local string S;
	local int i;

	// Figure out the server's port.
	S = Level.GetAddressURL();
	i = InStr( S, ":" );
	assert(i>=0);
	return int(Mid(S,i+1));
}

function bool SetPause( BOOL bPause, PlayerController P )
{
	local SceneManager SM;
	
	// Kamek edit - forbid pause if SceneManager says so.
	if (bPause)
	{
		SM = P.GetCurrentSceneManager();
		if (SM != None
			&& SM.bForbidPausing)
			return False;
	}
	
	if( bPauseable || P.IsA('Admin') || Level.Netmode==NM_Standalone )
	{
		if( bPause )
			Level.Pauser=P.PlayerReplicationInfo;
		else
			Level.Pauser=None;
		return True;
	}
	else return False;
}

//------------------------------------------------------------------------------
// Game parameters.

//
// Set gameplay speed.
//
function SetGameSpeed( Float T )
{
	local float OldSpeed;

	OldSpeed = GameSpeed;
	GameSpeed = FMax(T, 0.1);
	Level.TimeDilation = GameSpeed;
	if ( GameSpeed != OldSpeed )
		SaveConfig();
	SetTimer(Level.TimeDilation, true);
}

//
// Called after setting low or high detail mode.
//
event DetailChange()
{
	local actor A;
	local zoneinfo Z;

	if( !Level.bHighDetailMode )
	{
		foreach DynamicActors(class'Actor', A)
		{
			if( A.bHighDetail && !A.bGameRelevant )
				A.Destroy();
		}
	}
	foreach AllActors(class'ZoneInfo', Z)
		Z.LinkToSkybox();
}

//------------------------------------------------------------------------------
// Player start functions

//
// Grab the next option from a string.
//
function bool GrabOption( out string Options, out string Result )
{
	if( Left(Options,1)=="?" )
	{
		// Get result.
		Result = Mid(Options,1);
		if( InStr(Result,"?")>=0 )
			Result = Left( Result, InStr(Result,"?") );

		// Update options.
		Options = Mid(Options,1);
		if( InStr(Options,"?")>=0 )
			Options = Mid( Options, InStr(Options,"?") );
		else
			Options = "";

		return true;
	}
	else return false;
}

//
// Break up a key=value pair into its key and value.
//
function GetKeyValue( string Pair, out string Key, out string Value )
{
	if( InStr(Pair,"=")>=0 )
	{
		Key   = Left(Pair,InStr(Pair,"="));
		Value = Mid(Pair,InStr(Pair,"=")+1);
	}
	else
	{
		Key   = Pair;
		Value = "";
	}
}

/* ParseOption()
 Find an option in the options string and return it.
*/
function string ParseOption( string Options, string InKey )
{
	local string Pair, Key, Value;
	while( GrabOption( Options, Pair ) )
	{
		GetKeyValue( Pair, Key, Value );
		if( Key ~= InKey )
			return Value;
	}
	return "";
}

/* Initialize the game.
 The GameInfo's InitGame() function is called before any other scripts (including 
 PreBeginPlay() ), and is used by the GameInfo to initialize parameters and spawn 
 its helper classes.
 Warning: this is called before actors' PreBeginPlay.
*/
// RWS CHANGE: Made Options an out so that the info can change any url options it needs
event InitGame( out string Options, out string Error )
{
	local string InOpt, LeftOpt;
	local int pos;
	local class<AccessControl> ACClass;
	local class<GameRules> GRClass;
	local class<BroadcastHandler> BHClass;

	log( "InitGame:" @ Options );
// RWS CHANGE: Merged clamping from UT2003
    MaxPlayers = Clamp(GetIntOption( Options, "MaxPlayers", MaxPlayers ),0,16);
    MaxSpectators = Clamp(GetIntOption( Options, "MaxSpectators", MaxSpectators ),0,16);
    GameDifficulty = FMax(0,GetIntOption(Options, "Difficulty", GameDifficulty));

	InOpt = ParseOption( Options, "GameSpeed");
	if( InOpt != "" )
	{
		log("GameSpeed"@InOpt);
		SetGameSpeed(float(InOpt));
	}

    // RWS CHANGE: Let function do the work, merged from UT2003
	AddMutator(MutatorClass);
	
	BHClass = class<BroadcastHandler>(DynamicLoadObject(BroadcastHandlerClass,Class'Class'));
	BroadcastHandler = spawn(BHClass);

	InOpt = ParseOption( Options, "AccessControl");
	if( InOpt != "" )
		ACClass = class<AccessControl>(DynamicLoadObject(InOpt, class'Class'));
	// RWS CHANGE: Reworked to make sure an access class is used no matter what, per UT2003
    if ( ACClass == None )
    {
        ACClass = class<AccessControl>(DynamicLoadObject(AccessControlClass, class'Class'));
		if (ACClass == None)
			ACClass = class'Engine.AccessControl';
	}

	InOpt = ParseOption( Options, "AdminPassword");

	AccessControl = Spawn(ACClass);
	if (AccessControl != None && InOpt!="" )
		AccessControl.SetAdminPassword(InOpt);

	InOpt = ParseOption( Options, "GameRules");
	if ( InOpt != "" )
	{
		log("Game Rules"@InOpt);
		while ( InOpt != "" )
		{
			pos = InStr(InOpt,",");
			if ( pos > 0 )
			{
				LeftOpt = Left(InOpt, pos);
				InOpt = Right(InOpt, Len(InOpt) - pos - 1);
			}
			else
			{
				LeftOpt = InOpt;
				InOpt = "";
			}
			log("Add game rules "$LeftOpt);
			GRClass = class<GameRules>(DynamicLoadObject(LeftOpt, class'Class'));
			if ( GRClass != None )
			{
				if ( GameRulesModifiers == None )
					GameRulesModifiers = Spawn(GRClass);
				else	
					GameRulesModifiers.AddGameRules(Spawn(GRClass));
			}
		}
	}

	log("Base Mutator is "$BaseMutator);

	InOpt = ParseOption( Options, "Mutator");
	if ( InOpt != "" )
	{
		log("Mutators"@InOpt);
		while ( InOpt != "" )
		{
			pos = InStr(InOpt,",");
			if ( pos > 0 )
			{
				LeftOpt = Left(InOpt, pos);
				InOpt = Right(InOpt, Len(InOpt) - pos - 1);
			}
			else
			{
				LeftOpt = InOpt;
				InOpt = "";
			}
			log("Add mutator "$LeftOpt);
            // RWS CHANGE: Let function do the work, merged from UT2003
			AddMutator(LeftOpt, true);
		}
	}

	InOpt = ParseOption( Options, "GamePassword");
	if( InOpt != "" )
	{
		AccessControl.SetGamePassWord(InOpt);
		log( "GamePassword" @ InOpt );
	}

	// RWS CHANGE: Merged behind view flag from UT2003
	InOpt = ParseOption( Options, "AllowBehindview");
    if ( InOpt != "" )
    	bAllowBehindview = bool(InOpt);

	// RWS CHANGE: Merged new log/stats stuff from UT2003
	InOpt = ParseOption(Options, "GameStats");
	if ( InOpt != "")
		bEnableStatLogging = bool(InOpt);
	// RWS CHANGE: Accept the command line version, but if it's not specified, 
	// let the config value set it 
//	else
//		bEnableStatLogging = false;

	log("GameInfo::InitGame : bEnableStatLogging"@bEnableStatLogging);
}

// RWS CHANGE: Merged from UT2003
function AddMutator(string mutname, optional bool bUserAdded)
{
    local class<Mutator> mutClass;
    local Mutator mut;

    mutClass = class<Mutator>(DynamicLoadObject(mutname, class'Class'));
    if (mutClass == None)
        return;

	if ( (mutClass.Default.GroupName != "") && (BaseMutator != None) )
	{
		// make sure no mutators with same groupname
		for ( mut=BaseMutator; mut!=None; mut=mut.NextMutator )
			if ( mut.GroupName == mutClass.Default.GroupName )
				return;
	}

    mut = Spawn(mutClass);
	// mc, beware of mut being none
	if (mut == None)
		return;

	// Meant to verify if this mutator was from Command Line parameters or added from other Actors
	mut.bUserAdded = bUserAdded;

    if (BaseMutator == None)
        BaseMutator = mut;
    else
        BaseMutator.AddMutator(mut);
}

//
// Return beacon text for serverbeacon.
//
event string GetBeaconText()
{
	// RWS CHANGE: Now calls func for num players to match UT2003
	return
		Level.ComputerName
    $   " "
    $   Left(Level.Title,24)
    $   " "
    $   BeaconName
    $   " "
    $   GetNumPlayers()
	$	"/"
	$	MaxPlayers;
}

/* ProcessServerTravel()
 Optional handling of ServerTravel for network games.
*/
function ProcessServerTravel( string URL, bool bItems )
{
	local playercontroller P, LocalPlayer;

	EndLogging("mapchange");

	// Notify clients we're switching level and give them time to receive.
	// We call PreClientTravel directly on any local PlayerPawns (ie listen server)
	log("ProcessServerTravel:"@URL);
	foreach DynamicActors( class'PlayerController', P )
		if( NetConnection( P.Player)!=None )
			P.ClientTravel( URL, TRAVEL_Relative, bItems );
		else
		{	
			LocalPlayer = P;
			P.PreClientTravel();
			// RWS CHANGE: Set loading texture for the listen server player
			if(P.Player != None)
				P.Player.InteractionMaster.BaseMenu.SetLoadingTexture(URL);
		}

	if ( (Level.NetMode == NM_ListenServer) && (LocalPlayer != None) )
		Level.NextURL = Level.NextURL
//					 $"?Skin="$LocalPlayer.GetDefaultURL("Skin")	// RWS CHANGE: We don't use this
//					 $"?Face="$LocalPlayer.GetDefaultURL("Face")	// RWS CHANGE: We don't use this
					 $"?Team="$LocalPlayer.GetDefaultURL("Team")
					 $"?Name="$LocalPlayer.GetDefaultURL("Name")
					 $"?Class="$LocalPlayer.GetDefaultURL("Class");	// RWS CHANGE: Add class from UT2003

	// Switch immediately if not networking.
	if( Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
		Level.NextSwitchCountdown = 0.0;
}

//
// Accept or reject a player on the server.
// Fails login if you set the Error to a non-empty string.
//
event PreLogin
(
	string Options,
	string Address,
	out string Error,
	out string FailCode
)
{
	local bool bSpectator;

    // RWS CHANGE: Minor rework to clean up code per UT2003
	bSpectator = ( ParseOption( Options, "SpectatorOnly" ) ~= "true" );
	AccessControl.PreLogin(Options, Address, Error, FailCode, bSpectator);
}

function int GetIntOption( string Options, string ParseString, int CurrentValue)
{
	local string InOpt;

	InOpt = ParseOption( Options, ParseString );
	if ( InOpt != "" )
	{
		log(ParseString@InOpt);
		return int(InOpt);
	}	
	return CurrentValue;
}

function bool AtCapacity(bool bSpectator)
{
	if ( Level.NetMode == NM_Standalone )
		return false;

	if ( bSpectator )
		return ( (NumSpectators >= MaxSpectators)
			&& ((Level.NetMode != NM_ListenServer) || (NumPlayers > 0)) );
	else
		return ( (MaxPlayers>0) && (NumPlayers>=MaxPlayers) );
}

//
// Log a player in.
// Fails login if you set the Error string.
// PreLogin is called before Login, but significant game time may pass before
// Login is called, especially if content is downloaded.
//
event PlayerController Login
(
	string Portal,
	string Options,
	out string Error
)
{
	local NavigationPoint StartSpot;
	local PlayerController NewPlayer;
	local class<Pawn> DesiredPawnClass;
	local Pawn      TestPawn;
	local string          InName, InPassword, InChecksum, InClass;
	local byte            InTeam;
	local bool bSpectator, bAdmin, bMapPreview;

	bSpectator = ( ParseOption( Options, "SpectatorOnly" ) ~= "true" );
	bAdmin = AccessControl.CheckOptionsAdmin(Options);

    // Make sure there is capacity except for admins. (This might have changed since the PreLogin call).
    if ( !bAdmin && AtCapacity(bSpectator) )
	{
		Error=GameMessageClass.Default.MaxedOutMessage;
		return None;
	}

	// If admin, force spectate mode if the server already full of reg. players
	if ( bAdmin && AtCapacity(false))
		bSpectator = true;

	BaseMutator.ModifyLogin(Portal, Options);

	// Get URL options.
	InName     = Left(ParseOption ( Options, "Name"), 20);
	InTeam     = GetIntOption( Options, "Team", 255 ); // default to "no team"
	InPassword = ParseOption ( Options, "Password" );
	InChecksum = ParseOption ( Options, "Checksum" );
	bMapPreview = ( ParseOption( Options, "MapPreview" ) ~= "true" );

	log( "Login:" @ InName );
	
	// Pick a team (if need teams)
	InTeam = PickTeam(InTeam,None);
		 
	// Find a start spot.
	if (Level.NetMode == NM_Standalone && bMapPreview)
	{
		// Use the StartSpot created by the editor
		foreach AllActors(class'NavigationPoint', StartSpot)
			if (MapPreviewPoint(StartSpot) != None)
				break;
			
		// Doesn't exist, find a player start like normal.
		if (MapPreviewPoint(StartSpot) == None)
			StartSpot = FindPlayerStart( None, InTeam, Portal );
	}
	else
		StartSpot = FindPlayerStart( None, InTeam, Portal );
	

	if( StartSpot == None )
	{
		Error = GameMessageClass.Default.FailedPlaceMessage;
		return None;
	}

	if ( PlayerControllerClass == None )
		PlayerControllerClass = class<PlayerController>(DynamicLoadObject(PlayerControllerClassName, class'Class'));

	NewPlayer = spawn(PlayerControllerClass,,,StartSpot.Location,StartSpot.Rotation);

	// Handle spawn failure.
	if( NewPlayer == None )
	{
		log("Couldn't spawn player controller of class "$PlayerControllerClass);
		Error = GameMessageClass.Default.FailedSpawnMessage;
		return None;
	}

	NewPlayer.StartSpot = StartSpot;

	// Init player's replication info
	NewPlayer.GameReplicationInfo = GameReplicationInfo;

	NewPlayer.GotoState('Spectating');

	// Init player's name
	if( InName=="" )
		InName=DefaultPlayerName;
	if( Level.NetMode!=NM_Standalone || NewPlayer.PlayerReplicationInfo.PlayerName==DefaultPlayerName )
		ChangeName( NewPlayer, InName, false );

	// RWS CHANGE: Merged bOnlySpectator test from UT2003
	if ( bSpectator || NewPlayer.PlayerReplicationInfo.bOnlySpectator )
	{
        NewPlayer.PlayerReplicationInfo.bOnlySpectator = true;
		NewPlayer.PlayerReplicationInfo.bIsSpectator = true;
        // RWS CHANGE: Merged bOutOfLives and PlayerID assignments from UT2003
		NewPlayer.PlayerReplicationInfo.bOutOfLives = true;
	    NewPlayer.PlayerReplicationInfo.PlayerID = CurrentID++;
		NumSpectators++;
		return NewPlayer;
	}

	// Setup player's pawn class
	InClass = ParseOption( Options, "Class" );
	if ( InClass != "" )
	{
		DesiredPawnClass = class<Pawn>(DynamicLoadObject(InClass, class'Class'));
		if ( DesiredPawnClass != None )
			NewPlayer.PawnClass = DesiredPawnClass;
	}

	// Change player's team.
	if ( !ChangeTeam(newPlayer, InTeam, false) )
	{
		Error = GameMessageClass.Default.FailedTeamMessage;
		return None;
	}

	// RWS CHANGE: Do real admin login in PostLogin
	// Init player's administrative privileges and log it
    //if (AccessControl.AdminLogin(NewPlayer, InPassword))
    //{
	//	AccessControl.AdminEntered(NewPlayer);
    //}

	// Set the player's ID.
	NewPlayer.PlayerReplicationInfo.PlayerID = CurrentID++;

	// Log it.
	NewPlayer.ReceivedSecretChecksum = !(InChecksum ~= "NoChecksum");

	NumPlayers++;

	// If we are a server, broadcast a welcome message.
	if( Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer )
		BroadcastLocalizedMessage(GameMessageClass, 1, NewPlayer.PlayerReplicationInfo);

	// if delayed start, don't give a pawn to the player yet
	// Normal for multiplayer games
	if ( bDelayedStart )
	{
		NewPlayer.GotoState('PlayerWaiting');
		return NewPlayer;	
	}

	// Try to match up to existing unoccupied player in level,
	// for savegames and coop level switching.
	ForEach DynamicActors(class'Pawn', TestPawn )
	{
		if ( (TestPawn!=None) && (PlayerController(TestPawn.Controller)!=None) && (PlayerController(TestPawn.Controller).Player==None) && (TestPawn.Health > 0)
			&&  (TestPawn.OwnerName~=InName) )
		{
			NewPlayer.Destroy();
			TestPawn.SetRotation(TestPawn.Controller.Rotation);
			TestPawn.bInitializeAnimation = false; // FIXME - temporary workaround for lack of meshinstance serialization
			TestPawn.PlayWaiting();
			return PlayerController(TestPawn.Controller);
		}
	}
	return newPlayer;
}	

/* StartMatch()
Start the game - inform all actors that the match is starting, and spawn player pawns
*/
function StartMatch()
{	
	local Controller P;
	local Actor A; 

	if (GameStats!=None)
		GameStats.StartGame();

	// tell all actors the game is starting
	ForEach AllActors(class'Actor', A)
		A.MatchStarting();

	// start human players first
	for ( P = Level.ControllerList; P!=None; P=P.nextController )
		if ( P.IsA('PlayerController') && (P.Pawn == None) )
		{
            if ( bGameEnded )
                return; // telefrag ended the game with ridiculous frag limit
			// RWS CHANGE: Merged call to CanRestartPlayer() from UT2003
            else if ( PlayerController(P).CanRestartPlayer()  )
			{
				RestartPlayer(P);
				SendStartMessage(PlayerController(P));
			}
		}

	// start AI players
	for ( P = Level.ControllerList; P!=None; P=P.nextController )
		if ( P.bIsPlayer && !P.IsA('PlayerController') )
        {
			if ( Level.NetMode == NM_Standalone )
				RestartPlayer(P);
        	else
				P.GotoState('Dead','MPStart');
		}

	bWaitingToStartMatch = false;
	GameReplicationInfo.bMatchHasBegun = true;
}

//
// Restart a player.
//
function RestartPlayer( Controller aPlayer )	
{
	local NavigationPoint startSpot;
	local int TeamNum;
	local class<Pawn> DefaultPlayerClass;

	if( bRestartLevel && Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
		return;

	if ( (aPlayer.PlayerReplicationInfo == None) || (aPlayer.PlayerReplicationInfo.Team == None) )
		TeamNum = 255;
	else
		TeamNum = aPlayer.PlayerReplicationInfo.Team.TeamIndex;

	startSpot = FindPlayerStart(aPlayer, TeamNum);
	if( startSpot == None )
	{
		log(" Player start not found!!!");
		return;
	}	
	
/* RWS CHANGE: Removed to match UT2003
	if ( (aPlayer.PlayerReplicationInfo.Team != None)
		&& ((aPlayer.PawnClass == None) || !aPlayer.PlayerReplicationInfo.Team.BelongsOnTeam(aPlayer.PawnClass)) )
			aPlayer.PawnClass = aPlayer.PlayerReplicationInfo.Team.DefaultPlayerClass;
*/
	if (aPlayer.PreviousPawnClass!=None && aPlayer.PawnClass != aPlayer.PreviousPawnClass)
		BaseMutator.PlayerChangedClass(aPlayer);			
			
	if ( aPlayer.PawnClass != None )
		aPlayer.Pawn = Spawn(aPlayer.PawnClass,,,StartSpot.Location,StartSpot.Rotation);

	if( aPlayer.Pawn==None )
	{
// RWS CHANGE: Merged assignment of function return value from UT2003
		DefaultPlayerClass = GetDefaultPlayerClass(aPlayer);
		aPlayer.Pawn = Spawn(DefaultPlayerClass,,,StartSpot.Location,StartSpot.Rotation);
	}
	if ( aPlayer.Pawn == None )
	{
		log("Couldn't spawn player of type "$aPlayer.PawnClass$" at "$StartSpot);
		aPlayer.GotoState('Dead');
		return;
	}

	// RWS CHANGE: Merged anti-spawn-camping from UT2003
	aPlayer.Pawn.LastStartSpot = PlayerStart(startSpot);
	aPlayer.Pawn.LastStartTime = Level.TimeSeconds;
	aPlayer.PreviousPawnClass = aPlayer.Pawn.Class;

	aPlayer.Possess(aPlayer.Pawn);
	aPlayer.PawnClass = aPlayer.Pawn.Class;

// RWS CHANGE: Merged fix from UT2003 to call pawn function instead of controller function
	aPlayer.Pawn.PlayTeleportEffect(true, true);
	aPlayer.ClientSetRotation(aPlayer.Pawn.Rotation);
	AddDefaultInventory(aPlayer.Pawn);

	// RWS CHANGE: Added log message to make debugging scripted stuff a little easier
	if (StartSpot.Event != '')
		Log("PlayerStart "$StartSpot$" is triggering event "$StartSpot.Event);
	TriggerEvent( StartSpot.Event, StartSpot, aPlayer.Pawn);
}

function class<Pawn> GetDefaultPlayerClass(Controller C)
{
// RWS CHANGE: Merged from UT2003
    local PlayerController PC;
    local String PawnClassName;
    local class<Pawn> PawnClass;

    PC = PlayerController( C );

    // RWS CHANGE: For Singleplayer, just get the default player class
	if( PC != None && !bIsSinglePlayer)
    {
        PawnClassName = PC.GetDefaultURL( "Class" );
        PawnClass = class<Pawn>( DynamicLoadObject( PawnClassName, class'Class') );

		if( PawnClass != None )
            return( PawnClass );
    }

    return( class<Pawn>( DynamicLoadObject( DefaultPlayerClassName, class'Class' ) ) );
}

function SendStartMessage(PlayerController P)
{
	P.ClearProgressMessages();
}


//
// Called after a successful login. This is the first place
// it is safe to call replicated functions on the PlayerPawn.
//
// RWS CHANGE: Tacked on Options for admin logging in
event PostLogin( PlayerController NewPlayer, string Options )
{
	local class<HUD> HudClass;
	local class<Scoreboard> ScoreboardClass;

    // Log player's login.
	if (GameStats!=None)
	{
		GameStats.ConnectEvent(NewPlayer.PlayerReplicationInfo);
		GameStats.GameEvent("NameChange",NewPlayer.PlayerReplicationInfo.playername,NewPlayer.PlayerReplicationInfo);
	}

	if ( !bDelayedStart )
	{
		// start match, or let player enter, immediately
		bRestartLevel = false;	// let player spawn once in levels that must be restarted after every death
		if ( bWaitingToStartMatch )
			StartMatch();
		// RWS FIX: After loading a saved game, player will already have a pawn so don't give him another one
		else if ( NewPlayer.IsA('PlayerController') && (NewPlayer.Pawn == None) )
			RestartPlayer(NewPlayer);
		bRestartLevel = Default.bRestartLevel;
	}

	// Start player's music.
	NewPlayer.ClientSetMusic( Level.Song, MTRAN_Fade );
	
	// tell client what hud and scoreboard to use
	// RWS CHANGE: Merged improved checking and logging from UT2003
    if( HUDType == "" )
        log(self @ "No HUDType specified in GameInfo" );
	else
	{
		HudClass = class<HUD>(DynamicLoadObject(HUDType, class'Class'));

        if( HudClass == None )
            log( "Can't find HUD class "$HUDType, 'Error' );
	}

    if( ScoreBoardType == "" )
        log(self @ "No ScoreBoardType specified in GameInfo" );
    else
    {
        ScoreboardClass = class<Scoreboard>(DynamicLoadObject(ScoreBoardType, class'Class'));

        if( ScoreboardClass == None )
            log( "Can't find ScoreBoard class "$ScoreBoardType, 'Error' );
    }
	NewPlayer.ClientSetHUD( HudClass, ScoreboardClass );

	if ( NewPlayer.Pawn != None )
		NewPlayer.Pawn.ClientSetRotation(NewPlayer.Pawn.Rotation);

    // RWS CHANGE: Do admin login through the player controller's console command
	NewPlayer.ConsoleCommand("adminlogin" @ ParseOption(Options, "Password"));
}

//
// Player exits.
//
function Logout( Controller Exiting )
{
	local bool bMessage;

	bMessage = true;
	if ( PlayerController(Exiting) != None )
	{
		// RWS CHANGE: Merged some Admin stuff from 2199
		if ( AccessControl.AdminLogout( PlayerController(Exiting) ) )
			AccessControl.AdminExited( PlayerController(Exiting) );

        // RWS CHANGE: Moved bOnlySpectator to PRI
		if ( PlayerController(Exiting).PlayerReplicationInfo.bOnlySpectator )
		{
			bMessage = false;
			NumSpectators--;
		}
		else
			NumPlayers--;
	}
	if( bMessage && (Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer) )
		BroadcastLocalizedMessage(GameMessageClass, 4, Exiting.PlayerReplicationInfo);

	if ( GameStats!=None)
		GameStats.DisconnectEvent(Exiting.PlayerReplicationInfo);
}

//
// Examine the passed player's inventory, and accept or discard each item.
// AcceptInventory needs to gracefully handle the case of some inventory
// being accepted but other inventory not being accepted (such as the default
// weapon).  There are several things that can go wrong: A weapon's
// AmmoType not being accepted but the weapon being accepted -- the weapon
// should be killed off. Or the player's selected inventory item, active
// weapon, etc. not being accepted, leaving the player weaponless or leaving
// the HUD inventory rendering messed up (AcceptInventory should pick another
// applicable weapon/item as current).
//
event AcceptInventory(pawn PlayerPawn)
{
	//default accept all inventory except default weapon (spawned explicitly)
}

//
// Spawn any default inventory for the player.
//
function AddDefaultInventory( pawn PlayerPawn )
{
	local Weapon newWeapon;
	local class<Weapon> WeapClass;

	// Spawn default weapon.
	WeapClass = BaseMutator.GetDefaultWeapon();
	if( (WeapClass!=None) && (PlayerPawn.FindInventoryType(WeapClass)==None) )
	{
		newWeapon = Spawn(WeapClass,,,PlayerPawn.Location);
		if( newWeapon != None )
		{
			newWeapon.GiveTo(PlayerPawn);
			newWeapon.BringUp();
			newWeapon.bCanThrow = false; // don't allow default weapon to be thrown out
		}
	}
	SetPlayerDefaults(PlayerPawn);
}

/* SetPlayerDefaults()
 first make sure pawn properties are back to default, then give mutators an opportunity
 to modify them
*/
function SetPlayerDefaults(Pawn PlayerPawn)
{
    // RWS CHANGE: Merged setting of additional vars from UT2003
	PlayerPawn.AirControl = PlayerPawn.Default.AirControl;
    PlayerPawn.GroundSpeed = PlayerPawn.Default.GroundSpeed;
    PlayerPawn.WaterSpeed = PlayerPawn.Default.WaterSpeed;
    PlayerPawn.AirSpeed = PlayerPawn.Default.AirSpeed;
    PlayerPawn.Acceleration = PlayerPawn.Default.Acceleration;
	PlayerPawn.JumpZ = PlayerPawn.Default.JumpZ;
	BaseMutator.ModifyPlayer(PlayerPawn);
}

function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn )
{
	local Controller C;

	for ( C=Level.ControllerList; C!=None; C=C.nextController )
		C.NotifyKilled(Killer, Killed, KilledPawn);
}

function KillEvent(string Killtype, PlayerReplicationInfo Killer, PlayerReplicationInfo Victim, class<DamageType> Damage)
{
	if ( GameStats != None )
		GameStats.KillEvent(KillType, Killer, Victim, Damage);
}

function Killed( Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType )
{
	if ( (Killed != None) && Killed.bIsPlayer )
	{
		Killed.PlayerReplicationInfo.Deaths += 1;
		BroadcastDeathMessage(Killer, Killed, damageType);

		if ( (Killer == Killed) || (Killer == None) )
		{
			if ( Killer == None )
				KillEvent("K", None, Killed.PlayerReplicationInfo, DamageType);	//"Kill"
			else
				KillEvent("K", Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, DamageType);	//"Kill"
		}
		else
		{
			if ( bTeamGame && (Killer.PlayerReplicationInfo != None)
				&& (Killer.PlayerReplicationInfo.Team == Killed.PlayerReplicationInfo.Team) )
				KillEvent("TK", Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, DamageType);	//"Teamkill"
			else
				KillEvent("K", Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo, DamageType);	//"Kill"
		}
	}
    if ( Killed != None )
		ScoreKill(Killer, Killed);
	DiscardInventory(KilledPawn);
    NotifyKilled(Killer,Killed,KilledPawn);
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if ( GameRulesModifiers == None )
		return false;
	return GameRulesModifiers.PreventDeath(Killed,Killer, damageType,HitLocation);
}

function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> damageType)
{
	if ( (Killer == Other) || (Killer == None) )
        BroadcastLocalized(self,DeathMessageClass, 1, None, Other.PlayerReplicationInfo, damageType);
	else 
        BroadcastLocalized(self,DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, damageType);
}


// %k = Owner's PlayerName (Killer)
// %o = Other's PlayerName (Victim)
// %w = Owner's Weapon ItemName
static native function string ParseKillMessage( string KillerName, string VictimName, string DeathMessage );

function Kick( string S )
{
	AccessControl.Kick(S);
}
function KickBan( string S )
{
	AccessControl.KickBan(S);
}

function bool IsOnTeam(Controller Other, int TeamNum)
{
    // RWS CHANGE: Merged bIsPlayer test from UT2003
	if ( bTeamGame && (Other != None) && Other.bIsPlayer
		&& (Other.PlayerReplicationInfo.Team != None)
		&& (Other.PlayerReplicationInfo.Team.TeamIndex == TeamNum) )
		return true;
	return false;
}

//-------------------------------------------------------------------------------------
// Level gameplay modification.

//
// Return whether Viewer is allowed to spectate from the
// point of view of ViewTarget.
//
function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
{
	return true;
}

/* Use reduce damage for teamplay modifications, etc.
*/
function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
	local int OriginalDamage;
	local armor FirstArmor;

	OriginalDamage = Damage;

	if( injured.PhysicsVolume.bNeutralZone )
		Damage = 0;
	else if ( injured.InGodMode() ) // God mode
		return 0;
	else if ( (injured.Inventory != None) && (damage > 0) ) //then check if carrying armor
	{
		FirstArmor = injured.inventory.PrioritizeArmor(Damage, DamageType, HitLocation);
		while( (FirstArmor != None) && (Damage > 0) )
		{
			Damage = FirstArmor.ArmorAbsorbDamage(Damage, DamageType, HitLocation);
			FirstArmor = FirstArmor.nextArmor;
		} 
	}

	if ( GameRulesModifiers != None )
		return GameRulesModifiers.NetDamage( OriginalDamage, Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );

	return Damage;
}

//
// Return whether an item should respawn.
//
function bool ShouldRespawn( Pickup Other )
{
	if( Level.NetMode == NM_StandAlone )
		return false;

	return Other.ReSpawnTime!=0.0;
}

/* Called when pawn has a chance to pick Item up (i.e. when 
   the pawn touches a weapon pickup). Should return true if 
   he wants to pick it up, false if he does not want it.
*/
function bool PickupQuery( Pawn Other, Pickup item )
{
	local byte bAllowPickup;

	if ( (GameRulesModifiers != None) && GameRulesModifiers.OverridePickupQuery(Other, item, bAllowPickup) )
		return (bAllowPickup == 1);

	if ( Other.Inventory == None )
		return true;
	else
		return !Other.Inventory.HandlePickupQuery(Item);
}
		
/* Discard a player's inventory after he dies.
*/
function DiscardInventory( Pawn Other )
{
	local inventory Inv,Next;
	local float speed;
	local int Count;

	if( (Other.Weapon!=None) && Other.Weapon.bCanThrow && Other.Weapon.HasAmmo() )
	{
		if ( Other.Weapon.PickupAmmoCount == 0 )
			Other.Weapon.PickupAmmoCount = 1;
		speed = VSize(Other.Velocity);
		if (speed != 0)
			Other.TossWeapon(Normal(Other.Velocity/speed + 0.5 * VRand()) * (speed + 280));
		else 
			Other.TossWeapon(vect(0,0,0));
	}
	Other.Weapon = None;
	Other.SelectedItem = None;
	Inv = Other.Inventory;
	while ( Inv != None )
	{
		Next = Inv.Inventory;
		Inv.Destroy();
		Inv = Next;
		Count++;
		if (Count > 5000)
			break;
	}	
	Other.Inventory = None;	// RWS CHANGE: All inventory has been destroyed
}

/* Try to change a player's name.
*/	
function ChangeName( Controller Other, coerce string S, bool bNameChange )
{
	local Controller C;

	if( S == "" )
		return;

	Other.PlayerReplicationInfo.SetPlayerName(S);
    // notify local players
	if( bNameChange && (PlayerController(Other) != None) )
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
			if ( (PlayerController(C) != None) && (Viewport(PlayerController(C).Player) != None) )
				PlayerController(C).ReceiveLocalizedMessage( class'GameMessage', 2, Other.PlayerReplicationInfo );
}

/* Return whether a team change is allowed.
*/
// RWS CHANGE: Added bNewTeam parm from UT2003
function bool ChangeTeam(Controller Other, int N, bool bNewTeam)
{
	return true;
}

/* Return a picked team number if none was specified
*/
// RWS CHANGE: Addded C parm from UT2003
function byte PickTeam(byte Current, Controller C)
{
	return Current;
}

/* Send a player to a URL.
*/
function SendPlayer( PlayerController aPlayer, string URL )
{
	aPlayer.ClientTravel( URL, TRAVEL_Relative, true );
}

/* Restart the game.

  RWS WARNING
	This functionality has been duplicated in MpGameInfo because we use a different
	naming scheme for maps and it wasn't easy to update this code.  When merging
	future changes into this function you probably want to update MpGameInfo, too.
*/
function RestartGame()
{
	local string NextMap;
	local MapList MyList;

	if ( (GameRulesModifiers != None) && GameRulesModifiers.HandleRestartGame() )
		return;

	if ( bGameRestarted )
		return;
    bGameRestarted = true;

	// these server travels should all be relative to the current URL
	if ( bChangeLevels && !bAlreadyChanged && (MapListType != "") )
	{
		// open a the nextmap actor for this game type and get the next map
		bAlreadyChanged = true;
        MyList = GetMapList(MapListType);
		if (MyList != None)
		{
			NextMap = MyList.GetNextMap();
			MyList.Destroy();
		}
		if ( NextMap == "" )
			NextMap = GetMapName(MapPrefix, NextMap,1);

		if ( NextMap != "" )
		{
			Level.ServerTravel(NextMap, false);
			return;
		}
	}

	Level.ServerTravel( "?Restart", false );
}

// RWS CHANGE: Merged from UT2003
function MapList GetMapList(string MapListType)
{
local class<MapList> MapListClass;

	if (MapListType != "")
	{
        MapListClass = class<MapList>(DynamicLoadObject(MapListType, class'Class'));
		if (MapListClass != None)
			return Spawn(MapListClass);
	}
	return None;
}

//==========================================================================
// Message broadcasting functions (handled by the BroadCastHandler)

event Broadcast( Actor Sender, coerce string Msg, optional name Type )
{
	BroadcastHandler.Broadcast(Sender,Msg,Type);
}

function BroadcastTeam( Controller Sender, coerce string Msg, optional name Type )
{
	BroadcastHandler.BroadcastTeam(Sender,Msg,Type);
}

/*
 Broadcast a localized message to all players.
 Most message deal with 0 to 2 related PRIs.
 The LocalMessage class defines how the PRI's and optional actor are used.
*/
event BroadcastLocalized( actor Sender, class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	BroadcastHandler.AllowBroadcastLocalized(Sender,Message,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
}

//==========================================================================
	
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local Controller P;

	if ( (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
		return false;

	// all player cameras focus on winner or final scene (picked by gamerules)
	for ( P=Level.ControllerList; P!=None; P=P.NextController )
	{
		P.ClientGameEnded();
        // RWS CHANGE: Merged from UT2003
		P.GameHasEnded();
	}	
	return true;
}

/* End of game.
*/
function EndGame( PlayerReplicationInfo Winner, string Reason )
{
	// don't end game if not really ready
	if ( !CheckEndGame(Winner, Reason) )
	{
		bOverTime = true;
		return;
	}

	bGameEnded = true;
	TriggerEvent('EndGame', self, None);
	EndLogging(Reason);
}

function EndLogging(string Reason)
{
	if (GameStats == None)
		return;

	GameStats.EndGame(Reason);
	GameStats.Destroy();
	GameStats = None;
}

/* Return the 'best' player start for this player to start from.
 */
function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string incomingName )
{
	local NavigationPoint N, BestStart;
	local Teleporter Tel;
	local float BestRating, NewRating;
	local byte Team;

	// always pick StartSpot at start of match
	// RWS CHANGE: Merged extra test from UT2003
    if ( (Player != None) && (Player.StartSpot != None) && (Level.NetMode == NM_Standalone)
		&& (bWaitingToStartMatch || ((Player.PlayerReplicationInfo != None) && Player.PlayerReplicationInfo.bWaitingPlayer))  )
	{
		return Player.StartSpot;
	}	

	if ( GameRulesModifiers != None )
	{
		N = GameRulesModifiers.FindPlayerStart(Player,InTeam,incomingName);
		if ( N != None )
		    return N;
	}

	// if incoming start is specified, then just use it
	if( incomingName!="" )
		foreach AllActors( class 'Teleporter', Tel )
			if( string(Tel.Tag)~=incomingName )
				return Tel;

	// use InTeam if player doesn't have a team yet
	if ( (Player != None) && (Player.PlayerReplicationInfo != None) )
	{
		if ( Player.PlayerReplicationInfo.Team != None )
			Team = Player.PlayerReplicationInfo.Team.TeamIndex;
		else
			Team = 0;
	}
	else
		Team = InTeam;

	for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
	{
		NewRating = RatePlayerStart(N,InTeam,Player);
		if ( NewRating > BestRating )
		{
			BestRating = NewRating;
			BestStart = N;
		}
	}
	
	if ( BestStart == None )
	{
		log("Warning - PATHS NOT DEFINED or NO PLAYERSTART");			
		foreach AllActors( class 'NavigationPoint', N )
		{
			NewRating = RatePlayerStart(N,0,Player);
			if ( NewRating > BestRating )
			{
				BestRating = NewRating;
				BestStart = N;	
			}
		}
	}

	return BestStart;
}

/* Rate whether player should choose this NavigationPoint as its start
default implementation is for single player game
*/
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
	local PlayerStart P;

	P = PlayerStart(N);
	if ( P != None )
	{
		if (MapPreviewPoint(P) != None)
			return 9999;
		if ( P.bSinglePlayerStart )
		{
			if ( P.bEnabled )
				return 1000;
			return 20;
		}
		return 10;
	}
	return 0;
}

function ScoreObjective(PlayerReplicationInfo Scorer, Int Score)
{
	if ( Scorer != None )
	{
		Scorer.Score += Score;
        /* RWS CHANGE: Removed to match UT2003
		if ( Scorer.Team != None )
			Scorer.Team.Score += Score;
		*/
	}
	if ( GameRulesModifiers != None )
		GameRulesModifiers.ScoreObjective(Scorer,Score);

	CheckScore(Scorer);
}

/* CheckScore()
see if this score means the game ends
*/
function CheckScore(PlayerReplicationInfo Scorer)
{
	if ( (GameRulesModifiers != None) && GameRulesModifiers.CheckScore(Scorer) )
		return;
}
	
// RWS CHANGE: Merged from UT2003
function ScoreEvent(PlayerReplicationInfo Who, float Points, string Desc)
{
	if (GameStats!=None)
		GameStats.ScoreEvent(Who,Points,Desc);
}

// RWS CHANGE: Merged from UT2003
function TeamScoreEvent(int Team, float Points, string Desc)
{
	if ( GameStats != None )
		GameStats.TeamScoreEvent(Team, Points, Desc);
}

function ScoreKill(Controller Killer, Controller Other)
{
    if( (killer == Other) || (killer == None) )
	{
    	if (Other!=None)
        {
			Other.PlayerReplicationInfo.Score -= 1;
			ScoreEvent(Other.PlayerReplicationInfo,-1,"self_frag");
        }
	}
    else if ( killer.PlayerReplicationInfo != None )
	{
		Killer.PlayerReplicationInfo.Score += 1;
		Killer.PlayerReplicationInfo.Kills++;
		ScoreEvent(Killer.PlayerReplicationInfo,1,"frag");
	}

	if ( GameRulesModifiers != None )
		GameRulesModifiers.ScoreKill(Killer, Other);

    if ( (Killer != None) || (MaxLives > 0) )
		CheckScore(Killer.PlayerReplicationInfo);
}

// RWS CHANGE: Added parm from UT2003
function bool TooManyBots(Controller botToRemove)
//function bool TooManyBots()
{
	return false;
}

// RWS CHANGE: Merged from UT2003
function TeamInfo OtherTeam(TeamInfo Requester)
{
	return None;
}

// RWS CHANGE: Merged from UT2003
exec function KillBots(int num);

// RWS CHANGE: Merged from UT2003
exec function AdminSay(string Msg)
{
	local controller C;

	for( C=Level.ControllerList; C!=None; C=C.nextController )
		if( C.IsA('PlayerController') )
		{
			PlayerController(C).ClearProgressMessages();
			PlayerController(C).SetProgressTime(6);
			PlayerController(C).SetProgressMessage(0, Msg, class'Canvas'.Static.MakeColor(255,255,255));
		}
}

// Kamek 1/17 - add native function for deleting saves
native function bool DeleteSave(int slotNo);

defaultproperties
{
	bDelayedStart=true
	HUDType="Engine.HUD"
	bWaitingToStartMatch=false
	bLoggingGame=False
	MaxPlayers=16
    GameDifficulty=+1.0
    bRestartLevel=True
    bPauseable=True
    bCanChangeSkin=True
	bCanViewOthers=true
    bChangeLevels=True
    AutoAim=1.000000
    GameSpeed=1.000000
    MaxSpectators=2
    DefaultPlayerName="Player"
	GameName="Game"
	MutatorClass="Engine.Mutator"
	BroadcastHandlerClass="Engine.BroadcastHandler"
	DeathMessageClass=class'LocalMessage'
	bEnableStatLogging=false
	GameStatsClass="MultiBase.MPGameStats"
	AccessControlClass="Engine.AccessControl"
	PlayerControllerClassName="Engine.PlayerController"
	GameMessageClass=class'GameMessage'
	GameReplicationInfoClass=class'GameReplicationInfo'
	bGameHighDetail=true
	MatineeFastForwardSpeed=4.0
}
