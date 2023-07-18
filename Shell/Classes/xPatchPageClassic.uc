class xPatchPageClassic extends xPatchPageBase;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
	
var string RGStr;
var /*config*/ byte LastRadio;

// game mode radio buttons/group
var UWindowRadioGroup GameRadioGroup;
var UWindowRadioButton ClassicGameRadio;
var localized string ClassicGameText;
var localized string ClassicGameHelp;
var UWindowRadioButton RegularGameRadio;
var localized string RegularGameText;
var localized string RegularGameHelp;

var localized string OldskoolCrapText;

// Disable Classic Game
var ShellMenuChoice			DisableChoice;
var localized string		DisableText;		
var localized string		DisableHelp;
var UWindowMessageBox		DisableConfirmationBox, DisableInfoBox;
var localized string		DisableConfirmText;

// Classic / Regular Game
var UWindowComboControl ClassicCombo;
var localized string 	ClassicModes[2];
var localized string	ClassicComboText;
var localized string	ClassicComboHelp;

// Allow AW Weapons
// NOTE: Option reverses bool value!
var UWindowCheckbox		NoAWWeaponsCheckbox;	
var localized string	NoAWWeaponsText;
var localized string	NoAWWeaponsHelp;
const NoAWWeaponsPath = "Postal2Game.xPatchManager bNoAWWeapons";	

// Allow exceptions
var UWindowCheckbox		AllowExceptionsCheckbox;
var localized string	AllowExceptionsText;
var localized string	AllowExceptionsHelp;
const AllowExceptionsPath = "Postal2Game.xPatchManager bAllowExceptions";

// Oldskool Hands
var UWindowCheckbox		ClassicHandsCheckbox;
var localized string	ClassicHandsText;
var localized string	ClassicHandsHelp;
const ClassicHandsPath = "Postal2Game.xPatchManager bClassicHands";

// Classic Zombies
var UWindowCheckbox		ClassicZombiesCheckbox;
var localized string	ClassicZombiesText;
var localized string	ClassicZombiesHelp;
const ClassicZombiesPath = "Postal2Game.xPatchManager bClassicZombies";

// Classic Melee
var UWindowCheckbox MeleeBloodCheckbox;
var localized string MeleeBloodText;
var localized string MeleeBloodHelp;
const MeleeBloodPath = "Postal2Game.xPatchManager bClassicMelee";

// Classic Mode Toggle
var UWindowCheckbox		ClassicModeCheckbox;
var localized string	ClassicModeText;
var localized string	ClassicModeHelp, ClassicModeOffHelp;

// Classic Anims
var UWindowCheckbox		ClassicAnimsCheckbox;
var localized string	ClassicAnimsText;
var localized string	ClassicAnimsHelp;
const ClassicAnimsPath = "Postal2Game.xPatchManager bClassicAnimations";

// Classic Load
var UWindowCheckbox		ClassicLoadCheckbox;
var localized string	ClassicLoadText;
var localized string	ClassicLoadHelp;
const ClassicLoadPath = "Postal2Game.xPatchManager bClassicLoadScreens";

// Classic Icons
var UWindowCheckbox		ClassicIconsCheckbox;
var localized string	ClassicIconsText;
var localized string	ClassicIconsHelp;
const ClassicIconsPath = "Postal2Game.xPatchManager bClassicHUDIcons";

// Classic Cars
var UWindowCheckbox		ClassicCarsCheckbox;
var localized string	ClassicCarsText;
var localized string	ClassicCarsHelp;
const ClassicCarsPath = "Postal2Game.xPatchManager bClassicCars";

// Classic Dude
var UWindowCheckbox		ClassicDudeCheckbox;
var localized string	ClassicDudeText;
var localized string	ClassicDudeHelp;
const ClassicDudePath = "Postal2Game.xPatchManager bClassicDude";

// Original weapons without Classic Mode
var UWindowCheckbox OGWeaponsCheckbox;
var localized string OGWeaponsText;
var localized string OGWeaponsHelp, OGWeaponsOffHelp;
const OGWeaponsPath = "Postal2Game.xPatchManager bAlwaysOGWeapons";

var float RadioWidth;
var float RadioLeft;
var float RadioHeight;
var float RadioOffset;

// Exceptions 
var xWeaponListBox OnMouseList;
var xWeaponExclude Exclude;
var xWeaponInclude Include;

struct NewWeaponsStr 
{
	var() string WeaponClass;					// Class name of the weapon
	var() string PickupClass;					// Class name of the pickup
	var() string AmmoClass;						// Class name of the ammo pickup
};
var() array<NewWeaponsStr> NewWeaponsList;

var localized string ExcludeCaption;
var localized string ExcludeHelp;
var localized string IncludeCaption;
var localized string IncludeHelp;

var UMenuMutatorFrameCW FrameExclude;
var UMenuMutatorFrameCW FrameInclude;

var float ListTitleY;
var float ListHeight;
var float ListWidth;

var string MoveLeftText;
var string MoveRightText;

// description
var UWindowDynamicTextArea DescWindow;
var const float DescAreaHeight;
var float DescAreaTop;

const BUTTON_WIDTH  = 30;
const BUTTON_HEIGHT = 20;
const BUTTON_SPACEY = 4;
const BUTTON_SPACEX = 10;

///////////////////////////////////////////////////////////////////////////////
// Create contents
///////////////////////////////////////////////////////////////////////////////
function Created()
{
	bInitialized = False;
	Super.Created();

	// Create radio button group and the buttons that are part of it
	GameRadioGroup = UWindowRadioGroup(CreateControl(class'UWindowRadioGroup', 0, 0, 0, 0));

	ClassicGameRadio = UWindowRadioButton(CreateControl(class'UWindowRadioButton', RadioLeft, ControlOffset, RadioWidth, RadioHeight));
	ClassicGameRadio.SetText(ClassicGameText);
	ClassicGameRadio.SetHelpText(ClassicGameHelp);
	ClassicGameRadio.SetFont(ControlFont);
	ClassicGameRadio.SetGroup(GameRadioGroup);
//	ControlOffset += RadioHeight;

	RegularGameRadio = UWindowRadioButton(CreateControl(class'UWindowRadioButton', RadioLeft, ControlOffset, RadioWidth, RadioHeight));
	RegularGameRadio.SetText(RegularGameText);
	RegularGameRadio.SetHelpText(RegularGameHelp);
	RegularGameRadio.SetFont(ControlFont);
	RegularGameRadio.SetGroup(GameRadioGroup);
//	ControlOffset += RadioHeight;
	
	if (LastRadio == 0)
	{
		GameRadioGroup.SetSelectedButton(ClassicGameRadio);
		RGStr = "RG";
	}
	else
	{
		GameRadioGroup.SetSelectedButton(RegularGameRadio);
		RGStr = "";
	}
	
	// Add Space
//	ControlOffset += (ControlHeight * 0.5);		
	
	// Create options
	ClassicLoadCheckbox			= AddCheckbox(ClassicLoadText, ClassicLoadHelp, ControlFont);
	ClassicAnimsCheckbox		= AddCheckbox(ClassicAnimsText, ClassicAnimsHelp, ControlFont);
	ClassicIconsCheckbox		= AddCheckbox(ClassicIconsText, ClassicIconsHelp, ControlFont);
	ClassicZombiesCheckbox 		= AddCheckbox(ClassicZombiesText, ClassicZombiesHelp, ControlFont);
	MeleeBloodCheckbox			= AddCheckbox(MeleeBloodText, MeleeBloodHelp, ControlFont);
	ClassicCarsCheckbox 		= AddCheckbox(ClassicCarsText, ClassicCarsHelp, ControlFont);
	ClassicDudeCheckbox			= AddCheckbox(ClassicDudeText, ClassicDudeHelp, ControlFont);
	ClassicHandsCheckbox 		= AddCheckbox(ClassicHandsText, ClassicHandsHelp, ControlFont);
	
	ControlOffset += (ControlHeight * 0.5);	
	
	//OGWeaponsCheckbox			= AddCheckbox(OGWeaponsText, OGWeaponsHelp, ControlFont);
	NoAWWeaponsCheckbox			= AddCheckbox(NoAWWeaponsText, NoAWWeaponsHelp, ControlFont);
	AllowExceptionsCheckbox		= AddCheckbox(AllowExceptionsText, AllowExceptionsHelp, ControlFont);
	
	// Debug
	//if(FPSPlayer(GetPlayerOwner()).bEnableDebugMenu)
	//ControlOffset += (ControlHeight * 0.5);	
	//ClassicModeCheckbox	= AddCheckbox(ClassicModeText, ClassicModeHelp, ControlFont);

	ControlOffset += (ControlHeight * 0.5);	

	ListTitleY = ControlOffset;
	ControlOffset += 18;

	FrameExclude = UMenuMutatorFrameCW(CreateWindow(class'UMenuMutatorFrameCW', 0, 0, 100, ListHeight));
	FrameInclude = UMenuMutatorFrameCW(CreateWindow(class'UMenuMutatorFrameCW', 0, 0, 100, ListHeight));

	Exclude = xWeaponExclude(CreateWindow(class'xWeaponExclude', 0, 0, 100, ListHeight, Self));
	FrameExclude.Frame.SetFrame(Exclude);
	Include = xWeaponInclude(CreateWindow(class'xWeaponInclude', 0, 0, 100, ListHeight, Self));
	FrameInclude.Frame.SetFrame(Include);

	Exclude.Register(Self);
	Include.Register(Self);

	Exclude.SetHelpText(ExcludeHelp);
	Include.SetHelpText(IncludeHelp);

	Include.DoubleClickList = Exclude;
	Exclude.DoubleClickList = Include;

	//DescWindow = UWindowDynamicTextArea(CreateWindow(class'UWindowDynamicTextArea', 0, 0, 100, 100));
	//DescWindow.bAutoScrollbar = true;
	//DescWindow.bScrollOnResize = false;
	//DescWindow.bTopCentric = true;

	LoadWeapons();
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);
	
	ControlLeft = (WinWidth - ControlWidth*2/3)/2;	// display in the center

	// NOTE: Hidden in offcial patch, use xPatchPageClassicRG tab instead
/*	RadioWidth = WinWidth * 0.8;	// give it almost the full width
	//RadioLeft = WinWidth * 0.1;		// slight offset from left edge
	RadioLeft = WinLeft+(WinWidth/2)-RadioOffset;	// Center */

	ClassicGameRadio.SetSize(RadioWidth, RadioHeight);
	ClassicGameRadio.WinLeft = RadioLeft;

	RegularGameRadio.SetSize(RadioWidth, RadioHeight);
	RegularGameRadio.WinLeft = RadioLeft;

	ClassicModeCheckbox.SetSize(CheckWidth, ControlHeight);
	ClassicModeCheckbox.WinLeft = ControlLeft;
	
	ClassicLoadCheckbox.SetSize(CheckWidth, ControlHeight);
	ClassicLoadCheckbox.WinLeft = ControlLeft;
	
	ClassicAnimsCheckbox.SetSize(CheckWidth, ControlHeight);
	ClassicAnimsCheckbox.WinLeft = ControlLeft;
	
	ClassicIconsCheckbox.SetSize(CheckWidth, ControlHeight);
	ClassicIconsCheckbox.WinLeft = ControlLeft;
	
	ClassicZombiesCheckbox.SetSize(CheckWidth, ControlHeight);
	ClassicZombiesCheckbox.WinLeft = ControlLeft;
	
	ClassicCarsCheckbox.SetSize(CheckWidth, ControlHeight);
	ClassicCarsCheckbox.WinLeft = ControlLeft;
	
	ClassicDudeCheckbox.SetSize(CheckWidth, ControlHeight);
	ClassicDudeCheckbox.WinLeft = ControlLeft;
	
	MeleeBloodCheckbox.SetSize(CheckWidth, ControlHeight);
	MeleeBloodCheckbox.WinLeft = ControlLeft;
	
	//OGWeaponsCheckbox.SetSize(CheckWidth, ControlHeight);
	//OGWeaponsCheckbox.WinLeft = ControlLeft;
	
	if(NoAWWeaponsCheckbox != None) {
	NoAWWeaponsCheckbox.SetSize(CheckWidth, ControlHeight);
	NoAWWeaponsCheckbox.WinLeft = ControlLeft;
	}
	
	if(AllowExceptionsCheckbox != None) {
	AllowExceptionsCheckbox.SetSize(CheckWidth, ControlHeight);
	AllowExceptionsCheckbox.WinLeft = ControlLeft;
	}
	
	if(ClassicHandsCheckbox != None) {
	ClassicHandsCheckbox.SetSize(CheckWidth, ControlHeight);
	ClassicHandsCheckbox.WinLeft = ControlLeft;
	}

	ControlLeft = (WinWidth - ControlWidth/2)/2;

	UpdateSizes();

	//DescWindow.SetSize(BodyWidth - 20, DescAreaHeight);
	//DescWindow.WinLeft = BodyLeft + 10;
	//DescWindow.WinTop = DescAreaTop;
}

function Paint(Canvas C, float X, float Y)
{
	local float W, H, TextY;

	Super.Paint(C, X, Y);

	C.Font = Root.Fonts[F_SmallBold];
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;

	// Draw labels over list boxes
	C.StrLen(ExcludeCaption, W, H);
	ClipText(C, (WinWidth/2 - W)/2, ListTitleY+2, ExcludeCaption, True);
	C.StrLen(IncludeCaption, W, H);
	ClipText(C, WinWidth/2 + (WinWidth/2 - W)/2, ListTitleY+2, IncludeCaption, True);

	// Draw arrows between lists
	TextY = FrameExclude.WinTop + (FrameExclude.WinHeight - (BUTTON_HEIGHT * 2 + BUTTON_SPACEY)) / 2;
	C.StrLen(MoveRightText, W, H);
	ClipText(C, (WinWidth - W)/2, TextY, MoveRightText, true);
	TextY += BUTTON_HEIGHT + BUTTON_SPACEY;
	C.StrLen(MoveLeftText, W, H);
	ClipText(C, (WinWidth - W)/2, TextY, MoveLeftText, true);
}

function Resized()
{
	Super.Resized();

	UpdateSizes();
}

function UpdateSizes()
{
	ListHeight = BodyHeight - (ControlOffset - BodyTop);
	ListWidth = BodyWidth/2 - (BUTTON_WIDTH + BUTTON_SPACEX)/2;
	FrameExclude.WinTop = ControlOffset;
	FrameExclude.WinLeft = BodyLeft;
	FrameExclude.SetSize(ListWidth, ListHeight);
	FrameInclude.WinTop = ControlOffset;
	FrameInclude.WinLeft = BodyLeft + BodyWidth - ListWidth;
	FrameInclude.SetSize(ListWidth, ListHeight);

	DescAreaTop = FrameExclude.WinTop + FrameExclude.WinHeight + 5;
}

function AfterCreate()
{
	Super.AfterCreate();
	
	LoadValues();
	
	if(!AllowExceptionsCheckbox.GetValue())
		HideExceptions();
		
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
				//case ClassicCombo:
				case GameRadioGroup:
					LoadValues();
					break;	
				case ClassicAnimsCheckbox:
					CheckboxChange(ClassicAnimsPath$RGStr, ClassicAnimsCheckbox.GetValue());
					break;
				case ClassicLoadCheckbox:
					CheckboxChange(ClassicLoadPath, ClassicLoadCheckbox.GetValue());
					break;
				case ClassicIconsCheckbox:
					ClassicIconsCheckboxChanged();
					break;
				case ClassicZombiesCheckbox:
					CheckboxChange(ClassicZombiesPath$RGStr, ClassicZombiesCheckbox.GetValue());
					break;
				case ClassicCarsCheckbox:
					CheckboxChange(ClassicCarsPath$RGStr, ClassicCarsCheckbox.GetValue());
					break;
				case ClassicDudeCheckbox:
					CheckboxChange(ClassicDudePath$RGStr, ClassicDudeCheckbox.GetValue());
					break;
				case MeleeBloodCheckbox:
					CheckboxChange(MeleeBloodPath$RGStr, MeleeBloodCheckbox.GetValue());
					break;
				//case OGWeaponsCheckbox:
				//	CheckboxChange(OGWeaponsPath, OGWeaponsCheckbox.GetValue());
				//	break;	
				case NoAWWeaponsCheckbox:
					CheckboxChange(NoAWWeaponsPath$RGStr, !NoAWWeaponsCheckbox.GetValue());
					break;
				case AllowExceptionsCheckbox:
					//CheckboxChange(AllowExceptionsPath$RGStr, AllowExceptionsCheckbox.GetValue());
					CheckboxChange(AllowExceptionsPath$RGStr, AllowExceptionsCheckbox.GetValue(), InfoTitle, OldskoolCrapText, 
					(ClassicHandsCheckbox.GetValue() && AllowExceptionsCheckbox.GetValue()) );
					if(AllowExceptionsCheckbox.GetValue())
					ShowExceptions();
					else
					HideExceptions();
					break;
				case ClassicHandsCheckbox:
					ClassicHandsCheckboxChanged();				
					break;
				case ClassicModeCheckbox:
					ToggleClassicMode();
					break;
				case Exclude:
					break;
				case Include:
					SaveConfigs();
					break;
				}
			break;
		case DE_Click:
			switch (C)
				{
				case DisableChoice:
					DisableClassicMode();
				case Exclude:
					SetWDescription(xWeaponList(UWindowListBox(C).SelectedItem));
					Include.ClearSelectedItem();
					break;
				case Include:
					SetWDescription(xWeaponList(UWindowListBox(C).SelectedItem));
					Exclude.ClearSelectedItem();
					break;
				}
			break;
		case DE_MouseEnter:
			OnMouseList = xWeaponListBox(C);
			break;
		case DE_MouseLeave:
			OnMouseList = None;
			break;
		}	
	}
	Super.Notify(C, E);
}

function LoadValues()
{
	local float fVal;
	local int iVal;
	local bool flag;
	
	if (GameRadioGroup.GetSelectedButton() == ClassicGameRadio)
	{
		LastRadio = 0;
		RGStr = "";
	}
	else
	{
		LastRadio = 1;
		RGStr = "RG";
	}
	
	// Classic Load
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@ClassicLoadPath));
	ClassicLoadCheckbox.SetValue(flag);	
	
	// Classic Weapons Only
	//flag = bool(GetPlayerOwner().ConsoleCommand("get"@OGWeaponsPath));
	//OGWeaponsCheckbox.SetValue(flag);

	// Oldskool Hands
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@ClassicHandsPath));
	ClassicHandsCheckbox.SetValue(flag);
	
	// Classic anims
	flag = bool(GetPlayerOwner().ConsoleCommand("get" @ ClassicAnimsPath$RGStr));
	ClassicAnimsCheckbox.SetValue(flag); 
	
	// Classic icons
	flag = bool(GetPlayerOwner().ConsoleCommand("get" @ ClassicIconsPath$RGStr));
	ClassicIconsCheckbox.SetValue(flag); 
	
	// Classic Zombies
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@ClassicZombiesPath$RGStr));
	ClassicZombiesCheckbox.SetValue(flag);	
	
	// Classic Cars
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@ClassicCarsPath$RGStr));
	ClassicCarsCheckbox.SetValue(flag);
	
	// Classic Dude
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@ClassicDudePath$RGStr));
	ClassicDudeCheckbox.SetValue(flag);

	// No Melee Blood
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@MeleeBloodPath$RGStr));
	MeleeBloodCheckbox.SetValue(flag);
	
	// AW Weapons
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@NoAWWeaponsPath$RGStr));
	NoAWWeaponsCheckbox.SetValue(!flag);
	
	// Exceptions
	flag = bool(GetPlayerOwner().ConsoleCommand("get"@AllowExceptionsPath$RGStr));
	AllowExceptionsCheckbox.SetValue(flag);
	
	// Toggle
	flag = GetGameSingle().InClassicMode();
	ClassicModeCheckbox.SetValue(flag);


	// Classic Game
	if (GameRadioGroup.GetSelectedButton() == ClassicGameRadio)
	{
		//OGWeaponsCheckbox.bDisabled = True;
		//OGWeaponsCheckbox.bChecked = True;
		ClassicLoadCheckbox.bDisabled = True;
		ClassicLoadCheckbox.bChecked = True;
		
		ClassicHandsCheckbox.ShowWindow();
		AllowExceptionsCheckbox.ShowWindow();
		NoAWWeaponsCheckbox.ShowWindow();
		
		if(AllowExceptionsCheckbox.GetValue())
			ShowExceptions();
	}
		
	// Regular Game
	if (GameRadioGroup.GetSelectedButton() == RegularGameRadio)
	{
		//OGWeaponsCheckbox.bDisabled = False;
		//OGWeaponsCheckbox.bChecked = bool(GetPlayerOwner().ConsoleCommand("get"@OGWeaponsPath));
		ClassicLoadCheckbox.bDisabled = False;
		ClassicLoadCheckbox.bChecked = bool(GetPlayerOwner().ConsoleCommand("get"@ClassicLoadPath));
		
		ClassicHandsCheckbox.HideWindow();
		AllowExceptionsCheckbox.HideWindow();
		NoAWWeaponsCheckbox.HideWindow();
		
		HideExceptions();
	}
}

function ShowExceptions()
{
	FrameExclude.ShowWindow();
	FrameInclude.ShowWindow();
	Exclude.ShowWindow();
	Include.ShowWindow();
	
	ExcludeCaption = default.ExcludeCaption;
	IncludeCaption = default.IncludeCaption;
	MoveLeftText = default.MoveLeftText;
	MoveRightText = default.MoveRightText;
}

function HideExceptions()
{		
	FrameExclude.HideWindow();
	FrameInclude.HideWindow();
	Exclude.HideWindow();
	Include.HideWindow();
	
	ExcludeCaption = "";
	IncludeCaption = "";
	MoveLeftText = "";
	MoveRightText = "";
}

///////////////////////////////////////////////////////////////////////////////
// Set all values to default
///////////////////////////////////////////////////////////////////////////////
function SetDefaultValues()
{
	// Classic Game
	if (GameRadioGroup.GetSelectedButton() == ClassicGameRadio)
	{
		ClassicAnimsCheckbox.SetValue(true);
		ClassicHandsCheckbox.SetValue(false);
		MeleeBloodCheckbox.SetValue(true);
		ClassicZombiesCheckbox.SetValue(true);
		ClassicIconsCheckbox.SetValue(true);
		NoAWWeaponsCheckbox.SetValue(false);
		AllowExceptionsCheckbox.SetValue(false);
		ClassicCarsCheckbox.SetValue(true);
		ClassicDudeCheckbox.SetValue(false);
	}
	else // Regular Game
	{
		ClassicAnimsCheckbox.SetValue(false);
		ClassicLoadCheckbox.SetValue(false);
		//OGWeaponsCheckbox.SetValue(false);
		MeleeBloodCheckbox.SetValue(false);
		ClassicZombiesCheckbox.SetValue(false);
		ClassicIconsCheckbox.SetValue(false);
		NoAWWeaponsCheckbox.SetValue(true);
		AllowExceptionsCheckbox.SetValue(false);
		ClassicCarsCheckbox.SetValue(false);
		ClassicDudeCheckbox.SetValue(false);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Apply changes
///////////////////////////////////////////////////////////////////////////////
function ClassicHandsCheckboxChanged()
{
	if(bInitialized)
	{	
		// Update settings
		CheckboxChange(ClassicHandsPath, ClassicHandsCheckbox.GetValue(), InfoTitle, OldskoolCrapText, (ClassicHandsCheckbox.GetValue() 
			&& (NoAWWeaponsCheckbox.GetValue() || AllowExceptionsCheckbox.GetValue() || GetGameSingle().IsWeekend())));
		
		// Apply changes to weapon
		if(GetPlayerOwner().Pawn.Weapon != None)
		{
			P2Weapon(GetPlayerOwner().Pawn.Weapon).SetRightHandedMesh();
			P2Weapon(GetPlayerOwner().Pawn.Weapon).PlayIdleAnim();
		}
	}	
}

function ClassicIconsCheckboxChanged()
{
	if(bInitialized)
	{	
		// Update settings
		CheckboxChange(ClassicIconsPath$RGStr, ClassicIconsCheckbox.GetValue());
				
		// Apply changes to inventory
		if(GetPlayerOwner().Pawn.Inventory != None)
		{
			P2PowerupInv(GetPlayerOwner().Pawn.Inventory).SwapIcons();
		}
	}	
}

function ToggleClassicMode()
{
	if(bInitialized)
	{	
		GetGameSingle().ToggleClassicMode();
		
		//if(IsGameMenu())
			ShowWarning(InfoTitle, MapChangeText);
	}	
}

function DisableClassicMode()
{
	if(bInitialized)
	{	
		DisableConfirmationBox = MessageBox(DisableText, DisableConfirmText, MB_YESNO, MR_NO, MR_YES);
	}	
}

///////////////////////////////////////////////////////////////////////////////
// Notification that the message box has finished.
///////////////////////////////////////////////////////////////////////////////
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	Super.MessageBoxDone(W, Result);
	
	// Silly, not checking to make sure that the dialog box they clicked on was the one we put up.
	if (W == DisableConfirmationBox)
	{
		switch (Result)
			{
			case MR_YES:
				// Disable classic game.
				GetGameSingle().ToggleClassicMode();
				DisableInfoBox = MessageBox(InfoTitle, MapChangeText, MB_OK, MR_OK, MR_OK);
				break;
			case MR_NO:
				// Whimped out..carry on.
				break;
			}
	}
	
	// If it's the game menu then resume the game
	if (W == DisableInfoBox)
	{
		//if (IsGameMenu())
		//	HideMenu();	
		Close();
	}
}


function LoadWeapons()
{
	local xWeaponList List;
	local class<P2Weapon> P2Weap;
	local string WClass, PClass, AClass;
	local string ExceptionClass;
	local int i;
	local int j;

	for( i = 0 ; i < NewWeaponsList.Length ; i++ )
	{
		WClass = NewWeaponsList[i].WeaponClass;
		PClass = NewWeaponsList[i].PickupClass;
		AClass = NewWeaponsList[i].AmmoClass;
		
		// Add "New Weapons" List
		if( WClass != "" )
		{
			P2Weap = class<P2Weapon>(DynamicLoadObject(WClass, class'class'));
			
			if (P2Weap != None)
			{
				List = xWeaponList(Exclude.Items.Append(class'xWeaponList'));

				List.WeaponName = P2Weap.default.ItemName;
				List.WeaponClass = WClass;
				List.PickupClass = PClass;
				List.AmmoClass = AClass;
			}
			else
				warn("Bad weapon pickup entry:"@WClass);
		}
	}
	
	
	for( j = 0 ; j < GetGameSingle().xManager.ClassicModeExceptionList.Length ; j++ )
	{
		ExceptionClass = GetGameSingle().xManager.ClassicModeExceptionList[j];
		
		// Add "Exceptions" List
		if( ExceptionClass != "" )
		{
			List = xWeaponList(Exclude.Items).FindWeapon(ExceptionClass);
			if(List != None)
			{
				List.Remove();
				Include.Items.AppendItem(List);
			}
			else
				Log("Unknown weapon in exceptions list: "$ExceptionClass);
		}
	}
	
	Exclude.Sort();

	// Start with the first item selected (this indirectly sets the current map, too)
	if (Include.Items.Next != None)
		Include.SetSelectedItem(xWeaponList(Include.Items.Next));
	else if (Exclude.Items.Next != None)
		Exclude.SetSelectedItem(xWeaponList(Exclude.Items.Next));
}

function SaveConfigs()
{
	local xWeaponList LI;
	local int i;
	local array<string> TempExceptionsList;

	Super(UMenuPageWindow).SaveConfigs();
	
	i = 0;
	for(LI = xWeaponList(Include.Items.Next); LI != None; LI = xWeaponList(LI.Next))
	{
		if(LI.WeaponClass != "")
		{
			TempExceptionsList[i] = LI.WeaponClass;	
			i++;
		}
	
		if(LI.PickupClass != "")
		{
			TempExceptionsList[i] = LI.PickupClass;	
			i++;
		}

		if(LI.AmmoClass != "")
		{
			TempExceptionsList[i] = LI.AmmoClass;	
			i++;
		}
	}
	
	GetGameSingle().xManager.ClassicModeExceptionList.Length = 0;
	GetGameSingle().xManager.ClassicModeExceptionList.Insert(0, TempExceptionsList.Length);
	
	i = 0;	
	for(i=0; i<TempExceptionsList.Length; i++)
	{
		GetGameSingle().xManager.ClassicModeExceptionList[i] = TempExceptionsList[i];
	}
	
	GetGameSingle().xManager.SaveConfig();
}

function SetWDescription(xWeaponList Item)
{
	//DescWindow.Clear();
	//DescWindow.AddText(Item.WeaponName$":");
	//DescWindow.AddTExt(Item.WeaponClass@Item.PickupClass@Item.AmmoClass);
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) 
{
	if (Msg==WM_KeyDown)
	{
		if (Key==236 && OnMouseList != None)
			OnMouseList.VertSB.Scroll(-1);
		else if (Key==237 && OnMouseList != None)
			OnMouseList.VertSB.Scroll(1);
			
		return;
	}

	Super.WindowEvent(MSg,C,X,Y,Key);
}

defaultproperties
{
	//PageHeaderText="Select the game mode you want to adjust the settings for."
	PageHeaderText="NOTE: Some settings will apply after level transition."
	ControlWidthPercent=0.75
	
	ClassicGameText="Classic Mode"
	RegularGameText="Regular Game"
	RadioHeight=18
	RadioOffset=75
	
	ClassicModes[0] = "Classic Mode"
	ClassicModes[1] = "Regular Game"
	ClassicComboText="Apply options below to..."
	ClassicComboHelp="Select the game mode you want to adjust the settings below for."
	
	ClassicModeText="Classic Mode"
	ClassicModeHelp="Toggle Classic Mode for current game."
	ClassicModeOffHelp="Can't be toggled in Main Menu."
	
	DisableText="Disable Classic Mode"
	DisableHelp="Disables Classic Mode for the current game."
	DisableConfirmText  = "Are you sure you want to disable Classic Mode? You won't be able to enable it again for this game."
	
	ClassicLoadText="Classic Loading Screens"
	ClassicLoadHelp="Toggles original day loading screens. This feature is always enabled in Classic Mode."

	ClassicAnimsText="Classic NPC Animations"
	ClassicAnimsHelp="Toggles old variations of a few character animations."
	
	ClassicZombiesText="Classic Zombies"
	ClassicZombiesHelp="Toggles old variations of Apocalypse Weekend zombies skins and their animations."
	
	ClassicHandsText="Oldskool Hands"
	ClassicHandsHelp="Toggles old pre-Share The Pain viewmodels. Works only with original POSTAL 2 weapons."
	OldskoolCrapText = "You have some of the new weapons allowed in the current game. Note that old models will only be applied to the original POSTAL 2 weapons."
	
	NoAWWeaponsText="Allow AW Weapons"
	NoAWWeaponsHelp="Allows Apocalypse Weekend weapons (Machete, Sledge, Scythe) to appear during Monday-Friday in Classic Mode. (AW weapons will still be always present during the weekend, regardless of this setting)."
	
	AllowExceptionsText="Allow Exceptions"
	AllowExceptionsHelp="Allows weapons from your exceptions list to not be removed in Classic Mode."
	
	//OGWeaponsText="Classic Arsenal"
	//OGWeaponsHelp="Removes or replaces ED/AWP/P2C weapons, allowing only the original weapons to be present in game. This feature is always enabled in Classic Mode."
	
	MeleeBloodText="Classic Melee"
	MeleeBloodHelp="Restores original damage and disables new bloodied skins for Shovel and Baton."
	
	ClassicIconsText = "Classic Icons"
	ClassicIconsHelp = "Changes some icons to their upscaled original-style versions."
	
	ClassicCarsText = "Classic Police Cars"
	ClassicCarsHelp = "Restores original Police Car models."
	
	ClassicDudeText = "Classic POSTAL Dude"
	ClassicDudeHelp = "Restores the pre-Apocalypse Weekend POSTAL Dude head model."
	
	MoveLeftText="<--"
	MoveRightText="-->"
	
	ExcludeCaption="Excluded Weapons"
	ExcludeHelp="These weapons will not be used.  Click and drag weapons to the right list if you want to use them."
	IncludeCaption="Included Weapons"
	IncludeHelp="These weapons will be used.  Click and drag weapons to the left list to remove them."
	
	NewWeaponsList[0]=(WeaponClass="EDStuff.MP5Weapon",PickupClass="EDStuff.MP5Pickup",AmmoClass="EDStuff.MP5AmmoPickup")
	NewWeaponsList[1]=(WeaponClass="EDStuff.GSelectWeapon",PickupClass="EDStuff.GSelectPickup",AmmoClass="EDStuff.GSelectAmmoPickup")
	NewWeaponsList[2]=(WeaponClass="EDStuff.GrenadeLauncherWeapon",PickupClass="EDStuff.GrenadeLauncherPickup")
	NewWeaponsList[3]=(WeaponClass="EDStuff.ShearsWeapon",PickupClass="EDStuff.ShearsPickup")
	NewWeaponsList[4]=(WeaponClass="EDStuff.AxeWeapon",PickupClass="EDStuff.AxePickup")
	NewWeaponsList[5]=(WeaponClass="EDStuff.BaliWeapon",PickupClass="EDStuff.BaliPickup")
	NewWeaponsList[6]=(WeaponClass="EDStuff.DynamiteWeapon",PickupClass="EDStuff.DynamitePickup")
	
	NewWeaponsList[7]=(WeaponClass="AWPStuff.NukeWeapon",PickupClass="AWPStuff.NukePickup",AmmoClass="AWPStuff.NukeAmmoPickup")
	NewWeaponsList[8]=(WeaponClass="AWPStuff.SawnOffWeapon",PickupClass="AWPStuff.SawnOffPickup")
	NewWeaponsList[9]=(WeaponClass="AWPStuff.BaseballBatWeapon",PickupClass="AWPStuff.BaseballBatPickup")
	NewWeaponsList[10]=(WeaponClass="AWPStuff.ChainsawWeapon",PickupClass="AWPStuff.ChainSawPickup")
	NewWeaponsList[11]=(WeaponClass="AWPStuff.DustersWeapon",PickupClass="AWPStuff.DustersPickup")
	NewWeaponsList[12]=(WeaponClass="AWPStuff.FlameWeapon",PickupClass="AWPStuff.FlamePickup")
	
	NewWeaponsList[13]=(WeaponClass="Inventory.MrDKNadeWeapon",PickupClass="Inventory.MrDKNadePickup")
	NewWeaponsList[14]=(WeaponClass="P2R.ProtestSignWeapon",PickupClass="P2R.ProtestSignPickup")
}