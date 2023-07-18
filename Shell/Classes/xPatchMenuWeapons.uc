///////////////////////////////////////////////////////////////////////////////
// xPatchMenu.uc
//
// Settings menu for xPatch 2.0 
// by Man Chrzan 
///////////////////////////////////////////////////////////////////////////////
class xPatchMenuWeapons extends xPatchMenuBase;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var ShellMenuChoice			ViewmodelsChoice;
var localized string	 	ViewmodelsText;
var localized string	 	ViewmodelsHelp;

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

// Keep Blood
const KeepBloodPath = "Postal2Game.xPatchManager bKeepBlood";
var UWindowCheckbox		KeepBloodCheckbox;
var localized string	KeepBloodText;
var localized string	KeepBloodHelp;

// Randomize Guns
const RandomGunsPath = "Postal2Game.xPatchManager bRandomGuns";
var UWindowCheckbox		RandomGunsCheckbox;
var localized string	RandomGunsText;
var localized string	RandomGunsHelp;

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

// Dual Wield SFX
var UWindowCheckbox		DualSFXCheckbox;
var localized string	DualSFXText;
var localized string	DualSFXHelp;
const DualSFXPath = "Postal2Game.xPatchManager bDualEffect";

// Moved from MenuGameSettings
const c_strDualWieldSwapPath = "Postal2Game.P2Player bDualWieldSwap";
var UWindowCheckbox DualWieldSwapCheckbox;
var localized string DualWieldSwapText;
var localized string DualWieldSwapHelp;

// Variable is named opposite to effect, so this must be flipped(with !) everytime you set it.
const c_strWeaponSwitch = "Engine.PlayerController bneverswitchonpickup";
var UWindowCheckbox WeaponSwitchCheckbox;
var localized string WeaponSwitchText;
var localized string WeaponSwitchHelp;

const c_strWeaponEmpty = "Postal2Game.P2Player bAutoSwitchOnEmpty";
var UWindowCheckbox WeaponEmptyCheckbox;
var localized string WeaponEmptyText;
var localized string WeaponEmptyHelp;

//////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();
	
	AddTitle(TitleText, TitleFont, TitleAlign);
	
	if(FPSPlayer(GetPlayerOwner()).bEnableDebugMenu)
		ViewmodelsChoice	= AddChoice(ViewmodelsText, ViewmodelsHelp, ItemFont, ItemAlign, false);
		
	RandomGunsCheckbox		= AddCheckbox(RandomGunsText, RandomGunsHelp, ItemFont);
	
	// Moved from MenuGameSettings
	WeaponSwitchCheckbox    = AddCheckbox(WeaponSwitchText, WeaponSwitchHelp, ItemFont);
	WeaponEmptyCheckbox     = AddCheckbox(WeaponEmptyText, WeaponEmptyHelp, ItemFont);
	DualWieldSwapCheckbox	= AddCheckbox(DualWieldSwapText, DualWieldSwapHelp, ItemFont);
	
	DualSFXCheckbox			= AddCheckbox(DualSFXText, DualSFXHelp, ItemFont);
	MuzzleFlashCombo			= AddComboBox(MuzzleFlashText, MuzzleFlashHelp, ItemFont);
	DynamicLights				= AddCheckbox(DynamicLightsText, DynamicLightsHelp, ItemFont);
	ShellsCheckbox			= AddCheckbox(ShellsText, ShellsHelp, ItemFont);
	ShellsLifetimeSlider	= AddSlider(ShellsLifetimeText, ShellsLifetimeHelp, ItemFont, 1, 10);	
	KeepBloodCheckbox		= AddCheckbox(KeepBloodText, KeepBloodHelp, ItemFont);
	GlockModeCombo 			= AddComboBox(GlockText, GlockHelp, ItemFont);
	if(bParadiseLost)
		RevolverModeCombo 			= AddComboBox(RevolverBarText, RevolverBarHelp, ItemFont);
	SuperRifleCheckbox		= AddCheckbox(SuperRifleText, SuperRifleHelp, ItemFont);
	GrenadeCheckbox 		= AddCheckbox(GrenadeText, GrenadeHelp, ItemFont);
	BatCheckbox				= AddCheckbox(BatText, BatHelp, ItemFont);

//	EDExpCheckbox			= AddCheckbox(EDExpText, EDExpHelp, ItemFont);
//	FlashFXCheckbox			= AddCheckbox(FlashFXText, FlashFXHelp, ItemFont);

	RestoreChoice    	= AddChoice(RestoreText, RestoreHelp,	ItemFont, ItemAlign);
	BackChoice       	= AddChoice(BackText,    "",			ItemFont, ItemAlign, true);

	LoadValues();
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
					CheckboxChange(ShellsPath, ShellsCheckbox.bChecked, WarningTitle, PerformanceText, ShellsCheckbox.bChecked);
					P2Weapon(GetPlayerOwner().Pawn.Weapon).SetupShell(); 
					break;
				case ShellsLifetimeSlider:
					SliderChanged(ShellsLifetimePath, ShellsLifetimeSlider.GetValue());
					break;
				case KeepBloodCheckbox:
					CheckboxChange(KeepBloodPath, KeepBloodCheckbox.GetValue());
					break;
				case RandomGunsCheckbox:
					CheckboxChange(RandomGunsPath, RandomGunsCheckbox.GetValue());
					break;	
				case RevolverModeCombo:
					RevolverModeChanged();
					break;
				case DualSFXCheckbox:
					CheckboxChange(DualSFXPath, DualSFXCheckbox.GetValue());
					break;
				// Moved from Game Settings
				case WeaponSwitchCheckbox:
					WeaponSwitchCheckboxChanged();
					break;
				case WeaponEmptyCheckbox:
					WeaponEmptyCheckboxChanged();
				case DualWieldSwapCheckbox:
					DualWieldSwapCheckboxChanged();
					break;
			}
			break;
		case DE_Click:
			switch (C)
				{
				case ViewmodelsChoice:
					GoToMenu(class'xPatchMenuViewmodels');
					break;
			break;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Load all values from ini files
///////////////////////////////////////////////////////////////////////////////
function LoadValues()
{
	local float fVal;
	local int iVal;
	local bool flag;
	
	bUpdate = false;
	
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
	
	flag = bool(GetPlayerOwner().ConsoleCommand("get" @ KeepBloodPath));
	KeepBloodCheckbox.SetValue(flag);
	
	flag = bool(GetPlayerOwner().ConsoleCommand("get" @ RandomGunsPath));
	RandomGunsCheckbox.SetValue(flag);
	
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@DualSFXPath));
	DualSFXCheckbox.SetValue(flag);
	
// Moved from Game Settings
	// Value true or false
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strWeaponSwitch));
	WeaponSwitchCheckbox.SetValue(!flag);

	// 12/12/02 JMI Mapped to bAutoSwitchOnEmpty.
	// Value true or false
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strWeaponEmpty));
	WeaponEmptyCheckbox.SetValue(flag);
	
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strDualWieldSwapPath));
	DualWieldSwapCheckbox.SetValue(flag);
	
	///////////////////////////////////////////////////////////////////////////////

	bUpdate = true;
	
}

///////////////////////////////////////////////////////////////////////////////
// Set all values to default
///////////////////////////////////////////////////////////////////////////////
function SetDefaultValues()
{
	bAsk = false;
	
	///////////////////////////////////////////////////////////////////////////////
	
	MuzzleFlashCombo.SetValue(MuzzleFlashModes[0]);
	GlockModeCombo.SetValue(GlockModes[2]);	
	RevolverModeCombo.SetValue(RevolverModes[0]);	
	DynamicLights.SetValue(False);
	GrenadeCheckbox.SetValue(False);
	SuperRifleCheckbox.SetValue(True);
	BatCheckbox.SetValue(False);
	ShellsCheckbox.SetValue(False);
	ShellsLifetimeSlider.SetValue(3);
	KeepBloodCheckbox.SetValue(False);
	RandomGunsCheckbox.SetValue(True);
	DualSFXCheckbox.SetValue(true);
	
	WeaponSwitchCheckbox.SetValue(false);
	DualWieldSwapCheckbox.SetValue(false);
	WeaponEmptyCheckbox.SetValue(true);

	///////////////////////////////////////////////////////////////////////////////
	
	bAsk = true;
}

///////////////////////////////////////////////////////////////////////////////
// Changes
///////////////////////////////////////////////////////////////////////////////
function MuzzleFlashComboChanged()
{
	local String NewMuzzleFlashMode;

	if (bUpdate)
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

	if (bUpdate)
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

	if (bUpdate)
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


function WeaponSwitchCheckboxChanged()
	{
	local int val;

	if (bUpdate)
		{
		//GetPlayerOwner().ConsoleCommand("set"@c_strWeaponSwitch@!(WeaponSwitchCheckbox.bChecked));
		P2Player(GetPlayerOwner()).default.bneverswitchonpickup = !WeaponSwitchCheckbox.bChecked;
		P2Player(GetPlayerOwner()).bneverswitchonpickup = !WeaponSwitchCheckbox.bChecked;
		GetPlayerOwner().Static.StaticSaveConfig();
		}
	}

function WeaponEmptyCheckboxChanged()
	{
	if (bUpdate)
		{
		//GetPlayerOwner().ConsoleCommand("set"@c_strWeaponEmpty@WeaponEmptyCheckbox.bChecked);
		P2Player(GetPlayerOwner()).default.bAutoSwitchOnEmpty = WeaponEmptyCheckbox.bChecked;
		P2Player(GetPlayerOwner()).bAutoSwitchOnEmpty = WeaponEmptyCheckbox.bChecked;
		GetPlayerOwner().Static.StaticSaveConfig();
		}
	}
	
function DualWieldSwapCheckboxChanged()
{
	if (bUpdate)
		GetPlayerOwner().ConsoleCommand("set"@c_strDualWieldSwapPath@DualWieldSwapCheckbox.GetValue());
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	TitleText="Weapons Settings"
	MenuWidth=735
	
	 ViewmodelsText = "(DEBUG) Adjust Viewmodels..."
	 ViewmodelsHelp = ""
	 
	 DynamicLightsText="Dynamic Lights"
	 DynamicLightsHelp="Enables muzzle flash dynamic lighting."
	 
	 MuzzleFlashText = "Muzzle Flash Style"
	 MuzzleFlashHelp = "Choose between the default (2023) and alternative (2013) muzzle flash effects."
	 MuzzleFlashModes[0] = "Default"
	 MuzzleFlashModes[1] = "Alternative"
	
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

	 BatText="Bat Distance Counter"
	 BatHelp="Enables a distance counter for the Baseball Bat. Shows how far a person's head went off their shoulders."
	 
	 SuperRifleText="Super Rifle Damage"
	 SuperRifleHelp="Hunting Rifle bullets dismember bodies and explode heads."
	 
	 ShellsText = "Spawn Shells"
	 ShellsHelp = "Guns spawn actual shells that drop on the ground."
	 
	 ShellsLifetimeText = "Shells Lifetime"
	 ShellsLifetimeHelp = "How long shells stay before disappearing."
	 
	 RandomGunsText = "Expanded NPC Gun Variety"
	 RandomGunsHelp = "Bystanders have a random chance of using Eternal Damnation weapons."
	 
	 KeepBloodText = "Keep Blood on Melee Weapons"
	 KeepBloodHelp ="Blood remains on melee weapons after deselecting them."
	  
	DualSFXText="Dual Wielding SFX"
	DualSFXHelp="Toggles dual wielding sound effects."
	
	DualWieldSwapText = "Dual Wielding Swap"
	DualWieldSwapHelp = "Switches the Fire and Alt Fire buttons while dual wielding or for specific weapons that request it."
	
	WeaponSwitchText = "Auto-Switch Weapons on Pickup"
	WeaponSwitchHelp = "Switches to weapons when they are picked up"
	
	WeaponEmptyText = "Auto-Switch Weapons on Empty"
	WeaponEmptyHelp = "Switches to next-best weapon when ammo runs out"
}
