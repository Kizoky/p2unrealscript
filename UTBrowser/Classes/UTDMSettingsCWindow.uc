// DEATHMATCH GAME SETTINGS

class UTDMSettingsCWindow extends UTSettingsCWindow;

// Max Lives
var UWindowEditControl MaxLivesEdit;


function Created()
{
	Super.Created();
}

function SetupMapOptions()
{
	Super.SetupMapOptions();

	MaxLivesEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	MaxLivesEdit.SetText(MaxLivesText);
	MaxLivesEdit.SetHelpText(MaxLivesHelp);
	MaxLivesEdit.SetFont(F_SmallBold);
	MaxLivesEdit.SetNumericOnly(True);
	MaxLivesEdit.SetMaxLength(3);
	MaxLivesEdit.SetValue(string(class<Deathmatch>(BotmatchParent.GameClass).Default.MaxLives));
	ControlOffset += ControlHeight;
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	MaxLivesEdit.SetSize(ControlWidth-EditWidth+SmallEditBoxWidth, ControlHeight);
	MaxLivesEdit.WinLeft = ControlLeft;
	MaxLivesEdit.EditBoxWidth = SmallEditBoxWidth;
	MaxLivesEdit.SetTextColor(TC);
}


function Notify(UWindowDialogControl C, byte E)
{
	if (!Initialized)
		return;

	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch (C)
		{
			case MaxLivesEdit:
				MaxLivesChanged();
				break;
		}
		break;
	}
}

function MaxLivesChanged()
{
	if(Int(MaxLivesEdit.GetValue()) < 0)
		MaxLivesEdit.SetValue("0");

	class<Deathmatch>(BotmatchParent.GameClass).Default.MaxLives = int(MaxLivesEdit.GetValue());
}

defaultproperties
{
}
