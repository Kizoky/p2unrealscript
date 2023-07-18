///////////////////////////////////////////////////////////////////////////////
// Seekrit menu
///////////////////////////////////////////////////////////////////////////////
class MenuSeekrit extends MenuStart;

var config int NPCDifficultySliderMax;

var UWindowHSliderControl NPCDifficultySlider;
var localized string NPCDifficultyText, NPCDifficultyHelp;
var UWindowComboControl ViolenceModeCombo;	// Combobar for selecting Liebermode, Hestonworld etc.
var localized string ViolenceModeText, ViolenceModeHelp;
var UWindowCheckbox TheyHateMeCheckbox;		// Checkbox for They Hate Me Mode
var localized string TheyHateMeText, TheyHateMeHelp;
var UWindowCheckbox ExpertCheckbox;			// Checkbox for Expert mode
var localized string ExpertText, ExpertHelp;
var UWindowCheckbox VeteranCheckbox;			// Checkbox for Veteran mode
var localized string VeteranText, VeteranHelp;
var UWindowCheckbox MasochistCheckbox;			// Checkbox for Masochist mode
var localized string MasochistText, MasochistHelp;
var UWindowCheckbox HardLiebermodeCheckbox;			// Checkbox for Melee mode
var localized string HardLiebermodeText, HardLiebermodeHelp;

var ShellTextControl TextItem;

var localized array<string> ViolenceModes;

var bool bStartWith30Lives;

const DIFFICULTY_NUMBER_CUSTOM = 16;


///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	local int i;
	
	Super(ShellMenuCW).CreateMenuContents();
	
	AddTitle(TitleText, F_FancyXL, TA_Left);
	
	ItemFont = F_FancyL;
	
	bUpdate = false;
	NPCDifficultySlider = AddSlider(NPCDifficultyText, NPCDifficultyHelp, ItemFont, 1, NPCDifficultySliderMax);
	NPCDifficultySlider.SetValue(5);
	
	ViolenceModeCombo = AddComboBox(ViolenceModeText, ViolenceModeHelp, ItemFont);
	ViolenceModeCombo.List.MaxVisible = ViolenceModes.Length;
	
	for (i=0; i < ViolenceModes.Length; i++)
		ViolenceModeCombo.AddItem(ViolenceModes[i]);
	ViolenceModeCombo.SetValue(ViolenceModes[2]);		
	// Seems too wide on the text side.
	ViolenceModeCombo.EditBoxWidth = ViolenceModeCombo.WinWidth * 0.35;
	
	ItemFont = F_FancyM;	// Medium font for checkboxes
	ItemHeight = 23;		// and closer to each other
	
	TheyHateMeCheckbox = AddCheckbox(TheyHateMeText, TheyHateMeHelp, ItemFont);
	TheyHateMeCheckbox.SetValue(False);
	
	ExpertCheckbox = AddCheckbox(ExpertText, ExpertHelp, ItemFont);
	ExpertCheckbox.SetValue(False);
	
	VeteranCheckbox  = AddCheckbox(VeteranText, VeteranHelp, ItemFont);
	VeteranCheckbox.SetValue(False);
	VeteranCheckbox.bDisabled = True;
	
	MasochistCheckbox  = AddCheckbox(MasochistText, MasochistHelp, ItemFont);
	MasochistCheckbox.SetValue(False);
	
	HardLiebermodeCheckbox = AddCheckbox(HardLiebermodeText, HardLiebermodeHelp, ItemFont);
	HardLiebermodeCheckbox.SetValue(False);

/*	// Add space
	TextItem = AddTextItem("", "", ItemFont);
	TextItem.bActive = False;

	if (GetGameSingle().IsHoliday('ANY_HOLIDAY')
		&& !GetGameSingle().IsHoliday('SeasonalAprilFools'))	// April Fools do not affect the game itself so ignore it.
	{
		NoHolidaysCheckbox = AddCheckbox(NoHolidaysText, NoHolidaysHelp, ItemFont);
		NoHolidaysCheckbox.SetValue(False);
	}
	
	if (GetGameSingle().SeqTimeVerified())
	{
		EnhancedCheckbox = AddCheckbox(EnhancedText, EnhancedHelp, ItemFont);
		EnhancedCheckbox.SetValue(False);
	}
	
	ClassicGameCheckbox = AddCheckbox(ClassicGameText, ClassicGameHelp, ItemFont);
	ClassicGameCheckbox.SetValue(False);
	
	SkipCheckbox = AddCheckbox(SkipText, SkipHelp, ItemFont);
	SkipCheckbox.SetValue(False);
*/
	
	ItemFont = F_FancyL;	// Back to normal
	ItemHeight = 32;
	
	StartMF =		AddChoice(StartMFText,		StartMFHelp,		ItemFont,	TA_Left);
	StartWeekend =	AddChoice(StartWeekendText,	StartWeekendHelp,	ItemFont,	TA_Left);
	StartAW7 =		AddChoice(StartAW7Text,		StartAW7Help,		ItemFont,	TA_Left);
	StartWorkshop =	AddChoice(StartWorkshopText,StartWorkshopHelp,	ItemFont,	TA_Left);
	BackChoice  = AddChoice(BackText,   "", ItemFont, TA_Left, true);
	
	bUpdate = true;
}

function SeekritKodeEntered()
{
	bStartWith30Lives = true;
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	local int val;
	local bool bDoSuper;
	
	bDoSuper = True;

	switch(E)
		{
// xPatch: Allow Enhanced Game + POSTAL / Impossible in Custom Difficulty
/*		case DE_Change:
			switch (C)
				{
				case ExpertCheckbox:
					if (EnhancedCheckbox != None)
						EnhancedCheckbox.bDisabled = ExpertCheckbox.GetValue();
						if (EnhancedCheckbox.bDisabled)
							EnhancedCheckbox.SetValue(false);

					break;
				}
			break;
*/
		// Expert Mode Plus is allowed only with Expert Mode
		case DE_Change:
			switch (C)
				{
				case ExpertCheckbox:
					if (ExpertCheckbox.GetValue())
						VeteranCheckbox.bDisabled = False;
					else
					{
						VeteranCheckbox.bDisabled = True;
						VeteranCheckbox.SetValue(false);
					}
					break;
				}
			break;
		case DE_Click:
			switch (C)
				{
				case StartMF:
					GoToStartMenu(class'MenuStart_P2');
					bDoSuper = False;
					break;
				case StartWeekend:
					GoToStartMenu(class'MenuStart_AW');
					bDoSuper = False;
					break;
				case StartAW7:
					GoToStartMenu(class'MenuStart_AWP');
					bDoSuper = False;
					break;
				case StartWorkshop:
					// Before launching workshop window, apply custom difficulty settings.
					ApplyCustomDifficultySettings();
					break;
				}
		}
	if(bDoSuper)
		Super.Notify(C, E);
	}

///////////////////////////////////////////////////////////////////////////////
// Actually applies customized difficulty settings
///////////////////////////////////////////////////////////////////////////////
function ApplyCustomDifficultySettings()
{
	local bool bLieberMode, bHestonMode, bInsaneoMode, bLudicrousMode, bNukeMode, bMeleeMode;
	local string ViolenceName;

	// Actually apply the desired difficulty settings here, then start the game.
	ViolenceName = ViolenceModeCombo.GetValue();
	
	// Liebermode	
	if (ViolenceName == ViolenceModes[0])
		bLieberMode = true;
	else if (ViolenceName == ViolenceModes[1])
		bMeleeMode = true;
	else if (ViolenceName == ViolenceModes[3])
		bHestonMode = true;
	else if (ViolenceName == ViolenceModes[4])
		bInsaneoMode = true;
	else if (ViolenceName == ViolenceModes[5])
		bLudicrousMode = true;
	else if (ViolenceName == ViolenceModes[6])
		bNukeMode = true;
		
	//log(ViolenceName@bLieberMode@bHestonMode@bInsaneoMode@bLudicrousMode);
	
	GetPlayerOwner().ConsoleCommand("set"@c_strDifficultyPath@NPCDifficultySlider.GetValue());
	GetPlayerOwner().ConsoleCommand("set"@c_strDifficultyNumberPath@DIFFICULTY_NUMBER_CUSTOM);
	GetPlayerOwner().ConsoleCommand("set"@LieberPath@bLieberMode);
	GetPlayerOwner().ConsoleCommand("set"@HestonPath@bHestonMode);
	GetPlayerOwner().ConsoleCommand("set"@InsaneoPath@bInsaneoMode);
	GetPlayerOwner().ConsoleCommand("set"@LudicrousPath@bLudicrousMode);
	GetPlayerOwner().ConsoleCommand("set"@NukeModePath@bNukeMode);
	GetPlayerOwner().ConsoleCommand("set"@MeleePath@bMeleeMode);
	GetPlayerOwner().ConsoleCommand("set"@CustomPath@"true");
	
	GetPlayerOwner().ConsoleCommand("set"@TheyHateMePath@TheyHateMeCheckbox.GetValue());
	GetPlayerOwner().ConsoleCommand("set"@ExpertPath@ExpertCheckbox.GetValue());
	GetPlayerOwner().ConsoleCommand("set"@VeteranPath@VeteranCheckbox.GetValue());
	GetPlayerOwner().ConsoleCommand("set"@MasochistPath@MasochistCheckbox.GetValue());
	GetPlayerOwner().ConsoleCommand("set"@HardLieberPath@HardLiebermodeCheckbox.GetValue());
	
	if (bStartWith30Lives)
		GetPlayerOwner().ConsoleCommand("set"@ContraPath@"true");
}

///////////////////////////////////////////////////////////////////////////////
// Allows for use of custom difficulty
///////////////////////////////////////////////////////////////////////////////
function GoToStartMenu(class<ShellMenuCW> StartMenuClass)
{
	ApplyCustomDifficultySettings();
	GotoMenu(StartMenuClass);
}

defaultproperties
{
	TitleText="Custom Difficulty"
	MenuWidth  = 575
//	MenuHeight = 475
	ItemSpacingY = 10
	NPCDifficultySliderMax = 15
	
	ViolenceModeText="Violence Rating"
	ViolenceModeHelp="Determines the type of weapons NPCs receive and how tough they are."
	TheyHateMeText="They Hate Me"
	TheyHateMeHelp="Makes any armed NPC hate you on sight (as in They Hate Me difficulty)."
	ExpertText="Expert Mode"
	ExpertHelp="Disables stored health, allows just one save per level, and gives you an infinite radar."
	NPCDifficultyText="NPC Difficulty"
	NPCDifficultyHelp="Higher values make the NPCs meaner and tougher. 1 is the equivalent of Liebermode, 10 is the equivalent of Manic and above, and 15 is the equivalent of Ludicrous."
	
	VeteranText="Expert Mode Plus"
	VeteranHelp="NPCs don't drop their weapons, no infinite radar, your weapon and ammo capacity is limited, etc."
	MasochistText="Masochist Mode"
	MasochistHelp="Removes your immunity to special damage types (dismemberment, shotgun headshots, etc.)."
	HardLiebermodeText="Reversed Liebermode"
	HardLiebermodeHelp="Makes you unable to use anything but melee weapons. Goes well with Liebermode or Liebermode Plus (Violence Rating)."

	ViolenceModes[0]="Liebermode"
	ViolenceModes[1]="Liebermode Plus"
	ViolenceModes[2]="Normal"
	ViolenceModes[3]="Hestonworld"
	ViolenceModes[4]="Insane-o"
	ViolenceModes[5]="Ludicrous"
	ViolenceModes[6]="Mass Destruction"
	
	bStartWith30Lives=false
	
	KodeAccepted=Sound'arcade.arcade_52'
}