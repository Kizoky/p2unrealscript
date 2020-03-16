///////////////////////////////////////////////////////////////////////////////
// xMpPlayer.uc
// Copyright 2003 Running With Scissors.  All Rights Reserved.
//
// Multiplayer player controller.
//
///////////////////////////////////////////////////////////////////////////////
class xMpPlayer extends DudePlayer;


///////////////////////////////////////////////////////////////////////////////
// Startup
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
    PreloadCustomAnnouncer();
}

///////////////////////////////////////////////////////////////////////////////
// Shut down Menu if we travel to a new level
///////////////////////////////////////////////////////////////////////////////
event PreClientTravel()
{
	// Disable the Menu for a level change
	P2RootWindow(Player.InteractionMaster.BaseMenu).DisableMenu();

	Super.PreClientTravel();
}

///////////////////////////////////////////////////////////////////////////////
// Change the default hud so we can make some assumptions about having a
// reasonable hud (rather than engine.hud).
///////////////////////////////////////////////////////////////////////////////
function SpawnDefaultHUD()
{
	myHUD = spawn(class'MpHUDBase',self);
}

///////////////////////////////////////////////////////////////////////////////
// Keep the player in this state until he's seen the match intro.
///////////////////////////////////////////////////////////////////////////////
auto state PlayerWaiting
{
	exec function Fire(optional float F)
	{
		if (bFullyLoggedIn && MpHUDBase(myHUD).CanMatchIntroEnd())
		{
			WriteTeam();
			MpHUDBase(myHUD).EndMatchIntro();
			Super.Fire(F);
		}
	}
	
	// Allows people to see all the hints in succession
	exec function AltFire( optional float F )
	{
		if(MyHUD != None
			&& MyHUD.Scoreboard != None)
			MyHUD.Scoreboard.UseNextHint();
	}

	simulated function EndState()
	{
		MpHUDBase(myHUD).EndMatchIntro();
		Super.EndState();
	}

	simulated function BeginState()
	{
		Super.BeginState();
	}
}

///////////////////////////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////////////////////////
state Dead
{
ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon;

	exec function Fire( optional float F )
	{
		if ( bFrozen )
		{
			if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
				bFrozen = false;
			return;
		}
		if ( PlayerReplicationInfo.bOutOfLives )
			ServerSpectate();
		else
			Super.Fire(F);
	}

	// Allows people to see all the hints in succession
	exec function AltFire( optional float F )
	{
		if(MyHUD != None
			&& MyHUD.Scoreboard != None)
			MyHUD.Scoreboard.UseNextHint();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if player can restart
// This is in this class so it won't affect singleplayer
///////////////////////////////////////////////////////////////////////////////
function bool CanRestartPlayer()
{
	return Super.CanRestartPlayer() && bFullyLoggedIn && bIntroFinished;
}

///////////////////////////////////////////////////////////////////////////////
// Preload custom announcer sounds.  Note that default announcer sounds are
// directly referenced by the code so they don't require a manual preload.
///////////////////////////////////////////////////////////////////////////////
function PreloadCustomAnnouncer()
{
	if ( CustomizedAnnouncerPack == "" )
		return;

	DynamicLoadObject(CustomizedAnnouncerPack$".Announcer1", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".Announcer10", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".Announcer1min", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".Announcer2", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".Announcer3", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".Announcer30sec", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".Announcer3min", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".Announcer4", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".Announcer5", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".Announcer5min", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".Announcer6", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".Announcer7", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".Announcer8", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".Announcer9", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerGrudgeMatch", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamBandScore", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamBandWin", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamButchersScore", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamButchersWin", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamCopsScore", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamCopsWin", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamDudeScore", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamDudeWin", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamFanaticsScore", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamFanaticsWin", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamGaryScore", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamGaryWin", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamGimpScore", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamGimpWin", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamHoodScore", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamHoodWin", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamMilitaryScore", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamMilitaryWin", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamParcelworkersScore", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamParcelworkersWin", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamPostalScore", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamPostalWin", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamPriestsScore", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamPriestsWin", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamRednecksScore", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamRednecksWin", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamRobbersScore", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamRobbersWin", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamRWSScore", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamRWSWin", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamSWATScore", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamSWATWin", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamTheManScore", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamTheManWin", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamZealotsScore", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTeamZealotsWin", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTheirFlagDropped", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTheirFlagReturned", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerTheirFlagTaken", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerYouLost", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerYourFlagDropped", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerYourFlagReturned", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerYourFlagTaken", class'Sound');
	DynamicLoadObject(CustomizedAnnouncerPack$".AnnouncerYouWon", class'Sound');
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	BeepSound=sound'MpSounds.Misc.Talk'
	}
