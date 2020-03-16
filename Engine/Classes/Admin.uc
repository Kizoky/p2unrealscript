class Admin extends AdminBase;

// Execute an administrative console command on the server.
exec function DoLogin( string Password )
{
	if (Level.Game.AccessControl.AdminLogin(Outer, Password))
	{
		bAdmin = true;
		Level.Game.AccessControl.AdminEntered(Outer);
	}
}

exec function DoLogout()
{
	if (Level.Game.AccessControl.AdminLogout(Outer))
	{
		bAdmin = false;
		Level.Game.AccessControl.AdminExited(Outer);
	}
}

exec function KickBan( string S )
{
	Level.Game.KickBan(S);
}

exec function Kick( string S )
{
	Level.Game.Kick(S);
}

exec function PlayerList()
{
	local PlayerReplicationInfo PRI;

	log("Player List:");
	ForEach DynamicActors(class'PlayerReplicationInfo', PRI)
		log(PRI.PlayerName@"(ping"@PRI.Ping$")");
}

exec function RestartMap()
{
	ClientTravel( "?restart", TRAVEL_Relative, false );
}

exec function Switch( string URL )
{
	Level.ServerTravel( URL, false );
}

exec function NextMap()
{
	if (bAdmin)
    {
		Level.Game.bChangeLevels=true;
        Level.Game.bAlreadyChanged=false;
		Level.Game.RestartGame();
    }
}

defaultproperties
{
}
