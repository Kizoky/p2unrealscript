//=============================================================================
// GameReplicationInfo.
//=============================================================================
class GameReplicationInfo extends ReplicationInfo
	native nativereplication;

var string GameName;						// Assigned by GameInfo.
var string GameClass;						// Assigned by GameInfo.
var bool bTeamGame;							// Assigned by GameInfo.
var bool bStopCountDown;
// RWS CHANGE: Merged from UT2003
var bool bMatchHasBegun;
var int  RemainingTime, ElapsedTime, RemainingMinute;
var float SecondCount;
var int GoalScore;
var int TimeLimit;
// RWS CHANGE: Merged from UT2003
var int MaxLives;

var TeamInfo Teams[2];

var() globalconfig string ServerName;		// Name of the server, i.e.: Bob's Server.
var() globalconfig string ShortName;		// Abbreviated name of server, i.e.: B's Serv (stupid example)
var() globalconfig string AdminName;		// Name of the server admin.
var() globalconfig string AdminEmail;		// Email address of the server admin.
var() globalconfig int	  ServerRegion;		// Region of the game server.

var() globalconfig string MOTDLine1;		// Message
var() globalconfig string MOTDLine2;		// Of
var() globalconfig string MOTDLine3;		// The
var() globalconfig string MOTDLine4;		// Day

var Actor Winner;			// set by gameinfo when game ends

// RWS CHANGE: Merged PRIArray from UT2003
var() array<PlayerReplicationInfo> PRIArray;

// RWS CHANGE: Merged flag replication from UT2003
var vector FlagPos[2];	// replicated 2D position of one object
var EFlagState FlagState[2];
var PlayerReplicationInfo FlagHolder[2];	// hack to work around flag holder replication FIXME remove when break net compatibility

replication
{
	reliable if ( bNetDirty && (Role == ROLE_Authority) )
		RemainingMinute, bStopCountDown, Winner, Teams, 
		FlagPos, FlagState, FlagHolder, bMatchHasBegun;

	reliable if ( bNetInitial && (Role==ROLE_Authority) )
		GameName, GameClass, bTeamGame, 
		RemainingTime, ElapsedTime,MOTDLine1, MOTDLine2, 
		MOTDLine3, MOTDLine4, ServerName, ShortName, AdminName,
		AdminEmail, ServerRegion, GoalScore, MaxLives, TimeLimit;
}

simulated function PostNetBeginPlay()
{
	local PlayerReplicationInfo PRI;
	
	ForEach DynamicActors(class'PlayerReplicationInfo',PRI)
		AddPRI(PRI);
}

simulated function PostBeginPlay()
{
	if( Level.NetMode == NM_Client )
	{
		// clear variables so we don't display our own values if the server has them left blank 
		ServerName = "";
		AdminName = "";
		AdminEmail = "";
		MOTDLine1 = "";
		MOTDLine2 = "";
		MOTDLine3 = "";
		MOTDLine4 = "";
	}

	SecondCount = Level.TimeSeconds;
	SetTimer(1, true);
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	Winner = None;
}

simulated function Timer()
{
	local int i;
	local PlayerReplicationInfo OldHolder[2];
	local Controller C;
	
	if ( Level.NetMode == NM_Client )
	{
		if (Level.TimeSeconds - SecondCount >= Level.TimeDilation)
		{
			ElapsedTime++;
			if ( RemainingMinute != 0 )
			{
				RemainingTime = RemainingMinute;
				RemainingMinute = 0;
			}
			if ( (RemainingTime > 0) && !bStopCountDown )
				RemainingTime--;
			SecondCount += Level.TimeDilation;
		}
	}
	else if ( Level.NetMode != NM_Standalone )
	{
		OldHolder[0] = FlagHolder[0];
		OldHolder[1] = FlagHolder[1];
		for ( i=0; i<PRIArray.length; i++ )
			if ( (PRIArray[i].HasFlag != None) && (PRIArray[i].Team != None) )
				FlagHolder[PRIArray[i].Team.TeamIndex] = PRIArray[i];

	/* RWS CHANGE: Removed epic's workaround for not replicating FlagHolder
		for ( i=0; i<2; i++ )
			if ( OldHolder[i] != FlagHolder[i] )
			{
				for ( C=Level.ControllerList; C!=None; C=C.NextController )
					if ( PlayerController(C) != None )
						PlayerController(C).ClientUpdateFlagHolder(FlagHolder[i],i);
			}
	*/
	}
}

// RWS CHANGE: Merged PRIArray from UT2003
simulated function AddPRI(PlayerReplicationInfo PRI)
{
    PRIArray[PRIArray.Length] = PRI;
}

// RWS CHANGE: Merged PRIArray from UT2003
simulated function RemovePRI(PlayerReplicationInfo PRI)
{
    local int i;

    for (i=0; i<PRIArray.Length; i++)
    {
        if (PRIArray[i] == PRI)
            break;
    }

    if (i == PRIArray.Length)
    {
        log("GameReplicationInfo::RemovePRI() pri="$PRI$" not found.", 'Error');
        return;
    }

    PRIArray.Remove(i,1);
}

defaultproperties
{
	FlagState[0]=FLAG_Home
	FlagState[1]=FLAG_Home
	bStopCountDown=true
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
	ServerName="Another Server"
	ShortName="Server"
	MOTDLine1=""
	MOTDLine2=""
	MOTDLine3=""
	MOTDLine4=""
}
