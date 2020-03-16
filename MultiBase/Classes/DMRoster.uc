// DMRoster
// Holds list of pawns to use in this DM battle

class DMRoster extends MpTeamInfo;

var int Position;

function bool AddToTeam(Controller Other)
{
	local SquadAI DMSquad;

	if ( Bot(Other) != None )
	{
		DMSquad = spawn(DeathMatch(Level.Game).DMSquadClass);
		DMSquad.AddBot(Bot(Other));
	}
	Other.PlayerReplicationInfo.Team = None;
	return true;
}

defaultproperties
{
	TeamIndex=255
	bSuitableForTeamGames=false
	bHighlyHomogeneous=false;
}
