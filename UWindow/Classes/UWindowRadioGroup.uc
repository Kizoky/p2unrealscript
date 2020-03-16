// RWS CHANGE: This class handles a group of radio buttons.  It makes sure only one
// button is selected at any time and all Notify() events related to the radio buttons
// are routed through this class.  The group itself never visible -- just the buttons.
class UWindowRadioGroup extends UWindowDialogControl;

var array<UWindowRadioButton>		Buttons;
var UWindowRadioButton				SelectedButton;
var int								SelectedButtonIndex;

function UWindowRadioButton GetSelectedButton()
{
	return SelectedButton;
}

function int GetSelectedIndex()
{
	return SelectedButtonIndex;
}

function SetSelectedButton(UWindowRadioButton Button)
{
	ButtonSelected(Button);
}

function SetSelectedIndex(int index)
{
	ButtonSelected(Buttons[index]);
}

function ButtonSelected(UWindowRadioButton Button)
{
	local int i;

	for (i = 0; i < Buttons.length; i++)
	{
		if (Buttons[i] == Button)
		{
			Buttons[i].bSelected = true;
			SelectedButton = Button;
			SelectedButtonIndex = i;
		}
		else
			Buttons[i].bSelected = false;
	}

	Notify(DE_CHANGE);
}

function AddButton(UWindowRadioButton Button)
{
	local int i;

	// Only add the button if it isn't already in the list
	for (i = 0; i < Buttons.length; i++)
	{
		if (Buttons[i] == Button)
			break;
	}
	if (i == Buttons.length)
	{
		Buttons.insert(i, 1);
		Buttons[i] = Button;
	}

	// The most recently added button is always selected.  We have to do
	// something here to ensure only one button is selected and this seemed
	// like a reasonable way to handle it.
	ButtonSelected(Button);
}

// The group is never visible
function Paint(Canvas C, float X, float Y)
{
}
