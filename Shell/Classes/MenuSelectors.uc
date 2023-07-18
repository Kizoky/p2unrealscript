///////////////////////////////////////////////////////////////////////////////
// MenuSelectors.uc
//
// Settings menu for weapon and item selector
// by Man Chrzan 
///////////////////////////////////////////////////////////////////////////////
class MenuSelectors extends ShellMenuCW;

var localized string TitleText;
var bool bUpdate;	// Notifications of changes will be ignored when this is false.
var bool bAsk;

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

const c_strInvSelectorPath = "Postal2Game.P2GameInfo bUseInventorySelector";
var UWindowCheckbox InvSelectorCheckbox;
var localized string InvSelectorText;
var localized string InvSelectorHelp;

// xPatch: Selector Style Settings
var UWindowComboControl WSelectorCombo;
var localized string	WSelectorText, WSelectorHelp;

var UWindowComboControl ISelectorCombo;
var localized string	ISelectorText, ISelectorHelp;

var string CurrentSelector, CurrentInvSelector, CustomSelector, CustomInvSelector;

const CusSelectorPath 	 = "GameTypes.DudePlayer CustomWeaponSelectorClassName";
const SelectorPath 		 = "GameTypes.DudePlayer WeaponSelectorClassName";

const CusInvSelectorPath 	 = "GameTypes.DudePlayer CustomInventorySelectorClassName";
const InvSelectorPath 		 = "GameTypes.DudePlayer InventorySelectorClassName";

// Selector Style Presets
var localized array<string> SelectorModes[3], InvSelectorModes[3];
//var localized array<string> SelectorModes, InvSelectorModes;
var localized string SelectorCustom;

var globalconfig int WeaponSelectorPreset;
var array<string> SetGroupCellTexName;
var array<color> SetSelectedGroupElementColor, 
					SetSelectedWeaponElementColor,
					SetAmmoBarBGColor, 
					SetAmmoBarColor,
					SetNoAmmoWeaponColor,
					SetGroupCellColor;	
					
var globalconfig int InventorySelectorPreset;
var array<string> SetLeftArrow, SetRightArrow;				
var array<color> SetSelectedColor, 
					SetBackgroundColor,
					SetBorderColor, 
					SetUnlockedArrowColor,
					SetLockedArrowColor;
var array<bool> SetFancyFont;
				
var array<texture> LoadTextures;

//////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super(ShellMenuCW).CreateMenuContents();
	
	AddTitle(TitleText, TitleFont, TitleAlign);
	
	SelectorCheckbox		= AddCheckbox(SelectorText, SelectorHelp, ItemFont);
	WSelectorCombo 			= AddComboBox(WSelectorText, WSelectorHelp, ItemFont);
	SelectorFullCheckbox	= AddCheckbox(SelectorFullText, SelectorFullHelp, ItemFont);
	SelectorSwitchCheckbox	= AddCheckbox(SelectorSwitchText, SelectorSwitchHelp, ItemFont);
	
	InvSelectorCheckbox		= AddCheckbox(InvSelectorText, InvSelectorHelp, ItemFont);
	ISelectorCombo 			= AddComboBox(ISelectorText, ISelectorHelp, ItemFont);

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
				case SelectorCheckbox:
					SelectorCheckboxChanged();
					break;
				case InvSelectorCheckbox:
					InvSelectorCheckboxChanged();
					break;
				case SelectorFullCheckbox:
					SelectorFullCheckboxChanged();
					break;
				case SelectorSwitchCheckbox:
					SelectorSwitchCheckboxChanged();
					break;
				case WSelectorCombo:
					WSelectorComboChanged();
					break;
				case ISelectorCombo:
					ISelectorComboChanged();
					break;
			break;
		}
		
		case DE_Click:
			switch (C)
				{
				case RestoreChoice:
					SetDefaultValues();
					break;
				case BackChoice:
					GoBack();
					break;
				}
			break;
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

	CurrentSelector = GetPlayerOwner().ConsoleCommand("get" @ SelectorPath); 
	CustomSelector = GetPlayerOwner().ConsoleCommand("get" @ CusSelectorPath); 
	
	CurrentInvSelector = GetPlayerOwner().ConsoleCommand("get" @ InvSelectorPath); 
	CustomInvSelector = GetPlayerOwner().ConsoleCommand("get" @ CusInvSelectorPath); 
	
	///////////////////////////////////////////////////////////////////////////////
	
	bUpdate = false;
	
	///////////////////////////////////////////////////////////////////////////////
	
	// Value 0 or 1
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strSelectorPath));
	SelectorCheckbox.SetValue(flag);	
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strSelectorFullPath));
	SelectorFullCheckbox.SetValue(flag);	
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strSelectorSwitchPath));
	SelectorSwitchCheckbox.SetValue(flag);	
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@c_strInvSelectorPath));
	InvSelectorCheckbox.SetValue(flag);	
	
	// Weapon Selector
	WSelectorCombo.Clear();
	for (iVal = 0; iVal < ArrayCount(SelectorModes); iVal++)
	//for (iVal = 0; iVal < SelectorModes.Length; iVal++)
		WSelectorCombo.AddItem(SelectorModes[iVal]);
		
	if(CustomSelector != "")
		WSelectorCombo.SetValue(SelectorCustom);
	else
	{
/*		if(SelectorModes[WeaponSelectorPreset] == "")
		{
			default.SelectorModes[WeaponSelectorPreset] = "My Preset"@WeaponSelectorPreset;
			SelectorModes[WeaponSelectorPreset] = "My Preset"@WeaponSelectorPreset;
			GetPlayerOwner().Static.StaticSaveConfig();
		}
*/	
		WSelectorCombo.SetValue(SelectorModes[WeaponSelectorPreset]);
	}	
	// Inventory Selector
	ISelectorCombo.Clear();
	for (iVal = 0; iVal < ArrayCount(InvSelectorModes); iVal++)
	//for (iVal = 0; iVal < InvSelectorModes.Length; iVal++)
		ISelectorCombo.AddItem(InvSelectorModes[iVal]);
		
	if(CustomInvSelector != "")
		ISelectorCombo.SetValue(SelectorCustom);
	else
	{
/*		if(InvSelectorModes[InventorySelectorPreset] == "")
		{
			default.InvSelectorModes[InventorySelectorPreset] = "My Preset"@InventorySelectorPreset;
			InvSelectorModes[InventorySelectorPreset] = "My Preset"@InventorySelectorPreset;
			GetPlayerOwner().Static.StaticSaveConfig();
		}
*/		
		ISelectorCombo.SetValue(InvSelectorModes[InventorySelectorPreset]);
	}

	///////////////////////////////////////////////////////////////////////////////

	bUpdate = true;
	
}

///////////////////////////////////////////////////////////////////////////////
// Set all values to defaults
///////////////////////////////////////////////////////////////////////////////
function SetDefaultValues()
	{
	bAsk = false;

	SelectorCheckbox.SetValue(true);
	SelectorSwitchCheckbox.SetValue(false);
	SelectorFullCheckbox.SetValue(false);
	InvSelectorCheckbox.SetValue(true);
	
	WSelectorCombo.SetValue(SelectorModes[0]);
	ISelectorCombo.SetValue(InvSelectorModes[0]);

	bAsk = true;
	}


function SelectorCheckboxChanged()
{
	if (bUpdate)
	{		
		if(SelectorCheckbox.GetValue())
		{
			DudePlayer(GetPlayerOwner()).AddWeaponSelector();
			DudePlayer(GetPlayerOwner()).SetupWeaponSelector(False);
			DudePlayer(GetPlayerOwner()).WeaponSelector.RefreshSelector();
		}
		else
			DudePlayer(GetPlayerOwner()).RemoveWeaponSelector();
		
		GetPlayerOwner().ConsoleCommand("set"@c_strSelectorPath@SelectorCheckbox.GetValue());
	}
}
function InvSelectorCheckboxChanged()
{
	if (bUpdate)
	{
		if(InvSelectorCheckbox.GetValue())
			DudePlayer(GetPlayerOwner()).AddInventorySelector();
		else
			DudePlayer(GetPlayerOwner()).RemoveInventorySelector();
			
		GetPlayerOwner().ConsoleCommand("set"@c_strInvSelectorPath@InvSelectorCheckbox.GetValue());
	}
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

function WSelectorComboChanged()
{
	local String NewSelector;
	local Int Preset;
	local DudePlayer DPlayer;
	
	DPlayer = DudePlayer(GetPlayerOwner());
	
	if(DPlayer == None)
		return;

	if (bUpdate)
	{
		NewSelector = WSelectorCombo.GetValue();
		Preset = GetSelectorModeNumber(NewSelector);
			
		// Don't do anything with selectors definied by workshop game / mutator 
		if( CurrentSelector != Class'DudePlayer'.default.WeaponSelectorClassName
			&& CurrentSelector != CustomSelector)
			return;
		
		// Remove Custom Selector and restore default one		
		if(CurrentSelector == CustomSelector)
		{
			DPlayer.RemoveWeaponSelector();
			GetPlayerOwner().ConsoleCommand("Set" @ CusSelectorPath @ "" );
			DPlayer.WeaponSelectorClassName = DPlayer.default.WeaponSelectorClassName;
			DPlayer.AddWeaponSelector();
		}
	
		// Restore default selector
		if (Preset == 0)	
			DPlayer.SetupWeaponSelector(True);
		else // Setup custom preset
		{
			GetPlayerOwner().ConsoleCommand("Set" @ CurrentSelector @ "MyGroupCellTex" 					@ SetGroupCellTexName[Preset] );
			GetPlayerOwner().ConsoleCommand("Set" @ CurrentSelector @ "MyGroupCellColor" 				@ GetColorAsString(SetGroupCellColor[Preset]) );	
			GetPlayerOwner().ConsoleCommand("Set" @ CurrentSelector @ "MySelectedGroupElementColor" 	@ GetColorAsString(SetSelectedGroupElementColor[Preset]) );	
			GetPlayerOwner().ConsoleCommand("Set" @ CurrentSelector @ "MySelectedWeaponElementColor"	@ GetColorAsString(SetSelectedWeaponElementColor[Preset]) );
			GetPlayerOwner().ConsoleCommand("Set" @ CurrentSelector @ "MyAmmoBarBGColor" 				@ GetColorAsString(SetAmmoBarBGColor[Preset]) );	 
			GetPlayerOwner().ConsoleCommand("Set" @ CurrentSelector @ "MyAmmoBarColor"			 		@ GetColorAsString(SetAmmoBarColor[Preset]) );
			
			// Update selector with the new changes.
			DPlayer.SetupWeaponSelector(False);
		}
		
		// Update current preset info 
		WeaponSelectorPreset = Preset;
		GetPlayerOwner().ConsoleCommand("Set MenuSelectors WeaponSelectorPreset" @ Preset);
		
		log(self$" Changed Weapon Selector to preset: "$Preset);
	}
}

function ISelectorComboChanged()
{
	local String NewSelector;
	local DudePlayer DPlayer;
	local int Preset;
	
	DPlayer = DudePlayer(GetPlayerOwner());
	
	if(DPlayer == None)
		return;

	if (bUpdate)
	{
		NewSelector = ISelectorCombo.GetValue();
		Preset = GetInvSelectorModeNumber(NewSelector);
			
		// Don't do anything with selectors definied by workshop game / mutator 
		if( CurrentInvSelector != Class'DudePlayer'.default.InventorySelectorClassName
			&& CurrentInvSelector != CustomInvSelector)
			return;
		
		// Remove Custom Selector and restore default one		
		if(CurrentInvSelector == CustomInvSelector)
		{
			DPlayer.RemoveInventorySelector();
			GetPlayerOwner().ConsoleCommand("Set" @ CusInvSelectorPath @ "" );
			DPlayer.InventorySelectorClassName = DPlayer.default.InventorySelectorClassName;
			DPlayer.AddInventorySelector();
		}
			
		if (Preset == 0)	
		{			
			// Restore default selector
			DPlayer.SetupInventorySelector(True);
		}
		else
		{
			GetPlayerOwner().ConsoleCommand("Set" @ CurrentInvSelector @ "MyLeftArrow" 					@ SetLeftArrow[Preset] );
			GetPlayerOwner().ConsoleCommand("Set" @ CurrentInvSelector @ "MyRightArrow" 				@ SetRightArrow[Preset] );
			GetPlayerOwner().ConsoleCommand("Set" @ CurrentInvSelector @ "MySelectedColor" 				@ GetColorAsString(SetSelectedColor[Preset]) );
			GetPlayerOwner().ConsoleCommand("Set" @ CurrentInvSelector @ "MyBackgroundColor" 			@ GetColorAsString(SetBackgroundColor[Preset]) );
			GetPlayerOwner().ConsoleCommand("Set" @ CurrentInvSelector @ "MyBorderColor"				@ GetColorAsString(SetBorderColor[Preset]) );
			GetPlayerOwner().ConsoleCommand("Set" @ CurrentInvSelector @ "MyUnlockedArrowColor" 		@ GetColorAsString(SetUnlockedArrowColor[Preset]) );
			GetPlayerOwner().ConsoleCommand("Set" @ CurrentInvSelector @ "MyLockedArrowColor"			@ GetColorAsString(SetLockedArrowColor[Preset]) );
			GetPlayerOwner().ConsoleCommand("Set" @ CurrentInvSelector @ "FancyFont"			 		@ SetFancyFont[Preset] );
			
			// Update selector with the new changes.
			DPlayer.SetupInventorySelector(False);
		}
		
		InventorySelectorPreset = Preset;
		GetPlayerOwner().ConsoleCommand("Set MenuSelectors InventorySelectorPreset" @ Preset);
		
		log(self$" Changed Inventory Menu to preset: "$Preset);
	}
}

function int GetSelectorModeNumber(string ModeStr)
{
	local int i;
	
	if(ModeStr != "")
	{	
		for (i=0; i<ArrayCount(SelectorModes); i++)
		//for (i=0; i<SelectorModes.Length; i++)
		{
			if (ModeStr == SelectorModes[i])	
				return i;
		}
	}
	return 0;
}

function int GetInvSelectorModeNumber(string ModeStr)
{
	local int i;
	
	if(ModeStr != "")
	{	
		for (i=0; i<ArrayCount(InvSelectorModes); i++)
		//for (i=0; i<InvSelectorModes.Length; i++)
		{
			if (ModeStr == InvSelectorModes[i])	
				return i;
		}
	}
	return 0;
}

function string GetColorAsString(color TheColor)
{
	local string TheColorStr;
	local int R, G, B, A;
	local color TempColor;
	
	TempColor = TheColor;
	R = TempColor.R;
	G = TempColor.G;
	B = TempColor.B;
	A = TempColor.A;
	
	TheColorStr = "(R="$R$",G="$G$",B="$B$",A="$A$")";
	//TheColorStr = GetPlayerOwner().ConsoleCommand("Get MenuSelectors TempColor"); 
	
	log(self$" GetColorAsString = "$TheColorStr);
	return TheColorStr;
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
	TitleText="Item Selection Settings" 
	MenuWidth=700
	
	SelectorText = "Use Weapon Selector"
	SelectorHelp = "Use the pop-up Weapon Selector."
	SelectorFullText = "Weapon Selector Full Screen"
	SelectorFullHelp = "Allows the weapon selector to fill the entire screen instead of a smaller area."
	SelectorSwitchText = "Weapon Selector Auto-Switch"
	SelectorSwitchHelp = "Automatically switches between weapons while using the weapon selector."
	WSelectorText = "Weapon Selector Type"
    WSelectorHelp="Choose the Weapon Selector design."
	
	InvSelectorText = "Use Inventory Menu"
	InvSelectorHelp = "Enables the Inventory Menu."
	ISelectorText = "Inventory Menu Type"
	ISelectorHelp="Choose the Inventory Menu design."
	
	SelectorCustom="Custom Class"
	
	// Weapon Selector Presets
	SelectorModes[0]="Bloody Red"
	SelectorModes[1]="Relic of the past"
	SelectorModes[2]="Black & White"
	
//	SetGroupCellTexName[0]				=	"xPatchTex.HUD.selector_red"
//	SetSelectedGroupElementColor[0]		=	(R=0,G=0,B=0,A=140)
//	SetSelectedWeaponElementColor[0]	=	(R=0,G=0,B=0,A=105)
//	SetAmmoBarBGColor[0]				=	(R=33,G=33,B=33,A=225)
//	SetAmmoBarColor[0]					=	(G=130,R=0,A=225)
	
	SetGroupCellTexName[1]				=	"MpHUD.HUD.field_gray"
	SetGroupCellColor[1]				=	(R=255,G=255,B=255,A=255)
	SetSelectedGroupElementColor[1]		=	(R=255,G=255,B=0,A=63)
	SetSelectedWeaponElementColor[1]	=	(R=255,G=255,B=0,A=63)
	SetAmmoBarBGColor[1]				=	(R=63,G=63,B=63,A=255)
	SetAmmoBarColor[1]					=	(R=160,G=0,B=0,A=255)
	
	SetGroupCellTexName[2]				=	"xPatchTex.HUD.xSelector"
	SetGroupCellColor[2]				=	(R=1,G=1,B=1,A=255)
	SetSelectedGroupElementColor[2]		=	(R=0,G=0,B=0,A=100)
	SetSelectedWeaponElementColor[2]	=	(R=0,G=0,B=0,A=140)
	SetAmmoBarBGColor[2]				=	(R=33,G=33,B=33,A=255)
	SetAmmoBarColor[2]					=	(R=200,G=200,B=200,A=255)
	
	// Inventory Selector Presets
	InvSelectorModes[0]="Bloody Red"
	InvSelectorModes[1]="Relic of the past"
	InvSelectorModes[2]="Black & White"
	
	SetLeftArrow[1]="P2Misc.Icons.InvArrowLeft"
	SetRightArrow[1]="P2Misc.Icons.InvArrowRight"
	SetSelectedColor[1]=(R=64,G=64,B=64,A=255)
	SetBackgroundColor[1]=(R=255,G=255,B=255,A=175)
	SetBorderColor[1]=(R=255,G=255,B=255,A=255)
	SetUnlockedArrowColor[1]=(R=255,G=255,B=255,A=255)
	SetLockedArrowColor[1]=(R=64,G=64,B=64,A=255)
	SetFancyFont[1]=False
	
	SetLeftArrow[2]="xPatchTex.HUD.xArrowLeft"
	SetRightArrow[2]="xPatchTex.HUD.xArrowRight"
	SetSelectedColor[2]=(R=255,G=255,B=255,A=20)
	SetBackgroundColor[2]=(R=255,G=255,B=255,A=175)
	SetBorderColor[2]=(R=1,G=1,B=1,A=255)
	SetUnlockedArrowColor[2]=(R=200,G=200,B=200,A=255)
	SetLockedArrowColor[2]=(R=64,G=64,B=64,A=175)
	SetFancyFont[2]=True
	
	// Need to list all used textures here, otherwise it will not work!
	LoadTextures[0]=Texture'xPatchTex.HUD.selector_red"'
	LoadTextures[1]=Texture'MpHUD.HUD.field_gray'
	LoadTextures[2]=Texture'xPatchTex.HUD.xSelector'
	LoadTextures[3]=Texture'xPatchTex.HUD.xArrowLeft'
	LoadTextures[4]=Texture'xPatchTex.HUD.xArrowRight'
	LoadTextures[5]=Texture'P2Misc.Icons.InvArrowLeft'
	LoadTextures[6]=Texture'P2Misc.Icons.InvArrowRight'
}
