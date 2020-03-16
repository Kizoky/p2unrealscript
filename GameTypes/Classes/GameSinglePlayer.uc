///////////////////////////////////////////////////////////////////////////////
// GameSinglePlayer.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This defines the Postal 2 single-player game.
//
// History:
//	07/10/02 MJR	Started by copying errand stuff from DudePlayer.
//
///////////////////////////////////////////////////////////////////////////////
class GameSinglePlayer extends P2GameInfoSingle;


var float NewCatTime;	// When we'll make a new cat
var float CatRainTime;	// When we'll start raining again
var bool  bRainingCats;

const NEW_CAT_BASE_TIME	= 1;
const NEW_CAT_RAND_TIME	= 6;
const RAIN_BASE_TIME	= 25;
const RAIN_RAND_TIME	= 50;
const CAT_MAKE_RANGE_DIST=4000;
const CAT_MAKE_RANGE_XY = 1500;
const CAT_MAKE_BASE_DIST= 200;
const CAT_MAKE_Z		= 3000;
const CAT_RAIN_SPEED	= 100;
const CAT_RAIN_ACC		= -1200;

///////////////////////////////////////////////////////////////////////////////
// Check to swap out the postal dude's bandaged head skin.
///////////////////////////////////////////////////////////////////////////////
function CheckDudeHeadskin()
{
	local AWPostalDude TheDude;

	foreach DynamicActors(class'AWPostalDude', TheDude)
		TheDude.DudeCheckHeadSkin();
}

///////////////////////////////////////////////////////////////////////////////
// As soon as we have a valid game state, check for the dude's bandaged head
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
{
	Super.PostLoadGame();
	CheckDudeHeadSkin();
}

// Nightmare stuff that won't go in P2GameInfoSingle due to dependency issue
/*
function bool PickupQuery( Pawn Other, Pickup item )
{
	// In nightmare mode, prevent stored health pickups other than crack.
	if (P2Pawn(Other) != None)
		if (Item.Class == class'FastFoodPickup'
			|| Item.Class == class'PizzaPickup'
			|| Item.Class == class'DonutPickup'
			|| Item.Class == class'CrackPickup')
		{
			if (P2Pawn(Other).Health >= P2Pawn(Other).HealthMax)
				return false;
		}

	return Super.PickupQuery(Other, Item);
}
*/

event PostTravel(P2Pawn PlayerPawn)
	{
	local Inventory InvAdd;
	local P2PowerupInv ppinv;
	local ClothesPickup clothes;

	const NIGHTMARE_RADAR_MIN = 2000;

	// Take away the clipboard mission in They Hate Me mode
	if (TheyHateMeMode())
		Days[1] = DayBase'DayBase1Impossible';

	Super.PostTravel(PlayerPawn);

	// In nightmare mode, give him a radar with a long battery life
	if (/*TheGameState.bFirstLevelOfDay &&*/ InNightmareMode())
	{
		invadd = PlayerPawn.CreateInventoryByClass(class'RadarInv');
		//log(Self$" invadd "$invadd);
		// Make sure they have enough--if you have more than this, that's fine.
		ppinv = P2PowerupInv(invadd);
		if(ppinv != None
			&& ppinv.Amount < NIGHTMARE_RADAR_MIN)
			ppinv.SetAmount(NIGHTMARE_RADAR_MIN);

		// Force it to activate immediately if not already active.
		if (ppinv != None
			&& !ppinv.IsInState('Operating'))
			ppinv.Activate();

		// Delete clothes pickups the dude could use to sneak around town.
		foreach DynamicActors(class'ClothesPickup', clothes)
		{
			if (!clothes.bUseForErrands
				&& DudeClothesPickup(Clothes) == None
				&& GimpClothesPickupErrand(Clothes) == None)
				clothes.Destroy();
		}
	}

	// Check for the dude's bandaged head
	CheckDudeHeadSkin();
}
// Moved to their respective inventory classes.
/*
event InitGame(out string Options, out string Error)
{
	Super.InitGame(Options, Error);

	// Nightmare mode stuff
	if (InNightmareMode())
	{
		// In nightmare mode, prevent stored health pickups other than crack.
		class'FastFoodPickup'.Default.InventoryType = class'FastFoodInvAuto';
		class'PizzaPickup'.Default.InventoryType = class'PizzaInvAuto';
		class'DonutPickup'.Default.InventoryType = class'DonutInvAuto';
		class'CrackPickup'.Default.InventoryType = class'MedKitInv';
//		class'MaDBeerPickup'.Default.InventoryType = class'AW7Inventory.MadBeerInvAuto';

		// Animals go crazy
		//foreach DynamicActors(class'AnimalPawn', Animal)
		//	Animal.bGunCrazy = True;
	}
	else
	{
		class'FastFoodPickup'.Default.InventoryType = class'FastFoodInv';
		class'PizzaPickup'.Default.InventoryType = class'PizzaInv';
		class'DonutPickup'.Default.InventoryType = class'DonutInv';
		class'CrackPickup'.Default.InventoryType = class'CrackInv';
//		class'MaDBeerPickup'.Default.InventoryType = class'MadBeerInv';
	}
}
*/
///////////////////////////////////////////////////////////////////////////////
// Reach into entry and put a new reference to every chameleon texture/meshes in this
// level.
///////////////////////////////////////////////////////////////////////////////
function StoreChams()
{
	local LevelInfo lev;
	local TextureLoader texl;
	local MeshLoader mesher;
	local Actor checkme;
	local PersonPawn checkpawn;

	lev = GetPlayer().GetEntryLevel();

	//log(self$" StoreChams "$lev);

	foreach lev.AllActors(class'Actor', checkme)
	{
		if(TextureLoader(checkme) != None)
			texl = TextureLoader(checkme);
		else if(MeshLoader(checkme) != None)
			mesher = MeshLoader(checkme);
	}

	//log(self$" checking texture loader "$mesher$" mesh loader "$mesher);
	if(texl != None
		&& mesher != None)
	{
		// Clear the lists
		texl.ClearArray();
		mesher.ClearArray();
		// Now go through each pawn and put their textures/meshes into the list
		foreach DynamicActors(class'PersonPawn', checkpawn)
		{
			texl.AddTexture(checkpawn.Skins[0]);
			mesher.AddMesh(checkpawn.Mesh);
			if(checkpawn.MyHead != None)
			{
				texl.AddTexture(checkpawn.MyHead.Skins[0]);
				mesher.AddMesh(checkpawn.MyHead.Mesh);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check to rain cats during the apocalypse
///////////////////////////////////////////////////////////////////////////////
function CheckCatRain(float DeltaTime)
{
	local P2Player p2p;
	local CatRocket catr;
	local vector dir, StartLoc;
	local float tempf;

	CatRainTime -= DeltaTime;

	// Check to toggle rain
	if(CatRainTime <= 0)
	{
		bRainingCats = !bRainingCats;
		if(bRainingCats)
			CatRainTime = RAIN_BASE_TIME + Rand(RAIN_RAND_TIME);
		else
			CatRainTime = Rand(RAIN_BASE_TIME);
	}

	if(bRainingCats)
	{
		NewCatTime -= DeltaTime;
		if(NewCatTime <= 0)
		{
			p2p = GetPlayer();
			if(p2p != None
				&& p2p.MyPawn != None)
			{
				NewCatTime = NEW_CAT_BASE_TIME + Rand(NEW_CAT_RAND_TIME);
				// Make it generally in front of the player
				// Move it in front of him
				StartLoc = vector(p2p.MyPawn.Rotation);
				StartLoc.z = 0;
				StartLoc = (FRand()*CAT_MAKE_RANGE_DIST + CAT_MAKE_BASE_DIST) * StartLoc;
				// Vaguely center the rain if he's dead
				if(p2p.MyPawn.Health <= 0)
				{
					tempf = 0.5*(CAT_MAKE_RANGE_DIST + CAT_MAKE_BASE_DIST);
					StartLoc.x += tempf;
					StartLoc.y += tempf;
				}
				// Now create a range around that point
				tempf = (0.5*CAT_MAKE_RANGE_XY);
				StartLoc.x = StartLoc.x + (FRand()*CAT_MAKE_RANGE_XY - tempf);
				StartLoc.y = StartLoc.y + (FRand()*CAT_MAKE_RANGE_XY - tempf);
				// Move it above him
				StartLoc.z += CAT_MAKE_Z;
				StartLoc = StartLoc + p2p.MyPawn.Location;
				dir = VRand();
				dir.z=-1;
				catr = spawn(class'CatRocket',,,StartLoc,Rotator(dir));
				if(catr != None)
				{
					catr.AmbientGlow=255;	// make them pulse so they're easier to see.
					// modify speed for a gentle rain
					Dir = vector(catr.Rotation);
					catr.Velocity = CAT_RAIN_SPEED * Dir;
					catr.Acceleration.z = CAT_RAIN_ACC;
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Monitor things in the game, and rain cats
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunningApocalypse
{
	function BeginState()
	{
		Super.BeginState();
		// Init new cat time, the first time the level starts
		NewCatTime = NEW_CAT_BASE_TIME + Rand(NEW_CAT_RAND_TIME);
	}
}


defaultproperties
	{
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
	// Monday errands
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////

	// Get Paycheck
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalGetPickup0
		PickupTag="PaycheckPickup"
		TriggerOnCompletionTag="PaycheckErrand_ProtestorsAttack"
		HateClass="RWSProtestors"
		HateDesTex="p2misc.map.Hate_Group1Name"
		HatePicTex="p2misc.map.Hate_Group1Pic"
		HateComment="DudeDialog.dude_map_hate1"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBase0
		UniqueName="GetPaycheck"
		NameTex="p2misc.map.PickupCheck_text"
		LocationTex="p2misc.map.PickupCheck_here"
		LocationX=621
		LocationY=246
		LocationCrossTex="p2misc.map.hint_cross_1"
		LocationCrossX=674
		LocationCrossY=252
		DudeStartComment="DudeDialog.dude_map_getcheck"
		DudeWhereComment="DudeDialog.Dude_map_foundrws"	// sounds better before writing location on map
		//DudeFoundComment=
		DudeCompletedComment="DudeDialog.dude_map_anddone"
		Goals(0)=ErrandGoalGetPickup'ErrandGoalGetPickup0'
	End Object

	// Cash Paycheck
	Begin Object Class=ErrandGoalGiveInventory Name=ErrandGoalGiveInventory1
		InvClassName="PaycheckInv"
		GiveToMeTag="jenny"
		TriggerOnCompletionTag="BankErrand_RobbersShowUp"
	End Object
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalGetPickup3
		PickupTag="BankDeposit"
		TriggerOnCompletionTag="BankErrand_CopsShowUp"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBase1
		UniqueName="CashPaycheck"
		NameTex="p2misc.map.CashCheck_text"
		LocationTex="p2misc.map.CashCheck_here"
		LocationX=523
		LocationY=560
		LocationCrossTex="p2misc.map.hint_cross_2"
		LocationCrossX=580
		LocationCrossY=588
		DudeStartComment="DudeDialog.dude_map_cashcheck"
		DudeWhereComment="DudeDialog.Dude_map_loc2"
		DudeFoundComment="DudeDialog.Dude_map_found3"
		DudeCompletedComment="DudeDialog.dude_map_missionaccom"
		Goals(0)=ErrandGoalGiveInventory'ErrandGoalGiveInventory1'
		Goals(1)=ErrandGoalGetPickup'ErrandGoalGetPickup3'
	End Object

	// Get Milk
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalGetPickup2
		TriggerOnCompletionTag="MilkErrand_Completed"
		PickupTag="MilkPickup"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBase2
		UniqueName="GetMilk"
		NameTex="p2misc.map.GetMilk_text"
		LocationTex="p2misc.map.GetMilk_here"
		LocationX=660
		LocationY=432
		LocationCrossTex="p2misc.map.hint_cross_3"
		LocationCrossX=664
		LocationCrossY=464
		DudeStartComment="DudeDialog.dude_map_getmilk"
		DudeWhereComment="DudeDialog.Dude_map_loc4"
		DudeFoundComment="DudeDialog.Dude_map_found1"
		DudeCompletedComment="DudeDialog.dude_map_tooeasy"
		Goals(0)=ErrandGoalGetPickup'ErrandGoalGetPickup2'
	End Object

	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
	// Tuesday errands
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////

	// Visit Priest
	Begin Object Class=ErrandGoalTalkTo Name=ErrandGoalTalkTo0
		TalkToMeTag="FatherPriest"
		TriggerOnCompletionTag="FanaticSpawner"
	End Object
	Begin Object Class=ErrandGoalKillMe Name=ErrandGoalKillMe1
		KillMeTag="FatherPriest"
		TriggerOnCompletionTag="FanaticSpawner"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBase3
		UniqueName="VisitPriest"
		NameTex="p2misc.map.MakePeaceWithMaker_text"
		LocationTex="p2misc.map.MakePeaceWithMaker_here"
		LocationX=335
		LocationY=282
		LocationCrossTex="p2misc.map.hint_cross_4"
		LocationCrossX=356
		LocationCrossY=319
		DudeStartComment="DudeDialog.dude_map_confess"
		DudeWhereComment="DudeDialog.Dude_map_loc1"
		DudeFoundComment="DudeDialog.Dude_map_found5"
		DudeCompletedComment="DudeDialog.dude_map_closeenough"
		Goals(0)=ErrandGoalTalkTo'ErrandGoalTalkTo0'
		Goals(1)=ErrandGoalKillMe'ErrandGoalKillMe1'
	End Object

	// Get Signatures
	Begin Object Class=ErrandGoalGetAmmoMax Name=ErrandGoalGetAmmoMax0
		TriggerOnCompletionTag="SignaturesErrand_Completed"
		InvClassName="ClipboardWeapon"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBase4
		UniqueName="GetSignatures"
		NameTex="p2misc.map.GetSignatures"
		// takes place everywhere so no location is used
		DudeStartComment="DudeDialog.dude_map_signatures"
		DudeFoundComment="DudeDialog.Dude_map_foundsigs"
		DudeCompletedComment="DudeDialog.dude_map_anddone"
		Goals(0)=ErrandGoalGetAmmoMax'ErrandGoalGetAmmoMax0'
	End Object

	// Return Book
	Begin Object Class=ErrandGoalDropOffPickup Name=ErrandGoalDropOffPickup0
		PickupClassName="LibraryBookPickup"
		DropIntoHereTriggerTag="BookDropOff"
		TriggerOnCompletionTag="BookErrand_ProtestorsAttack"
		HateClass="BookProtestors"
		HateDesTex="p2misc.map.Hate_Group2Name"
		HatePicTex="p2misc.map.Hate_Group2Pic"
		HateComment="DudeDialog.dude_map_hate2"
	End Object
	Begin Object Class=ErrandGoalGiveInventory Name=ErrandGoalGiveInventory2
		InvClassName="LibraryBookInv"
		GiveToMeTag="betty"
		TriggerOnCompletionTag="BookErrand_ProtestorsAttack"
		HateClass="BookProtestors"
		HateDesTex="p2misc.map.Hate_Group2Name"
		HatePicTex="p2misc.map.Hate_Group2Pic"
		HateComment="DudeDialog.dude_map_hate2"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBase5
		UniqueName="ReturnBook"
		NameTex="p2misc.map.ReturnBook_text"
		LocationTex="p2misc.map.ReturnBook_here"
		LocationX=592
		LocationY=494
		LocationCrossTex="p2misc.map.hint_cross_3"
		LocationCrossX=607
		LocationCrossY=521
		DudeStartComment="DudeDialog.dude_map_returnbook"
		DudeWhereComment="DudeDialog.Dude_map_loc4"
		DudeFoundComment="DudeDialog.Dude_map_loc3"
		DudeCompletedComment="DudeDialog.dude_map_donebitch"
		Goals(0)=ErrandGoalDropOffPickup'ErrandGoalDropOffPickup0'
		Goals(1)=ErrandGoalGiveInventory'ErrandGoalGiveInventory2'
	End Object

	// Get Gary's Autograph
	Begin Object Class=ErrandGoalGetInvClassFromPerson Name=ErrandGoalGetInvClassFromPerson2
		TriggerOnCompletionTag="GaryErrand_GotBook"
		InvClassName="GaryBookInv"
		TalkToMeTag="Gary"
	End Object
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalGetPickup5
		TriggerOnCompletionTag="GaryErrand_StoleBook"
		PickupTag="GaryBookPickup"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBase6
		UniqueName="GetGary"
		NameTex="p2misc.map.GetGarysAutograph_text"
		LocationTex="p2misc.map.GetGarysAutograph_here"
		LocationX=579
		LocationY=376
		LocationCrossTex="p2misc.map.hint_cross_3"
		LocationCrossX=585
		LocationCrossY=385
		DudeStartComment="DudeDialog.dude_map_getgary"
		DudeWhereComment="DudeDialog.Dude_map_loc1"
		DudeFoundComment="DudeDialog.Dude_map_loc5"
		DudeCompletedComment="DudeDialog.dude_map_closeenough"
		Goals(0)=ErrandGoalGetInvClassFromPerson'ErrandGoalGetInvClassFromPerson2'
		Goals(1)=ErrandGoalGetPickup'ErrandGoalGetPickup5'
	End Object

	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
	// Wednesday errands
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////

	// Visit Dad
	Begin Object Class=ErrandGoalUrineQuotaMet Name=ErrandGoalUrineQuotaMet0
		UrineRecorderTag="DadsGrave"
		HateClass="Rednecks"
		HateDesTex="p2misc.map.Hate_Group3Name"
		HatePicTex="p2misc.map.Hate_Group3Pic"
		HateComment="DudeDialog.dude_map_hate3"
		TriggerOnCompletionTag="AttackAtGrave"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBase7
		UniqueName="VisitDad"
		NameTex="p2misc.map.PissOnDad_text"
		LocationTex="p2misc.map.PissOnDad_here"
		LocationX=371
		LocationY=207
		LocationCrossTex="p2misc.map.hint_cross_3"
		LocationCrossX=387
		LocationCrossY=233
		DudeStartComment="DudeDialog.dude_map_dad"
		DudeWhereComment="DudeDialog.Dude_map_loc1"
		DudeFoundComment="DudeDialog.Dude_map_loc6"
		DudeCompletedComment="DudeDialog.dude_map_next"
		Goals(0)=ErrandGoalUrineQuotaMet'ErrandGoalUrineQuotaMet0'
	End Object

	// Vote
	Begin Object Class=ErrandGoalTag Name=ErrandGoalTag0
		UniqueTag="VoteScreen"
		TriggerOnCompletionTag="VoteErrand_Completed"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBase8
		UniqueName="Vote"
		NameTex="p2misc.map.Vote_text"
		LocationTex="p2misc.map.Vote_here"
		LocationX=758
		LocationY=416
		LocationCrossTex="p2misc.map.hint_cross_3"
		LocationCrossX=787
		LocationCrossY=421
		DudeStartComment="DudeDialog.dude_map_vote"
		DudeWhereComment="DudeDialog.Dude_map_loc2"
		DudeFoundComment="DudeDialog.Dude_map_loc3"
		DudeCompletedComment="DudeDialog.dude_map_tooeasy"
		Goals(0)=ErrandGoalTag'ErrandGoalTag0'
	End Object

	// Get Tree
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalGetPickup6
		PickupTag="TreePickup"
		TriggerOnCompletionTag="TreeErrand_Completed"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBase9
		UniqueName="GetTree"
		NameTex="p2misc.map.GetXmasTree_text"
		LocationTex="p2misc.map.GetXmasTree_here"
		LocationX=739
		LocationY=856
		LocationCrossTex="p2misc.map.hint_cross_1"
		LocationCrossX=793
		LocationCrossY=889
		IgnoreTag="BadXmasTree"
		DudeStartComment="DudeDialog.dude_map_gettree"
		DudeWhereComment="DudeDialog.Dude_map_loc4"
		DudeFoundComment="DudeDialog.Dude_map_loc5"
		DudeCompletedComment="DudeDialog.dude_map_donebitch"
		Goals(0)=ErrandGoalGetPickup'ErrandGoalGetPickup6'
	End Object

	// Pickup Laundry
	Begin Object Class=ErrandGoalGetInvClassFromPerson Name=ErrandGoalGetInvClassFromPerson0
		TriggerOnCompletionTag="PickupLaundryErrand_GotClothes"
		InvClassName="DudeClothesInv"
		TalkToMeTag="Qing"
	End Object
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalGetPickup1
		TriggerOnCompletionTag="PickupLaundryErrand_StoleClothes"
		PickupTag="DudeClothesPickup"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBase10
		bInitiallyActive=false	// gets activated during gameplay
		UniqueName="PickupLaundry"
		NameTex="p2misc.map.PickupLaundry_text"
		LocationTex="p2misc.map.GetLaundry_here"
		LocationX=739
		LocationY=461
		LocationCrossTex="p2misc.map.hint_cross_2"
		LocationCrossX=794
		LocationCrossY=490
		DudeStartComment="DudeDialog.dude_map_getlaundry"
		DudeWhereComment="DudeDialog.Dude_map_loc1"
		DudeFoundComment="DudeDialog.Dude_map_loc6"
		DudeCompletedComment="DudeDialog.dude_map_next"
		Goals(0)=ErrandGoalGetInvClassFromPerson'ErrandGoalGetInvClassFromPerson0'
		Goals(1)=ErrandGoalGetPickup'ErrandGoalGetPickup1'
	End Object

	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
	// Thursday errands
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////

	// Get Napalm
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalGetPickup7
		PickupTag="NapalmPickupErrand"
		TriggerOnCompletionTag="NapalmErrand_Completed"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBase11
		UniqueName="GetNapalm"
		NameTex="p2misc.map.GetNapalm_text"
		LocationTex="p2misc.map.GetNapalm_here"
		LocationX=374
		LocationY=444
		LocationCrossTex="p2misc.map.hint_cross_2"
		LocationCrossX=368
		LocationCrossY=444
		IgnoreTag="NapalmPickupTalk"
		DudeStartComment="DudeDialog.dude_map_getnapalm"
		DudeWhereComment="DudeDialog.Dude_map_loc1"
		DudeFoundComment="DudeDialog.Dude_map_loc3"
		DudeCompletedComment="DudeDialog.dude_partywithnapalm"
		Goals(0)=ErrandGoalGetPickup'ErrandGoalGetPickup7'
	End Object

	// Get Krotchy
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalGetPickup8
		PickupTag="KrotchyPickup"
		TriggerOnCompletionTag="KrotchyErrand_Completed"
	End Object
	Begin Object Class=ErrandGoalGetInvClassFromPerson Name=ErrandGoalGetInvClassFromPerson3
		InvClassName="KrotchyInv"
		TalkToMeTag="Krotchy"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBase12
		UniqueName="GetKrotchy"
		NameTex="p2misc.map.GetKrotchy_text"
		LocationTex="p2misc.map.GetKrotchy_here"
		LocationX=553
		LocationY=302
		LocationCrossTex="p2misc.map.hint_cross_1"
		LocationCrossX=557
		LocationCrossY=331
		DudeStartComment="DudeDialog.dude_map_getkrotchy"
		DudeWhereComment="DudeDialog.Dude_map_loc2"
		DudeFoundComment="DudeDialog.Dude_map_loc5"
		DudeCompletedComment="DudeDialog.dude_map_missionaccom"
		Goals(0)=ErrandGoalGetPickup'ErrandGoalGetPickup8'
		Goals(1)=ErrandGoalGetInvClassFromPerson'ErrandGoalGetInvClassFromPerson3'
	End Object

	// Get Steaks
	Begin Object Class=ErrandGoalGetInvClassFromPerson Name=ErrandGoalGetInvClassFromPerson1
		InvClassName="SteakInv"
		TalkToMeTag="Fred"
		TriggerOnCompletionTag="SteaksErrand_GotSteaks"
	End Object
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalGetPickup4
		PickupTag="SteakPickup"
		HateClass="Slaughterers"
		HateDesTex="p2misc.map.Hate_Group4Name"
		HatePicTex="p2misc.map.Hate_Group4Pic"
		HateComment="DudeDialog.dude_map_hate4"
		TriggerOnCompletionTag="SteaksErrand_StoleSteaks"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBase13
		UniqueName="GetSteaks"
		NameTex="p2misc.map.GetSteaks_text"
		LocationTex="p2misc.map.GetSteaks_here"
		LocationX=749
		LocationY=728
		LocationCrossTex="p2misc.map.hint_cross_4"
		LocationCrossX=746
		LocationCrossY=725
		DudeStartComment="DudeDialog.dude_map_getsteaks"
		DudeWhereComment="DudeDialog.Dude_map_loc4"
		DudeFoundComment="DudeDialog.Dude_map_loc6"
		DudeCompletedComment="DudeDialog.dude_map_anddone"
		Goals(0)=ErrandGoalGetInvClassFromPerson'ErrandGoalGetInvClassFromPerson1'
		Goals(1)=ErrandGoalGetPickup'ErrandGoalGetPickup4'
	End Object

	// Pay Ticket
	Begin Object Class=ErrandGoalGiveInventory Name=ErrandGoalGiveInventory3
		InvClassName="CitationInv"
		GiveToMeTag="Dick"
		TriggerOnCompletionTag="CitationErrand_PaidTicket"
	End Object
	Begin Object Class=ErrandGoalDropOffPickup Name=ErrandGoalDropOffPickup1
		PickupClassName="CitationPickup"
		DropIntoHereTriggerTag="CitationDropOff"
		TriggerOnCompletionTag="CitationErrand_DroppedOffTicket"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBase14
		UniqueName="PayTicket"
		NameTex="p2misc.map.PayTicket_text"
		LocationTex="p2misc.map.PayTicket_here"
		LocationX=677
		LocationY=605
		LocationCrossTex="p2misc.map.hint_cross_4"
		LocationCrossX=681
		LocationCrossY=604
		DudeStartComment="DudeDialog.dude_map_payticket"
		DudeWhereComment="DudeDialog.Dude_map_loc1"
		DudeFoundComment="DudeDialog.Dude_map_loc3"
		DudeCompletedComment="DudeDialog.dude_map_anotherone"
		Goals(0)=ErrandGoalGiveInventory'ErrandGoalGiveInventory3'
		Goals(1)=ErrandGoalDropOffPickup'ErrandGoalDropOffPickup1'
	End Object

	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
	// Friday errands
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////

	// Get Alternator
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalGetPickup9
		PickupTag="AlternatorPickup"
		TriggerOnCompletionTag="AlternatorErrand_GotIt"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBase15
		UniqueName="GetAlternator"
		NameTex="p2misc.map.GetAlternator_text"
		LocationTex="p2misc.map.GetAlternator_here"
		LocationX=328
		LocationY=611
		LocationCrossTex="p2misc.map.hint_cross_4"
		LocationCrossX=354
		LocationCrossY=636
		DudeStartComment="DudeDialog.dude_map_getalternator"
		DudeWhereComment="DudeDialog.Dude_map_loc1"
		DudeFoundComment="DudeDialog.Dude_map_loc5"
		DudeCompletedComment="DudeDialog.dude_map_next"
		Goals(0)=ErrandGoalGetPickup'ErrandGoalGetPickup9'
	End Object

	// Pickup Package
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalGetPickup11
		PickupTag="ParcelPickup"
		TriggerOnCompletionTag="PackageErrand_GotIt"
		HateClass="ParcelWorkers"
		HateDesTex="p2misc.map.Hate_Group5Name"
		HatePicTex="p2misc.map.Hate_Group5Pic"
		HateComment="DudeDialog.dude_map_hate5"
	End Object
	Begin Object Class=ErrandGoalTalkTo Name=ErrandGoalTalkTo1
		TalkToMeTag="Lucy"
		TriggerOnCompletionTag="PackageErrand_BringItUp"
		HateClass="ParcelWorkers"
		HateDesTex="p2misc.map.Hate_Group5Name"
		HatePicTex="p2misc.map.Hate_Group5Pic"
		HateComment="DudeDialog.dude_map_hate5"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBase16
		UniqueName="PickupPackage"
		NameTex="p2misc.map.BuyStamps_text"
		LocationTex="p2misc.map.BuyStamps_here"
		LocationX=840
		LocationY=693
		LocationCrossTex="p2misc.map.hint_cross_1"
		LocationCrossX=840
		LocationCrossY=693
		DudeStartComment="DudeDialog.dude_map_getpackage"
		DudeWhereComment="DudeDialog.Dude_map_loc2"
		DudeFoundComment="DudeDialog.Dude_map_loc6"
		DudeCompletedComment="DudeDialog.dude_map_anddone"
		Goals(0)=ErrandGoalTalkTo'ErrandGoalTalkTo1'
		Goals(1)=ErrandGoalGetPickup'ErrandGoalGetPickup11'
	End Object

	// Give Present
	Begin Object Class=ErrandGoalGiveInventory Name=ErrandGoalGiveInventory0
		InvClassName="GiftInv"
		GiveToMeTag="UncleDave"
		TriggerOnCompletionTag="UncleDaveErrand_Completed"
	End Object
	Begin Object Class=ErrandGoalKillMe Name=ErrandGoalKillMe0
		KillMeTag="UncleDave"
		TriggerOnCompletionTag="UncleDaveErrand_Completed"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBase17
		UniqueName="GivePresent"
		NameTex="p2misc.map.UncleDavesBday_text"
		LocationTex="p2misc.map.UncleDavesBday_here"
		LocationX=526
		LocationY=57
		LocationCrossTex="p2misc.map.hint_cross_1"
		LocationCrossX=571
		LocationCrossY=64
		DudeStartComment="DudeDialog.dude_map_uncledave"
		DudeWhereComment="DudeDialog.Dude_map_loc4"
		DudeFoundComment="DudeDialog.Dude_map_loc3"
		DudeCompletedComment="DudeDialog.dude_map_tooeasy"
		Goals(0)=ErrandGoalGiveInventory'ErrandGoalGiveInventory0'
		Goals(1)=ErrandGoalKillMe'ErrandGoalKillMe0'
	End Object

	// Visit Clinic
	Begin Object Class=ErrandGoalGetPickup Name=ErrandGoalGetPickup10
		PickupTag="PillsPickup"
		TriggerOnCompletionTag="ClinicErrand_Completed"
	End Object
	Begin Object Class=ErrandBase Name=ErrandBase18
		bInitiallyActive=false	// gets activated during gameplay
		UniqueName="VisitClinic"
		NameTex="p2misc.map.GoToClinic_text"
		LocationTex="p2misc.map.GoToClinic_here"
		LocationX=471
		LocationY=405
		LocationCrossTex="p2misc.map.hint_cross_2"
		LocationCrossX=537
		LocationCrossY=437
		DudeStartComment="DudeDialog.dude_map_clinic"
		DudeWhereComment="DudeDialog.Dude_map_loc1"
		DudeFoundComment="DudeDialog.Dude_map_loc5"
		DudeCompletedComment="DudeDialog.dude_map_next"
		Goals(0)=ErrandGoalGetPickup'ErrandGoalGetPickup10'
	End Object

	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
	// Days are defined here
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////

	// Monday
	Begin Object Class=DayBase Name=DayBase0
        Description="Monday"
		UniqueName="DAY_A"
		ExcludeDays[0]="DEMO"
		Errands(0)=ErrandBase'ErrandBase0'
		Errands(1)=ErrandBase'ErrandBase1'
		Errands(2)=ErrandBase'ErrandBase2'
        MapTex="p2misc_full.map_day1"
        NewsTex="p2misc.newspaper_day_1"
		DudeNewsComment="DudeDialog.dude_news_monday"
        LoadTex="p2misc_full.loading1"
		DudeStartComment="DudeDialog.dude_map_exit1"

		PlayerInvList(0)=(InvClassName="Inventory.MoneyInv",NeededAmount=20)
		PlayerInvList(1)=(InvClassName="Inventory.MapInv")
		// Don't override the Dude's new hands by giving him the old ones
		//PlayerInvList(2)=(InvClassName="Inventory.HandsWeapon")
		PlayerInvList(2)=(InvClassName="Inventory.CopClothesInv",bEnhancedOnly=true)
		PlayerInvList(3)=(InvClassName="Inventory.StatInv")

		TakeFromPlayerList(0)=(InvClassName="Inventory.NewspaperInv")
		TakeFromPlayerList(1)=(InvClassName="Inventory.GimpClothesInv")
		TakeFromPlayerList(2)=(InvClassName="Inventory.DudeClothesInv")
		TakeFromPlayerList(3)=(InvClassName="Inventory.MilkInv")
		TakeFromPlayerList(4)=(InvClassName="Inventory.PaycheckInv")
	End Object

	// Tuesday
	Begin Object Class=DayBase Name=DayBase1
        Description="Tuesday"
		UniqueName="DAY_B"
		ExcludeDays[0]="DEMO"
		Errands(0)=ErrandBase'ErrandBase3'
		Errands(1)=ErrandBase'ErrandBase4'
		Errands(2)=ErrandBase'ErrandBase5'
		Errands(3)=ErrandBase'ErrandBase6'
        MapTex="p2misc_full.map_day2"
        NewsTex="p2misc_full.newspaper_day_2"
		DudeNewsComment="DudeDialog.dude_news_tuesday"
        LoadTex="p2misc_full.loading2"
		DudeStartComment="DudeDialog.dude_map_exit2"

		PlayerInvList(0)=(InvClassName="Inventory.LibraryBookInv")
		PlayerInvList(1)=(InvClassName="Inventory.ClipboardWeapon")
		PlayerInvList(2)=(InvClassName="Inventory.GimpClothesInv",bEnhancedOnly=true)

		TakeFromPlayerList(0)=(InvClassName="Inventory.NewspaperInv")
		TakeFromPlayerList(1)=(InvClassName="Inventory.GimpClothesInv")
		TakeFromPlayerList(2)=(InvClassName="Inventory.DudeClothesInv")
		TakeFromPlayerList(3)=(InvClassName="Inventory.ClipboardWeapon")
		TakeFromPlayerList(4)=(InvClassName="Inventory.LibraryBookInv")
		// leave the gary book--you can bribe Krotchy with it
	End Object

	// Tuesday - Impossible Mode.
	Begin Object Class=DayBase Name=DayBase1Impossible
        Description="Tuesday"
		UniqueName="DAY_B"
		ExcludeDays[0]="DEMO"
		Errands(0)=ErrandBase'ErrandBase3'
		Errands(1)=ErrandBase'ErrandBase5'
		Errands(2)=ErrandBase'ErrandBase6'
        MapTex="p2misc_full.map_day2"
        NewsTex="p2misc_full.newspaper_day_2"
		DudeNewsComment="DudeDialog.dude_news_tuesday"
        LoadTex="p2misc_full.loading2"
		DudeStartComment="DudeDialog.dude_map_exit2"

		PlayerInvList(0)=(InvClassName="Inventory.LibraryBookInv")
		PlayerInvList(1)=(InvClassName="Inventory.GimpClothesInv",bEnhancedOnly=true)
		PlayerInvList(2)=(InvClassName="")

		TakeFromPlayerList(0)=(InvClassName="Inventory.NewspaperInv")
		TakeFromPlayerList(1)=(InvClassName="Inventory.GimpClothesInv")
		TakeFromPlayerList(2)=(InvClassName="Inventory.DudeClothesInv")
		TakeFromPlayerList(3)=(InvClassName="Inventory.ClipboardWeapon")
		TakeFromPlayerList(4)=(InvClassName="Inventory.LibraryBookInv")
		// leave the gary book--you can bribe Krotchy with it
	End Object

	// Wednesday
	Begin Object Class=DayBase Name=DayBase2
        Description="Wednesday"
		UniqueName="DAY_C"
		ExcludeDays[0]="DEMO"
		Errands(0)=ErrandBase'ErrandBase7'
		Errands(1)=ErrandBase'ErrandBase8'
		Errands(2)=ErrandBase'ErrandBase9'
		Errands(3)=ErrandBase'ErrandBase10'
        MapTex="p2misc_full.map_day3"
        NewsTex="p2misc_full.newspaper_day_3"
		DudeNewsComment="DudeDialog.dude_news_wednesday"
        LoadTex="p2misc_full.loading3"
		DudeStartComment="DudeDialog.dude_map_exit3"

		PlayerInvList(0)=(InvClassName="Inventory.CatnipInv",NeededAmount=5,bEnhancedOnly=true)

		TakeFromPlayerList(0)=(InvClassName="Inventory.NewspaperInv")
		TakeFromPlayerList(1)=(InvClassName="Inventory.GimpClothesInv")
		TakeFromPlayerList(2)=(InvClassName="Inventory.DudeClothesInv")
		TakeFromPlayerList(3)=(InvClassName="Inventory.TreeInv")
	End Object

	// Thursday
	Begin Object Class=DayBase Name=DayBase3
		Description="Thursday"
		UniqueName="DAY_D"
		ExcludeDays[0]="DEMO"
        Errands(0)=ErrandBase'ErrandBase11'
		Errands(1)=ErrandBase'ErrandBase12'
		Errands(2)=ErrandBase'ErrandBase13'
		Errands(3)=ErrandBase'ErrandBase14'
        MapTex="p2misc_full.map_day4"
        NewsTex="p2misc_full.newspaper_day_4"
		DudeNewsComment="DudeDialog.dude_news_thursday"
        LoadTex="p2misc_full.loading4"
		DudeStartComment="DudeDialog.dude_map_exit4"

		PlayerInvList(0)=(InvClassName="Inventory.CitationInv")
		PlayerInvList(1)=(InvClassName="Inventory.RocketCamInv",bEnhancedOnly=true)

		TakeFromPlayerList(0)=(InvClassName="Inventory.NewspaperInv")
		TakeFromPlayerList(1)=(InvClassName="Inventory.GimpClothesInv")
		TakeFromPlayerList(2)=(InvClassName="Inventory.DudeClothesInv")
		TakeFromPlayerList(3)=(InvClassName="Inventory.KrotchyInv")
		TakeFromPlayerList(4)=(InvClassName="Inventory.SteakInv")
		TakeFromPlayerList(5)=(InvClassName="Inventory.CitationInv")
	End Object

	// Friday
	Begin Object Class=DayBase Name=DayBase4
		Description="Friday"
		UniqueName="DAY_E"
		ExcludeDays[0]="DEMO"
        Errands(0)=ErrandBase'ErrandBase15'
		Errands(1)=ErrandBase'ErrandBase16'
		Errands(2)=ErrandBase'ErrandBase17'
		Errands(3)=ErrandBase'ErrandBase18'
        MapTex="p2misc_full.map_day5"
        NewsTex="p2misc_full.newspaper_day_5"
		DudeNewsComment="DudeDialog.dude_news_friday"
        LoadTex="p2misc_full.loading5"
		DudeStartComment="DudeDialog.dude_map_exit5"

		PlayerInvList(0)=(InvClassName="Inventory.GiftInv")
		PlayerInvList(1)=(InvClassName="Inventory.GonorrheaAmmoInv")
		PlayerInvList(2)=(InvClassName="Inventory.CopClothesInv",bEnhancedOnly=true)

		TakeFromPlayerList(0)=(InvClassName="Inventory.NewspaperInv")
		TakeFromPlayerList(1)=(InvClassName="Inventory.GimpClothesInv")
		TakeFromPlayerList(2)=(InvClassName="Inventory.DudeClothesInv")
		TakeFromPlayerList(3)=(InvClassName="Inventory.ParcelInv")
		TakeFromPlayerList(4)=(InvClassName="Inventory.AlternatorInv")
		TakeFromPlayerList(5)=(InvClassName="Inventory.PillsInv")
		TakeFromPlayerList(6)=(InvClassName="Inventory.GonorrheaAmmoInv")
		TakeFromPlayerList(7)=(InvClassName="Inventory.MapInv")
		TakeFromPlayerList(8)=(InvClassName="Inventory.GiftInv")
		TakeFromPlayerList(9)=(InvClassName="Inventory.CopClothesInv")
		TakeFromPlayerList(10)=(InvClassName="Inventory.RocketCamInv")
	End Object

	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
	// the week is defined here
	//////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////

	Days(0)=DayBase'DayBase0'
	Days(1)=DayBase'DayBase1'
	Days(2)=DayBase'DayBase2'
	Days(3)=DayBase'DayBase3'
	Days(4)=DayBase'DayBase4'

	GameSpeed=1.000000
	MaxSpectators=2
	DefaultPlayerName="TheDude"
	PlayerControllerClassName="GameTypes.DudePlayer"
	IntroURL			= "intro.fuk"
	StartFirstDayURL	= "suburbs-3"
	StartNextDayURL		= "suburbs-3"
	FinishedDayURL		= "homeatnight"
	JailURL				= "police.fuk#cell"
	//"Police.fuk#cell"
	//"jailtest.fuk#cell"
	GameStateClass=Class'AWGameState'
	ApocalypseTex="AW7Tex.Misc.ApocalypseNewspaper"
	ChameleonClass=class'ChameleonPlus'
    DefaultPlayerClassName="GameTypes.AWPostalDude"
	HUDType="GameTypes.AchievementHUD"
	KissEmitterClass=class'FX2.KissEmitter'
	GameName="POSTAL 2"
	GameNameshort="POSTAL 2"
	GameDescription="The original POSTAL 2. Live a life in the week of 'The POSTAL Dude', a hapless everyman just trying to check off some chores."
	HolidaySpawnerClassName="Postal2Holidays.HolidaySpawner"
	}
