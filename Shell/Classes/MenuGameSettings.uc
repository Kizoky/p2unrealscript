///////////////////////////////////////////////////////////////////////////////
// MenuGameSettings.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// The game settings menu.
//
// History:	
// 4/29 Kamek - backported AW7 game timer
//
//	05/15/03 NPF	Added Tracers option.
//
//	02/05/03 JMI	Moved difficulty to new MenuStart.
//
//	02/12/03 MJR	Added autosave option.
//
//	02/12/03 JMI	Added reticle submenu.
//
//	01/22/03 JMI	Changed iCommonCtlDivisor to fCommonCtlArea both in name
//					and behavior.
//
//	01/20/03 JMI	Made IsInGame into a function of ShellMenuCW from direct 
//					usage in MenuGameSettings so more menus can utilize it.
//
//	01/17/03 NPF	Removed bDamageFlash and replace with DamageAlphaSlider.
//	01/13/03 NPF	Added bNeverSwitchOnPickup
//	01/13/03 JMI	Added strHelp parameter to AddChoice() allowing us to pass
//					in many help strings that had been created but were not 
//					being used for standard menu choices.  Added generic 
//					RestoreHelp for menus sporting a Restore option.
//
//	01/12/03 JMI	Changed bDontAsk to bAsk.
//
//	01/08/03 JMI	bDontUpdate's usage was backward from the name of the
//					var and the associated comment.  Renamed the var and changed
//					the comment rather than risking changing the code.
//
//  01/06/03 NPF	Exposed WeaponBob after adding var to Postal2Game
//  12/17/02 NPF	Moved Input.. to MenuControls.
//	12/11/02 JMI	For gore, we were reading in "GoreLevel" and writing out
//					"Gore".  Added c_strGorePath to fix.  Did the same for the
//					other vars.
//					bInventoryHints, bGameplayHints, and bDamageFlash were all
//					being read as integers which would just always come back 0
//					b/c they are stored as boolean "True" or "False".
//					Mapped WeaponEmpty to bAutoSwitchOnEmpty.  Couldn't find
//					vars for WeaponBob & WeaponSwitch so hid these.
//
//	08/31/02 MJR	Started it.
//
///////////////////////////////////////////////////////////////////////////////
class MenuGameSettings extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized string GameSettingsTitleText;

const c_strAutoSavePath = "Postal2Game.P2GameInfoSingle bUseAutoSave";
var UWindowCheckbox AutoSaveCheckbox;
var localized string AutoSaveText;
var localized string AutoSaveHelp;

const c_strGorePath = "Postal2Game.P2Player ShowBlood";
var UWindowCheckbox GoreCheckbox;
var localized string GoreText;
var localized string GoreHelp;

const c_strInvHintsPath = "Postal2Game.P2GameInfo bInventoryHints";
var UWindowCheckbox InvHintsCheckbox;
var localized string InvHintsText;
var localized string InvHintsHelp;

const c_strGameHintsPath = "Postal2Game.P2GameInfo bGameplayHints";
var UWindowCheckbox GameHintsCheckbox;
var localized string GameHintsText;
var localized string GameHintsHelp;

const c_strMPHintsPath = "Postal2Game.P2PLayer bMPHints";
var UWindowCheckbox MpHintsCheckbox;
var localized string MpHintsText;
var localized string MpHintsHelp;

const c_strWeaponBobPath = "Postal2Game.P2PLayer bWeaponBob";
var UWindowCheckbox WeaponBobCheckbox;
var localized string WeaponBobText;
var localized string WeaponBobHelp;

const c_strTracersPath = "Postal2Game.P2GameInfo bShowTracers";
var UWindowCheckbox TracersCheckbox;
var localized string TracersText;
var localized string TracersHelp;

// Variable is named opposite to effect, so this must be flipped(with !) everytime you set it.
const c_strWeaponSwitch = "Engine.PlayerController bneverswitchonpickup";
var UWindowCheckbox WeaponSwitchCheckbox;
var localized string WeaponSwitchText;
var localized string WeaponSwitchHelp;

const c_strWeaponEmpty = "Postal2Game.P2Player bAutoSwitchOnEmpty";
var UWindowCheckbox WeaponEmptyCheckbox;
var localized string WeaponEmptyText;
var localized string WeaponEmptyHelp;

// Variable is named opposite to effect, so this must be flipped(with !) everytime you set it.
const c_StrItemSwitch = "Engine.PlayerController bNeverSwitchItemOnPickup";
var UWindowCheckbox ItemSwitchCheckbox;
var localized string ItemSwitchText;
var localized string ItemSwitchHelp;

const c_strDamageFlashPath = "Postal2Game.P2Player HurtBarAlpha";
var UWindowHSliderControl DamageFlashSlider;
var localized string DamageFlashText;
var localized string DamageFlashHelp;

const c_strDrawPath = "Postal2Game.P2GameInfoSingle bDrawTime";
var UWindowCheckbox DrawTimeCheckbox;
var localized string DrawTimeText;
var localized string DrawTimeHelp;

const c_strStrictPath = "Postal2Game.P2GameInfoSingle bStrictTime";
var UWindowCheckbox StrictTimeCheckbox;
var localized string StrictTimeText;
var localized string StrictTimeHelp;

const c_strAchPath = "GameTypes.P2AchievementManager bDisplayAchievements";
var UWindowCheckbox AchCheckbox;
var localized string AchText, AchHelp;

const c_strAutoAimPath = "Engine.GameInfo AutoAim";
var UWindowHSliderControl AutoAimSlider;
var localized string AutoAimText;
var localized string AutoAimHelp;

const c_strSelectorPath = "Postal2Game.P2GameInfo bUseWeaponSelector";
var UWindowCheckbox SelectorCheckbox;
var localized string SelectorText;
var localized string SelectorHelp;

const c_strSelectorSwitchPath = "Postal2Game.P2GameInfo bWeaponSelectorAutoSwitch";
var UWindowCheckbox SelectorSwitchCheckbox;
var localized string SelectorSwitchText;
var localized string SelectorSwitchHelp;

const c_strSelectorFullPath = "GameTypes.P2WeaponSelector bFullScreen";
var UWindowCheckbox SelectorFullCheckbox;
var localized string SelectorFullText;
var localized string SelectorFullHelp;


const c_strCrouchTogglePath = "Postal2Game.P2Player bCrouchToggle";
var UWindowCheckbox CrouchToggleCheckbox;
var localized string CrouchToggleText;
var localized string CrouchToggleHelp;

const c_strDualWieldSwapPath = "Postal2Game.P2Player bDualWieldSwap";
var UWindowCheckbox DualWieldSwapCheckbox;
var localized string DualWieldSwapText;
var localized string DualWieldSwapHelp;

var bool bUpdate;
var bool bAsk;


///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();
	AddTitle(GameSettingsTitleText, TitleFont, TitleAlign);
	
	ReticleChoice			= AddChoice(ReticleText, ReticleHelp, ItemFont, ItemAlign);
	AutoSaveCheckbox		= AddCheckbox(AutoSaveText, AutoSaveHelp, ItemFont);
	GoreCheckbox			= AddCheckbox(GoreText, GoreHelp, ItemFont);
	InvHintsCheckbox		= AddCheckbox(InvHintsText, InvHintsHelp, ItemFont);
	GameHintsCheckbox		= AddCheckbox(GameHintsText, GameHintsHelp, ItemFont);
	//MpHintsCheckbox			= AddCheckbox(MpHintsText, MpHintsHelp, ItemFont);
	SelectorCheckbox		= AddCheckbox(SelectorText, SelectorHelp, ItemFont);
	SelectorFullCheckbox	= AddCheckbox(SelectorFullText, SelectorFullHelp, ItemFont);
	SelectorSwitchCheckbox	= AddCheckbox(SelectorSwitchText, SelectorSwitchHelp, ItemFont);
	WeaponSwitchCheckbox    = AddCheckbox(WeaponSwitchText, WeaponSwitchHelp, ItemFont);
	WeaponEmptyCheckbox     = AddCheckbox(WeaponEmptyText, WeaponEmptyHelp, ItemFont);
	WeaponBobCheckbox		= AddCheckbox(WeaponBobText, WeaponBobHelp, ItemFont);
	DualWieldSwapCheckbox	= AddCheckbox(DualWieldSwapText, DualWieldSwapHelp, ItemFont);
	ItemSwitchCheckbox    	= AddCheckbox(ItemSwitchText, ItemSwitchHelp, ItemFont);
	AutoAimSlider			= AddSlider(AutoAimText, AutoAimHelp, ItemFont, 0, 2);
	CrouchToggleCheckbox	= AddCheckbox(CrouchToggleText, CrouchToggleHelp, ItemFont);
	DamageFlashSlider		= AddSlider(DamageFlashText, DamageFlashHelp, ItemFont, 0, 255);
	TracersCheckbox			= AddCheckbox(TracersText, TracersHelp, ItemFont);
	DrawTimeCheckbox		= AddCheckbox(DrawTimeText, DrawTimeHelp, ItemFont);
	StrictTimeCheckbox		= AddCheckbox(StrictTimeText, StrictTimeHelp, ItemFont);
	AchCheckbox				= AddCheckbox(AchText, AchHelp, ItemFont);

	RestoreChoice    = AddChoice(RestoreText, RestoreHelp,	ItemFont, ItemAlign);
	BackChoice       = AddChoice(BackText,    "",			ItemFont, ItemAlign, true);

	LoadValues();
	}

///////////////////////////////////////////////////////////////////////////////
// Set all values to defaults
///////////////////////////////////////////////////////////////////////////////
function SetDefaultValues()
	{
	bAsk = false;

	AutoSaveCheckbox.SetValue(true);
	GoreCheckbox.SetValue(true);
	InvHintsCheckbox.SetValue(true);
	GameHintsCheckbox.SetValue(true);
	MpHintsCheckbox.SetValue(true);
	WeaponBobCheckbox.SetValue(true);
	TracersCheckbox.SetValue(true);
	WeaponSwitchCheckbox.SetValue(false);
	ItemSwitchCheckbox.SetValue(true);
	WeaponEmptyCheckbox.SetValue(true);
	DamageFlashSlider.SetValue(200);
	AutoAimSlider.SetValue(0);
	SelectorCheckbox.SetValue(true);
	SelectorSwitchCheckbox.SetValue(false);
	CrouchToggleCheckbox.SetValue(false);
	DualWieldSwapCheckbox.SetValue(false);

	bAsk = true;
	}

///////////////////////////////////////////////////////////////////////////////
// Load all values from ini files
///////////////////////////////////////////////////////////////////////////////
function LoadValues()
	{
	local float val;
	local bool flag;
	local String detail;
	local int i;

	//log(" LoadValues game info is "$class'P2GameInfo'$" default is "$class'P2GameInfo'.default.bInventoryHints);

	// Controls will generate Notify() events when their values are updated, so we
	// use this flag to block the events from actually doing anything.  In other
	// words, we're only setting the initial values of the controls and we don't
	// want that to count as a change.
	bUpdate = False;

	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strDrawPath));
	DrawTimeCheckbox.SetValue(flag);
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strStrictPath));
	StrictTimeCheckbox.SetValue(flag);
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strAchPath));
	AchCheckbox.SetValue(flag);

	// Value 0 or 1
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strAutoSavePath));
	AutoSaveCheckbox.SetValue(flag);

	// Value 0 or 1
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strGorePath));
	GoreCheckbox.SetValue(flag);

	// Value true or false
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strInvHintsPath));
	InvHintsCheckbox.SetValue(flag);

	// Value true or false
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strGameHintsPath));
	GameHintsCheckbox.SetValue(flag);

	// Value true or false
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strMpHintsPath));
	MpHintsCheckbox.SetValue(flag);

	// Value true or false
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strWeaponBobPath));
	WeaponBobCheckbox.SetValue(flag);

	// Value true or false
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strWeaponSwitch));
	WeaponSwitchCheckbox.SetValue(!flag);

	// Value true or false
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strItemSwitch));
	ItemSwitchCheckbox.SetValue(!flag);

	// 12/12/02 JMI Mapped to bAutoSwitchOnEmpty.
	// Value true or false
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strWeaponEmpty));
	WeaponEmptyCheckbox.SetValue(flag);

	// Value true or false
	val = float(GetPlayerOwner().ConsoleCommand("get"@c_strDamageFlashPath));
	DamageFlashSlider.SetValue(val);

	// Value true or false
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strTracersPath));
	TracersCheckbox.SetValue(flag);
	
	// Value 0 to 1
	val = float(GetPlayerOwner().ConsoleCommand("get"@c_strAutoAimPath));
	AutoAimSlider.SetValue((1.0 - val) * 100.0);

	// Value 0 or 1
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strSelectorPath));
	SelectorCheckbox.SetValue(flag);	
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strSelectorFullPath));
	SelectorFullCheckbox.SetValue(flag);	
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strSelectorSwitchPath));
	SelectorSwitchCheckbox.SetValue(flag);	
	
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strCrouchTogglePath));
	CrouchToggleCheckbox.SetValue(flag);
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strDualWieldSwapPath));
	DualWieldSwapCheckbox.SetValue(flag);
	
	bUpdate = True;
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
				case AutoSaveCheckbox:
					AutoSaveCheckboxChanged();
					break;
				case GoreCheckbox:
					GoreCheckboxChanged();
					break;
				case InvHintsCheckbox:
					InvHintsCheckboxChanged();
					break;
				case GameHintsCheckbox:
					GameHintsCheckboxChanged();
					break;
				case MpHintsCheckbox:
					MpHintsCheckboxChanged();
					break;
				case WeaponBobCheckbox:
					WeaponBobCheckboxChanged();
					break;
				case WeaponSwitchCheckbox:
					WeaponSwitchCheckboxChanged();
					break;
				case ItemSwitchCheckbox:
					ItemSwitchCheckboxChanged();
					break;
				case WeaponEmptyCheckbox:
					WeaponEmptyCheckboxChanged();
					break;
				case DamageFlashSlider:
					DamageFlashSliderChanged();
					break;
				case TracersCheckbox:
					TracersCheckboxChanged();
					break;
				case DrawTimeCheckbox:
					DrawTimeChanged();
					break;
				case StrictTimeCheckbox:
					StrictTimeChanged();
					break;
				case AchCheckbox:
					AchChanged();
					break;
				case AutoAimSlider:
					AutoAimSliderChanged();
					break;
				case SelectorCheckbox:
					SelectorCheckboxChanged();
					break;
				case SelectorFullCheckbox:
					SelectorFullCheckboxChanged();
					break;
				case SelectorSwitchCheckbox:
					SelectorSwitchCheckboxChanged();
					break;
				case CrouchToggleCheckbox:
					CrouchToggleCheckboxChanged();
					break;
				case DualWieldSwapCheckbox:
					DualWieldSwapCheckboxChanged();
					break;
				}
			break;
		case DE_Click:
			switch (C)
				{
				case RestoreChoice:
					SetDefaultValues();
					break;
				case BackChoice:
					GoBack();
					break;
				case ReticleChoice:
					GoToMenu(class'MenuReticle');
					break;
				}
			break;
		}
	}

function AutoAimSliderChanged()
{
	local float val;
	if (bUpdate)
	{
		val = (100.0 - AutoAimSlider.GetValue()) / 100.0;
		GetPlayerOwner().ConsoleCommand("set"@c_strAutoAimPath@val);
	}
}
	
function AutoSaveCheckboxChanged()
	{
	if (bUpdate)
		{
		GetPlayerOwner().ConsoleCommand("set"@c_strAutoSavePath@AutoSaveCheckbox.GetValue());
		}
	}

function GoreCheckboxChanged()
	{
	local int val;

	if (bUpdate)
		{
	//log(" writing gore/show blood val "$GoreCheckbox.bChecked);
	//	GetPlayerOwner().ConsoleCommand("set"@c_strGorePath@GoreCheckbox.bChecked);
		P2Player(GetPlayerOwner()).default.ShowBlood = GoreCheckbox.bChecked;
		P2Player(GetPlayerOwner()).ShowBlood = GoreCheckbox.bChecked;
		GetPlayerOwner().Static.StaticSaveConfig();
		}
	}

function InvHintsCheckboxChanged()
	{
	if (bUpdate)
		{
		GetPlayerOwner().ConsoleCommand("set"@c_strInvHintsPath@InvHintsCheckbox.bChecked);
		}
	}

function GameHintsCheckboxChanged()
	{
	if (bUpdate)
		{
		GetPlayerOwner().ConsoleCommand("set"@c_strGameHintsPath@GameHintsCheckbox.bChecked);
		}
	}

function MpHintsCheckboxChanged()
	{
	if (bUpdate)
		{
		//GetPlayerOwner().ConsoleCommand("set"@c_strMpHintsPath@MpHintsCheckbox.bChecked);
		P2Player(GetPlayerOwner()).default.bMpHints = MpHintsCheckbox.bChecked;
		P2Player(GetPlayerOwner()).bMpHints = MpHintsCheckbox.bChecked;
		GetPlayerOwner().Static.StaticSaveConfig();
		}
	}

function WeaponBobCheckboxChanged()
	{
	local int val;

	if (bUpdate)
		{
		//GetPlayerOwner().ConsoleCommand("set"@c_strWeaponBobPath@WeaponBobCheckbox.bChecked);
		P2Player(GetPlayerOwner()).default.bWeaponBob = WeaponBobCheckbox.bChecked;
		P2Player(GetPlayerOwner()).bWeaponBob = WeaponBobCheckbox.bChecked;
		GetPlayerOwner().Static.StaticSaveConfig();
		}
	}

function TracersCheckboxChanged()
	{
	local int val;

	if (bUpdate)
		{
		GetPlayerOwner().ConsoleCommand("set"@c_strTracersPath@TracersCheckbox.bChecked);
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

function ItemSwitchCheckboxChanged()
	{
	local int val;

	if (bUpdate)
		{
		//GetPlayerOwner().ConsoleCommand("set"@c_strItemSwitch@!(ItemSwitchCheckbox.bChecked));
		P2Player(GetPlayerOwner()).default.bNeverSwitchItemOnPickup = !ItemSwitchCheckbox.bChecked;
		P2Player(GetPlayerOwner()).bNeverSwitchItemOnPickup = !ItemSwitchCheckbox.bChecked;
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

function DamageFlashSliderChanged()
	{
	if (bUpdate)
		//GetPlayerOwner().ConsoleCommand("set"@c_strDamageFlashPath@DamageFlashSlider.GetValue());
		P2Player(GetPlayerOwner()).default.HurtBarAlpha = DamageFlashSlider.GetValue();
		P2Player(GetPlayerOwner()).HurtBarAlpha = DamageFlashSlider.GetValue();
		GetPlayerOwner().Static.StaticSaveConfig();
	}

function DrawTimeChanged()
	{
	if (bUpdate)
		{
		GetPlayerOwner().ConsoleCommand("set"@c_strDrawPath@DrawTimeCheckbox.bChecked);
		}
	}
function StrictTimeChanged()
	{
	if (bUpdate)
		{
		GetPlayerOwner().ConsoleCommand("set"@c_strStrictPath@StrictTimeCheckbox.bChecked);
		}
	}
function AchChanged()
	{
	if (bUpdate)
		{
		GetPlayerOwner().ConsoleCommand("set"@c_strAchPath@AchCheckbox.bChecked);
		}
	}

function SelectorCheckboxChanged()
{
	if (bUpdate)
		GetPlayerOwner().ConsoleCommand("set"@c_strSelectorPath@SelectorCheckbox.GetValue());
}
function SelectorFullCheckboxChanged()
{
	if (bUpdate)
		GetPlayerOwner().ConsoleCommand("set"@c_strSelectorFullPath@SelectorFullCheckbox.GetValue());
}
function SelectorSwitchCheckboxChanged()
{
	if (bUpdate)
		GetPlayerOwner().ConsoleCommand("set"@c_strSelectorSwitchPath@SelectorSwitchCheckbox.GetValue());
}
function CrouchToggleCheckboxChanged()
{
	if (bUpdate)
		GetPlayerOwner().ConsoleCommand("set"@c_strCrouchTogglePath@CrouchToggleCheckbox.GetValue());
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
	MenuWidth = 630
	fCommonCtlArea = 0.25
	ItemHeight = 28
	ItemSpacingY = 0

	GameSettingsTitleText = "Game"

	AutoSaveText = "Auto-Save"
	AutoSaveHelp = "Saves the game after each level transition"

	GoreText = "Blood and Gore"
	GoreHelp = "Turn off to remove most blood and gore from game"

	InvHintsText = "Inventory Hints"
	InvHintsHelp = "Shows hints for weapons and inventory items"

	GameHintsText = "Gameplay Hints"
	GameHintsHelp = "Shows hints during gameplay"

	MpHintsText = "Multiplayer Hints"
	MpHintsHelp = "Shows tips at start/finish of MP games"

	WeaponBobText = "Weapon Bob"
	WeaponBobHelp = "Makes the view bob up and down as you walk"

	WeaponSwitchText = "Auto-Switch Weapons on Pickup"
	WeaponSwitchHelp = "Switches to weapons when they are picked up"

	ItemSwitchText = "Auto-Switch Inventory on Pickup"
	ItemSwitchHelp = "Switches to inventory items when they are picked up"

	WeaponEmptyText = "Auto-Switch Weapons on Empty"
	WeaponEmptyHelp = "Switches to next-best weapon when ammo runs out"

	DamageFlashText = "Damage Flash Brightness"
	DamageFlashHelp = "Controls red flashes that show direction of attacks"

	TracersText = "Show Tracers"
	TracersHelp = "Shows paths for bullets when selected"

	DrawTimeText = "Show Game Timer"
	DrawTimeHelp = "Displays time elapsed in-game (for speedruns, etc.)"

	StrictTimeText = "Strict Game Timer"
	StrictTimeHelp = "If enabled, game timer always runs except between loading zones."

	AchText = "Display Achievements"
	AchHelp = "Displays achievements earned in-game."
	
	AutoAimText = "Aiming Assistance"
	AutoAimHelp = "How much aiming assistance should be applied. (0 = none, 1 = some, 2 = lots)"

	SelectorText = "Use Weapon Selector"
	SelectorHelp = "Use the pop-up weapon selector."
	SelectorFullText = "Weapon Selector Full Screen"
	SelectorFullHelp = "Allows the weapon selector to fill the entire screen instead of a smaller area."
	SelectorSwitchText = "Weapon Selector Auto-Switch"
	SelectorSwitchHelp = "Automatically switches between weapons while using the weapon selector."
	
	CrouchToggleText = "Crouch Toggle"
	CrouchToggleHelp = "If enabled, the crouch button acts as a toggle switch instead of hold-to-crouch."

	DualWieldSwapText = "Dual Wielding Swap"
	DualWieldSwapHelp = "Switches the Fire and Alt Fire buttons while dual-wielding or for specific weapons that request it."
	}
