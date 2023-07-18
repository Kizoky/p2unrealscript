class xPatchPageMain extends xPatchPageBase;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var UWindowLabelControl Label;
var localized string LabelText;
var UWindowLabelControl Label2;
var localized string LabelText2;
var UWindowLabelControl Label3;
var localized string LabelText3;

// Headshots	
// NOTE: Mod-Exclusive
//var UWindowCheckbox		HeadshotsCheckbox;
//var localized string	HeadshotsText;
//var localized string	HeadshotsHelp;
//const HeadshotsPath = "Postal2Game.xPatchManager bSPHeadshots";

// Allow Workshop Achievements
// NOTE: Mod-Exclusive
//var UWindowCheckbox		AchHackCheckbox;
//var localized string	AchHackText, AchHackHelp;
//const AchHackPath = "Postal2Game.xPatchManager bWSAchievements";


// Randomize Guns
const RandomGunsPath = "Postal2Game.xPatchManager bRandomGuns";
var UWindowCheckbox		RandomGunsCheckbox;
var localized string	RandomGunsText;
var localized string	RandomGunsHelp;

///////////////////////////////////////////////////////////////////////////////

// Multiplayer Blood Effects
var UWindowCheckbox		BloodCheckbox;
var localized string	BloodText;
var localized string	BloodHelp;
const BloodPath = "BaseFX.EffectMaker bSTPBloodFX";

// Food Effect
var UWindowCheckbox		FoodCheckbox;
var localized string	FoodText;
var localized string	FoodHelp;
const FoodPath = "Postal2Game.xPatchManager bEatEffect";

// Catnip Effect
var UWindowCheckbox		CatnipCheckbox;
var localized string	CatnipText;
var localized string	CatnipHelp;
const CatnipPath = "Postal2Game.xPatchManager bCatnipEffect";

// Dual Wield SFX
var UWindowCheckbox		DualSFXCheckbox;
var localized string	DualSFXText;
var localized string	DualSFXHelp;
const DualSFXPath = "Postal2Game.xPatchManager bDualEffect";

///////////////////////////////////////////////////////////////////////////////

// Multiplayer
const MultiPath = "Shell.MenuMain bShowMP";
var UWindowCheckbox MultiCheckbox;
var localized string MultiText;
var localized string MultiHelp;

// Paradise Lost
//const ParadiseLostPath = "Shell.MenuMain bShowDLC";
//var UWindowCheckbox ParadiseLostCheckbox;
//var localized string ParadiseLostText;
//var localized string ParadiseLostHelp;

// Holidays
//const HolidaysPath = "Postal2Game.xPatchManager bUnlockHolidays";
//var UWindowCheckbox HolidaysCheckbox;
//var localized string HolidaysText;
//var localized string HolidaysHelp;

// Debug
//var UWindowCheckbox DebugCheckbox;
//var localized string DebugText;
//var localized string DebugHelp;

// Achievements
const MoveAchievementsPath = "Postal2Game.xPatchManager bMoveAchevements";
var UWindowCheckbox MoveAchievementsCheckbox;
var localized string MoveAchievementsText;
var localized string MoveAchievementsHelp;

// Main menu background
var UWindowCheckbox		ClassicBackgroundCheckbox;
var localized string	ClassicBackgroundText;
var localized string	ClassicBackgroundHelp;
const ClassicBackgroundPath = "Postal2Game.xPatchManager bClassicBackground";

var UWindowMessageBox		DebugConfirmationBox;
var localized string		DebugWarning;

//////////////////////////////////////////
// Create contents
//////////////////////////////////////////
function Created()
{
	bInitialized = False;
	Super.Created();

	//Label = AddLabel(LabelText, F_SmallBold);

	//HeadshotsCheckbox		= AddCheckbox(HeadshotsText, HeadshotsHelp, ControlFont);
	RandomGunsCheckbox		= AddCheckbox(RandomGunsText, RandomGunsHelp, ControlFont);
	//AchHackCheckbox			= AddCheckbox(AchHackText, AchHackHelp, ControlFont);
	//DebugCheckbox			= AddCheckbox(DebugText, DebugHelp, ControlFont);
		
	//ControlOffset += (ControlHeight * 0.5);	// Space
		
	//Label2 = AddLabel(LabelText2, F_SmallBold);
	BloodCheckbox			= AddCheckbox(BloodText, BloodHelp, ControlFont);	
	FoodCheckbox			= AddCheckbox(FoodText, FoodHelp, ControlFont);
	CatnipCheckbox			= AddCheckbox(CatnipText, CatnipHelp, ControlFont);
	DualSFXCheckbox			= AddCheckbox(DualSFXText, DualSFXHelp, ControlFont);
	
	//ControlOffset += (ControlHeight * 0.5);	// Space
	
	//Label3 = AddLabel(LabelText3, F_SmallBold);
	//if(!bParadiseLost)
	ClassicBackgroundCheckbox = AddCheckbox(ClassicBackgroundText, ClassicBackgroundHelp, ControlFont);	
	//ParadiseLostCheckbox	= AddCheckbox(ParadiseLostText, ParadiseLostHelp, ControlFont);
	//MultiCheckbox			= AddCheckbox(MultiText, MultiHelp, ControlFont);
	//HolidaysCheckbox		= AddCheckbox(HolidaysText, HolidaysHelp, ControlFont);
	MoveAchievementsCheckbox = AddCheckbox(MoveAchievementsText, MoveAchievementsHelp, ControlFont);
	
	//if(FPSPlayer(GetPlayerOwner()).bEnableDebugMenu)
	//	xWelcomeCheckbox		= AddCheckbox(xWelcomeText, xWelcomeHelp, ControlFont);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;
		
	Super.BeforePaint(C, X, Y);

	// display in the center
	ControlLeft = (WinWidth - ControlWidth*2/3)/2;
	
	TC.R = 255;
	TC.G = 255;
	TC.B = 255;
	
	//C.Font = Root.Fonts[Label.Font];
	//TextSize(C, LabelText, W, H);
	//Label.SetSize(W, H);
	//Label.WinLeft = (WinWidth - Label.WinWidth) / 2;
	Label.SetSize(CheckWidth, ControlHeight);
	Label.WinLeft = ControlLeft;
	
	//HeadshotsCheckbox.SetSize(CheckWidth, ControlHeight);
	//HeadshotsCheckbox.WinLeft = ControlLeft;
	
	RandomGunsCheckbox.SetSize(CheckWidth, ControlHeight);
	RandomGunsCheckbox.WinLeft = ControlLeft;
	
	//AchHackCheckbox.SetSize(CheckWidth, ControlHeight);
	//AchHackCheckbox.WinLeft = ControlLeft;
	
	//DebugCheckbox.SetSize(CheckWidth, ControlHeight);
	//DebugCheckbox.WinLeft = ControlLeft;
	
	//C.Font = Root.Fonts[Label2.Font];
	//TextSize(C, LabelText2, W, H);
	//Label2.SetSize(W, H);
	//Label2.WinLeft = (WinWidth - Label2.WinWidth) / 2;
	//Label2.SetSize(CheckWidth, ControlHeight);
	//Label2.WinLeft = ControlLeft;
	
	BloodCheckbox.SetSize(CheckWidth, ControlHeight);
	BloodCheckbox.WinLeft = ControlLeft;
	
	FoodCheckbox.SetSize(CheckWidth, ControlHeight);
	FoodCheckbox.WinLeft = ControlLeft;
	
	CatnipCheckbox.SetSize(CheckWidth, ControlHeight);
	CatnipCheckbox.WinLeft = ControlLeft;
	
	DualSFXCheckbox.SetSize(CheckWidth, ControlHeight);
	DualSFXCheckbox.WinLeft = ControlLeft;
	
	//C.Font = Root.Fonts[Label3.Font];
	//TextSize(C, LabelText3, W, H);
	//Label3.SetSize(W, H);
	//Label3.WinLeft = (WinWidth - Label3.WinWidth) / 2;
	Label3.SetSize(CheckWidth, ControlHeight);
	Label3.WinLeft = ControlLeft;
	
	ClassicBackgroundCheckbox.SetSize(CheckWidth, ControlHeight);
	ClassicBackgroundCheckbox.WinLeft = ControlLeft;
	
	//ParadiseLostCheckbox.SetSize(CheckWidth, ControlHeight);
	//ParadiseLostCheckbox.WinLeft = ControlLeft;
	
	MultiCheckbox.SetSize(CheckWidth, ControlHeight);
	MultiCheckbox.WinLeft = ControlLeft;
	
	//HolidaysCheckbox.SetSize(CheckWidth, ControlHeight);
	//HolidaysCheckbox.WinLeft = ControlLeft;
	
	MoveAchievementsCheckbox.SetSize(CheckWidth, ControlHeight);
	MoveAchievementsCheckbox.WinLeft = ControlLeft;
	
	//xWelcomeCheckbox.SetSize(CheckWidth, ControlHeight);
	//xWelcomeCheckbox.WinLeft = ControlLeft;

}

function AfterCreate()
{
	local float fVal;
	local int iVal;
	local bool flag;

	Super.AfterCreate();
	
	///////////////////////////////////////////////////////////////////////////////
	
	// Achievements
	//flag = bool(GetPlayerOwner().ConsoleCommand("get"@AchHackPath));
	//AchHackCheckbox.SetValue(flag);
	
	// Headshots
	//flag = bool(GetPlayerOwner().ConsoleCommand("get"@HeadshotsPath));
	//HeadshotsCheckbox.SetValue(flag);
	
	// Rando Guns
	flag = bool(GetPlayerOwner().ConsoleCommand("get" @ RandomGunsPath));
	RandomGunsCheckbox.SetValue(flag);
	
	///////////////////////////////////////////////////////////////////////////////
	
	// STP Blood
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@BloodPath));
	BloodCheckbox.SetValue(flag);
	
	// Food FX
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@FoodPath));
	FoodCheckbox.SetValue(flag);
	
	// Catnip FX
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@CatnipPath));
	CatnipCheckbox.SetValue(flag);

	// Dual SFX
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@DualSFXPath));
	DualSFXCheckbox.SetValue(flag);
	
	///////////////////////////////////////////////////////////////////////////////
	
	// Debug
	//flag = (FPSPlayer(GetPlayerOwner()).bEnableDebugMenu);
	//DebugCheckbox.SetValue(flag);
	
	// Multiplayer
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@MultiPath));
	MultiCheckbox.SetValue(flag);	
	
	// Paradise Lost
	//flag = bool(GetPlayerOwner().ConsoleCommand("get"@ParadiseLostPath));
	//ParadiseLostCheckbox.SetValue(flag);
	
	// Holidays
	//flag = bool(GetPlayerOwner().ConsoleCommand("get"@HolidaysPath));
	//HolidaysCheckbox.SetValue(flag);	
	
	// Achievements
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@MoveAchievementsPath));
	MoveAchievementsCheckbox.SetValue(flag);	
	
	// Message
	//flag = bool(GetPlayerOwner().ConsoleCommand("get"@xWelcomePath));
	//xWelcomeCheckbox.SetValue(flag);
	
	// Background
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@ClassicBackgroundPath));
	ClassicBackgroundCheckbox.SetValue(flag);
	
	///////////////////////////////////////////////////////////////////////////////

	bInitialized = True;
}

///////////////////////////////////////////////////////////////////////////////
// Callback for when control has changed
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	Super.Notify(C, E);
	
	switch (E)
		{
		case DE_Change:
			switch (C)
				{
				//case AchHackCheckbox:
				//	CheckboxChange(AchHackPath, AchHackCheckbox.GetValue());
				//	break;
				//case HeadshotsCheckbox:
				//	CheckboxChange(HeadshotsPath, HeadshotsCheckbox.GetValue());
				//	break;
				case BloodCheckbox:
					CheckboxChange(BloodPath, BloodCheckbox.GetValue());
					break;
				case FoodCheckbox:
					CheckboxChange(FoodPath, FoodCheckbox.GetValue());
					break;
				case CatnipCheckbox:
					CheckboxChange(CatnipPath, CatnipCheckbox.GetValue());
					break;
				case DualSFXCheckbox:
					CheckboxChange(DualSFXPath, DualSFXCheckbox.GetValue());
					break;
				case RandomGunsCheckbox:
					CheckboxChange(RandomGunsPath, RandomGunsCheckbox.GetValue());
					break;	
				
				//case DebugCheckbox:
				//	DebugCheckboxChanged();
				//	break;
				//case ParadiseLostCheckbox:
				//	CheckboxChange(ParadiseLostPath, ParadiseLostCheckbox.bChecked);
				//	break;
				case MultiCheckbox:
					CheckboxChange(MultiPath, MultiCheckbox.bChecked);
					break;		
				//case HolidaysCheckbox:
				//	CheckboxChange(HolidaysPath, HolidaysCheckbox.bChecked);
				//	break;		
				case MoveAchievementsCheckbox:
					CheckboxChange(MoveAchievementsPath, MoveAchievementsCheckbox.bChecked);
					break;
				//case xWelcomeCheckbox:
				//	CheckboxChange(xWelcomePath, xWelcomeCheckbox.bChecked);
				//	break;	
				case ClassicBackgroundCheckbox:
					if(bInitialized) 
					{
						CheckboxChange(ClassicBackgroundPath, ClassicBackgroundCheckbox.bChecked);
						GetGameSingle().ChangeMenuBackground();
					}
				}
			break;
		}
	}
	
///////////////////////////////////////////////////////////////////////////////
// Set all values to default
///////////////////////////////////////////////////////////////////////////////
function SetDefaultValues()
{
	//HeadshotsCheckbox.SetValue(false);
	//AchHackCheckbox.SetValue(true);
	FoodCheckbox.SetValue(true);
	CatnipCheckbox.SetValue(true);
	DualSFXCheckbox.SetValue(true);
	RandomGunsCheckbox.SetValue(True);
	
	//ParadiseLostCheckbox.SetValue(true);
	MultiCheckbox.SetValue(false);
	//HolidaysCheckbox.SetValue(false);
	//DebugCheckbox.SetValue(false);
	MoveAchievementsCheckbox.SetValue(false);
	//xWelcomeCheckbox.SetValue(false);
	ClassicBackgroundCheckbox.SetValue(false);
	BloodCheckbox.SetValue(false);
}

/*
///////////////////////////////////////////////////////////////////////////////
// Changes
///////////////////////////////////////////////////////////////////////////////
function DebugCheckboxChanged()
{
	if (bInitialized)
	{
		if (DebugCheckbox.bChecked)
			DebugConfirmationBox = MessageBox(WarningTitle, DebugWarning, MB_YESNO, MR_NO, MR_YES);
		else // Disable debug
		{
			if(FPSPlayer(GetPlayerOwner()).bEnableDebugMenu)
				GetPlayerOwner().ConsoleCommand("EnableDebugMenu");
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Notification that the message box has finished.
///////////////////////////////////////////////////////////////////////////////
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	Super.MessageBoxDone(W, Result);
	
	if (W == DebugConfirmationBox)
	{
		switch (Result)
			{
			case MR_YES:
				// Enable Debug Menu.
				if(!FPSPlayer(GetPlayerOwner()).bEnableDebugMenu)
					GetPlayerOwner().ConsoleCommand("EnableDebugMenu");
				break;
			case MR_NO:
				DebugCheckbox.SetValue(false);
				// Whimped out..carry on.
				break;
			}
	}
}
*/

defaultproperties
{
	PageHeaderText="Customize various game settings."
	ControlWidthPercent=0.75
	
	//LabelText = "Game Settings:"
	 //HeadshotsText="Headshots"
	 //HeadshotsHelp="Shoots to the head deal increased damage. NPCs headshot chance scales with difficulty from 25% to max 75%. (Average and below is always 25%, everything after icreases by additional 5%)."
	 //AchHackText = "Workshop Achievements"
	 //AchHackHelp = "Allows you to unlock achievements while using workshop content."
	 RandomGunsText = "Expanded NPC Gun Variety"
	 RandomGunsHelp = "Bystanders have a random chance of using Eternal Damnation weapons. NOTE: Doesn't affect Classic Mode."

	
	//LabelText2 = "Effects Settings:"
	 BloodText="STP Blood Effects"
	 BloodHelp="Enables alternate Share The Pain-style blood effects."
	 FoodText="Food Particles"
     FoodHelp="Enables Share The Pain-style food particles when eating."
	 CatnipText="Catnip Effects"
	 CatnipHelp="Toggles the new catnip visual effects."
	 DualSFXText="Dual Wielding SFX"
	 DualSFXHelp="Toggles dual wielding sound effects."
	 
	//LabelText3 = "Menu Settings:"
	 ClassicBackgroundText = "Classic Menu Background"
	 ClassicBackgroundHelp = "Toggles the main menu background image."
	 MultiText = "Show Multiplayer"
	 //ParadiseLostText = "Show Paradise Lost"
	 //HolidaysText = "Show Holidays"
	 //DebugText="Debug Mode"
	 MoveAchievementsText="Move Achievements"
	 //xWelcomeText="(DEBUG) xPatch's First Run"
	 MultiHelp="Unlocks the hidden in-game Multiplayer option. (Unsupported, you can play only with bots or on your own servers)."
	 //ParadiseLostHelp="Shows the Paradise Lost re-launch option."
	 //HolidaysHelp = "Unlocks the '?????????' option even if you didn't beat 'A Week In Paradise' on Hestonworld difficulty."
	 //DebugHelp="Unlocks the debug menu which allows you to jump to any level or day you want, plus other stuff."
	 MoveAchievementsHelp="Moves the 'Achievements' option from the game menu to the options menu."
	 //DebugWarning="Are you sure? Using debug mode diables achievements and flags all saves as cheated until disabled!"
}