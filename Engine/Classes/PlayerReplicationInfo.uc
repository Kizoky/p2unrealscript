//=============================================================================
// PlayerReplicationInfo.
//=============================================================================
class PlayerReplicationInfo extends ReplicationInfo
	native nativereplication;

var float				Score;			// Player's current score.
var float				Deaths;			// Number of player's deaths.
var Decoration			HasFlag;
var int					Ping;
// RWS CHANGE: Merged volume/location stuff from UT2003
var Volume				PlayerVolume;
var ZoneInfo            PlayerZone;
var int					NumLives;

var string				PlayerName;		// Player name, or blank if none.
var string				OldName, PreviousName;		// Temporary value.
var int					PlayerID;		// Unique id number.
var TeamInfo			Team;			// Player Team
var int					TeamID;			// Player position in team.
var class<VoicePack>	VoiceType;
// RWS CHANGE: Merged bAdmin from UT2003
var bool				bAdmin;				// Player logged in as Administrator
var bool				bIsFemale;
// RWS CHANGE: Dropped this feature
//var bool				bFeigningDeath;
var bool				bIsSpectator;
// RWS CHANGE: Merged bOnlySpectator from UT2003
var bool				bOnlySpectator;
var bool				bWaitingPlayer;
var bool				bReadyToPlay;
var bool				bOutOfLives;
var bool				bBot;
// RWS CHANGE: Dropped this feature
//var Texture				TalkTexture;
// RWS CHANGE: Merged new ping calculation from UT2003
var bool				bReceivedPing;

// Time elapsed.
var int					StartTime;
// RWS CHANGE: Unused, so removed it
//var int					TimeAcc;

// RWS CHANGE: Merged volume/location stuff from UT2003
var localized String	StringDead;
var localized String    StringSpectating;
var localized String	StringUnknown;

// RWS CHANGE: Merged goals and kills from UT2003
var int					GoalsScored;		// not replicated - used on server side only
var int					Kills;				// RWS CHANGE: we replicate this

replication
{
	// Things the server should send to the client.
	reliable if ( bNetDirty && (Role == Role_Authority) )
		Score, Deaths, HasFlag, PlayerVolume, PlayerZone,
		PlayerName, Team, TeamID, VoiceType, bIsFemale, bAdmin, 
		bIsSpectator, bOnlySpectator, bWaitingPlayer, bReadyToPlay,
		bOutOfLives, Kills;
	reliable if ( bNetDirty && (!bNetOwner || bDemoRecording) && (Role == Role_Authority) )
		Ping; 
	reliable if ( bNetInitial && (Role == Role_Authority) )
		StartTime, bBot;
}

function PostBeginPlay()
{
// RWS CHANGE: Merged from UT2003
	if ( Role < ROLE_Authority )
		return;
    if (AIController(Owner) != None)
        bBot = true;
	StartTime = Level.Game.GameReplicationInfo.ElapsedTime;
	Timer();
	SetTimer(1.5 + FRand(), true);
// RWS CHANGE: Else
//	StartTime = Level.TimeSeconds;
//	Timer();
//	SetTimer(2.0, true);
// RWS CHANGE: End
}

// RWS CHANGE: Merged PRIArray from UT2003
simulated function PostNetBeginPlay()
{
	local GameReplicationInfo GRI;
	
	ForEach DynamicActors(class'GameReplicationInfo',GRI)
	{
		GRI.AddPRI(self);
		break;
	}
}

// RWS CHANGE: Merged PRIArray from UT2003
simulated function Destroyed()
{
	local GameReplicationInfo GRI;
	
	ForEach DynamicActors(class'GameReplicationInfo',GRI)
        GRI.RemovePRI(self);
        
    Super.Destroyed();
}
	
/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	Score = 0;
	Deaths = 0;
	HasFlag = None;
	bReadyToPlay = false;
	NumLives = 0;
	bOutOfLives = false;
	GoalsScored = 0;
	Kills = 0;
}

// RWS CHANGE: See new func below
//simulated function string GetLocationName()
//{
//	if ( PlayerLocation != None )
//		return PlayerLocation.LocationName;
//	else
//		return"";
//}

simulated function string GetHumanReadableName()
{
	return PlayerName;
}

// RWS CHANGE: Merged new volume/location stuff from UT2003
simulated function string GetLocationName()
{
    if( ( PlayerVolume == None ) && ( PlayerZone == None ) )
    {
    	if ( (Owner != None) && Controller(Owner).IsInState('Dead') )
        	return StringDead;
        else
			return StringSpectating;
    }
    
	if( ( PlayerVolume != None ) && ( PlayerVolume.LocationName != class'Volume'.Default.LocationName ) )
		return PlayerVolume.LocationName;
	else if( PlayerZone != None && ( PlayerZone.LocationName != "" )  )
		return PlayerZone.LocationName;
    else if ( Level.Title != Level.Default.Title )
		return Level.Title;
	else
        return StringUnknown;
}

function UpdatePlayerLocation()
{
// RWS CHANGE: Merged new volume/location stuff from UT2003
    local Volume V, Best;
    local Pawn P;
    local Controller C;
    
    C = Controller(Owner);

    if( C != None )
        P = C.Pawn;
    
    if( P == None )
    {
        PlayerVolume = None;
        PlayerZone = None;
        return;
    }
    
    if ( PlayerZone != P.Region.Zone )
		PlayerZone = P.Region.Zone;

    foreach P.TouchingActors( class'Volume', V )
    {
        if( V.LocationName == "") 
            continue;
        
        if( (Best != None) && (V.LocationPriority <= Best.LocationPriority) )
            continue;
            
        if( V.Encompasses(P) )
            Best = V;
    }
    if ( PlayerVolume != Best )
		PlayerVolume = Best;
// RWS CHANGE: Else
//	local Volume V;
//
//	PlayerLocation = None;
//	ForEach TouchingActors(class'Volume',V)
//		if ( (V.LocationName != "") 
//			&& ((PlayerLocation == None) || (V.LocationPriority > PlayerLocation.LocationPriority))
//			&& V.Encompasses(self) )
//		{
//			PlayerLocation = V;
//		}
// RWS CHANGE: End
}

/* DisplayDebug()
list important controller attributes on canvas
*/
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	if ( Team != None )
		Canvas.DrawText("     PlayerName "$PlayerName$" Team "$Team.GetHumanReadableName()$" has flag "$HasFlag);
	else
		Canvas.DrawText("     PlayerName "$PlayerName$" NO Team");
}
 					
function Timer()
{
// RWS CHANGE: Merged a few minor changes from UT2003
    local Controller C;

	UpdatePlayerLocation();
	SetTimer(1.5 + FRand(), true);
	if( FRand() < 0.65 )
		return;

	if( !bBot )
	{
	    C = Controller(Owner);
		// RWS CHANGE: Merged new ping calculation from UT2003
		if ( !bReceivedPing )
			Ping = int(C.ConsoleCommand("GETPING"));
	}
// RWS CHANGE: Else
//	UpdatePlayerLocation();
//
//	if ( FRand() < 0.65 )
//		return;
//
//	if (PlayerController(Owner) != None)
//		Ping = int(Controller(Owner).ConsoleCommand("GETPING"));
// RWS CHANGE: End
}

function SetPlayerName(string S)
{
	OldName = PlayerName;
	PlayerName = S;
}

function SetWaitingPlayer(bool B)
{
	bIsSpectator = B;	
	bWaitingPlayer = B;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
    StringSpectating="Spectating"
    StringUnknown="Unknown"
    StringDead="Dead"
    NetUpdateFrequency=5
}
