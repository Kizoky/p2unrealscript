//=============================================================================
// AccessControl.
//
// AccessControl is a helper class for GameInfo.
// The AccessControl class determines whether or not the player is allowed to 
// login in the PreLogin() function, and also controls whether or not a player 
// can enter as a spectator or a game administrator.
//
//=============================================================================
//
// RWS CHANGE: Lots of merges from the newer UT2003 scheme
//
//=============================================================================
class AccessControl extends Info
	config;

var globalconfig string     IPPolicies[50];
var	localized string          IPBanned;
var	localized string	      WrongPassword;
var	localized string          NeedPassword;
var class<AdminBase>		  AdminClass;

var bool bReplyToGUI;

var private string AdminPassword;						// Password to receive bAdmin privileges.
var private globalconfig string GamePassword;		    // Password to enter game.

var private PlayerController KickedPlayer;		// Person we need to eventually destroy after they've been kicked/banned

function bool AdminLogin( PlayerController P, string Password)
{
	if (ValidLogin(Password)
		||		// RWS CHANGE: Always let listen server player be admin
			(Level.NetMode == NM_ListenServer
			&& Role == ROLE_Authority
			&& ViewPort(P.Player) != None))
	{
		P.PlayerReplicationInfo.bAdmin = true;
		return true;
	}
	return false;
}

function bool AdminLogout( PlayerController P )
{
	if (P.PlayerReplicationInfo.bAdmin)
	{
		P.PlayerReplicationInfo.bAdmin = false;
		return true;
	}
	return false;
}

function AdminEntered( PlayerController P )
{
	Log(P.PlayerReplicationInfo.PlayerName@"logged in as Administrator.");
	Level.Game.Broadcast( P, P.PlayerReplicationInfo.PlayerName@"logged in as a server administrator." );
}

function AdminExited( PlayerController P )
{
	Log(P.PlayerReplicationInfo.PlayerName@"logged out from Administrator.");
	Level.Game.Broadcast( P, P.PlayerReplicationInfo.PlayerName@"gave up administrator abilities.");
}

function bool IsAdmin(PlayerController P)
{
	return P.PlayerReplicationInfo.bAdmin;
}

function SetAdminPassword(string P)
{
	AdminPassword = P;
}

function SetGamePassword(string P)
{
	GamePassword = P;
}

function bool RequiresPassword()
{
	return GamePassword != "";
}

function Kick( string S ) 
{
	local PlayerController P;
	local bool bResult;

	ForEach DynamicActors(class'PlayerController', P)
		if ( P.PlayerReplicationInfo.PlayerName~=S 
			&&	(NetConnection(P.Player)!=None) 
			&& !IsAdmin(P) )
		{
			// RWS CHANGE: Tell player he got kicked before destroying AND log him out

			// Destroy any previos kicked player that hasn't been destroyed yet
			Timer();

			KickedPlayer = P;
			// Tell player he got kicked
			P.ProgressCommand("menu:kick", Localize("Errors", "ConnectLost", "Engine"), Localize("Errors", "Kicked", "Engine"));
			// Log player out
			Level.Game.Logout(P);
			// Destroy his pawn, just in case
			if(P.Pawn != None)
				P.Pawn.Destroy();
			// Give a chance for the client to leave, then destroy it if it's still there
			SetTimer(2, false);
			return;
		}
}

function Timer()
{
	if(KickedPlayer != None)
	{
		KickedPlayer.Destroy();
		KickedPlayer = None;
	}
}

function KickBan( string S ) 
{
	local PlayerController P;
	local string IP;
	local int j;

	ForEach DynamicActors(class'PlayerController', P)
		if ( P.PlayerReplicationInfo.PlayerName~=S 
			&&	(NetConnection(P.Player)!=None) )
		{
			IP = P.GetPlayerNetworkAddress();
			if( CheckIPPolicy(IP) && !IsAdmin(P))
			{
				IP = Left(IP, InStr(IP, ":"));
				Log("Adding IP Ban for: "$IP);
				for(j=0;j<50;j++)
					if( IPPolicies[j] == "" )
						break;
				if(j < 50)
					IPPolicies[j] = "DENY,"$IP;
				SaveConfig();
			}
			if(!IsAdmin(P))
				Kick(P.PlayerReplicationInfo.PlayerName);
			return;
		}
}

function bool CheckOptionsAdmin( string Options)
{
	local string InPassword;

	InPassword = Level.Game.ParseOption( Options, "Password" );
	return ValidLogin(InPassword);
}

function bool ValidLogin(string Password)
{
	return (AdminPassword != "" && Password==AdminPassword);
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
	out string FailCode,
	bool bSpectator
)

{
	// Do any name or password or name validation here.
	local string InPassword;
	local bool   bAdmin;

	Error="";
	InPassword = Level.Game.ParseOption( Options, "Password" );
	bAdmin = CheckOptionsAdmin(Options);

	if( (Level.NetMode != NM_Standalone) && !bAdmin && Level.Game.AtCapacity(bSpectator) )
	{
		Error=Level.Game.GameMessageClass.Default.MaxedOutMessage;
	}
	else if	( GamePassword!="" && caps(InPassword)!=caps(GamePassword) && !bAdmin )
	{
		if( InPassword == "" )
		{
			Error = NeedPassword;
			FailCode = "NEEDPW";
		}
		else
		{
			Error = WrongPassword;
			FailCode = "WRONGPW";
		}
	}

	if(!CheckIPPolicy(Address))
		Error = IPBanned;
}


function bool CheckIPPolicy(string Address)
{
	local int i, j, LastMatchingPolicy;
	local string Policy, Mask;
	local bool bAcceptAddress, bAcceptPolicy;
	
	// strip port number
	j = InStr(Address, ":");
	if(j != -1)
		Address = Left(Address, j);

	bAcceptAddress = True;
	for(i=0; i<50 && IPPolicies[i] != ""; i++)
	{
		j = InStr(IPPolicies[i], ",");
		if(j==-1)
			continue;
		Policy = Left(IPPolicies[i], j);
		Mask = Mid(IPPolicies[i], j+1);
		if(Policy ~= "ACCEPT") 
			bAcceptPolicy = True;
		else if(Policy ~= "DENY") 
			bAcceptPolicy = False;
		else
			continue;

		j = InStr(Mask, "*");
		if(j != -1)
		{
			if(Left(Mask, j) == Left(Address, j))
			{
				bAcceptAddress = bAcceptPolicy;
				LastMatchingPolicy = i;
			}
		}
		else
		{
			if(Mask == Address)
			{
				bAcceptAddress = bAcceptPolicy;
				LastMatchingPolicy = i;
			}
		}
	}

	if(!bAcceptAddress)
		Log("Denied connection for "$Address$" with IP policy "$IPPolicies[LastMatchingPolicy]);
		
	return bAcceptAddress;
}

defaultproperties
{
	WrongPassword="The password you entered is incorrect."
	NeedPassword="You need to enter a password to join this game."
	IPBanned="Your IP address has been banned on this server."
	IPPolicies(0)="ACCEPT,*"
	AdminClass=class'Engine.Admin'
}