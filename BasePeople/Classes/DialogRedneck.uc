///////////////////////////////////////////////////////////////////////////////
// DialogRedneck
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for the Redneck
//
///////////////////////////////////////////////////////////////////////////////
class DialogRedneck extends DialogMale;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	clear(lGreeting);
	Addto(lGreeting, 							"RedneckDialog.redneck_hello", 1);
												
	Clear(lgreetingquestions);					
												
	Clear(lRespondtogreeting);
	Addto(lrespondtogreeting,					"RedneckDialog.redneck_youtalkintome", 1);

	Clear(lGetDownMP);
	Addto(lGetDownMP,							"RedneckDialog.redneck_imgonnamake", 1);
	Addto(lGetDownMP,							"RedneckDialog.redneck_taunt1", 1);
	Addto(lGetDownMP,							"RedneckDialog.redneck_whosfirst", 1);

	Clear(lFollowMe);
	Addto(lFollowMe,							"RedneckDialog.redneck_yeehaw1", 1);
	Addto(lFollowMe,							"RedneckDialog.redneck_yeehaw2", 1);

	clear(lYes);								
	Addto(lyes,									"RedneckDialog.redneck_yes", 1);
												
	clear(lNo);									
	Addto(lno,									"RedneckDialog.redneck_no", 1);

	clear(lThanks);
	Addto(lthanks,								"RedneckDialog.redneck_appreciated", 1);

	Clear(ldying);
	Addto(ldying,								"RedneckDialog.redneck_realdaddy", 1);
	Addto(ldying,								"WMaleDialog.wm_deathcrawl1", 1);
	Addto(ldying,								"WMaleDialog.wm_deathcrawl2", 1);
	Addto(ldying,								"WMaleDialog.wm_deathcrawl3", 2);

	Clear(lgothit);
	addto(lgothit,								"RedneckDialog.redneck_aahimhit", 1);	
	addto(lgothit,								"RedneckDialog.redneck_argh", 1);	
	addto(lgothit,								"RedneckDialog.redneck_ak", 1);	

	Clear(lAttacked);
	addto(lAttacked,								"RedneckDialog.redneck_argh", 1);	
	addto(lAttacked,								"RedneckDialog.redneck_ak", 1);	

	addto(lGrunt,								"RedneckDialog.redneck_aahimhit", 1);	
	addto(lGrunt,								"RedneckDialog.redneck_argh", 1);	
	addto(lGrunt,								"RedneckDialog.redneck_ak", 1);	

	Clear(lGotHitInCrotch);	
	addto(lGotHitInCrotch,						"RedneckDialog.redneck_ak", 1);	

	Clear(lGotHealth);
	Addto(lGotHealth,							"RedneckDialog.redneck_whoop1", 1);
	Addto(lGotHealth,							"RedneckDialog.redneck_yahoo1", 1);
	Addto(lGotHealth,							"RedneckDialog.redneck_whoop2", 2);
	Addto(lGotHealth,							"RedneckDialog.redneck_yahoo2", 2);

	Clear(lGotHealthFood);
	Addto(lGotHealthFood,						"RedneckDialog.redneck_whoop1", 1);
	Addto(lGotHealthFood,						"RedneckDialog.redneck_yahoo1", 1);
	Addto(lGotHealthFood,						"RedneckDialog.redneck_whoop2", 2);
	Addto(lGotHealthFood,						"RedneckDialog.redneck_yahoo2", 2);

	Clear(lGotCrackHealth);
	Addto(lGotCrackHealth,						"RedneckDialog.redneck_yeehaw1", 1);
	Addto(lGotCrackHealth,						"RedneckDialog.redneck_yeehaw2", 2);

	Clear(lWhileFighting);
	Addto(lWhileFighting,							"RedneckDialog.redneck_taunt1", 1);
	Addto(lWhileFighting,							"RedneckDialog.redneck_whoop1", 1);
	Addto(lWhileFighting,							"RedneckDialog.redneck_yahoo1", 1);
	Addto(lWhileFighting,							"RedneckDialog.redneck_yeehaw1", 1);
	Addto(lWhileFighting,							"RedneckDialog.redneck_whoop2", 2);
	Addto(lWhileFighting,							"RedneckDialog.redneck_yahoo2", 2);
	Addto(lWhileFighting,							"RedneckDialog.redneck_yeehaw2", 2);

	Clear(ltrashtalk);
	Addto(ltrashtalk,								"RedneckDialog.redneck_taunt1", 1);
	Addto(ltrashtalk,								"WMaleDialog.wm_fuckyoubuddy", 1);

	Clear(ldecidetofight);
	Addto(ldecidetofight,							"RedneckDialog.redneck_whoop1", 1);
	Addto(ldecidetofight,							"RedneckDialog.redneck_yahoo1", 1);
	Addto(ldecidetofight,							"RedneckDialog.redneck_yeehaw1", 1);
	Addto(ldecidetofight,							"RedneckDialog.redneck_whoop2", 2);
	Addto(ldecidetofight,							"RedneckDialog.redneck_yahoo2", 2);
	Addto(ldecidetofight,							"RedneckDialog.redneck_yeehaw2", 2);


	Clear(llaughing);
	Addto(llaughing,								"RedneckDialog.redneck_huhhuhhuh", 1);


	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
