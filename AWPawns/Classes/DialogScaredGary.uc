///////////////////////////////////////////////////////////////////////////////
// DialogScaredGary
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for bruised, scared Gary Coleman
//
///////////////////////////////////////////////////////////////////////////////
class DialogScaredGary extends DialogGary;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	Clear(lscreaming);
	addto(lscreaming,							"GaryDialog.gary_ak", 1);	
	addto(lscreaming,							"GaryDialog.gary_shit", 1);	
	addto(lscreaming,							"GaryDialog.gary_youbitch", 1);	
	addto(lscreaming,							"GaryDialog.gary_argh", 1);	
	addto(lscreaming,							"GaryDialog.gary_aaah", 1);	
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     TestModeClasses(0)="BasePeople.DialogDude"
     TestModeClasses(1)="BasePeople.DialogFemale"
     TestModeClasses(2)="BasePeople.DialogFemaleCop"
     TestModeClasses(3)="BasePeople.DialogGary"
     TestModeClasses(4)="BasePeople.DialogGeneric"
     TestModeClasses(5)="BasePeople.DialogHabib"
     TestModeClasses(6)="BasePeople.DialogKrotchy"
     TestModeClasses(7)="BasePeople.DialogMale"
     TestModeClasses(8)="BasePeople.DialogMaleCop"
     TestModeClasses(9)="BasePeople.DialogMaleMilitary"
     TestModeClasses(10)="BasePeople.DialogPriest"
     TestModeClasses(11)="BasePeople.DialogRedneck"
     TestModeClasses(12)="BasePeople.DialogVince"
}
