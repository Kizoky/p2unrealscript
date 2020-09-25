///////////////////////////////////////////////////////////////////////////////
// MpFemaleDialog.uc
// Copyright 2019 Running With Scissors.  All Rights Reserved.
// by NickP, nickp@gopostal.com
//
// Base mp female dialog.
//
///////////////////////////////////////////////////////////////////////////////
class MpFemaleDialog extends DialogFemale;

///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	Clear(lGetDownMP);
	Addto(lGetDownMP,							"WFemaleDialog.wf_angrygetdown", 1);
	Addto(lGetDownMP,							"WFemaleDialog.wf_angrygetdownifyou", 1);
	Addto(lGetDownMP,							"WFemaleDialog.wf_angrygetonground", 1);
	Addto(lGetDownMP,							"WFemaleDialog.wf_angrygetdown", 1);
	Addto(lGetDownMP,							"WFemaleDialog.wf_fuckyoubuddy", 2);
	Addto(lGetDownMP,							"WFemaleDialog.wf_goscrewyourself", 2);
	Addto(lGetDownMP,							"WFemaleDialog.wf_cmonfightlikeaman", 3);
	Addto(lGetDownMP,							"WFemaleDialog.wf_postal_howaboutwe", 3);

	Clear(lFollowMe);
	Addto(lFollowMe,							"WFemaleDialog.wf_followme", 1);
	Addto(lfollowme,							"WFemaleDialog.wf_thisway", 1);
	Addto(lfollowme,							"WFemaleDialog.wf_overhere", 1);
	Addto(lFollowMe,							"WFemaleDialog.wf_cmoneveryonefollow", 2);
	Addto(lFollowMe,							"WFemaleDialog.wf_alrighteveryone", 2);

	Clear(lStayHere);
	Addto(lStayHere,							"WFemaleDialog.wf_cop_stoprightthere", 1);

	Clear(lgothit);
	Addto(lgothit,								"WFemaleDialog.wf_aahimhit", 1);
	addto(lgothit,								"WFemaleDialog.wf_argh", 1);	
	addto(lgothit,								"WFemaleDialog.wf_ow", 1);
	addto(lgothit,								"WFemaleDialog.wf_shit", 2);
	addto(lgothit,								"WFemaleDialog.wf_aghk", 2);
	addto(lgothit,								"WFemaleDialog.wf_gak", 3);

	Clear(lGrunt);
	Addto(lGrunt,								"WFemaleDialog.wf_aahimhit", 1);
	addto(lGrunt,								"WFemaleDialog.wf_argh", 1);	
	addto(lGrunt,								"WFemaleDialog.wf_ow", 1);
	addto(lGrunt,								"WFemaleDialog.wf_shit", 2);
	addto(lGrunt,								"WFemaleDialog.wf_aghk", 2);
	addto(lGrunt,								"WFemaleDialog.wf_gak", 3);

	Clear(lPissOnSelf);
	Addto(lPissOnSelf,							"WFemaleDialog.wf_spitoutpiss", 1);

	Clear(lDude_SniperBreathing);
	AddTo(lDude_SniperBreathing,					"WeaponSounds.sniper_zoombreathing", 1);

	Clear(lGotHealthFood);
	Addto(lGotHealthFood,							"WFemaleDialog.wf_thatwasprettytasty", 1);
	Addto(lGotHealthFood,							"WFemaleDialog.wf_hardtobelievethat", 2);
	Addto(lGotHealthFood,							"WFemaleDialog.wf_heythatwasactually", 2);
	Addto(lGotHealthFood,							"WFemaleDialog.wf_goodgodwhatwasin", 3);
	Addto(lGotHealthFood,							"WFemaleDialog.wf_burp", 3);

	Clear(lGotHealth);
	Addto(lGotHealth,						"WFemaleDialog.wf_ahh", 1);

	Clear(lPissOutFireOnSelf);
	Addto(lPissOutFireOnSelf,					"WFemaleDialog.wf_ahh", 1);

	Clear(lGotCrackHealth);
	Addto(lGotCrackHealth,							"WFemaleDialog.wf_ohyeahthattookayear", 1);
	Addto(lGotCrackHealth,							"WFemaleDialog.wf_thatsaloadoff", 1);
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
