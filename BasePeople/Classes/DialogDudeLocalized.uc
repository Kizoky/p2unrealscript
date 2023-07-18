///////////////////////////////////////////////////////////////////////////////
// DialogDudeLocalized
// Added by Man Chrzan: xPatch 2.0
//
// Dialog for Dude in localized game versions
// (removed 2013 dialogs) 
//
///////////////////////////////////////////////////////////////////////////////
class DialogDudeLocalized extends DialogDude;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	Clear(lGreeting);
	AddTo(lGreeting,								"DudeDialog.dude_hithere", 1);
	
	Clear(lRespondToGreeting);
	AddTo(lRespondToGreeting,						"DudeDialog.dude_hi", 1);

	Clear(lYes);
	AddTo(lYes,										"DudeDialog.dude_yes", 1);

	Clear(lNo);
	AddTo(lNo,										"DudeDialog.dude_no", 1);

	Clear(lThanks);
	AddTo(lThanks,										"DudeDialog.dude_thanks2", 1);

	Clear(lDude_Arrested);
	AddTo(lDude_Arrested,							"DudeDialog.dude_okaytakemein", 1);
	AddTo(lDude_Arrested,							"DudeDialog.dude_yeahblahjustcuff", 1);
	AddTo(lDude_Arrested,							"DudeDialog.dude_ihavefaithinsys", 1);
	AddTo(lDude_Arrested,							"DudeDialog.dude_ineededavacation", 1);
	AddTo(lDude_Arrested,							"DudeDialog.dude_cmonhurryup", 1);
	AddTo(lDude_Arrested,							"DudeDialog.dude_heyitsnotmyfault", 1);

	Clear(lDude_EscapeJail);
	AddTo(lDude_EscapeJail,							"DudeDialog.dude_ahjail", 1);
	AddTo(lDude_EscapeJail,							"DudeDialog.dude_imboredalready", 1);
	AddTo(lDude_EscapeJail,							"DudeDialog.dude_nojailcanholdme", 1);
//	AddTo(lDude_EscapeJail,							"DudeDialog.dude_ohlooktheyleft", 1); Makes no sense
//	AddTo(lDude_EscapeJail,							"DudeDialog.dude_heytheyleftthe", 1);
//	AddTo(lDude_EscapeJail,							"DudeDialog.dude_illbetthatdooris", 1);
	AddTo(lDude_EscapeJail,							"DudeDialog.dude_maybeishouldtry", 1);

	Clear(lDude_JailHint);
	AddTo(lDude_JailHint,							"DudeDialog.dude_ohlookistill", 1);

//	Clear(lDude_BecomeCop1);
//	AddTo(lDude_BecomeCop1,							"DudeDialog.dude_saywhatsthis", 1);

	Clear(lDude_BecomingCop);
	AddTo(lDude_BecomingCop,						"DudeDialog.dude_thisisgonnabe", 1);

	Clear(lDude_NowIsCop);
	AddTo(lDude_NowIsCop,							"DudeDialog.dude_iamthelaw", 1);

	Clear(lDude_NowIsDude);
	AddTo(lDude_NowIsDude,							"DudeDialog.dude_gunsdontkill", 1);

	Clear(lDude_AttackAsCop);
	AddTo(lDude_AttackAsCop,							"DudeDialog.dude_nothingtoseehere", 1);
	AddTo(lDude_AttackAsCop,							"DudeDialog.dude_movealong", 1);
	AddTo(lDude_AttackAsCop,							"DudeDialog.dude_geeisurehope", 1);
	AddTo(lDude_AttackAsCop,							"DudeDialog.dude_someonestolemy", 1);

	Clear(lDude_FirstSeenWithWeapon);
	Addto(lDude_FirstSeenWithWeapon,				"DudeDialog.dude_heyimJustexercise", 1);

	Clear(lDude_WeaponFirstUse);
	AddTo(lDude_WeaponFirstUse,						"DudeDialog.dude_sothatswhatthat", 1);
	AddTo(lDude_WeaponFirstUse,						"DudeDialog.dude_fascinating", 1);
	AddTo(lDude_WeaponFirstUse,						"DudeDialog.dude_ohigetit", 1);
	AddTo(lDude_WeaponFirstUse,						"DudeDialog.dude_yess", 1);
	AddTo(lDude_WeaponFirstUse,						"DudeDialog.dude_sweet", 1);
	AddTo(lDude_WeaponFirstUse,						"DudeDialog.dude_ohlikethatsnot", 1);
	AddTo(lDude_WeaponFirstUse,						"DudeDialog.dude_viagraworks", 1);

	Clear(lDude_ThrowGrenade);
	AddTo(lDude_ThrowGrenade,						"DudeDialog.dude_herecatch", 1);
	AddTo(lDude_ThrowGrenade,						"DudeDialog.dude_golong", 1);

	Clear(lDude_KillWithGun);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_gunsdontkill", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_mypresidentis", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_onlymyweapon", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_isupposeitwould", 1);
// This line needs to be when he just hurts someone, but we don't have enough of those, maybe?
//	AddTo(lDude_KillWithGun,						"DudeDialog.dude_imsorryimeantto", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_youprobablythink", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_andonetogrowon", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_dontcrowdtheres", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_todaysthefirst", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_howwouldyoulike", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_yougogirl", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_haveaniceday", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_damnhereiwas", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_youthoughtyou", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_thatstheone", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_iknowwhatyoure", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_yeahthatswhat", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_thisgenepoolis", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_hehhehheh", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_sorry", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_justkiddin", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_ohthatsgottahurt", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_thatsgoingto", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_buttsauce", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_imsoryapparently", 1);
//	AddTo(lDude_KillWithGun,						"DudeDialog.imprettygoodatthis", 1);
//	AddTo(lDude_KillWithGun,						"DudeDialog.Laughing", 1);
// xPatch 2.0 Unused Lines below:
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_heyimJustexercise", 1);
	AddTo(lDude_KillWithGun,						"DudeDialog.dude_videogamesdont", 1);

	Clear(lDude_KillWithProjectile);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_nicecatch", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_isupposeitwould", 1);
// This line needs to be when he just hurts someone, but we don't have enough of those, maybe?
//	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_imsorryimeantto", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_youprobablythink", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_andonetogrowon", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_dontcrowdtheres", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_todaysthefirst", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_howwouldyoulike", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_damnhereiwas", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_yougogirl", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_haveaniceday", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_youthoughtyou", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_thatstheone", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_iknowwhatyoure", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_yeahthatswhat", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_hehhehheh", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_sorry", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_justkiddin", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_ohthatsgottahurt", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_thatsgoingto", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_buttsauce", 1);
//	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_iseedeadpeople", 1);
//	AddTo(lDude_KillWithProjectile,					"DudeDialog.imprettygoodatthis", 1);
//	AddTo(lDude_KillWithProjectile,					"DudeDialog.Laughing", 1);
	// xPatch 2.0 Unused Lines below:
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_imsoryapparently", 1);
	AddTo(lDude_KillWithProjectile,					"DudeDialog.dude_nicecatch", 1);
	
	Clear(lDude_KillWithMelee);
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_isupposeitwould", 1);
// This line needs to be when he just hurts someone, but we don't have enough of those, maybe?
//	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_imsorryimeantto", 1);
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_youprobablythink", 1);
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_andonetogrowon", 1);
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_dontcrowdtheres", 1);
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_todaysthefirst", 1);
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_howwouldyoulike", 1);
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_damnhereiwas", 1);
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_yougogirl", 1);
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_haveaniceday", 1);
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_youthoughtyou", 1);
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_thatstheone", 1);
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_iknowwhatyoure", 1);
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_yeahthatswhat", 1);
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_hehhehheh", 1);
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_sorry", 1);
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_justkiddin", 1);
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_ohthatsgottahurt", 1);
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_thatsgoingto", 1);
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_buttsauce", 1);
//	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_iseedeadpeople", 1);
//	AddTo(lDude_KillWithMelee,						"DudeDialog.imprettygoodatthis", 1);
//	AddTo(lDude_KillWithMelee,						"DudeDialog.Laughing", 1);
	// xPatch 2.0 Unused Lines below:
	AddTo(lDude_KillWithMelee,						"DudeDialog.dude_videogamesdont", 1);

	Clear(lDude_QuickKills);
	AddTo(lDude_QuickKills,							"DudeDialog.dude_oneforyourmother", 1);
	AddTo(lDude_QuickKills,							"DudeDialog.dude_oneforthepope", 1);
	AddTo(lDude_QuickKills,							"DudeDialog.dude_oneforjohnny", 1);
	AddTo(lDude_QuickKills,							"DudeDialog.dude_oneforbebo", 1);
	AddTo(lDude_QuickKills,							"DudeDialog.dude_onecauseugly", 1);
	AddTo(lDude_QuickKills,							"DudeDialog.dude_onebecauseican", 1);
	AddTo(lDude_QuickKills,							"DudeDialog.dude_onebecauseihave", 1);

	Clear(lDude_QuickKills2);
//	AddTo(lDude_QuickKills2,						"DudeDialog.oohtheresanotherone", 1);
//	AddTo(lDude_QuickKills2,						"DudeDialog.oneformom", 1);
//	AddTo(lDude_QuickKills2,						"DudeDialog.oneforstevenhawking", 1);
//	AddTo(lDude_QuickKills2,						"DudeDialog.oneforjimmy", 1);
//	AddTo(lDude_QuickKills2,						"DudeDialog.oneforpresidenthilary", 1);
//	AddTo(lDude_QuickKills2,						"DudeDialog.oneforuncledad", 1);
	AddTo(lDude_QuickKills2,						"DudeDialog.dude_oneforyourmother", 1);
	AddTo(lDude_QuickKills2,						"DudeDialog.dude_oneforthepope", 1);
	AddTo(lDude_QuickKills2,						"DudeDialog.dude_oneforjohnny", 1);
	AddTo(lDude_QuickKills2,						"DudeDialog.dude_oneforbebo", 1);
	AddTo(lDude_QuickKills2,						"DudeDialog.dude_onecauseugly", 1);
	AddTo(lDude_QuickKills2,						"DudeDialog.dude_onebecauseican", 1);
	AddTo(lDude_QuickKills2,						"DudeDialog.dude_onebecauseihave", 1);
	
	// Dual Wield P2
//	DudeDialog.dude_viagraworks

	Clear(lDude_PlayerCheating);
	AddTo(lDude_PlayerCheating,						"DudeDialog.dude_yougogirl", 1);
	AddTo(lDude_PlayerCheating,						"DudeDialog.dude_youvegottabekid", 1);
	AddTo(lDude_PlayerCheating,						"DudeDialog.dude_buttsauce", 1);
	// xPatch 2.0 Unused Lines below:
	AddTo(lDude_PlayerCheating,						"DudeDialog.dude_saywhatsthis", 1);
	AddTo(lDude_PlayerCheating,						"DudeDialog.dude_didiaskforcheese", 1); 	


	Clear(lDude_PlayerSissy);
	AddTo(lDude_PlayerSissy,						"DudeDialog.dude_sissy", 1);

	Clear(lDude_ReusedPeople);
	AddTo(lDude_ReusedPeople,						"DudeDialog.dude_damndothesepeople", 1);
	AddTo(lDude_ReusedPeople,						"DudeDialog.dude_definitelysome", 1);
	AddTo(lDude_ReusedPeople,						"DudeDialog.dude_heylookitsuncle", 1);
	AddTo(lDude_ReusedPeople,						"DudeDialog.dude_holyshitimnot", 1);
	AddTo(lDude_ReusedPeople,						"DudeDialog.dude_thisgenepoolis", 1);
	AddTo(lDude_ReusedPeople,						"DudeDialog.dude_andjoebobsonof", 1);
	AddTo(lDude_ReusedPeople,						"DudeDialog.dude_grandfatherof", 1);
	AddTo(lDude_ReusedPeople,						"DudeDialog.dude_woulditbesafeto", 1);

	Clear(lDude_BurningPeople);
	AddTo(lDude_BurningPeople,						"DudeDialog.dude_saythatactually", 1);
	AddTo(lDude_BurningPeople,						"DudeDialog.dude_slowroastedgood", 1);
	AddTo(lDude_BurningPeople,						"DudeDialog.dude_smellslikechick", 1);
//	AddTo(lDude_BurningPeople,						"DudeDialog.sothatswhatthesmellslike", 1);

	Clear(lDude_ShootMinorities);
	AddTo(lDude_ShootMinorities,						"DudeDialog.dude_igotyeraffirm", 1);
	AddTo(lDude_ShootMinorities,						"DudeDialog.dude_pleasedontthink", 1);
	AddTo(lDude_ShootMinorities,						"DudeDialog.dude_imanequalopport", 1);
	AddTo(lDude_ShootMinorities,						"DudeDialog.dude_nowthatswhaticall", 1);
	// xPatch 2.0 Unused Lines below:
	AddTo(lDude_ShootMinorities,						"DudeDialog.dude_damndothesepeople", 1);


	Clear(lDude_ShootGays);
	AddTo(lDude_ShootGays,						"DudeDialog.dude_sorryfolksbible", 1);

	Clear(lDude_ShootOlds);
	AddTo(lDude_ShootOlds,						"DudeDialog.dude_justcallmedr", 1);
	AddTo(lDude_ShootOlds,						"DudeDialog.dude_rightaboutnow", 1);
	AddTo(lDude_ShootOlds,						"DudeDialog.dude_hehiknowyouve", 1);
	AddTo(lDude_ShootOlds,						"DudeDialog.dude_oohmedicareaint", 1);

	Clear(lDude_ShootBum);
	AddTo(lDude_ShootBum,						"DudeDialog.dude_nowthatswhaticall", 1);
	AddTo(lDude_ShootBum,						"DudeDialog.dude_heresyertaxrelief", 1);
	AddTo(lDude_ShootBum,						"DudeDialog.dude_heressomeleadfor", 1);

	Clear(lDude_DidSomethingCool);
	AddTo(lDude_DidSomethingCool,						"DudeDialog.dude_wellwhodathought", 1);
	AddTo(lDude_DidSomethingCool,						"DudeDialog.dude_thatsdefinitely", 1);
	AddTo(lDude_DidSomethingCool,						"DudeDialog.dude_geethatwasntso", 1);

	Clear(lPissing);
	AddTo(lPissing,						"DudeDialog.dude_ohyeah", 1);
	AddTo(lPissing,						"DudeDialog.dude_thatstheticket", 1);
	AddTo(lPissing,						"DudeDialog.dude_sigh", 1);
	AddTo(lPissing,						"DudeDialog.dude_nowtheflowers", 1);

	Clear(lPissOnSelf);
	AddTo(lPissOnSelf,						"DudeDialog.dude_pissingonself", 1);
	
	Clear(lPissOutFireOnSelf);
	AddTo(lPissOutFireOnSelf,				"DudeDialog.dude_thatstheticket", 1);
	AddTo(lPissOutFireOnSelf,				"DudeDialog.dude_ohyeah", 1);
	AddTo(lPissOutFireOnSelf,				"DudeDialog.dude_sigh", 1);
	
	Clear(lDude_SniperBreathing);
	AddTo(lDude_SniperBreathing,					"WeaponSounds.sniper_zoombreathing", 1);

	Clear(lDude_RetortToNameCalling);
	AddTo(lDude_RetortToNameCalling,				"DudeDialog.dude_howwouldyoulike", 1);

	Clear(lDude_LongLine);
	AddTo(lDude_LongLine,						"DudeDialog.dude_everyonesameidea", 1);
	AddTo(lDude_LongLine,						"DudeDialog.dude_quiteawait", 1);
	AddTo(lDude_LongLine,						"DudeDialog.dude_donttheyhavejobs", 1);
	AddTo(lDude_LongLine,						"DudeDialog.dude_lineinevitable", 1);
	AddTo(lDude_LongLine,						"DudeDialog.dude_lookslikemeeting", 1);

	Clear(lLackOfMoney);	
	AddTo(lLackOfMoney,						"DudeDialog.dude_hmmalloutofcash", 1);
	AddTo(lLackOfMoney,						"DudeDialog.dude_hmmalloutofcash2", 1);

	Clear(lDude_RandomLevel);
	AddTo(lDude_RandomLevel,						"DudeDialog.dude_ifeellikeillget", 1);
	AddTo(lDude_RandomLevel,						"DudeDialog.dude_nothingacoatof", 1);
	AddTo(lDude_RandomLevel,						"DudeDialog.dude_whoeverdesigned", 1);
	AddTo(lDude_RandomLevel,						"DudeDialog.dude_doesmyvoiceannoy", 1);
	AddTo(lDude_RandomLevel,						"DudeDialog.dude_noreallydoesthe", 1);
	AddTo(lDude_RandomLevel,						"DudeDialog.dude_ifthesheriff", 1);

	Clear(lDude_CantBeGood);
	AddTo(lDude_CantBeGood,						"DudeDialog.dude_wasthatsupposed", 1);
	AddTo(lDude_CantBeGood,						"DudeDialog.dude_youvegottabe", 1);
	AddTo(lDude_CantBeGood,						"DudeDialog.dude_thatsclearly", 1);
	AddTo(lDude_CantBeGood,						"DudeDialog.dude_thatcantbegood", 1);
	AddTo(lDude_CantBeGood,						"DudeDialog.dude_ididntexpectthat", 1);
	AddTo(lDude_CantBeGood,						"DudeDialog.dude_howconvenient", 1);

	Clear(lGotHitInCrotch);	
	AddTo(lGotHitInCrotch,						"DudeDialog.dude_ohmynads", 1);

	Clear(lGotHit);	
	AddTo(lGotHit,							"DudeDialog.dude_damnthatstings", 1);
	AddTo(lGotHit,							"DudeDialog.dude_owmyclavichord", 1);
	AddTo(lGotHit,							"DudeDialog.dude_ohrightinthestuff", 1);
	AddTo(lGotHit,							"DudeDialog.dude_ohthatcanthave", 1);
	AddTo(lGotHit,							"DudeDialog.dude_ohmommy", 1);
	AddTo(lGotHit,							"DudeDialog.dude_aughthatsgonnabe2", 1);
	AddTo(lGotHit,							"DudeDialog.dude_heynowicantfeel", 1);
	AddTo(lGotHit,							"DudeDialog.dude_ughnowmyspleens", 1);
	AddTo(lGotHit,							"DudeDialog.dude_owsothatswhatthat", 1);
	AddTo(lGotHit,							"DudeDialog.dude_excusemewhilei", 1);
// xPatch 2.0 Unused Lines below:
	AddTo(lGotHit,							"DudeDialog.dude_ohmyhead", 1);
	AddTo(lGotHit,							"DudeDialog.dude_alliwantedwas", 1);
	AddTo(lGotHit,							"DudeDialog.dude_ifthereweregun", 1);
	AddTo(lGotHit,							"DudeDialog.dude_cantwealljustget", 1);
	

	Clear(lGrunt);
	AddTo(lGrunt,						"DudeDialog.dude_oof", 1);
	AddTo(lGrunt,						"DudeDialog.dude_augh", 1);
	AddTo(lGrunt,						"DudeDialog.dude_augh2", 1);
	AddTo(lGrunt,						"DudeDialog.dude_ow", 1);
	AddTo(lGrunt,						"DudeDialog.dude_whuff", 1);
	AddTo(lGrunt,						"DudeDialog.dude_ak", 1);
	AddTo(lGrunt,						"DudeDialog.dude_augh3", 1);
//	AddTo(lGrunt,						"DudeDialog.oww", 1);
//	AddTo(lGrunt,						"DudeDialog.oww2", 1);

	Clear(lCussing);
	AddTo(lCussing,						"DudeDialog.dude_shit", 1);
//	AddTo(lCussing,						"DudeDialog.shit", 1);
	AddTo(lCussing,						"DudeDialog.dude_fuck", 1);

	Clear(lGetDown);
	AddTo(lGetDown,								"DudeDialog.dude_getdown", 1);
	AddTo(lGetDown,								"DudeDialog.dude_getdownifyoudont", 1);
	AddTo(lGetDown,								"DudeDialog.dude_getthefuckdown", 1);
												
	Clear(lGetDownMP);
	AddTo(lGetDownMP,							"DudeDialog.dude_getdown", 1);
	AddTo(lGetDownMP,							"DudeDialog.dude_getdownifyoudont", 1);
	AddTo(lGetDownMP,							"DudeDialog.dude_getthefuckdown", 1);
												
	Clear(lFollowMe);
	AddTo(lFollowMe,							"DudeDialog.dude_movealong", 1);
												
	Clear(lStayHere);
	Addto(lStayHere,							"DudeDialog.dude_getdown", 1);

	Clear(lDude_CloseEnough);
	AddTo(lDude_CloseEnough,						"DudeDialog.dude_closeenough", 1);

	Clear(lLastWords);
	AddTo(lLastWords,						"DudeDialog.dude_alliwantedwas", 1);
	AddTo(lLastWords,						"DudeDialog.dude_ifthereweregun", 1);
	AddTo(lLastWords,						"DudeDialog.dude_cantwealljustget", 1);
	
//	Clear(lDude_Suicide);
//	AddTo(lDude_Suicide,						"DudeDialog.dude_iregretnothing", 1);

	Clear(lDude_Arcade);	
	AddTo(lDude_Arcade,					"DudeDialog.dude_videogamesdont", 1);

//	Clear(lDude_Bum);	
//	AddTo(dude_itsyourluckyday,					"DudeDialog.dude_itsyourluckyday", 1);

	Clear(lDude_GottaBeKidding);	
	AddTo(lDude_GottaBeKidding,						"DudeDialog.dude_youvegottabekid", 1);
//	AddTo(lDude_GottaBeKidding,						"DudeDialog.yougottabefuckingkidding", 1);

	Clear(lNegativeResponse);	
	AddTo(lNegativeResponse,						"DudeDialog.dude_youvegottabekid", 1);
	AddTo(lNegativeResponse,						"DudeDialog.dude_fuckyou", 1);
	AddTo(lNegativeResponse,						"DudeDialog.dude_shutupmoron", 1);
	AddTo(lNegativeResponse,						"DudeDialog.dude_idontthinkso", 1);
	AddTo(lNegativeResponse,						"DudeDialog.dude_notachance", 1);
	AddTo(lNegativeResponse,						"DudeDialog.dude_idontthinkso2", 1);

	Clear(lPositiveResponse);
	AddTo(lPositiveResponse,						"DudeDialog.dude_sure", 1);
	AddTo(lPositiveResponse,						"DudeDialog.dude_ifyousayso", 1);
	//AddTo(lPositiveResponse,						"DudeDialog.dude_icanbuythat", 1);
	AddTo(lPositiveResponse,						"DudeDialog.dude_soundsreasonable", 1);
	AddTo(lPositiveResponse,						"DudeDialog.dude_okay", 1);

	Clear(lNegativeResponseCashier);	
	AddTo(lNegativeResponseCashier,					"DudeDialog.dude_youvegottabekid", 1);
	AddTo(lNegativeResponseCashier,					"DudeDialog.dude_fuckyou", 1);
	AddTo(lNegativeResponseCashier,					"DudeDialog.dude_shit", 1);

	Clear(lApologize);
	AddTo(lApologize,								"DudeDialog.dude_imsowrong", 1);
	AddTo(lApologize,								"DudeDialog.dude_imsorry", 1);
	AddTo(lApologize,								"DudeDialog.dude_oops", 1);
//	AddTo(lApologize,								"DudeDialog.oops", 1);
	AddTo(lApologize,								"DudeDialog.dude_mybad", 1);
//	AddTo(lApologize,								"DudeDialog.mybad", 1);
	AddTo(lApologize,								"DudeDialog.dude_thatwasbadofme", 1);

	Clear(lDude_GetFired);
	AddTo(lDude_GetFired,						"DudeDialog.dude_butijuststarted", 1);

	Clear(lDude_HaveToPee);
	AddTo(lDude_HaveToPee,						"DudeDialog.dude_ivegottatakea", 1);
	AddTo(lDude_HaveToPee,						"DudeDialog.dude_ivereallygotta", 1);
	AddTo(lDude_HaveToPee,						"DudeDialog.dude_ineedtotakeapiss", 1);
	AddTo(lDude_HaveToPee,						"DudeDialog.dude_imreallygonna", 1);

	Clear(lDude_HasDisease);
	AddTo(lDude_HasDisease,						"DudeDialog.dude_owoohthatcantbe", 1);
	AddTo(lDude_HasDisease,						"DudeDialog.dude_jeezbetterget", 1);

	Clear(lGotHealth);
	AddTo(lGotHealth,							"DudeDialog.dude_thatstuffreally", 1);
	AddTo(lGotHealth,							"DudeDialog.dude_ifeelbetter", 1);
	AddTo(lGotHealth,							"DudeDialog.dude_aahthatsthestuff", 1);
	AddTo(lGotHealth,							"DudeDialog.dude_idefinitelyneed", 1);
	AddTo(lGotHealth,							"DudeDialog.dude_igottafindmore", 1);

	Clear(lGotHealthFood);
	AddTo(lGotHealthFood,						"DudeDialog.dude_thatstuffreally", 1);
	AddTo(lGotHealthFood,						"DudeDialog.dude_ifeelbetter", 1);
	AddTo(lGotHealthFood,						"DudeDialog.dude_aahthatsthestuff", 1);
	AddTo(lGotHealthFood,						"DudeDialog.dude_idefinitelyneed", 1);
	AddTo(lGotHealthFood,						"DudeDialog.dude_igottafindmore", 1);

	Clear(lDude_CuredGonorrhea);
	AddTo(lDude_CuredGonorrhea,					"DudeDialog.dude_ifeelbetter", 1);

	Clear(lDude_SmokedCatnip);
	AddTo(lDude_SmokedCatnip,					"DudeDialog.dude_thewallsare", 1);
	AddTo(lDude_SmokedCatnip,					"DudeDialog.dude_yeahbabyiam", 1);
	AddTo(lDude_SmokedCatnip,					"DudeDialog.dude_innagadda", 1);
// xPatch 2.0 Unused Lines below:
	AddTo(lDude_SmokedCatnip,					"DudeDialog.dude_nowicanseemusic", 1);
	
	Clear(lGotCrackHealth);
	AddTo(lGotCrackHealth,					"DudeDialog.dude_healthcantbegood", 1);
	
	Clear(lDude_NeedMoreCrackHealth);
	AddTo(lDude_NeedMoreCrackHealth,			"DudeDialog.dude_stuffwasntgood", 1);
	AddTo(lDude_NeedMoreCrackHealth,			"DudeDialog.dude_gottastopsmoking", 1);
	AddTo(lDude_NeedMoreCrackHealth,			"DudeDialog.dude_idontfeelsogood", 1);
	AddTo(lDude_NeedMoreCrackHealth,			"DudeDialog.dude_ifeellikeshit", 1);

	Clear(lDude_GotHurtByCrack);	
	AddTo(lDude_GotHurtByCrack,					"DudeDialog.dude_coldturkey", 1);
	AddTo(lDude_GotHurtByCrack,					"DudeDialog.dude_healthpipemy", 1);
	AddTo(lDude_GotHurtByCrack,					"DudeDialog.dude_withdrawalisa", 1);

	Clear(lDude_LowHealth);
	AddTo(lDude_LowHealth,						"DudeDialog.dude_idontfeelsogood", 1);
	AddTo(lDude_LowHealth,						"DudeDialog.dude_ifeellikeshit", 1);
	AddTo(lDude_LowHealth,						"DudeDialog.dude_igottafindmore", 1);

	Clear(lDude_EnterHabibs);
	AddTo(lDude_EnterHabibs,						"DudeDialog.dude_whatsthataweful", 1);
	AddTo(lDude_EnterHabibs,						"DudeDialog.dude_didslaughtergoat", 1);
	AddTo(lDude_EnterHabibs,						"DudeDialog.dude_youjustknowtheres", 1);
	AddTo(lDude_EnterHabibs,						"DudeDialog.dude_areyousotring", 1);

	Clear(lDude_enterhabibstestes);
	Addto(lDude_enterhabibstestes,						"DudeDialog.dude_youjustknowtheres", 1);

	Clear(lDude_seeTestes);
	AddTo(lDude_seeTestes,						"DudeDialog.dude_iknewit", 1);

	Clear(lDude_CallForHabib);
	AddTo(lDude_CallForHabib,						"DudeDialog.dude_heyayatollah", 1);

	Clear(lDude_KillHabib);
	AddTo(lDude_KillHabib,						"DudeDialog.dude_welliguessidont", 1);
	
	Clear(lDude_DropOffBook);
	AddTo(lDude_DropOffBook,						"DudeDialog.dude_wonderwherethebox", 1);
	AddTo(lDude_DropOffBook,						"DudeDialog.dude_stupidbook", 1);
	
	Clear(lDude_CashingPaycheck);
	AddTo(lDude_CashingPaycheck,						"DudeDialog.dude_idliketocash", 1);

	Clear(lDude_KillBankTeller);	
	AddTo(lDude_KillBankTeller,						"DudeDialog.dude_whowillcash", 1);
	
	Clear(lDude_RobbersShowUp);
	AddTo(lDude_RobbersShowUp,						"DudeDialog.dude_nowmydayis", 1);
	
	Clear(lDude_EmptyVault);
	AddTo(lDude_EmptyVault,						"DudeDialog.dude_whydoesthisnot", 1);

	Clear(lDude_DayChallenge);
	AddTo(lDude_DayChallenge,						"DudeDialog.dude_bettergethome", 1);
	AddTo(lDude_DayChallenge,						"DudeDialog.dude_bettergetoutta", 1);
	
	Clear(lDude_NeedsItem);
	AddTo(lDude_NeedsItem,						"DudeDialog.dude_ithinkineedthat", 1);
	AddTo(lDude_NeedsItem,						"DudeDialog.dude_maybeishouldkeep", 1);

	Clear(lDude_KillLibrary);
	AddTo(lDude_KillLibrary,						"DudeDialog.dude_findthedropbox", 1);

	Clear(lDude_Petition1);	
	AddTo(lDude_Petition1,							"DudeDialog.dude_petition1a", 1);
	AddTo(lDude_Petition1,							"DudeDialog.dude_petition1b", 1);

	Clear(lDude_Petition2);	
	AddTo(lDude_Petition2,							"DudeDialog.dude_petition2a", 1);
	AddTo(lDude_Petition2,							"DudeDialog.dude_petition2b", 1);

	Clear(lDude_Petition3);	
	AddTo(lDude_Petition3,							"DudeDialog.dude_petition3a", 1);
	AddTo(lDude_Petition3,							"DudeDialog.dude_petition3b", 1);

	Clear(lDude_CollectBalk);	
	AddTo(lDude_CollectBalk,						"DudeDialog.dude_shit", 1);
//	AddTo(lDude_CollectBalk,						"DudeDialog.dude_fuck", 1);
	AddTo(lDude_CollectBalk,						"DudeDialog.dude_youvegottabekid", 1);

	Clear(lDude_GaryTalk1);	
	AddTo(lDude_GaryTalk1,						"DudeDialog.dude_hellomrcoleman", 1);
	
	Clear(lDude_GaryTalk2);	
	AddTo(lDude_GaryTalk2,						"DudeDialog.dude_itsformymother", 1);
	
	Clear(lDude_GaryBullhorn);	
	AddTo(lDude_GaryBullhorn,						"DudeDialog.dude_icanrelatebro", 1);
	
	Clear(lDude_KillGary);	
	AddTo(lDude_KillGary,						"DudeDialog.dude_shit", 1);

	Clear(lDude_ConfessSins);	
	AddTo(lDude_ConfessSins,					"DudeDialog.dude_blessmefather", 1);

	Clear(lDude_GetNormalClothes);	
	AddTo(lDude_GetNormalClothes,					"DudeDialog.dude_getnormalclothes", 1);

	Clear(lDude_BuySteaks);	
//	AddTo(lDude_BuySteaks,						"DudeDialog.dude_needsomesteaks", 1);

	Clear(lDude_KillReception);	
	AddTo(lDude_KillReception,					"DudeDialog.dude_thatwasimpetuous", 1);

	Clear(lDude_FindSteaks);	
	AddTo(lDude_FindSteaks,						"DudeDialog.dude_thesebetterbefine", 1);

	Clear(lDude_GiveToUncleDave);
	AddTo(lDude_GiveToUncleDave,				"DudeDialog.dude_hereuncledave", 1);

	Clear(lDude_PayTraffic);
	AddTo(lDude_PayTraffic,						"DudeDialog.dude_paytrafficticket", 1);

	Clear(lDude_PayTraffic2);
	AddTo(lDude_PayTraffic2,					"DudeDialog.dude_carsareprops", 1);

	Clear(lDude_BuyNapalm);	
	AddTo(lDude_BuyNapalm,						"DudeDialog.dude_ineedsomenapalm", 1);

	Clear(lDude_KillNapalm);	
	AddTo(lDude_KillNapalm,						"DudeDialog.dude_whereisnapalm", 1);

	Clear(lDude_FindNapalm);	
	AddTo(lDude_FindNapalm,						"DudeDialog.dude_partywithnapalm", 1);

	Clear(lDude_FreeHealth);	
	AddTo(lDude_FreeHealth,						"DudeDialog.dude_imexperiencinga", 1);

	Clear(lDude_CureSelf);	
	AddTo(lDude_CureSelf,						"DudeDialog.dude_nowimgoingto", 1);

	Clear(lDude_BuyAlternator);	
	AddTo(lDude_BuyAlternator,					"DudeDialog.dude_heychicoineedan", 1);

	Clear(lDude_GetPackage);	
	AddTo(lDude_GetPackage,						"DudeDialog.dude_hereforpackage", 1);

	Clear(lDude_TalkToKrotchy);	
	AddTo(lDude_TalkToKrotchy,					"DudeDialog.dude_heymascotineeda", 1);

	Clear(lDude_NoKrotchy);	
	AddTo(lDude_NoKrotchy,						"DudeDialog.dude_crapsoldout", 1);

	Clear(lDude_KillKrotchy);	
	AddTo(lDude_KillKrotchy,					"DudeDialog.dude_nowimgonnahaveto", 1);

	Clear(lDude_FindToy);	
	AddTo(lDude_FindToy,						"DudeDialog.dude_wonderhowmuchon", 1);

	Clear(lDude_BribeKrotchyMoney);	
	AddTo(lDude_BribeKrotchyMoney,				"DudeDialog.dude_lookwebothknow", 1);

	Clear(lDude_BribeKrotchyBook);	
	AddTo(lDude_BribeKrotchyBook,				"DudeDialog.dude_howsthissound", 1);

	Clear(lDude_SaveTooMuch);
	AddTo(lDude_SaveTooMuch,					"DudeDialog.dude_areyousaving", 1);
	AddTo(lDude_SaveTooMuch,					"DudeDialog.dude_mygrandmothercould", 1);
	AddTo(lDude_SaveTooMuch,					"DudeDialog.dude_didntyoujustsave", 1);
	
	Clear(lDude_AchievementProgress);
	AddTo(lDude_AchievementProgress,			"DudeDialog.dude_ohigetit", 1);
	AddTo(lDude_AchievementProgress,			"DudeDialog.dude_saywhatsthis", 1);
	AddTo(lDude_AchievementProgress,			"DudeDialog.dude_thisisgonnabe", 1);
	
	Clear(lDude_AchievementUnlocked);
	AddTo(lDude_AchievementUnlocked,			"DudeDialog.dude_fascinating", 1);
	AddTo(lDude_AchievementUnlocked,			"DudeDialog.dude_hehhehheh", 1);
	AddTo(lDude_AchievementUnlocked,			"DudeDialog.dude_ididntexpectthat", 1);
	AddTo(lDude_AchievementUnlocked,			"DudeDialog.dude_iknowwhatyoure", 1);
	AddTo(lDude_AchievementUnlocked,			"DudeDialog.dude_yess", 1);
	AddTo(lDude_AchievementUnlocked,			"DudeDialog.dude_sweet", 1);
	AddTo(lDude_AchievementUnlocked,			"DudeDialog.dude_wellwhodathought", 1);
	AddTo(lDude_AchievementUnlocked,			"DudeDialog.dude_map_anotherone", 1);
	AddTo(lDude_AchievementUnlocked,			"DudeDialog.dude_map_anddone", 1);
	AddTo(lDude_AchievementUnlocked,			"DudeDialog.dude_yougogirl", 1);

	Clear(lDude_AchievementUnlockedGrind);
	AddTo(lDude_AchievementUnlockedGrind,		"DudeDialog.dude_thatlooksenough", 1);
	AddTo(lDude_AchievementUnlockedGrind,		"DudeDialog.dude_imboredalready", 1);
	AddTo(lDude_AchievementUnlockedGrind,		"DudeDialog.dude_hehhehheh", 1);
	AddTo(lDude_AchievementUnlockedGrind,		"DudeDialog.dude_yess", 1);
	AddTo(lDude_AchievementUnlockedGrind,		"DudeDialog.dude_sweet", 1);
	AddTo(lDude_AchievementUnlockedGrind,		"DudeDialog.dude_map_anotherone", 1);
	AddTo(lDude_AchievementUnlockedGrind,		"DudeDialog.dude_map_anddone", 1);
	AddTo(lDude_AchievementUnlockedGrind,		"DudeDialog.dude_geethatwasntso", 1);
	

	///////////////////////////////////////////////////////////////////////////////
	// Added by Man Chrzan: xPatch 2.0
	// New dialogs for Paradise Lost features backport.
	///////////////////////////////////////////////////////////////////////////////	
	
	// Fuck You Lines
	Clear(lDude_FuckYou);
	AddTo(lDude_FuckYou,						"DudeDialog.dude_fuckyou", 1);
	
	// Dual Wielding
	Clear(lDude_BeginDualWielding);
	AddTo(lDude_BeginDualWielding, 				"DudeDialog.dude_sothatswhatthat", 1);
	AddTo(lDude_BeginDualWielding, 				"DudeDialog.dude_fascinating", 1);
	AddTo(lDude_BeginDualWielding, 				"DudeDialog.dude_sweet", 1);
	AddTo(lDude_BeginDualWielding, 				"DudeDialog.dude_viagraworks", 1);
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
}
