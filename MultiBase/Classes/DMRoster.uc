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

// Change by NickP: MP fix
function RosterEntry GetNextBot()
{
	local int i, n;
	local array<int> RandRoster;

	for ( i=0; i<Roster.Length; i++ )
		if ( !Roster[i].bTaken )
		{
			n = RandRoster.Length;
			RandRoster.Insert(n, 1);
			RandRoster[n] = i;

			//Roster[i].bTaken = true;
			//return Roster[i];
		}

	if( RandRoster.Length != 0 )
	{
		i = RandRoster[Rand(RandRoster.Length-1)];
		Roster[i].bTaken = true;
		return Roster[i];
	}

	i = Roster.Length;
	Roster.Length = Roster.Length + 1;
	Roster[i] = GetRandomPlayer();
	Roster[i].bTaken = true;
	return Roster[i];
}
// End

defaultproperties
{
	TeamIndex=255
	bSuitableForTeamGames=false
	bHighlyHomogeneous=false;
}
