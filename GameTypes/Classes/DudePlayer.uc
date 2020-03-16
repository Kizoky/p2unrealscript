///////////////////////////////////////////////////////////////////////////////
// Postal 2 player controller
//
// Dude controller, placed here so it has access in default properties
// to all the inventory items and things defined so late in the ucc make.
// 
// If you put these defaults in Postal2Game.P2Player, then you run into dependency
// issues with things like the MilkPickup and such
///////////////////////////////////////////////////////////////////////////////
class DudePlayer extends MpPlayer;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var Sound GaryTalking;
var array<Texture> GarySkins;
var class<DudeTalkMarker> dudehungryclass;	// keeps track of him being hungry
var DudeTalkMarker	dudecomplaining;	// whatever your complaining about
var class<DudeTalkMarker> dudecowhuntingclass;	// keeps track of him cow hunting
//var array<AWTrigger>	KillTrigger;	// Trigger keeping track of our kills
var Material MikeJHeadSkin;
var Mesh MikeJHeadMesh;
var String MikeJDialog;
var Sound BeginDualWield, DualWieldAmbient, EndDualWield;	// Ambient sound to play while dual-wielding

// Weapon selector
var globalconfig string				WeaponSelectorClassName;
var protected transient P2WeaponSelector	WeaponSelector;

// Inventory selector
var globalconfig string InventorySelectorClassName;
var protected transient P2InventorySelector InventorySelector;

// "Last Weapon" button
var int LastWeaponGroup, LastWeaponOffset;

///////////////////////////////////////////////////////////////////////////////
// CONST
///////////////////////////////////////////////////////////////////////////////
const	WATCH_ME_CHANGE_RADIUS	= 4096;
const	MAKE_OUT_CHANGE_RADIUS	= 1024;
const	PETITION_FOV			= 0.2;
const   BONE_HEAD				= 'MALE01 head';
const	CLOTHES_BOLTON			= 7;


replication
{
	reliable if( RemoteRole==ROLE_AutonomousProxy ) 
		ClientToggleToHands;
}

//ErikFOV Change: Subtitle system
function int CheckSpeakerState(Actor A)
{
	local P2Pawn P, S;
	local CashierController CC;
	local int st;

	st = Super.CheckSpeakerState(A);

	if (A != none && (st == 3 || st == 0 || st == 1))
	{
		P = P2Pawn(Pawn);
		S = P2Pawn(A);

		if (S == none) // if speaker not pawn
			return 0;

		CC = CashierController(S.Controller);

		if (P != none && CC != none && (CC.InterestPawn == P || (CC.InterestPawn == none && CC.PossibleCutter == P)) && CC.Attacker == none) //if cashier tilk with player
		{
			return 1;
		}
		else if (P != none && CC != none && (CC.InterestPawn != none || CC.PossibleCutter != none)) //if cashier tilk with anybody
		{
			return 0;
		}
	}
	return st;
}
//end


///////////////////////////////////////////////////////////////////////////////
// Only show these when you're getting arrested
///////////////////////////////////////////////////////////////////////////////
function bool GetBriberyHints(out String str1, out String str2)
{
	// If the cop switched us to our cash, they're interested in a bribe - show a bribery hint.
	if (InterestPawn != None
		&& InterestPawn.Controller != None
		&& PoliceController(InterestPawn.Controller) != None
		&& MoneyInv(MyPawn.SelectedItem) != None)
	{
		str1 = CopBribeHint1;
		str2 = CopBribeHint2;
		return true;
	}
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// called after a level travel
///////////////////////////////////////////////////////////////////////////////
event TravelPostAccept()
{
	local P2GameInfoSingle checkg;

	Super.TravelPostAccept();

	checkg = P2GameInfoSingle(Level.Game);

	// Start of new day
	if(checkg == None
		|| checkg.TheGameState == None
		|| (checkg.TheGameState.bFirstLevelOfDay
			&& !checkg.bLoadedSavedGame) )
	{
		// Switch to your hands on the start of a new day
		SwitchToLastWeaponInGroup(MyPawn.HandsClass.default.InventoryGroup);

		if(MyPawn.Weapon != None)
		{
			// Remember what our hands are
			LastWeaponGroupHands = MyPawn.Weapon.InventoryGroup;
			LastWeaponOffsetHands= MyPawn.Weapon.GroupOffset;
		}

		// Switch your inventory to your map on the start of a new day
		SwitchToThisPowerup(class'MapInv'.default.InventoryGroup, class'MapInv'.default.GroupOffset);

		// To start a new day, give the player full health if he's low (he could
		// be over the max with crack, so make sure to check)
		if(MyPawn.Health < MyPawn.HealthMax)
			MyPawn.Health = MyPawn.HealthMax;
	}
	else
	{
		// If it's not a new day (just another level) restore the inventory item
		// we had when going through the transition
		if(checkg.TheGameState.LastSelectedInventoryGroup >= 0)
			SwitchToThisPowerup(checkg.TheGameState.LastSelectedInventoryGroup, 
								checkg.TheGameState.LastSelectedInventoryOffset);
	}
	
	// If we're on hands and should be on an errand weapon, change out
	if (MyPawn.Weapon != None)
	{
		if (MyPawn.Weapon.InventoryGroup == MyPawn.HandsClass.default.InventoryGroup)
		{
			SwitchToLastWeaponInGroup(MyPawn.HandsClass.default.InventoryGroup);
		}
	}

	// Set no-fire damage for enhanced mode
	if(checkg.VerifySeqTime())
		MyPawn.TakesOnFireDamage=0.0;

	//log(self$" &&&&&&&&&&&&&&&&&&&&TravelPostAccept, starting up health "$MyPawn.Health$" mypawn "$MyPawn.HealthMax);
	MyPawn.bPlayerStarting=false;
	
	// Restore cheated game speed
	if (P2GameInfoSingle(Level.Game).TheGameState.CheatGameSpeed != 0)
		Level.Game.SetGameSpeed(P2GameInfoSingle(Level.Game).TheGameState.CheatGameSpeed);
		
	// Restore Mighty Foot cheat
	if (P2GameInfoSingle(Level.Game).TheGameState.bMightyFoot)
		RestoreCheat("MightyFoot");
		
	// Restore speed cheats
	if (P2GameInfoSingle(Level.Game).TheGameState.bSuperMario)
		RestoreCheat("SuperMario");
	if (P2GameInfoSingle(Level.Game).TheGameState.bSonicBoom)
		RestoreCheat("SonicBoom");
		
	// Restore low gravity
	if (P2GameInfoSingle(Level.Game).TheGameState.bMoonMan)
		RestoreCheat("MoonMan");
	
}

///////////////////////////////////////////////////////////////////////////////
// See if we picked up a weapon, and if we're in a disguise, change the hands
// on the weapon to match our diguise
///////////////////////////////////////////////////////////////////////////////
function NotifyAddInventory(inventory NewItem)
{
	local class<ClothesInv> UseNewClass;
	local P2Weapon p2weap;

	Super.NotifyAddInventory(NewItem);

	// Check for weapons and change hand textures to match our disguise
	p2weap = P2Weapon(NewItem);
	if(p2weap != None)
	{
		if(CurrentClothes != DefaultClothes)
		{
			UseNewClass = class<ClothesInv>(CurrentClothes);
			p2weap.ChangeHandTexture(UseNewClass.default.HandsTexture, DefaultHandsTexture, 
				UseNewClass.default.FootTexture);
		}
	}
	if(NewItem.IsA('Weapon'))
		WeaponSelector.AddWeapon(Weapon(NewItem));
}

///////////////////////////////////////////////////////////////////////////////
// True means the damage stops you from peeing, false means you keep going
///////////////////////////////////////////////////////////////////////////////
function bool DamageStopsPiss(class<DamageType> damageType)
{
	if (class<P2Damage>(DamageType) != None)
		return class<P2Damage>(DamageType).Default.bDamageStopsPiss;		
	else
		return true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	if(Damage > 0
		|| Level.Game.bIsSinglePlayer)
	{
		Super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, damageType, Momentum);

		// Stop peeing when you take any damage except gonrrhea damage
		// (in which case keep letting you pee)
		//mypawnfix
		if(Pawn.Weapon == P2Pawn(Pawn).MyUrethra
			&& Pawn.Weapon.IsFiring()
			&& DamageStopsPiss(DamageType))
		{
			// If you were peeing, and you got hurt, then stop peeing for a moment
			P2Weapon(Pawn.Weapon).ForceEndFire();
			P2Weapon(Pawn.Weapon).UseWaitTime = SayTime + Frand();
			Pawn.Weapon.GotoState('WaitAfterStopping');
		}
	}	
}

///////////////////////////////////////////////////////////////////////////////
// Check if we can use these clothes and they aren't the same as what we
// have on, if so, change them.
///////////////////////////////////////////////////////////////////////////////
function bool CheckForChangeClothes(class<Inventory> NewClothesClass)
{
	if(NewClothesClass != CurrentClothes)
	{
		NewClothes = NewClothesClass;
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// After a level change we have to re-clothe you with the clothes you left
// with (we don't save all the skin changes across a level transition--we just
// save what you were wearing when you left, so now we have to redo it)
// CurrentClothes is saved by the gamestate. Check it against default dude
// clothes, and if it's different, change them. (But with no screen fade
// and no level transition
///////////////////////////////////////////////////////////////////////////////
function SetClothes(class<Inventory> NewClothesClass)
{
	if(NewClothesClass != DefaultClothes)
	{
		NewClothes = NewClothesClass;
		ChangeToNewClothes();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Called after a saved game has been loaded
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
{
	Super.PostLoadGame();
	SetClothes(CurrentClothes); // ensures the hud splash icons behind come up for each outfit
	AddWeaponSelector();
	AddInventorySelector();
	WeaponSelector.RefreshSelector();
}

///////////////////////////////////////////////////////////////////////////////
// Change the dudes clothes from what they are now, to the this new clothing
// type, and if specified, keep the old clothes in his inventory
///////////////////////////////////////////////////////////////////////////////
function ChangeToNewClothes()
{
	local class<ClothesInv> UseNewClass;
	local class<ClothesInv> UseCurrClass;
	local Inventory inv;
	local P2Pawn CheckP;
	local PoliceController policec;
	local PersonController personc;
	local int count;

	UseNewClass = class<ClothesInv>(NewClothes);
	UseCurrClass= class<ClothesInv>(CurrentClothes);

	// Put our old clothes into our inventory, if we're supposed to
	if(UseNewClass.default.bAllowSwap
		&& (UseCurrClass.default.bAllowKeep
		// Allow keeping clothing during enhanced mode
		|| P2GameInfoSingle(Level.Game).VerifySeqTime()))
	{
		// Switch your inventory view to your old clothes, now in your inventory
		MyPawn.SelectedItem = Powerups(MyPawn.CreateInventoryByClass(UseCurrClass));
	}
	
	// Destroy old bolton, if any
	MyPawn.DestroyBolton(CLOTHES_BOLTON);

	// Change third person texture and mesh
	MyPawn.SwitchToNewMesh(UseNewClass.default.BodyMesh,
										UseNewClass.default.BodySkin,
										UseNewClass.default.HeadMesh,
										UseNewClass.default.HeadSkin);
										
	// Add bolton
	MyPawn.Boltons[CLOTHES_BOLTON] = UseNewClass.default.Bolton;
	MyPawn.SetupBolton(CLOTHES_BOLTON);
	if (MyPawn.Boltons[CLOTHES_BOLTON].Part != None)
		MyPawn.Boltons[CLOTHES_BOLTON].Part.SetRelativeLocation(UseNewClass.default.BoltonRelativeLocation);

	// Change first person textures
	ChangeAllWeaponHandTextures(UseNewClass.default.HandsTexture, UseNewClass.default.FootTexture);

	// Change the hud backer splats
	P2Hud(MyHUD).ChangeHudSplats(UseNewClass.default.HudSplats);

	// If your changing into new clothes, check to see who saw you.. you might fool people
	if(CurrentClothes != NewClothes)
	{
		// Check if anyone sees/doesn't see us change our clothes. For most of our attackers
		// who don't see us change, we'll erase our record with them.
		// If we use a VisibleCollidingActors check, people behind walls won't be counted, 
		// and we want those people.
		foreach CollidingActors(class'P2Pawn', CheckP, WATCH_ME_CHANGE_RADIUS, MyPawn.Location)
		{
			personc = PersonController(CheckP.Controller);
			if(personc != None)
			{
				policec = PoliceController(CheckP.Controller);
				
				if(personc.CanSeePawn(CheckP, MyPawn))
				{
					if(policec != None)
					{
						// If our new clothes are cop clothes, check to see if any cops around
						// saw us changing into a cop uniform. If they did--have them arrest you
						// or attack you (if it's military)!
						if(class<ClothesInv>(NewClothes).Default.bIsCopUniform)
							policec.HandleNewImpersonator(MyPawn);
						count++;
					}
				}
				else if(policec == None)
				// If this person didn't see us, and it's not a cop, and they are attacking me
				// then make them forget they were attacking me (but they could remember if I do
				// something stupid, like keep my gun out when I'm the dude, etc.)
				{
					personc.LostAttackerToDisguise(MyPawn);
				}
			}
		}

		// Cops are handled seperately when losing the dude to a costume change because
		// they are of a 'hive' mind.
		// If nooooooooo cops see you changing into a different outfit--erase your police record!
		// Set the cop radio wanted status to 0, so cops don't arrest you
		if(count == 0)
		{
			P2GameInfoSingle(Level.Game).TheGameState.ResetCopRadioTime();
			// Also, (this slowness doesn't get noticed because the screen's black as we
			// change our clothes) go back through the cops that were chasing you, if there
			// were any, and make them paranoid, looking for their attacker
			foreach CollidingActors(class'P2Pawn', CheckP, WATCH_ME_CHANGE_RADIUS, MyPawn.Location)
			{
				policec = PoliceController(CheckP.Controller);
				if(policec != None)
				{
					// Get confused and start looking around for the attacker they just lost
					policec.LostAttackerToDisguise(MyPawn);
				}
			}
		}
	}
	// Save our new clothes
	CurrentClothes = NewClothes;
}

///////////////////////////////////////////////////////////////////////////////
// Just finished putting my clothes on, say something funny
///////////////////////////////////////////////////////////////////////////////
function FinishedPuttingOnClothes()
{
	if(class<ClothesInv>(CurrentClothes).Default.bIsCopUniform)
		NowIsCop();
	else if(CurrentClothes == class'DudeClothesInv')
		NowIsDude();
	else if(CurrentClothes == class'GimpClothesInv')
		NowIsGimp();
}

///////////////////////////////////////////////////////////////////////////////
// I'm dressed as boring old me...
///////////////////////////////////////////////////////////////////////////////
function bool DudeIsDude()
{
	return (CurrentClothes == class'DudeClothesInv');
}

///////////////////////////////////////////////////////////////////////////////
// I'm dressed a cop! (for ai use)
///////////////////////////////////////////////////////////////////////////////
function bool DudeIsCop()
{
	return (class<ClothesInv>(CurrentClothes).Default.bIsCopUniform);
}

///////////////////////////////////////////////////////////////////////////////
// I'm dressed the gimp! (for ai use)
///////////////////////////////////////////////////////////////////////////////
function bool DudeIsGimp()
{
	return (ClassIsChildOf(CurrentClothes, class'GimpClothesInv'));
}

///////////////////////////////////////////////////////////////////////////////
// Player doesn't have the map selected, but wants to use it now anyway
///////////////////////////////////////////////////////////////////////////////
exec function QuickUseMap()
{
	local Inventory inv;

	if( Level.Pauser!=None)
		return;

	if(Pawn != None)
	{
		// Find the map in his inventory, then activate it manually, but *don't* switch
		// to it
		inv = Pawn.Inventory;

		while(inv != None
			&& MapInv(inv) == None)
		{
			inv = inv.Inventory;
		}

		// If we found it, activate it
		if(MapInv(inv) != None)
		{
			inv.GotoState('Activated');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Switch directly to your hands weapon, or back to whatever
// weapon you had out before you toggled to your hands.
///////////////////////////////////////////////////////////////////////////////
exec function ToggleToHands(optional bool bForce)
{
	ClientToggleToHands(bForce);
}

///////////////////////////////////////////////////////////////////////////////
// Is simply just the body when called 
///////////////////////////////////////////////////////////////////////////////
function ClientToggleToHands(optional bool bForce)
{
	if( Level.Pauser!=None)
		return;

	// If you're not also pressing fire, then do this
	if(Pawn != None
		//mypawnfix
		&& (!Pawn.PressingFire()
			|| bForce))
	{
		WeaponSelector.ResetIndexes();
		// If we're not using our hands, then remember what weapon this is
		// and switch to it
		if(Pawn.Weapon == None
			|| Pawn.Weapon.InventoryGroup != MyPawn.HandsClass.default.InventoryGroup)
		{
//			// Don't remember that you were using your urethra, or your hands before
//			if(
			if(Pawn.Weapon != None)
			{
				if(Pawn.Weapon.InventoryGroup != MyPawn.HandsClass.default.InventoryGroup)
				{
					// Remember what weapon we we're using
					LastWeaponGroupHands = Pawn.Weapon.InventoryGroup;
					LastWeaponOffsetHands= Pawn.Weapon.GroupOffset;
				}
			}
			else
			{
				// If you didn't have one, say it's your hands
				LastWeaponGroupHands = MyPawn.HandsClass.default.InventoryGroup;
				LastWeaponOffsetHands = MyPawn.HandsClass.default.GroupOffset;
			}
			// If we're switching from our fists, disable it so the cops will arrest us
			if (LastWeaponSeen == Pawn.Weapon
				&& !Pawn.Weapon.bCanThrow)
				LastWeaponSeen = None;
			// Switch to the best version of the hands in this group (we might
			// need to use the clipboard as our hands for one day).
			SwitchToLastWeaponInGroup(MyPawn.HandsClass.default.InventoryGroup);
			return;
		}
		else // already using our hands
		{
			// If we're peeing, don't remember that we are, just stop peeing and switch
			// back to our hands, preserving the weapon we were using before
			if(Pawn.Weapon.GroupOffset == class'UrethraWeapon'.default.GroupOffset)
			{
				SwitchToLastWeaponInGroup(MyPawn.HandsClass.default.InventoryGroup);
				return;
			}
			// If we were using our hands, and the last weapon we remember is a legitimate
			// weapon (like a pistol) then switch to it.
			if(LastWeaponGroupHands != MyPawn.HandsClass.default.InventoryGroup)
			{
				// Switch to our old weapon, but if it fails, make our hands the one's
				// were switching too, and don't switch at all.
				if(!SwitchToThisWeapon(LastWeaponGroupHands, LastWeaponOffsetHands))
				{
					LastWeaponGroupHands = MyPawn.HandsClass.default.InventoryGroup;
					LastWeaponOffsetHands = MyPawn.HandsClass.default.GroupOffset;
				}
			}
			/*
			// Removed--We used to make your hands come out when you 'fired' the hands
			// but this confused people because they didn't know what they could do with them.
			//
			// If the last weapon we remember is also our hands, then just make them
			// stick out so the player can see this
			else if(LastWeaponOffsetHands == MyPawn.HandsClass.default.GroupOffset)
			{
				Fire();
			}
			*/
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Switch directly to your hands weapon
// If you force this, it will override anything in the hands that say don't
// currently show the hands (ex: the clipboard hands will override the normal
// hands, but sometimes (on suicide) you want the normal hands no matter what)
///////////////////////////////////////////////////////////////////////////////
exec function SwitchToHands(optional bool bForce)
{
	if( Level.Pauser!=None)
		return;

	// If you're not also pressing fire, then do this
	if(Pawn != None
		&& Pawn.Weapon.class != MyPawn.HandsClass
		//mypawnfix
		&& (!Pawn.PressingFire()
			|| bForce))
	{
		// If we're switching from our fists, disable it so the cops will arrest us
		if (LastWeaponSeen == Pawn.Weapon
			&& !Pawn.Weapon.bCanThrow)
			LastWeaponSeen = None;
		SwitchToThisWeapon(MyPawn.HandsClass.default.InventoryGroup, 
						MyPawn.HandsClass.default.GroupOffset, true);
	}
}

///////////////////////////////////////////////////////////////////////////////
// If we've gone through a level transition that takes our weapons/inventory
// use this to reset the toggle button
///////////////////////////////////////////////////////////////////////////////
function ResetHandsToggle()
{
	// If you didn't have one, say it's your hands
	LastWeaponGroupHands = MyPawn.HandsClass.default.InventoryGroup;
	LastWeaponOffsetHands = MyPawn.HandsClass.default.GroupOffset;
}

///////////////////////////////////////////////////////////////////////////////
// Do you have only your hands out?
///////////////////////////////////////////////////////////////////////////////
function bool HasHandsOut()
{
	local P2Weapon p2weap;

	p2weap = P2Weapon(Pawn.Weapon);

	if(p2weap != None
		&& p2weap.IsIdle()
		&& p2weap.IsA('HandsWeapon'))
		return true;

	return false;
}

///////////////////////////////////////////////////////////////////////////////
//Throw out current weapon, and switch to a new weapon
// OR
// in special situations, when ordered by a cop, you can drop the
// last weapon you had, if you're on your hands weapon
//
//
//  Last part is the same as PlayerController version. Copying this over just to control
// the speed and direction. Called on client/single player game.
///////////////////////////////////////////////////////////////////////////////
exec function ThrowWeapon()
{
	if( Level.Pauser!=None)
		return;

	if(Pawn == None)
		return;

	//  if you're also pressing fire, then don't allow this
	if(Pawn.PressingFire())
		return;

	if( P2Weapon(Pawn.Weapon)==None)
		return;

    ServerThrowWeapon();
}

///////////////////////////////////////////////////////////////////////////////
// Server part of actually throwing out the weapon.
///////////////////////////////////////////////////////////////////////////////
function ServerThrowWeapon()
{
	local Inventory inv;
	local bool bFoundIt;
	local P2Weapon PossiblePendingWeapon;

	// If we're being told by a cop to drop the weapon we've concealed by
	// switching to our hands, then by pressing this button, during this time
	// we will automatically stay on our hands weapon, but drop the last weapon
	// we knew about
	// So if the hints are on, and we're on a hands type weapon, and the last
	// weapon we had wasn't a hands type, then to find it, and drop it.
	if(bShowWeaponHints
		&& P2Weapon(Pawn.Weapon).bArrestableWeapon
		&& LastWeaponSeen != None
		&& !LastWeaponSeen.default.bArrestableWeapon)
	{
		inv = Pawn.Inventory;

		// Find that inventory item
		while(inv != None
			&& !bFoundIt)
		{
			if(inv != None 
				&& inv.InventoryGroup == LastWeaponSeen.default.InventoryGroup 
				&& inv.GroupOffset == LastWeaponSeen.default.GroupOffset)
				bFoundIt=true;
			else
				inv = inv.Inventory;
		}

		if(bFoundIt)
		{
			// Find the inventory we're talking about
			if(MyPawn.TossThisInventory(GenTossVel(), inv))
			{
				// If it worked, say the cop noticed, so say you don't
				// have anything right now
				LastWeaponSeen=None;
				// Set it to your hands or whatever you have now, since the last
				// weapon we were set to, has just been thrown
				LastWeaponGroupHands = MyPawn.Weapon.InventoryGroup;
				LastWeaponOffsetHands= MyPawn.Weapon.GroupOffset;
			}
		}
	}
	else	// Otherwise, just try to drop the weapon we have
	{
		if(!Pawn.Weapon.bCanThrow)
			return;

		// Throw it out now
		Pawn.TossWeapon(GenTossVel());

		// If it worked
		if(Pawn.Weapon == None
			|| Pawn.Weapon.Instigator == None)
		{
			// If we're being told by a cop to drop our weapon, say we dropped it
			if(bShowWeaponHints)
			{
				LastWeaponSeen=None;
			}
			// Always switch to your hands after dropping a weapon
			ToggleToHands();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// The player unzips his pants, and prepares his urethra for peeing. 
// The Fire button makes him actually pee.
///////////////////////////////////////////////////////////////////////////////
exec function UseZipper( optional float F )
{
	if(P2Pawn(Pawn) == None
		//mypawnfix
		|| P2Pawn(Pawn).bPlayerStarting)
		return;

	// Don't allow this to unpause the game
	if ( Level.Pauser == PlayerReplicationInfo )
		return;

	//  if you're also pressing fire, then don't allow this
	if(Pawn.PressingFire())
	{
		return;
	}
	
	// Must have a urethra to go pee
	if(P2Pawn(Pawn).MyUrethra == None)
	{
		log("I'm a p2pawn and I have no urethra "$self);
		return;
	}

	//log(self$" my weapon "$MyPawn.Weapon$" urethra "$MyPawn.MyUrethra);
	// Unzip pants and prepare to pee
	if(Pawn.Weapon != P2Pawn(Pawn).MyUrethra)
	{
		//log("unzip pants",'Debug');
		if(Pawn.Weapon != None)
		{
			LastWeaponGroupPee = Pawn.Weapon.InventoryGroup;
			LastWeaponOffsetPee= Pawn.Weapon.GroupOffset;
		}
		else
		{
			LastWeaponGroupPee = 1;
			LastWeaponOffsetPee= 0;
		}

		SwitchToThisWeapon(class'UrethraWeapon'.default.InventoryGroup,
						class'UrethraWeapon'.default.GroupOffset);
	}
	// Pants are already down, so zip them back up
	else if(!P2Pawn(Pawn).MyUrethra.IsInState('NormalFire'))
	{
		bPee=0;
		// Head back to the weapon we had up before we started peeing
		//log("switch back to gun at"@LastWeaponGroupPee@LastWeaponOffsetPee,'Debug');
		SwitchToThisWeapon(LastWeaponGroupPee, LastWeaponOffsetPee);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Search through the players inventory and use the most powerful health he has.
///////////////////////////////////////////////////////////////////////////////
exec function QuickHealth()
{
	local Inventory inv;
	local P2PowerupInv pickme;
	local float healval, maxheal;

	if( Level.Pauser!=None)
		return;

	if(Pawn != None)
	{
		//mypawnfix
		inv = Pawn.Inventory;

		while(inv != None)
		{
			if(P2PowerupInv(inv) != None)
			{
				healval = P2PowerupInv(inv).RateHealingPower();
				if(maxheal < healval)
				{
					maxheal = healval;
					pickme = P2PowerupInv(inv);
				}
			}
			inv = inv.Inventory;
		}

		// Heal the player with this item
		if(pickme != None)
		{
			// Don't let him use food when he's over the max--only crack.
			if(Pawn.Health < P2Pawn(Pawn).HealthMax
				|| CrackInv(pickme) != None)
			{
				pickme.Activate();
				MyHUD.LocalizedMessage(class'PickupMessagePlus', ,,,,pickme.HealingString);
			}
		}
		else
		{
			MyHUD.LocalizedMessage(class'PickupMessagePlus', ,,,,NoMoreHealthItems);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Timers are used for talking and could interrupt our count. 
// We'll add up how long it's been since we used crack in the state code
// of PlayerMoving and PlayerClimbing and such.
///////////////////////////////////////////////////////////////////////////////
function CheckForCrackUse(float TimePassed)
{
	local float OldTime;
	local int i;

	// if we have a 0 time, we're not addicted
	//mypawnfix
	if(P2Pawn(Pawn).CrackAddictionTime <= 0)
		return;

	OldTime = P2Pawn(Pawn).CrackAddictionTime;

	P2Pawn(Pawn).CrackAddictionTime-=TimePassed;

	if(OldTime >= CrackHintTimes[0])
	{
		for(i=0; i<MAX_CRACK_HINTS; i++)
		{
			if(P2Pawn(Pawn).CrackAddictionTime <= CrackHintTimes[i]
				&& OldTime > CrackHintTimes[i])
			{
				// Say How you need more crack
				P2Pawn(Pawn).Say(P2Pawn(Pawn).myDialog.lDude_NeedMoreCrackHealth);
				// Swap to crack in your inventory if you have it
				SwitchToThisPowerup(class'CrackInv'.default.InventoryGroup,
									class'CrackInv'.default.GroupOffset);
			}
		}
	}
	else	// You didn't find crack in time, so you get hurt badly by it
	{
		if(P2Pawn(Pawn).CrackAddictionTime <= 0)
		{
			P2Pawn(Pawn).CrackAddictionTime = 0;
			P2Pawn(Pawn).TakeDamage(CrackDamagePercentage*Pawn.Health, MyPawn, Pawn.Location,
						vect(0,0,0), class'CrackSmokingDamage');
			// reset the heart after you've been hurt by it
			ResetHeart();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check to turn on/off this weapon
///////////////////////////////////////////////////////////////////////////////
function SetWeaponUseability(bool bUseable, class<P2Weapon> weapclass)
{
	local Inventory inv;

	//mypawnfix
	inv = Pawn.Inventory;

	while(inv != None)
	{
		if(inv.class == weapclass
			&& P2Weapon(inv) != None)
		{
			P2Weapon(inv).SetReadyForUse(bUseable);
			return;
		}
		inv = inv.Inventory;
	}
}

///////////////////////////////////////////////////////////////////////////////
// You're ready to take down signatures, only if you have your clipboard out
///////////////////////////////////////////////////////////////////////////////
function bool ClipboardReady()
{
	if(ClipboardWeapon(MyPawn.Weapon) != None
		&& (MyPawn.Weapon.IsInState('NormalFire')
			|| MyPawn.Weapon.IsInState('Idle')
			|| MyPawn.Weapon.IsInState('WaitForResponse')))
		return true;

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Dude is asking for money to be donated to him or a charity
///////////////////////////////////////////////////////////////////////////////
function DudeAskForMoney(vector AskPoint, float AskRadius, 
						 actor HitActor,		// actor we hit with our test forward.. dude's aiming at this guy
						 bool bIsForCharity)
{
	local FPSPawn CheckP, KeepP;
	local float keepdist, checkdist, usedot;
	local byte StateChange;
	local int useline;
	local LambController lambc;
	local PersonController personc;
	
	// Check to see if we lost our interest
	if (InterestPawn != None
		&& (InterestPawn.IsInState('Dying')
			|| !InterestPawn.Controller.IsInState('CheckToDonate')
		)
		)
		InterestPawn = None;

	// Don't even try this if you're already talking to someone
	if(InterestPawn != None
		|| bDealingWithCashier)
		return;

	keepdist = 2*AskRadius;

	// Check if we were aiming at someone in particular
	CheckP = FPSPawn(HitActor);
	if(CheckP != None)
	{
		if(CheckP != MyPawn									// not me
			&& CheckP.Health > 0)							// live people are listening
			KeepP = FPSPawn(HitActor);
	}

	if(KeepP == None)	// we weren't aiming at anyone in particular so look for someone
	{
		// Do a collision test in this area, where you would have stopped the trace
		ForEach VisibleCollidingActors(class'FPSPawn', CheckP, AskRadius, AskPoint)
		{
			if(CheckP != MyPawn									// not me
				&& CheckP.Health > 0							// live people are listening
				&& FastTrace(MyPawn.Location, CheckP.Location)  // not on the other side of a wall
				&& ((Normal(CheckP.Location - MyPawn.Location) Dot vector(MyPawn.Rotation)) > PETITION_FOV))
				// and generally in front of the dude
			{
				checkdist = VSize(CheckP.Location - AskPoint);

				if(keepdist > checkdist)
				{
					keepdist = checkdist;
					KeepP = CheckP;
				}
			}
		}
	}

	if(KeepP != None)
	{
		personc = PersonController(KeepP.controller);
		if(personc != None)
			useline = personc.DonatedBotherCount;
	}

	// Say to give me money
	switch(useline)
	{
		case -2:
			// Person's dealing with me so leave early
			return; 
		case -1:
		case 0:
			//log("-----------------------dude dialogue: please sign this");
			SayTime = MyPawn.Say(MyPawn.myDialog.lDude_Petition1);
		break;
		case 1:
			//log("-----------------------dude dialogue: sign it now!");
			SayTime = MyPawn.Say(MyPawn.myDialog.lDude_Petition2);
		break;
		case 2:
			//log("-----------------------dude dialogue: sign it or i kill you");
			SayTime = MyPawn.Say(MyPawn.myDialog.lDude_Petition3);
		break;
	}
	SetTimer(SayTime + 1.0, false);
	bStillTalking=true;


	// Tell them who's talking to me
	if(KeepP != None)
	{
		lambc = LambController(KeepP.Controller);
	}

	if(lambc != None)
	{
		lambc.RespondToTalker(MyPawn, None, TALK_askformoney, StateChange);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Make the dude reach out and grab money
///////////////////////////////////////////////////////////////////////////////
function GrabMoneyPutInCan(int MoneyToGet)
{
	local ClipboardWeapon canweap;

	canweap = ClipboardWeapon(Pawn.Weapon);
	//log(canweap@"grab money put in can"@moneytoget);

	if(canweap != None)
	{
		// play anim on clipboard to get signature
		canweap.CauseAltFire();
		// set how many sigs to give the dude, probably just 1
		canweap.PendingMoney = MoneyToGet;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get a certain amount of money to be given to us
///////////////////////////////////////////////////////////////////////////////
function DudeTakeDonationMoney(int MoneyToGet, bool bIsForCharity)
{
	local ClipboardWeapon canweap;
	local P2GameInfoSingle checkg;

	canweap = ClipboardWeapon(Pawn.Weapon);

	if(bIsForCharity)
	{
		if(canweap != None)
		{
			// grant us the money in the can
			if(!canweap.AmmoType.AddAmmo(MoneyToGet))
			{
				checkg = P2GameInfoSingle(Level.Game);
				if(checkg != None)
				{
					// Now that the errand is complete, after the idle plays on the clipboard
					// it will determine when it's okay to remove the clipboard and use the
					// normal hands again
					checkg.CheckForErrandCompletion(canweap, None, None, self, false);
				}
			}
		}
	}

	// say thanks
	InterestPawn = None;
	SayTime = MyPawn.Say(MyPawn.myDialog.lThanks);
	SetTimer(SayTime + 1.0, false);
	bStillTalking=true;
}

///////////////////////////////////////////////////////////////////////////////
// Returns the number of dollars the player has right now.
///////////////////////////////////////////////////////////////////////////////
function float CashPlayerHas()
{
	return MyPawn.HowMuchInventory(class'MoneyInv');
}

///////////////////////////////////////////////////////////////////////////////
// Setup textures for prizes player won
///////////////////////////////////////////////////////////////////////////////
function SetupTargetPrizeTextures()
{
	local int kills;
	local Material gettex;
	local class<Powerups> pclass;
	local P2PowerupInv p2inv;
	local byte CreatedNow;

	if(P2Hud(MyHUD).TargetPrizes.Length > 0)
		P2Hud(MyHUD).TargetPrizes.Remove(0, P2Hud(MyHUD).TargetPrizes.Length);
	kills = RadarTargetKills;
	// Allocate the ones we've one
	while(kills > 0)
	{
		pclass = None;

		// Various prizes for each kill level
		switch(kills)
		{
			case 1:
				pclass = class<Powerups>(DynamicLoadObject("Inventory.DonutInv", class'Class'));break;
			case 2:
				pclass = class<Powerups>(DynamicLoadObject("Inventory.PizzaInv", class'Class'));break;
			case 3:
				pclass = class<Powerups>(DynamicLoadObject("Inventory.FastFoodInv", class'Class'));break;
			case 5: // nothing for 4
				pclass = class<Powerups>(DynamicLoadObject("Inventory.KevlarInv", class'Class'));break;
			case 8:// nothing for 6-7
				pclass = class<Powerups>(DynamicLoadObject("Inventory.CrackInv", class'Class'));break;
			case 12:// nothing for 9-11
				pclass = class<Powerups>(DynamicLoadObject("Inventory.CatNipInv", class'Class'));break;
				// nothing else past this
		}

		if(pclass != None)
		{
			gettex = pclass.default.Icon;

			// put in the texture list
			P2Hud(MyHUD).TargetPrizes.Insert(P2Hud(MyHUD).TargetPrizes.Length, 1);
			P2Hud(MyHUD).TargetPrizes[P2Hud(MyHUD).TargetPrizes.Length-1] = gettex;
			// give it to the player
			CreatedNow=0;
			p2inv = P2PowerupInv(MyPawn.CreateInventoryByClass(pclass,CreatedNow));
			if(p2inv != None
				&& CreatedNow == 0)
				p2inv.AddAmount(class<P2PowerupPickup>(p2inv.PickupClass).default.AmountToAdd);
		}

		kills--;
	}
}

/*
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ViewShake(float DeltaTime)
{
	local float VelDampen, AccMag;
	local vector checkdiff, checkvel;

	Super.ViewShake(DeltaTime);

	if(!bSniperSettled
		&& bSniperStartToSettle
		&& DesiredFOV != DefaultFOV)
	{
		checkdiff = SniperVect - OldShakeOffset;

		VelDampen = VSize(checkdiff);
		if(SniperDampen > VelDampen)
			SniperDampen = VelDampen;

//		if(abs(checkdiff.x) < SNIPER_MIN_VECT
//			&& abs(checkdiff.y) < SNIPER_MIN_VECT
//			&& abs(checkdiff.z) < SNIPER_MIN_VECT)
		if(SniperDampen < SNIPER_DAMPEN_MIN)
		{
			log(self$" end swing "$SniperVect);
			bSniperSettled=true;
			SniperVect = vect(0, 0, 0);
			SniperVect = vect(0, 0, 0);
		}
		else
		{
			SniperVel = (DeltaTime*(-checkdiff)) + SniperDampen*SniperVel;
			SniperVect += DeltaTime*SniperVel;
			log(self$" vect "$checkdiff$" vel "$SniperVel$" acc "$SniperAcc$" time "$DeltaTime);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// We calculate things that need to take over the player's view here, like the
// sniper rifle movement, or throwing up in first-person
///////////////////////////////////////////////////////////////////////////////
function UpdateRotation(float DeltaTime, float maxPitch)
{
	local vector rotdiff;
	local float swingmag;

	Super.UpdateRotation(DeltaTime, maxPitch);

	rotdiff = (vector(Rotation) - vector(OldRotation));

	if(rotdiff.x == 0
		&& rotdiff.y == 0
		&& rotdiff.z == 0)
	{
		if(!bSniperStartToSettle
			&& RifleWeapon(Pawn.Weapon) != None
			&& DesiredFOV != DefaultFOV)
		{
			SniperDampen = 0.95;
			bSniperStartToSettle=true;
			bSniperSettled=false;
			swingmag = VSize(SwingDir);
			swingmag += 0.1;
			SniperVect = 500*swingmag*Normal(SwingDir);
			SniperVel = SniperVect;
			log(self$" start swing "$SniperVect$" swing dir "$SwingDir$" swing dir mag "$swingmag);
		}
	}
	else
	{
		bSniperSettled=false;
		bSniperStartToSettle=false;
		SwingDir = (rotdiff + SwingDir)/2;
	}

	OldRotation = Rotation;
}
*/

///////////////////////////////////////////////////////////////////////////////
// Turns every current non-player, bystander pawns into Gary Colemans
// It's easy to debug in a player controller (hard in a cheat manager)
///////////////////////////////////////////////////////////////////////////////
function GarySize()
{
	local FPSPawn checkpawn;
	local Gary newgary;
	local vector useloc;
	local rotator userot;
	local Inventory CheckInv;

	if(!CheatsAllowed())
		return;

	log(self$" CHEAT: Whatchutalkinbout");
	ClientMessage("Gary-sizing your bystanders--please wait.");

	foreach DynamicActors(class'FPSPawn', checkpawn)
	{
		if(!checkpawn.bPlayer
			&& !checkpawn.bSliderStasis
			&& BystanderController(checkpawn.Controller) != None
			&& CashierController(checkpawn.Controller) == None
			&& RWSController(checkpawn.Controller) == None
			&& Gary(checkpawn) == None)
		{
			useloc = checkpawn.Location;
			userot = checkpawn.Rotation;
			checkpawn.Destroy();
			newgary = spawn(class'Gary',,,useloc,userot,GarySkins[Rand(GarySkins.Length)]);
			if (newgary != None 
				&& newgary.Controller == None
				&& newgary.Health > 0 )
			{
				// Don't put the real gary controller on these... you'l have the right
				// dialog, and the real one has a cashier controller and needs other things.
				newgary.Controller = spawn(class'BystanderController');
				if ( newgary.Controller != None )
				{
					newgary.Controller.Possess(newgary);
					newgary.CheckForAIScript();
					
					// Delete errand-use items
					for (CheckInv = newgary.Inventory; CheckInv != None; CheckInv = CheckInv.Inventory)
						if (P2PowerupInv(CheckInv) != None
							&& P2PowerupInv(CheckInv).UseForErrands != 0)
						{
							newgary.DeleteInventory(CheckInv);
							break;
						}
				}
				else
					newgary.Destroy();					
			}
		}
	}

	MyPawn.PlaySound(GaryTalking);
}

// Puts Mike J heads on everything. Loads of fun!
function JewTown()
{
	local P2MoCapPawn CheckPawn;
	
	foreach DynamicActors(class'P2MoCapPawn', CheckPawn)
	{
		if (!checkpawn.bPlayer
			//&& CheckPawn.MyRace == Race_White
			//&& !CheckPawn.bIsFemale
			&& CheckPawn.MyHead != None
			//&& !CheckPawn.bIsFat
			&& CheckPawn.Controller != None)
		{
			CheckPawn.MyHead.Setup(MikeJHeadMesh, MikeJHeadSkin, CheckPawn.MyHead.DrawScale3D, CheckPawn.MyHead.AmbientGlow);
			CheckPawn.MyDialog = P2GameInfo(Level.Game).GetDialogObj(MikeJDialog);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Turns every current non-player, bystander pawns into this class
// Newclass should be higher level than Bystander.
///////////////////////////////////////////////////////////////////////////////
function ConvertNonImportants(class<P2Pawn> newclass, optional class<AIController> contclass,
							optional bool bHatesPlayer, optional bool bGunCrazy,
							optional bool bNoMales, optional bool bNoFemales)
{
	local FPSPawn checkpawn;
	local FPSPawn newpawn;
	local vector useloc;
	local rotator userot;
	local Inventory CheckInv;

	if(contclass == None)
		contclass = newclass.default.ControllerClass;

	foreach DynamicActors(class'FPSPawn', checkpawn)
	{
		if(!checkpawn.bPlayer
			&& !checkpawn.bSliderStasis
			&& (!bNoMales
				|| checkpawn.bIsFemale)
			&& (!bNoFemales
				|| !checkpawn.bIsFemale)
			&& BystanderController(checkpawn.Controller) != None
			&& CashierController(checkpawn.Controller) == None
			&& RWSController(checkpawn.Controller) == None
			&& !ClassIsChildOf(checkpawn.class, newclass))
		{
			useloc = checkpawn.Location;
			userot = checkpawn.Rotation;
			checkpawn.Destroy();
			newpawn = spawn(newclass,,,useloc,userot);
			if (newpawn != None 
				&& newpawn.Controller == None
				&& newpawn.Health > 0 )
			{
				// Don't put the real gary controller on these... you'l have the right
				// dialog, and the real one has a cashier controller and needs other things.
				if ( (contclass != None))
					newpawn.Controller = spawn(contclass);
				if ( newpawn.Controller != None )
				{
					newpawn.Controller.Possess(newpawn);
					newpawn.CheckForAIScript();
					if(bHatesPlayer)
						newpawn.bPlayerIsEnemy = bHatesPlayer;
					if(bGunCrazy
						&& P2Pawn(newpawn) != None)
						P2Pawn(newpawn).bGunCrazy = bGunCrazy;
					// Delete errand-use items
					for (CheckInv = newpawn.Inventory; CheckInv != None; CheckInv = CheckInv.Inventory)
						if (P2PowerupInv(CheckInv) != None
							&& P2PowerupInv(CheckInv).UseForErrands != 0)
						{
							newpawn.DeleteInventory(CheckInv);
							break;
						}
				}
				else
					newpawn.Destroy();
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Blow smoke for smoking health pipe and catnip.
///////////////////////////////////////////////////////////////////////////////
simulated function BlowSmoke(vector smokecolor)
{
	local PipeSmokeFPS smokeff;
	local float useoffset;
	local vector useloc;
	local rotator userot;

	// generate smoke effect
	if(bBehindView)
	{
		//mypawnfix
		useloc = P2MocapPawn(Pawn).MyHead.Location;
		userot = P2MocapPawn(Pawn).MyHead.Rotation;
		useoffset = Pawn.EyeHeight-8;
	}
	else
	{
		useloc = ViewTarget.Location;
		userot = ViewTarget.Rotation;
		useoffset = 0;
		CalcFirstPersonView(useloc, userot);
	}

	smokeff = spawn(class'PipeSmokeFPS',Pawn,,useloc, userot);
	smokeff.SetDirection(Pawn.Velocity, useoffset);
	smokeff.TintIt(smokecolor);
}

///////////////////////////////////////////////////////////////////////////////
// Generate food crumb effect only in MP so you can see
// when someone is eating to make it feel more fair
///////////////////////////////////////////////////////////////////////////////
function EatingFood()
{
	local vector useloc;
	local rotator userot;
	local coords checkc;

	const FOOD_DIST = 25;

	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
	{
		//mypawnfix
		checkc = Pawn.GetBoneCoords(BONE_HEAD);

		// hacking use of rotation to store velocity
		userot.Pitch = Pawn.Velocity.x;
		userot.Yaw   = Pawn.Velocity.y;
		userot.Roll  = Pawn.Velocity.z;
		useloc = checkc.origin + FOOD_DIST*vector(Pawn.Rotation) + FOOD_DIST*Normal(Pawn.Velocity);
		spawn(class'FoodCrumbMaker',MyPawn,,useloc, userot);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Show a flash of color for when you're hurt by chem infection clouds
///////////////////////////////////////////////////////////////////////////////
function FlashChemHurt()
{
	local ChemHurtEmitter cheme;
	local float useoffset;
	local vector useloc;
	local rotator userot;

	// Generate flashy effect
	if(!bBehindView)
	{
		useloc = ViewTarget.Location;
		userot = ViewTarget.Rotation;
		useoffset = 0;
		CalcFirstPersonView(useloc, userot);
		cheme = spawn(class'ChemHurtEmitter',MyPawn,,useloc, userot);
		cheme.SetDirection(Pawn.Velocity,0);
	}
}

///////////////////////////////////////////////////////////////////////////////
// If he's essentially someone you'd meet out on the street and kill, he's okay.
// Bystanders and cops/military are included, but protestors/osamas/etc aren't
// because in the linear play situations, you'd run into so many streams in a row
// it'd be way too easy to get.
///////////////////////////////////////////////////////////////////////////////
function bool ValidQuickKill(P2Pawn DeadGuy)
{
	return (PoliceController(DeadGuy.Controller) != None || DeadGuy.bInnocent);
}

///////////////////////////////////////////////////////////////////////////////
// Start complaining about being hungry to get the player to go 
// to the fast food restaurant in the hub level.
///////////////////////////////////////////////////////////////////////////////
function StartHungry()
{
	//log(self$" start hungry "$dudecomplaining,'Debug');
	if(dudecomplaining != None
		&& !dudecomplaining.bDeleteMe)
		dudecomplaining.Destroy();
	if(dudehungryclass != None)
		dudecomplaining = spawn(dudehungryclass, self);
}
function StopHungry()
{
	//log(self$" stop hungry "$dudecomplaining,'Debug');
	if(dudecomplaining != None
		&& !dudecomplaining.bDeleteMe)
		dudecomplaining.Destroy();

	dudecomplaining = None;
}

///////////////////////////////////////////////////////////////////////////////
// Start saying lines about hunting cows
///////////////////////////////////////////////////////////////////////////////
function StartCowHunting()
{
	//log(self$" start cow hunting "$dudecomplaining);
	if(dudecomplaining != None
		&& !dudecomplaining.bDeleteMe)
		dudecomplaining.Destroy();
	if(dudecowhuntingclass != None)
		dudecomplaining = spawn(dudecowhuntingclass, self);
	//log(self$" started cow hunting - "$dudecomplaining);
}
function StopCowHunting()
{
	//log(self$" stop cow hunting "$dudecomplaining);
	if(dudecomplaining != None
		&& !dudecomplaining.bDeleteMe)
		dudecomplaining.Destroy();

	dudecomplaining = None;
}

///////////////////////////////////////////////////////////////////////////////
// Find the first instance of the enemy with this tag and show his health
// while the player tries to kill him.
///////////////////////////////////////////////////////////////////////////////
function StartKillBoss(Texture HudPawnIcon, name EnemyTag, optional bool bPercentageDisplay, optional bool bWillow, optional string WillowText)
{
	AddKillJob(HudPawnIcon, EnemyTag,, bPercentageDisplay, bWillow, WillowText);
	/*
	local FPSPawn usep;
	
	if(!bKillJob)
	{
		// Find our trigger that tracks our kills
		foreach DynamicActors(class'FPSPawn', usep, EnemyTag)
		{
			if(usep != None)
				KillEnemy = usep;
		}
		// If it succeeds, continue
		if(KillEnemy != None)
		{
			bKillJob=true;
			// tell your hud about the new texture
			BossPawnIcon = HudPawnIcon;
			P2Hud(MyHud).BossIcon = HudPawnIcon;
		}
	}
	*/
}

///////////////////////////////////////////////////////////////////////////////
// Tell the player to start showing hud data during a kill job. AWTrigger
// in level keeps track of kills. 
///////////////////////////////////////////////////////////////////////////////
function StartKillCount(Texture HudPawnIcon, name TriggerTag, optional bool bPercentageDisplay)
{
	local int i;
	
	i = AddKillJob(HudPawnIcon, '', TriggerTag, bPercentageDisplay);
	// AddKillJob is defined in P2Player and doesn't have access to AWTrigger,
	// so we still need to link the trigger here.
	if (i > -1)
		AWTrigger(KillJobs[i].KillTrigger).PlayerWatch = self;
	/*
	local AWTrigger usetrig;

	if(!bKillJob)
	{
		// Find our trigger that tracks our kills
		foreach DynamicActors(class'AWTrigger', usetrig, TriggerTag)
		{
			if(usetrig != None)
				break;
		}
		// If it succeeds, continue
		if(usetrig != None)
		{
			bKillJob=true;
			// tell your hud about the new texture
			KillPawnIcon = HudPawnIcon;
			P2Hud(MyHud).KillIcon = HudPawnIcon;
			// link trigger to us
			usetrig.PlayerWatch = self;
			// Save time
			StartKillTime=Level.TimeSeconds;
		}
	}
	*/
}

///////////////////////////////////////////////////////////////////////////////
// Turn it all off
///////////////////////////////////////////////////////////////////////////////
function FinishKillCount(name FinishTag)
{
	//AWGameState(P2GameInfoSingle(Level.Game).TheGameState).FinishKillCount(Level.TimeSeconds - StartKillTime, KillTrigger.Tag);
	RemoveKillJob(FinishTag);
	/*
	bKillJob=false;
	P2Hud(MyHud).KillIcon = None;
	KillPawnIcon = None;
	KillTrigger = None;
	*/
}

///////////////////////////////////////////////////////////////////////////////
// Look at trigger/boss and tell HUD the values.
///////////////////////////////////////////////////////////////////////////////
function GetKillJobValues(int Index, out int UseCount, out int UseMax, out int bPercentageDisplay)
{
	local AWTrigger AWTrig;
	
	// Sanity check.
	if (Index >= KillJobs.Length)
	{
		warn("In GetKillJobValues: invalid Index!");
		return;
	}
	
	if (KillJobs[Index].BossPawn != None)
	{
		UseCount = KillJobs[Index].BossPawn.Health;
		UseMax = KillJobs[Index].BossPawn.HealthMax;
		if (KillJobs[Index].bPercentageDisplay)
			bPercentageDisplay = 1;
		else
			bPercentageDisplay = 0;
		// As soon as we know he's dead, remove everything
		if (UseCount <= 0)
			FinishKillCount(KillJobs[Index].BossPawn.Tag);
	}
	else if (KillJobs[Index].KillTrigger != None)
	{
		AWTrig = AWTrigger(KillJobs[Index].KillTrigger);
		// Sanity check
		if (AWTrig == None)
		{
			warn("Invalid trigger in kill job");
			return;
		}
		UseMax = AWTrig.TimesTillTrigger;
		UseCount = AWTrig.UseTimes;
		// Check to shake the kill count.
		if (KillJobs[Index].OldCount == 0
			&& UseCount == 0)
			KillJobs[Index].OldCount = UseCount;
		else if (KillJobs[Index].OldCount != UseCount)
		{
			KillJobs[Index].OldCount = UseCount;
			KillJobs[Index].ShakeKillTime = SHAKE_KILL_TIME;
		}		
		if (KillJobs[Index].bPercentageDisplay)
			bPercentageDisplay = 1;
		else
			bPercentageDisplay = 0;
	}
	else
	{
		// Kill count invalid. Spam log warnings until it's fixed
		warn("Boss pawn and Kill Trigger missing in kill count!");
		FinishKillCount(KillJobs[Index].BossPawn.Tag);
		return;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Look at trigger and tell hud what we still need to do
///////////////////////////////////////////////////////////////////////////////
function GetKillCountVals(out int UseMax, out int UseCount)
{
	// STUB, no longer used.
	
	/*
	if(KillTrigger != None)
	{
		UseMax = KillTrigger.TimesTillTrigger;
		UseCount = KillTrigger.UseTimes;
	}
	*/
}

function RestoreCheat(string CheatToRestore)
{
	ConsoleCommand("RestoreCheat"@CheatToRestore);
}

// Player scored a nutshot, tell the achievement manager.
function ScoredNutShot(P2Pawn Victim)
{
	if(Level.NetMode != NM_DedicatedServer ) GetEntryLevel().GetAchievementManager().UpdateStatInt(self, 'PLNutshots', 1, true);
}

///////////////////////////////////////////////////////////////////////////////
// Go into dual-wield mode
///////////////////////////////////////////////////////////////////////////////
function SetupDualWielding(float starttime)
{
	// FIXME this could probably be cleaned up and implemented better (conflict with Gary Heads weapon?)
	Super.SetupDualWielding(StartTime);
	if(starttime > 0)
	{
		// Go into head-injury overlay mode for effect
		//AWDude(Pawn).HasHeadInjury=1;
		//P2Hud(myHUD).DoWalkHeadInjury();
		Pawn.PlaySound(BeginDualWield, SLOT_Interface);
		Pawn.AmbientSound=DualWieldAmbient;
	}
	else // reset things
	{
		// Turn off the head effects (but only if they were present to begin with)
		//if (AWDude(Pawn).HasHeadInjury == 1)
		if (Pawn.AmbientSound != None)
		{
			//AWDude(Pawn).HasHeadInjury=0;
			//P2Hud(myHUD).StopHeadInjury();
			Pawn.PlaySound(EndDualWield, SLOT_Interface);
			Pawn.AmbientSound = None;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// LastWeapon
///////////////////////////////////////////////////////////////////////////////
exec function SwitchToLastWeapon()
{
	log("Switch to last weapon"@LastWeaponGroup@LastWeaponOffset@"Current"@Pawn.Weapon@"Pending"@Pawn.PendingWeapon);
	if (Pawn.PendingWeapon != None && Pawn.PendingWeapon.InventoryGroup == LastWeaponGroup && Pawn.PendingWeapon.GroupOffset == LastWeaponOffset)
		return;
		
	SwitchToThisWeapon(LastWeaponGroup, LastWeaponOffset);
	RegisterLastWeapon();
}
function RegisterLastWeapon()
{
	log("Register last weapon current"@Pawn.Weapon@"pending"@Pawn.PendingWeapon);
	if (Pawn.Weapon != None && (LastWeaponGroup != Pawn.Weapon.InventoryGroup || LastWeaponOffset != Pawn.Weapon.GroupOffset))
	{
		LastWeaponGroup = Pawn.Weapon.InventoryGroup;
		LastWeaponOffset = Pawn.Weapon.GroupOffset;
		log("Last weapon registered as"@LastWeaponGroup@LastWeaponOffset);
	}
}
exec function SwitchToBestWeapon()
{
	Super.SwitchToBestWeapon();
	if (Pawn.PendingWeapon != None)
		RegisterLastWeapon();
}
function bool SwitchAfterOutOfAmmo()
{
	local bool bResult;
	
	bResult = Super.SwitchAfterOutOfAmmo();
	
	if (Pawn.PendingWeapon != None)
		RegisterLastWeapon();

	return bResult;
}	
function bool SwitchToThisWeapon(int GroupNum, int OffsetNum, optional bool bForceReady)
{
	local bool bResult;
	
	bResult = Super.SwitchToThisWeapon(GroupNum, OffsetNum, bForceReady);
	
	if (Pawn.PendingWeapon != None)
		RegisterLastWeapon();

	return bResult;
}
exec function SwitchToLastWeaponInGroup(int GroupNum)
{
	Super.SwitchToLastWeaponInGroup(GroupNum);
	
	if (Pawn.PendingWeapon != None)
		RegisterLastWeapon();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Functions for new Weapon Selector
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
protected function AddWeaponSelector()
{
	local int i;

	// Verify that WeaponSelectorClassName is valid.
	assert(DynamicLoadObject(WeaponSelectorClassName, class'Class') != None);

	for(i = 0; i < Player.LocalInteractions.Length; i++)
	{
		if(Player.LocalInteractions[i].IsA('P2WeaponSelector'))
		{
			WeaponSelector = P2WeaponSelector(Player.LocalInteractions[i]);
			WeaponSelector.RefreshSelector();
			return;
		}
	}

	if(WeaponSelector == None)
		WeaponSelector = P2WeaponSelector(Player.InteractionMaster.AddInteraction(WeaponSelectorClassName, Player));
}
function HideWeaponSelector()
{
	if (WeaponSelector != None)
		WeaponSelector.ResetIndexes();
}

function Possess(Pawn aPawn)
{
	super.Possess(aPawn);
	AddWeaponSelector();
	AddInventorySelector();
}

function NotifyDeleteInventory(Inventory OldItem)
{
	if(OldItem.IsA('Weapon'))
		WeaponSelector.RemoveWeapon(Weapon(OldItem));
}

exec function PrevWeapon()
{
	// Ignore while zooming with the rifle or other zoom weapon
	if (P2Weapon(Pawn.Weapon) != None
		&& P2Weapon(Pawn.Weapon).IsZoomed())
	{
		Super.PrevWeapon();
		return;
	}

    if(WeaponSelector != None
		&& class'P2GameInfo'.Default.bUseWeaponSelector)
	{
		WeaponSelector.PrevWeapon();
		// Handle bPrevWeapon
		if (bPrevWeapon != 0 || bNextWeapon != 0)
		{
			LastWeaponChange = Level.TimeSeconds;
			RapidWeaponChange++;
		}
		else
			RapidWeaponChange = 0;
		if (P2GameInfo(Level.Game).bWeaponSelectorAutoSwitch)
			WeaponSelector.SwitchWeaponByIndex(true);
	}
	else
		Super.PrevWeapon();
		
	if (Pawn.PendingWeapon != None)
		RegisterLastWeapon();
}

exec function NextWeapon()
{
	// Ignore while zooming with the rifle or other zoom weapon
	if (P2Weapon(Pawn.Weapon) != None
		&& P2Weapon(Pawn.Weapon).IsZoomed())
	{
		Super.NextWeapon();
		return;
	}
	
	// If we're putting a cat on the gun, don't bring up the weapon selector
	if ((CatableWeapon(Pawn.Weapon) != None && CatableWeapon(Pawn.Weapon).bPutCatOnGun)
		|| (DualCatableWeapon(Pawn.Weapon) != None && DualCatableWeapon(Pawn.Weapon).bPutCatOnGun))
	{
		Super.NextWeapon();
		return;
	}

    if(WeaponSelector != None
		&& class'P2GameInfo'.Default.bUseWeaponSelector
		&& !Pawn.Weapon.IsInState('WaitingOnBlade'))
	{
		WeaponSelector.NextWeapon();
		// Handle bNextWeapon
		if (bPrevWeapon != 0 || bNextWeapon != 0)
		{
			LastWeaponChange = Level.TimeSeconds;
			RapidWeaponChange++;
		}
		else
			RapidWeaponChange = 0;
		if (P2GameInfo(Level.Game).bWeaponSelectorAutoSwitch)
			WeaponSelector.SwitchWeaponByIndex(true);
	}
	else
		Super.NextWeapon();
		
	if (Pawn.PendingWeapon != None)
		RegisterLastWeapon();		
}

exec function SwitchWeapon(byte F)
{
    if(WeaponSelector != None
		&& class'P2GameInfo'.Default.bUseWeaponSelector)
	{
		WeaponSelector.SwitchWeapon(F);
		if (P2GameInfo(Level.Game).bWeaponSelectorAutoSwitch)
			WeaponSelector.SwitchWeaponByIndex(true);
	}
	else
		Super.SwitchWeapon(F);
		
	if (Pawn.PendingWeapon != None)
		RegisterLastWeapon();		
}

exec function Fire(float Value)
{
	if((WeaponSelector != None) && (WeaponSelector.ValidIndexesSelected())
		&& class'P2GameInfo'.Default.bUseWeaponSelector)
	{
		if(WeaponSelector.SwitchWeaponByIndex() && !P2GameInfo(Level.Game).bWeaponSelectorAutoSwitch)
		{
			if (Pawn.PendingWeapon != None)
				RegisterLastWeapon();
			return;
		}
	}
	Super.Fire(Value);
}

exec function AltFire(float Value)
{
	if((WeaponSelector != None) && (WeaponSelector.ValidIndexesSelected())
		&& class'P2GameInfo'.Default.bUseWeaponSelector)
	{
		WeaponSelector.ResetIndexes();
		return;
	}
	Super.AltFire(Value);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Functions for new Inventory Selector
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
protected function AddInventorySelector()
{
	local int i;

	// Verify that WeaponSelectorClassName is valid.
	assert(DynamicLoadObject(InventorySelectorClassName, class'Class') != None);

	for(i = 0; i < Player.LocalInteractions.Length; i++)
	{
		if(Player.LocalInteractions[i].IsA('P2InventorySelector'))
		{
			InventorySelector = P2InventorySelector(Player.LocalInteractions[i]);
			return;
		}
	}

	if(InventorySelector == None)
		InventorySelector = P2InventorySelector(Player.InteractionMaster.AddInteraction(InventorySelectorClassName, Player));
}

exec function InventoryMenu()
{
	if (InventorySelector != None)
		InventorySelector.ToggleMenu();
	else
		warn("DudePlayer::InventoryMenu() - InventorySelector == NONE");
}

function bool InventoryMenuVisible()
{
	if (InventorySelector != None)
		return InventorySelector.bMenuVisible;
	else
		return false;
}

defaultproperties
	{
	CurrentClothes=class'DudeClothesInv'
	DefaultClothes=class'DudeClothesInv'
	CheatClass=class'P2CheatManager'
	GaryTalking=Sound'GaryDialog.gary_whatchutalkin'
	GarySkins[0]=Texture'ChameleonSkins.Special.Gary'
	GarySkins[1]=Texture'MPSkins.MB__136__Mini_M_Jacket_Pants'
	GarySkins[2]=Texture'MPSkins.MB__137__Mini_M_Jacket_Pants'
	dudehungryclass=Class'DudeHungry'
	dudecowhuntingclass=Class'DudeCowHunting'
	CopBribeHint1="Hmm, maybe this officer could be bribed?"
	CopBribeHint2="Press %KEY_InventoryActivate% to offer him some money."
	MikeJHeadSkin=Texture'ChamelHeadSkins.MWA__006__AvgMale'
	MikeJHeadMesh=Mesh'Heads.AvgMale'
	MikeJDialog="BasePeople.DialogMikeJ"
	WeaponSelectorClassName="GameTypes.P2WeaponSelector"
	InventorySelectorClassName="GameTypes.P2InventorySelector"
}
