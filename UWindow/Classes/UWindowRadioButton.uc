// RWS CHANGE: This class implements a radio button, one or more of which are assocated
// with a UWindowRadioButtonGroup.
class UWindowRadioButton extends UWindowButton;

var bool					bSelected;
var UWindowRadioGroup		Group;
var Color TC;

function Created()
{
	Super.Created();

	TC.R = 0;
	TC.G = 0;
	TC.B = 0;
	TC.A = 255;

	Align = TA_LeftOfText;
}

function SetGroup(UWindowRadioGroup NewGroup)
{
	Group = NewGroup;
	Group.AddButton(self);
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);
	LookAndFeel.RadioButton_SetupSizes(Self, C);
}

function Paint(Canvas C, float X, float Y)
{
	LookAndFeel.RadioButton_Draw(Self, C);
	Super.Paint(C, X, Y);

	if(Font ~= F_SmallBold)
		TextColor = TC;
}

function LMouseUp(float X, float Y)
{
	if(!bDisabled)
	{	
		LookAndFeel.Control_Click(self);
		Group.ButtonSelected(self);
	}
	Super.LMouseUp(X, Y);
}

function MouseEnter()
{
	Super.MouseEnter();
	if (!bDisabled)
		LookAndFeel.Control_MouseEnter(self);

	if(Font ~= F_SmallBold)
		TextColor = TC;
}

function MouseLeave()
{
	Super.MouseLeave();
	if (!bDisabled)
		LookAndFeel.Control_MouseLeave(self);

	if(Font ~= F_SmallBold)
		TextColor = TC;
}
