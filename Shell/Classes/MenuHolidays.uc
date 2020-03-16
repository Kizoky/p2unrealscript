///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
class MenuHolidays extends ShellMenuCW;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
var localized string TitleText;
var localized string Msg[7];

var array<UWindowCheckbox> HolidayCheckbox;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
{
	local int i;
	local array<string> Msg2;
	local P2GameInfoSingle usegame;

	// Dynamic arrays don't localize properly, so copy static array to dynamic array
	Msg2.insert(0, ArrayCount(Msg));
	for (i = 0; i < Msg2.length; i++)
		Msg2[i] = Msg[i];

	AddTitle(TitleText, TitleFont, TitleAlign);
	AddWrappedTextItem(Msg2, 50, F_FancyS, TA_Left);
	
	usegame = GetGameSingle();
	HolidayCheckbox.Length = 0;
	
	for (i=0; i < usegame.Holidays.Length; i++)
	{
		HolidayCheckbox[HolidayCheckbox.Length] = AddCheckbox(usegame.HolidayDisplayName[i], usegame.HolidayDescription[i], ItemFont);
	}

	BackChoice       = AddChoice(BackText,    "",			ItemFont, ItemAlign, true);

	LoadValues();
}

///////////////////////////////////////////////////////////////////////////////
// Load all values from ini files
///////////////////////////////////////////////////////////////////////////////
function LoadValues()
{
	local int i;
	local P2GameInfoSingle usegame;
	
	usegame = GetGameSingle();
	for (i=0; i < usegame.Holidays.Length; i++)
	{
		HolidayCheckbox[i].SetValue(usegame.IsHolidayOverridden(usegame.Holidays[i].HolidayName));
	}
}

///////////////////////////////////////////////////////////////////////////////
// Callback for when control has changed
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	local int i;
	local P2GameInfoSingle usegame;
	
	Super.Notify(C, E);
	
	switch (E)
	{
		case DE_Change:
			/*
			switch (C)
			{
			}
			*/
			for (i=0; i < HolidayCheckbox.Length; i++)
				if (C == HolidayCheckbox[i])
				{
					usegame = GetGameSingle();
					if (HolidayCheckbox[i].bChecked)
						usegame.AddHolidayOverride(usegame.Holidays[i].HolidayName);
					else
						usegame.DelHolidayOverride(usegame.Holidays[i].HolidayName);
				}
			break;
		case DE_Click:
			switch (C)
			{
				case BackChoice:
					GoBack();
					break;
			}
			break;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	TitleText="Holiday Overrides"
	Msg[0]="Tick the check box of the holiday\\nyou want to enable in-game!"
}