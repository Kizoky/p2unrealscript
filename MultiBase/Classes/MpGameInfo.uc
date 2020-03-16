class MpGameInfo extends P2GameInfoMulti
	config;

var globalconfig int			MinPlayers;				// bots fill in to guarantee this level in net game 
var globalconfig bool			bAutoFillBots;			// use bots to fill to minplayers if true
var globalconfig float			BotDifficulty;			// use this instead of GameDifficulty

var config bool					bTeamScoreRounds;
var bool						bSoaking;
var float						EndTime;
var globalconfig float			EndTimeDelay;
var config bool					bExtendedScoring;		// score = kills - deaths

var string						MapNameGameCode;		// A character which preceeds the "-" in a map name to
														// indicate that map is compatible with one or more games
														// Ex: ABC-MyMap is compatible with "A", "B" and "C" games

function SpecialEvent(PlayerReplicationInfo Who, string Desc)
{
	if ( GameStats != None )
		GameStats.SpecialEvent(Who,Desc);
}

function Killed( Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType )
{
	// Ignore non-person kills
	if (KilledPawn != None && P2Pawn(KilledPawn) == None)
		return;

	Super.Killed(Killer, Killed, KilledPawn, damageType);
}

function KillEvent(string Killtype, PlayerReplicationInfo Killer, PlayerReplicationInfo Victim, class<DamageType> Damage)
{
	local MpPlayerReplicationInfo TPRI;

/* RWS CHANGE: We're not currently tracking these stats
	if ( (Killer == None) || (Killer == Victim) )
		MpPlayerReplicationInfo(Victim).Suicides++;

	TPRI = MpPlayerReplicationInfo(Killer);

	if ( TPRI != None )
	{
		if ( TPRI != Victim )
			TPRI.AddWeaponKill(Damage);
		MpPlayerReplicationInfo(Victim).AddWeaponDeath(Damage);
	}
*/
	if ( GameStats != None )
		GameStats.KillEvent(KillType, Killer, Victim, Damage);
}

function GameEvent(string GEvent, string Desc, PlayerReplicationInfo Who)
{
	local MpPlayerReplicationInfo TPRI;

	if ( GameStats != None )
		GameStats.GameEvent(GEvent, Desc, Who);

/* RWS CHANGE: We don't use these stats
	TPRI = MpPlayerReplicationInfo(Who);

	if ( TPRI == None )
		return;

	if ( (GEvent ~= "flag_taken") || (GEvent ~= "flag_pickup")
		|| (GEvent ~= "bomb_taken") || (GEvent ~= "Bomb_pickup") )
	{
		TPRI.FlagTouches++;
		return;
	}

	if ( GEvent ~= "flag_returned" )
	{
		TPRI.FlagReturns++;
		return;
	}
*/
}

function ScoreKill(Controller Killer, Controller Other)
{
	Super.ScoreKill(Killer,Other);

	if (bExtendedScoring)
	{
		// With this method, getting killed reduces your score by 1, but we never let it go negative
		// because (a) it confuses/annoys people, and (b) when people join a game in progress with
		// a score of 0 it puts them in the middle of the field instead of in last place.  Both of
		// these situations suck, so we decided flooring the score at 0 worked out pretty well.

		// Suicides already reduce your score (see super) so we only want to reduce the score
		// if it's NOT a suicide, which is what this wacky statement checks for.
		if(!(((killer == Other) || (killer == None)) && (Other != None)))
		{
			if (Other != None)
			{
				if (Other.PlayerReplicationInfo.Score > 0)
					Other.PlayerReplicationInfo.Score -= 1;
			}
		}
	}
}

function ScoreEvent(PlayerReplicationInfo Who, float Points, string Desc)
{
	if ( GameStats != None )
		GameStats.ScoreEvent(Who,Points,Desc);
}

function TeamScoreEvent(int Team, float Points, string Desc)
{
	if ( GameStats != None )
		GameStats.TeamScoreEvent(Team,Points,Desc);
}

function int GetNumPlayers()
{
	if ( NumPlayers > 0 )
		return (NumPlayers+NumBots);
	return Min(MinPlayers,MaxPlayers/2);
}

function bool ShouldRespawn(Pickup Other)
{
	return false;
}

function float SpawnWait(AIController B)
{
	if ( B.PlayerReplicationInfo.bOutOfLives )
		return 999;
	if ( Level.NetMode == NM_Standalone )
		return ( 0.5 * FMax(2,NumBots-4) * FRand() );
	return FRand();
}

function bool TooManyBots(Controller botToRemove) //amb
{
	return ( (Level.NetMode != NM_Standalone) && (NumBots + NumPlayers > MinPlayers) );
}

function RestartGame()
{
	local Actor A;
	local string NextMap;
	local MapList MyList;

	if ( EndTime > Level.TimeSeconds ) // still showing end screen
		return;

	// DO NOT CALL SUPER!  We use a different naming scheme for our multiplayer maps
	// and the super couldn't easily be modified to handle it, so we duplicate the 
	// super functionality here and make the necessary changes.
	
	if ( (GameRulesModifiers != None) && GameRulesModifiers.HandleRestartGame() )
		return;

	if ( bGameRestarted )
		return;
    bGameRestarted = true;

	// these server travels should all be relative to the current URL
	if ( bChangeLevels && !bAlreadyChanged && (MapListType != "") )
	{
		// open a the nextmap actor for this game type and get the next map
		bAlreadyChanged = true;
        MyList = GetMapList(MapListType);
		if (MyList != None)
		{
			NextMap = MyList.GetNextMap();
			MyList.Destroy();
		}
		if ( NextMap == "" )
			NextMap = class'FPSGame.FPSGameInfo'.static.GetGameMap(MapNameGameCode, NextMap,1);

		if ( NextMap != "" )
		{
			Level.ServerTravel(NextMap, false);
			return;
		}
	}

	Level.ServerTravel( "?Restart", false );
}

function ChangeLoadOut(PlayerController P, string LoadoutName);
function ForceAddBot();

/* only allow pickups if they are in the pawns loadout
*/
function bool PickupQuery(Pawn Other, Pickup item)
{
	local byte bAllowPickup;

	if ( (GameRulesModifiers != None) && GameRulesModifiers.OverridePickupQuery(Other, item, bAllowPickup) )
		return (bAllowPickup == 1);

	if ( (MpPawn(Other) != None) && !MpPawn(Other).IsInLoadout(item.inventorytype) )
		return false;

	if ( Other.Inventory == None )
		return true;
	else
		return !Other.Inventory.HandlePickupQuery(Item);
}

function InitPlacedBot(Controller C, RosterEntry R);

static function string CleanMapName(string MapName)
{
	local string Clean;
	local int Dash;

	// Strip the extension
	if(Right(MapName, 4) ~= ".fuk")
		Clean = Left(MapName, Len(MapName) - 4);
	else
		Clean = MapName;

	// Strip the prefix
	Dash = InStr(Clean, "-");
	if (Dash > 0)
		Clean = Mid(Clean, Dash+1);

	return Clean;
}

defaultproperties
{
	DefaultPlayerClassName="MultiStuff.MpDude"
	PlayerControllerClassName="MultiStuff.xMpPlayer"
	bTeamScoreRounds=false
	bExtendedScoring=true
	bChangeLevels=true
    EndTimeDelay=+4.0
	bAutoFillBots=true
	MinPlayers=4
	BotDifficulty=5.0
}
