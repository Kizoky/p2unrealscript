class UWindowComboControl extends UWindowDialogControl;

var	float				EditBoxWidth, EditBoxHeight;
var float				EditAreaDrawX, EditAreaDrawY;
var float				EditBoxHeightReduction;		// RWS CHANGE: Allow height of edit box to be independantly adjusted
var float				ButtonWidth;

var UWindowEditBox		EditBox;
var UWindowComboButton	Button;
var UWindowComboLeftButton LeftButton;
var UWindowComboRightButton RightButton;

var class<UWindowComboList>	ListClass;
var UWindowComboList	List;

var bool				bListVisible;
var bool				bCanEdit;
var bool				bButtons;

function Created()
{
	Super.Created();

	// These control the size of the full edit box area (the bevel and everything inside it).
	EditBoxHeight = WinHeight - EditBoxHeightReduction;
	EditBoxWidth = WinWidth / 2;

	// EditBox position and size are changed by LookAndFeel, so these values don't mean much
	EditBox = UWindowEditBox(CreateWindow(class'UWindowEditBox', 0, 0, EditBoxWidth, EditBoxHeight)); 
	EditBox.NotifyOwner = Self;
	EditBox.bTransient = True;

	// Button position and size are changed by LookAndFeel, so these values don't mean much
	Button = UWindowComboButton(CreateWindow(class'UWindowComboButton', 0, 0, ButtonWidth, EditBoxHeight)); 
	Button.Owner = Self;
	
	List = UWindowComboList(Root.CreateWindow(ListClass, 0, 0, 100, 100)); 
	List.LookAndFeel = LookAndFeel;
	List.Owner = Self;
	List.Setup();
	
	List.HideWindow();
	bListVisible = False;

	SetEditTextColor(LookAndFeel.EditBoxTextColor);
}

function SetButtons(bool bInButtons)
{
	bButtons = bInButtons;
	if(bInButtons)
	{
		LeftButton = UWindowComboLeftButton(CreateWindow(class'UWindowComboLeftButton', WinWidth-12, 0, 12, 10));
		RightButton = UWindowComboRightButton(CreateWindow(class'UWindowComboRightButton', WinWidth-12, 0, 12, 10));

		LeftButton.Owner = Self;
		RightButton.Owner = Self;
	}
	else
	{
		LeftButton = None;
		RightButton = None;
	}
}

function Notify(byte E)
{
	Super.Notify(E);

	if(E == DE_LMouseDown)
	{
		// RWS CHANGE - let LookAndFeel do feedback
		LookAndFeel.Control_Click(self);

		if(!bListVisible)
		{
			if(!bCanEdit)
			{
				DropDown();
				Root.CaptureMouse(List);
			}
		}
		else
			CloseUp();
	}
}

function int FindItemIndex(string V, optional bool bIgnoreCase)
{
	return List.FindItemIndex(V, bIgnoreCase);
}

function RemoveItem(int Index)
{
	List.RemoveItem(Index);
}

function int FindItemIndex2(string V2, optional bool bIgnoreCase)
{
	return List.FindItemIndex2(V2, bIgnoreCase);
}

function Close(optional bool bByParent)
{
	if(bByParent && bListVisible)
		CloseUp();

	Super.Close(bByParent);
}

function SetNumericOnly(bool bNumericOnly)
{
	EditBox.bNumericOnly = bNumericOnly;
}

function SetNumericFloat(bool bNumericFloat)
{
	EditBox.bNumericFloat = bNumericFloat;
}

function SetFont(int NewFont)
{
	Super.SetFont(NewFont);
	EditBox.SetFont(NewFont);
}

function SetEditTextColor(Color NewColor)
{
	EditBox.SetTextColor(NewColor);
}

function SetEditable(bool bNewCanEdit)
{
	bCanEdit = bNewCanEdit;
	EditBox.SetEditable(bCanEdit);
}

function int GetSelectedIndex()
{
	return List.FindItemIndex(GetValue());
}

function SetSelectedIndex(int Index)
{
	SetValue(List.GetItemValue(Index), List.GetItemValue2(Index));
}

// RWS CHANGE: Added useful query to find out what's at a particular index
function string GetValueAt(int Index)
{
	return List.GetItemValue(Index);
}

function string GetValue()
{
	return EditBox.GetValue();
}

function string GetValue2()
{
	return EditBox.GetValue2();
}

function SetValue(string NewValue, optional string NewValue2)
{
	EditBox.SetValue(NewValue, NewValue2);
// RWS CHANGE: 01/26/03 JMI Our EditBox will do this in the SetValue call above.
//	UWindowDialogClientWindow(OwnerWindow).Notify(self, DE_Change);
}

function SetMaxLength(int MaxLength)
{
	EditBox.MaxLength = MaxLength;
}

function Paint(Canvas C, float X, float Y)
{
	LookAndFeel.Combo_Draw(Self, C);
	Super.Paint(C, X, Y);
}

function AddItem(string S, optional string S2, optional int SortWeight)
{
	List.AddItem(S, S2, SortWeight);
}

function InsertItem(string S, optional string S2, optional int SortWeight)
{
	List.InsertItem(S, S2, SortWeight);
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);
	LookAndFeel.Combo_SetupSizes(Self, C);
	List.bLeaveOnscreen = bListVisible && bLeaveOnscreen;
}

function CloseUp()
{
	//log(self@"closing up list"@EditBox@List);
	bListVisible = False;
	EditBox.SetEditable(bCanEdit);
	EditBox.SelectAll();
	List.HideWindow();
}

function DropDown()
{
	bListVisible = True;
	EditBox.SetEditable(False);
	List.ShowWindow();
}

function Sort()
{
	List.Sort();
}

function ClearValue()
{
	EditBox.Clear();
}

function Clear()
{
	List.Clear();
	EditBox.Clear();
}

function FocusOtherWindow(UWindowWindow W)
{
	Super.FocusOtherWindow(W);

	if(bListVisible && W.ParentWindow != Self && W != List && W.ParentWindow != List)
		CloseUp();
}

// RWS CHANGE - let LookAndFeel do feedback
function MouseEnter()
{
	Super.MouseEnter();
	LookAndFeel.Control_MouseEnter(self);
}

// RWS CHANGE - let LookAndFeel do feedback
function MouseLeave()
{
	Super.MouseLeave();
	LookAndFeel.Control_MouseLeave(self);
}

defaultproperties
{
	ListClass=class'UWindowComboList'
	bNoKeyboard=True
	EditBoxHeightReduction = 6
	ButtonWidth = 16
}
