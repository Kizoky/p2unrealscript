///////////////////////////////////////////////////////////////////////////////
// MpPlayer.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Base multiplayer player controller, although it's also included in single
// the singleplayer player hierarchy!
//
///////////////////////////////////////////////////////////////////////////////
//
// WARNING: THIS CLASS IS USED IN SINGLE AND MULTIPLAYER!
//
///////////////////////////////////////////////////////////////////////////////
class MpPlayer extends P2Player;

	
var bool							bRising;
var bool							bLatecomer;				// entered multiplayer game after game started
var bool							bFullyLoggedIn;
var bool							bIntroFinished;			// only used server-side!
var byte							MostRecentStartupStage;

var class<WillowWhisp>				PathWhisps[2];
var Sound							BeepSound;

var globalconfig byte				AnnouncerLevel;			// 0=none, 1=no possession announcements, 2=all
var globalconfig string				CustomizedAnnouncerPack;
var float							LastPlayAnnouncer;

var array<vector>					FlavinSpots;			// used in grab bag only
var array<MpPawn>					FlavinPawns;			// used in grab bag only

var string							StatsPassword;			// user entered password used to check stats in MP games

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		ClientPlayTakeHit, PlayStartupMessage, PlayAnnouncement;
	reliable if ( Role == ROLE_Authority )
		PlayWinMessage, ClientPlayerPostLogin;

	reliable if ( Role < ROLE_Authority )
		ServerDropFlag, ServerTaunt, ServerChangeLoadout, ServerSpectate, ServerShowPathToBase, ServerIntroFinished;
}

exec function SoakBots()
{
	local Bot B;

	log("Start Soaking");
	MPGameInfo(Level.Game).bSoaking = true;
	ForEach DynamicActors(class'Bot',B)
		B.bSoaking = true;
}

function SoakPause(Pawn P)
{
	log("Soak pause by "$P);
	SetViewTarget(P);
	SetPause(true);
	bBehindView = true;
	myHud.bShowDebugInfo = true;
}

exec function AttackPath()
{
	if (PlayerReplicationInfo.Team == None )
		return;
	if ( PlayerReplicationInfo.Team.TeamIndex == 0 )
		ServerShowPathToBase(1);
	else
		ServerShowPathToBase(0);
}

exec function DefendPath()
{
	if (PlayerReplicationInfo.Team == None )
		return;
	if ( PlayerReplicationInfo.Team.TeamIndex == 0 )
		ServerShowPathToBase(0);
	else
		ServerShowPathToBase(1);
}

function ServerShowPathToBase(int TeamNum)
{
	local NavigationPoint N;
	local GameObjective G,Best;

	if ( (Pawn == None) || (TeamGame(Level.Game) == None) || !TeamGame(Level.Game).CanShowPathTo(self,TeamNum) )
		return;

	for ( G=TeamGame(Level.Game).Teams[0].AI.Objectives; G!=None; G=G.NextObjective )
		if ( !G.bDisabled && (G.DefenderTeamIndex == TeamNum)
			&& ((Best == None) || (Best.DefensePriority < G.DefensePriority)) )
		{
			Best = G;
		}
	if ( (Best != None) && (FindPathToward(Best) != None) )
		spawn(PathWhisps[TeamNum],Pawn,,Pawn.Location);	
}

function byte GetMessageIndex(name PhraseName)
{
	if ( PlayerReplicationInfo.VoiceType == None )
		return 0;
	return PlayerReplicationInfo.Voicetype.Static.GetMessageIndex(PhraseName);
}

exec function Taunt( name Sequence )
{
	if ( (Pawn != None) && (Pawn.Health > 0) )
		ServerTaunt(Sequence);
}

/* RWS CHANGE: Avoid conflict with our version (by the way, in 927 this function is never called)
exec function WeaponZoom()
{
	if ( (Pawn != None) && (Pawn.Weapon != None) )
		Pawn.Weapon.Zoom();
}
*/

function ServerTaunt(name AnimName )
{
	Pawn.SetAnimAction(AnimName);
}

function PlayStartupMessage(byte StartupStage)
{
	MostRecentStartupStage = StartupStage;
	ReceiveLocalizedMessage( class'StartupMessage', StartupStage, PlayerReplicationInfo );
}

simulated function PlayBeepSound()
{
	if ( ViewTarget != None && BeepSound != None)
		ViewTarget.PlaySound(BeepSound, SLOT_None,,,,,false);
}

exec function CycleLoadout()
{
	if ( MpTeamInfo(PlayerReplicationInfo.Team) != None )
		ServerChangeLoadout(string(MpTeamInfo(PlayerReplicationInfo.Team).NextLoadOut(PawnClass)));
}

exec function ChangeLoadout(string LoadoutName)
{
	ServerChangeLoadout(LoadoutName);
}

function ServerChangeLoadout(string LoadoutName)
{
	if(Level.Game != None && MPGameInfo(Level.Game) != None)
		MPGameInfo(Level.Game).ChangeLoadout(self, LoadoutName);
}

function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	local int iDam;
	local float rnd;

	Super.NotifyTakeHit(InstigatedBy,HitLocation,Damage,DamageType,Momentum);

/*	RWS: Took this out, probably will replace without own effects
	if ( Damage > 1 )
	{
		rnd = FClamp(Damage, 20, 60);
		ClientFlash(DamageType.Default.FlashScale*rnd,DamageType.Default.FlashFog*rnd);
	}

	ShakeView(0.15 + 0.005 * Damage, Damage * 30, Damage * vect(0,0,0.03), 120000, vect(1,1,1), 0.2); 
*/
	iDam = Clamp(Damage,0,250);
	if ( (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer) )
		ClientPlayTakeHit(hitLocation - Pawn.Location, iDam, damageType); 
}

function ClientPlayTakeHit(vector HitLoc, byte Damage, class<DamageType> damageType)
{
	HitLoc += Pawn.Location;
	Pawn.PlayTakeHit(HitLoc, Damage, damageType);
}
	
function PlayWinMessage(bool bWinner);

//==============
// Encroachment
event bool EncroachingOn( actor Other )
{
	if ( GameReplicationInfo.bTeamGame && (Pawn(Other) != None) )
	{
		if ( (Role == ROLE_Authority) && Level.Game.bWaitingToStartMatch )
			return Super.EncroachingOn(Other);
		else
			return true;
	}
	return Super.EncroachingOn(Other);
}

function SendMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait, name BroadcastType)
{
	if ( Level.TimeSeconds - OldMessageTime < 10 )
		return;

	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, BroadcastType);
}

function bool TurnTowardNearestEnemy()
{
	local Pawn P;
	local Controller C;
	local vector LookDir, Look;
	local float BestVal, NewVal;
	local float MinVal, MaxVal;

	MinVal = 0.93;
	MaxVal = 0.995;

	Look = Pawn.Location + Pawn.Eyeheight * vect(0,0,1);
	LookDir = vector(Rotation);
	if ( (TurnTarget == None) || (TurnTarget.Health <= 0) )
		TurnTarget = None;
	else
	{
		NewVal = LookDir Dot Normal(LastSeenPos - Look);
		if ( NewVal > MaxVal )
		{
			TurnTarget = None;
			return false;
		}
		if ( FastTrace(TurnTarget.Location, Look) )
			LastSeenPos = TurnTarget.Location;
		else if ( NewVal > MinVal )
			TurnTarget = None;
	}

	if ( TurnTarget == None )
	{
		BestVal = -2;
		if ( Level.NetMode == NM_Client )
		{
			ForEach DynamicActors(class'Pawn',P)
				if ( P.IsPlayerPawn() && (P.Controller != self) && (P.Health > 0) && (P.Visibility > 0) 
					&& (!GameReplicationInfo.bTeamGame || (P.PlayerReplicationInfo.Team != PlayerReplicationInfo.Team)) )
				{
					NewVal = LookDir Dot Normal(P.Location - Look);
					if ( (NewVal > MinVal) && (VSize(P.Location - Look) < 2600) && FastTrace(P.Location, Look) )
						return false;	// already close enough
					if ( (NewVal > BestVal) && FastTrace(P.Location, Look) )
					{
						BestVal = NewVal;
						TurnTarget = P;
					}
				}
		}
		else
		{
			for ( C=Level.ControllerList; C!=None; C=C.NextController )
				if ( C.bIsPlayer && (C != self) && (C.Pawn != None) && (C.Pawn.Visibility > 0) 
					&& (!GameReplicationInfo.bTeamGame || (P.PlayerReplicationInfo.Team != PlayerReplicationInfo.Team)) )
				{
					NewVal = LookDir Dot Normal(C.Pawn.Location - Look);
					if ( (NewVal > MinVal) && FastTrace(C.Pawn.Location, Look) )
						return false;	// already close enough
					else if ( (NewVal > BestVal) && FastTrace(C.Pawn.Location, Look) )
					{
						BestVal = NewVal;
						TurnTarget = C.Pawn;
					}
				}
		}
		if ( TurnTarget == None )
			return false;
		LastSeenPos = TurnTarget.Location;
	}
	// Rotate towards best, but with as little up/down as possible
	bRotateToDesired = true;
	DesiredRotation = Rotator(LastSeenPos - Look);
	GroundPitch = GroundPitch & 65535;
	if ( (DesiredFOV == DefaultFOV)
		&& ((abs(DesiredRotation.Pitch - GroundPitch) < 12000) 
			|| (abs(DesiredRotation.Pitch - GroundPitch) > 53535)) )
		DesiredRotation.Pitch = GroundPitch;
		
	return true;
}

function ServerSpectate()
{
	GotoState('Spectating');
    bBehindView = true;
    ServerViewNextPlayer();
}

exec function DropFlag()
{
	ServerDropFlag();
}

function ServerDropFlag()
{
	if (PlayerReplicationInfo==None || PlayerReplicationInfo.HasFlag==None)
    	return;

    PlayerReplicationInfo.HasFlag.Drop(Pawn.Velocity * 0.5);
}

function PlayerPostLogin(class<MatchIntro> MatchIntroClass)
{
	// Set server-side flag
	bFullyLoggedIn = true;

	ClientPlayerPostLogin(MatchIntroClass);

	// If there is no intro then set server-side flag
	if (MatchIntroClass == None)
		bIntroFinished = true;
}

simulated function ClientPlayerPostLogin(class<MatchIntro> MatchIntroClass)
{
	// Set client-side flag
	bFullyLoggedIn = true;

	// Start the match intro or set client-side flag
	if (MatchIntroClass != None)
		MpHUDBase(myHUD).StartMatchIntro(MatchIntroClass);

	WriteTeam();
}

function ServerIntroFinished()
{
	// Set server-side flag
	bIntroFinished = true;
}

///////////////////////////////////////////////////////////////////////////////
// Set proper character class + team - only in multiplayer
///////////////////////////////////////////////////////////////////////////////
simulated function WriteTeam()
{
	if(Level.Game != None && Level.Game.bIsSinglePlayer)
		return;
	UpdateURL("Class", string(PawnClass), True);
	ConsoleCommand("set" @ "Shell.MenuMulti MultiPlayerClass" @ PawnClass);
	if(PlayerReplicationInfo != None && PlayerReplicationInfo.Team != None)
		UpdateURL("Team", string(PlayerReplicationInfo.Team.TeamIndex), True);
}

///////////////////////////////////////////////////////////////////////////////
// Play announcer stuff
///////////////////////////////////////////////////////////////////////////////
simulated function PlayAnnouncement(sound ASound, byte AnnouncementLevel, optional bool bForce)
{
	local float Atten;

	if ( AnnouncementLevel > AnnouncerLevel )
		return;
	if ( !bForce && (Level.TimeSeconds - LastPlayAnnouncer < 1) )
		return;
    LastPlayAnnouncer = Level.TimeSeconds;  // so voice messages won't overlap
	
	ASound = CustomizeAnnouncer(ASound);
	ClientPlaySound(ASound,true);
}

function Sound CustomizeAnnouncer(Sound AnnouncementSound)
{
	local sound LoadSound;

	if ( CustomizedAnnouncerPack == "" )
		return AnnouncementSound;

	LoadSound = sound(DynamicLoadObject(CustomizedAnnouncerPack$"."$GetItemName(string(AnnouncementSound)), class'Sound'));

	if ( LoadSound != None )
		return LoadSound;

	return AnnouncementSound;
}

///////////////////////////////////////////////////////////////////////////////
// Tell dude he got some health
///////////////////////////////////////////////////////////////////////////////
function NotifyGotHealth(int howmuch)
{
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// GameEnded
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GameEnded
{
	ignores ExitSnipingState;

	///////////////////////////////////////////////////////////////////////////////
	// These two zoom the camera in and out
	///////////////////////////////////////////////////////////////////////////////
	exec function NextWeapon()
	{
		if( Level.Pauser!=None)
			return;
		DeadNextWeapon(CAMERA_DEAD_ZOOM_CHANGE, CAMERA_DEAD_MIN_DIST);
	}
	exec function PrevWeapon()
	{
		if( Level.Pauser!=None)
			return;
		DeadPrevWeapon(CAMERA_DEAD_ZOOM_CHANGE, CAMERA_DEAD_MAX_DIST);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Same as Engine.PlayerController version except we
	// use our own distance numbers for the camera
	///////////////////////////////////////////////////////////////////////////////
	function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
	{
		local vector View,HitLocation,HitNormal;
		local float ViewDist;
		local coords checkcoords;

		if(CTFBase(ViewTarget) != None)
			Dist=Dist/2;

		CameraLocation = ViewTarget.Location;

		// Now modify it based on your surroundings.
		CameraRotation = Rotation;
		View = vect(1,0,0) >> CameraRotation;
		if( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
			ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
		else
			ViewDist = Dist;
		CameraLocation -= (ViewDist - 30) * View; 
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Timer()
	{
		Super.Timer();
		myHUD.bShowScores = true;
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local MpPawn p;

		//mypawnfix
		if(P2Pawn(Pawn) != None 
			&& P2Pawn(Pawn).MyBodyFire != None)
		{
			P2Pawn(Pawn).MyBodyFire.Destroy();
			P2Pawn(Pawn).UnhookPawnFromFire();
		}

		Super.BeginState();

		ForEach DynamicActors(class'MpPawn', P)
		{
			p.GotoState('GameOver');
		}
	}
}

defaultproperties
{
	PathWhisps[0]=class'WillowWhisp'
	PathWhisps[1]=class'WillowWhisp'
	FovAngle=+00085.000000
	LocalMessageClass=class'LocalMessagePlus'
	PlayerReplicationInfoClass=Class'MultiBase.MpPlayerReplicationInfo'
	AnnouncerLevel=2
}
