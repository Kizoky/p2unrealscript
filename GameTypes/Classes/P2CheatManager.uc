///////////////////////////////////////////////////////////////////////////////
// P2CheatManager
//
// Most Postal 2 cheats
//
// 8/15 - Backported various AWP and AW cheats. Cheat manager will now accept
// any variant of cheat from either P2, AW, or AWP.
///////////////////////////////////////////////////////////////////////////////

class P2CheatManager extends CheatManager;


var() CameraEffect BulletEffect;
var Sound FanaticsTalking, KrotchyTalking, MikeJTalking, ZombieTalking;
var array<Sound> WrongItemSound;
var sound bts, bte;
var array<Material> DogSkins;
var array<Material> CatSkins;

var array<NavigationPoint> ValidMailDrops;

var Vector EarthGravity, MoonGravity;

struct LoadoutItem
{
	var() class<Inventory> Item;	// Item to give
	var int Amount;					// How much of this thing to give (ammo, armor etc.)
};

// Can't do nested arrays
struct LoadoutList
{
	var() array<LoadoutItem> Items;	// List of items for this day
};

var() array<LoadoutList> LoadoutDays;	// List of items per day

var const localized string	NoSkeletonsText;
var const localized string	NightModeOffText;

// Assumed maxes.. could be outdated
const MAX_RAGDOLLS	=	10;
const RAGDOLL_BONES	=	17;
const BODY_MAX		=	400;
const MODEL_MAX		=	800;

const MAX_AMMO_NUM	=	9999;

const SLOW_ROCKETS = 0.333333;
const NORMAL_ROCKETS = 1.0;
const FAST_ROCKETS = 3.0;

const NORMAL_SPEED = 1.0;
const BULLET_SPEED = 0.1;
const ANTIBULLET_SPEED = 5.0;

const MARIO_JUMP = 2.0;
const SONIC_SPEED = 2.0;	// If you change this value make sure to change it in ScissorsWeapon too
const QUICK_MULT = 10.0;
const HEAD_SCALE = 2.0;

///////////////////////////////////////////////////////////////////////////////
// DEBUG(?) - Gives player an inventory loadout based on the current day.
///////////////////////////////////////////////////////////////////////////////
exec function LoadOut()
{
	local int i;
	local int day;
	local P2Pawn Dude;
	local Inventory inv;
	
	if (P2GameInfoSingle(Outer.Level.Game) == None
		|| P2GameInfoSingle(Outer.Level.Game).TheGameState == None)
		return;
		
	if (!FPSPlayer(Outer).DebugEnabled())
		return;
	
	// Get current day and dude
	day = P2GameInfoSingle(Outer.Level.Game).TheGameState.CurrentDay;
	Dude = P2Pawn(Outer.Pawn);
	
	// Add items to the dude's inventory
	for (i = 0; i < LoadoutDays[day].Items.Length; i++)
	{
		inv = Dude.CreateInventoryByClass(LoadoutDays[day].Items[i].Item);
		// If we made it, possibly give them some extra ammo or whatever.
		if (inv != None)
		{
			if (P2Weapon(Inv) != None)
			{
				P2Weapon(Inv).GiveAmmoFromPickup(Dude, LoadoutDays[day].Items[i].Amount);
				P2Weapon(inv).bJustMade = false;
			}			
			else if (Ammunition(Inv) != None)
				Ammunition(Inv).AddAmmo(LoadoutDays[day].Items[i].Amount);
			else if (P2PowerupInv(Inv) != None)
				P2PowerupInv(Inv).AddAmount(LoadoutDays[day].Items[i].Amount);
		}
	}	
}

///////////////////////////////////////////////////////////////////////////////
// All-in-one cheat reporting function.
// Returns "false" if the cheat should not be allowed.
// Otherwise, records the cheat in the scriptlog and in the GameState, and
// optionally has the dude comment on it.
///////////////////////////////////////////////////////////////////////////////
function bool RecordCheater(optional string CheatName, optional bool bCommentOnIt)
{
	//log("record cheater"@CheatName@bCommentOnIt);
	if (!P2Player(Outer).CheatsAllowed())
		return false;
	else if (P2GameInfoSingle(Level.Game).bWarnedCheater)
	{
		if (CheatName != "")
			log(CheatName,'CheatUsed');
		P2GameInfoSingle(Level.Game).TheGameState.PlayerCheated("Used cheat"@CheatName);
		if (bCommentOnIt)
			P2Player(Outer).CommentOnCheating();
		return true;
	}
	else {
		Outer.ClientMessage("WARNING! Using cheat codes will disable achievements for the current save file. This is your only warning!");
		P2GameInfoSingle(Level.Game).bWarnedCheater = true;
		P2GameInfoSingle(Level.Game).SaveConfig();
		return false;
	}
}

// Wipe out stats and achievements (Testing only)
// Kamek added 4/15
// This is for testing only. Should be stubbed/commented-out upon release.
// FIXME re-enabled for testing!!!

exec function WipeOut()
{
	if (FPSPlayer(Outer).DebugEnabled())
	{
		//Outer.GetEntryLevel().SteamResetStats(true);
		// Non-steam builds: reset stats in achievement manager
		if (Outer.Level.NetMode != NM_DedicatedServer)
		{
			Outer.GetEntryLevel().GetAchievementManager().ResetAll();
			ClientMessage("Steam stats and achievements reset.");
		}
	}
}
exec function WipeStats()
{
	WipeOut();
}
exec function WipeThis(name Achievement)
{
	if (FPSPlayer(Outer).DebugEnabled())
	{
		if (Outer.Level.NetMode != NM_DedicatedServer)
		{
			ClientMessage("Wiping achievement"@Achievement);
			Outer.GetEntryLevel().GetAchievementManager().ResetAll(Achievement);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Count the total number of actors (dynamic and static) in the entire level
///////////////////////////////////////////////////////////////////////////////
exec function CountAll()
{
	local Actor checkA;
	local int i;

	if (!FPSPlayer(Outer).DebugEnabled())
		return;
		
	log("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
	i=0;
	ForEach AllActors(class'Actor', checkA)
	{
		i++;
	}
	log("CountAll: Total number of actors in this level: "$i);
	log("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
}

///////////////////////////////////////////////////////////////////////////////
// Count the total number dynamic actors in the level (one's that don't
// have bStatic set)
///////////////////////////////////////////////////////////////////////////////
exec function CountDynamic()
{
	local Actor checkA;
	local int i;

	if (!FPSPlayer(Outer).DebugEnabled())
		return;

	log("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
	i=0;
	ForEach DynamicActors(class'Actor', checkA)
	{
		i++;
	}
	log("CountDynamic: Total number of dynamic actors in this level: "$i);
	log("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
}

///////////////////////////////////////////////////////////////////////////////
// Count how much karma memory that's taken up.
// This is only for level designers so they know how many actors (and which) that
// count against the two memory pool counts of karma-using objects.
///////////////////////////////////////////////////////////////////////////////
exec function CountKarma()
{
	local Actor checkA;
	local int i, j, max;

	if (!FPSPlayer(Outer).DebugEnabled())
		return;

	log("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
	log("CountKarma: Counting all actors Karma memory.");
	i=0;

	ForEach AllActors(class'Actor', checkA)
	{
		if(checkA.Physics == PHYS_Karma
			|| checkA.Physics == PHYS_KarmaRagDoll)
		{
			i++;
			j++;
			log("CountKarma: actor with Karma physics (body/model pool):	"$checkA);
		}
		else if(checkA.bBlockKarma)
		{
			j++;
			log("CountKarma: actor has bBlockKarma true (model only pool):	"$checkA);
		}
	}

	// We believe our skeletons have 17 bones that matter when it comes to karma memory allocation
	// We assume a max forever of 10 ragdolls.
	max = RAGDOLL_BONES*MAX_RAGDOLLS;
	log("CountKarma: Dynamic ragdoll allocation is body and model "$max);
	i+=max;
	j+=max;
	log("CountKarma: Karma 'Body' pool used:	"$i$" current max "$BODY_MAX);
	log("CountKarma: Karma 'Model' pool used:	"$j$" curret max  "$MODEL_MAX);
	log("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
}
exec function ListKarma()
{
	local Actor checkA;
	local int i, j, max;

	if (!FPSPlayer(Outer).DebugEnabled())
		return;

	log("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
	log("CountKarma: Counting all actors Karma memory.");
	i=0;

	ForEach AllActors(class'Actor', checkA)
	{
		if(checkA.Physics == PHYS_Karma
			|| checkA.Physics == PHYS_KarmaRagDoll)
		{
			i++;
			j++;
			//log("CountKarma: actor with Karma physics (body/model pool):	"$checkA);
		}
		else if(checkA.bBlockKarma)
		{
			j++;
			//log("CountKarma: actor has bBlockKarma true (model only pool):	"$checkA);
		}
	}

	// We believe our skeletons have 17 bones that matter when it comes to karma memory allocation
	// We assume a max forever of 10 ragdolls.
	max = RAGDOLL_BONES*MAX_RAGDOLLS;
	log("CountKarma: Dynamic ragdoll allocation is body and model "$max);
	i+=max;
	j+=max;
	log("CountKarma: Karma 'Body' pool used:	"$i$" current max "$BODY_MAX);
	log("CountKarma: Karma 'Model' pool used:	"$j$" curret max  "$MODEL_MAX);
	log("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
}

///////////////////////////////////////////////////////////////////////////////
// Warp to a specific actor/class
///////////////////////////////////////////////////////////////////////////////
exec function WarpTo(coerce string target)
{
	local class<Actor> actorclass;
	local Actor testactor;
	local vector HitLocation;
	
	if (!RecordCheater("WarpTo"@Target,false))
		return;
		
	actorclass = class<Actor>(DynamicLoadObject(target, class'Class'));
	
	foreach DynamicActors(ActorClass, TestActor)
	{
		HitLocation = TestActor.Location;
		break;
	}
	HitLocation.Z += 100;
	ViewTarget.SetLocation(HitLocation);
}


///////////////////////////////////////////////////////////////////////////////
// Give the player this item
///////////////////////////////////////////////////////////////////////////////
exec function IWant(coerce string S)
{
	local Inventory thisinv;
	local P2PowerupInv pinv;
	local class<Inventory> NewInv;
	local byte CreatedNow;

	if (!RecordCheater("IWant"@S,false))
		return;

	NewInv = class<Inventory>(DynamicLoadObject(S, class'Class'));

	thisinv = P2Pawn(Pawn).CreateInventoryByClass(NewInv, CreatedNow);
	
	if (ThisInv != None)
	{
		P2Player(Outer).CommentOnCheating();
		if(CreatedNow == 0)
		{
			pinv = P2PowerupInv(thisinv);

			if(pinv != None)
			{
				pinv.AddAmount(1);
			}
		}
	}
	else
	{
		DudePlayer(Outer).MyPawn.PlaySound(WrongItemSound[rand(WrongItemSound.Length)]);
	}
}
exec function GrantItem(coerce string S)
{
	IWant(S);
}
exec function Gimme(coerce string S)
{
	IWant(S);
}

// Stubbing out old versions, prefering IWant instead
/*
exec function Gimme(class<Inventory> NewInv)
{
	GrantItem(NewInv);
}

exec function GrantItem(class<Inventory> NewInv)
{
	local Inventory thisinv;
	local P2PowerupInv pinv;
	local byte CreatedNow;

	thisinv = P2Pawn(Pawn).CreateInventoryByClass(NewInv, CreatedNow);

	if(CreatedNow == 0)
	{
		pinv = P2PowerupInv(thisinv);

		if(pinv != None)
		{
			pinv.AddAmount(1);
			P2Player(Outer).CommentOnCheating();
		}
	}
}
*/

///////////////////////////////////////////////////////////////////////////////
// Stubs to make the engine level codes invalid
///////////////////////////////////////////////////////////////////////////////
exec function AllWeapons()
{
}
exec function AllAmmo()
{
}
exec function Invisible(bool B)
{
}
exec function God()
{
}
exec function SetJumpZ( float F )
{
}
exec function SetGravity( float F )
{
}
exec function SetSpeed( float F )
{
}
exec function KillAll(class<actor> aClass)
{
}
exec function KillPawns()
{
}
/*
// invasion of the body snatchers
exec function Avatar( string ClassName )
{
	local class<actor> NewClass;
	local FPSPawn P;
	local FPSPawn OldPawn;
		
	NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
	if( NewClass!=None )
	{
		Foreach DynamicActors(class'FPSPawn',P)
		{
			if ( (P.Class == NewClass) && (P != Pawn) && !P.Controller.bStasis)
			{
				OldPawn = FPSPawn(Pawn);
				
				if ( Pawn.Controller != None )
					Pawn.Controller.PawnDied(Pawn);
				Possess(P);
				
				AddController(OldPawn);
				
				break;
			}
		}
	}
}
*/
exec function Loaded()
{
}
///////////////////////////////////////////////////////////////////////////////
// Can use this for debugging... might as well
///////////////////////////////////////////////////////////////////////////////
exec function Summon( string ClassName )
{
	local class<actor> NewClass;
	local vector SpawnLoc;
	local Actor SpawnedActor;

	NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
	if (NewClass!=None && RecordCheater("Summon"@NewClass))
	{
		if ( Pawn != None )
			SpawnLoc = Pawn.Location;
		else
			SpawnLoc = Location;
		SpawnedActor = Spawn( NewClass,,,SpawnLoc + 72 * Vector(Rotation) + vect(0,0,1) * 15 );
		if (SpawnedActor != None
			&& FPSPawn(SpawnedActor) != None)
			AddController(FPSPawn(SpawnedActor));
	}

}
///////////////////////////////////////////////////////////////////////////////
// Used to be slomo.. appropriately now it's gamespeed
///////////////////////////////////////////////////////////////////////////////
exec function GameSpeed( float T )
{
	if (!RecordCheater("GameSpeed"@T,true))
		return;
		
	P2GameInfoSingle(Level.Game).TheGameState.CheatGameSpeed = T;
	log("changed cheat game speed TO"@P2GameInfoSingle(Level.Game).TheGameState.CheatGameSpeed);
	Level.Game.SetGameSpeed(T);
}

///////////////////////////////////////////////////////////////////////////////
// Player goes in to god mode
///////////////////////////////////////////////////////////////////////////////
exec function Alamode()
{
	if (!RecordCheater("Alamode",false))
		return;
		
	if ( bGodMode )
	{
		bGodMode = false;
		ClientMessage("God mode off");
		return;
	}

	bGodMode = true; 
	ClientMessage("God Mode on");

	P2Player(Outer).CommentOnCheating();
}
exec function AllahMode()
{
	Alamode();
}

exec function SuperPunchout()
{
	if (!RecordCheater("SuperPunchout",true))
		return;

	P2Pawn(Pawn).CreateInventory("AWPStuff.DustersWeapon");
}

exec function FlameOn()
{
	if (!RecordCheater("FlameOn",true))
		return;

	P2Pawn(Pawn).CreateInventory("AWPStuff.FlameWeapon");
}

exec function TexasChainSawMassacre()
{
	if (!RecordCheater("TexasChainSawMassacre",true))
		return;

	P2Pawn(Pawn).CreateInventory("AWPStuff.ChainSawWeapon");
}

exec function BatterUp()
{
	if (!RecordCheater("BatterUp",true))
		return;

	P2Pawn(Pawn).CreateInventory("AWPStuff.BaseballBatWeapon");
}

exec function ThisIsMyBoomstick()
{
	if (!RecordCheater("ThisIsMyBoomstick",true))
		return;

	P2Pawn(Pawn).CreateInventory("AWPStuff.SawnOffWeapon");
}

exec function HedgeYourBets()
{
	if (!RecordCheater("HedgeYourBets",true))
		return;

	P2Pawn(Pawn).CreateInventory("EDStuff.ShearsWeapon");
}

exec function AxeCrazy()
{
	if (!RecordCheater("AxeCrazy",true))
		return;

	P2Pawn(Pawn).CreateInventory("EDStuff.AxeWeapon");
}

exec function LikeAButterfly()
{
	if (!RecordCheater("LikeAButterfly",true))
		return;

	P2Pawn(Pawn).CreateInventory("EDStuff.BaliWeapon");
}

exec function GoodTimes()
{
	if (!RecordCheater("GoodTimes",true))
		return;

	P2Pawn(Pawn).CreateInventory("EDStuff.DynamiteWeapon");
}

exec function GlockOut()
{
	if (!RecordCheater("GlockOut",true))
		return;

	P2Pawn(Pawn).CreateInventory("EDStuff.GSelectWeapon");
}

exec function LaunchDetected()
{
	if (!RecordCheater("LaunchDetected",true))
		return;

	P2Pawn(Pawn).CreateInventory("EDStuff.GrenadeLauncherWeapon");
}

exec function MP5Player()
{
	if (!RecordCheater("MP5Player",true))
		return;

	P2Pawn(Pawn).CreateInventory("EDStuff.MP5Weapon");
}

// Debug test new weapons
/*
exec function NewWeapons()
{
	local Inventory ThisInv;

	if (!RecordCheater("NewWeapons",true))
		return;

	P2Pawn(Pawn).CreateInventory("AWInventory.MacheteWeapon");
	P2Pawn(Pawn).CreateInventory("AWInventory.SledgeWeapon");
	P2Pawn(Pawn).CreateInventory("AWInventory.ScytheWeapon");
	P2Pawn(Pawn).CreateInventory("AWPStuff.BaseballBatWeapon");
	P2Pawn(Pawn).CreateInventory("AWPStuff.ChainSawWeapon");
	P2Pawn(Pawn).CreateInventory("AWPStuff.DustersWeapon");
	P2Pawn(Pawn).CreateInventory("AWPStuff.FlameWeapon");
	P2Pawn(Pawn).CreateInventory("AWPStuff.SawnOffWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.ShearsWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.AxeWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.BaliWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.DynamiteWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.GSelectWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.GrenadeLauncherWeapon");

	thisinv = P2Pawn(Pawn).Inventory;
	while(thisinv != None)
	{
		if(P2Weapon(thisinv) != None)
		{
			P2Weapon(thisinv).bJustMade=false;
		}
		thisinv = thisinv.inventory;
	}
	log("NewWeapons done");
}
*/

///////////////////////////////////////////////////////////////////////////////
// Gives player every destructive weapon in the game
///////////////////////////////////////////////////////////////////////////////
exec function PackNHeat()
{
	local Inventory thisinv;
	local class<Inventory> TestClass;
	local int i;

	if (!RecordCheater("PackNHeat",true))
		return;
		
	P2Pawn(Pawn).CreateInventory("AWInventory.MacheteWeapon");
	P2Pawn(Pawn).CreateInventory("AWInventory.SledgeWeapon");
	P2Pawn(Pawn).CreateInventory("AWInventory.ScytheWeapon");
	P2Pawn(Pawn).CreateInventory("Inventory.BatonWeapon");
	P2Pawn(Pawn).CreateInventory("Inventory.ShovelWeapon");
	P2Pawn(Pawn).CreateInventory("Inventory.ShockerWeapon");
	P2Pawn(Pawn).CreateInventory("Inventory.PistolWeapon");
	P2Pawn(Pawn).CreateInventory("Inventory.ShotgunWeapon");
	P2Pawn(Pawn).CreateInventory("Inventory.MachinegunWeapon");
	P2Pawn(Pawn).CreateInventory("Inventory.GasCanWeapon");
	P2Pawn(Pawn).CreateInventory("Inventory.CowHeadWeapon");
	P2Pawn(Pawn).CreateInventory("Inventory.GrenadeWeapon");
	P2Pawn(Pawn).CreateInventory("Inventory.ScissorsWeapon");
	P2Pawn(Pawn).CreateInventory("Inventory.MolotovWeapon");
	P2Pawn(Pawn).CreateInventory("Inventory.RifleWeapon");
	P2Pawn(Pawn).CreateInventory("Inventory.LauncherWeapon");
	P2Pawn(Pawn).CreateInventory("Inventory.NapalmWeapon");
	P2Pawn(Pawn).CreateInventory("AWPStuff.BaseballBatWeapon");
	P2Pawn(Pawn).CreateInventory("AWPStuff.ChainSawWeapon");
	P2Pawn(Pawn).CreateInventory("AWPStuff.DustersWeapon");
	P2Pawn(Pawn).CreateInventory("AWPStuff.FlameWeapon");
	P2Pawn(Pawn).CreateInventory("AWPStuff.SawnOffWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.ShearsWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.AxeWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.BaliWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.DynamiteWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.GSelectWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.GrenadeLauncherWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.MP5Weapon");

	// Only award these weapons if they've earned them
	if (P2Player(Outer).bPlegg)
		P2Pawn(Pawn).CreateInventory("Inventory.PlagueWeapon");
	if (P2Player(Outer).bFlubber)
		P2Pawn(Pawn).CreateInventory("Inventory.BoxLauncherWeapon");
	if (P2Player(Outer).bOldskool)
		P2Pawn(Pawn).CreateInventory("EDStuff.BetaShotgunWeapon");
	if (P2Player(Outer).bNuts)
		P2Pawn(Pawn).CreateInventory("Inventory.MrDKNadeWeapon");
	if (P2Player(Outer).bProtest)
		P2Pawn(Pawn).CreateInventory("P2R.ProtestSignWeapon");
	if (P2Player(Outer).bRads)
		P2Pawn(Pawn).CreateInventory("AWPStuff.NukeWeapon");
	
	thisinv = P2Pawn(Pawn).Inventory;
	while(thisinv != None)
	{
		if(P2Weapon(thisinv) != None)
		{
			P2Weapon(thisinv).bJustMade=false;
		}
		thisinv = thisinv.inventory;
	}
}
exec function GunRack()
{
	PackNHeat();
}
exec function Armory()
{
	PackNHeat();
}

///////////////////////////////////////////////////////////////////////////////
// Sets all current weapons to have lots of ammo
///////////////////////////////////////////////////////////////////////////////
exec function PayLoad()
{
	local Inventory Inv;

	if (!RecordCheater("PayLoad",true))
		return;

	for( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory ) 
		if (Ammunition(Inv)!=None
			&& ClipboardAmmoInv(Inv) == None)	// Don't load up the clipboard this way
		{
			Ammunition(Inv).AmmoAmount  = MAX_AMMO_NUM;
			Ammunition(Inv).MaxAmmo  = MAX_AMMO_NUM;
		}
}	
exec function BlastACap()
{
	PayLoad();
}
exec function AmmoWhore()
{
	PayLoad();
}

///////////////////////////////////////////////////////////////////////////////
// Super-delux cheat gives you all weapons, with max ammo and turns you invincible.
///////////////////////////////////////////////////////////////////////////////
exec function IAmSoLame()
{
	local Inventory Inv;

	if (!RecordCheater("IAmSoLame",false))
		return;

	if (!bGodMode)
		AlaMode();
	PackNHeat();
	PayLoad();
}
exec function WhyDoIPlay()
{
	IAmSoLame();
}
exec function Kamek0wnzJ00()
{
	IAmSoLame();
}
exec function Kamek0wnsMe()
{
	Armory();
	AmmoWhore();
	TheQuick();
	SonicSpeed();
	SuperMario();
}

///////////////////////////////////////////////////////////////////////////////
// Give player lots of doughnuts
///////////////////////////////////////////////////////////////////////////////
exec function PiggyTreats()
{
	local Inventory invadd;
	local P2PowerupInv ppinv;

	if (!RecordCheater("PiggyTreats",true))
		return;

	invadd = P2Pawn(Pawn).CreateInventory("Inventory.DonutInv");

	ppinv = P2PowerupInv(invadd);
	if(ppinv != None)
		ppinv.AddAmount(19);
}

///////////////////////////////////////////////////////////////////////////////
// Give the player lots of cash
///////////////////////////////////////////////////////////////////////////////
exec function JewsForJesus()
{
	local P2PowerupInv mycash;

	if (!RecordCheater("JewsForJesus",true))
		return;

	mycash = P2PowerupInv(P2Pawn(Pawn).CreateInventoryByClass(class'MoneyInv'));

	if(mycash != None)
		mycash.AddAmount(4990);
}

///////////////////////////////////////////////////////////////////////////////
// Give player lots of dog treats
///////////////////////////////////////////////////////////////////////////////
exec function BoyAndHisDog()
{
	local Inventory invadd;
	local P2PowerupInv ppinv;

	if (!RecordCheater("BoyAndHisDog",true))
		return;

	invadd = P2Pawn(Pawn).CreateInventory("Inventory.DogTreatInv");

	ppinv = P2PowerupInv(invadd);
	if(ppinv != None)
		ppinv.AddAmount(19);
}

///////////////////////////////////////////////////////////////////////////////
// Give player lots of health pipes
///////////////////////////////////////////////////////////////////////////////
exec function Jones()
{
	local Inventory invadd;
	local P2PowerupInv ppinv;

	if (!RecordCheater("Jones",true))
		return;

	invadd = P2Pawn(Pawn).CreateInventory("Inventory.CrackInv");

	ppinv = P2PowerupInv(invadd);
	if(ppinv != None)
		ppinv.AddAmount(19);
}
exec function HeadShop()
{
	Jones();
}
exec function CrackAddict()
{
	Jones();
}

///////////////////////////////////////////////////////////////////////////////
// Give player all radar related items
///////////////////////////////////////////////////////////////////////////////
exec function SwimWithFishes()
{
	local Inventory invadd;
	local P2PowerupInv ppinv;

	if (!RecordCheater("SwimWithFishes",true))
		return;

	invadd = P2Pawn(Pawn).CreateInventory("Inventory.RadarInv");
	ppinv = P2PowerupInv(invadd);
	if(ppinv != None)
		ppinv.AddAmount(440);
	invadd = P2Pawn(Pawn).CreateInventory("Inventory.CopRadarPlugInv");
	invadd = P2Pawn(Pawn).CreateInventory("Inventory.GunRadarPlugInv");
	
	// If they're cool enough, give em a little extra
	if (P2Player(Outer).bMunch)
		invadd = P2Pawn(Pawn).CreateInventory("Inventory.RadarTargetInv");
}

///////////////////////////////////////////////////////////////////////////////
// Say that you're using rocket cameras
///////////////////////////////////////////////////////////////////////////////
exec function FireInYourHole()
{
	if (!RecordCheater("FireInYourHole",true))
		return;

	P2Player(Outer).bUseRocketCameras = !P2Player(Outer).bUseRocketCameras;
	P2Player(Outer).OldViewRotation = Rotation;
}

///////////////////////////////////////////////////////////////////////////////
// Give player lots of catnip
///////////////////////////////////////////////////////////////////////////////
exec function IAmTheOne()
{
	local Inventory invadd;
	local P2PowerupInv ppinv;

	if (!RecordCheater("IAmTheOne",true))
		return;

	invadd = P2Pawn(Pawn).CreateInventory("Inventory.CatnipInv");

	ppinv = P2PowerupInv(invadd);
	if(ppinv != None)
		ppinv.AddAmount(19);
}

///////////////////////////////////////////////////////////////////////////////
// Give player lots of cats
///////////////////////////////////////////////////////////////////////////////
exec function LotsAPussy(optional int IsTainted)
{
	local Inventory invadd;
	local P2PowerupInv ppinv;
	local int i;
	local Material MakeThis;

	if (!RecordCheater("LotsAPussy",true))
		return;

	invadd = P2Pawn(Pawn).CreateInventory("Inventory.CatInv");

	ppinv = P2PowerupInv(invadd);
	if(ppinv != None)
	{
		for (i=0; i<19; i++)
		{
			MakeThis=CatSkins[Rand(CatSkins.Length)];
			ppinv.AddAmount(1,Texture(MakeThis),,IsTainted);
		}
	}
}
exec function CatFancy()
{
	LotsaPussy();
}
exec function MeowMix()
{
	LotsaPussy();
}
exec function CatNado()
{
	LotsaPussy(1);
}

///////////////////////////////////////////////////////////////////////////////
// Give player body armor
///////////////////////////////////////////////////////////////////////////////
exec function BlockMyAss()
{
	local Inventory invadd;

	if (!RecordCheater("BlockMyAss",true))
		return;

	invadd = P2Pawn(Pawn).CreateInventory("Inventory.BodyArmorInv");
	P2Player(Outer).CommentOnCheating();
}

///////////////////////////////////////////////////////////////////////////////
// Give player the gimp suit
///////////////////////////////////////////////////////////////////////////////
exec function SmackDatAss()
{
	local Inventory invadd;

	if (!RecordCheater("SmackDatAss",true))
		return;

	invadd = P2Pawn(Pawn).CreateInventory("Inventory.GimpClothesInv");

	P2Player(Outer).CommentOnCheating();
}

///////////////////////////////////////////////////////////////////////////////
// Give player the cop clothes
///////////////////////////////////////////////////////////////////////////////
exec function IAmTheLaw()
{
	local Inventory invadd;

	if (!RecordCheater("IAmTheLaw",true))
		return;

	invadd = P2Pawn(Pawn).CreateInventory("Inventory.CopClothesInv");

	P2Player(Outer).CommentOnCheating();
}

///////////////////////////////////////////////////////////////////////////////
// Give player full health with several medkits
///////////////////////////////////////////////////////////////////////////////
exec function Healthful()
{
	local Inventory invadd;
	local P2PowerupInv ppinv;

	if (!RecordCheater("Healthful",true))
		return;

	P2Pawn(Pawn).CreateInventory("Inventory.MedKitInv");
	P2Pawn(Pawn).CreateInventory("Inventory.MedKitInv");
	P2Pawn(Pawn).CreateInventory("Inventory.MedKitInv");
	P2Pawn(Pawn).CreateInventory("Inventory.MedKitInv");
	P2Player(Outer).CommentOnCheating();
}
exec function InjectLife()
{
	Healthful();
}
exec function Curaga()
{
	Healthful();
}

///////////////////////////////////////////////////////////////////////////////
// Turns every current non-player, bystander pawns into Gary Colemans
///////////////////////////////////////////////////////////////////////////////
exec function Whatchutalkinbout()
{
	// Disallow during weekend
//	if (P2GameInfoSingle(Level.Game).IsWeekend())
//		return;
		
	if (!RecordCheater("Whatchutalkinbout",false))
		return;		
	
	DudePlayer(Outer).GarySize();
}

///////////////////////////////////////////////////////////////////////////////
// Turns every current non-player, bystander pawns into Fanatics
///////////////////////////////////////////////////////////////////////////////
exec function Osama()
{
	if (!RecordCheater("Osama",false))
		return;

	ClientMessage("Fanaticizing your bystanders--please wait.");

	DudePlayer(Outer).ConvertNonImportants(class'Fanatics',,,true,,true);
	DudePlayer(Outer).ConvertNonImportants(class'Kumquat',,,true,true);

	DudePlayer(Outer).MyPawn.PlaySound(FanaticsTalking);
}

exec function KrotchatizeMe()
{
	if (!RecordCheater("KrotchatizeMe",false))
		return;

	ClientMessage("Krotchatizing your bystanders--please wait.");

	DudePlayer(Outer).ConvertNonImportants(class'Krotchy');

	DudePlayer(Outer).MyPawn.PlaySound(KrotchyTalking);
}

exec function JewTown()
{
	if (!RecordCheater("JewTown",false))
		return;

	ClientMessage("Entering Jewtown--please wait.");

	DudePlayer(Outer).JewTown();

	DudePlayer(Outer).MyPawn.PlaySound(MikeJTalking);
}

exec function Zombification()
{
	local class<P2Pawn> PawnClass;
	
	if (!RecordCheater("Zombification",false))
		return;

	ClientMessage("Zombifying your bystanders--please wait.");
	
	PawnClass = class<P2Pawn>(DynamicLoadObject("AWPawns.AWZombieTom", class'Class'));

	DudePlayer(Outer).ConvertNonImportants(PawnClass);

	DudePlayer(Outer).MyPawn.PlaySound(ZombieTalking);
}

///////////////////////////////////////////////////////////////////////////////
// Change any guns that can have cats on them to constantly have a cat on 
// and shoot off the cat everytime with a new one magically reappearing.
///////////////////////////////////////////////////////////////////////////////
exec function RockinCats()
{
	local Inventory inv;

	if (!RecordCheater("RockinCats",true))
		return;

	inv = Pawn.Inventory;
	while(inv != None)
	{
		if(CatableWeapon(inv) != None)
			CatableWeapon(inv).ToggleRepeatCatGun(true);
		if(DualCatableWeapon(inv) != None)
			DualCatableWeapon(inv).ToggleRepeatCatGun(true);
		inv = inv.Inventory;
	}
}
// Removes cat repeating guns (turns them back to normal versions)
exec function DokkinCats()
{
	local Inventory inv;

	if (!RecordCheater("DokkinCats",true))
		return;

	inv = Pawn.Inventory;
	while(inv != None)
	{
		if(CatableWeapon(inv) != None)
			CatableWeapon(inv).ToggleRepeatCatGun(false);
		if(DualCatableWeapon(inv) != None)
			DualCatableWeapon(inv).ToggleRepeatCatGun(false);
		inv = inv.Inventory;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Makes cats that shoot off guns will bounce off walls or not. These
// cats will bounce for a good while before exploding. If they hit people though,
// they'll explode on contact.
///////////////////////////////////////////////////////////////////////////////
exec function BoppinCats()
{
	local Inventory inv;

	if (!RecordCheater("BoppinCats",true))
		return;

	inv = Pawn.Inventory;
	while(inv != None)
	{
		if(CatableWeapon(inv) != None)
			CatableWeapon(inv).BounceCat=1;
		if(DualCatableWeapon(inv) != None)
			DualCatableWeapon(inv).BounceCat=1;
		inv = inv.Inventory;
	}
	P2Player(Outer).CommentOnCheating();
}
///////////////////////////////////////////////////////////////////////////////
// Turns off the BoppinCats power (makes cats like normal--they explode on contact
// after being launched off your gun).
///////////////////////////////////////////////////////////////////////////////
exec function SplodinCats()
{
	local Inventory inv;

	if (!RecordCheater("SplodinCats",true))
		return;

	inv = Pawn.Inventory;
	while(inv != None)
	{
		if(CatableWeapon(inv) != None)
			CatableWeapon(inv).BounceCat=0;
		if(DualCatableWeapon(inv) != None)
			DualCatableWeapon(inv).BounceCat=0;
		inv = inv.Inventory;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Shoot bouncing scissors from the machine gun! It's WaCKy!
///////////////////////////////////////////////////////////////////////////////
exec function NowWeDance()
{
	local MachinegunWeapon inv;

	if (!RecordCheater("NowWeDance",true))
		return;

	Inv = MachinegunWeapon(P2Player(Outer).MyPawn.FindInventoryType(class'MachineGunWeapon'));

	if(Inv != None)
	{
		if(inv.ShootScissors == 0)
		{
			P2Player(Outer).CommentOnCheating();
			inv.ShootScissors=1;
		}
		else
			inv.ShootScissors=0;
	}
}


///////////////////////////////////////////////////////////////////////////////
// Ghost mode
///////////////////////////////////////////////////////////////////////////////
exec function IFeelFree()
{
	if (!RecordCheater("IFeelFree",true))
		return;

	// Set ghost mode if you aren't exactly in ghost mode 
	if(!(bCheatFlying
		&& !Pawn.bCollideWorld))
	{
		Pawn.UnderWaterTime = -1.0;	
		ClientMessage("You feel free.");
		Pawn.SetCollision(false, false, false);
		Pawn.bCollideWorld = false;
		bCheatFlying = true;
		Outer.GotoState('PlayerFlying');
	}
	else
	{
		ResetFlying();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Fly mode
///////////////////////////////////////////////////////////////////////////////
exec function LikeABirdy()
{
	if (!RecordCheater("LikeABirdy",true))
		return;

	// Set Fly mode if you aren't exactly in Fly mode 
	if(!(bCheatFlying
		&& Pawn.bCollideWorld))
	{
		Pawn.UnderWaterTime = Pawn.Default.UnderWaterTime;	
		ClientMessage("You feel much lighter.");
		Pawn.SetCollision(true, true , true);
		Pawn.bCollideWorld = true;
		bCheatFlying = true;
		Outer.GotoState('PlayerFlying');
	}
	else
	{
		ResetFlying();
	}
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ResetFlying()
{	
	if ( Pawn != None )
	{
		bCheatFlying = false;
		Pawn.UnderWaterTime = Pawn.Default.UnderWaterTime;	
		Pawn.SetCollision(true, true , true);
		Pawn.SetPhysics(PHYS_Walking);
		Pawn.bCollideWorld = true;
		ClientReStart();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
exec function ViewClass( class<actor> aClass, optional bool bQuiet, optional bool bCheat )
{
	local actor other, first;
	local bool bFound;

	if(P2GameInfo(Level.Game) == None
		|| !FPSPlayer(Outer).DebugEnabled())
		return;

	if ( !bCheat && (Level.Game != None) && !Level.Game.bCanViewOthers )
		return;

	first = None;

	ForEach AllActors( aClass, other )
	{
		if ( bFound || (first == None) )
		{
			first = other;
			if ( bFound )
				break;
		}
		if ( other == ViewTarget ) 
			bFound = true;
	}  

	if ( first != None )
	{
		if ( !bQuiet )
		{
			if ( Pawn(first) != None )
				ClientMessage(ViewingFrom@First.GetHumanReadableName(), 'Event');
			else
				ClientMessage(ViewingFrom@first, 'Event');
		}
		SetViewTarget(first);
		bBehindView = ( ViewTarget != outer );

		if ( bBehindView )
			ViewTarget.BecomeViewTarget();

		FixFOV();
	}
	else
		ViewSelf(bQuiet);
}

///////////////////////////////////////////////////////////////////////////////
// In addition to our goofy versions, we allow the old versions, if the cheats
// are enabled.
///////////////////////////////////////////////////////////////////////////////
// Don't allow these actually, just use the "goofy" versions
exec function Fly();
exec function Walk();
exec function Ghost();
exec function Slomo(float T);
/*
exec function Fly()
{
	if(P2Player(Outer).CheatsAllowed())
		Super.Fly();	// Come on.. laugh! That's funny! The dude is SuperFly...
}
exec function Walk()
{	
	if(P2Player(Outer).CheatsAllowed())
		Super.Walk();
}
exec function Ghost()
{
	if(P2Player(Outer).CheatsAllowed())
		Super.Ghost();
}
exec function Slomo( float T )
{
	if(P2Player(Outer).CheatsAllowed())
		Level.Game.SetGameSpeed(T);
//		Level.Game.SaveConfig(); 
//		Level.Game.GameReplicationInfo.SaveConfig();
}
*/
///////////////////////////////////////////////////////////////////////////////
// Dangerous! Who knows how things like the clipboard or whatever will act
// if you set the ammo on that.
// Set ammo directly (changes max also)
///////////////////////////////////////////////////////////////////////////////
// Stub this out too, PayLoad now sets ammo to 9999 which should be way more than enough for anyone's needs
/*
exec function FeelLuckyPunk(int T)
{
	local P2Weapon p2w;
	if(!P2Player(Outer).CheatsAllowed()
		|| P2Player(Outer).MyPawn == None)
		return;

	p2w = P2Weapon(P2Player(Outer).MyPawn.Weapon);
	if(p2w != None
		&& p2w.AmmoType != None)
	{
		if(T < 0)
			T = 0;
		if(T > MAX_AMMO_NUM)
			T = MAX_AMMO_NUM;
		if(T > p2w.AmmoType.MaxAmmo)
			p2w.AmmoType.MaxAmmo = T;
		p2w.AmmoType.AmmoAmount = T;
	}

}
*/
///////////////////////////////////////////////////////////////////////////////
// Put this in becuase some people we're whining about 'releastic body damage'.
// So anyway, this makes it so any bullet shot from a gun will kill any person
// in one shot if they get hit in the head by the bullet. With the exception
// of the rifle and the shotgun (they already have their own headshot kills).
// So gosh.. guess we're just down to the pistol and the machinegun. 
///////////////////////////////////////////////////////////////////////////////
exec function HeadShots()
{
	if (!RecordCheater("HeadShots",true))
		return;

	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None)
	{
		if(!P2GameInfoSingle(Level.Game).TheGameState.bGetsHeadShots)
		{
			P2GameInfoSingle(Level.Game).TheGameState.bGetsHeadShots = true;
			ClientMessage("Increased head shot damage: enabled.");
		}
		else
		{
			P2GameInfoSingle(Level.Game).TheGameState.bGetsHeadShots = false;
			ClientMessage("Increased head shot damage: disabled.");
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Display the stats screen (called externally)
// Stub this out before release because the stats screen now triggers achievements
///////////////////////////////////////////////////////////////////////////////
exec function Sup()
{
	if (!FPSPlayer(Outer).DebugEnabled())
		return;
		
	P2Player(Outer).DisplayStats();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
exec function Bladey()
{
	local MacheteWeapon machweap;

	//if(!P2GameInfoSingle(Outer.Level.Game).FinallyOver())
	//	return;
	//if(!P2GameInfoSingle(Outer.Level.Game).DoMP3())
	//	return;
	if (!RecordCheater("Bladey",true))
		return;

	machweap = MacheteWeapon(P2Pawn(Pawn).CreateInventory("AWInventory.MacheteWeapon"));
	if(machweap != None)
		machweap.bBladey=!machweap.bBladey;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
exec function LimbSnapper()
{
	//if(!P2GameInfoSingle(Outer.Level.Game).FinallyOver())
	//	return;
	//if(!P2GameInfoSingle(Outer.Level.Game).DoMP1())
	//	return;
	if (!RecordCheater("LimbSnapper",true))
		return;

	P2Pawn(Pawn).CreateInventory("AWInventory.SledgeWeapon");
	P2Player(Outer).bLimbSnapper = !P2Player(Outer).bLimbSnapper;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
exec function HulkSmash()
{
	local SledgeWeapon sledgeweap;

	//if(!P2GameInfoSingle(Outer.Level.Game).FinallyOver())
	//	return;
	//if(!P2GameInfoSingle(Outer.Level.Game).DoMP1())
	//	return;
	if (!RecordCheater("HulkSmash",true))
		return;

	sledgeweap = SledgeWeapon(P2Pawn(Pawn).CreateInventory("AWInventory.SledgeWeapon"));
	if(sledgeweap != None)
		sledgeweap.bHulkSmash=!sledgeweap.bHulkSmash;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
exec function ReaperOfLove()
{
	local ScytheWeapon scytheweap;

	//if(!P2GameInfoSingle(Outer.Level.Game).FinallyOver())
	//	return;
	//if(!P2GameInfoSingle(Outer.Level.Game).DoMP2())
	//	return;
	if (!RecordCheater("ReaperOfLove",true))
		return;

	scytheweap = ScytheWeapon(P2Pawn(Pawn).CreateInventory("AWInventory.ScytheWeapon"));
	if(scytheweap != None)
		scytheweap.bReaper=!scytheweap.bReaper;
}

///////////////////////////////////////////////////////////////////////////////
// The Mighty Foot
// Gives player the Mighty Foot.
///////////////////////////////////////////////////////////////////////////////
exec function MightyFoot()
{
	local P2Pawn p2p;
	local Inventory thisinv;

	if (!RecordCheater("MightyFoot",true))
		return;
		
	P2GameInfoSingle(Level.Game).TheGameState.bMightyFoot = !P2GameInfoSingle(Level.Game).TheGameState.bMightyFoot;

	p2p = P2Player(Outer).MyPawn;
	if (P2GameInfoSingle(Level.Game).TheGameState.bMightyFoot)
		thisinv = P2P.CreateInventoryByClass(class'MightyFootWeapon');
	else
		thisinv = P2P.CreateInventoryByClass(class'FootWeapon');
	if(FootWeapon(thisinv) != None)
	{
		P2P.MyFoot = P2Weapon(thisinv);
		P2P.MyFoot.GotoState('Idle');
		P2P.MyFoot.bJustMade=false;
		if(P2P.Controller != None)
			P2P.Controller.NotifyAddInventory(P2P.MyFoot);
		P2P.ClientSetFoot(P2Weapon(thisinv));
	}

	if (P2GameInfoSingle(Level.Game).TheGameState.bMightyFoot)
		clientmessage("Mighty Foot activated");
	else
		clientmessage("Mighty Foot deactivated");
}

// Stubbed out -- didn't finish this in time
/*
exec function HereKittyKitty()
{
	local Inventory inv;

	if (!RecordCheater("HereKittyKitty",true))
		return;

	inv = P2Pawn(Pawn).CreateInventory("AWPStuff.CatLauncherWeapon");
	P2Weapon(Inv).bJustMade = False;
}
*/

///////////////////////////////////////////////////////////////////////////////
// Spawns a dog and makes him love you
// Enabled when you complete the game with no dogs killed
///////////////////////////////////////////////////////////////////////////////
exec function DogLover()
{
	local class<AWPDoghousePawn> aclass;
	local AWPDoghousePawn DogP;
	local AWPDoghouseController DogC;

//	if (!AW7GameInfo(Level.Game).MetoolEnabled())
//		return;
	if (!RecordCheater("DogLover",true))
		return;

	aclass = class<AWPDoghousePawn>(DynamicLoadObject("AWPStuff.AWPDoghousePawn", class'Class'));
	DogP=spawn(aclass,,,Outer.Pawn.Location,Outer.Pawn.Rotation);
	DogP.Skins[0]=DogSkins[Rand(DogSkins.Length)];
	AddController(DogP);
	DogC=AWPDoghouseController(DogP.Controller);
	DogC.HookHero(FPSPawn(Outer.Pawn)); // the player is our hero
	DogC.ChangeHeroLove(DogC.HERO_LOVE_MAX,0);
	DogC.GoToHero();
}

///////////////////////////////////////////////////////////////////////////////
// Add a controller to our newly spawned cat
///////////////////////////////////////////////////////////////////////////////
function AddController(FPSPawn newcat)
{
	if ( newcat.Controller == None
		&& newcat.Health > 0 )
	{
		if ( (newcat.ControllerClass != None))
			newcat.Controller = spawn(newcat.ControllerClass);
		if ( newcat.Controller != None )
			newcat.Controller.Possess(newcat);
		// Check for AI Script
		newcat.CheckForAIScript();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Bystanders hate cops
// Enabled when you complete the game with no cops killed
///////////////////////////////////////////////////////////////////////////////
exec function CopKilla()
{
	local Controller C;

	if (!RecordCheater("CopKilla",true))
		return;

	P2GameInfoSingle(Level.Game).TheGameState.bCopKilla = !P2GameInfoSingle(Level.Game).TheGameState.bCopKilla;

	if (P2GameInfoSingle(Level.Game).TheGameState.bCopKilla)
		Outer.ClientMessage("CopKilla ON");
	else
		Outer.ClientMessage("CopKilla OFF");
}

///////////////////////////////////////////////////////////////////////////////
// RocketConversion
// Converts rocket speed.
///////////////////////////////////////////////////////////////////////////////
function RocketConversion(class<LauncherProjectile> Proj, float SpeedMod)
{
	Proj.Default.Speed = Proj.Default.Speed * SpeedMod;
	Proj.Default.MaxSpeed = Proj.Default.MaxSpeed * SpeedMod;
	Proj.Default.ForwardAccelerationMag = Proj.Default.ForwardAccelerationMag * SpeedMod;
	if (class<LauncherSeekingProjectileTrad>(Proj) != None)
		class<LauncherSeekingProjectileTrad>(Proj).Default.SeekingAccelerationMag = class<LauncherSeekingProjectileTrad>(Proj).Default.SeekingAccelerationMag * SpeedMod;
	if (class<LauncherSeekingProjectile>(Proj) != None)
		class<LauncherSeekingProjectile>(Proj).Default.SeekingAccelerationMag = class<LauncherSeekingProjectile>(Proj).Default.SeekingAccelerationMag * SpeedMod;
}

///////////////////////////////////////////////////////////////////////////////
// Slow Rockets
// Slows down player rockets (for use with the rocket camera)
///////////////////////////////////////////////////////////////////////////////
exec function SlowRockets()
{
	if (!RecordCheater("SlowRockets",true))
		return;

	RocketConversion(class'LauncherProjectile', SLOW_ROCKETS);
	RocketConversion(class'LauncherSeekingProjectile', SLOW_ROCKETS);
	RocketConversion(class'LauncherSeekingProjectileTrad', SLOW_ROCKETS);
//	RocketConversion(class'NukeProjectile', SLOW_ROCKETS);

	Outer.ClientMessage("Rocket speed decreased");
}

///////////////////////////////////////////////////////////////////////////////
// Fast Rockets
// Slows down player rockets (for use with the rocket camera)
///////////////////////////////////////////////////////////////////////////////
exec function FastRockets()
{
	if (!RecordCheater("FastRockets",true))
		return;

	RocketConversion(class'LauncherProjectile', FAST_ROCKETS);
	RocketConversion(class'LauncherSeekingProjectile', FAST_ROCKETS);
	RocketConversion(class'LauncherSeekingProjectileTrad', FAST_ROCKETS);
//	RocketConversion(class'NukeProjectile', FAST_ROCKETS);

	Outer.ClientMessage("Rocket speed increased");
}

///////////////////////////////////////////////////////////////////////////////
// Normal Rockets
// Normalizes player rockets (for use with the rocket camera)
///////////////////////////////////////////////////////////////////////////////
exec function NormalRockets()
{
	if (!RecordCheater("NormalRockets",true))
		return;

	RocketConversion(class'LauncherProjectile', NORMAL_ROCKETS);
	RocketConversion(class'LauncherSeekingProjectile', NORMAL_ROCKETS);
	RocketConversion(class'LauncherSeekingProjectileTrad', NORMAL_ROCKETS);
//	RocketConversion(class'NukeProjectile', NORMAL_ROCKETS);

	Outer.ClientMessage("Rocket speed returned to normal");
}

// Stubbed out - not finished in time for patch

///////////////////////////////////////////////////////////////////////////////
// Bystanders help you
// Enabled when you complete the game without killing innocent bystanders
///////////////////////////////////////////////////////////////////////////////
exec function Charismatic()
{
	local P2Pawn CheckP;

	if (!RecordCheater("Charismatic",true))
		return;

	P2GameInfoSingle(Level.Game).TheGameState.bCharisma = !P2GameInfoSingle(Level.Game).TheGameState.bCharisma;

	if (P2GameInfoSingle(Level.Game).TheGameState.bCharisma)
	{
		Outer.ClientMessage("Charisma ON");
		foreach DynamicActors(class'P2Pawn', CheckP)
			if (!CheckP.bPlayerIsEnemy)
				{
					CheckP.bPlayerIsFriend = True;
					CheckP.FriendDamageThreshold = 1000;
				}
	}
	else
	{
		Outer.ClientMessage("Charisma OFF");
		foreach DynamicActors(class'P2Pawn', CheckP)
			CheckP.bPlayerIsFriend = CheckP.Default.bPlayerIsFriend;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Kamek edit: GhostTown -- removes everyone except for you
// Enabled when all cheats unlocked
///////////////////////////////////////////////////////////////////////////////
exec function GhostTown()
{
	local P2Pawn CheckP;

//	if (!AW7GameInfo(Level.Game).AllEnabled())
//		return;
	if (!RecordCheater("GhostTown",true))
		return;

	ForEach DynamicActors(class 'P2Pawn', CheckP) // For every Pawn on the current level
	{
		if (LambController(CheckP.Controller) != None) //  bystanders only
		{
			CheckP.Died(None, class'Gibbed', CheckP.Location); // kill it
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Kamek edit: Anarchy -- removes cops
///////////////////////////////////////////////////////////////////////////////
exec function Anarchist()
{
	local P2Pawn CheckP;

	if (!RecordCheater("Anarchist",true))
		return;

	ForEach DynamicActors(class 'P2Pawn', CheckP) // For every Pawn on the current level
	{
		if (CheckP.bAuthorityFigure) //  bystanders only
		{
			CheckP.Died(None, class'gibbed', CheckP.Location); // kill it
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Kamek edit: Get an STD
///////////////////////////////////////////////////////////////////////////////
exec function GonorrheaChaChaCha()
{
	if (!RecordCheater("GonorrheaChaChaCha",true))
		return;

	if (UrethraWeapon(P2Player(Outer).MyPawn.MyUrethra).IsInfected()) {
		ClientMessage("VD cured");
		UrethraWeapon(P2Player(Outer).MyPawn.MyUrethra).MakeCured();
	}
	else {
		ClientMessage("VD contracted");
		P2Player(Outer).MyPawn.CreateInventoryByClass(class'GonorrheaAmmoInv');
		UrethraWeapon(P2Player(Outer).MyPawn.MyUrethra).GiveAmmo(P2Player(Outer).MyPawn);

	}

	P2Player(Outer).CommentOnCheating();
}

///////////////////////////////////////////////////////////////////////////////
// Kamek edit: Turn on/off super jump
///////////////////////////////////////////////////////////////////////////////
exec function SuperMario()
{
	if (!RecordCheater("SuperMario",true))
		return;
		
	P2GameInfoSingle(Level.Game).TheGameState.bSuperMario = !P2GameInfoSingle(Level.Game).TheGameState.bSuperMario;

	if (P2GameInfoSingle(Level.Game).TheGameState.bSuperMario)
	{
		P2Player(Outer).MyPawn.JumpZ = P2Player(Outer).MyPawn.Default.JumpZ * MARIO_JUMP;
		P2Player(Outer).MyPawn.MaxFallSpeed = P2Player(Outer).MyPawn.Default.MaxFallSpeed * MARIO_JUMP;
	}
	else
	{
		P2Player(Outer).MyPawn.JumpZ = P2Player(Outer).MyPawn.Default.JumpZ;
		P2Player(Outer).MyPawn.MaxFallSpeed = P2Player(Outer).MyPawn.Default.MaxFallSpeed;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Oh hell that game was fuckin' AWFUL
///////////////////////////////////////////////////////////////////////////////
exec function SonicBoom()
{
	//P2Player(Outer).SayTime = P2Player(Outer).MyPawn.Say(P2Player(Outer).MyPawn.MyDialog.lPissOnSelf);
	SonicSpeed();
}

///////////////////////////////////////////////////////////////////////////////
// Kamek edit: Turn on/off super speed
// Enabled when you beat the game under a set time period
///////////////////////////////////////////////////////////////////////////////
exec function SonicSpeed()
{

//	if (!AW7GameInfo(Level.Game).MatrixEnabled())
//		return;

	if (!RecordCheater("SonicSpeed",true))
		return;
		
	P2GameInfoSingle(Level.Game).TheGameState.bSonicBoom = !P2GameInfoSingle(Level.Game).TheGameState.bSonicBoom;

	if (P2GameInfoSingle(Level.Game).TheGameState.bSonicBoom)
	{
		P2Player(Outer).MyPawn.GroundSpeedMult = SONIC_SPEED;
		P2Player(Outer).MyPawn.AccelRate = P2Player(Outer).MyPawn.Default.AccelRate * SONIC_SPEED;
		P2Player(Outer).MyPawn.LadderSpeed = P2Player(Outer).MyPawn.Default.LadderSpeed * SONIC_SPEED;
		P2Player(Outer).MyPawn.AirSpeed = P2Player(Outer).MyPawn.Default.AirSpeed * SONIC_SPEED;
	}
	else
	{
		P2Player(Outer).MyPawn.GroundSpeedMult = 1.0;
		P2Player(Outer).MyPawn.AccelRate = P2Player(Outer).MyPawn.Default.AccelRate;
		P2Player(Outer).MyPawn.LadderSpeed = P2Player(Outer).MyPawn.Default.LadderSpeed;
		P2Player(Outer).MyPawn.AirSpeed = P2Player(Outer).MyPawn.Default.AirSpeed;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Kamek edit: Give player lots of pizzas
///////////////////////////////////////////////////////////////////////////////
exec function Domino()
{
	local Inventory invadd;
	local P2PowerupInv ppinv;

	if (!RecordCheater("Domino",true))
		return;

	invadd = P2Player(Outer).MyPawn.CreateInventory("Inventory.PizzaInv");

	ppinv = P2PowerupInv(invadd);
	if(ppinv != None)
		ppinv.AddAmount(19);
}

///////////////////////////////////////////////////////////////////////////////
// Kamek edit: Give player lots of fast foods
///////////////////////////////////////////////////////////////////////////////
exec function JerkInYourBox()
{
	local Inventory invadd;
	local P2PowerupInv ppinv;

	if (!RecordCheater("JerkInYourBox",true))
		return;

	invadd = P2Player(Outer).MyPawn.CreateInventory("Inventory.FastFoodInv");

	ppinv = P2PowerupInv(invadd);
	if(ppinv != None)
		ppinv.AddAmount(19);
}

///////////////////////////////////////////////////////////////////////////////
// Kamek edit: Gravity code
///////////////////////////////////////////////////////////////////////////////
exec function MoonMan()
{
	local PhysicsVolume PV;
	
	if (!RecordCheater("MoonMan",true))
		return;
		
	P2GameInfoSingle(Level.Game).TheGameState.bMoonMan = !P2GameInfoSingle(Level.Game).TheGameState.bMoonMan;

	foreach AllActors(class'PhysicsVolume', PV)
		if (P2GameInfoSingle(Level.Game).TheGameState.bMoonMan)
			PV.Gravity = MoonGravity;
		else 
			PV.Gravity = EarthGravity;

	P2Player(Outer).CommentonCheating();
}

///////////////////////////////////////////////////////////////////////////////
// speed up firing rate
// Enabled after beating the game under a set period of time (same as Sonicboom)
///////////////////////////////////////////////////////////////////////////////
exec function TheQuick()
{
	local inventory thisinv;

//	if (!AW7GameInfo(Level.Game).MatrixEnabled())
//		return;

	if (!RecordCheater("TheQuick",true))
		return;
		
	P2GameInfoSingle(Level.Game).TheGameState.bTheQuick = true;
	P2Player(Outer).ChangeAllWeaponSpeeds(1.0);

	/*
	thisinv = P2Pawn(Pawn).Inventory;

	while(thisinv != None)
	{
		if(P2Weapon(thisinv) != None)
		{
			P2Weapon(thisinv).WeaponSpeedHolster = P2Weapon(thisinv).Default.WeaponSpeedHolster * QUICK_MULT;
			P2Weapon(thisinv).WeaponSpeedLoad = P2Weapon(thisinv).Default.WeaponSpeedLoad * QUICK_MULT;
			P2Weapon(thisinv).WeaponSpeedReload = P2Weapon(thisinv).Default.WeaponSpeedReload * QUICK_MULT;
			P2Weapon(thisinv).WeaponSpeedShoot1 = P2Weapon(thisinv).Default.WeaponSpeedShoot1 * QUICK_MULT;
			P2Weapon(thisinv).WeaponSpeedShoot2 = P2Weapon(thisinv).Default.WeaponSpeedShoot2 * QUICK_MULT;
		}
		if (MacheteWeapon(thisinv) != None)
			MacheteWeapon(thisinv).WeaponSpeedCatch = MacheteWeapon(thisinv).Default.WeaponSpeedCatch * QUICK_MULT;
		if (ScytheWeapon(thisinv) != None)
		{
			ScytheWeapon(thisinv).WeaponSpeedPullBackSwing = ScytheWeapon(thisinv).Default.WeaponSpeedPullBackSwing * QUICK_MULT;
			ScytheWeapon(thisinv).WeaponSpeedPullBackThrow = ScytheWeapon(thisinv).Default.WeaponSpeedPullBackThrow * QUICK_MULT;
		}
		if (SledgeWeapon(thisinv) != None)
		{
			SledgeWeapon(thisinv).WeaponSpeedPullBackSwing = SledgeWeapon(thisinv).Default.WeaponSpeedPullBackSwing * QUICK_MULT;
			SledgeWeapon(thisinv).WeaponSpeedPullBackThrow = SledgeWeapon(thisinv).Default.WeaponSpeedPullBackThrow * QUICK_MULT;
		}
		thisinv = thisinv.inventory;
	}
	*/
}

///////////////////////////////////////////////////////////////////////////////
// normal firing rate
///////////////////////////////////////////////////////////////////////////////
exec function UnQuick()
{
	local inventory thisinv;

//	if (!AW7GameInfo(Level.Game).MatrixEnabled())
//		return;

	if (!RecordCheater("UnQuick",true))
		return;
		
	P2GameInfoSingle(Level.Game).TheGameState.bTheQuick = false;
	P2Player(Outer).ChangeAllWeaponSpeeds(1.0);

	/*
	thisinv = P2Pawn(Pawn).Inventory;
	while(thisinv != None)
	{
		if(P2Weapon(thisinv) != None)
		{
			//P2Weapon(thisinv).WeaponSpeedIdle = 99;
			P2Weapon(thisinv).WeaponSpeedHolster = P2Weapon(thisinv).Default.WeaponSpeedHolster;
			P2Weapon(thisinv).WeaponSpeedLoad = P2Weapon(thisinv).Default.WeaponSpeedLoad;
			P2Weapon(thisinv).WeaponSpeedReload = P2Weapon(thisinv).Default.WeaponSpeedReload;
			P2Weapon(thisinv).WeaponSpeedShoot1 = P2Weapon(thisinv).Default.WeaponSpeedShoot1;
			P2Weapon(thisinv).WeaponSpeedShoot2 = P2Weapon(thisinv).Default.WeaponSpeedShoot2;
		}
		if (MacheteWeapon(thisinv) != None)
			MacheteWeapon(thisinv).WeaponSpeedCatch = MacheteWeapon(thisinv).Default.WeaponSpeedCatch;
		if (ScytheWeapon(thisinv) != None)
		{
			ScytheWeapon(thisinv).WeaponSpeedPullBackSwing = ScytheWeapon(thisinv).Default.WeaponSpeedPullBackSwing;
			ScytheWeapon(thisinv).WeaponSpeedPullBackThrow = ScytheWeapon(thisinv).Default.WeaponSpeedPullBackThrow;
		}
		if (SledgeWeapon(thisinv) != None)
		{
			SledgeWeapon(thisinv).WeaponSpeedPullBackSwing = SledgeWeapon(thisinv).Default.WeaponSpeedPullBackSwing;
			SledgeWeapon(thisinv).WeaponSpeedPullBackThrow = SledgeWeapon(thisinv).Default.WeaponSpeedPullBackThrow;
		}
		thisinv = thisinv.inventory;
	}
	*/

	ClientMessage("Normal fire applied to all currently-held weapons");
}

///////////////////////////////////////////////////////////////////////////////
// Bullet time
// Enabled when all cheats are unlocked
///////////////////////////////////////////////////////////////////////////////
exec function Bullet()
{
//	if (!AW7GameInfo(Level.Game).AllEnabled())
//		return;
		
	if (!RecordCheater("Bullet",true))
		return;
		
    if (Level.Game.GameSpeed == NORMAL_SPEED)
	{
		P2GameInfoSingle(Level.Game).PossibleSetGameSpeed(BULLET_SPEED);
		Outer.AddCameraEffect(BulletEffect);
		Pawn.PlaySound(bts);
    }
    else
	{
		P2GameInfoSingle(Level.Game).PossibleSetGameSpeed(NORMAL_SPEED);
		Outer.RemoveCameraEffect(BulletEffect);
		Pawn.PlaySound(bte);
    }
}

///////////////////////////////////////////////////////////////////////////////
// Anti-Bullet Time
// Make things go way fast for bored people
///////////////////////////////////////////////////////////////////////////////
exec function AntiBullet()
{
	if (!RecordCheater("AntiBullet",true))
		return;
    if (Level.Game.GameSpeed == NORMAL_SPEED)
	{
		P2GameInfoSingle(Level.Game).PossibleSetGameSpeed(ANTIBULLET_SPEED);
		Pawn.PlaySound(bte);
    }
    else
	{
		P2GameInfoSingle(Level.Game).PossibleSetGameSpeed(NORMAL_SPEED);
		Pawn.PlaySound(bts);
    }
}

function SetupMailDrops()
{
	local int i;
	local NavigationPoint N;
	
	if (ValidMailDrops.Length > 0)
		return;

	for (N = Level.NavigationPointList; N != None; N=N.NextNavigationPoint)
	{
		if (ClassIsChildOf(N.Class, class'PathNode'))
		{
			ValidMailDrops.Insert(0,1);
			ValidMailDrops[0] = N;
		}
	}
}

// RandomSpot()
// Returns a random path node.
function vector RandomSpot()
{
	return ValidMailDrops[Rand(ValidMailDrops.Length)].Location;
}



exec function PropBreaker()
{
	local PropBreakable pb;
	local KActorExplodable ka;
	local DoorMover dm;
	
	if (!RecordCheater("PropBreaker",false))
		return;

	foreach DynamicActors(class'PropBreakable', pb)
		pb.Trigger(None, None);
		
	foreach DynamicActors(class'KActorExplodable', ka)
		ka.Trigger(None, None);
		
	foreach DynamicActors(class'DoorMover', dm)
		dm.TakeDamage(dm.Health, None, dm.Location, vect(0,0,0), dm.DamagedBy[0]);
	
}

exec function EgoBoost()
{
	local P2MoCapPawn P;
	local int i;
	
	if (!RecordCheater("EgoBoost",true))
		return;		
		
	foreach DynamicActors(class'P2MoCapPawn', P)
		if (P.MyHead != None)
		{
			if (P.MyHead.DrawScale >= P.MyHead.Default.DrawScale * HEAD_SCALE * 5)
				return;

			// Scale head
			P.MyHead.SetDrawScale(P.MyHead.DrawScale * HEAD_SCALE);
			// Scale collision
			P.MyHead.SetCollisionSize(
				P.MyHead.CollisionRadius * HEAD_SCALE, 
				P.MyHead.CollisionHeight * HEAD_SCALE);
			// Scale boltons
			for (i=0; i < ArrayCount(P.Boltons); i++)
				if (!P.Boltons[i].bInActive
					&& P.Boltons[i].bAttachToHead
					&& P.Boltons[i].Part != None)
					P.Boltons[i].Part.SetDrawScale(P.Boltons[i].Part.DrawScale * HEAD_SCALE);
			// Scale voice
			//P.VoicePitch -= 0.25;
		}
}

exec function WitchDoctor()
{
	local P2MoCapPawn P;
	local int i;
	
	if (!RecordCheater("WitchDoctor",true))
		return;		
		
	foreach DynamicActors(class'P2MoCapPawn', P)
		if (P.MyHead != None)
		{
			if (P.MyHead.DrawScale <= P.MyHead.Default.DrawScale / HEAD_SCALE)
				return;
		
			// Scale head
			P.MyHead.SetDrawScale(P.MyHead.DrawScale / HEAD_SCALE);
			// Scale collision
			P.MyHead.SetCollisionSize(
				P.MyHead.CollisionRadius / HEAD_SCALE, 
				P.MyHead.CollisionHeight / HEAD_SCALE);
			// Scale boltons
			for (i=0; i < ArrayCount(P.Boltons); i++)
				if (!P.Boltons[i].bInActive
					&& P.Boltons[i].bAttachToHead
					&& P.Boltons[i].Part != None)
					P.Boltons[i].Part.SetDrawScale(P.Boltons[i].Part.DrawScale / HEAD_SCALE);
			// Scale voice
			//P.VoicePitch += 0.25;
		}
}

// Makes player 20% cooler
exec function TwentyPercent()
{
	local P2PowerupInv ppinv;
	local Inventory Inv;
	
	const TWENTY_PERCENT = 1.20;
	const TWENTY = 20;
	
	if (P2Player(Outer).bIsCool)
	{
		Outer.ClientMessage("You are already 20% cooler");
		return;
	}

	if (!RecordCheater("TwentyPercent",true))
		return;

	P2Player(Outer).MyPawn.JumpZ *= TWENTY_PERCENT;
	P2Player(Outer).MyPawn.MaxFallSpeed *= TWENTY_PERCENT;
	P2Player(Outer).MyPawn.GroundSpeedMult *= TWENTY_PERCENT;
	P2Player(Outer).MyPawn.AccelRate *= TWENTY_PERCENT;
	P2Player(Outer).MyPawn.LadderSpeed *= TWENTY_PERCENT;
	P2Player(Outer).ChangeAllWeaponSpeeds(1.2);
	P2Player(Outer).MyPawn.Health += (TWENTY * P2Player(Outer).MyPawn.HealthMax / 100);

	for( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory ) 
		if (Ammunition(Inv)!=None
			&& ClipboardAmmoInv(Inv) == None)	// Don't load up the clipboard this way
		{
			Ammunition(Inv).AmmoAmount += TWENTY;
			Ammunition(Inv).MaxAmmo += TWENTY;
		}
		else if (P2PowerupInv(Inv) != None)
		{
			P2PowerupInv(Inv).Amount += TWENTY;
		}

	P2Player(Outer).bIsCool = true;
	Outer.ClientMessage("You are now 20% cooler");
}

// dev anim cheat
exec function Animate(name Anim, optional float a, optional float b)
{
	if (FPSPlayer(Outer).DebugEnabled())
	{
		if (a == 0)	
			a = 1.0;
		if (b == 0)
			b = 0.15;
		if (anim == 's_laugh')
			P2Pawn(Pawn).Say(P2Pawn(Pawn).myDialog.lLaughing);
		Pawn.PlayAnim(Anim, a, b);
	}
}

exec function RestoreCheat(string CheatToRestore)
{
	local Inventory thisinv;
	local P2Pawn p2p;
	local PhysicsVolume PV;
	
	if (!P2GameInfoSingle(Level.Game).TheGameState.DidPlayerCheat())
		return;
		
	log("Restoring cheat after post travel:"@CheatToRestore);
	if (CheatToRestore == "MightyFoot")
	{
		p2p = P2Player(Outer).MyPawn;
		if (P2GameInfoSingle(Level.Game).TheGameState.bMightyFoot)
			thisinv = P2P.CreateInventoryByClass(class'MightyFootWeapon');
		else
			thisinv = P2P.CreateInventoryByClass(class'FootWeapon');
		if(FootWeapon(thisinv) != None)
		{
			P2P.MyFoot = P2Weapon(thisinv);
			P2P.MyFoot.GotoState('Idle');
			P2P.MyFoot.bJustMade=false;
			if(P2P.Controller != None)
				P2P.Controller.NotifyAddInventory(P2P.MyFoot);
			P2P.ClientSetFoot(P2Weapon(thisinv));
		}
	}
	if (CheatToRestore == "SuperMario")
	{
		P2Player(Outer).MyPawn.JumpZ = P2Player(Outer).MyPawn.Default.JumpZ * MARIO_JUMP;
		P2Player(Outer).MyPawn.MaxFallSpeed = P2Player(Outer).MyPawn.Default.MaxFallSpeed * MARIO_JUMP;
	}
	if (CheatToRestore == "SonicBoom")
	{
		P2Player(Outer).MyPawn.GroundSpeedMult = SONIC_SPEED;
		P2Player(Outer).MyPawn.AccelRate = P2Player(Outer).MyPawn.Default.AccelRate * SONIC_SPEED;
		P2Player(Outer).MyPawn.LadderSpeed = P2Player(Outer).MyPawn.Default.LadderSpeed * SONIC_SPEED;
		P2Player(Outer).MyPawn.AirSpeed = P2Player(Outer).MyPawn.Default.AirSpeed * SONIC_SPEED;
	}
	if (CheatToRestore == "MoonMan")
	{
		foreach AllActors(class'PhysicsVolume', PV)
			PV.Gravity = MoonGravity;
	}
}

exec function step1()
{
	local AWPerson P;
	local int i;
	local int damage;
	local Vector Momentum, HitLocation;
	
	foreach DynamicActors(class'AWPerson', P)
		if (P.Controller == None || PlayerController(P.Controller) == None)
		{
			i = 1 - i;
			if (i == 1)
			{
				Momentum = VRand();
				Momentum.Z = FRand() * 2;
				Momentum *= class'FootAmmoInv'.Default.MomentumHitMag;
				if (!P.bMissingBottomHalf && !P.bMissingTopHalf && P.MyHead != None)
				{
					P.BlowOffHeadAndLimbs(Outer.Pawn, Momentum, damage);
					P.ChopInHalf(Outer.Pawn, class'ScytheDamage', Momentum, Damage, HitLocation);
				}
				P.TakeDamage(Damage, Outer.Pawn, HitLocation, Momentum, class'Crushed');
			}
		}
}

exec function step2()
{
	local AWPerson P;
	local PeoplePart P2;
	local Vector Momentum;
	
	foreach DynamicActors(class'AWPerson', P)
		if (P.Controller == None || PlayerController(P.Controller) == None)
		{
			Momentum = VRand();
			Momentum.Z = FRand() * 2;
			Momentum *= class'FootAmmoInv'.Default.MomentumHitMag;
			P.TakeDamage(1, Outer.Pawn, P.Location, Momentum, class'KickingDamage');
		}
	/*
	foreach DynamicActors(class'PeoplePart', P2)
	{
		Momentum = VRand();
		Momentum.Z = FRand() * 50;
		Momentum *= class'FootAmmoInv'.Default.MomentumHitMag;
		P2.TakeDamage(1, Outer.Pawn, P.Location, Momentum, class'KickingDamage');
	}
	*/
}

exec function step3profit()
{
	local AWPerson P;
	
	foreach DynamicActors(class'AWPerson', P)
		if (P.Health <= 0)
		{
			if (P.Health > 0)
				P.TakeDamage(9999, Outer.Pawn, P.Location, vect(0,0,0), class'Gibbed');
			else
				P.ChunkUp(9999);
		}
}

exec function crashme()
{
	step1();
	step2();
	step3profit();
}

///////////////////////////////////////////////////////////////////////////////
// Console commands to disable specific parts of Halloween event. Not actually
// cheats since they can be used without adversely affecting achievements, etc.
///////////////////////////////////////////////////////////////////////////////

// Disables Halloween skeletons
exec function NoAgitatingSkeletons()
{
	ConsoleCommand("set Postal2Game.P2GameInfoSingle bNoHolidays true");
	ConsoleCommand("set Postal2Game.GameState bNoHolidays true");
	ClientMessage(NoSkeletonsText);
}

//Disables night mode
exec function TooSpookyForMe()
{
	ConsoleCommand("set Postal2Game.GameState bNightMode false");
	ClientMessage(NightModeOffText);
}

defaultproperties
{
	FanaticsTalking=Sound'HabibDialog.habib_ailili'
	KrotchyTalking=Sound'KrotchyDialog.wm_krotchy_bitchyougot'
	MikeJTalking=Sound'MikeJDialog.Cuss_7'
	ZombieTalking=Sound'AWDialog.Zombie.zombie_curse5'
	DogSkins[0]=Texture'AnimalSkins.Dog'
	DogSkins[1]=Texture'AnimalSkins.Dog2'
	DogSkins[2]=Texture'AnimalSkins.Dog3'
	DogSkins[3]=Texture'AnimalSkins.Dog4'
	DogSkins[4]=Shader'AW_Characters.Animals.Dog_Gimp_Shader'
	DogSkins[5]=Texture'AW_Characters.Animals.UberChamp'
	CatSkins[0]=Texture'AnimalSkins.Cat_Black'
	CatSkins[1]=Texture'AnimalSkins.Cat_Grey'
	CatSkins[2]=Texture'AnimalSkins.Cat_Orange'
	CatSkins[3]=Texture'AnimalSkins.Cat_Siamese'
//	CatSkins[4]=Texture'AW_Characters.Animals.Cat_Gimp'
	Begin Object Class=MotionBlur Name=MotionBlur0
		Alpha=1.00
		FinalEffect=False
		BlurAlpha=120
	End Object
	BulletEffect=MotionBlur'MotionBlur0'
	//DropCatClassStr="People.AWCatPawn"
	EarthGravity=(Z=-1500)
	MoonGravity=(Z=-250)
	WrongItemSound[0]=Sound'DudeDialog.dude_notright'
	WrongItemSound[1]=Sound'DudeDialog.dude_nope'
	LoadoutDays[0]=(Items=((Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=50),(Item=class'GrenadeWeapon',Amount=5),(Item=class'PizzaInv',Amount=5),(Item=class'CrackInv'),(Item=class'MachineGunWeapon',Amount=100),(Item=class'RadarInv',Amount=200),(Item=class'GasCanWeapon',Amount=50)))
	LoadoutDays[1]=(Items=((Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=100),(Item=class'GSelectWeapon',Amount=50),(Item=class'GrenadeWeapon',Amount=10),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv'),(Item=class'ShotgunWeapon',Amount=30),(Item=class'FastFoodInv',Amount=5),(Item=class'MachineGunWeapon',Amount=100),(Item=class'RadarInv',Amount=200),(Item=class'GasCanWeapon',Amount=100)))
	LoadoutDays[2]=(Items=((Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=150),(Item=class'GSelectWeapon',Amount=100),(Item=class'GrenadeWeapon',Amount=15),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=2),(Item=class'ShotgunWeapon',Amount=60),(Item=class'FastFoodInv',Amount=5),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=100),(Item=class'MachineGunWeapon',Amount=100),(Item=class'KevlarInv'),(Item=class'CatnipInv'),(Item=class'RadarInv',Amount=200),(Item=class'GasCanWeapon',Amount=10)))
	LoadoutDays[3]=(Items=((Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=200),(Item=class'GSelectWeapon',Amount=150),(Item=class'GrenadeWeapon',Amount=20),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=3),(Item=class'ShotgunWeapon',Amount=90),(Item=class'FastFoodInv',Amount=10),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=150),(Item=class'MachineGunWeapon',Amount=150),(Item=class'KevlarInv'),(Item=class'CatnipInv'),(Item=class'RadarInv',Amount=200),(Item=class'LauncherWeapon',Amount=100),(Item=class'MacheteWeapon'),(Item=class'GasCanWeapon',Amount=10)))
	LoadoutDays[4]=(Items=((Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=250),(Item=class'GSelectWeapon',Amount=200),(Item=class'GrenadeWeapon',Amount=25),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=3),(Item=class'ShotgunWeapon',Amount=120),(Item=class'FastFoodInv',Amount=10),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=200),(Item=class'MachineGunWeapon',Amount=200),(Item=class'BodyArmorInv'),(Item=class'CatnipInv',Amount=2),(Item=class'RadarInv',Amount=200),(Item=class'LauncherWeapon',Amount=100),(Item=class'MacheteWeapon'),(Item=class'ChainsawWeapon',Amount=150),(Item=class'GasCanWeapon',Amount=100)))
	LoadoutDays[5]=(Items=((Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=250),(Item=class'GSelectWeapon',Amount=200),(Item=class'GrenadeWeapon',Amount=25),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=3),(Item=class'ShotgunWeapon',Amount=120),(Item=class'FastFoodInv',Amount=10),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=200),(Item=class'MachineGunWeapon',Amount=200),(Item=class'BodyArmorInv'),(Item=class'CatnipInv',Amount=2),(Item=class'RadarInv',Amount=200),(Item=class'LauncherWeapon',Amount=100),(Item=class'MacheteWeapon'),(Item=class'ChainsawWeapon',Amount=150),(Item=class'GasCanWeapon',Amount=100)))
	LoadoutDays[6]=(Items=((Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=250),(Item=class'GSelectWeapon',Amount=200),(Item=class'GrenadeWeapon',Amount=25),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=3),(Item=class'ShotgunWeapon',Amount=120),(Item=class'FastFoodInv',Amount=10),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=200),(Item=class'MachineGunWeapon',Amount=200),(Item=class'BodyArmorInv'),(Item=class'CatnipInv',Amount=2),(Item=class'RadarInv',Amount=200),(Item=class'LauncherWeapon',Amount=100),(Item=class'MacheteWeapon'),(Item=class'ChainsawWeapon',Amount=150),(Item=class'GasCanWeapon',Amount=100)))
	
	NoSkeletonsText="It's as if millions of doots suddenly cried out in terror and were suddenly silenced."
	NightModeOffText="The day will return to you in due time."
}
