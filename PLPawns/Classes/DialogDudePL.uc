///////////////////////////////////////////////////////////////////////////////
// DialogDudePL
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Dude dialog for PL
///////////////////////////////////////////////////////////////////////////////
class DialogDudePL extends DialogDude;

///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
{
	// Let super go first
	Super.FillInLines();
	
	Clear(lGreeting);
	AddTo(lGreeting,							"PL-Dialog.Misc.Dude-Hi", 1);
	AddTo(lGreeting,							"PL-Dialog.Misc.Dude-HiThere", 1);
	AddTo(lGreeting,							"PL-Dialog.Misc.Dude-Salutations", 1);
	

	// Photo weapon
	Clear(lPhoto_Dude1);
	AddTo(lPhoto_Dude1,							"PL-Dialog.MondayA.Dude-LostDog1b", 1);
	AddTo(lPhoto_Dude1,							"PL-Dialog.MondayA.Dude-LostDog1", 1);

	Clear(lPhoto_Dude2);
	AddTo(lPhoto_Dude2,							"PL-Dialog.MondayA.Dude-LostDog2b", 1);
	AddTo(lPhoto_Dude2,							"PL-Dialog.MondayA.Dude-LostDog2", 1);

	Clear(lPhoto_Dude3);
	AddTo(lPhoto_Dude3,							"PL-Dialog.MondayA.Dude-LostDog3b", 1);
	AddTo(lPhoto_Dude3,							"PL-Dialog.MondayA.Dude-LostDog3", 1);

	Clear(lPhoto_Dude4);
	AddTo(lPhoto_Dude4,							"PL-Dialog.MondayA.Dude-LostDog4b", 1);
	AddTo(lPhoto_Dude4,							"PL-Dialog.MondayA.Dude-LostDog4", 1);

	Clear(lPhoto_Dude5);
	AddTo(lPhoto_Dude5,							"PL-Dialog.MondayA.Dude-LostDog5b", 1);
	AddTo(lPhoto_Dude5,							"PL-Dialog.MondayA.Dude-LostDog5", 1);

	Clear(lPhoto_Dude6);
	AddTo(lPhoto_Dude6,							"PL-Dialog.MondayA.Dude-LostDog6b", 1);
	AddTo(lPhoto_Dude6,							"PL-Dialog.MondayA.Dude-LostDog6", 1);

	Clear(lPhoto_Dude7);
	AddTo(lPhoto_Dude7,							"PL-Dialog.MondayA.Dude-LostDog7b", 1);
	AddTo(lPhoto_Dude7,							"PL-Dialog.MondayA.Dude-LostDog7", 1);

	Clear(lPhoto_Dude8);
	AddTo(lPhoto_Dude8,							"PL-Dialog.MondayA.Dude-LostDog8b", 1);
	AddTo(lPhoto_Dude8,							"PL-Dialog.MondayA.Dude-LostDog8", 1);
	
	// Photo weapon Dude reactions to fleeing bystanders
	Clear(lPhoto_DudeReact1);
	AddTo(lPhoto_DudeReact1,					"PL-Dialog.MondayA.Dude-DogReaction1", 1);

	Clear(lPhoto_DudeReact2);
	AddTo(lPhoto_DudeReact2,					"PL-Dialog.MondayA.Dude-DogReaction2", 1);

	Clear(lPhoto_DudeReact3);
	AddTo(lPhoto_DudeReact3,					"PL-Dialog.MondayA.Dude-DogReaction3", 1);

	Clear(lPhoto_DudeReact4);
	AddTo(lPhoto_DudeReact4,					"PL-Dialog.MondayA.Dude-DogReaction4", 1);

	Clear(lPhoto_DudeReact5);
	AddTo(lPhoto_DudeReact5,					"PL-Dialog.MondayA.Dude-DogReaction5", 1);

	Clear(lPhoto_DudeReact6);
	AddTo(lPhoto_DudeReact6,					"PL-Dialog.MondayA.Dude-DogReaction7", 1);

	Clear(lPhoto_DudeReact7);
	AddTo(lPhoto_DudeReact7,					"PL-Dialog.MondayA.Dude-DogReaction9", 1);
	
	// Photo weapon Dude suggests asking someone else
	Clear(lPhoto_DudeAskSomeoneElse);
	Addto(lPhoto_DudeAskSomeoneElse, 			"PL-Dialog.MondayA.Dude-DogReaction6", 1);
	AddTo(lPhoto_DudeAskSomeoneElse,			"PL-Dialog.MondayA.Dude-DogReaction8", 1);	
	
	// Fuck You hands dialog
	Clear(lDude_FuckYou);
	AddTo(lDude_FuckYou,						"PL-Dialog.Misc.Dude-FuckYou01", 1);
	AddTo(lDude_FuckYou,						"PL-Dialog.Misc.Dude-FuckYou02", 1);
	AddTo(lDude_FuckYou,						"PL-Dialog.Misc.Dude-FuckYou03", 1);
	AddTo(lDude_FuckYou,						"PL-Dialog.Misc.Dude-FuckYou04", 1);
	AddTo(lDude_FuckYou,						"PL-Dialog2.Dude-AdditionalLines2.Dude-FuckOff", 1);
	AddTo(lDude_FuckYou,						"PL-Dialog2.Dude-AdditionalLines2.Dude-FuckYouBuddy", 1);
	AddTo(lDude_FuckYou,						"PL-Dialog2.Dude-AdditionalLines2.Dude-FuckYouPal", 1);
	AddTo(lDude_FuckYou,						"PL-Dialog2.Dude-AdditionalLines2.Dude-GoFuckYourself", 1);
	
	// Collection can
	Clear(lDude_Can1);
	AddTo(lDude_Can1,							"PL-Dialog.WednesdayA.Dude-2GenerousDonation", 1);
	AddTo(lDude_Can1,							"PL-Dialog.WednesdayA.Dude-2HowAboutAnOffering", 1);
	AddTo(lDude_Can1,							"PL-Dialog.WednesdayA.Dude-2SpareSomeCash", 1);
	AddTo(lDude_Can1,							"PL-Dialog.WednesdayA.Dude-2WantToChipIn", 1);

	Clear(lDude_Can2);	
	AddTo(lDude_Can2,							"PL-Dialog.WednesdayA.Dude-3DonateToMyCharity", 1);
	AddTo(lDude_Can2,							"PL-Dialog.WednesdayA.Dude-3LookIntoYourHeart", 1);
	AddTo(lDude_Can2,							"PL-Dialog.WednesdayA.Dude-3MaybeIllStopBothering", 1);
	AddTo(lDude_Can2,							"PL-Dialog.WednesdayA.Dude-3UnwantedCash", 1);

	Clear(lDude_Can3);	
	AddTo(lDude_Can3,							"PL-Dialog.WednesdayA.Dude-4DonateSomeMoney", 1);
	AddTo(lDude_Can3,							"PL-Dialog.WednesdayA.Dude-4HandOverSomeCash", 1);
	AddTo(lDude_Can3,							"PL-Dialog.WednesdayA.Dude-4HeresTheDeal", 1);
	AddTo(lDude_Can3,							"PL-Dialog.WednesdayA.Dude-4ShowSomeGenerosity", 1);
	
	Clear(lDude_CanReceived1);
	AddTo(lDude_CanReceived1,					"PL-Dialog.WednesdayA.Dude-5WhatTheHell", 1);
	
	Clear(lDude_CanReceived2);
	AddTo(lDude_CanReceived2,					"PL-Dialog.WednesdayA.Dude-5StillNextToNothing", 1);

	Clear(lDude_CanReceived3);
	AddTo(lDude_CanReceived3,					"PL-Dialog.WednesdayA.Dude-5ThanksALotCheapskate", 1);

	Clear(lDude_CanReceived4);
	AddTo(lDude_CanReceived4,					"PL-Dialog.WednesdayA.Dude-5AnotherStingyDonation", 1);

	Clear(lDude_CanReceived5);
	AddTo(lDude_CanReceived5,					"PL-Dialog.WednesdayA.CoreyDude-2HeyEinstein", 1);
	lDude_CanReceived5.bCoreyLine = true;

	Clear(lDude_CanReceived6);
	AddTo(lDude_CanReceived6,					"PL-Dialog.WednesdayA.CoreyDude-2PlanIsntWorkingAce", 1);
	lDude_CanReceived6.bCoreyLine = true;

	Clear(lDude_CanReceived7);
	AddTo(lDude_CanReceived7,					"PL-Dialog.WednesdayA.CoreyDude-2NotGettingThrough", 1);
	lDude_CanReceived7.bCoreyLine = true;

	Clear(lDude_CanReceived_SeeZack1);
	AddTo(lDude_CanReceived_SeeZack1,			"PL-Dialog.WednesdayA.Dude-6IThinkThatVoice", 1);

	Clear(lDude_CanReceived_SeeZack2);
	AddTo(lDude_CanReceived_SeeZack2,			"PL-Dialog.WednesdayA.Dude-8ClearlyThesePeople", 1);
	AddTo(lDude_CanReceived_SeeZack2,			"PL-Dialog.WednesdayA.Dude-8StillWastingTime", 1);
	AddTo(lDude_CanReceived_SeeZack2,			"PL-Dialog.WednesdayA.Dude-8StopNaggingMyself", 1);
	AddTo(lDude_CanReceived_SeeZack2,			"PL-Dialog.WednesdayA.Dude-8ThisIsHopeless", 1);
	
	// Wipe House
	Clear(lDude_WipeHouse);
	AddTo(lDude_WipeHouse,						"PL-Dialog.TuesdayA.CoreyDude-RollOfAssWipes", 1);
	lDude_WipeHouse.bCoreyLine = true;
	
	// CCCP
	Clear(lCCCP_CoreyDude_Ostriches);
	AddTo(lCCCP_CoreyDude_Ostriches, "PL-Dialog.MondayB.CoreyDude-SearchingOstriches", 1);
	lCCCP_CoreyDude_Ostriches.bCoreyLine = true;

	Clear(lCCCP_Dude_LostDog);
	AddTo(lCCCP_Dude_LostDog, "PL-Dialog.MondayB.Dude-SearchingForLostDog", 1);
	
	// Yeeland's Arcade
	Clear(lArcade_Dude_DeliverGame);
	AddTo(lArcade_Dude_DeliverGame, "PL-Dialog.TuesdayB.Dude-1HereToNewGame", 1);
	
	Clear(lArcade_CoreyDude_MoralGrounds);
	AddTo(lArcade_CoreyDude_MoralGrounds, "PL-Dialog.TuesdayB.CoreyDude-1YouBetterAccept", 1);
	lArcade_CoreyDude_MoralGrounds.bCoreyLine = true;
	
	// Cow Milking
	Clear(lDude_CowMilking_Empty);
	AddTo(lDude_CowMilking_Empty, "PL-Dialog.WednesdayB.Dude-BessysAllMilkedOut", 1);
	AddTo(lDude_CowMilking_Empty, "PL-Dialog.WednesdayB.Dude-CantSqueezeAnyMore", 1);
	AddTo(lDude_CowMilking_Empty, "PL-Dialog.WednesdayB.Dude-GivenAllShesGot", 1);
	AddTo(lDude_CowMilking_Empty, "PL-Dialog.WednesdayB.Dude-ThisOnesDry", 1);
	AddTo(lDude_CowMilking_Empty, "PL-Dialog.WednesdayB.Dude-ThisOnesEmpty", 1);
	
	// Chemical Errand
	Clear(lDude_WantsChems);
	AddTo(lDude_WantsChems, "PL-Dialog2.ThursdayErrandA.Dude-1MarketForChemicals", 1);
	Clear(lDude_FinallyBuy);
	AddTo(lDude_FinallyBuy, "PL-Dialog2.ThursdayErrandA.Dude-2FinallyBuyChemicals", 1);
	Clear(lDude_ThatsOutrageous);
	AddTo(lDude_ThatsOutrageous, "PL-Dialog2.ThursdayErrandA.Dude-3GottaBeFuckingKidding", 1);
	
	// Blasting Cap errand
	Clear(lDude_WantsBlastingCap);
	AddTo(lDude_WantsBlastingCap, "PL-Dialog2.FridayErrandB.Dude-2BlastingCapsForSale", 1);
	
	// Dual Wielding
	Clear(lDude_BeginDualWielding);
	AddTo(lDude_BeginDualWielding, "PL-Dialog2.DudeDualWielding.Dude-DoubleTheGun", 1);
	AddTo(lDude_BeginDualWielding, "PL-Dialog2.DudeDualWielding.Dude-OneGunIsntEnough", 1);
	AddTo(lDude_BeginDualWielding, "PL-Dialog2.DudeDualWielding.Dude-OneInEachHand", 1);
	AddTo(lDude_BeginDualWielding, "PL-Dialog2.DudeDualWielding.Dude-TwiceTheLove", 1);
	
	// Champ fight
	Clear(lDude_ShouldUseCure);
	AddTo(lDude_ShouldUseCure, "PL-Dialog2.FridayShowdownChampBoss.Dude-5BetterUseThisCure", 1);
	AddTo(lDude_ShouldUseCure, "PL-Dialog2.FridayShowdownChampBoss.Dude-5GottaUseCureNow", 1);
	AddTo(lDude_ShouldUseCure, "PL-Dialog2.FridayShowdownChampBoss.Dude-5HesDown", 1);
	AddTo(lDude_ShouldUseCure, "PL-Dialog2.FridayShowdownChampBoss.Dude-5UseCureWhileICan", 1);
	
	// Uncle Dave Radio
	Clear(lDude_UncleDaveRadio_Received);
	AddTo(lDude_UncleDaveRadio_Received, "PL-Dialog2.Dude-AdditionalLines2.Dude-UseThisRadio", 1);
	Clear(lDude_UncleDaveRadio_AllClear);
	AddTo(lDude_UncleDaveRadio_AllClear, "PL-Dialog2.Dude-AdditionalLines2.Dude-AllClearUncleDave", 1);
	AddTo(lDude_UncleDaveRadio_AllClear, "PL-Dialog2.Dude-AdditionalLines2.Dude-AOKUncleDave", 1);
	AddTo(lDude_UncleDaveRadio_AllClear, "PL-Dialog2.Dude-AdditionalLines2.Dude-GoingJustDandy", 1);
	AddTo(lDude_UncleDaveRadio_AllClear, "PL-Dialog2.Dude-AdditionalLines2.Dude-NoProblemsToReport", 1);
	Clear(lDude_UncleDaveRadio_FollowMe);
	AddTo(lDude_UncleDaveRadio_FollowMe, "PL-Dialog2.Dude-AdditionalLines2.Dude-FollowMe", 1);
	AddTo(lDude_UncleDaveRadio_FollowMe, "PL-Dialog2.Dude-AdditionalLines2.Dude-FollowMeUncleDave", 1);
	AddTo(lDude_UncleDaveRadio_FollowMe, "PL-Dialog2.Dude-AdditionalLines2.Dude-GetYourAssOverHere", 1);
	AddTo(lDude_UncleDaveRadio_FollowMe, "PL-Dialog2.Dude-AdditionalLines2.Dude-NeedYourHelp", 1);
	AddTo(lDude_UncleDaveRadio_FollowMe, "PL-Dialog2.Dude-AdditionalLines2.Dude-GetMoving", 1);
	Clear(lDude_UncleDaveRadio_StayHere);
	AddTo(lDude_UncleDaveRadio_StayHere, "PL-Dialog2.Dude-AdditionalLines2.Dude-StayThere", 1);
	AddTo(lDude_UncleDaveRadio_StayHere, "PL-Dialog2.Dude-AdditionalLines2.Dude-StayThereUncleDave", 1);
	AddTo(lDude_UncleDaveRadio_StayHere, "PL-Dialog2.Dude-AdditionalLines2.Dude-WaitRightThere", 1);
	AddTo(lDude_UncleDaveRadio_StayHere, "PL-Dialog2.Dude-AdditionalLines2.Dude-HoldItRightThere", 1);
	AddTo(lDude_UncleDaveRadio_StayHere, "PL-Dialog2.Dude-AdditionalLines2.Dude-CoverThatSpot", 1);
	
	// Lawman disguise
	Clear(lDude_NowIsCop);
	AddTo(lDude_NowIsCop,							"PL-Dialog2.Dude-AdditionalLines2.Dude-HiHoSilver", 1);
	AddTo(lDude_NowIsCop,							"PL-Dialog2.Dude-AdditionalLines2.Dude-WhipThisOut", 1);
	AddTo(lDude_NowIsCop,							"PL-Dialog2.Dude-AdditionalLines2.Dude-HighNoon", 1);
	AddTo(lDude_NowIsCop,							"PL-Dialog2.Dude-AdditionalLines2.Dude-SnakeInMyBoot", 1);
	
	Clear(lDude_AttackAsCop);
	AddTo(lDude_AttackAsCop,						"PL-Dialog2.Dude-AdditionalLines2.Dude-GetAlongLilDoggie", 1);
	AddTo(lDude_AttackAsCop,						"PL-Dialog2.Dude-AdditionalLines2.Dude-RollingRollingRolling", 1);
	AddTo(lDude_AttackAsCop,						"PL-Dialog2.Dude-AdditionalLines2.Dude-HangEmUp", 1);
	AddTo(lDude_AttackAsCop,						"PL-Dialog2.Dude-AdditionalLines2.Dude-SorryTherePartner", 1);
	AddTo(lDude_AttackAsCop,						"PL-Dialog2.Dude-AdditionalLines2.Dude-MoveAlong", 1);

}
