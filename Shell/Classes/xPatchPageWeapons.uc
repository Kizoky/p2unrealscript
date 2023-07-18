class xPatchPageWeapons extends xPatchPageBase;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

//var ShellMenuChoice			ViewmodelsChoice;
var UWindowSmallButton	ViewmodelsButton;
var localized string	ViewmodelsText;
var localized string	ViewmodelsHelp;

var float ButtonWidth, ButtonHeight;

// Muzzle Flashes
const MuzzleFlashPath = "Postal2Game.xPatchManager iMFEffect";
var UWindowComboControl MuzzleFlashCombo;
var localized string MuzzleFlashText, MuzzleFlashHelp;
var localized string MuzzleFlashModes[2];

// Dynamic Lights
const DynamicLightsPath = "Postal2Game.xPatchManager bDynamicLights";
var UWindowCheckbox DynamicLights;
var localized string DynamicLightsText, DynamicLightsHelp;

// Shells
const ShellsPath = "Postal2Game.xPatchManager bShellCases";
var UWindowCheckbox		ShellsCheckbox;
var localized string	ShellsText;
var localized string	ShellsHelp;
var localized string 	ShellsWarning;

// Shells Lifetime
var UWindowHSliderControl ShellsLifetimeSlider;
var localized string ShellsLifetimeText;
var localized string ShellsLifetimeHelp;
const ShellsLifetimePath = "Postal2Game.xPatchManager ShellLifetime";

// Grenade Launcher
const GrenadePath = "Postal2Game.xPatchManager bSteamGrenadeLauncher";
var UWindowCheckbox		GrenadeCheckbox;
var localized string	GrenadeText;
var localized string	GrenadeHelp;

// Super Rifle
const SuperRiflePath = "Postal2Game.xPatchManager bSuperRifle";
var UWindowCheckbox SuperRifleCheckbox;
var localized string SuperRifleText;
var localized string SuperRifleHelp;

// Baseball bat
const BaseballPath = "Postal2Game.xPatchManager bBaseballCounter";
var UWindowCheckbox BatCheckbox;
var localized string BatText;
var localized string BatHelp;

// Glock 
const GLOCK_BURST			= 0;
const GLOCK_AUTO			= 1;
const GLOCK_ALL		    	= 2;
var UWindowComboControl GlockModeCombo;
var localized string 	GlockModes[3];
var localized string	GlockText;
var localized string	GlockHelp;
const GlockPath = "Postal2Game.xPatchManager iGlockMode";
var int GlockType;

// Revolver 
var UWindowComboControl RevolverModeCombo;
var localized string 	RevolverModes[3];
var localized string	RevolverBarText;
var localized string	RevolverBarHelp;
const RevolverPath = "Postal2Game.xPatchManager iRevolverMode";

///////////////////////////////////////////////////////////////////////////////
// Create contents
///////////////////////////////////////////////////////////////////////////////
function Created()
{
	bInitialized = False;
	
	///////////////////////////////////////////////////////////////////////////////
	Super.Created();

	//ViewmodelsChoice	= AddChoice(ViewmodelsText, ViewmodelsHelp, ControlFont, ItemAlign, false);
	//ViewmodelsChoice 	= AddLabel(ViewmodelsText, F_FancyS, 0);
	//ViewmodelsChoice.bActive = True;
	
	//ViewmodelsButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 0, ControlOffset, WinWidth, ControlHeight));
	ViewmodelsButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-56, WinHeight-24, 48, 16));
	ViewmodelsButton.SetText(ViewmodelsText);
	ViewmodelsButton.SetFont(F_Smallbold);
	
	ControlOffset += (ControlHeight * 1.5);			// Add Space
	
	MuzzleFlashCombo			= AddComboBox(MuzzleFlashText, MuzzleFlashHelp, ControlFont);
	DynamicLights				= AddCheckbox(DynamicLightsText, DynamicLightsHelp, ControlFont);
	
	ControlOffset += (ControlHeight * 0.5);			// Add Space
	
	ShellsCheckbox			= AddCheckbox(ShellsText, ShellsHelp, ControlFont);
	ShellsLifetimeSlider	= AddSlider(ShellsLifetimeText, ShellsLifetimeHelp, ControlFont, 1, 10);
	
	GlockModeCombo 			= AddComboBox(GlockText, GlockHelp, ControlFont);
	//if(bParadiseLost)
		RevolverModeCombo 			= AddComboBox(RevolverBarText, RevolverBarHelp, ControlFont);
	SuperRifleCheckbox		= AddCheckbox(SuperRifleText, SuperRifleHelp, ControlFont);
	GrenadeCheckbox 		= AddCheckbox(GrenadeText, GrenadeHelp, ControlFont);
	BatCheckbox				= AddCheckbox(BatText, BatHelp, ControlFont);
//	EDExpCheckbox			= AddCheckbox(EDExpText, EDExpHelp, ControlFont);


}
/*
function Resized()
{
	Super.Resized();

	ViewmodelsButton.WinLeft = WinLeft+52;
	ViewmodelsButton.WinTop = WinTop;
}
*/
function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	// display in the center
	ControlLeft = (WinWidth - ControlWidth)/2;
	
	
	ViewmodelsButton.WinLeft = WinLeft+(WinWidth/2)-(ButtonWidth/2);
	ViewmodelsButton.WinTop = WinTop+(ControlHeight * 0.5);
	ViewmodelsButton.SetSize(ButtonWidth, ButtonHeight);
	
	//ViewmodelsButton.WinLeft = ControlLeft + (ButtonWidth * 0.5);
	
	//ViewmodelsButton.WinTop = ControlOffset + 24;
	
	//ViewmodelsChoice.SetSize(CheckWidth, ControlHeight);
	//ViewmodelsChoice.WinLeft = ControlLeft;
	
	// display in the center
	ControlLeft = (WinWidth - ControlWidth*2/3)/2;
	
	MuzzleFlashCombo.SetSize(ControlWidth-EditWidth+170, ControlHeight+3);
	MuzzleFlashCombo.WinLeft = ControlLeft;
	MuzzleFlashCombo.EditBoxWidth = 170;
	
	GlockModeCombo.SetSize(ControlWidth-EditWidth+170, ControlHeight+3);
	GlockModeCombo.WinLeft = ControlLeft;
	GlockModeCombo.EditBoxWidth = 170;
	
	RevolverModeCombo.SetSize(ControlWidth-EditWidth+170, ControlHeight+3);
	RevolverModeCombo.WinLeft = ControlLeft;
	RevolverModeCombo.EditBoxWidth = 170;
	
	DynamicLights.SetSize(CheckWidth, ControlHeight);
	DynamicLights.WinLeft = ControlLeft;
	
	ShellsCheckbox.SetSize(CheckWidth, ControlHeight);
	ShellsCheckbox.WinLeft = ControlLeft;
	
	ShellsLifetimeSlider.SetSize(CheckWidth+98, ControlHeight);
	ShellsLifetimeSlider.SliderWidth = 100;
	ShellsLifetimeSlider.WinLeft = ControlLeft;
	
	SuperRifleCheckbox.SetSize(CheckWidth, ControlHeight);
	SuperRifleCheckbox.WinLeft = ControlLeft;
	
	GrenadeCheckbox.SetSize(CheckWidth, ControlHeight);
	GrenadeCheckbox.WinLeft = ControlLeft;
	
	BatCheckbox.SetSize(CheckWidth, ControlHeight);
	BatCheckbox.WinLeft = ControlLeft;
}

function AfterCreate()
{
	local float fVal;
	local int iVal;
	local bool flag;

	Super.AfterCreate();
	
	///////////////////////////////////////////////////////////////////////////////
	
	// Muzzle Flash
	MuzzleFlashCombo.Clear();
	for (iVal = 0; iVal < ArrayCount(MuzzleFlashModes); iVal++)
		MuzzleFlashCombo.AddItem(MuzzleFlashModes[iVal]);
	
	iVal = int(GetPlayerOwner().ConsoleCommand("get" @ MuzzleFlashPath));	
	MuzzleFlashCombo.SetValue(MuzzleFlashModes[iVal]);
	
	// Dynamic lights
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@DynamicLightsPath));
	DynamicLights.SetValue(flag);
	
	// Glock
	GlockModeCombo.Clear();
	for (iVal = 0; iVal < ArrayCount(GlockModes); iVal++)
		GlockModeCombo.AddItem(GlockModes[iVal]);
	
	iVal = int(GetPlayerOwner().ConsoleCommand("get" @ GlockPath));	
	GlockModeCombo.SetValue(GlockModes[iVal]);
	
	// Revolver
	RevolverModeCombo.Clear();
	for (iVal = 0; iVal < ArrayCount(RevolverModes); iVal++)
		RevolverModeCombo.AddItem(RevolverModes[iVal]);
	
	iVal = int(GetPlayerOwner().ConsoleCommand("get" @ RevolverPath));	
	RevolverModeCombo.SetValue(RevolverModes[iVal]);
	
	// Grenade Launcher
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@GrenadePath));
	GrenadeCheckbox.SetValue(flag);

	// Super Rifle
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@SuperRiflePath));
	SuperRifleCheckbox.SetValue(flag);
	
	// Baseball Bat
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@BaseballPath));
	BatCheckbox.SetValue(flag);
	
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@ShellsPath));
	ShellsCheckbox.SetValue(flag);
	
	fVal = float(GetPlayerOwner().ConsoleCommand("get" @ ShellsLifetimePath));
	ShellsLifetimeSlider.SetValue(fVal);
	
	ShellsLifetimeSlider.SetText(ShellsLifetimeText$" ("$int(ShellsLifetimeSlider.GetValue())$"s)");
	
	///////////////////////////////////////////////////////////////////////////////

	bInitialized = True;
}

function Notify(UWindowDialogControl C, byte E)
{
	if(bInitialized)
	{
		switch (E)
		{
			case DE_Change:
				switch (C)
					{
					case MuzzleFlashCombo:
						MuzzleFlashComboChanged();
						break;	
					case DynamicLights:
						CheckboxChange(DynamicLightsPath, DynamicLights.GetValue());
						break;	
					case GlockModeCombo:
						GlockModeChanged();
						break;
					case GrenadeCheckbox:
						CheckboxChange(GrenadePath, GrenadeCheckbox.GetValue());
					case SuperRifleCheckbox:
						CheckboxChange(SuperRiflePath, SuperRifleCheckbox.GetValue());
						break;
					case BatCheckbox:
						CheckboxChange(BaseballPath, BatCheckbox.GetValue());
						break;
					case ShellsCheckbox:
						CheckboxChange(ShellsPath, ShellsCheckbox.GetValue(), WarningTitle, ShellsWarning, ShellsCheckbox.GetValue());
						P2Weapon(GetPlayerOwner().Pawn.Weapon).SetupShell(); 
						break;
					case ShellsLifetimeSlider:
						SliderChanged(ShellsLifetimePath, ShellsLifetimeSlider.GetValue());
						ShellsLifetimeSlider.SetText(ShellsLifetimeText$" ("$int(ShellsLifetimeSlider.GetValue())$"s)");
						break;
					case RevolverModeCombo:
						RevolverModeChanged();
						break;
				}
				break;
			case DE_Click:
				switch (C)
					{
					case ViewmodelsButton:
						//GoToMenu(class'xPatchMenuViewmodels');
						if(ShellRootWindow(Root) != None)
						{
							ShellRootWindow(Root).GoBack();
							ShellRootWindow(Root).GoToMenu(class'MenuOptions', class'xPatchMenuViewmodels');
						}
						break;
				break;
			}
		}
	}
	Super.Notify(C, E);
}

///////////////////////////////////////////////////////////////////////////////
// Set all values to default
///////////////////////////////////////////////////////////////////////////////
function SetDefaultValues()
{
	MuzzleFlashCombo.SetValue(MuzzleFlashModes[1]);
	GlockModeCombo.SetValue(GlockModes[1]);	
	RevolverModeCombo.SetValue(RevolverModes[0]);	
	DynamicLights.SetValue(False);
	GrenadeCheckbox.SetValue(False);
	SuperRifleCheckbox.SetValue(True);
	BatCheckbox.SetValue(False);
	ShellsCheckbox.SetValue(False);
	ShellsLifetimeSlider.SetValue(3);
}


///////////////////////////////////////////////////////////////////////////////
// Changes
///////////////////////////////////////////////////////////////////////////////
function MuzzleFlashComboChanged()
{
	local String NewMuzzleFlashMode;

	if (bInitialized)
		{
			NewMuzzleFlashMode = MuzzleFlashCombo.GetValue();
			
			if (NewMuzzleFlashMode == MuzzleFlashModes[0])	
				GetPlayerOwner().ConsoleCommand("set" @ MuzzleFlashPath @ 0);

			if (NewMuzzleFlashMode == MuzzleFlashModes[1])
				GetPlayerOwner().ConsoleCommand("set" @ MuzzleFlashPath @ 1);
			
			// Update all the weapons with the new settings.
			class'Postal2Game.P2Weapon'.static.ViewmodelSettingsUpdated(P2Player(GetPlayerOwner()), False);
		}
}

function GlockModeChanged()
{
	local String NewGlockMode;

	if (bInitialized)
	{
		NewGlockMode = GlockModeCombo.GetValue();
			
		if (NewGlockMode == GlockModes[GLOCK_BURST])
			GetPlayerOwner().ConsoleCommand("set" @ GlockPath @ GLOCK_BURST);
			
		if (NewGlockMode == GlockModes[GLOCK_AUTO])
			GetPlayerOwner().ConsoleCommand("set" @ GlockPath @ GLOCK_AUTO);
			
		if (NewGlockMode == GlockModes[GLOCK_ALL])
			GetPlayerOwner().ConsoleCommand("set" @ GlockPath @ GLOCK_ALL);
	}
}

function RevolverModeChanged()
{
	local String RevolverMode;

	if (bInitialized)
	{
		RevolverMode = RevolverModeCombo.GetValue();
			
		if (RevolverMode == RevolverModes[0])
			GetPlayerOwner().ConsoleCommand("set" @ RevolverPath @ 0);
			
		if (RevolverMode == RevolverModes[1])
			GetPlayerOwner().ConsoleCommand("set" @ RevolverPath @ 1);
			
		if (RevolverMode == RevolverModes[2])
			GetPlayerOwner().ConsoleCommand("set" @ RevolverPath @ 2);
		
		// Uhhh.. yeah let's do this this way... for now(?)
		GetPlayerOwner().ConsoleCommand("set RevolverWeapon bModeChecked False");
	}
}

defaultproperties
{
	PageHeaderText="Customize various weapon related settings."
	ControlWidthPercent=0.75
	
	 ViewmodelsText = "Adjust Viewmodels"
	 ButtonWidth = 125
	 ButtonHeight = 20
	 
	 DynamicLightsText="Dynamic Lights"
	 DynamicLightsHelp="Enables muzzle flash dynamic lighting."	 
	 MuzzleFlashText = "Muzzle Flash Style"
	 MuzzleFlashHelp = "Choose between particle-based and sprite-based muzzle flash effects."
	 MuzzleFlashModes[0] = "Sprite"
	 MuzzleFlashModes[1] = "Particle"	
	 GlockText="Machine Pistol Modes"
     GlockHelp="Choose the selectable firing modes for the Machine Pistol."
	 GlockModes[0]="Semi and Burst"
	 GlockModes[1]="Semi and Auto"
	 GlockModes[2]="Semi, Burst, and Auto"	 
	 RevolverBarText="Revolver Execution Bar"
	 RevolverBarHelp="Choose the display method of the execution bar."
	 RevolverModes[0]="Simple Meter"
	 RevolverModes[1]="Graphic Meter"
	 RevolverModes[2]="Percentage"	 
	 GrenadeText="Hand Grenade Launcher"
     GrenadeHelp="Toggles Grenade Launcher projectile."
	 BatText="Baseball Bat Distance Counter"
	 BatHelp="Enables a distance counter for Baseball Bat. Shows how far a person's head went off their shoulders."	 
	 SuperRifleText="Super Rifle Damage"
	 SuperRifleHelp="Hunting Rifle bullets dismember bodies and explode heads."	 
	 ShellsText = "Spawn Shells"
	 ShellsHelp = "Guns spawn shells that drop to the ground." 
	 ShellsLifetimeText = "Shells Lifetime"
	 ShellsLifetimeHelp = "How long shells remain before disappearing." 
	
	 ShellsWarning	 = "Enabling this option will affect performance."
}