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
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
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
}
