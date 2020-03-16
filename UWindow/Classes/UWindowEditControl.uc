class UWindowEditControl extends UWindowDialogControl;

var	float			EditBoxWidth;
var float			EditAreaDrawX, EditAreaDrawY;
var UWindowEditBox	EditBox;

function Created()
{
	local Color C;

	Super.Created();
	
	EditBox = UWindowEditBox(CreateWindow(class'UWindowEditBox', 0, 0, WinWidth, WinHeight)); 
	EditBox.NotifyOwner = Self;
	EditBox.bSelectOnFocus = True;

	EditBoxWidth = WinWidth / 2;

	SetEditTextColor(LookAndFeel.EditBoxTextColor);
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

function SetHistory(bool bInHistory)
{
	EditBox.SetHistory(bInHistory);
}

function SetEditTextColor(Color NewColor)
{
	EditBox.SetTextColor(NewColor);
}

function Clear()
{
	EditBox.Clear();
}

function string GetValue()
{
	return EditBox.GetValue();
}

function SetValue(string NewValue)
{
	EditBox.SetValue(NewValue);	
}

function SetMaxLength(int MaxLength)
{
	EditBox.MaxLength = MaxLength;
}

function Paint(Canvas C, float X, float Y)
{
	LookAndFeel.Editbox_Draw(Self, C);
	Super.Paint(C, X, Y);
}


function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);
	LookAndFeel.Editbox_SetupSizes(Self, C);
}

function SetDelayedNotify(bool bDelayedNotify)
{
	Editbox.bDelayedNotify = bDelayedNotify;
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
