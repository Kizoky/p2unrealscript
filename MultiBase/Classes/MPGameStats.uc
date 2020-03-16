// ====================================================================
//  Class:  MPGameStats
//  Parent: Engine.GameStats
//
//  Logs things to a text file for each individual match. Stats file is then
// parsed by a seperate program to view player stats for various matches.
//
//
// Chr(9) is a tab.
//
// Player code means PlayerNum/Player ID/Player password, etc.
// In this case it's the PlayerName$MpPlayer.StatsPassword all as one string.
// This represents each player in the stats. If the person doesn't have
// a password, they're not shown in the stats. If they need to show
// up in a log but don't have a player code, they they show up as 0.
// Ex:	For the KillEvent that wants to show
//		the victim, it simply shows the victim as 0 for player code for 'non existant'.
//
// Here are the event codes:
//
// NG is New Game, starts with time, time zone, map name, map title, map author, game class, game name, mutator list
// SG is Start Game
// EG is End Game, starts with reason game ended (fraglimit, timelimit, lastman, teamscorelimit), 
//		followed by a list of all player codes in order of score (like a scoreboard)
// SI is serverinfo, starts with servername, time zone, admin name, admin email, ip port
// C  is Connect, followed by player code
// D  is Disconnect, followed by player code
// G  is a Game event like namechange, etc.
//		NameChange shows the player name and the player code. (use this to link to the player name)
//		TeamChange
//		flag_taken
//		flag_returned
//		flag_returned_timeout
//		flag_pickup
//		flag_captured
//		flag_dropped
// S  is a Score event, starts with the player code, point value (like 1 for a frag), 
//	  and score event description:
//		(frag,self_frag,
//		tdm_frag (you kill enemy team member),team_frag(suicide on opposite team),
//		flag_cap,flag_ret_friendly,flag_ret_enemy,flag_denial,flag_cap_1st_touch,flag_cap_assist,flag_cap_final,
//		objectivescore,game_objective_score)
// T  is a TeamScore event, starts with team number, points scored, description
//		(tdm_frag (you kill enemy team member),team_frag(suicide on opposite team), 
//		flag_cap, game_objective_score,)
// K  is a Kill event, 
//		starts player code of killer (-1 is used for suicides/environment deaths), damage type 
//		inflicted by killer, victim player code, victim weapon at the time
// P  is a Special event
//		type_kill is when a player is killed while typing, starts with killer player code, type_kill (as description)
//
//	Here are the damage types and the weapons they represent (as seen from the KillEvent)
//  BatonDamage:		Baton
//  ShovelDamage:		Shovel
//	BulletDamage:		Pistol
//  ShotgunDamage:		Shotgun
//  MachinegunDamage:   machinegun
//  AnthDamage:			Cowhead
//	BurnedDamage:		Molotov
//	FireExplodedDamage: Molotov
//	OnFirDamage:		Molotov
//  CuttingDamage:		Scissors
//  GrenadeDamage:      Grenades
//  RocketDamage:		Rockets
//  KickingDamage		Foot
//  RifleDamage:		Sniper rifle
// 
// ====================================================================

class MPGameStats extends GameStats;



///////////////////////////////////////////////////////////////////////////////
// Send stats for the end of the game
///////////////////////////////////////////////////////////////////////////////
function EndGame(string Reason)
{
	local string out;
	local int i,j;
	local GameReplicationInfo GRI;
	local array<PlayerReplicationInfo> PRIs;
	local PlayerReplicationInfo PRI,t;

	out = Header()$"EG"$Chr(9)$Reason;	// "EndGame"

	GRI = Level.Game.GameReplicationInfo;

	// Quick cascade sort.
	for (i=0;i<GRI.PRIArray.Length;i++)
	{
		PRI = GRI.PRIArray[i];
		if ( !PRI.bOnlySpectator && !PRI.bBot )
		{
			PRIs.Length = PRIs.Length+1;
			for (j=0;j<Pris.Length-1;j++)
			{
				if (PRIs[j].Score < PRI.Score ||
				   (PRIs[j].Score == PRI.Score && PRIs[j].Deaths > PRI.Deaths) )
				{
					t = PRIs[j];
					PRIs[j] = PRI;
					PRI = t;
				}
			}
			PRIs[j] = PRI;
		}
	}

	// Minimal scoreboard, shows player codes in order of Score
	for (i=0;i<PRIs.Length;i++)
	{
		if(MpPlayer(PRIs[i].Owner).StatsPassword != "")
			out = out$chr(9)$PRIs[i].PlayerName$MpPlayer(PRIs[i].Owner).StatsPassword;
	}
	//out = out$chr(9)$PRIs[i].PlayerName;
		
	Logf(out);
}	


///////////////////////////////////////////////////////////////////////////////
// Connect Events get fired every time a player connects to a server
///////////////////////////////////////////////////////////////////////////////
function ConnectEvent(PlayerReplicationInfo Who)
{
	local string out;
	if ( Who.bBot || Who.bOnlySpectator )			// Spectators should never show up in stats!
		return;

	// C	0	11d8944d9e138a5aa688d503e0e4c3e0
	if(MpPlayer(Who.Owner).StatsPassword != "")
	{
		out = ""$Header()$"C"$Chr(9)$Who.PlayerName$MpPlayer(Who.Owner).StatsPassword$Chr(9);

	// Login identifier
	// RWS Change, Not including this right now becuase in C it requires some giant password from UConn.cpp that we
	// don't support and probably don't want.
//	out = out$GetStatsIdentifier(Controller(Who.Owner));
		Logf(out);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Connect Events get fired every time a player connects or leaves from a server
///////////////////////////////////////////////////////////////////////////////
function DisconnectEvent(PlayerReplicationInfo Who)
{
	local string out;
	if ( Who.bBot || Who.bOnlySpectator )			// Spectators should never show up in stats!
		return;

	if(MpPlayer(Who.Owner).StatsPassword != "")
	{
		// D	0	
		out = ""$Header()$"D"$Chr(9)$Who.PlayerName$MpPlayer(Who.Owner).StatsPassword;	//"Disconnect"

		Logf(out);
	}
}


///////////////////////////////////////////////////////////////////////////////
// Scoring Events occur when a player's score changes
///////////////////////////////////////////////////////////////////////////////
function ScoreEvent(PlayerReplicationInfo Who, float Points, string Desc)
{
	if ( Who.bBot || Who.bOnlySpectator )			// Just to be totally safe Spectators sends nothing
		return;

	if(MpPlayer(Who.Owner).StatsPassword != "")
	{
		Logf( ""$Header()$"S"$chr(9)$Who.PlayerName$MpPlayer(Who.Owner).StatsPassword$chr(9)$Points$chr(9)$Desc );	//"Score"
	}
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function TeamScoreEvent(int Team, float Points, string Desc)
{
	Logf( ""$Header()$"T"$Chr(9)$Team$Chr(9)$Points$Chr(9)$Desc );	//"TeamScore"
}


///////////////////////////////////////////////////////////////////////////////
// KillEvents occur when a player kills, is killed, suicides
///////////////////////////////////////////////////////////////////////////////
function KillEvent(string Killtype, PlayerReplicationInfo Killer, PlayerReplicationInfo Victim, class<DamageType> Damage)
{
	local string out;
	
	if ( Victim.bBot || Victim.bOnlySpectator || ((Killer != None) && Killer.bBot) )
		return;

	if(MpPlayer(Killer.Owner).StatsPassword != "")
	{

		out = ""$Header()$Killtype$Chr(9);

		// KillerNumber and KillerDamagetype
		if (Killer!=None)
		{
			out = out$Killer.PlayerName$MpPlayer(Killer.Owner).StatsPassword$Chr(9);
			// KillerWeapon no longer used, using damagetype
			out = out$GetItemName(string(Damage))$Chr(9);
		}
		else
			out = out$"-1"$chr(9)$GetItemName(string(Damage))$Chr(9);	// No Playercode -> -1, Environment "deaths"

		// VictimNumber and VictimWeapon
		if(MpPlayer(Victim.Owner).StatsPassword != "")
			out = out$Victim.PlayerName$MpPlayer(Victim.Owner).StatsPassword$chr(9)$GetItemName(string(Controller(Victim.Owner).GetLastWeapon()));
		else // not entered into stats
			out = out$"0"$chr(9)$GetItemName(string(Controller(Victim.Owner).GetLastWeapon()));

		// Type killers tracked as player event (redundant Typing, removed from kill line)
		if ( PlayerController(Victim.Owner)!= None && PlayerController(Victim.Owner).bIsTyping)
		{
			if ( PlayerController(Killer.Owner) != PlayerController(Victim.Owner) )	
				SpecialEvent(Killer, "type_kill");						// Killer killed typing victim
		}

		Logf(out);
	}
}


///////////////////////////////////////////////////////////////////////////////
// Special Events are everything else regarding the player
///////////////////////////////////////////////////////////////////////////////
function SpecialEvent(PlayerReplicationInfo Who, string Desc)
{
	local string out;

	if(MpPlayer(Who.Owner).StatsPassword != "")
	{
		if (Who != None)
		{
			if ( Who.bBot || Who.bOnlySpectator )		// Avoid spectator suicide on console "type_kill"
				return;
			out = ""$Who.PlayerName$MpPlayer(Who.Owner).StatsPassword;
		}
		else
			out = "-1";

		Logf( ""$Header()$"P"$Chr(9)$out$Chr(9)$Desc );					//"PSpecial"
	}
}


///////////////////////////////////////////////////////////////////////////////
// Special events regarding the game
///////////////////////////////////////////////////////////////////////////////
function GameEvent(string GEvent, string Desc, PlayerReplicationInfo Who)
{
	local string out, tab, geDesc;

	if(MpPlayer(Who.Owner).StatsPassword != "")
	{
		if (Who != None)
		{
			if ( Who.bBot || Who.bOnlySpectator )		// Specator could cause NameChange, TeamChange! No longer.
				return;
			out = ""$Who.PlayerName$MpPlayer(Who.Owner).StatsPassword;
		}
		else
			out = "-1";

		geDesc	= Desc;
		tab		= ""$Chr(9);
		ReplaceText(geDesc, tab, "_");									// geDesc, can be the nickname!

		Logf( ""$Header()$"G"$Chr(9)$GEvent$Chr(9)$out$Chr(9)$geDesc );	//"GSpecial"
	}
}

defaultproperties
{
}
