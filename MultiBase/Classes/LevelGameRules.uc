class LevelGameRules extends Info;

var() bool			bSpawnInTeamArea;			// players spawn in marked team playerstarts
var() int			RecommendedNumPlayers[2];	// recommended players (bots will fill out in single player)
var() string		DefaultRosters[2];
var() string		DefaultDMRoster;

var MpTeamInfo		Rosters[2];
var DMRoster		DMRoster;


function bool GetSpawnInTeamArea()
{
	return bSpawnInTeamArea;
}

function string GetTeamRosterName(int i)
{
	return DefaultRosters[i];
}

function string GetRosterName()
{
	return DefaultDMRoster;
}

function Trigger(Actor Other, Pawn EventInstigator)
{
	Level.Game.EndGame(EventInstigator.PlayerReplicationInfo,"triggered");
} 

defaultproperties
{
	Event=EndGame
	RemoteRole=ROLE_None
	bSpawnInTeamArea=false
	RecommendedNumPlayers(0)=4
	RecommendedNumPlayers(1)=4
	Texture=Texture'PostEd.Icons_256.LevelGamePlay'
	DrawScale=0.25
}