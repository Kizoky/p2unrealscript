//=============================================================================
// CTFGame.
//=============================================================================
class CTFGame extends TeamGame
	config;

var sound CaptureSound[2];
var sound ReturnSounds[2];
var sound DroppedSounds[2];

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTeamFlags();
}

function float SpawnWait(AIController B)
{
	if ( B.PlayerReplicationInfo.bOutOfLives )
		return 999;
	if ( Level.NetMode == NM_Standalone )
	{
		if ( !CTFSquadAI(Bot(B).Squad).FriendlyFlag.bHome && (Numbots <= 16) )
			return FRand();
		return ( 0.5 * FMax(2,NumBots-4) * FRand() );
	}
	return FRand();
}

function SetTeamFlags()
{
	local CTFFlag F;

	// associate flags with teams
	ForEach AllActors(Class'CTFFlag',F)
	{
		F.Team = Teams[F.TeamNum];
		F.Team.HomeBase = F.HomeBase;
		CTFTeamAI(F.Team.AI).FriendlyFlag = F;
		if ( F.TeamNum == 0 )
			CTFTeamAI(Teams[1].AI).EnemyFlag = F;
		else
			CTFTeamAI(Teams[0].AI).EnemyFlag = F;
	}
}

function Logout(Controller Exiting)
{
	if ( Exiting.PlayerReplicationInfo.HasFlag != None )
		CTFFlag(Exiting.PlayerReplicationInfo.HasFlag).Drop(vect(0,0,0));	
	Super.Logout(Exiting);
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local CTFFlag BestFlag;
	local Controller P;
	local PlayerController Player;
    local bool bLastMan;
    
	if ( bOverTime )
	{
		if ( Numbots + NumPlayers == 0 )
			return true;
		bLastMan = true;
		for ( P=Level.ControllerList; P!=None; P=P.nextController )
			if ( (P.PlayerReplicationInfo != None) && !P.PlayerReplicationInfo.bOutOfLives )
			{
				bLastMan = false;
				break;
			}
		if ( bLastMan )
			return true;
	}			

    bLastMan = ( Reason ~= "LastMan" );

	if ( (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
		return false;

	if ( bLastMan )
		GameReplicationInfo.Winner = Winner.Team;
	else
	{
		if ( Teams[1].Score == Teams[0].Score )
		{
			if ( !bOverTimeBroadcast )
			{
				StartupStage = 7;
				PlayStartupMessage();
				bOverTimeBroadcast = true;
			}
			return false;
		}		
		if ( Teams[1].Score > Teams[0].Score )
			GameReplicationInfo.Winner = Teams[1];
		else
			GameReplicationInfo.Winner = Teams[0];
//			if ( CurrentGameProfile != None )
//				CurrentGameProfile.bWonMatch = (Player.PlayerReplicationInfo.Team == GameReplicationInfo.Winner);
	}

	BestFlag = CTFTeamAI(MpTeamInfo(GameReplicationInfo.Winner).AI).FriendlyFlag;
	EndGameFocus = BestFlag.HomeBase;
	EndGameFocus.bHidden = false;

	if (MpTeamInfo(GameReplicationInfo.Winner).TeamIndex == 0)
	{
		CheerleaderClass1 = class'CheerleadersHotRed';
		CheerleaderClass2 = class'CheerleadersHotBlue2';
	}
	else
	{
		CheerleaderClass1 = class'CheerleadersHotBlue2';
		CheerleaderClass2 = class'CheerleadersHotRed';
	}

	EndTime = Level.TimeSeconds + EndTimeDelay;
	for ( P=Level.ControllerList; P!=None; P=P.nextController )
	{
		if(P != None)
			P.GameHasEnded();
		Player = PlayerController(P);
		if ( Player != None )
		{
			Player.ClientSetBehindView(true);
			Player.ClientSetViewTarget(EndGameFocus);
			Player.SetViewTarget(EndGameFocus);
			PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == GameReplicationInfo.Winner));
			Player.ClientGameEnded();
		}
	}
	BestFlag.HomeBase.bHidden = false;
	BestFlag.bHidden = true;
	return true;
}

function ScoreFlag(Controller Scorer, CTFFlag theFlag)
{
	local float Dist,oppDist;
	local int i;
	local float ppp,numtouch;
	local vector FlagLoc;

	if ( Scorer.PlayerReplicationInfo.Team == theFlag.Team )
	{
		FlagLoc = TheFlag.Position().Location;
		Dist = vsize(FlagLoc - TheFlag.HomeBase.Location);
		
		if (TheFlag.TeamNum==0)
			oppDist = vsize(FlagLoc - Teams[1].HomeBase.Location);
		else
  			oppDist = vsize(FlagLoc - Teams[0].HomeBase.Location); 
	
		GameEvent("flag_returned",""$theFlag.Team.TeamIndex,Scorer.PlayerReplicationInfo);
		BroadcastLocalizedMessage( class'CTFMessage', 1, Scorer.PlayerReplicationInfo, None, TheFlag.Team );
		
		if (Dist>1024)
		{
			// figure out who's closer
				
			if (Dist<=oppDist)	// In your team's zone
			{
				Scorer.PlayerReplicationInfo.Score += 3;
				ScoreEvent(Scorer.PlayerReplicationInfo,3,"flag_ret_friendly");
			}
			else
			{
				Scorer.PlayerReplicationInfo.Score += 5;
				ScoreEvent(Scorer.PlayerReplicationInfo,5,"flag_ret_enemy");
				
				if (oppDist<=1024)	// Denial
				{
  					Scorer.PlayerReplicationInfo.Score += 7;
					ScoreEvent(Scorer.PlayerReplicationInfo,7,"flag_denial");
				}
					
			}					
		} 
		return;
	}
	
	// Figure out Team based scoring.
	if (TheFlag.FirstTouch!=None)	// Original Player to Touch it gets 5
	{
		ScoreEvent(TheFlag.FirstTouch.PlayerReplicationInfo,5,"flag_cap_1st_touch");
		TheFlag.FirstTouch.PlayerReplicationInfo.Score += 5;
	}
		
	// Guy who caps gets 5
	Scorer.PlayerReplicationInfo.Score += 5;
	IncrementGoalsScored(Scorer.PlayerReplicationInfo);
	
	// Each player gets 20/x but it's guarenteed to be at least 1 point but no more than 5 points 
	numtouch=0;	
	for (i=0;i<TheFlag.Assists.length;i++)
	{
		if (TheFlag.Assists[i]!=None)
			numtouch = numtouch + 1.0;
	}
	
	ppp = FClamp(20/numtouch,1,5);
		
	for (i=0;i<TheFlag.Assists.length;i++)
	{
		if (TheFlag.Assists[i]!=None)
		{
			ScoreEvent(TheFlag.Assists[i].PlayerReplicationInfo,ppp,"flag_cap_assist");
			TheFlag.Assists[i].PlayerReplicationInfo.Score += int(ppp);
		}
	}

	// Apply the team score
	Scorer.PlayerReplicationInfo.Team.Score += 1.0;
	ScoreEvent(Scorer.PlayerReplicationInfo,5,"flag_cap_final");
	TeamScoreEvent(Scorer.PlayerReplicationInfo.Team.TeamIndex,1,"flag_cap");	
	GameEvent("flag_captured",""$theflag.Team.TeamIndex,Scorer.PlayerReplicationInfo);

	BroadcastLocalizedMessage( class'CTFMessage', 0, Scorer.PlayerReplicationInfo, None, TheFlag.Team );
//	AnnounceScore(Scorer.PlayerReplicationInfo.Team.TeamIndex);
	CheckScore(Scorer.PlayerReplicationInfo);

    if ( bOverTime )
    {
		EndGame(Scorer.PlayerReplicationInfo,"timelimit");
    }
}

function DiscardInventory( Pawn Other )
{
	if ( (Other.PlayerReplicationInfo != None) && (Other.PlayerReplicationInfo.HasFlag != None) )
		CTFFlag(Other.PlayerReplicationInfo.HasFlag).Drop(0.5 * Other.Velocity);
	
	Super.DiscardInventory(Other);
}

// Special 'on a bed' victory dance
function PartyForTheWinner(Actor Focus)
{
	local rotator girl1rot, girl2rot;
	local vector loc, uptest, downtest, gloc1, gloc2, newnormal;
	local class<actor> ExplosionClass;
	local bool bgirl1, bgirl2;
	local CTFFlag checkflag;
	local CTFBase checkbase;
	local MPPawn checkpawn;
	local PeoplePart checkpart;

	const FACING_GIRL_DIST  =	-17;
	const SIDE_GIRL_DIST	=	10;
	const UP_DOWN_TEST		=	75;
	const HIDE_PAWN_RADIUS  =	100;
	const BED_OFFSET_DIST   =	45;

	// If the focus isn't a base, do the old party at the end of deathmatch
	// since the focus being on a base means the girls are over their bad. Otherwise
	// it could be a time up or whatever, out in the boonies.
	if(CTFBase(Focus) != None)
	{
		// First hide any flags in the level (so the girl won't be on the bed that was
		// there before the last guy scored)
		foreach DynamicActors(class'CTFFlag', checkflag)
		{
			checkflag.bHidden=true;
		}
		foreach DynamicActors(class'CTFBase', checkbase)
		{
			checkbase.bHidden=true;
		}
		// Also hide any players that might be in the way (including the
		// one that last scored)
		foreach RadiusActors(class'MPPawn', checkpawn, HIDE_PAWN_RADIUS, Focus.Location)
		{
			checkpawn.bHidden=true;
			if(checkpawn.Weapon != None)
			{
				checkpawn.Weapon.Destroy();
				checkpawn.Weapon = None;
			}
			if(checkpawn.MyHead != None)
			{
				checkpawn.MyHead.Destroy();
				checkpawn.MyHead = None;
			}
		}
		foreach RadiusActors(class'PeoplePart', checkpart, HIDE_PAWN_RADIUS, Focus.Location)
		{
			checkpart.bHidden=true;
		}

		if (ExplosionClassName != "")
			ExplosionClass = class<actor>(DynamicLoadObject(ExplosionClassName, class'class'));

		// get first girl location
		girl1rot = Focus.Rotation;
		girl1rot.yaw += 16384;
		gloc1 = Focus.location + (vector(girl1rot) * FACING_GIRL_DIST) 
			+ (vector(Focus.Rotation) * SIDE_GIRL_DIST)
			+ (vector(Focus.Rotation) * BED_OFFSET_DIST);
		// get second
		girl2rot = girl1rot;
		girl2rot.yaw -= 32768;
		gloc2 = Focus.location + (vector(girl2rot) * FACING_GIRL_DIST) 
			- (vector(Focus.Rotation) * SIDE_GIRL_DIST)
			+ (vector(Focus.Rotation) * BED_OFFSET_DIST);
		// Find the floor for her, within reason. Start a little above her
		// and test to a little below her
		// Making first girl
		uptest = gloc1;
		downtest = gloc1;
		uptest.z += UP_DOWN_TEST;
		downtest.z -= UP_DOWN_TEST;
		if(Trace(loc, newnormal, downtest, uptest, false) != None)
		{
			gloc1=loc;
			gloc1.z+=UP_DOWN_TEST;
		}
		// make the girl and the explosion
		spawn(CheerleaderClass1, EndGameFocus, , gloc1 + vect(0,0,0), girl1rot);
		if (ExplosionClass != None)
			spawn(ExplosionClass, EndGameFocus, , gloc1 + vect(0,0,-50), girl1rot);
		// Making second girl
		uptest = gloc2;
		downtest = gloc2;
		uptest.z += UP_DOWN_TEST;
		downtest.z -= UP_DOWN_TEST;
		if(Trace(loc, newnormal, downtest, uptest, false) != None)
		{
			gloc2=loc;
			gloc2.z+=UP_DOWN_TEST;
		}
		// make the girl and the explosion					// move her down a little (she's shorter than dude)
		spawn(CheerleaderClass2, EndGameFocus, , gloc2 + vect(0,0,0), girl2rot);
		if (ExplosionClass != None)
			spawn(ExplosionClass, EndGameFocus, , gloc2 + vect(0,0,-50), girl2rot);

		// blaring music
		spawn(class'CheerLeaderMusic',EndGameFocus,,Focus.Location);
	}
	else // Do normal dance, instead of 'on bed' dance
		Super(DeathMatch).PartyForTheWinner(Focus);
}

State MatchOver
{
	function ScoreFlag(Controller Scorer, CTFFlag theFlag)
	{
	}
}

defaultproperties
{
	bSpawnInTeamArea=true
	bScoreTeamKills=False
	//bWeaponStay=true	// we don't like this in our team games, plus false helps stop cheating with pickups
	BeaconName="CTF"
	GameName="Snatch"
	GoalScore=3
	bTeamScoreRounds=false
	TeamAIType(0)=class'MultiBase.CTFTeamAI'
	TeamAIType(1)=class'MultiBase.CTFTeamAI'
	MaxLives=0
	SettingsMenuType="UTBrowser.UTCTFSettingsSClient"
}
