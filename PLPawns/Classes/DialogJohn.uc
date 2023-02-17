///////////////////////////////////////////////////////////////////////////////
// Dialog
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for all white males
//
// If a new dialog class is added and it references a new sound package
// (like SuperHeroDialog.uax) then in order for those sounds to play on the
// client, you either need a hard reference in the code to one of those files
// Sound'SuperHeroDialog.DieScum', or you need to put that package in the
// ini's with serverpackages (cheesier version).
//
//	History:
//		02/07/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class DialogJohn extends DialogGeneric;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	Clear(lGetDown);
	AddTo(lGetDown,								"DialogJohn.Dialouge_Killed1", 1);
	AddTo(lGetDown,								"DialogJohn.Dialouge_Killed2", 1);
	AddTo(lGetDown,								"DialogJohn.Dialouge_Killed3", 1);
	AddTo(lGetDown,								"DialogJohn.Dialouge_Killed4", 1);
	AddTo(lGetDown,								"DialogJohn.Dialouge_Killed5", 1);
	AddTo(lGetDown,								"DialogJohn.Dialouge_Killed6", 1);
	AddTo(lGetDown,								"DialogJohn.Dialouge_Killed7", 1);

	Clear(lCussing);
	Addto(lCussing,								"DialogJohn.Dialouge_Hurt1", 1);
	Addto(lCussing,								"DialogJohn.Dialouge_Killed1", 1);
	Addto(lCussing,								"DialogJohn.Dialouge_Killed2", 1);
	Addto(lCussing,								"DialogJohn.Dialouge_Killed3", 1);
	Addto(lCussing,								"DialogJohn.Dialouge_Killed4", 1);
	Addto(lCussing,								"DialogJohn.Dialouge_Killed6", 1);

	Clear(ldefiant);
	Addto(ldefiant,								"DialogJohn.Dialouge_Killed1", 1);
	Addto(ldefiant,								"DialogJohn.Dialouge_Killed2", 1);
	Addto(ldefiant,								"DialogJohn.Dialouge_Killed3", 1);
	Addto(ldefiant,								"DialogJohn.Dialouge_Killed4", 1);
	Addto(ldefiant,								"DialogJohn.Dialouge_Killed6", 1);
	Addto(ldefiant,								"DialogJohn.Dialouge_Killed7", 1);

	Clear(ldefiantline);
	Addto(ldefiantline,							"DialogJohn.Dialouge_Killed1", 1);
	Addto(ldefiantline,							"DialogJohn.Dialouge_Killed2", 1);
	Addto(ldefiantline,							"DialogJohn.Dialouge_Killed3", 1);
	Addto(ldefiantline,							"DialogJohn.Dialouge_Killed4", 1);
	Addto(ldefiantline,							"DialogJohn.Dialouge_Killed6", 1);
	Addto(ldefiantline,							"DialogJohn.Dialouge_Killed7", 1);
	
	Clear(lCloseToWeapon);
	Addto(lCloseToWeapon,						"DialogJohn.Dialouge_Hurt1", 1);
	Addto(lCloseToWeapon,						"DialogJohn.Dialouge_Killed1", 1);
	Addto(lCloseToWeapon,						"DialogJohn.Dialouge_Killed2", 1);
	Addto(lCloseToWeapon,						"DialogJohn.Dialouge_Killed3", 1);
	Addto(lCloseToWeapon,						"DialogJohn.Dialouge_Killed4", 1);
	Addto(lCloseToWeapon,						"DialogJohn.Dialouge_Killed6", 1);

	Clear(ldecidetofight);
	Addto(ldecidetofight,						"DialogJohn.Dialouge_Killed1", 1);
	Addto(ldecidetofight,						"DialogJohn.Dialouge_Killed2", 1);
	Addto(ldecidetofight,						"DialogJohn.Dialouge_Killed3", 1);
	Addto(ldecidetofight,						"DialogJohn.Dialouge_Killed4", 1);
	Addto(ldecidetofight,						"DialogJohn.Dialouge_Killed5", 1);
	Addto(ldecidetofight,						"DialogJohn.Dialouge_Killed6", 1);
	Addto(ldecidetofight,						"DialogJohn.Dialouge_Killed7", 1);

	Clear(llaughing);
	Addto(llaughing,								"WMaleDialog.wm_laugh", 1);

	Clear(lSnickering);
	Addto(lSnickering,								"WMaleDialog.wm_snicker", 1);

	Clear(lOutOfBreath);
	Addto(lOutOfBreath,								"WMaleDialog.wm_outofbreath", 1);

	Clear(lWatchingCrazy);
	Addto(lWatchingCrazy,							"WMaleDialog.wm_snicker", 1);
	
	Clear(lscreaming);
	Addto(lscreaming,								"DialogJohn.Dialouge_Hurt1", 1);
	Addto(lscreaming,								"DialogJohn.Dialouge_Hurt2", 1);
	Addto(lscreaming,								"DialogJohn.Dialouge_Hurt3", 1);

	Clear(lscreamingonfire);
	Addto(lscreamingonfire,							"DialogJohn.Dialouge_Hurt1", 1);
	Addto(lscreamingonfire,							"DialogJohn.Dialouge_Hurt2", 1);
	Addto(lscreamingonfire,							"DialogJohn.Dialouge_Hurt3", 1);
	
	Clear(lDoHeroics);
	Addto(lDoHeroics,								"DialogJohn.Dialouge_Killed1", 1);
	Addto(lDoHeroics,								"DialogJohn.Dialouge_Killed2", 1);
	Addto(lDoHeroics,								"DialogJohn.Dialouge_Killed3", 1);
	Addto(lDoHeroics,								"DialogJohn.Dialouge_Killed4", 1);
	Addto(lDoHeroics,								"DialogJohn.Dialouge_Killed5", 1);
	Addto(lDoHeroics,								"DialogJohn.Dialouge_Killed6", 1);
	Addto(lDoHeroics,								"DialogJohn.Dialouge_Killed7", 1);

	Clear(lgettingpissedon);
	Addto(lgettingpissedon,							"WMaleDialog.wm_spitoutpiss", 1);

	Clear(laftergettingpissedon);
	Addto(laftergettingpissedon,					"DialogJohn.Dialouge_Hurt1", 1);
	Addto(laftergettingpissedon,					"DialogJohn.Dialouge_Killed4", 1);
	
	Clear(lgothit);
	Addto(lgothit,								"DialogJohn.Dialouge_Hurt1", 1);
	Addto(lgothit,								"DialogJohn.Dialouge_Hurt2", 1);
	Addto(lgothit,								"DialogJohn.Dialouge_Hurt3", 1);

	Clear(lAttacked);
	addto(lAttacked,								"DialogJohn.Dialouge_Hurt1", 1);	
	addto(lAttacked,								"DialogJohn.Dialouge_Hurt2", 1);	
	addto(lAttacked,								"DialogJohn.Dialouge_Hurt3", 1);	

	Clear(lGrunt);
	addto(lGrunt,								"DialogJohn.Dialouge_Hurt1", 1);	
	addto(lGrunt,								"DialogJohn.Dialouge_Hurt2", 1);	
	addto(lGrunt,								"DialogJohn.Dialouge_Hurt3", 1);	

	// no pissing talking
	Clear(lPissing);
	Addto(lPissing,								"DialogJohn.Dialouge_Piss5", 1);

	Clear(lPissOnSelf);
	Addto(lPissOnSelf,							"WMaleDialog.wm_spitting", 1);
	
	// no pissing myself out talking
	Clear(lPissOutFireOnSelf);
	Addto(lPissOutFireOnSelf,					"DialogJohn.Dialouge_Piss5", 1);
	
	Clear(lDude_SniperBreathing);
	AddTo(lDude_SniperBreathing,				"WeaponSounds.sniper_zoombreathing", 1);

	Clear(lGotHealth);
	Addto(lGotHealth,							"DialogJohn.Dialouge_Piss5", 1);

	Clear(lGotHealthFood);
	Addto(lGotHealthFood,						"DialogJohn.Dialouge_Piss5", 1);

	Clear(lGotCrackHealth);
	Addto(lGotCrackHealth,						"DialogJohn.Dialouge_Piss5", 1);

	Clear(lGotHitInCrotch);	
	addto(lGotHitInCrotch,						"DialogJohn.Dialouge_Hurt3", 1);	

	Clear(ltrashtalk);
	Addto(ltrashtalk,							"DialogJohn.Dialouge_Killed1", 1);
	Addto(ltrashtalk,							"DialogJohn.Dialouge_Killed2", 1);
	Addto(ltrashtalk,							"DialogJohn.Dialouge_Killed3", 1);
	Addto(ltrashtalk,							"DialogJohn.Dialouge_Killed4", 1);
	Addto(ltrashtalk,							"DialogJohn.Dialouge_Killed5", 1);
	Addto(ltrashtalk,							"DialogJohn.Dialouge_Killed6", 1);
	Addto(ltrashtalk,							"DialogJohn.Dialouge_Killed7", 1);

	Clear(lWhileFighting);
	Addto(lWhileFighting,							"DialogJohn.Dialouge_Killed1", 1);
	Addto(lWhileFighting,							"DialogJohn.Dialouge_Killed2", 1);
	Addto(lWhileFighting,							"DialogJohn.Dialouge_Killed3", 1);
	Addto(lWhileFighting,							"DialogJohn.Dialouge_Killed4", 1);
	Addto(lWhileFighting,							"DialogJohn.Dialouge_Killed5", 1);
	Addto(lWhileFighting,							"DialogJohn.Dialouge_Killed6", 1);
	Addto(lWhileFighting,							"DialogJohn.Dialouge_Killed7", 1);
	
	Clear(lInhale);
	Addto(lInhale,								"WMaleDialog.wm_inhale", 1);
												
	Clear(lExhale);								
	Addto(lExhale,								"WMaleDialog.wm_exhale", 1);
	
	Clear(lEatingFood);
	Addto(lEatingFood,							"WMaleDialog.wm_mmm", 1);
	Addto(lEatingFood,							"WMaleDialog.wm_chewing", 1);
	Addto(lEatingFood,							"WMaleDialog.wm_smacking", 1);
	Addto(lEatingFood,							"WMaleDialog.wm_drinkingsucking", 1);

	Clear(lAfterEating);
	Addto(lAfterEating,							"DialogJohn.Dialouge_Piss5", 1);
	Addto(lAfterEating,							"WMaleDialog.wm_ohyeahthattookayear", 1);
	Addto(lAfterEating,							"WMaleDialog.wm_hardtobelievethat", 1);
	Addto(lAfterEating,							"WMaleDialog.wm_heythatwasactually", 1);
	Addto(lAfterEating,							"WMaleDialog.wm_goodgodwhatwasin", 1);
	Addto(lAfterEating,							"WMaleDialog.wm_burp", 1);

	Clear(lpleasureresponse);					
	Addto(lpleasureresponse,						"DialogJohn.Dialouge_Piss5", 1);

	Clear(laftersitdown);
	Addto(laftersitdown,							"DialogJohn.Dialouge_Piss5", 1);

	Clear(lSpitting);
	Addto(lSpitting,							"WMaleDialog.wm_shortingspitting", 1);
	Addto(lSpitting,							"WMaleDialog.wm_spitting", 1);
	
	Clear(lhmm);
	Addto(lhmm,									"WMaleDialog.wm_hmmmm", 1);

	Clear(lbodyfunctions);
	Addto(lbodyfunctions,							"WMaleDialog.wm_vomit", 1);

	Clear(lGettingShocked);
	Addto(lGettingShocked,							"WMaleDialog.wm_vomit", 1);

	// This sounds so much like a girl, the Kumquat wives (of Habib's) use this too
	Clear(lBattleCry);
	Addto(lBattleCry,								"HabibDialog.habib_ailili", 1);

	Clear(ldudedead);
	Addto(ldudedead,							"DialogJohn.Dialouge_Killed1", 1);
	Addto(ldudedead,							"DialogJohn.Dialouge_Killed2", 1);
	Addto(ldudedead,							"DialogJohn.Dialouge_Killed3", 1);
	Addto(ldudedead,							"DialogJohn.Dialouge_Killed4", 1);
	Addto(ldudedead,							"DialogJohn.Dialouge_Killed5", 1);
	Addto(ldudedead,							"DialogJohn.Dialouge_Killed6", 1);
	Addto(ldudedead,							"DialogJohn.Dialouge_Killed7", 1);

	Clear(lKickDead);
	Addto(lKickDead,							"DialogJohn.Dialouge_Killed1", 1);
	Addto(lKickDead,							"DialogJohn.Dialouge_Killed2", 1);
	Addto(lKickDead,							"DialogJohn.Dialouge_Killed3", 1);
	Addto(lKickDead,							"DialogJohn.Dialouge_Killed4", 1);
	Addto(lKickDead,							"DialogJohn.Dialouge_Killed5", 1);
	Addto(lKickDead,							"DialogJohn.Dialouge_Killed6", 1);
	Addto(lKickDead,							"DialogJohn.Dialouge_Killed7", 1);
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
