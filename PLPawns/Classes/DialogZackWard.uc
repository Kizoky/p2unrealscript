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
class DialogZackWard extends DialogGeneric;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	Clear(lGetDown);
	AddTo(lGetDown,								"PL-Dialog.WednesdayZackBoss.Zack-Grenade-FireInTheHole1", 1);
	AddTo(lGetDown,								"PL-Dialog.WednesdayZackBoss.Zack-Grenade-FireInTheHole2", 1);
	AddTo(lGetDown,								"PL-Dialog.WednesdayZackBoss.Zack-Grenade-IveGottaPresentForYa1", 1);
	AddTo(lGetDown,								"PL-Dialog.WednesdayZackBoss.Zack-Grenade-IveGottaPresentForYa2", 1);
	AddTo(lGetDown,								"PL-Dialog.WednesdayZackBoss.Zack-Grenade-ThinkFastJerk", 1);
	AddTo(lGetDown,								"PL-Dialog.WednesdayZackBoss.Zack-Grenade-ThinkFastJerk2", 1);

	Clear(lCussing);
	Addto(lCussing,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-OhFudge", 1);

	Clear(ldefiant);
	Addto(ldefiant,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-ShootYourEyeOut", 1);
	Addto(ldefiant,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-ShootYourEyeOut2", 1);

	Clear(ldefiantline);
	Addto(ldefiantline,							"PL-Dialog.WednesdayZackBoss.Zack-Pain-ShootYourEyeOut", 1);
	Addto(ldefiantline,							"PL-Dialog.WednesdayZackBoss.Zack-Pain-ShootYourEyeOut2", 1);
	
	Clear(lCloseToWeapon);
	Addto(lCloseToWeapon,						"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ack1", 1);
	Addto(lCloseToWeapon,						"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ack2", 1);
	Addto(lCloseToWeapon,						"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ack3", 1);
	Addto(lCloseToWeapon,						"PL-Dialog.WednesdayZackBoss.Zack-Pain-Aiee1", 1);
	Addto(lCloseToWeapon,						"PL-Dialog.WednesdayZackBoss.Zack-Pain-Aiee2", 1);
	Addto(lCloseToWeapon,						"PL-Dialog.WednesdayZackBoss.Zack-Pain-Augh1", 1);
	Addto(lCloseToWeapon,						"PL-Dialog.WednesdayZackBoss.Zack-Pain-Augh2", 1);
	Addto(lCloseToWeapon,						"PL-Dialog.WednesdayZackBoss.Zack-Pain-OhFudge", 1);

	Clear(ldecidetofight);
	Addto(ldecidetofight,						"PL-Dialog.WednesdayZackBoss.Zack-StationaryTaunts-HeresZacky", 1);

	Clear(llaughing);
	Addto(llaughing,							"PL-Dialog.WednesdayZackBoss.Zack-Laugher1", 1);
	Addto(llaughing,							"PL-Dialog.WednesdayZackBoss.Zack-Laugher2", 1);
	Addto(llaughing,							"PL-Dialog.WednesdayZackBoss.Zack-Laugher3", 1);

	Clear(lSnickering);
	Addto(lSnickering,							"WMaleDialog.wm_snicker", 1);

	Clear(lOutOfBreath);
	Addto(lOutOfBreath,							"WMaleDialog.wm_outofbreath", 1);

	Clear(lWatchingCrazy);
	Addto(lWatchingCrazy,						"WMaleDialog.wm_snicker", 1);
	
	Clear(lscreaming);
	Addto(lscreaming,							"PL-Dialog.WednesdayZackBoss.Zack-Pain-Aiee1", 1);
	Addto(lscreaming,							"PL-Dialog.WednesdayZackBoss.Zack-Pain-Aiee2", 1);
	Addto(lscreaming,							"PL-Dialog.WednesdayZackBoss.Zack-Pain-Augh1", 1);
	Addto(lscreaming,							"PL-Dialog.WednesdayZackBoss.Zack-Pain-Augh2", 1);

	Clear(lscreamingonfire);
	Addto(lscreamingonfire,						"PL-Dialog.WednesdayZackBoss.Zack-Pain-Aiee1", 1);
	Addto(lscreamingonfire,						"PL-Dialog.WednesdayZackBoss.Zack-Pain-Aiee2", 1);
	Addto(lscreamingonfire,						"PL-Dialog.WednesdayZackBoss.Zack-Pain-Augh1", 1);
	Addto(lscreamingonfire,						"PL-Dialog.WednesdayZackBoss.Zack-Pain-Augh2", 1);
	
	Clear(lDoHeroics);
	Addto(lDoHeroics,							"PL-Dialog.WednesdayZackBoss.Zack-Grenade-IveGottaPresentForYa1", 1);
	Addto(lDoHeroics,							"PL-Dialog.WednesdayZackBoss.Zack-Grenade-IveGottaPresentForYa2", 1);
	Addto(lDoHeroics,							"PL-Dialog.WednesdayZackBoss.Zack-Grenade-ThinkFastJerk", 1);
	Addto(lDoHeroics,							"PL-Dialog.WednesdayZackBoss.Zack-Grenade-ThinkFastJerk2", 1);
	Addto(lDoHeroics,							"PL-Dialog.WednesdayZackBoss.Zack-StationaryTaunts-HeresZacky", 1);

	Clear(lgettingpissedon);
	Addto(lgettingpissedon,						"WMaleDialog.wm_spitoutpiss", 1);

	Clear(laftergettingpissedon);
	Addto(laftergettingpissedon,				"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ack1", 1);
	Addto(laftergettingpissedon,				"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ack2", 1);
	Addto(laftergettingpissedon,				"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ack3", 1);
	Addto(laftergettingpissedon,				"PL-Dialog.WednesdayZackBoss.Zack-Pain-Aiee1", 1);
	Addto(laftergettingpissedon,				"PL-Dialog.WednesdayZackBoss.Zack-Pain-Aiee2", 1);
	Addto(laftergettingpissedon,				"PL-Dialog.WednesdayZackBoss.Zack-Pain-Augh1", 1);
	Addto(laftergettingpissedon,				"PL-Dialog.WednesdayZackBoss.Zack-Pain-Augh2", 1);
	
	Clear(lgothit);
	Addto(lgothit,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ack1", 1);
	Addto(lgothit,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ack2", 1);
	Addto(lgothit,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ack3", 1);
	Addto(lgothit,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Aiee1", 1);
	Addto(lgothit,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Aiee2", 1);
	Addto(lgothit,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Augh1", 1);
	Addto(lgothit,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Augh2", 1);
	Addto(lgothit,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-OhFudge", 1);
	Addto(lgothit,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ow", 1);
	Addto(lgothit,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ow1", 1);
	Addto(lgothit,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ow2", 1);
	Addto(lgothit,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-ShootYourEyeOut", 1);
	Addto(lgothit,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-ShootYourEyeOut2", 1);
	Addto(lgothit,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Uncle", 1);

	Clear(lAttacked);
	Addto(lAttacked,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ack1", 1);
	Addto(lAttacked,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ack2", 1);
	Addto(lAttacked,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ack3", 1);
	Addto(lAttacked,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Aiee1", 1);
	Addto(lAttacked,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Aiee2", 1);
	Addto(lAttacked,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Augh1", 1);
	Addto(lAttacked,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Augh2", 1);
	Addto(lAttacked,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-OhFudge", 1);
	Addto(lAttacked,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ow", 1);
	Addto(lAttacked,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ow1", 1);
	Addto(lAttacked,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ow2", 1);

	Clear(lGrunt);
	Addto(lGrunt,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ack1", 1);
	Addto(lGrunt,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ack2", 1);
	Addto(lGrunt,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ack3", 1);
	Addto(lGrunt,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Aiee1", 1);
	Addto(lGrunt,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Aiee2", 1);
	Addto(lGrunt,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Augh1", 1);
	Addto(lGrunt,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Augh2", 1);
	Addto(lGrunt,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-OhFudge", 1);
	Addto(lGrunt,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ow", 1);
	Addto(lGrunt,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ow1", 1);
	Addto(lGrunt,								"PL-Dialog.WednesdayZackBoss.Zack-Pain-Ow2", 1);

	// no pissing talking
	Clear(lPissing);
	Addto(lPissing,								"WMaleDialog.wm_satisfiedsigh", 1);

	Clear(lPissOnSelf);
	Addto(lPissOnSelf,							"WMaleDialog.wm_spitting", 1);
	
	// no pissing myself out talking
	Clear(lPissOutFireOnSelf);
	Addto(lPissing,								"WMaleDialog.wm_satisfiedsigh", 1);
	
	Clear(lDude_SniperBreathing);
	AddTo(lDude_SniperBreathing,				"WeaponSounds.sniper_zoombreathing", 1);

	Clear(lGotHealth);
	Addto(lPissing,								"WMaleDialog.wm_satisfiedsigh", 1);

	Clear(lGotHealthFood);
	Addto(lPissing,								"WMaleDialog.wm_satisfiedsigh", 1);

	Clear(lGotCrackHealth);
	Addto(lPissing,								"WMaleDialog.wm_satisfiedsigh", 1);

	Clear(lGotHitInCrotch);	
	addto(lGotHitInCrotch,						"PL-Dialog.WednesdayZackBoss.Zack-Pain-OhFudge", 1);
	addto(lGotHitInCrotch,						"PL-Dialog.WednesdayZackBoss.Zack-Pain-Uncle", 1);

	Clear(ltrashtalk);
	Addto(ltrashtalk,							"PL-Dialog.WednesdayZackBoss.Zack-Laugher1", 1);
	Addto(ltrashtalk,							"PL-Dialog.WednesdayZackBoss.Zack-Laugher2", 1);
	Addto(ltrashtalk,							"PL-Dialog.WednesdayZackBoss.Zack-Laugher3", 1);
	Addto(ltrashtalk,							"PL-Dialog.WednesdayZackBoss.Zack-Roar1", 1);
	Addto(ltrashtalk,							"PL-Dialog.WednesdayZackBoss.Zack-Roar2", 1);
	Addto(ltrashtalk,							"PL-Dialog.WednesdayZackBoss.Zack-Taunts-ComeOnCryBaby", 1);
	Addto(ltrashtalk,							"PL-Dialog.WednesdayZackBoss.Zack-Taunts-CryForMe", 1);
	Addto(ltrashtalk,							"PL-Dialog.WednesdayZackBoss.Zack-Taunts-CryForMe2", 1);
	Addto(ltrashtalk,							"PL-Dialog.WednesdayZackBoss.Zack-Taunts-SayUncle1", 1);
	Addto(ltrashtalk,							"PL-Dialog.WednesdayZackBoss.Zack-Taunts-SayUncle2", 1);
	Addto(ltrashtalk,							"PL-Dialog.WednesdayZackBoss.Zack-Taunts-YouGonnaCryNow", 1);

	Clear(lWhileFighting);
	Addto(lWhileFighting,							"PL-Dialog.WednesdayZackBoss.Zack-Laugher1", 1);
	Addto(lWhileFighting,							"PL-Dialog.WednesdayZackBoss.Zack-Laugher2", 1);
	Addto(lWhileFighting,							"PL-Dialog.WednesdayZackBoss.Zack-Laugher3", 1);
	Addto(lWhileFighting,							"PL-Dialog.WednesdayZackBoss.Zack-Roar1", 1);
	Addto(lWhileFighting,							"PL-Dialog.WednesdayZackBoss.Zack-Roar2", 1);
	Addto(lWhileFighting,							"PL-Dialog.WednesdayZackBoss.Zack-Taunts-ComeOnCryBaby", 1);
	Addto(lWhileFighting,							"PL-Dialog.WednesdayZackBoss.Zack-Taunts-CryForMe", 1);
	Addto(lWhileFighting,							"PL-Dialog.WednesdayZackBoss.Zack-Taunts-CryForMe2", 1);
	Addto(lWhileFighting,							"PL-Dialog.WednesdayZackBoss.Zack-Taunts-SayUncle1", 1);
	Addto(lWhileFighting,							"PL-Dialog.WednesdayZackBoss.Zack-Taunts-SayUncle2", 1);
	Addto(lWhileFighting,							"PL-Dialog.WednesdayZackBoss.Zack-Taunts-YouGonnaCryNow", 1);
	
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
	Addto(lAfterEating,							"WMaleDialog.wm_ohyeahthattookayear", 1);
	Addto(lAfterEating,							"WMaleDialog.wm_hardtobelievethat", 1);
	Addto(lAfterEating,							"WMaleDialog.wm_heythatwasactually", 1);
	Addto(lAfterEating,							"WMaleDialog.wm_goodgodwhatwasin", 1);
	Addto(lAfterEating,							"WMaleDialog.wm_burp", 1);

	Clear(lpleasureresponse);					
	Addto(lpleasureresponse,					"WMaleDialog.wm_satisfiedsigh", 1);

	Clear(laftersitdown);
	Addto(laftersitdown,						"WMaleDialog.wm_satisfiedsigh", 1);

	Clear(lSpitting);
	Addto(lSpitting,							"WMaleDialog.wm_shortingspitting", 1);
	Addto(lSpitting,							"WMaleDialog.wm_spitting", 1);
	
	Clear(lhmm);
	Addto(lhmm,									"WMaleDialog.wm_hmmmm", 1);

	Clear(lbodyfunctions);
	Addto(lbodyfunctions,						"WMaleDialog.wm_vomit", 1);

	Clear(lGettingShocked);
	Addto(lGettingShocked,						"WMaleDialog.wm_vomit", 1);

	// This sounds so much like a girl, the Kumquat wives (of Habib's) use this too
	Clear(lBattleCry);
	Addto(lBattleCry,							"HabibDialog.habib_ailili", 1);

	Clear(ldudedead);
	Addto(ldudedead,							"PL-Dialog.WednesdayZackBoss.Zack-Victory-DifferenceBetweenADuck", 1);
	Addto(ldudedead,							"PL-Dialog.WednesdayZackBoss.Zack-Victory-ShouldHaveSaidUncle", 1);
	Addto(ldudedead,							"PL-Dialog.WednesdayZackBoss.Zack-Victory-SuchAnAnnoyingVoice", 1);
	Addto(ldudedead,							"PL-Dialog.WednesdayZackBoss.Zack-Victory-SuchAnAnnoyingVoice2", 1);

	Clear(lKickDead);
	Addto(lKickDead,							"PL-Dialog.WednesdayZackBoss.Zack-Grenade-HereCatch", 1);
	Addto(lKickDead,							"PL-Dialog.WednesdayZackBoss.Zack-Grenade-HereCatch2", 1);
	Addto(lKickDead,							"PL-Dialog.WednesdayZackBoss.Zack-Grenade-IveGottaPresentForYa1", 1);
	Addto(lKickDead,							"PL-Dialog.WednesdayZackBoss.Zack-Grenade-IveGottaPresentForYa2", 1);
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
