///////////////////////////////////////////////////////////////////////////////
// Seekrit menu
///////////////////////////////////////////////////////////////////////////////
class PLMenuSeekrit extends PLMenuStart;

var config int NPCDifficultySliderMax;

var UWindowHSliderControl NPCDifficultySlider;
var localized string NPCDifficultyText, NPCDifficultyHelp;
var UWindowComboControl ViolenceModeCombo;	// Combobar for selecting Liebermode, Hestonworld etc.
var localized string ViolenceModeText, ViolenceModeHelp;
var UWindowCheckbox TheyHateMeCheckbox;		// Checkbox for They Hate Me Mode
var localized string TheyHateMeText, TheyHateMeHelp;
var UWindowCheckbox ExpertCheckbox;			// Checkbox for Expert mode
var localized string ExpertText, ExpertHelp;

var localized array<string> ViolenceModes;

var bool bStartWith30Lives;

const DIFFICULTY_NUMBER_CUSTOM = 15;


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
	ViolenceModeCombo.SetValue(ViolenceModes[1]);		
	// Seems too wide on the text side.
	ViolenceModeCombo.EditBoxWidth = ViolenceModeCombo.WinWidth * 0.3;
	
	TheyHateMeCheckbox = AddCheckbox(TheyHateMeText, TheyHateMeHelp, ItemFont);
	TheyHateMeCheckbox.SetValue(False);
	
	ExpertCheckbox = AddCheckbox(ExpertText, ExpertHelp, ItemFont);
	ExpertCheckbox.SetValue(False);

	if (GetGameSingle().SeqTimeVerified())
	{
		EnhancedCheckbox = AddCheckbox(EnhancedText, EnhancedHelp, ItemFont);
		EnhancedCheckbox.SetValue(False);
	}

	StartChoice	= AddChoice(StartText,	"", ItemFont, TA_Left);
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

	switch(E)
		{
		case DE_Change:
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
		case DE_Click:
			switch (C)
				{
				case StartWorkshop:
					// Before launching workshop window, apply custom difficulty settings.
					ApplyCustomDifficultySettings();
					break;
				}
		}
	Super.Notify(C, E);
	}

///////////////////////////////////////////////////////////////////////////////
// Actually applies customized difficulty settings
///////////////////////////////////////////////////////////////////////////////
function ApplyCustomDifficultySettings()
{
	local bool bLieberMode, bHestonMode, bInsaneoMode, bLudicrousMode;
	local string ViolenceName;

	// Actually apply the desired difficulty settings here, then start the game.
	ViolenceName = ViolenceModeCombo.GetValue();
	
	// Liebermode	
	if (ViolenceName == ViolenceModes[0])
		bLieberMode = true;
	else if (ViolenceName == ViolenceModes[2])
		bHestonMode = true;
	else if (ViolenceName == ViolenceModes[3])
		bInsaneoMode = true;
	else if (ViolenceName == ViolenceModes[4])
		bLudicrousMode = true;
		
	//log(ViolenceName@bLieberMode@bHestonMode@bInsaneoMode@bLudicrousMode);
	
	GetPlayerOwner().ConsoleCommand("set"@c_strDifficultyPath@NPCDifficultySlider.GetValue());
	GetPlayerOwner().ConsoleCommand("set"@c_strDifficultyNumberPath@DIFFICULTY_NUMBER_CUSTOM);
	GetPlayerOwner().ConsoleCommand("set"@LieberPath@bLieberMode);
	GetPlayerOwner().ConsoleCommand("set"@HestonPath@bHestonMode);
	GetPlayerOwner().ConsoleCommand("set"@InsaneoPath@bInsaneoMode);
	GetPlayerOwner().ConsoleCommand("set"@LudicrousPath@bLudicrousMode);
	GetPlayerOwner().ConsoleCommand("set"@CustomPath@"true");
	
	GetPlayerOwner().ConsoleCommand("set"@TheyHateMePath@TheyHateMeCheckbox.GetValue());
	GetPlayerOwner().ConsoleCommand("set"@ExpertPath@ExpertCheckbox.GetValue());
	
	if (bStartWith30Lives)
		GetPlayerOwner().ConsoleCommand("set"@ContraPath@"true");
}


///////////////////////////////////////////////////////////////////////////////
// Allows for use of enhanced mode
///////////////////////////////////////////////////////////////////////////////
function StartGame2(bool bEnhanced)
{
	ApplyCustomDifficultySettings();
	
	// Now start the game in normal or enhanced mode
	Super.StartGame2(bEnhanced);
}

defaultproperties
{
	TitleText="Custom Difficulty"
	MenuWidth  = 475
	MenuHeight = 425
	ItemSpacingY = 10
	NPCDifficultySliderMax = 15
	
	ViolenceModeText="Violence Rating"
	ViolenceModeHelp="NPC violence rating (determines the type of weapons they receive)"
	TheyHateMeText="They Hate Me"
	TheyHateMeHelp="Makes any armed NPC hate you on sight (as in They Hate Me difficulty)"
	ExpertText="Expert Mode"
	ExpertHelp="Disables stored health and allows just one save per level (Cannot use with Enhanced Game)"
	NPCDifficultyText="NPC Difficulty"
	NPCDifficultyHelp="Higher values make the NPC's meaner and tougher. 1 is the equivalent of Liebermode, 10 is the equivalent of Manic and above."

	ViolenceModes[0]="Liebermode"
	ViolenceModes[1]="Normal"
	ViolenceModes[2]="Hestonworld"
	ViolenceModes[3]="Insane-o"
	ViolenceModes[4]="Ludicrous"
	
	bStartWith30Lives=false
	
	KodeAccepted=Sound'arcade.arcade_52'
}
