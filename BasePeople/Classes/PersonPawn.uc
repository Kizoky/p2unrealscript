//=============================================================================
// PersonPawn
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// High-level person stuff.
//
//	History:
//		05/08/02:	NPF	Created. Took most from P2MocapPawn.
//
// 8/11 - Kamek backport from AW.
//=============================================================================
class PersonPawn extends MpPawn
	abstract;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var Material ColemansCrewSkin;
// external
var (PawnAttributes)bool	bAllowBareHands;	// Set to false to turn off the "bare hands" weapon given to tougher NPC's.
var (PawnAttributes)byte	CloseWeaponIndex;	// These two indices determine where to look in BaseEquipment
var (PawnAttributes)byte	FarWeaponIndex;		// for the two weapons to use when determining close and far
												// weapons chosen by WeapChangeDist; Defaults to 0 and 1, but
												// Police override this (to accomodate handcuffs and batons)
var string HandsClassNormal;	// Class of hands to use
var string HandsClassEnhanced;	// Class of hands to use for the Dude in enhanced mode

// internal
var UrinePourFeeder			FluidSpout;				// Blood(or puke) squirting in heavy volumes from something important

var bool					bGotDefaultInventory;	// Whether this pawn already got its default inventory
var Sound RicHit[2];								// Ricochet noises.
var class<PartDrip>	PeeBody;	// Body effect for pee dripping from me
var class<PartDrip>	GasBody;	// Same for gas

var(PawnAttributes) class<MeatExplosion> GibsClass;	// Class of meaty chunks to spawn when gibbed
var class<Weapon> UrethraClass;

// RANDOM DROPS
// These allow LDs or modders to decide what kind of pawns can drop what items at random,
// even if they don't "own" one as assigned in BaseEquipment.
struct RandomDrop
{
	var() class<Pickup> DropClass;		// Class of pickup to drop
	var() range DropAmount;				// How much of this thing we should drop. Will always drop at least 1.
	var() array<StaticMesh> DropMesh;	// If this is filled in, picks a random static mesh for the drop (for things like donuts, etc.)
};
struct RandomDropDef
{
	var() export editinline array<RandomDrop> DropItem;// Definition of item(s) to drop. If this is empty, all entries beyond this one will be ignored!
	var() float DropRate;				// How often this will drop (0.0 = never drop, 0.5 = drop 50% of the time, 1.0 = always drop)	
	// Everything below this line are advanced settings that most LDs/modders won't need to mess with if all you want to do is add in a custom item
	var() array<bool> DropDifficulties;	// Boolean flags for which difficulty levels this item is valid to drop in. If empty, the item will drop in any difficulty
										// Valid difficulty levels are 0-10 for a regular game, and 0-15 for custom difficulties
										// (note: everything Manic and above counts as 10, there are separate flags for They Hate Me, etc.)
	var() array<bool> DropDays;			// Boolean flags for which day this item is valid to drop in. If empty, the item will drop on any day	
	// For these settings, the following values are valid:
	//		 0 = Don't care
	//		-1 = Never drop in this difficulty
	//		 1 = Drop only in this difficulty
	var() byte DropInExpertMode;		// Whether to drop the item in "expert mode" (POSTAL, Impossible, custom difficulty with Expert mode checked)
	var() byte DropInCustomMode;		// Whether to drop the item in custom-difficulty mode (Up, Up, Down, Down, Left, Right, Left, Right at difficulty select)
	var() byte DropInLieberMode;		// Whether to drop the item in Liebermode (Liebermode or custom difficulty with NPC weapons set to Liebermode)
	var() byte DropInHestonMode;		// Whether to drop the item in Hestonmode (Hestonworld, POSTAL, or custom difficulty with NPC weapons set to Hestonworld)
	var() byte DropInHateMeMode;		// Whether to drop the item in They Hate Me mode (They Hate Me, POSTAL, Impossible, or custom difficulty with They Hate Me checked)
	var() byte DropInInsaneMode;		// Whether to drop the item in Insane-o mode (Insane-o, Impossible, or custom difficulty with NPC weapons set to Insane-o)
	var() byte DropInLudicrousMode;		// Whether to drop the item in Ludicrous mode (Custom difficulty with NPC weapons set to Ludicrous)
	var() byte DropInEnhancedMode;		// Whether to drop the item in the Enhanced Game (Note that the Box Launcher will only drop in the Enhanced Game regardless of this setting)
};

var (RandomDrops) export editinline array<RandomDropDef> RandomDrops;	// List of possible random drops, see above for config.

// These are arrays of weapon class names that are handed out to bystanders during certain difficulty modes.
var array<string> 	RandomLieberWeapons,		// Melee or other "sissy" weapons given out in Liebermode
					RandomHestonWeapons,		// Guns given out in Hestonworld
					RandomInsaneWeapons,		// Guns and powerful weapons given out in Insane-o
					RandomRareWeapons,			// Rare weapons to be given out in Insane-o
					RandomMeleeWeapons,			// Melee weapons (custom difficulty only)
					RandomLudicrousWeapons,		// Ludicrously strong weapons for Ludicrous diffculty
					RandomLudicrousWeaponsRare,
					RandomLudicrousWeaponsSuperRare,
					RandomMassDestructionWeapons;

const HEAD_MOVE_Z_UP_BIG_TEMP_VARIABLE	=	5;
const EASY_HEAD_HIT						=	2.5;
var float ADJUST_RELATIVE_HEAD_X;
// Adding these two so we can fix the dude head later
var float ADJUST_RELATIVE_HEAD_Y;
var float ADJUST_RELATIVE_HEAD_Z;

// These index into BaseEquipment for the distance-based weapon changing code for NPC's
const CLOSE_WEAPON_INDEX	= 0;
const FAR_WEAPON_INDEX		= 1;

const COP_RUN_MOD			= 0.92;
const NPC_RUN_MOD			= 0.9;

const PEE_BONE				= 'p_bone';

const GLARE_FORWARD			= 70;
const GLARE_UP				= 40;

// Chance to drop Doggy Treats and Donuts in POSTAL/Impossible Mode.
const POSTAL_DOGGY_CHANCE = 0.10;
const POSTAL_DONUT_CHANCE = 0.20;
const POSTAL_PIZZA_CHANCE = 0.15;
const POSTAL_FOOD_CHANCE = 0.10;
const INSANE_RARE_WEAPON_CHANCE = 0.10;
const MONEY_DROP_CHANCE = 0.10;
const NORMAL_FOOD_DROP_CHANCE = 0.10;

const IMPOSSIBLE_GANG_NAME = "PlayerHater";
const IMPOSSIBLE_HEALTH_PCT = 1.25;
const MELEE_BLOCK_MIN_HESTON = 0.25;
const MELEE_BLOCK_MAX_HESTON = 0.50;

const MELEE_BLOCK_MIN_INSANE = 0.50;
const MELEE_BLOCK_MAX_INSANE = 1.00;

// xPatch: New consts for Ludicrous difficulty
const LUDICROUS_RARE_WEAPON_CHANCE = 0.25;
const LUDICROUS_SUPER_RARE_WEAPON_CHANCE = 0.08;
const LUDICROUS_MELEE_BLOCK_MIN	= 0.75;
const LUDICROUS_ADVANCED_FIRE = 0.50;
const LUDICROUS_DUAL_WIELD = 0.35;
const CRACKOLA_DROP_LUDICROUS = 0.15;

// xPatch: New variables
var (RandomDrops)bool		NoRandomDrops; 		// If set to true NPC will not perform any random item drops.
var (RandomDrops)RandomDrop	GuranteedDrop; 		// Set if you want the NPC to drop a specified item upon death.
var (RandomWeapons)bool		bAllowRandomGuns;	// Weapons can be replaced if the xPatch option is enabled and it's not Classic Game.
var (RandomWeapons)bool		bForceRandomGuns;	// Foreces replacement ignoring everything.

struct ReplacementsDef
{
	var() class<P2Weapon> RandomWeapon;		// Class of weapon we replace with
	var string RandomWeaponStr;			// For dynamic load if we can't access it via class.
};
struct RandomGunsDef
{
	var() export editinline array<ReplacementsDef> Replacements;
	var() class<P2Weapon> DefaultWeapon;		// Class of default weapon we want to be replaced
	var() float Chance;							// Chance of this default weapon being replaced (0.0 = never, 0.5 = 50% of the time, 1.0 = always)	
};
var (RandomWeapons) export editinline array<RandomGunsDef> RandomGuns;

// Defined in P2MoCapPawn.
/*
///////////////////////////////////////////////////////////////////////////////
// Someone is about to attack us with a big weapon! (like a sledge or scythe)
// Do something!
///////////////////////////////////////////////////////////////////////////////
function BigWeaponAlert(P2MoCapPawn Swinger)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Flying machete coming our way--check to block it!
///////////////////////////////////////////////////////////////////////////////
function BlockMelee(Actor MeleeAttacker)
{
	// STUB
}
///////////////////////////////////////////////////////////////////////////////
//  If we can block this melee attack
///////////////////////////////////////////////////////////////////////////////
function CheckBlockMelee(vector HitLocation, out byte StateChange)
{
	// STUB
}
*/

///////////////////////////////////////////////////////////////////////////////
// For better compatibility with updated ACTION_ChangeWeapon
///////////////////////////////////////////////////////////////////////////////
function class<Weapon> GetHandsClass()
{
	local class<Weapon> UseClass;
	
	if (bPlayer && Level.Game.bIsSinglePlayer
		&& P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Controller.bIsPlayer)
		UseClass = class<Weapon>(DynamicLoadObject(HandsClassEnhanced, class'Class'));
	else
		UseClass = class<Weapon>(DynamicLoadObject(HandsClassNormal, class'Class'));
		
	return UseClass;
}

///////////////////////////////////////////////////////////////////////////////
// Used to make a new inventory item with a class
// Kamek 11/20 fix bug where PawnSpawners could bypass Liebermode restrictions
///////////////////////////////////////////////////////////////////////////////
function Inventory CreateInventoryByClass(class<Inventory> MakeMe,
										  optional out byte CreatedNow,
										  optional bool bIgnoreDifficulty)

{
	local class<P2Weapon> p2weapclass;
	local int randpick;
	local class<Inventory> useclass;
	local Inventory inv;
	local bool bHasMelee;

	//debuglog(self@"create inventory"@MakeMe@CreatedNow);

	p2weapclass = class<P2Weapon>(MakeMe);
	
	// If you're in Liebermode and this is a violent weapon, change
	// it to a weak one (but don't bother the player)
	if(p2weapclass != None
		&& (P2GameInfo(Level.Game).InLiebermode() || P2GameInfo(Level.Game).InMeeleMode())
		&& p2weapclass.default.ViolenceRank >= class'PistolWeapon'.default.ViolenceRank
		&& !bPlayer
		&& !bIgnoreDifficulty)
	{
		// Replace this violent weapon granted to us via PawnSpawner with some other melee weapon
		// But not if they already have a melee weapon of some kind
		bHasMelee = false;
		for (inv = Inventory; Inv != None; Inv = Inv.Inventory)
		{
			if (P2Weapon(Inv) != None
				&& P2Weapon(Inv).bMeleeWeapon)
			{
				bHasMelee = true;
				break;
			}
		}
		if (bHasMelee)
			return None;
		else if(P2GameInfo(Level.Game).InMeeleMode())
			return CreateInventory(RandomMeleeWeapons[Rand(RandomMeleeWeapons.Length)]);
		else
			return CreateInventory(RandomLieberWeapons[Rand(RandomLieberWeapons.Length)]);

		/*
		randpick = Rand(3);
		switch(randpick)
		{
			case 0:
				useclass = class'BatonWeapon';
				break;
			case 1:
				useclass = class'ShovelWeapon';
				break;
			case 2:
				useclass = class'ShockerWeapon';
				break;
		}*/

	}
	else
		useclass = MakeMe;

	//debuglog("going to super"@UseClass@CreatedNow);

	return Super.CreateInventoryByClass(useclass, CreatedNow, bIgnoreDifficulty);
}

///////////////////////////////////////////////////////////////////////////////
// Clean up
///////////////////////////////////////////////////////////////////////////////
event Destroyed()
{
	if(FluidSpout != None)
	{
		RemoveFluidSpout();
		FluidSpout.Destroy();
		FluidSpout=None;
	}

	StopPuking();

	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Pawn is possessed by Controller
///////////////////////////////////////////////////////////////////////////////
function PossessedBy(Controller C)
{
	if(C != None)
	{
		if(C.bIsPlayer)
		{
			GroundSpeed = default.GroundSpeed;
			BaseMovementRate = default.BaseMovementRate;
			//log(self$" setting player to default run speeds "$GroundSpeed);
		}
		else if(bAuthorityFigure)
		{
			GroundSpeed = COP_RUN_MOD*default.GroundSpeed;
			BaseMovementRate = COP_RUN_MOD*default.BaseMovementRate;
			//log(self$" setting COP to slower run speeds "$GroundSpeed);
		}
		else
		{
			GroundSpeed = NPC_RUN_MOD*default.GroundSpeed;
			BaseMovementRate = NPC_RUN_MOD*default.BaseMovementRate;
			//log(self$" setting NPC to slower run speeds "$GroundSpeed);
		}
	}

	Super.PossessedBy(C);
}

///////////////////////////////////////////////////////////////////////////////
// Set dialog class
///////////////////////////////////////////////////////////////////////////////
function SetDialogClass()
	{
	// This must be checked for None here. The default properties on Gary or Habib
	// set his voice, then we want to preserve that and not reset it here to a white male.
	if(DialogClass == None)
		{
		// Dialog overrides based on skin
		if (Skins[0] == ColemansCrewSkin)
			DialogClass = class'DialogMaleBlack';
		else if (bIsFemale)
			DialogClass=class'BasePeople.DialogFemale';
		else
			DialogClass=class'BasePeople.DialogMale';
		}
	}


///////////////////////////////////////////////////////////////////////////////
// Setup and destroy head
///////////////////////////////////////////////////////////////////////////////
function SetupHead()
{
	local rotator rot;
	local vector v;

	Super.SetupHead();

	// Create head and attach to body
	if (HeadClass != None)
	{
		if (myHead == None)
		{
			myHead = spawn(HeadClass, self,,Location);
			if (myHead != None)
			{
				// Attach to body
				AttachToBone(myHead, BONE_HEAD);
			}
		}

		if (myHead != None)
		{
			// Setup the head
			myHead.Setup(HeadMesh, HeadSkin, HeadScale, AmbientGlow);

			// Rotate head so it looks right (this is temporary until the editor's
			// animation browser supports attachment sockets)
			rot.Pitch = 0;
			rot.Yaw = -16384;	// -18000 looks better but leaves a gap at back of neck!
			rot.Roll = 16384;
			myHead.SetRelativeRotation(rot);

			// Push the heads down a hair to hide the seam
			v.x = ADJUST_RELATIVE_HEAD_X;
			v.y = ADJUST_RELATIVE_HEAD_Y;
			v.z = ADJUST_RELATIVE_HEAD_Z;
			myHead.SetRelativeLocation(v);
		}
	}
	else
		Warn("No HeadClass defined for "$self);
}

///////////////////////////////////////////////////////////////////////////////
// Head goes into stasis
///////////////////////////////////////////////////////////////////////////////
function PrepBeforeStasis()
{
	Super.PrepBeforeStasis();
	// Turn off our physics to save cycles
	SetPhysics(PHYS_None);
	if(MyHead != None)
		MyHead.bStasis=true;
}
///////////////////////////////////////////////////////////////////////////////
// Head comes out of stasis
///////////////////////////////////////////////////////////////////////////////
function PrepAfterStasis()
{
	Super.PrepAfterStasis();
	// Turn physics back on
	SetPhysics(PHYS_Falling);
	if(MyHead != None)
		MyHead.bStasis=false;
}

///////////////////////////////////////////////////////////////////////////////
// If you have a melee/trace-based weapon, set that first as your main weapon
// and then find any distance-based thrown or shot weapons (like a grenade
// or rocket launcher). Then, take the AIRating and set it just under your
// lowest melee/trace-based weapon. Then the AI will pick the melee-trace
// most of the time, and
///////////////////////////////////////////////////////////////////////////////
function FindSecondaryRangeWeapon()
{
}

///////////////////////////////////////////////////////////////////////////////
// Set to false bGotDefaultInventory in personpawn
///////////////////////////////////////////////////////////////////////////////
function ResetGotDefaultInventory( )
{
	bGotDefaultInventory=false;
}

///////////////////////////////////////////////////////////////////////////////
// Adds all the required equipment and picks out the urethra.
// Do this here so we access to the inventory package for specific things
// like HandsWeapon and UrethraWeapon.
///////////////////////////////////////////////////////////////////////////////
function AddDefaultInventory()
{
	local int i, j, randpick;
	local Inventory thisinv;
	local P2PowerupInv pinv;
	local P2Weapon p2weap;
	local class<P2Weapon> p2weapclass;
	local int usedam;
	local int Count;
	local float TestBlockMeleeFreq;
	local bool bHasMeleeWeapon;
	// xPatch: 
	local xPatchManager xManager;
	local bool ClassicWeapons;
	local float randchance;
	
	xManager = P2GameInfoSingle(Level.Game).xManager;
	if(P2GameInfoSingle(Level.Game).InClassicMode() || xManager.bAlwaysOGWeapons)
		ClassicWeapons = True;

	// Only let this be called once
	if (!bGotDefaultInventory)
	{
		//Log(self$" PersonPawn.AddDefaultInventory() is adding inventory");
		// Everyone gets hands, so add that explicitly here
		// Players will get the new HandsWeapon, NPCs can get the normal ones
		// Only give this in enhanced mode.
        if (bPlayer && Level.Game.bIsSinglePlayer
			&& P2GameInfoSingle(Level.Game) != None
			&& P2GameInfoSingle(Level.Game).VerifySeqTime()
			&& Controller.bIsPlayer)
			{
				thisinv = CreateInventory(HandsClassEnhanced);
				HandsClass = class<P2Weapon>(thisinv.class);
			}
        else
            thisinv = CreateInventory(HandsClassNormal);

		// Defined in AWPerson
		/*
		// Give them a cell phone
		if (bCellUser && CellPhoneClass != None)
			CreateInventoryByClass(CellPhoneClass);
		else // No cell phone class means no calls
			bCellUser = False;
		*/

		// Handle money seperately
		if(MaxMoneyToStart > 0)
		{
			pinv = P2PowerupInv(CreateInventoryByClass(class'Inventory.MoneyInv'));
			pinv.SetAmount(MaxMoneyToStart);
		}
		
		bHasMeleeWeapon = false;
		
		// xPatch: Isn't it weird that The Dude is the only one using the new weapons?
		// I mean, in normal diffculties. Let's add some more guns vareity, for bystanders mostly.
		if( (bAllowRandomGuns && xManager.bRandomGuns && !ClassicWeapons) || bForceRandomGuns )
		{
			if(!bPlayer && RandomGuns.Length != 0 && BaseEquipment.Length != 0)
			{
				// Go through pawn's equipment
				for( i = 0 ; i < BaseEquipment.Length ; i++ )
				{	
					if(BaseEquipment[i].weaponclass != None)
					{
						// Go through RandomGuns array
						for( j = 0 ; j < RandomGuns.Length ; j++ )
						{
							// See if pawn have default weapon we want to replace
							if( BaseEquipment[i].weaponclass == RandomGuns[j].DefaultWeapon )
							{
								// Check the chance for replacement
								randchance = RandomGuns[j].Chance;
								if (FRand() <= randchance)
								{
									// Pick random replacement
									randpick = RandomGuns[j].Replacements.Length;
									randpick = Rand(randpick);
									
									// Use RandomWeapon (class) if defined. 
									if(RandomGuns[j].Replacements[randpick].RandomWeapon != None)
										p2weapclass = RandomGuns[j].Replacements[randpick].RandomWeapon;
									// If not do Dynamic Load of RandomWeaponStr.
									else if(RandomGuns[j].Replacements[randpick].RandomWeaponStr != "")
										p2weapclass = class<P2Weapon>(DynamicLoadObject(RandomGuns[j].Replacements[randpick].RandomWeaponStr, class'Class'));
										
									// And finally replace it
									BaseEquipment[i].weaponclass = p2weapclass;
								}
							}
						}
					}
				}
			}
		}
		
		// xPatch: Classic Mode
		if(ClassicWeapons && !bPlayer)
			ReplaceToClassicInventory();	
			
		// xPatch: Meele Mode (Custom Difficulty)
		// Clean up their BaseEquipment, they will get only melee.
		if(P2GameInfo(Level.Game).InMeeleMode()
			&& !bPlayer)
		{
			for ( i=0; i<BaseEquipment.Length; i++ )
			{
				if (BaseEquipment[i].weaponclass != None)
				{
					//log(self$" base equipment "$i$" weap "$BaseEquipment[i].weaponclass);
					p2weapclass = class<P2Weapon>(BaseEquipment[i].weaponclass);
					// If you're in Liebermode and this is a violent weapon, change
					if(p2weapclass != None) //&& !p2weapclass.default.bMeleeWeapon)
						BaseEquipment[i].weaponclass = None;
				}
			}
		}
		
		// xPatch: Restored this function so it can be used on custom maps by modders. 
		// It's disabled by default now and should not cause any problems anyway.
		
		// If they have a lot of balls, give them some fists for punching
		// Only do this if they don't have a melee weapon already.
		if (bAllowBareHands)
		{
			if (Cajones >= 0.4
			&& BaseEquipment.Length < 2
			&& !P2GameInfo(Level.Game).InLiebermode()	// Don't give out the fists in lieber mode, it screws with the melee weapon check and causes general weirdness
			&& !Controller.IsA('MuggerController')		// Don't give to muggers, they'll try to hold you up with fists instead
			&& !IsA('Gary') && !IsA('AWGary') && !IsA('AWScaredGary')	// Don't give to Gary
			&& Level.TimeSeconds == 0					// Don't give to PawnSpawner-spawned pawns - it tends to screw with the equipment PawnSpawners give them.
			)
			{
			BaseEquipment.Insert(0,1);
			BaseEquipment[0].WeaponClass = class'Inventory.FistsWeapon';
			CloseWeaponIndex = 0;
			FarWeaponIndex = 1;
			WeapChangeDist = 100;
			}
		}
		

		// Add in the extra stuff now
		for ( i=0; i<BaseEquipment.Length; i++ )
		{
			if (BaseEquipment[i].weaponclass != None)
			{
				//log(self$" base equipment "$i$" weap "$BaseEquipment[i].weaponclass);
				p2weapclass = class<P2Weapon>(BaseEquipment[i].weaponclass);

				// If you're in Liebermode and this is a violent weapon, change
				// it to a weak one (but don't bother the player)
				if(p2weapclass != None
					&& P2GameInfo(Level.Game).InLiebermode()
					&& p2weapclass.default.ViolenceRank >= class'PistolWeapon'.default.ViolenceRank
					&& !bPlayer)
				{
					// If you're a cop, don't let them have their pistols/machine guns
					// (leave them with batons)
					if(class == class'Police')
						BaseEquipment[i].weaponclass = None;
					else // Other people get random melee weapons in their inventories
					// but only if they don't have one already
					if (bHasMeleeWeapon)
						BaseEquipment[i].weaponclass = None;
					else
					{
						BaseEquipment[i].weaponclass = class<P2Weapon>(DynamicLoadObject(RandomLieberWeapons[Rand(RandomLieberWeapons.Length)],class'Class'));
						
						/*
						randpick = Rand(3);
						switch(randpick)
						{
							case 0:
								BaseEquipment[i].weaponclass = class'BatonWeapon';
								break;
							case 1:
								BaseEquipment[i].weaponclass = class'ShovelWeapon';
								break;
							case 2:
								BaseEquipment[i].weaponclass = class'ShockerWeapon';
								break;
						}
						*/
					}
				}

				// If you have anything at all
				if(BaseEquipment[i].weaponclass != None)
				{
					// Create the weapon from this base equipment index
					thisinv = CreateInventoryByClass(BaseEquipment[i].weaponclass);
					if (P2Weapon(thisinv) != None
						&& P2Weapon(thisinv).bMeleeWeapon)
						bHasMeleeWeapon=true;

					// Special weapon handling:
					// Keep track of the foot now, because we can't do it below (like the urethra)
					// --it's not added to the inventory list
					// Link up your foot
					if(FootWeapon(thisinv) != None)
					{
						MyFoot = P2Weapon(thisinv);
						MyFoot.GotoState('Idle');
						MyFoot.bJustMade=false;
						if(Controller != None)
							Controller.NotifyAddInventory(MyFoot);
						ClientSetFoot(P2Weapon(thisinv));
					}
				}
			}
		}
		
		// xPatch: Meele Mode (Custom Difficulty)
		// Melee weapons for everyone, yaay!
		if(P2GameInfo(Level.Game).InMeeleMode()
			&& !bPlayer)
		{
			CreateInventoryForDifficulty(RandomMeleeWeapons[Rand(RandomMeleeWeapons.Length)]);
				
			// And bump them up to be ready to fight
			if(PainThreshold < 1.0)
				PainThreshold = 1.0;
			if(Cajones < 1.0)
				Cajones = 1.0;
			TestBlockMeleeFreq=RandRange(MELEE_BLOCK_MIN_HESTON, MELEE_BLOCK_MAX_HESTON);
			if (BlockMeleeFreq < TestBlockMeleeFreq)
				BlockMeleeFreq = TestBlockMeleeFreq;
		}

		// If you're in heston mode, no matter what, always give them some more random guns
		// (unless you're the player)
		if(P2GameInfo(Level.Game).InHestonMode()
			&& !bPlayer)
		{
			// Change by Man Chrzan: xPatch 3.0
			/*CreateInventory(RandomHestonWeapons[Rand(RandomHestonWeapons.Length)]);*/
			CreateInventoryForDifficulty(RandomHestonWeapons[Rand(RandomHestonWeapons.Length)]);

			// And bump them up to be ready to fight
			if(PainThreshold < 1.0)
				PainThreshold = 1.0;
			if(Cajones < 1.0)
				Cajones = 1.0;
			TestBlockMeleeFreq=RandRange(MELEE_BLOCK_MIN_HESTON, MELEE_BLOCK_MAX_HESTON);
			if (BlockMeleeFreq < TestBlockMeleeFreq)
				BlockMeleeFreq = TestBlockMeleeFreq;
		}

		// If you're in Insane-o mode, no matter what, always give them some more random guns
		// (unless you're the player) (but give them more than heston)
		if(P2GameInfo(Level.Game).InInsaneMode()
			&& !bPlayer)
		{
			// Change by Man Chrzan: xPatch 3.0 
			if (FRand() <= INSANE_RARE_WEAPON_CHANCE)
				CreateInventoryForDifficulty(RandomRareWeapons[Rand(RandomRareWeapons.Length)]);
			else
				CreateInventoryForDifficulty(RandomInsaneWeapons[Rand(RandomInsaneWeapons.Length)]);

			// And bump them up to be ready to fight
			if(PainThreshold < 1.0)
				PainThreshold = 1.0;
			if(Cajones < 1.0)
				Cajones = 1.0;
			TestBlockMeleeFreq=RandRange(MELEE_BLOCK_MIN_INSANE, MELEE_BLOCK_MAX_INSANE);
			if (BlockMeleeFreq < TestBlockMeleeFreq)
				BlockMeleeFreq = TestBlockMeleeFreq;
		}

		// If you're in Ludicrous mode, no matter what, always give them some more random guns
		// (unless you're the player) (but give them more than Insane-O)
		if(P2GameInfo(Level.Game).InLudicrousMode()
			&& !bPlayer)
		{
			// Give them one of our awesome ludicrous weapons.			
			if (FRand() <= LUDICROUS_SUPER_RARE_WEAPON_CHANCE)
				CreateInventoryForDifficulty(RandomLudicrousWeaponsSuperRare[Rand(RandomLudicrousWeaponsSuperRare.Length)]);
			else if (FRand() <= LUDICROUS_RARE_WEAPON_CHANCE)
				CreateInventoryForDifficulty(RandomLudicrousWeaponsRare[Rand(RandomLudicrousWeaponsRare.Length)]);
			else
				CreateInventoryForDifficulty(RandomLudicrousWeapons[Rand(RandomLudicrousWeapons.Length)]);

			// And bump them up to be ready to fight
			if(PainThreshold < 1.0)
				PainThreshold = 1.0;
			if(Cajones < 1.0)
				Cajones = 1.0;
			TestBlockMeleeFreq=RandRange(LUDICROUS_MELEE_BLOCK_MIN, 1.00);
			if (BlockMeleeFreq < TestBlockMeleeFreq)
				BlockMeleeFreq = TestBlockMeleeFreq;
				
			// Allows them to burst fire etc.
			if (FRand() <= LUDICROUS_ADVANCED_FIRE)
				bAdvancedFiring=True;
			
			// Make them dual wield too, hahaha! (not in classic mode though)
			if (!ClassicWeapons && FRand() <= LUDICROUS_DUAL_WIELD)
				bForceDualWield = True;
				
			// Oh, and make them walk with the guns ready too!
			bRiotMode=True;
		}
		
		// A silly Custom Difficulty mode
		if(P2GameInfo(Level.Game).InNukeMode())
		{
			if(!bPlayer)
			{
				// Give them some weapons of mass destruction.
				CreateInventoryForDifficulty(RandomMassDestructionWeapons[Rand(RandomMassDestructionWeapons.Length)]);

				// And bump them up to be ready to fight
				if(PainThreshold < 1.0)
					PainThreshold = 1.0;
				if(Cajones < 1.0)
					Cajones = 1.0;
				TestBlockMeleeFreq=RandRange(MELEE_BLOCK_MIN_HESTON, MELEE_BLOCK_MAX_HESTON);
				if (BlockMeleeFreq < TestBlockMeleeFreq)
					BlockMeleeFreq = TestBlockMeleeFreq;
					
				// Allows them to burst fire etc.
				if (FRand() <= LUDICROUS_ADVANCED_FIRE)
					bAdvancedFiring=True;
			}
			else // Player gets it too, hell yeah!
			{
				for ( i=0; i<RandomMassDestructionWeapons.Length; i++ )
					CreateInventoryForDifficulty(RandomMassDestructionWeapons[i]);
			}
		}
		
		// If an NPC, give an NPC urethra
		if (!bPlayer)
			CreateInventoryByClass(Urethraclass);
		
		// tell the weapons they've been made now
		thisinv = Inventory;
		while(thisinv != None)
		{
			if(P2Weapon(thisinv) != None)
			{
				// After the creation of the weapon, while  normal weapons link up their ammo,
				// we wait and finally link up the urethra. Don't do it above, during the creation
				// of the weapon, it must wait till here.
				if(UrethraWeapon(thisinv) != None)
				{
					MyUrethra = Weapon(thisinv);
					MyUrethra.GiveAmmo(self);
					ClientSetUrethra(P2Weapon(thisinv));
				}

				P2Weapon(thisinv).bJustMade=false;
			}
			thisinv = thisinv.inventory;
			Count++;
			if (Count > 5000)
				break;
		}

		// Switch them as a default, to use their hands
		if(PersonController(Controller) != None)
			PersonController(Controller).SwitchToThisWeapon(StartWeapon_Group, StartWeapon_Offset);

		// If you're using distance-based weapon changing, then save the weapons to use
		if(WeapChangeDist > 0)
		{
			if(BaseEquipment.Length >= 2)
			{
				if(BaseEquipment[CloseWeaponIndex].weaponclass != None)
					CloseWeap = class<P2Weapon>(BaseEquipment[CloseWeaponIndex].weaponclass);
				if(CloseWeap == None)
					log(self$" ERROR: WeapChangeDist and Close weapon is invalid!");

				if(BaseEquipment[FarWeaponIndex].weaponclass != None)
					FarWeap = class<P2Weapon>(BaseEquipment[FarWeaponIndex].weaponclass);
				if(FarWeap == None)
					log(self$" ERROR: WeapChangeDist and Far weapon is invalid!");
			}
			else
			{
				log(self$" ERROR: WeapChangeDist set with only 1 weapon!");
				WeapChangeDist = 0;
			}
		}

		// Note that we got our default inventory
		bGotDefaultInventory = true;

		//log(self$" in they hate me: "$P2GameInfo(Level.Game).TheyHateMeMode()$" game diff "$P2GameInfo(Level.Game).GameDifficulty);
		// If you're in They Hate Me mode, make everyone hate the player.
		// Do this at the end, so we don't retry to do this whole function again in
		// the new Possess, should redo our controller (below)
		if(P2GameInfo(Level.Game).TheyHateMeMode()
			&& !bPlayer)
		{
			// Leave innocents and cashiers alone. Hostiles get
			// made more hostile.
			if(bHasViolentWeapon)
			{
				bPlayerIsEnemy=true;
				bPlayerIsFriend=false;
				bPlayerHater=true;
				// And bump them up to be ready to fight, if they have a weapon
				if(PainThreshold < 1.0)
					PainThreshold = 1.0;
				if(Cajones < 1.0)
					Cajones = 1.0;

				if(CashierController(Controller) == None)
				{
					// If you were a Cop/Military, then turn into a cop-like bystander
					// so you don't try arrests or anything like that.
					if(Controller.IsA('PoliceController')
						|| Controller.IsA('RWSController')
						//|| Controller.IsA('RedneckController')	// Fix for rednecks in brewery
						//|| Controller.IsA('KumquatController')
						)
					{
						Controller.Destroy();
						Controller = None;
						Controller = spawn(class'BystanderController');
						if(Controller != None )
						{
							Controller.Possess(self);
							AIController(Controller).Skill += SkillModifier;
							CheckForAIScript();
						}
					}
				}
			}
		}
		// If they're in Impossible (or Ludicrous) mode, put them all on the same gang and make them even more tough
		if (P2GameInfo(Level.Game).InNightmareMode()
			&& (P2GameInfo(Level.Game).InInsaneMode() || P2GameInfo(Level.Game).InLudicrousMode())
			&& !bPlayer)
		{
			Gang = IMPOSSIBLE_GANG_NAME;
			HealthMax *= IMPOSSIBLE_HEALTH_PCT;
			Health = HealthMax;
			Compassion = 0;
			WarnPeople = 0;
			Psychic = FMax(Psychic, 0.75);
			WillDodge = FMax(WillDodge, 0.75);
			WillKneel = FMax(WillKneel, 0.75);
			WillUseCover = FMax(WillUseCover, 0.75);
			Confidence = 1;
			Fitness = 1;
			Glaucoma = FMin(Glaucoma, 0.5);
			TakesOnFireDamage = FMin(TakesOnFireDamage, 0.5);
			TakesShotgunHeadShot = FMin(TakesShotgunHeadShot, 0.75);
			//TakesRifleHeadShot = FMin(TakesRifleHeadShot, 0.75);
			TakesShovelHeadShot = FMin(TakesShovelHeadShot, 0.75);
			TakesAnthraxDamage = FMin(TakesAnthraxDamage, 0.75);
			TakesShockerDamage = FMin(TakesShockerDamage, 0.75);
			TakesPistolHeadShot = FMin(TakesPistolHeadShot, 0.75);
		}

		// Make sure *un-armed* bystanders take one pistol bullet if you hit them exactly in the middle
		if(!bHasViolentWeapon
			&& bInnocent)
		{
			// Calculate pistol damage for one hit kills.
			usedam = class'PistolBulletAmmoInv'.default.DamageAmount*class'Dude'.default.DamageMult - 1;
			//log(self$" new health "$usedam);
			HealthMax = usedam;
			Health = HealthMax;
		}	
		//log(self$" initting for new level, game info diff "$P2GameInfoSingle(Level.Game).GameDifficulty$" game state diff "$P2GameInfoSingle(Level.Game).TheGameState.GameDifficulty$" GET game state diff "$P2GameInfoSingle(Level.Game).GetGameDifficulty());
	}
	//else
	//{
	//	Log(self$" PersonPawn.AddDefaultInventory() is being bypassed because inventory was added already");
	//}
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: Allows us to replace new weapons to old ones in Classic Game
///////////////////////////////////////////////////////////////////////////////
function ReplaceToClassicInventory()
{
	local int i, j;
	local xPatchManager xManager;
	local class<P2Weapon> p2weapclass;
	local class<P2Weapon> AWweapclass[3];
	
	xManager = P2GameInfoSingle(Level.Game).xManager;
	
			for( i = 0 ; i < BaseEquipment.Length ; i++ )
			{
				// Replace weapons using the list from P2GameInfoSingle
				if(BaseEquipment[i].weaponclass != None)
				{
					if( P2GameInfoSingle(Level.Game).ClassicModeReplace.Length != 0 )
					{
						for( j = 0 ; j < P2GameInfoSingle(Level.Game).ClassicModeReplace.Length ; j++ )
						{
							p2weapclass = class<P2Weapon>(DynamicLoadObject(P2GameInfoSingle(Level.Game).ClassicModeReplace[j].OldClass, class'Class'));
							if( p2weapclass != None && p2weapclass == BaseEquipment[i].weaponclass && !xManager.IsException(P2GameInfoSingle(Level.Game).ClassicModeReplace[j].OldClass))
							{
								BaseEquipment[i].weaponclass = class<P2Weapon>(DynamicLoadObject(P2GameInfoSingle(Level.Game).ClassicModeReplace[j].NewClass,class'Class'));
							}
						}
					}
				}

				// Extra check for AW Weapons
				if((xManager.bAlwaysOGWeapons && xManager.bNoAWWeaponsRG) 
					|| (P2GameInfoSingle(Level.Game).InClassicMode() && xManager.bNoAWWeapons))
				{	
					AWweapclass[0] = class<P2Weapon>(DynamicLoadObject("AWInventory.MacheteWeapon", class'Class'));
					AWweapclass[1] = class<P2Weapon>(DynamicLoadObject("AWInventory.SledgeWeapon", class'Class'));
					AWweapclass[2] = class<P2Weapon>(DynamicLoadObject("AWInventory.ScytheWeapon", class'Class'));
						
					// Don't let them have AW weapons
					if(BaseEquipment[i].weaponclass == AWweapclass[0] 
						|| BaseEquipment[i].weaponclass == AWweapclass[1] 
						|| BaseEquipment[i].weaponclass == AWweapclass[2])
						BaseEquipment[i].weaponclass = class'ShovelWeapon';
				}		
			}
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: CreateInventory but check for Classic Game mode first.
///////////////////////////////////////////////////////////////////////////////
function Inventory CreateInventoryForDifficulty(string WeaponClassName)
{
	local int i;
	local bool bException;
	local string OldClassName, NewClassName;
	local P2GameInfoSingle GameSingle;
	local xPatchManager xManager;

	GameSingle = P2GameInfoSingle(Level.Game);
	xManager = GameSingle.xManager;

	if(GameSingle != None && GameSingle.InClassicMode())
	{
		if(GameSingle.ClassicModeReplace.Length != 0)
		{
			for( i = 0 ; i < GameSingle.ClassicModeReplace.Length ; i++ )
			{
				OldClassName = GameSingle.ClassicModeReplace[i].OldClass;
				NewClassName = GameSingle.ClassicModeReplace[i].NewClass;
				
				if(xManager != None && xManager.IsException(OldClassName))
					bException = True;
				
				if(WeaponClassName == OldClassName && !bException)
					WeaponClassName = NewClassName;
			}
		}
	}
	
	return CreateInventory(WeaponClassName);
}

///////////////////////////////////////////////////////////////////////////////
// Allocate spawner money here, because we have access to the class
///////////////////////////////////////////////////////////////////////////////
function InitBySpawner(PawnSpawner initsp)
{
	local P2PowerupInv pinv;

	Super.InitBySpawner(initsp);

	// Handle money seperately
	if(MaxMoneyToStart > 0)
	{
		pinv = P2PowerupInv(CreateInventoryByClass(class'Inventory.MoneyInv'));
		pinv.SetAmount(MaxMoneyToStart);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set the mood, which determines how various actions are performed.
//
// The amount is between 0.0 to 1.0 and is used by some of the mood-based
// to further refine the responses.  Most functionality is based purely on
// the specified mood, completely ignoring the amount.
///////////////////////////////////////////////////////////////////////////////
function SetMood(EMood moodNew, float amount)
{
	Super.SetMood(moodNew, amount);

	if(MyHead != None)
		Head(MyHead).SetMood(moodNew, amount);
}

///////////////////////////////////////////////////////////////////////////////
//	You will now puke
// More complicated than a normal play animation, it triggers the animation
// but also creates the puking effect. This function is usually called by the
// controller.
///////////////////////////////////////////////////////////////////////////////
function StartPuking(int newpuketype)
{
	Super.StartPuking(newpuketype);
	PlayAnim(GetAnimPuke(), 1.0);
}

///////////////////////////////////////////////////////////////////////////////
// For the love of all that's good and holy, please just stop puking...
// Tells the head to stop the puking.
///////////////////////////////////////////////////////////////////////////////
function StopPuking()
{
	if(MyHead != None)
	{
		Head(MyHead).StopPuking();
	}
}

simulated function Notify_StartPuking()
{
	if(MyHead != None)
	{
		Head(MyHead).StartPuking(PukeType);

		// tell controller you started actually spewing chunks
		if(PersonController(Controller) != None)
			PersonController(Controller).ActuallyPuking();
	}
}
simulated function Notify_StopPuking()
{
	StopPuking();
}

///////////////////////////////////////////////////////////////////////////////
// GetGonorrhea
// You've contracted gonorrhea
///////////////////////////////////////////////////////////////////////////////
function bool ContractGonorrhea()
{
	local UrethraWeapon myu;

	myu = UrethraWeapon(MyUrethra);

	if(myu!= None)
	{
		//myu.MakeInfected();
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// CureGonorrhea
// You've fixed your gonorrhea
///////////////////////////////////////////////////////////////////////////////
function bool CureGonorrhea()
{
	local UrethraWeapon myu;
	local P2Player p2p;

	myu = UrethraWeapon(MyUrethra);

	if(myu!= None)
	{
		p2p = P2Player(Controller);
		if(p2p != None)
			// probably say he feels better
			p2p.NotifyCuredGonorrhea();

		// actually fix it
		myu.MakeCured();
		return true;
	}
	// we didn't need to be fixed.
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// You've got a vd if true
///////////////////////////////////////////////////////////////////////////////
function bool UrethraIsInfected()
{
	if(MyUrethra != None)
	{
		return (GonorrheaAmmoInv(MyUrethra.AmmoType) != None);
	}
	return false;
}


///////////////////////////////////////////////////////////////////////////////
// My head says I'm still talking
///////////////////////////////////////////////////////////////////////////////
function bool IsTalking()
{
	if(MyHead != None
		&& Head(MyHead).bKillTalk)
		return true;
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Say the specified line of dialog and animate face appropriately.
// Returns the duration of the specified line.
///////////////////////////////////////////////////////////////////////////////
function float Say(out P2Dialog.SLine line, optional bool bImportant,
				   optional bool bIndexValid, optional int SpecIndex)
	{
	local float duration;
	// Let super class handle audio
	duration = Super.Say(line, False, bIndexValid, SpecIndex);

	// Tell head to talk (no lip sync for now)
	if(MyHead != None
		&& Duration > 0)
	{
		if(Mood == MOOD_Combat
			|| Mood == MOOD_Angry)
			Head(myHead).Yell(duration);
		else
			Head(myHead).Talk(duration);
	}

	return duration;
	}

///////////////////////////////////////////////////////////////////////////////
// Decide on a prize for a quick kill
///////////////////////////////////////////////////////////////////////////////
function PickQuickKillPrize(int KillIndex)
{
	local class<Inventory> invclass;
	local Inventory newone;
	local int Amount;

	switch(KillIndex)
	{
		case 0:
			invclass = class'MoneyInv';
			amount = 20;
		break;
		case 1:
			invclass = class'DonutInv';
			amount = 1;
		break;
		case 2:
			invclass = class'PizzaInv';
			amount = 1;
		break;
		case 3:
			invclass = class'FastFoodInv';
			amount = 1;
		break;
		case 4:
			invclass = class'KevlarInv';
			amount = 100;
		break;
		case 5:
			invclass = class'CrackInv';
			amount = 1;
		break;
		case 6:
			invclass = class'CatnipInv';
			amount = 1;
		break;
	}
	newone = spawn(invclass, self);
	P2PowerupInv(newone).AddAmount(Amount);
	TossThisInventory(vector(Rotation), newone);
}

///////////////////////////////////////////////////////////////////////////////
// Spit and make a sound
///////////////////////////////////////////////////////////////////////////////
function float DisgustedSpitting(out P2Dialog.SLine line)
{
	local float duration;

	// Let super class handle audio
	duration = Super.DisgustedSpitting(line);

	// Tell head to talk (no lip sync for now)
	if(MyHead != None)
		Head(myHead).DisgustedSpitting(duration);

	return duration;
}

///////////////////////////////////////////////////////////////////////////////
// Perform protesting motion
///////////////////////////////////////////////////////////////////////////////
function SetProtesting(bool bSet)
{
	if(bProtesting != bSet)
	{
		Super.SetProtesting(bSet);
		// If we're starting to protest, turn on the talking
		if(bSet)
				// Sending in -1 here so we can have manual control over when
				// to call Timer to stop the talking.
			Head(MyHead).SetChant(true);//Talk(-1);
		else	// If we're stopping talking, then turn off the talking
			Head(MyHead).SetChant(false);//Timer();
	}
}

///////////////////////////////////////////////////////////////////////////////
// called externally by the blood spout
///////////////////////////////////////////////////////////////////////////////
function RemoveFluidSpout()
{
	if (FluidSpout != None)
		FluidSpout.ToggleFlow(0, false);
	FluidSpout = None;
	//DetachFromBone(FluidSpout);
}

///////////////////////////////////////////////////////////////////////////////
// Make body drip with a given fluid effect
///////////////////////////////////////////////////////////////////////////////
function MakeDrip(Fluid.FluidTypeEnum ftype, vector HitLocation)
{
	local float ZDist;
	local class<PartDrip> useclass;

	// Only do this if you're not crouching or deathcrawling
	if(!bIsCrouched
		&& !bIsDeathCrawling
		&& !bIsCowering)
	{
		// Figure out if we're doing the body with this or the head
		if(MyHead != None
			&& CheckHeadForHit(HitLocation, ZDist))
		{
			// Find what fluid hit you
			if(ftype == FLUID_TYPE_Urine)
				useclass = class'UrineHeadDrip';
			else if(ftype == FLUID_TYPE_Gas)
					useclass = class'GasHeadDrip';

			// Only allow those fluids from above
			if(useclass != None)
			{
				Head(MyHead).MakeDrip(useclass);
			}
		}
		else
		{
			// Find what fluid hit you
			if(ftype == FLUID_TYPE_Urine)
				useclass = PeeBody;
			else if(ftype == FLUID_TYPE_Gas)
					useclass = GasBody;

			// Only allow those fluids from above
			if(useclass != None)
			{
				if(BodyDrips != None)
				{
					if(BodyDrips.LifeSpan == 0
						|| BodyDrips.bDeleteMe)
					{
						BodyDrips=None;
					}
					else if(BodyDrips.class != useclass)
					{
						// get rid of the previous emitter slowly
						BodyDrips.SlowlyDestroy();
						BodyDrips=None;
					}
				}

				if(BodyDrips == None)
				{
					BodyDrips = spawn(useclass,self,,Location);
					if(BodyDrips != None)
						BodyDrips.SetBase(self);
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// You're head has fluids dripping of it
///////////////////////////////////////////////////////////////////////////////
function bool HeadIsDripping()
{
	if(Head(MyHead).HeadDrips != None
		&& Head(MyHead).HeadDrips.LifeSpan > 0)
		return true;
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Stop the dripping
///////////////////////////////////////////////////////////////////////////////
function WipeHead()
{
	Head(MyHead).StopDripping();
}

///////////////////////////////////////////////////////////////////////////////
// Something's happening (like a crouch our puke) where we need to stop all the
// dripping (body and head)
///////////////////////////////////////////////////////////////////////////////
simulated function StopAllDripping()
{
	if(MyHead != None)
		Head(MyHead).StopDripping();

	if(BodyDrips != None)
	{
		// get rid of the previous emitter slowly
		BodyDrips.SlowlyDestroy();
		BodyDrips=None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Controller is requesting that pawn crouch
///////////////////////////////////////////////////////////////////////////////
function ShouldCrouch(bool Crouch)
{
	Super.ShouldCrouch(Crouch);
	// Make sure when you crouch you make you're head and body dripping stop
	if(bWantsToCrouch)
	{
		StopAllDripping();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Perform death crawl
///////////////////////////////////////////////////////////////////////////////
event StartDeathCrawl(float HeightAdjust)
{
	Super.StartDeathCrawl(HeightAdjust);

	// Make sure when you're down you make you're head and body dripping stop
	if(bIsDeathCrawling)
		StopAllDripping();
}

///////////////////////////////////////////////////////////////////////////////
// Start crouching
///////////////////////////////////////////////////////////////////////////////
event StartCrouch(float HeightAdjust)
	{
	Super.StartCrouch(HeightAdjust);
	// Make sure when you're down you make you're head and body dripping stop
	if(bIsCowering)
		StopAllDripping();
	}

///////////////////////////////////////////////////////////////////////////////
// Simply remove it, but don't destroy it
///////////////////////////////////////////////////////////////////////////////
simulated function DissociateHead(bool bDestroyHead)
{
	if(myHead != None)
	{
		DestroyHeadBoltons();
		Head(myHead).myBody = None;
		// Set in P2Pawn that you've lost your head
		bHasHead=false;

		if (bDestroyHead)
			myHead.Destroy();
		myHead = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Detonate head
///////////////////////////////////////////////////////////////////////////////
function ExplodeHead(vector HitLocation, vector Momentum)
{
	local int i, BloodDrips;
	
	if (HitLocation == vect(0,0,0))
		HitLocation = MyHead.Location;

	Super.ExplodeHead(HitLocation, Momentum);

	Head(MyHead).PinataStyleExplodeEffects(HitLocation, Momentum);

	BloodDrips = FRand()*4;
	for(i=0; i<BloodDrips; i++)
		DripBloodOnGround(Momentum);

	// Simply don't put spouts in MP.
	if(FluidSpout == None
		&& Level.Game != None
		&& Level.Game.bIsSinglePlayer)
	{
		// If we're puking at the time our head goes away, then
		// keep puke going out the neckhole
		if(Head(MyHead).PukeStream != None)
		{
			// Make the head stop puking, we'll take it from here.
			Head(MyHead).StopPuking();
			FluidSpout = spawn(class'PukePourFeeder',self,,Location);
			// Make it the same type of puke
			FluidSpout.SetFluidType(Head(MyHead).PukeStream.MyType);
		}
		else if(P2GameInfo(Level.Game).AllowBloodSpouts())
			// If our head is removed while not puking, then make blood squirt out
		{
			FluidSpout = spawn(class'BloodSpoutFeeder',self,,Location);
		}

		if(FluidSpout != None)
		{
			FluidSpout.MyOwner = self;
			FluidSpout.SetStartSpeeds(100, 10.0);
			AttachToBone(FluidSpout, BONE_NECK);
			SnapSpout(true);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
//	Check the head for collision here
//	Use bEasyHit for a bigger area to collide with the heads, resulting in a
//  more likely hit.
///////////////////////////////////////////////////////////////////////////////
function bool CheckHeadForHit(vector HitLocation, out float ZDist, optional bool bEasyHit)
{
	local float userad;

	// No head, no hit
	if(MyHead == None)
		return false;

	if(bEasyHit)
		userad = EASY_HEAD_HIT*MyHead.CollisionHeight;
	else
		userad = MyHead.CollisionHeight;

	// The goofy constant on the end compensates for the fact that the heads
	// center at the base of the neck, so the collision cylinder is weird on them,
	// it's too low.
	ZDist = HitLocation.z - (MyHead.Location.z + HEAD_MOVE_Z_UP_BIG_TEMP_VARIABLE);
	if(ZDist > -userad)
		return true;
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Dust like effects for a hit impact
///////////////////////////////////////////////////////////////////////////////
function DustHit(vector HitLocation, vector Momentum)
{
	if(!bReceivedHeadShot)
		spawn(class'DustHitPuff',self,,HitLocation);
	else// Do a special effect if you hit them in the head so they
		// can see they did well
		spawn(class'DustHeadShotPuff',self,,HitLocation);
}

///////////////////////////////////////////////////////////////////////////////
// Spark effects for a hit impact
///////////////////////////////////////////////////////////////////////////////
function SparkHit(vector HitLocation, vector Momentum, byte PlayRicochet)
{
	local SparkHitMachineGun spark1;

	spark1 = Spawn(class'Fx.SparkHitMachineGun',,,HitLocation);
	spark1.FitToNormal(-Normal(Momentum));
	if(PlayRicochet > 0)
		spark1.PlaySound(RicHit[Rand(ArrayCount(RicHit))],,,,,GetRandPitch());
}

///////////////////////////////////////////////////////////////////////////////
// Electrical effects--only in MP (handled differently in SP)
///////////////////////////////////////////////////////////////////////////////
function ElectricalHit()
{
	spawn(class'ShockerPawnLightningMP',self,,Location);
}

///////////////////////////////////////////////////////////////////////////////
//	poke a whole in the head
///////////////////////////////////////////////////////////////////////////////
function PunctureHead(vector HitLocation, vector Momentum)
{
	local PuncturedHeadEffects headeffects;
	local vector startoff;

	Super.PunctureHead(HitLocation, Momentum);

	// Sometimes just puff blood mist
	if(FRand() <= 0.5)
	{
		// Make some blood mist where it hit
		headeffects = spawn(class'PuncturedHeadEffects',,,HitLocation);
		headeffects.SetRelativeMotion(Momentum, Velocity);
	}
	else	// sometimes shoot out gouts of blood
	{
		if(FluidSpout == None
			&& P2GameInfo(Level.Game).AllowBloodSpouts())
		{
			FluidSpout = spawn(class'BloodSpoutFeeder',self,,Location);
			FluidSpout.MyOwner = self;
			// Try to factor in some extra rotation based on hit speed
			startoff.x = -FRand()*Momentum.x;
			startoff.y = -FRand()*Momentum.y;
			FluidSpout.SetStartSpeeds(100, 10.0, startoff);
			AttachToBone(FluidSpout, BONE_HEAD);
			SnapSpout(true);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
//	Decapitate the head and send it flying.
///////////////////////////////////////////////////////////////////////////////
function PopOffHead(vector HitLocation, vector Momentum)
{
	local PoppedHeadEffects headeffects;
	local P2Emitter HeadBloodTrail;			// Blood trail I drip if I'm detached.

	Super.PopOffHead(HitLocation, Momentum);

	// Create blood from neck hole
	if(FluidSpout == None
		&& P2GameInfo(Level.Game).AllowBloodSpouts())
	{
		// If we're puking at the time our head goes away, then
		// keep puke going out the neckhole
		if(Head(MyHead).PukeStream != None)
		{
			FluidSpout = spawn(class'PukePourFeeder',self,,Location);
			// Make it the same type of puke
			FluidSpout.SetFluidType(Head(MyHead).PukeStream.MyType);
		}
		else// If our head is removed while not puking, then make blood squirt out
			FluidSpout = spawn(class'BloodSpoutFeeder',self,,Location);

		FluidSpout.MyOwner = self;
		FluidSpout.SetStartSpeeds(100, 10.0);
		AttachToBone(FluidSpout, BONE_HEAD);
		SnapSpout(true);
	}

	// Pop off the head
	DetachFromBone(MyHead);

	// Get it ready to fly
	Head(MyHead).StopPuking();
	Head(MyHead).StopDripping();
	MyHead.SetupAfterDetach();
	// Make a blood drip effect come out of the head
	HeadBloodTrail = Spawn(class'BloodChunksDripping ',self);
	HeadBloodTrail.Emitters[0].RespawnDeadParticles=false;
	HeadBloodTrail.SetBase(self);

	MyHead.GotoState('Dead');

	// Send it flying
	MyHead.GiveMomentum(Momentum);

	// Make some blood mist where it hit
	headeffects = spawn(class'PoppedHeadEffects',,,HitLocation);
	headeffects.SetRelativeMotion(Momentum, Velocity);

	//Remove connection to head but don't destroy it
	DissociateHead(false);
}

///////////////////////////////////////////////////////////////////////////////
// Flick the eyes left or right
///////////////////////////////////////////////////////////////////////////////
simulated function PlayEyesLookLeftAnim(float fRate, float BlendFactor)
{
	if(MyHead != None)
		Head(MyHead).PlayLookLeft(fRate, BlendFactor);
}
simulated function PlayEyesLookRightAnim(float fRate, float BlendFactor)
{
	if(MyHead != None)
		Head(MyHead).PlayLookRight(fRate, BlendFactor);
}

///////////////////////////////////////////////////////////////////////////////
// Make it pour out the correct direction
///////////////////////////////////////////////////////////////////////////////
function SnapSpout(optional bool bInitArc)
{
	local vector startpos, X,Y,Z;
	local vector forward;
	local coords checkcoords;

	checkcoords = GetBoneCoords(BONE_NECK);
	FluidSpout.SetLocation(checkcoords.Origin);
	FluidSpout.SetDir(checkcoords.Origin, checkcoords.XAxis,,bInitArc);
}

///////////////////////////////////////////////////////////////////////////////
// Update the blood spout
///////////////////////////////////////////////////////////////////////////////
simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	// continuously update the stream if we have one
	if(FluidSpout != None)
		SnapSpout();
}
///////////////////////////////////////////////////////////////////////////////
// Make some glare from my sniper rifle
///////////////////////////////////////////////////////////////////////////////
//simulated
function MakeSniperGlare()
{
	local vector useloc;

	useloc = Location;
	useloc += GLARE_FORWARD*vector(Rotation);
	useloc.z += GLARE_UP;
	// try to attach it to the weapon in third person because in MP nothing
	// sticks to anything very well
	spawn(class'RifleScopeGlare',Weapon.ThirdPersonActor,,useloc);
}
///////////////////////////////////////////////////////////////////////////////
// Move blood pool to where you are, attach, when this is called
///////////////////////////////////////////////////////////////////////////////
function AttachBloodEffectsWhenDead()
{
	// Check to make blood pool below us.
	// See if we already have blood squrting out of us in some other spot first
	// --if so, don't make this
	if(ClassIsChildOf(DyingDamageType, class'BloodMakingDamage')
		&& bloodpool == None
		&& FluidSpout == None
		&& (P2GameInfo(Level.Game) == None
			|| (class'P2Player'.static.BloodMode()
				&& P2GameInfo(Level.Game).AllowBloodSpouts())))
	{
//		bloodpool = spawn(class'Fx.BloodBodyFeeder',self,,Location);
		bloodpool =  spawn(class'BloodBodyFeeder',self,,Location);
		AttachToBone(bloodpool, BONE_PELVIS);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Pee pants, no visible stream, but pee forms below you
///////////////////////////////////////////////////////////////////////////////
function PeePants()
{
	if(PeePool == None
		&& !bHasPeed)
	{
		PeePool =  spawn(class'UrineBodyFeeder',self,,Location);
		AttachToBone(PeePool, BONE_PELVIS);
		bHasPeed=true;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Stop peeing your pants--turn off the feeder
///////////////////////////////////////////////////////////////////////////////
function StopPeeingPants()
{
	if(PeePool != None)
	{
		DetachFromBone(PeePool);
		PeePool.Destroy();
		PeePool = None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Goes through our random drops and rolls the dice for each one.
///////////////////////////////////////////////////////////////////////////////
function PerformRandomDrops()
{
	local int i, j, DropAmount;
	local P2GameInfoSingle psg;
	local RandomDropDef Drop;
	local Pickup P;
	local Vector ThrowLocation, ThrowVelocity, X, Y, Z;
	local Rotator ThrowRotation;
	local class<Pickup> PickItemClass;
	local StaticMesh PickDropMesh;
	
	psg = P2GameInfoSingle(Level.Game);
	if (psg == None)
		return;
		
	// xPatch: new little feature for modders mostly, guranteed drop!
	if(GuranteedDrop.DropClass != None)
	{
		// Figure out how much of this thing to drop
		DropAmount = Int(RandRange(GuranteedDrop.DropAmount.Min, GuranteedDrop.DropAmount.Max));
		
		// Randomize the static mesh, if any
		if (GuranteedDrop.DropMesh.Length > 0)
			PickDropMesh = GuranteedDrop.DropMesh[Rand(GuranteedDrop.DropMesh.Length)];
			
		DropItem(GuranteedDrop.DropClass, DropAmount, PickDropMesh);
	}
	
	// xPatch: Sometimes we don't want to allow dropping random items at all
	if (P2GameInfo(Level.Game).InVeteranMode() || NoRandomDrops || psg.InClassicMode())
	{
		// But, maybe give them crackola to reward the player 
		// for the dual-wielder enemy kill, fuckers pack a punch
		if(bForceDualWield && FRand() <= CRACKOLA_DROP_LUDICROUS)
			DropItem(Class'CrackColaPickup', 1);

		return;
	}
	
	for (i = 0; i < RandomDrops.Length; i++)
	{
		Drop = RandomDrops[i];
		// If this is a "blank" drop, we're done - don't try to process this one or any more
		if (Drop.DropItem.Length == 0)
			break;
		
		// Roll the dice and see if this thing has a chance to drop
		if (FRand() > Drop.DropRate)
			continue;

		// Weed out any drops that are ineligible in this game mode
		// Game difficulty
		if (Drop.DropDifficulties.Length > 0
			&& Drop.DropDifficulties.Length > psg.GetGameDifficulty()
			&& !Drop.DropDifficulties[Int(psg.GetGameDifficulty())])
			continue;
		
		// Day of week
		if (Drop.DropDays.Length > 0
			&& Drop.DropDays.Length > psg.GetCurrentDay()
			&& !Drop.DropDays[psg.GetCurrentDay()])
			continue;
			
		// Expert Mode
		if (psg.InNightmareMode() && Drop.DropInExpertMode == -1)
			continue;
		if (!psg.InNightmareMode() && Drop.DropInExpertMode == 1)
			continue;
			
		// Custom Mode
		if (psg.InCustomMode() && Drop.DropInCustomMode == -1)
			continue;
		if (!psg.InCustomMode() && Drop.DropInCustomMode == 1)
			continue;
			
		// Lieber Mode
		if (psg.InLieberMode() && Drop.DropInLieberMode == -1)
			continue;
		if (!psg.InLieberMode() && Drop.DropInLieberMode == 1)
			continue;
			
		// They Hate Me Mode
		if (psg.TheyHateMeMode() && Drop.DropInHateMeMode == -1)
			continue;
		if (!psg.TheyHateMeMode() && Drop.DropInHateMeMode == 1)
			continue;
			
		// Insane-o Mode
		if (psg.InInsaneMode() && Drop.DropInInsaneMode == -1)
			continue;
		if (!psg.InInsaneMode() && Drop.DropInInsaneMode == 1)
			continue;
			
		// Ludicrous Mode
		if (psg.InLudicrousMode() && Drop.DropInLudicrousMode == -1)
			continue;
		if (!psg.InLudicrousMode() && Drop.DropInLudicrousMode == 1)
			continue;
			
		// Enhanced Mode
		if (psg.VerifySeqTime() && Drop.DropInEnhancedMode == -1)
			continue;
		if (!psg.VerifySeqTime() && Drop.DropInEnhancedMode == 1)
			continue;
			
		// If we've gotten this far, we can drop the item
		ThrowVelocity = Vector(Rotation);
		ThrowRotation = Rotation;
		ThrowRotation.Yaw = FRand() * 65535;
		GetAxes(ThrowRotation, X, Y, Z);
		ThrowLocation = Location + 0.3 * CollisionRadius * X + CollisionRadius * Z;
		
		// Choose one of the possible drops
		j = Rand(Drop.DropItem.Length);
		PickItemClass = Drop.DropItem[j].DropClass;
		
		// Randomize the static mesh, if any
		if (Drop.DropItem[j].DropMesh.Length > 0)
			PickDropMesh = Drop.DropItem[j].DropMesh[Rand(Drop.DropItem[j].DropMesh.Length)];
			
		// Figure out how much of this thing to drop
		DropAmount = Int(RandRange(Drop.DropItem[j].DropAmount.Min, Drop.DropItem[j].DropAmount.Max));
		
		// And finally spawn the thing
		DropItem(PickItemClass, DropAmount, PickDropMesh);
	}
}

// xPatch: Moved the spawning part into a new function so it can be done not only at random.
function DropItem(class<Pickup> ItemClass, int DropAmount, optional StaticMesh DropMesh)
{
	local RandomDropDef Drop;
	local Pickup P;
	local Vector ThrowLocation, ThrowVelocity, X, Y, Z;
	local Rotator ThrowRotation;
	
	if(ItemClass != None && DropAmount != 0)
	{			
		// If we've gotten this far, we can drop the item
		ThrowVelocity = Vector(Rotation);
		ThrowRotation = Rotation;
		ThrowRotation.Yaw = FRand() * 65535;
		GetAxes(ThrowRotation, X, Y, Z);
		ThrowLocation = Location + 0.3 * CollisionRadius * X + CollisionRadius * Z;

		P = Spawn(ItemClass,,,ThrowLocation,ThrowRotation);
		
		// If it didn't spawn, try directly at the pawn's location
		if (P == None)
			P = Spawn(ItemClass,,,Location,ThrowRotation);
			
		if (P != None)
		{
			// use specified static mesh, if any
			if(DropMesh != None)
				P.SetStaticMesh(DropMesh);
			
			// Specific inits for the dropped item
			if (Ammo(P) != None)
			{
				if (DropAmount > 0)
					Ammo(P).AmmoAmount = DropAmount;
				if (P2AmmoPickup(P) != None)
					P2AmmoPickup(P).bAllowMovement = True;
			}
			if (P2WeaponPickup(P) != None)
			{
				if (DropAmount > 0)
					P2WeaponPickup(P).AmmoGiveCount = DropAmount;
				P2WeaponPickup(P).bAllowMovement = true;
			}
			if (P2PowerupPickup(P) != None)
			{
				if (DropAmount > 0)
					P2PowerupPickup(P).AmountToAdd = DropAmount;
				P2PowerupPickup(P).bAllowMovement = true;
				P2PowerupPickup(P).bRanomDrop = true;	// xPatch: Crash Fix
			}
			
			// Now send it flying
			P.SetPhysics(PHYS_Falling);
			P.Velocity = ThrowVelocity;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Record pawn dead, if player killed them
///////////////////////////////////////////////////////////////////////////////
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local class<Inventory> invclass;
	local Inventory newone;
	local float seed;
	local int iseed;

	// Moved to P2Pawn/GameState
	/*
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& Killer != None
		&& Killer.bIsPlayer)
	{
		// Record him as a person dying.
		// Kamek edit - don't count if it was a "telefrag"
		if (damagetype != class'DamageType'
			&& damagetype != class'Gibbed')
		{
			//P2GameInfoSingle(Level.Game).TheGameState.PeopleKilled++;
			P2GameInfoSingle(Level.Game).TheGameState.PawnKilledByDude(Self, DamageType);

			if(Police(self) != None)
			{
				// If he was a cop, record that too
				P2GameInfoSingle(Level.Game).TheGameState.CopsKilled++;
			}
		}
		// If you killed him with fire, record that too
		if(ClassIsChildOf(damageType, class'BurnedDamage')
			|| ClassIsChildOf(damageType, class'OnFireDamage'))
		{
			P2GameInfoSingle(Level.Game).TheGameState.PeopleRoasted++;
		}
	}
	*/

	//debuglog(self@"killed by"@killer@killer.bisplayer@p2gameinfosingle(level.game).innightmaremode());
	
	if (Killer != None && Killer.bIsPlayer)
		PerformRandomDrops();	// Randomly drop stuff if the player kills us
		
	/*

	// If the player killed us, chance to drop a donut for health in POSTAL or Impossible mode.
	if (Killer != None
		&& Killer.bIsPlayer
		&& P2GameInfoSingle(Level.Game).InNightmareMode())
	{
		seed = FRand();
		if (seed <= POSTAL_FOOD_CHANCE)
			invclass = class'FastFoodInv';
		else if (seed <= POSTAL_PIZZA_CHANCE)
			invclass = class'PizzaInv';
		else if (seed <= POSTAL_DONUT_CHANCE)
			invclass = class'DonutInv';
	}
	//debuglog(invclass);
	if (invclass != None)
	{
		newone = spawn(invclass, self);
		P2PowerupInv(newone).AddAmount(1);
		//debuglog("spawned"@newone);
		TossThisInventory(vector(Rotation), newone);
		invclass = None;
	}

	// Chance to drop a doggy treat if the player killed us in Nightmare Mode.
	if (Killer != None
		&& Killer.bIsPlayer
		&& P2GameInfoSingle(Level.Game).InNightmareMode()
		&& FRand() <= POSTAL_DOGGY_CHANCE)
		invclass = class'DogTreatInv';
	*/
	// Double chance to drop a doggy treat if a dog helper killed us!
	if (P2GameInfoSingle(Level.Game).InNightmareMode()
		&& Killer != None
		&& Killer.Pawn.IsA('DogPawn')
		&& LambController(Killer).Hero != None
		&& LambController(Killer).Hero.bPlayer
		&& FRand() <= 2*POSTAL_DOGGY_CHANCE)
		invclass = class'DogTreatInv';

	if (invclass != None)
	{
		newone = spawn(invclass, self);
		P2PowerupInv(newone).AddAmount(1);
		TossThisInventory(vector(Rotation), newone);
	}
	/*
	// Non-POSTAL difficulties: chance to drop money and food on a kill.
	if (Killer != None
		&& Killer.bIsPlayer
		&& !P2GameInfoSingle(Level.Game).InNightmareMode()
		&& FRand() <= MONEY_DROP_CHANCE)
	{
		invclass = class'MoneyInv';
		newone = spawn(invclass, self);
		P2PowerupInv(newone).AddAmount(Rand(10)+5);
		TossThisInventory(vector(Rotation), newone);
	}
	if (Killer != None
		&& Killer.bIsPlayer
		&& !P2GameInfoSingle(Level.Game).InNightmareMode()
		&& FRand() <= NORMAL_FOOD_DROP_CHANCE)
	{
		iseed = Rand(3);
		if (iseed == 0)
			invclass = class'FastFoodInv';
		else if (iseed == 1)
			invclass = class'PizzaInv';
		else
			invclass = class'DonutInv';
		newone = spawn(invclass, self);
		P2PowerupInv(newone).AddAmount(1);
		TossThisInventory(vector(Rotation), newone);
	}
	*/

	Super.Died(Killer, damageType, HitLocation);
}

///////////////////////////////////////////////////////////////////////////////
// Destroy the ragdoll
///////////////////////////////////////////////////////////////////////////////
event KExcessiveJointError()
{
	ChunkUp(0);

	// Change by NickP: ragdolls issue fix
	// SetPhysics(PHYS_None);
	// MeshInstance = None;
	// bInitializeAnimation = false;
	// bInitialSetup = false;
	// LinkAnims();
	// PlayDyingAnim(DyingDamageType,Location);
	// End
}

///////////////////////////////////////////////////////////////////////////////
// blow up into little pieces (implemented in subclass)
///////////////////////////////////////////////////////////////////////////////
simulated function ChunkUp(int Damage)
{
	local MeatExplosion exp;

	bChunkedUp=true;

	if ( Controller != None )
	{
		if ( Controller.bIsPlayer )
			Controller.PawnDied(self);
		else
		{
			Controller.Destroy();
			Controller = None;
		}
	}

	// Make big blood splat if we can
	if(class'P2Player'.static.BloodMode())
	{
		exp = spawn(GibsClass,,,Location);
		exp.FitToNormal(vect(0, 0, 1));
	}
	else // dust if we're lame
		DustHit(Location, Velocity);

	// Get rid of me nicely
	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
// Take damage (pawn call) but also save who attacked me
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType)
{
	if(!ClassIsChildOf(damageType, class'BurnedDamage')
		&& !ClassIsChildOf(damageType, class'ExplodedDamage')
		&& damageType != class'CrackSmokingDamage'
		&& damageType != class'GonorrheaDamage')
		bCrotchHit = WasCrotchHit(HitLocation, Momentum);
	else
		bCrotchHit=false;

	// Check for a hurt urethra
	if(Damage > 0
		&& UrethraWeapon(Weapon) != None
		&& ClassIsChildOf(DamageType, class'BloodMakingDamage')
		&& bCrotchHit)
			UrethraWeapon(Weapon).MakeBloodied();
			
	// Check for napalm damage
	if (ClassIsChildOf(damageType, class'NapalmDamage')		// If it was napalm
		&& AWDude(InstigatedBy) != None							// And the dude done it
		&& MyBodyFire == None)									// And we're not already on fire
	{
		AWDude(InstigatedBy).PeopleBurned++;					// Say they burned us
		if (AWDude(InstigatedBy).PeopleBurned >= 5
			&& PlayerController(InstigatedBy.Controller) != None)	// Do the thing
			{
			if( Level.NetMode != NM_DedicatedServer ) PlayerController(InstigatedBy.Controller).GetEntryLevel().EvaluateAchievement(PlayerController(InstigatedBy.Controller),'GoodMorningVietnam');
			}
	}

	Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);

	// Kamek 4-28
	// Death-related achievements that we can't put in Postal2Game
	if (Health <= 0)
	{
		// Kills by dog helper
		if (DogController(InstigatedBy.Controller) != None && DogController(InstigatedBy.Controller).Hero.bPlayer && DogController(InstigatedBy.Controller).HeroLove > 0)
		{
			// Dog is owned by a player, record the kill and check to unlock the achievement.
			if( Level.NetMode != NM_DedicatedServer ) PlayerController(DogController(InstigatedBy.Controller).Hero.Controller).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(DogController(InstigatedBy.Controller).Hero.Controller),'DogKills',1,true);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Make sure the censored bar for the
///////////////////////////////////////////////////////////////////////////////
function name GetWeaponBoneFor(Inventory I)
	{
	if(UrethraWeapon(I) != None)
		return PEE_BONE;
	else
		return Super.GetWeaponBoneFor(I);
	}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function ClientStartRocketBeeping(Projectile ThisRocket)
{
	if(Level.NetMode != NM_DedicatedServer)
		spawn(class'RocketBeeper',Owner);
}

///////////////////////////////////////////////////////////////////////////////
// ReduceArmor
// Take away some armor
///////////////////////////////////////////////////////////////////////////////
function ReduceArmor(float ArmorDamage, Vector HitLocation)
{
	Super.ReduceArmor(ArmorDamage, HitLocation);

	if(ArmorDamage > 0
		&& P2Player(Controller) != None
		&& (Level.Game == None
			|| !Level.Game.bIsSinglePlayer))
	{
		//  Make some effects to show the kevlar being eaten away
		spawn(class<KevlarInv>(P2Player(Controller).HudArmorClass).default.EffectClass,self,,HitLocation);
	}
}

///////////////////////////////////////////////////////////////////////////////
// When you're dead, check to quickly add kevlar to your inventory, to
// have it dropped by you
///////////////////////////////////////////////////////////////////////////////
function DropArmorDead()
{
	local KevlarInv kinv;

	// Add in armor to be dropped, if you have it
	if(Armor > 0)
	{
		if(P2Player(Controller) != None)
			kinv = KevlarInv(CreateInventoryByClass(P2Player(Controller).HudArmorClass));
		else
			kinv = KevlarInv(CreateInventory("Inventory.KevlarInv"));
		kinv.ArmorAmount = Armor;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
	HeadClass=class'Head'
	CloseWeaponIndex=0
	FarWeaponIndex=1
	RicHit[0]=Sound'WeaponSounds.bullet_ricochet1'
	RicHit[1]=Sound'WeaponSounds.bullet_ricochet2'
	PeeBody=class'UrineBodyDrip'
	GasBody=class'GasBodyDrip'
	HandsClass=class'Inventory.HandsWeapon'
	ADJUST_RELATIVE_HEAD_X=-0.8
	ADJUST_RELATIVE_HEAD_Y=0
	ADJUST_RELATIVE_HEAD_Z=0

	RandomLieberWeapons(0)="Inventory.FistsWeapon"
	RandomLieberWeapons(1)="Inventory.BatonWeapon"
	RandomLieberWeapons(2)="Inventory.ShovelWeapon"
	RandomHestonWeapons(0)="Inventory.PistolWeapon"
	RandomHestonWeapons(1)="EDStuff.GSelectWeapon"
	RandomHestonWeapons(2)="Inventory.ShotgunWeapon"
	RandomHestonWeapons(3)="Inventory.MachineGunWeapon"
	RandomHestonWeapons(4)="EDStuff.MP5Weapon"
	RandomInsaneWeapons(0)="Inventory.PistolWeapon"
	RandomInsaneWeapons(1)="EDStuff.GSelectWeapon"
	RandomInsaneWeapons(2)="Inventory.ShotgunWeapon"
	RandomInsaneWeapons(3)="Inventory.MachineGunWeapon"
	RandomInsaneWeapons(4)="EDStuff.DynamiteWeapon"
	RandomInsaneWeapons(5)="Inventory.GrenadeWeapon"
	RandomInsaneWeapons(6)="Inventory.MolotovWeapon"
	RandomInsaneWeapons(7)="Inventory.ScissorsWeapon"
	RandomInsaneWeapons(8)="EDStuff.MP5Weapon"
	RandomRareWeapons(0)="EDStuff.GrenadeLauncherWeapon"
	RandomRareWeapons(1)="Inventory.LauncherWeapon"
	RandomRareWeapons(2)="Inventory.NapalmWeapon"
	RandomRareWeapons(3)="AWPStuff.SawnOffWeapon"
	RandomMeleeWeapons(0)="AWInventory.MacheteWeapon"
	RandomMeleeWeapons(1)="AWInventory.ScytheWeapon"
	RandomMeleeWeapons(2)="AWInventory.SledgeWeapon"
	RandomMeleeWeapons(3)="EDStuff.AxeWeapon"
	RandomMeleeWeapons(4)="EDStuff.ShearsWeapon"
	RandomMeleeWeapons(5)="AWPStuff.DustersWeapon"
	RandomMeleeWeapons(6)="Inventory.BatonWeapon"
	RandomMeleeWeapons(7)="Inventory.ShovelWeapon"
	RandomMeleeWeapons(8)="EDStuff.BaliWeapon"
	RandomMeleeWeapons(9)="AWPStuff.BaseballBatWeapon"
	ColemansCrewSkin=Texture'ChameleonSkins.Special.Colemans_Crew'
	bAllowBareHands=False //true
	GibsClass=class'PawnExplosion'
	HandsClassEnhanced="Postal2Extras.P2EHandsWeapon"
	HandsClassNormal="Inventory.HandsWeapon"
	UrethraClass=class'NPCUrethraWeapon'
	
	// xPatch Changes: 
	// - Commented out money (it's already handled by other function, it was causing double-money drops)
	// - Added random crackola drop (enhanced game)
	RandomDrops[0]=(DropItem=((DropClass=class'DogTreatPickup')),DropRate=0.1,DropInExpertMode=1)
	RandomDrops[1]=(DropItem=((DropClass=class'DonutPickup',DropMesh=(StaticMesh'Timb_mesh.fast_food.donut1_timb',StaticMesh'Timb_mesh.fast_food.donut2_timb',StaticMesh'Timb_mesh.fast_food.donut3_timb',StaticMesh'Timb_mesh.fast_food.donut4_timb',StaticMesh'Timb_mesh.fast_food.donut5_timb',))),DropRate=0.2,DropInExpertMode=1)
	RandomDrops[2]=(DropItem=((DropClass=class'PizzaPickup')),DropRate=0.15,DropInExpertMode=1)
	//RandomDrops[3]=(DropItem=((DropClass=class'MoneyPickup',DropAmount=(Min=5,Max=15))),DropRate=0.1)
	RandomDrops[3]=(DropItem=((DropClass=class'FastFoodPickup'),(DropClass=class'PizzaPickup'),(DropClass=class'DonutPickup',DropMesh=(StaticMesh'Timb_mesh.fast_food.donut1_timb',StaticMesh'Timb_mesh.fast_food.donut2_timb',StaticMesh'Timb_mesh.fast_food.donut3_timb',StaticMesh'Timb_mesh.fast_food.donut4_timb',StaticMesh'Timb_mesh.fast_food.donut5_timb',))),DropRate=0.1)
	RandomDrops[4]=(DropItem=((DropClass=class'CrackColaPickup')),DropRate=0.05,DropInEnhancedMode=1)	

	// xPatch: Ranom Guns
	bAllowRandomGuns=False	// We set it True for generic Bystanders and few other pawns, everyone else still uses their default inventory.
	RandomGuns[0]=(Replacements=((RandomWeaponStr="EDStuff.GselectWeapon")),DefaultWeapon=class'PistolWeapon',Chance=0.35)
	RandomGuns[1]=(Replacements=((RandomWeaponStr="EDStuff.MP5Weapon_NPC")),DefaultWeapon=class'MachineGunWeapon',Chance=0.25)

	// xPatch: Ludicrous Mode
	RandomLudicrousWeapons(0)="Inventory.PistolWeapon"
	RandomLudicrousWeapons(1)="EDStuff.GSelectWeapon"
	RandomLudicrousWeapons(2)="Inventory.ShotgunWeapon"
	RandomLudicrousWeapons(3)="AWPStuff.SawnOffWeapon"
	RandomLudicrousWeapons(4)="Inventory.MachineGunWeapon"
	RandomLudicrousWeapons(5)="EDStuff.MP5Weapon"
	RandomLudicrousWeapons(6)="EDStuff.MP5Weapon_NPC"
	RandomLudicrousWeapons(7)="AWInventory.MacheteWeapon"
	RandomLudicrousWeaponsRare(0)="EDStuff.GrenadeLauncherWeapon"
	RandomLudicrousWeaponsRare(1)="Inventory.LauncherWeapon"
	RandomLudicrousWeaponsRare(2)="Inventory.CowHeadWeapon"
	RandomLudicrousWeaponsRare(3)="Inventory.PlagueWeapon"
	RandomLudicrousWeaponsSuperRare(0)="Inventory.NapalmWeapon"
	RandomLudicrousWeaponsSuperRare(1)="AWPStuff.NukeWeapon"
	RandomLudicrousWeaponsSuperRare(2)="Inventory.RifleWeapon"
	
	RandomMassDestructionWeapons(0)="EDStuff.GrenadeLauncherWeapon"
	RandomMassDestructionWeapons(1)="Inventory.LauncherWeapon"
	RandomMassDestructionWeapons(2)="Inventory.PlagueWeapon"
	RandomMassDestructionWeapons(3)="AWPStuff.NukeWeapon"
}
