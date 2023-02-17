///////////////////////////////////////////////////////////////////////////////
// PLGameState
// Copyright 2014, Running With Scissors, Inc.
//
// Game state for Paradise Lost. Contains PL-specific stuff.
///////////////////////////////////////////////////////////////////////////////
class PLGameState extends PLBaseGameState;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////

const DAY_APOCALYPSE = 6;

// Wise Wang/Kennel hack
// If true, we need to activate the hack on level change.
var travel bool bKennelHack, bWiseWangHack;
var travel int SavedPriceBoard;			// Amount currently on the price board

// This is actually kind of a roundabout way to do this but whatever
const SNOWMAN_1 = 'WhizzedOn_BackyardSnowman';
const SNOWMAN_2 = 'WhizzedOn_BookRepoSnowman';
const SNOWMAN_3 = 'WhizzedOn_HumanSnowtipede';
const SNOWMAN_4 = 'WhizzedOn_GhettoSnowman';
const SNOWMAN_5 = 'WhizzedOn_PoliceGarageSnowman';
const SNOWMAN_6 = 'WhizzedOn_HouseSnowman';
const AC_ENDING = 'ApocalypseConquerorEnding';

// Speed Run times.
const SPEEDRUN_ACHIEVEMENT = 6300.00;	// 1:45:00 for Aderall achievement
const SPEED_RUN = 6300.00;				// 1:45:00 to get the speedrunner ranking.
const SUPER_SPEED_RUN = 5400.00;		// 1:30:00 to get the super speedrunner ranking.
const ULTRA_SPEED_RUN = 4500.00;		// 1:15:00 minutes to get the ultra speedrunner ranking.
const MEGA_SPEED_RUN = 3600.00;			// If they do it in under an hour, suggest they submit a run to SDA

// DEPRECATED
/*
var travel bool bCash4CatsSpawned;		// Set to true once we've spawned the Cash 4 Cats vendor pawn, so he'll remain spawned on a revisit.
var travel int WipeHousePriceHikes;		// Increases by 1 for each time we've hiked the prices at the Wipe House.
var travel bool bYeelandCrate1;			// For each Yeeland Crate, true if the crate was filled with the desired weapon
var travel bool bYeelandCrate2;
var travel bool bYeelandCrate3;
var travel bool bYeelandCrate4;
var travel bool bYeelandCrate5;
var travel bool bYeelandGame1;			// For each Yeeland Game, true if the game was forcibly installed
var travel bool bYeelandGame2;
var travel bool bYeelandGame3;
var travel bool bYeelandGame4;
*/

// Stored Cheats
var travel bool bFunzerking;

///////////////////////////////////////////////////////////////////////////////
// Stats
///////////////////////////////////////////////////////////////////////////////
var travel int CockAsianKills;			// Number of Cock Asian Butchers killed
var travel int PUKills;					// Number of PU Games Employees killed
var travel int FarciiKills;				// Number of Farcii killed
var travel int RobotKills;				// Number of pisstraps killed
var travel int BanditKills;				// Number of Bandits killed
var travel int SurvivalistKills;		// Number of Survivalists killed
var travel int AnimalKills;				// Number of animals killed (cats, dogs, elephants, mutants... everything but the raptor)
//var travel int RaptorKills;				// Number of raptors killed (joke stat)
var travel int MoneySpentOnVendors;		// Amount of money spent on vending machines only
var travel int SnowmenPeedOn;			// Number of snowmen peed on
var travel int NutShots;				// Number of people kicked in the balls
//var travel int BirdsFlipped;
var travel int ErrandsPeaceful;			// Number of errands completed peacefully
var travel bool bSpecialEnding;			// True if we activate the Apocalypse Conqueror ending

var localized string ApocalypseConquerorRanking;	// If you killed all the faction leaders instead of leaving town
var localized string NutShotRanking;				// If you kicked lots and lots of men in the balls
var localized string CapitalistRanking;				// If you spent way more on the vending machines than you killed people
var localized string ButcherRanking;				// If the vast majority of the people you killed were Cock Asian
var localized string GameDevRanking;				// If the vast majority of the people you killed were game devs
var localized string RedheadRanking;				// If the vast majority of the people you killed were redheads
var localized string RobotRanking;					// If you killed more Pisstraps than people
var localized string BanditRanking;					// If the vast majority of the people you killed were bandits
var localized string SurvivalistRanking;			// If the vast majority of the people you killed were Survivalists
var localized string RevolverRanking;				// If you made lots of revolver execution kills

// AWGameState
/*
//var travel int ZombiesKilledOverall;	// Total zombies killed in game
//var travel int ZombiesResurrected;		// total number of zombies brought back to 'life'
var travel int BryanSurvived;			// If RWS Bryan doesn't get killed in the Vince House level
										// defaults to 1.0, which says he's alive. When he dies
										// he tells the player about it so he can count it up.
//var travel int KillCowsTime;			// Time it took player to kill all the cows
//var travel int KillPigeonsTime;		// Time it took player to kill all the pigeons
var travel int KillElephantsScythe;	// If all the elephants were killed with the scythe
										// When an elephant is killed by anything other than the scythe
										// this is set to 0.0
//var travel int LimbsHacked;			// Any limb (no heads) cut off
//var travel int HeadsLopped;			// Any heads cut off (not exploded)
var travel int LostSledgeInCow;		// Number of sledges lost in the butts of cows
*/

// GameState
/*
var travel private bool bCheated;		// if player used any cheat codes
var travel private bool bMultiSegment;	// Speed runs only: set to true if PostLoadGame is ever called
var travel int PeopleKilled;		// total people player killed in game
var travel int ZombiesKilledOverall;
var travel int HeadsLopped;
var travel int LimbsHacked;
var travel int ZombiesResurrected;
var travel int CopsKilled;			// total cops player killed in game
var travel int ElephantsKilled;		// total elephants player killed in game
var travel int DogsKilled;			// total dogs player killed in game
var travel int CatsKilled;			// total cats player killed in game (includes ones used on guns)
var travel int PistolHeadShot;		// people that you snuck up behind to get a silent pistol head shot on
var travel int ShotgunHeadShot;		// people you shotgunned in the face, blowing up their heads
var travel int RifleHeadShot;		// people you got a one-shot rifle kill on
var travel int CatsUsed;			// cats you violated with your gun
var travel int MoneySpent;			// money the player spent
var travel int PeeTotal;			// 'gallons' of piss you peed. (divide by 10-ish)
var travel int DoorsKicked;			// number of times you kicked a door in a game
var travel int TimesArrested;		// number of times you've been arrested
var travel int DressedAsCop;		// number of times you impersonated a cop (dressed like him)
var travel int DogsTrained;			// number of dogs (non-unique) you trained
var travel int PeopleRoasted;		// number of people killed by fire
var travel int CopsLuredByDonuts;	// Number of cops you've lured by dropping donuts
var travel int BaseballHeads;
var travel int FanaticsKilled;
var travel int ArmyKilled;
var travel int ChainsawKills;
var travel bool bNightMode;			// If true, game is in "night mode", nighttime maps will be loaded if present (ngt-XXXXX.fuk)
*/

///////////////////////////////////////////////////////////////////////////////
// Get the player's speedrunning ranking
///////////////////////////////////////////////////////////////////////////////
function string GetPlayerRankingSpeedRun()
{
	if (!DidPlayerCheat())
	{
		// If you're a speedrunning god
		if (TimeElapsed <= MEGA_SPEED_RUN)
			return MegaSpeedRanking;
			
		// If you beat the game extremely quickly
		if(TimeElapsed <= ULTRA_SPEED_RUN)
			return UltraSpeedRanking;

		// If you beat the game very quickly
		if(TimeElapsed <= SUPER_SPEED_RUN)
			return SuperSpeedRanking;

		// If you beat the game quickly
		if(TimeElapsed <= SPEED_RUN)
			return SpeedRanking;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Updated for PL stats.
///////////////////////////////////////////////////////////////////////////////
function PawnKilledByDude(FPSPawn Victim, class<DamageType> DamageType)
{
	local int i;
	local bool bValid;
	
	// Go through list of acceptable damage types and consider it valid if
	// this is a thing that the Dude could have intentionally killed the
	// target with. (Gun, foot, fists, etc.)
	
	bValid = true;
	for (i=0; i < InvalidDudeKills.Length; i++)
		if (DamageType == InvalidDudeKills[i])
			bValid = false;

	// If it's a valid kill, increase our stats depending on the type of kill.
	if (bValid)
	{
		if (Victim.IsA('CockButchers'))
			CockAsianKills++;
			
		if (Victim.IsA('PUGamesBoss') || Victim.IsA('PUGamesEmployee'))
			PUKills++;
			
		if (Victim.IsA('Farcii') || Victim.IsA('ZackWard'))
			FarciiKills++;
			
		if (Victim.IsA('VendACurePawn'))
			RobotKills++;
			
		if (Victim.IsA('Bandits') || Victim.IsA('BanditLeader'))
			BanditKills++;
			
		if (Victim.IsA('Survivalist') || Victim.IsA('SurvivalistMinigunner'))
			SurvivalistKills++;
			
		if (Victim.IsA('CatPawn') || Victim.IsA('DogPawn') || Victim.IsA('CowPawn') || Victim.IsA('ElephantPawn') || Victim.IsA('LabMonkey') || Victim.IsA('RaptorKill'))
			AnimalKills++;
			
		//if (Victim.IsA('RaptorPawn'))
			//RaptorKills++;
			
		// Mike J is a bit of a special case. He's a kosher mad cow zombie, which makes him half man, half cow, half zombie, and half Jew.
		// So I guess that counts as several kills.
		if (Victim.IsA('PLMikeJ') || Victim.IsA('PLCowBossPawn'))
		{
			PeopleKilled++;
			ZombiesKilledOverall++;
			AnimalKills++;
		}
	}

	// Call super so they can check as well.
	Super.PawnKilledByDude(Victim, DamageType);
}

///////////////////////////////////////////////////////////////////////////////
// SetDynamicVariable
// A scripted action or something wants to set a variable.
///////////////////////////////////////////////////////////////////////////////
function SetDynamicVariable(Name VarName, EVarType VarType, EOperatorSet Operator, float Number, string Text, bool bCurrentDayOnly)
{
	// This is kind of a silly way to do the snowman count but whatever
	if (VarType == EVT_Number && Number == 1)
	{
		if (VarName == SNOWMAN_1 || VarName == SNOWMAN_2 || VarName == SNOWMAN_3 || VarName == SNOWMAN_4 || VarName == SNOWMAN_5 || VarName == SNOWMAN_6)
			SnowmenPeedOn++;
		if (VarName == AC_ENDING)
			bSpecialEnding = true;
	}

	Super.SetDynamicVariable(VarName, VarType, Operator, Number, Text, bCurrentDayOnly);
}

///////////////////////////////////////////////////////////////////////////////
// Get the name of the way the player has been playing based on the game stats.
///////////////////////////////////////////////////////////////////////////////
function string GetPlayerRanking()
{
	local P2Player ThePlayer;
	
	//log ("get ranking"@DidPlayerCheat()@bExpertMode@bInsaneoMode@bTheyHateMeMode@bHestonMode);
	
	// If you killed all the faction leaders instead of escaping, you're an Apocalypse Conqueror
	if (bSpecialEnding)
	{
		// EXCEPTION: If you did it on Impossible you still get the Impossible ranking.
		if (!DidPlayerCheat() && bExpertMode && bInsaneoMode)
			return ImpossibleRanking;
		else
			return ApocalypseConquerorRanking;
	}

	// If you cheated, short-circuit these rankings and go to the regular results
	if (!DidPlayerCheat())
	{
		// If you beat the game in Impossible mode, it says it wasn't even possible
		if (bExpertMode && bInsaneoMode)
			return ImpossibleRanking;
			
		// If you beat the game in Expert mode it says you're God
		if (bExpertMode)
			return ExpertRanking;

		// If you beat the game in They Hate Me mode it says you've got balls of steel
		if (bTheyHateMeMode)
			return HateMeRanking;
			
		// If you beat the game in Insaneo, it says you're crazy
		if (bInsaneoMode)
			return InsaneoRanking;
			
		// If you beeat the game in Heston mode, it says you're an NRA member
		if (bHestonMode)
			return HestonRanking;
	}
	
	// If you didn't kill a single living thing in the game, you're Jesus
	if(PeopleKilled + CatsKilled + ElephantsKilled + DogsKilled + ZombiesKilledOverall == 0)
		return Killed0Ranking;	
	
	// If the number of chainsaw kills was over half the people you killed in the game
	// (Put this before the limb-hacking rating, since it's very, very easy to get the
	// limb-hacking rating while chainsawing people.
	if (ChainsawKills > PeopleKilled*0.5)
		return ChainsawRanking;
		
	// If you cut off lots and lots of limbs
	if(LimbsHacked > LimbCutMin
		&& LimbsHacked > (ZombiesKilledOverall + PeopleKilled)*LimbCutRatio)
		return GhoulRanking;

	// If 3/4 the people you kill were cops, make you a cop killer		
	if(CopsKilled > PeopleKilled*0.75)
		return CopKillerRanking;

	// If you killed more animals than people
	if(AnimalKills > PeopleKilled)
		return AnimalKillerRanking;

	// If you killed more zombies than people
	if (ZombiesKilledOverall > PeopleKilled)
		return ZombieRanking;
		
	// Rankings for faction kills (at least 50% of the people-kills you make have to be from that faction)
	if (CockAsianKills > PeopleKilled * 0.5)
		return ButcherRanking;
	if (PUKills > PeopleKilled * 0.5)
		return GameDevRanking;
	if (FarciiKills > PeopleKilled * 0.5)
		return RedheadRanking;
	if (RobotKills > PeopleKilled * 0.5)
		return RobotRanking;
	if (BanditKills > PeopleKilled * 0.5)
		return BanditRanking;
	if (SurvivalistKills > PeopleKilled * 0.5)
		return SurvivalistRanking;

	// Not used in PL.
	/*
	// If the number of baseball head shots over half the people you killed in the game
	else if(BaseballHeads > PeopleKilled*0.5)
		return BaseballRanking;
	*/
	
	// If you spent lots and lots of money on the vending machines
	if (MoneySpentOnVendors > 15 * (ZombiesKilledOverall + PeopleKilled))
		return CapitalistRanking;
		
	// If you preferred to kick people in the nuts instead of just killing them
	if (NutShots > 50 && NutShots > PeopleKilled * 0.5)
		return NutShotRanking;
		
	// If your primary killing tool was the Big Iron on your hip
	if (ExecutionKills > PeopleKilled * 0.4)
		return RevolverRanking;

	// If the number of shotgun head shots over half the people/zombies you killed in the game
	if(ShotgunHeadShot > (ZombiesKilledOverall + PeopleKilled)*0.5)
		return ShotgunRanking;

	// If the number of rifle head shots over half the people you killed in the game
	if(RifleHeadShot > PeopleKilled*0.5)
		return RifleKillerRanking;

	// If the number of people killed by fire is over half the people you killed in the game
	if(PeopleRoasted > PeopleKilled*0.5)
		return FireKillerRanking;
		
	// If you peed on all the snowmen
	if (SnowmenPeedOn >= 6)
		return PeeRanking;
		
	// Not used in PL?	
	/*
	// If you pissed more in 'gallons' that killed people in numbers
	if(float(PeeTotal)*0.1 > PeopleKilled
		// Make sure you killed a few people too though, so you can get the Jesus ranking easier.
		&& PeopleKilled >= KILLED_2)
		return PeeRanking;
	*/
	
	// If you stick guns up waaay too many cats butts (most of the cats in the game)
	if(CatsUsed > CAT_USED_TOTAL)
		return CatSexRanking;

	// rankings for number of people killed
	if(PeopleKilled <= KILLED_1)
		return Killed1Ranking;
	if(PeopleKilled <= KILLED_2)
		return Killed2Ranking;
	if(PeopleKilled <= KILLED_3)
		return Killed3Ranking;
	if(PeopleKilled <= KILLED_4)
		return Killed4Ranking;
	if(PeopleKilled <= KILLED_5)
		return Killed5Ranking;
	if(PeopleKilled <= KILLED_6)
		return Killed6Ranking;
	if(PeopleKilled <= KILLED_7)
		return Killed7Ranking;
	if(PeopleKilled <= KILLED_8)
		return Killed8Ranking;
	if(PeopleKilled <= KILLED_9)
		return Killed9Ranking;
	if(PeopleKilled <= KILLED_10)
		return Killed10Ranking;
	
	return Killed11Ranking;
}

///////////////////////////////////////////////////////////////////////////////
// Starting a new day should forget several of the persistent lists
// and forget things like crack addiction, catnip time, etc.
///////////////////////////////////////////////////////////////////////////////
function RemovePersistanceForNewDay(P2Pawn PlayerPawn)
{
	Super.RemovePersistanceForNewDay(PlayerPawn);
	if (CurrentDay == DAY_APOCALYPSE)
		CurrentHaters.Length = 0;
}

defaultproperties
{
	Killed0Ranking		= "Thank you for playing, GANDHI."
	Killed1Ranking		= "Joe Fission"
	Killed2Ranking		= "Vault Dweller Pushed Over The Edge"
	Killed3Ranking		= "Wanna-be Bandit"
	Killed4Ranking		= "Tunnel Snake"
	Killed5Ranking		= "Trinity Man"
	Killed6Ranking		= "Mad as Max"
	Killed7Ranking		= "Serial Killer on Buffout"
	Killed8Ranking		= "Mister Burke's Hire"
	Killed9Ranking		= "Oppenheimer Groupie"
	Killed10Ranking		= "Fat Man would be proud."
	Killed11Ranking		= "Congratulations, Little Boy!"
	CopKillerRanking		= "Billy the Kid"
	AnimalKillerRanking	= "Mutant-Hating Animal Murderer"
	RifleKillerRanking	= "Arizona Killer"
	FireKillerRanking		= "Pyromaniac"
	PeeRanking			=	"Wasteland Water Salesman"
	CatSexRanking		=	"Cat Rapist"
	HestonRanking		=	"Gun Nut"
	InsaneoRanking	=	"Chaos-Braving POSTAL Freak"
	HateMeRanking		=	"Survivor of Bad Circumstance"
	ExpertRanking		=	"POSTAL God"
	ImpossibleRanking	=	"Holy shit! We didn't even think this was possible!"
	SpeedRanking		=	"(Speed Runner)"
	SuperSpeedRanking	=	"(Super Speed Runner)"
	UltraSpeedRanking	=	"(Ultimate Speed Runner)"
	MegaSpeedRanking	=	"(Want to REALLY speedrun this game? speedrun.com/postal2)"
	SingleSegmentSpeedRanking	=	"(Single-segment)"
	GhoulRanking		=	"Limb-Hacking POSTAL Ghoul"
	ShotgunRanking	=	"Head-Asploding Shotgun Ninja"
	BaseballRanking	=	"THIS RANKING SHOULD NOT APPEAR"
	ZombieRanking		=	"Wasteland Purifier"
	ChainsawRanking	=	"Meat-Grinding Badass Psycho"
	ApocalypseConquerorRanking	=	"Apocalypse Conqueror"
	NutShotRanking = "Women's Self-Defense Expert"
	CapitalistRanking = "Junktown Jerky Vendor"
	ButcherRanking = "Butcher Butcherer"
	GameDevRanking = "Social Justice Warrior"
	RedheadRanking = "Destroyer of Daywalkers"
	RobotRanking = "Crusher of the Robolution"
	BanditRanking = "Paladin of Steel"
	SurvivalistRanking = "Survivalist Slaughterer"
	RevolverRanking = "Ranger #21"
}
