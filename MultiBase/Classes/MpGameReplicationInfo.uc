class MpGameReplicationInfo extends GameReplicationInfo;


var bool						bGrudgeMatch;		// Assigned by GameInfo.
var TeamInfo					DMRoster;

replication
{
	reliable if ( bNetInitial && (Role==ROLE_Authority) )
		bGrudgeMatch, DMRoster;
}


defaultproperties
{
	 ServerName="Another Postal 2 Server"
	 ShortName="Postal 2 Server"
}
