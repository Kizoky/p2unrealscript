///////////////////////////////////////////////////////////////////////////////
// DialogGeneric
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for all characters.
//
//	History:
//		02/07/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class DialogGeneric extends P2Dialog;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	// Use one clap for everyone, should at least have a variety to choose from
	Clear(lapplauding);
	Addto(lapplauding,							"WFemaleDialog.wf_clap", 1);

	// Protestor lines are recorded as group chants, not individual people chanting.
	// Might want to change this in the future and add code to roughly synchronize
	// the protestor characters so they all say the same lines roughly in unison.
	clear(lProtest_Church);
	Addto(lProtest_Church, 					"Protestors.wm_protest_church", 1);
	
	clear(lProtest_Labs);
	Addto(lProtest_Labs, 					"Protestors.wm_protest_lab1", 1);

	clear(lProtest_Books);
	Addto(lProtest_Books,					"Protestors.wm_protest_library1", 1);

	clear(lProtest_Meat);
	Addto(lProtest_Meat, 					"Protestors.wm_protest_meat1", 1);

	clear(lProtest_Games);
	Addto(lProtest_Games,					"Protestors.wm_protest_rws1", 1);
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
