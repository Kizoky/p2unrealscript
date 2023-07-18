///////////////////////////////////////////////////////////////////////////////
// PLMenuEnhanced
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Enhanced menu description for Paradise Lost.
///////////////////////////////////////////////////////////////////////////////
class PLMenuEnhanced extends MenuEnhanced;

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	Super(ShellMenuCW).Notify(C, E);
	switch(E)
	{
		case DE_Click:
			switch (C)
			{
				case BackChoice:
					GoBack();
					break;
				case StartChoice:
					// xPatch: Go to the previously selected start menu
					if(PickStartMenu != None)
						JumpToMenu(PickStartMenu);
					else // This should not happen but if it somehow does go to the old start menu.
						JumpToMenu(class'PLMenuStart');
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
}
