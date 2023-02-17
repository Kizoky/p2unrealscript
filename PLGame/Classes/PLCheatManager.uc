///////////////////////////////////////////////////////////////////////////////
// PL CheatManager
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// We might change the cheat codes later, but for now just piggyback
// off the P2 cheats. - Rick
///////////////////////////////////////////////////////////////////////////////
class PLCheatManager extends P2CheatManager;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var() sound BooksTalking;
var() sound MiloTalking;
var() sound PisstrapTalking;

struct Partners
{
	var() float Weight;
	var class<PartnerPawn> PawnClass;
};

var() array<Partners> PossiblePartners;	// Possible partners for the CoverMyAss cheat

var() array<Material> MutantSkins;

///////////////////////////////////////////////////////////////////////////////
// Spawns a mutant dog and makes him love you
///////////////////////////////////////////////////////////////////////////////
exec function BeastLove()
{
	local class<MutantDoghousePawn> aclass;
	local MutantDoghousePawn DogP;
	local AWPDoghouseController DogC;

//	if (!AW7GameInfo(Level.Game).MetoolEnabled())
//		return;
	if (!RecordCheater("BeastLove",true))
		return;

	aclass = class<MutantDoghousePawn>(DynamicLoadObject("PLPawns.MutantDoghousePawn", class'Class'));
	DogP=spawn(aclass,,,Outer.Pawn.Location,Outer.Pawn.Rotation);
	DogP.Skins[0]=MutantSkins[Rand(MutantSkins.Length)];
	AddController(DogP);
	DogC=AWPDoghouseController(DogP.Controller);
	DogC.HookHero(FPSPawn(Outer.Pawn)); // the player is our hero
	DogC.ChangeHeroLove(DogC.HERO_LOVE_MAX,0);
	DogC.GoToHero();
}

///////////////////////////////////////////////////////////////////////////////
// Spawns Super Champ
///////////////////////////////////////////////////////////////////////////////
exec function DudesBestFriend()
{
	local class<DogPawn> aclass;
	local DogPawn DogP;
	local DogController DogC;

	if (!RecordCheater("DudesBestFriend",true))
		return;

	aclass = class<DogPawn>(DynamicLoadObject("PLPawns.PLSuperChamp", class'Class'));
	DogP=spawn(aclass,,,Outer.Pawn.Location,Outer.Pawn.Rotation);
	AddController(DogP);
	DogC=DogController(DogP.Controller);
	DogC.HookHero(FPSPawn(Outer.Pawn)); // the player is our hero
	DogC.ChangeHeroLove(DogC.HERO_LOVE_MAX,0);
	DogC.GoToHero();
}

///////////////////////////////////////////////////////////////////////////////
// DEBUG - Gives player all PL weapons
///////////////////////////////////////////////////////////////////////////////
exec function PLWeapons()
{
	local Inventory thisinv;
	local class<Inventory> TestClass;
	local int i;

	if (!RecordCheater("PLWeapons",true))
		return;

	P2Pawn(Pawn).CreateInventory("PLInventory.BeanBagWeapon");
	P2Pawn(Pawn).CreateInventory("PLInventory.FGrenadeWeapon");
	P2Pawn(Pawn).CreateInventory("PLInventory.LeverActionShotgunWeapon");
	P2Pawn(Pawn).CreateInventory("PLInventory.RevolverWeapon");
	P2Pawn(Pawn).CreateInventory("PLInventory.WeedWeapon");
	P2Pawn(Pawn).CreateInventory("PLInventory.PL_DildoWeapon");
	P2Pawn(Pawn).CreateInventory("PLInventory.PLSwordWeapon");
	
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
	//P2Pawn(Pawn).CreateInventory("AWPStuff.ChainSawWeapon");
	P2Pawn(Pawn).CreateInventory("AWPStuff.DustersWeapon");
	P2Pawn(Pawn).CreateInventory("AWPStuff.FlameWeapon");
	//P2Pawn(Pawn).CreateInventory("AWPStuff.SawnOffWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.ShearsWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.AxeWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.BaliWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.DynamiteWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.GSelectWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.GrenadeLauncherWeapon");
	P2Pawn(Pawn).CreateInventory("EDStuff.MP5Weapon");

	// For debugging, give 'em everything. FIXME before final release - K
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
		
	P2Pawn(Pawn).CreateInventory("PLInventory.BeanBagWeapon");
	P2Pawn(Pawn).CreateInventory("PLInventory.FGrenadeWeapon");
	P2Pawn(Pawn).CreateInventory("PLInventory.LeverActionShotgunWeapon");
	P2Pawn(Pawn).CreateInventory("PLInventory.RevolverWeapon");
	
	if (PLPlayer(Outer).bWeed)
		P2Pawn(Pawn).CreateInventory("PLInventory.WeedWeapon");
	if (PLPlayer(Outer).bDong)
		P2Pawn(Pawn).CreateInventory("PLInventory.PL_DildoWeapon");
	if (PLPlayer(Outer).bSord)
		P2Pawn(Pawn).CreateInventory("PLInventory.PLSwordWeapon");
	
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

///////////////////////////////////////////////////////////////////////////////
// DEBUG - Gives player a karma gun
///////////////////////////////////////////////////////////////////////////////
exec function KarmaGun()
{
	local Inventory thisinv;

	if (!RecordCheater("KarmaGun",true))
		return;
		
	thisinv = P2Pawn(Pawn).CreateInventoryByClass(class'P2EHandsWeapon');

	// Force it to come out immediately
	if (thisinv != None)
	{
		Pawn.PendingWeapon = Weapon(thisinv);
		P2Weapon(Pawn.PendingWeapon).SetReadyForUse(true);
		if ( Pawn.Weapon == None
			|| Pawn.Weapon.bDeleteMe)
			Pawn.ChangedWeapon();

		if ( Pawn.Weapon != Pawn.PendingWeapon
			&& Pawn.PendingWeapon != None)
			Pawn.Weapon.PutDown();
	}
}

///////////////////////////////////////////////////////////////////////////////
// This cheat code is offered with no explanation or apology.
///////////////////////////////////////////////////////////////////////////////
exec function BadBooks()
{
	local class<P2Pawn> PawnClass;
	
	if (!RecordCheater("BadBooks",false))
		return;

	ClientMessage("Shelving your bystanders--please wait.");
	
	PawnClass = class<P2Pawn>(DynamicLoadObject("PLPawns.ThatFuckingBookcase", class'Class'));

	DudePlayer(Outer).ConvertNonImportants(PawnClass);

	DudePlayer(Outer).MyPawn.PlaySound(BooksTalking);
}

///////////////////////////////////////////////////////////////////////////////
// ...???
///////////////////////////////////////////////////////////////////////////////
exec function AndN()
{
	local class<P2Pawn> PawnClass;
	
	if (!RecordCheater("AndN",false))
		return;

	ClientMessage("Commencing patriarchial oppression--please wait.");
	
	PawnClass = class<P2Pawn>(DynamicLoadObject("PLPawns.Milo", class'Class'));

	DudePlayer(Outer).ConvertNonImportants(PawnClass);

	DudePlayer(Outer).MyPawn.PlaySound(MiloTalking);
}

///////////////////////////////////////////////////////////////////////////////
// Dual Wield baby!
///////////////////////////////////////////////////////////////////////////////
exec function FunzerkingKicksAss()
{
	local P2DualWieldWeapon weap;
	local bool bShouldDualWield;
	
	if (!RecordCheater("FunzerkingKicksAss",true))
		return;
		
	P2Player(Outer).bCheatDualWield = !P2Player(Outer).bCheatDualWield;
	PLGameState(P2GameInfoSingle(Level.Game).TheGameState).bFunzerking = P2Player(Outer).bCheatDualWield;
	
	weap = P2DualWieldWeapon(Outer.Pawn.Weapon);
	if (weap != None)
	{
		bShouldDualWield = P2Player(Outer).bCheatDualWield || P2Player(Outer).DualWieldUseTime > 0;
		weap.SetupDualWielding();
		if (bShouldDualWield != weap.bDualWielding)
			weap.GotoState('ToggleDualWielding');
	}
}

///////////////////////////////////////////////////////////////////////////////
// CoverMyAss
// Gives player a partner radio (if they don't have one) and assigns a partner
// to help cover them
///////////////////////////////////////////////////////////////////////////////
exec function CoverMyAss()
{
	local PartnerRadioWeapon partweap;
	local byte bCreatedNow;
	local float MaxWeight, Seed;
	local int i;
	
	if (!RecordCheater("CoverMyAss",false))
		return;
		
	partweap = PartnerRadioWeapon(P2Pawn(Outer.Pawn).CreateInventoryByClass(class'PartnerRadioWeapon', bCreatedNow));
	
	// If they already have one, this fails
	if (partweap == None || bCreatedNow == 0)
		DudePlayer(Outer).MyPawn.PlaySound(WrongItemSound[rand(WrongItemSound.Length)]);
	else // Give them a random-ish partner
	{
		P2Player(Outer).CommentOnCheating();
		
		for (i = 0; i < PossiblePartners.Length; i++)
			MaxWeight += PossiblePartners[i].Weight;
			
		Seed = FRand() * MaxWeight;
		for (i = 0; i < PossiblePartners.Length; i++)
		{
			MaxWeight -= PossiblePartners[i].Weight;
			if (Seed >= MaxWeight)
			{
				partweap.PartnerClass = PossiblePartners[i].PawnClass;
				break;
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Restore cheats after a level transition
///////////////////////////////////////////////////////////////////////////////
exec function RestoreCheat(string CheatToRestore)
{
	local P2DualWieldWeapon weap;
	Super.RestoreCheat(CheatToRestore);
	
	if (!P2GameInfoSingle(Level.Game).TheGameState.DidPlayerCheat())
		return;
	
	if (CheatToRestore == "FunzerkingKicksAss")
	{
		P2Player(Outer).bCheatDualWield = true;
		weap = P2DualWieldWeapon(Outer.Pawn.Weapon);
		if (weap != None)
		{
			weap.SetupDualWielding();
			if (!weap.bDualWielding)
				weap.GotoState('ToggleDualWielding');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// What is this, a gun that makes ants?
///////////////////////////////////////////////////////////////////////////////
exec function GunForAnts()
{
	local Inventory thisinv;
	
	if (!RecordCheater("GunForAnts",true))
		return;
		
	thisinv = P2Pawn(Pawn).CreateInventoryByClass(class'EnsmallenWeaponCheat');

	// Force it to come out immediately
	if (thisinv != None)
	{
		Pawn.PendingWeapon = Weapon(thisinv);
		P2Weapon(Pawn.PendingWeapon).SetReadyForUse(true);
		if ( Pawn.Weapon == None
			|| Pawn.Weapon.bDeleteMe)
			Pawn.ChangedWeapon();

		if ( Pawn.Weapon != Pawn.PendingWeapon
			&& Pawn.PendingWeapon != None)
			Pawn.Weapon.PutDown();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Stop! Hammertime.
///////////////////////////////////////////////////////////////////////////////
exec function HammerTime()
{
	local Inventory thisinv;
	
	if (!RecordCheater("HammerTime",true))
		return;
		
	thisinv = P2Pawn(Pawn).CreateInventoryByClass(class'HammerWeapon');

	// Force it to come out immediately
	if (thisinv != None)
	{
		Pawn.PendingWeapon = Weapon(thisinv);
		P2Weapon(Pawn.PendingWeapon).SetReadyForUse(true);
		if ( Pawn.Weapon == None
			|| Pawn.Weapon.bDeleteMe)
			Pawn.ChangedWeapon();

		if ( Pawn.Weapon != Pawn.PendingWeapon
			&& Pawn.PendingWeapon != None)
			Pawn.Weapon.PutDown();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Give player the cop clothes
///////////////////////////////////////////////////////////////////////////////
exec function IAmTheLaw()
{
	local Inventory invadd;

	if (!RecordCheater("IAmTheLaw",true))
		return;

	invadd = P2Pawn(Pawn).CreateInventory("PLInventory.LawmanClothesInv");

	P2Player(Outer).CommentOnCheating();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
exec function AmazingAquaCura()
{
	local Inventory invadd;
	local P2PowerupInv ppinv;

	if (!RecordCheater("AmazingAquaCura",true))
		return;

	invadd = P2Player(Outer).MyPawn.CreateInventory("PLInventory.WaterBottleInv");

	ppinv = P2PowerupInv(invadd);
	if(ppinv != None)
		ppinv.AddAmount(19);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
exec function BullHonkey()
{
	local Inventory invadd;
	local P2PowerupInv ppinv;

	if (!RecordCheater("BullHonkey",true))
		return;

	invadd = P2Player(Outer).MyPawn.CreateInventory("PLInventory.DualWieldInv");

	ppinv = P2PowerupInv(invadd);
	if(ppinv != None)
		ppinv.AddAmount(19);
}

///////////////////////////////////////////////////////////////////////////////
// Turns every current non-player, bystander pawns into Fanatics
///////////////////////////////////////////////////////////////////////////////
exec function Osama()
{
	if (!RecordCheater("Osama",false))
		return;

	ClientMessage("Fanaticizing your bystanders--please wait.");

	DudePlayer(Outer).ConvertNonImportants(class'PLFanatics',,,true,,true);
	DudePlayer(Outer).ConvertNonImportants(class'PLKumquat',,,true,true);

	DudePlayer(Outer).MyPawn.PlaySound(FanaticsTalking);
}

///////////////////////////////////////////////////////////////////////////////
// Assimilates your bystanders
///////////////////////////////////////////////////////////////////////////////
exec function Robolution()
{
	local class<P2Pawn> PawnClass;
	local VendACurePawn piss;
	
	if (!RecordCheater("Robolution",false))
		return;

	ClientMessage("Commencing robot uprising--please wait.");
	
	PawnClass = class<P2Pawn>(DynamicLoadObject("PLPawns.VendACurePawn", class'Class'));

	DudePlayer(Outer).ConvertNonImportants(PawnClass);

	// Convert to riot mode
	foreach DynamicActors(class'VendACurePawn', piss)
		piss.bRiotMode = true;
	
	DudePlayer(Outer).MyPawn.PlaySound(PisstrapTalking);
}

///////////////////////////////////////////////////////////////////////////////
// Defaults
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	BooksTalking=Sound'LevelSoundsToo.library.woodCrash02'
	MiloTalking=Sound'BritMaleDialog.BritMale-GenericAnswer-02FullMacintosh'
	PisstrapTalking=Sound'PisstrapDialog.CombatTaunts.PissTrap-IntoWatersports'
	LoadoutDays[0]=(Items=((Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=50),(Item=class'RevolverWeapon',Amount=50),(Item=class'GrenadeWeapon',Amount=5),(Item=class'PizzaInv',Amount=5),(Item=class'CrackInv'),(Item=class'MachineGunWeapon',Amount=100),(Item=class'RadarInv',Amount=200),(Item=class'GasCanWeapon',Amount=50)))
	LoadoutDays[1]=(Items=((Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=100),(Item=class'RevolverWeapon',Amount=100),(Item=class'GSelectWeapon',Amount=50),(Item=class'GrenadeWeapon',Amount=10),(Item=class'FGrenadeWeapon',Amount=10),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv'),(Item=class'LeverActionShotgunWeapon',Amount=30),(Item=class'ShotgunWeapon',Amount=30),(Item=class'FastFoodInv',Amount=5),(Item=class'MachineGunWeapon',Amount=100),(Item=class'RadarInv',Amount=200),(Item=class'GasCanWeapon',Amount=100)))
	LoadoutDays[2]=(Items=((Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=150),(Item=class'RevolverWeapon',Amount=150),(Item=class'GSelectWeapon',Amount=100),(Item=class'GrenadeWeapon',Amount=15),(Item=class'FGrenadeWeapon',Amount=15),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=2),(Item=class'LeverActionShotgunWeapon',Amount=60),(Item=class'ShotgunWeapon',Amount=60),(Item=class'FastFoodInv',Amount=5),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=100),(Item=class'MachineGunWeapon',Amount=100),(Item=class'KevlarInv'),(Item=class'CatnipInv'),(Item=class'RadarInv',Amount=200),(Item=class'GasCanWeapon',Amount=10)))
	LoadoutDays[3]=(Items=((Item=class'PLSwordWeapon'),(Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=200),(Item=class'RevolverWeapon',Amount=200),(Item=class'GSelectWeapon',Amount=150),(Item=class'GrenadeWeapon',Amount=20),(Item=class'FGrenadeWeapon',Amount=20),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=3),(Item=class'LeverActionShotgunWeapon',Amount=90),(Item=class'ShotgunWeapon',Amount=90),(Item=class'FastFoodInv',Amount=10),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=150),(Item=class'MachineGunWeapon',Amount=150),(Item=class'KevlarInv'),(Item=class'CatnipInv'),(Item=class'RadarInv',Amount=200),(Item=class'LauncherWeapon',Amount=100),(Item=class'DualWieldInv'),(Item=class'MacheteWeapon'),(Item=class'GasCanWeapon',Amount=10)))
	LoadoutDays[4]=(Items=((Item=class'PLSwordWeapon'),(Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=250),(Item=class'RevolverWeapon',Amount=250),(Item=class'GSelectWeapon',Amount=200),(Item=class'GrenadeWeapon',Amount=25),(Item=class'FGrenadeWeapon',Amount=20),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=3),(Item=class'LeverActionShotgunWeapon',Amount=120),(Item=class'ShotgunWeapon',Amount=120),(Item=class'FastFoodInv',Amount=10),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=200),(Item=class'MachineGunWeapon',Amount=200),(Item=class'BodyArmorInv'),(Item=class'CatnipInv',Amount=2),(Item=class'RadarInv',Amount=200),(Item=class'LauncherWeapon',Amount=100),(Item=class'DualWieldInv',Amount=2),(Item=class'MacheteWeapon'),(Item=class'WeedWeapon',Amount=150),(Item=class'GasCanWeapon',Amount=100)))
	LoadoutDays[5]=(Items=((Item=class'PLSwordWeapon'),(Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=250),(Item=class'RevolverWeapon',Amount=250),(Item=class'GSelectWeapon',Amount=200),(Item=class'GrenadeWeapon',Amount=25),(Item=class'FGrenadeWeapon',Amount=20),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=3),(Item=class'LeverActionShotgunWeapon',Amount=120),(Item=class'ShotgunWeapon',Amount=120),(Item=class'FastFoodInv',Amount=10),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=200),(Item=class'MachineGunWeapon',Amount=200),(Item=class'BodyArmorInv'),(Item=class'CatnipInv',Amount=2),(Item=class'RadarInv',Amount=200),(Item=class'LauncherWeapon',Amount=100),(Item=class'DualWieldInv',Amount=2),(Item=class'MacheteWeapon'),(Item=class'WeedWeapon',Amount=150),(Item=class'GasCanWeapon',Amount=100)))
	LoadoutDays[6]=(Items=((Item=class'PLSwordWeapon'),(Item=class'ShovelWeapon'),(Item=class'PistolWeapon',Amount=250),(Item=class'RevolverWeapon',Amount=250),(Item=class'GSelectWeapon',Amount=200),(Item=class'GrenadeWeapon',Amount=25),(Item=class'FGrenadeWeapon',Amount=20),(Item=class'PizzaInv',Amount=10),(Item=class'CrackInv',Amount=3),(Item=class'LeverActionShotgunWeapon',Amount=120),(Item=class'ShotgunWeapon',Amount=120),(Item=class'FastFoodInv',Amount=10),(Item=class'SledgeWeapon'),(Item=class'MP5Weapon',Amount=200),(Item=class'MachineGunWeapon',Amount=200),(Item=class'BodyArmorInv'),(Item=class'CatnipInv',Amount=2),(Item=class'RadarInv',Amount=200),(Item=class'LauncherWeapon',Amount=100),(Item=class'DualWieldInv',Amount=2),(Item=class'MacheteWeapon'),(Item=class'WeedWeapon',Amount=150),(Item=class'GasCanWeapon',Amount=100)))
	PossiblePartners[0]=(Weight=100,PawnClass=class'PartnerPawn_UncleDave')
	PossiblePartners[1]=(Weight=100,PawnClass=class'PartnerPawn_RWSMikeJ')
	PossiblePartners[2]=(Weight=10,PawnClass=class'PartnerPawn_RWSBob')
	PossiblePartners[3]=(Weight=10,PawnClass=class'PartnerPawn_RWSJon')
	PossiblePartners[4]=(Weight=10,PawnClass=class'PartnerPawn_RWSKurt')
	PossiblePartners[5]=(Weight=10,PawnClass=class'PartnerPawn_RWSMick')
	PossiblePartners[6]=(Weight=10,PawnClass=class'PartnerPawn_RWSRickF')
	PossiblePartners[7]=(Weight=10,PawnClass=class'PartnerPawn_RWSRikki')
	PossiblePartners[8]=(Weight=10,PawnClass=class'PartnerPawn_RWSSim')
	PossiblePartners[9]=(Weight=3,PawnClass=class'PartnerPawn_Pisstrap')
	MutantSkins[0]=Texture'PLAnimalSkins.PLDog.MutantDog_base02'
	MutantSkins[1]=Texture'PLAnimalSkins.PLDog.MutantDog_base03'
	MutantSkins[2]=Texture'PLAnimalSkins.PLDog.MutantDog_base_01'
	DogSkins[0]=Shader'AW_Characters.Animals.Dog_Gimp_Shader'
	DogSkins[1]=Texture'AnimalSkins.Dog2'
	DogSkins[2]=Texture'AnimalSkins.Dog3'
	DogSkins[3]=Texture'AnimalSkins.Dog4'
	DogSkins[4]=Texture'AW_Characters.Animals.UberChamp'
}
