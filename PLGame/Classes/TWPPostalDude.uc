///////////////////////////////////////////////////////////////////////////////
// TWPPostalDude
// PLPostalDude extended to work with Two Weeks game mode
//
// Made by Piotr "Man Chrzan" Sztukowski
// For xPatch 2.5 and offcial P2 update (probably).
///////////////////////////////////////////////////////////////////////////////
class TWPPostalDude extends PLPostalDude;

///////////////////////////////////////////////////////////////////////////////
// Public vars
///////////////////////////////////////////////////////////////////////////////
var(Events) name	OverrideTagPL, OverrideTagP2;	// Forced tag name
var class<P2Dialog> DialogClassP2;	// Dialog class to use for first week
var class<P2Dialog> DialogClassPL;	// Dialog class to use for second week

///////////////////////////////////////////////////////////////////////////////
// Called by GameInfo
///////////////////////////////////////////////////////////////////////////////
function DudeCheckHeadSkin()
{
	if(TWPGameInfo(Level.Game).IsSecondWeek())
		Super(PLPostalDude).DudeCheckHeadSkin();
	else
		Super(AWPostalDude).DudeCheckHeadSkin();
}

///////////////////////////////////////////////////////////////////////////////
// For cutscenes and scripted sequences to work properly. (Called by TWPGameInfo)
///////////////////////////////////////////////////////////////////////////////
function SwapDudeTag(bool bSecondWeek)
{
	if(bSecondWeek)
	{
		Default.Tag = OverrideTagPL;
		Tag = OverrideTagPL;
	}
	else
	{
		Default.Tag = OverrideTagP2;
		Tag = OverrideTagP2;
	}
	
	CheckDialog(bSecondWeek);
}

///////////////////////////////////////////////////////////////////////////////
// Set dialog class.  Dialog class can be set via default properties in
// which case the extended class doesn't need to define this function.
///////////////////////////////////////////////////////////////////////////////
function CheckDialog(bool bSecondWeek)
{
	local bool bChange;
	
	if(bSecondWeek)
	{
		if(DialogClass == DialogClassP2)
		{
			DialogClass = DialogClassPL;
			default.DialogClass = DialogClassPL;
			bChange=True;
		}
	}
	else
	{
		if(DialogClass == DialogClassPL)
		{
			DialogClass = DialogClassP2;
			default.DialogClass = DialogClassP2;
			bChange=True;
		}
	}

	if(bChange)
		myDialog = P2GameInfo(Level.Game).GetDialogObj(String(DialogClass));
}

function SetDialogClass()
{
	// Dialog overrides based on current week
	//if (TWPGameInfo(Level.Game).IsSecondWeek())	// Didn't work for some reason
	if(Class'TWPGameInfo'.default.bIsSecondWeek)
	{
		DialogClass = DialogClassPL;
		default.DialogClass = DialogClassPL;
	}
	else
	{
		DialogClass = DialogClassP2;
		default.DialogClass = DialogClassP2;
	}
}

function SetupDialog()
{
	SetDialogClass();

	if (P2GameInfo(Level.Game) != None)
	{
		myDialog = P2GameInfo(Level.Game).GetDialogObj(String(DialogClass));
		if (myDialog == None)
			Warn("Couldn't load dialog: "$String(DialogClass));
	}
}

// DEBUG: Check how things are here
exec function GetTWPInfo()
{
	P2Player(Controller).ClientMessage("TWPPostalDude.DialogClass:"@DialogClass);
	P2Player(Controller).ClientMessage("TWPPostalDude.Tag:"@Tag);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	// For first week (POSTAL 2 and AW)
	OverrideTagP2 = AWPostalDude	
	DialogClassP2 = Class'DialogDude'
	
	// For second week (Paradise Lost) 
	OverrideTagPL = PLPostalDude	
	DialogClassPL = Class'DialogDudePL'
}