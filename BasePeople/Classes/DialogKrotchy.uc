///////////////////////////////////////////////////////////////////////////////
// DialogGary
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for guy in Krotchy outfit
//
///////////////////////////////////////////////////////////////////////////////
class DialogKrotchy extends DialogMale;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Krotchy really, really only wants these things to say, so don't let him say anything
	// other than this. Don't call the super!

	// clear ones we don't have good lines for
	Clear(lDoHeroics);
	Clear(lCloseToWeapon);

	clear(lKrotchy_HaveANiceDay);
	Addto(lKrotchy_HaveANiceDay,				"KrotchyDialog.wm_krotchy_haveakrotchy", 1);

	clear(lKrotchy_HeyKids);
	Addto(lKrotchy_HeyKids,						"KrotchyDialog.wm_krotchy_heykidsim", 1);

	clear(lKrotchy_SoldOut1);
	Addto(lKrotchy_SoldOut1, 					"KrotchyDialog.wm_krotchy_webeallsoldout", 1);

	clear(lKrotchy_SoldOut2);
	Addto(lKrotchy_SoldOut2, 					"KrotchyDialog.wm_krotchy_theresstill", 1);

	clear(lKrotchy_TakesBribe);
	Addto(lKrotchy_TakesBribe, 					"KrotchyDialog.wm_krotchy_bitchyougot", 1);

	Clear(ldecidetofight);
	Addto(ldecidetofight, 						"KrotchyDialog.wm_krotchy_gotcajones", 1);
	Addto(ldecidetofight, 						"KrotchyDialog.wm_krotchy_youthinkyou", 1);

	Clear(lWhileFighting);
	Addto(lWhileFighting, 						"KrotchyDialog.wm_krotchy_gotcajones", 1);
	Addto(lWhileFighting, 						"KrotchyDialog.wm_krotchy_youthinkyou", 1);

	Clear(lgetbumped);
	Addto(lgetbumped,							"KrotchyDialog.wm_krotchy_getoffme", 1);

	Clear(llaughing);
	Addto(llaughing,								"WMaleDialog.wm_laugh", 1);

	Clear(lSnickering);
	Addto(lSnickering,								"WMaleDialog.wm_snicker", 1);

	Clear(lGetMad);
	Addto(lGetMad,								"KrotchyDialog.wm_krotchy_getoffme", 1);
	addto(lGetMad,								"WMaleDialog.wm_ow", 1);
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
