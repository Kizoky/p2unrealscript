///////////////////////////////////////////////////////////////////////////////
// Apocalypse Weekend game state
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Game state for expansion pack
//
///////////////////////////////////////////////////////////////////////////////
class AWGameState extends GameState;

// Stats for AW
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

// Tags for unique events in game--correspond to in game AWTrigger tags for these jobs
//var name CowKillTag;
//var name ElephantsKillTag;

// Stat nums
var int Killed0;
var int Killed1;
var int Killed2;
var int Killed3;
var int Killed4;
var int Killed5;
var int Killed6;
var int Killed7;
var int Killed8;
var int Killed9;
var int Killed10;
var int SledgesLostMax;
var int LimbCutRatio;
var int LimbCutMin;
// New stat rankings
var localized string CowSledgeRanking;

///////////////////////////////////////////////////////////////////////////////
// Record a pickup for this level, so it won't be remade when you come back
// to this level
///////////////////////////////////////////////////////////////////////////////
function RecordPickup(name Pname)
{
	// Don't record pickups anymore. It's useless baggage the dude carries
	// from level to level, and no levels are ever reused in the AW game.
	if (!P2GameInfoSingle(Level.Game).IsWeekend())
		Super.RecordPickup(Pname);
}

///////////////////////////////////////////////////////////////////////////////
// Record times during kill counter sequence. Find particular sequence
// for each time by the trigger tag.
///////////////////////////////////////////////////////////////////////////////
function FinishKillCount(int KillTime, name KillTag)
{
	/*
	//log(self$" finish kill count, time "$KillTime$" tag "$KillTag$" cow tag "$CowKillTag);
	if(KillTag == CowKillTag)
		KillCowsTime = KillTime;
	else if(KillTag == ElephantsKillTag)
		KillElephantsTime = KillTime;
	//log(self$" cow time "$KillCowsTime$" ele "$KillElephantsTime);
*/
}

///////////////////////////////////////////////////////////////////////////////
// Get the name of the way the player has been playing based on the game stats.
///////////////////////////////////////////////////////////////////////////////
function string GetPlayerRanking()
{
	// ONLY CALL THIS IN APOCALYPSE WEEKEND ONLY GAME!!
	if (AWGameSP(Level.Game) == None)
		return Super.GetPlayerRanking();
	
	// If the number of chainsaw kills was over half the people you killed in the game
	// (Put this before the limb-hacking rating, since it's very, very easy to get the
	// limb-hacking rating while chainsawing people.
	if (ChainsawKills > PeopleKilled*0.5)
		return ChainsawRanking;
		
	// If you cut off lots and lots of limbs
	else if(LimbsHacked > LimbCutMin
		&& LimbsHacked > (ZombiesKilledOverall + PeopleKilled)*LimbCutRatio)
	{
		return GhoulRanking;
	}
	// If you killed more zombies than people
	else if (ZombiesKilledOverall > PeopleKilled)
		return ZombieRanking;
		
	// If the number of baseball head shots over half the people you killed in the game
	else if(BaseballHeads > PeopleKilled*0.5)
		return BaseballRanking;

	// If the number of shotgun head shots over half the people/zombies you killed in the game
	else if(ShotgunHeadShot > (ZombiesKilledOverall + PeopleKilled)*0.5)
		return ShotgunRanking;
	// If the number of rifle head shots over half the people you killed in the game
	if(RifleHeadShot > PeopleKilled*0.5)
	{
		return RifleKillerRanking;
	}
	// If the number of people killed by fire is over half the people you killed in the game
	else if(PeopleRoasted > PeopleKilled*0.5)
	{
		return FireKillerRanking;
	}
	// If you lose your sledge in a few too many cows, you may need to seek therapy
	else if(LostSledgeInCow > SledgesLostMax)
	{
		return CowSledgeRanking;
	}
	// If you pissed more in 'gallons' that killed people in numbers
	else if(float(PeeTotal)*0.1 > PeopleKilled
		// Make sure you killed a few people too though, so you can get the Jesus ranking easier.
		&& PeopleKilled >= Killed3)
	{
		return PeeRanking;
	}
	// rankings for number of people killed
	else
	{
		// Jesus ranking not really achievable, but in here anyway
		if(PeopleKilled + CatsKilled + ElephantsKilled + DogsKilled + ZombiesKilledOverall == 0)
			return Killed0Ranking;
		else if(PeopleKilled <= Killed1)
			return Killed1Ranking;
		else if(PeopleKilled <= Killed2)
			return Killed2Ranking;
		else if(PeopleKilled <= Killed3)
			return Killed3Ranking;
		else if(PeopleKilled <= Killed4)
			return Killed4Ranking;
		else if(PeopleKilled <= Killed5)
			return Killed5Ranking;
		else if(PeopleKilled <= Killed6)
			return Killed6Ranking;
		else if(PeopleKilled <= Killed7)
			return Killed7Ranking;
		else if(PeopleKilled <= Killed8)
			return Killed8Ranking;
		else if(PeopleKilled <= Killed9)
			return Killed9Ranking;
		else if(PeopleKilled <= Killed10)
			return Killed10Ranking;
		else
			return Killed11Ranking;
	}
	return "ERROR! No ranking specified. Contact a Dev.";
}

defaultproperties
{
	BryanSurvived=1
	KillElephantsScythe=1
	Killed1=5
	Killed2=25
	Killed3=50
	Killed4=80
	Killed5=120
	Killed6=180
	Killed7=200
	Killed8=300
	Killed9=400
	Killed10=500
	SledgesLostMax=2
	LimbCutRatio=2
	LimbCutMin=100
	CowSledgeRanking="Bovine Prostate Inspector"
}
