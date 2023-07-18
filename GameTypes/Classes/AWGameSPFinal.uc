///////////////////////////////////////////////////////////////////////////////
// Apocalypse Weekend Single Player game info
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class AWGameSPFinal extends AWGameSP;

// In nightmare mode, give the dude a fish radar
event PostTravel(P2Pawn PlayerPawn)
	{
	local Inventory InvAdd;
	local P2PowerupInv ppinv;

	const NIGHTMARE_RADAR_MIN = 2000;
	
	Super.PostTravel(PlayerPawn);

	// In nightmare mode, give him a radar with a long battery life
	if (InNightmareMode())
	{
		// xPatch: no infinite radar in super-hard Veteran Mode :)
		if(!InVeteranMode())
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
			{
				ppinv.bDisplayAmount = False;	// xPatch: No need to show amount in expert mode (it's infinite)
				if(TheGameState.bFirstLevelOfDay)
					ppinv.Activate();
			}
		}
	}
	
	CheckDudeHeadSkin();	// xPatch:
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
/*
function bool PickupQuery( Pawn Other, Pickup item )
{
	if(P2WeaponPickup(item) == None
		|| AWDude(Other) == None
		|| AWDude(Other).GaryHeads <= 0
		|| AWDudePlayer(AWDude(Other).Controller).bNeverSwitchOnPickup)	// This variable gets stored and
		// switched to true on creation of a gary head, but if the user goes into the
		// options and switches it manually back and forth, it will come undone. We don't
		// want them doing this, so if they do, don't let them pick up the gun at all.
		// It'll all be back to normal when the heads are gone anyway.
		return Super.PickupQuery(Other, item);
	else
		return false;
}*/


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// xPatch: Not really needed for the head but for the HD Dude skin.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

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

defaultproperties
{
	bAllowBehindView=True
	DefaultPlayerClassName="GameTypes.AWPostalDude"
	HUDType="GameTypes.AWWrapHUD"
	PlayerControllerClassName="GameTypes.AWDudePlayer"
	ChameleonClass=class'ChameleonPlus'
	KissEmitterClass=class'FX2.KissEmitter'
	MenuTitleTex="AW_ProductName.ProductMenu"	
	GameName="POSTAL 2: Apocalypse Weekend"
	GameNameShort="Apocalypse Weekend"
	GameDescription="The expansion pack for POSTAL 2. It's the weekend, and your trailer's been impounded, your dog is about to be put to sleep, and your hateful wife has left you... well, at least it isn't all bad."
	HolidaySpawnerClassName="Postal2Holidays.HolidaySpawner"
	
	// xPatch: added loadout from cheat manager to the game itself, needes to be here for day selection to work correctly.
	// NOTE: 1 is intentional, for Sunday. We can't get any loadout for the first day anyways.
	LoadoutDays[1]=(Items=((Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=250),(Item=class'GSelectWeapon',Amount=200),(Item=class'GrenadeWeapon',Amount=25),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=3),(Item=class'ShotgunWeapon',Amount=120),(Item=class'FastFoodInv',Amount=10),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=200),(Item=class'MachineGunWeapon',Amount=200),(Item=class'BodyArmorInv'),(Item=class'CatnipInv',Amount=2),(Item=class'RadarInv',Amount=200),(Item=class'LauncherWeapon',Amount=100),(Item=class'MacheteWeapon'),(Item=class'ChainsawWeapon',Amount=150),(Item=class'GasCanWeapon',Amount=100)))
	
	// Day names for saves localization, day select and idk something else maybe.
	DayNames[0]="Saturday"
	DayNames[1]="Sunday"
}
