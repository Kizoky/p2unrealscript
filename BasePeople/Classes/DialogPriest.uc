///////////////////////////////////////////////////////////////////////////////
// DialogPriest
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for priest in confessional booth.
//
///////////////////////////////////////////////////////////////////////////////
class DialogPriest extends DialogMale;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	clear(lPriest_BlessYou);
	Addto(lPriest_BlessYou, 						"WMaleDialog.wm_priest_godbless", 1);
												
	Clear(lGetDownMP);
	Addto(lGetDownMP,								"WMaleDialog.wm_priest_godbless", 1);
	Addto(lGetDownMP,								"WMaleDialog.wm_priest_peacebe", 1);

	Clear(lFollowMe);
	Addto(lFollowMe,	 							"WMaleDialog.wm_priest_comeoutmy", 1);

	clear(lPriest_Confession1);
	Addto(lPriest_Confession1, 						"WMaleDialog.wm_priest_didyoudrop", 1);
												
	clear(lPriest_Confession2);
	Addto(lPriest_Confession2, 						"WMaleDialog.wm_priest_thenyouare", 1);
												
	clear(lPriest_Mumble);
	Addto(lPriest_Mumble,							"WMaleDialog.wm_priest_next", 1);
												
	clear(lPriest_Next);
	Addto(lPriest_Next,								"WMaleDialog.wm_priest_next", 1);
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
