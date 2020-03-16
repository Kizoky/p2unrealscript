//=============================================================================
// UWindowCheckbox - a checkbox
//=============================================================================
class UWindowCheckbox extends UWindowButton;

var bool		bChecked;
var	float	    CheckBoxAreaW;	// RWS CHANGE: 01/15/03 JMI Added CheckBoxAreaW.
								// Used by look and feel to position checkbox.
var Color TC;

// RWS CHANGE: 01/15/03 JMI Added Created to default CheckBoxAreaW.
function Created()
{
	Super.Created();
	// RWS CHANGE: CRK - Keep CheckBoxAreaW = 0 unless made from a ShellMenuCW window
	//CheckBoxAreaW = WinWidth / 2;

	TC.R = 0;
	TC.G = 0;
	TC.B = 0;
	TC.A = 255;
}

// RWS CHANGE: Added SetValue() that does notify to match how other controls work
function SetValue(bool bNewValue)
{
	if (bChecked != bNewValue)
	{
		bChecked = bNewValue;
		Notify(DE_Change);
	}
}

// RWS CHANGE: Added GetValue() to match other controls
function bool GetValue()
{
	return bChecked;
}

function BeforePaint(Canvas C, float X, float Y)
{
// RWS FIX: Change to call super *before* doing anything else
	Super.BeforePaint(C, X, Y);
	LookAndFeel.Checkbox_SetupSizes(Self, C);
}

function Paint(Canvas C, float X, float Y)
{
	LookAndFeel.Checkbox_Draw(Self, C);
	Super.Paint(C, X, Y);

	if(Font ~= F_SmallBold)
		TextColor = TC;
}


function LMouseUp(float X, float Y)
{
	if(!bDisabled)
	{	
		// RWS CHANGE - let LookAndFeel do feedback
		LookAndFeel.Control_Click(self);

		bChecked = !bChecked;
		Notify(DE_Change);
	}
	
	Super.LMouseUp(X, Y);
}

// RWS CHANGE - let LookAndFeel do feedback
function MouseEnter()
{
	Super.MouseEnter();
	if (!bDisabled)
		LookAndFeel.Control_MouseEnter(self);

	if(Font ~= F_SmallBold)
		TextColor = TC;
}

// RWS CHANGE - let LookAndFeel do feedback
function MouseLeave()
{
	Super.MouseLeave();
	if (!bDisabled)
		LookAndFeel.Control_MouseLeave(self);

	if(Font ~= F_SmallBold)
		TextColor = TC;
}
