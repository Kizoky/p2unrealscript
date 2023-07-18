///////////////////////////////////////////////////////////////////////////////
// Menu to explain xPatch.
///////////////////////////////////////////////////////////////////////////////
class xPatchMenuWelcome extends ShellMenuCW;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var localized string		TitleText;
var localized string		Msg[4];
var ShellMenuChoice			OkayChoice;
var Color MsgColor;
var int MsgHeight;

const xMessagePath = "Shell.ShellMenuCW bShowedXPatch";

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	local int i;
	local array<string> Msg2;
	local ShellWrappedTextControl ctl;

	// Dynamic arrays don't localize properly, so copy static array to dynamic array
	Msg2.insert(0, ArrayCount(Msg));
	for (i = 0; i < Msg2.length; i++)
		Msg2[i] = Msg[i];

	Super.CreateMenuContents();
	GetPlayerOwner().ConsoleCommand("set"@xMessagePath@True);
	
	ItemFont = F_FancyL;
	ItemAlign = TA_Center;
	AddTitle(TitleText, ItemFont, ItemAlign);

	// xPatch: Changed font to be easier to read (was F_FancyS)
	ctl = AddWrappedTextItem(Msg2, MsgHeight, F_Bold, ItemAlign);
	ctl.SetTextColor(MsgColor);

	OkayChoice	= AddChoice(StartText,	"", ItemFont, ItemAlign);
	BackChoice	= AddChoice(BackText, "", ItemFont, ItemAlign, true);
	}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	Super.Notify(C, E);
	switch(E)
		{
		case DE_Click:
			switch (C)
				{
				case OkayChoice:
					GoBack();
					GotoWindow(Root.CreateWindow(Class'xPatchWindow', 0, 0, 1, 1, self, True));
					//JumpToMenu(Class'xPatchMenu');
					break;
				case BackChoice:
					GoBack();
					break;
				}
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	MenuWidth  = 666
	//MenuHeight = 150

	TitleText = "xPatch is now officialy implemented!"

	Msg[0] = "The awesome fan-made patch is finally here, delivered to you with an official update! "
	Msg[1] = "Most of the changes and new features can be customized in this new settings menu. "
	Msg[2] = "Few new options were also added to Game, Performance, Audio and Controls settings. "
    Msg[3] = "Make sure to check them out too! "
	
	StartText = "Got it!"
	
	MsgColor=(R=245,G=245,B=245,A=245)
	MsgHeight=150
}