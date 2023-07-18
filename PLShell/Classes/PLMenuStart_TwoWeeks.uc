///////////////////////////////////////////////////////////////////////////////
// PLMenuStart_TwoWeeks
// by Piotr "Man Chrzan" Sztukowski
//
// Start menu for Two Weeks in Paradise.
///////////////////////////////////////////////////////////////////////////////
class PLMenuStart_TwoWeeks extends PLMenuStart;

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	local int val;
	local class<UMenuStartGameWindow> StartGameClass;
	local string StartURL;
	local bool bUseSuper;
	
	bUseSuper = true;

	switch(E)
		{
		case DE_Click:
			switch (C)
				{
				case StartChoice:
					StartURL = class'TWPGameInfo'.Static.GetStartURL(true, SkipCheckbox.bChecked);
					StartGameInfo = class'TWPGameInfo';
					if (GetGameSingle().FinallyOver() || DayCombo != None )
					{
						StartGameURL = StartURL;
						bShouldForceMap = True; 				// xPatch
						StartGame2(EnhancedCheckbox.GetValue());
						ShellRootWindow(Root).bLaunchedMultiplayer = false;
					}
					// If they haven't finished the game yet, show 'em how to play
					else 
					{
						ShellRootWindow(Root).bEnhancedMode = EnhancedCheckbox.GetValue();
						ShellRootWindow(Root).StartGameURL = StartURL;
						ShellRootWindow(Root).bNoEDWeapons = ClassicGameCheckbox.GetValue();	// xPatch
						ShellRootWindow(Root).bForceMap = SkipCheckbox.bChecked;				// xPatch
						SetDiff();
						
						if (PlatformIsSteamDeck())
                            GotoMenu(class'MenuImageKeys_SteamDeck');
						else
							GotoMenu(class'MenuImageKeys');
					}
					bUseSuper = False;
					break;
				}
			break;
		}
		if (bUseSuper)
			Super.Notify(C, E);
	}
	
///////////////////////////////////////////////////////////////////////////////
// Should ensure that Day Selection works for Two Week In Paradise mode.
///////////////////////////////////////////////////////////////////////////////
function PossibleConvertToSecondWeek(int Day)
{
	if(Day >= 7)
	{
		class'TWPGameInfo'.default.bIsSecondWeek = True;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	TitleText="Two Weeks In Paradise"
	Days[0] = "Monday"
	Days[1] = "Tuesday"
	Days[2] = "Wednesday"
	Days[3] = "Thursday"
	Days[4] = "Friday"
	Days[5] = "Saturday"
	Days[6] = "Sunday"
	Days[7] = "2nd Monday"
	Days[8] = "2nd Tuesday"
	Days[9] = "2nd Wednesday"
	Days[10] = "2nd Thursday"
	Days[11] = "2nd Friday"
	Days[12] = "The Showdown"
	Days[13] = "The Apocalypse"
	MaxDays = 14
	
	//DayIntroSkipMap[5]="Hospital"
	//DayIntroSkipMap[7]="PL-highlands.fuk#PlayerStart"
	
}
