//=============================================================================
// TeamInfo.
//=============================================================================
class TeamInfo extends ReplicationInfo
	native
	nativereplication;

// RWS CHANGE: Made localized per UT2003
var localized string TeamName;
var int Size; //number of players on this team in the level
var float Score;
var int TeamIndex;
var color TeamColor, AltTeamColor;
var texture TeamIcon;
// RWS CHANGE: Renamed to more generic name per UT2003
var Actor HomeBase;			// key objective associated with this team
var() class<Pawn> DefaultPlayerClass;
var localized string ColorNames[4];

replication
{
	// Variables the server should send to the client.
	reliable if( bNetDirty && (Role==ROLE_Authority) )
		Score, HomeBase;
	reliable if ( bNetInitial && (Role==ROLE_Authority) )
		TeamName, TeamColor, AltTeamColor, TeamIcon, TeamIndex;
}

function bool BelongsOnTeam(class<Pawn> PawnClass)
{
	return true;
}

simulated function string GetHumanReadableName()
{
	if ( TeamName == Default.TeamName )
	{
		if ( TeamIndex < 4 )
			return ColorNames[TeamIndex];
		return TeamName@TeamIndex;
	}
	return TeamName;
}

function bool AddToTeam( Controller Other )
{
	local Controller P;
	local bool bSuccess;

	// make sure loadout works for this team
	if ( Other == None )
	{
		log("Added none to team!!!");
		return false;
	}

	// RWS CHANGE: Merged from UT2003
	if (MessagingSpectator(Other) != None)
		return false;

	Size++;
	Other.PlayerReplicationInfo.Team = self;
	bSuccess = false;
	if ( Other.IsA('PlayerController') )
		Other.PlayerReplicationInfo.TeamID = 0;
	else
		Other.PlayerReplicationInfo.TeamID = 1;

	while ( !bSuccess )
	{
		bSuccess = true;
		for ( P=Level.ControllerList; P!=None; P=P.nextController )
            if ( P.bIsPlayer && (P != Other) 
				&& (P.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) 
				&& (P.PlayerReplicationInfo.TeamId == Other.PlayerReplicationInfo.TeamId) )
				bSuccess = false;
		if ( !bSuccess )
			Other.PlayerReplicationInfo.TeamID = Other.PlayerReplicationInfo.TeamID + 1;
	}
	return true;
}

function RemoveFromTeam(Controller Other)
{
	Size--;
}

defaultproperties
{
	TeamName="Team"
	TeamColor=(R=255,G=0,B=0,A=255)
	AltTeamColor=(R=200,G=0,B=0,A=255)
	TeamIcon=S_Actor
	ColorNames(0)="Red"
	ColorNames(1)="Blue"
	ColorNames(2)="Green"
	ColorNames(3)="Gold"
}
