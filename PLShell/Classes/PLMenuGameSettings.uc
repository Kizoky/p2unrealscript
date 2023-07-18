///////////////////////////////////////////////////////////////////////////////
// PLMenuGameSettings
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Weapon selector got moved to P2, so this really doesn't do much now...
///////////////////////////////////////////////////////////////////////////////
class PLMenuGameSettings extends MenuGameSettings;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
/*
///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	Super(ShellMenuCW).CreateMenuContents();
	AddTitle(GameSettingsTitleText, TitleFont, TitleAlign);
	
	ReticleChoice			= AddChoice(ReticleText, ReticleHelp, ItemFont, ItemAlign);
	AutoSaveCheckbox		= AddCheckbox(AutoSaveText, AutoSaveHelp, ItemFont);
	GoreCheckbox			= AddCheckbox(GoreText, GoreHelp, ItemFont);
	InvHintsCheckbox		= AddCheckbox(InvHintsText, InvHintsHelp, ItemFont);
	GameHintsCheckbox		= AddCheckbox(GameHintsText, GameHintsHelp, ItemFont);
	//MpHintsCheckbox 		= AddCheckbox(MpHintsText, MpHintsHelp, ItemFont);
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
	Super.SetDefaultValues();
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
	
	Super.LoadValues();
	
}

///////////////////////////////////////////////////////////////////////////////
// Callback for when control has changed
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
}
*/

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
}
