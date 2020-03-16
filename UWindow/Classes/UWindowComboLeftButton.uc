class UWindowComboLeftButton extends UWindowButton;

var UWindowComboControl Owner;

function BeforePaint(Canvas C, float X, float Y)
{
	LookAndFeel.Combo_SetupLeftButton(Self);
}

function LMouseDown(float X, float Y)
{
	local int i;

	Super.LMouseDown(X, Y);
	if(!bDisabled)
	{
		i = UWindowComboControl(OwnerWindow).GetSelectedIndex();
		i--;
		if(i < 0)
			i = UWindowComboControl(OwnerWindow).List.Items.Count() - 1;
		UWindowComboControl(OwnerWindow).SetSelectedIndex(i);

		if(Owner.bListVisible)
			Owner.CloseUp();
	}
}

defaultproperties
{
	bNoKeyboard=True
	bStretched=True
}