///////////////////////////////////////////////////////////////////////////////
// PLAchievementManager
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Enables PL achievements.
///////////////////////////////////////////////////////////////////////////////
class PLAchievementManager extends P2AchievementManager;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
const PLAchievementBase = 69;

// Block P2-only achievements
function bool EvaluateAchievement(PlayerController Achiever, name AchievementName, optional bool bDisplayInConsole)
{
	if (AchievementName == 'PetitionKill')
		return false;
		
	return Super.EvaluateAchievement(Achiever, AchievementName, bDisplayInConsole);
}

// TODO
/*
///////////////////////////////////////////////////////////////////////////////
// We only want PL achievements to display in the menu if the player isn't
// connected to Steam.
///////////////////////////////////////////////////////////////////////////////
function string GetAchievementName(int i)
{
	while (i < Achievements.Length)
	{
		if (Achievements[i].bIgnore)
			//i++;
			return "";
		else
			return Achievements[i].DisplayName;
	}
	return "";
}
function string GetAchievementDescription(int i)
{
	while (i < Achievements.Length)
	{
		if (Achievements[i].bIgnore)
			i++;
		else if (Achievements[i].bHidden && !Achievements[i].bUnlocked)
			return HiddenAchievementString;
		else
			return Achievements[i].Description;
	}
	return "";
}
function string GetAchievementProgress(int i)
{
	while (i < Achievements.Length)
	{
		//log("get achievement"@i@"progress unlocked"@Achievements[i].bUnlocked@"ignore"@Achievements[i].bIgnore@"progstat"@Achievements[i].ProgressStat,'Debug');
		if (Achievements[i].bIgnore)
			i++;
		else if (Achievements[i].bUnlocked)
			return "";
		else if (Stats[Achievements[i].ProgressStat].APIName == '')
			return "(LOCKED)";
		else if (Stats[Achievements[i].ProgressStat].StatType == STATTYPE_Int)
			return "("$Stats[Achievements[i].ProgressStat].StatValue_int$"/"$Achievements[i].UnlockValue_int$")";
		else if (Stats[Achievements[i].ProgressStat].StatType == STATTYPE_Float)
			return "("$Stats[Achievements[i].ProgressStat].StatValue_float$"/"$Achievements[i].UnlockValue_float$")";
		else
			return "(???)";
			
	}
	return "";
}
function bool GetAchievement(name AchievementName)
{
	local int i;
	for (i=0; i < Achievements.Length; i++)
	{
		if (Achievements[i].APIName == AchievementName)
			return Achievements[i].bUnlocked;
	}
	return false;
}
function int NumAchievements()
{
	return Achievements.Length;
}
function Texture GetAchievementIcon(int i)
{
	while (i < Achievements.Length)
	{
		if (Achievements[i].bIgnore)
			i++;
		else if (Achievements[i].bUnlocked)
			return Achievements[i].UnlockedTex;
		else
			return Achievements[i].LockedTex;
	}
	return None;
}
*/

// All Stats and Achievements go here.
defaultproperties
{
	// ========================================================================
	// STATS
	// ========================================================================
	
	// Cats Sold at Cash 4 Cats
	Stats(22)=(APIName="PLCatsSold",bIncrementOnly=True,StatType=STATTYPE_INT,DefaultValue_int=0,DisplayName="Cats Sold",RelatedAchievementName="PLCash4Cats")
	
	// Money Spent at Vending Machines
	Stats(23)=(APIName="PLVendingSpent",bIncrementOnly=True,StatType=STATTYPE_INT,DefaultValue_int=0,DisplayName="Money Spent on Vending Machines",RelatedAchievementName="PLVendingMachines")
	
	// Nutshots
	Stats(24)=(APIName="PLNutshots",bIncrementOnly=True,StatType=STATTYPE_INT,DefaultValue_int=0,DisplayName="Nutshots Scored",RelatedAchievementName="PLNutshotAchievement")
	
	// Dual Wield Kills
	Stats(25)=(APIName="PLDualWieldKills",bIncrementOnly=True,StatType=STATTYPE_INT,DefaultValue_int=0,DisplayName="Dual Wield Kills",RelatedAchievementName="PLDualWieldAchievement")
	
	// ========================================================================
	// ACHIEVEMENTS
	// ========================================================================
	Achievements(0)=(bIgnore=true,APIName=,DisplayName=,Description=,bHidden=True,LockedTex=None,UnlockedTex=None)
	Achievements(1)=(APIName="PLMondayComplete",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.69-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.69-Locked')
	Achievements(2)=(APIName="PLTuesdayComplete",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.70-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.70-Locked')
	Achievements(3)=(APIName="PLWednesdayComplete",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.71-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.71-Locked')
	Achievements(4)=(APIName="PLThursdayComplete",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.72-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.72-Locked')
	Achievements(5)=(APIName="PLFridayComplete",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.73-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.73-Locked')
	Achievements(6)=(APIName="PLJesusRun",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.74-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.74-Locked')
	Achievements(7)=(APIName="PLPOSTALRun",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.75-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.75-Locked')
	Achievements(8)=(APIName="PLSpeedRun",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.76-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.76-Locked')
	Achievements(9)=(APIName="PLMonkeysSurvived",DisplayName=,Description=,bHidden=true,UnlockedTex=Texture'PLAchievementIcons.Unlocked.77-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.77-Locked')
	Achievements(10)=(APIName="PLKrotchySkip",DisplayName=,Description=,bHidden=True,UnlockedTex=Texture'PLAchievementIcons.Unlocked.78-Unlocked',bHidden=true,LockedTex=Texture'PLAchievementIcons.Locked.78-Locked')
	Achievements(11)=(APIName="PLBuyTP",DisplayName=,Description=,bHidden=True,UnlockedTex=Texture'PLAchievementIcons.Unlocked.79-Unlocked',bHidden=true,LockedTex=Texture'PLAchievementIcons.Locked.79-Locked')
	Achievements(12)=(APIName="PLCollectMoney",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.80-Unlocked',bHidden=true,LockedTex=Texture'PLAchievementIcons.Locked.80-Locked')
	Achievements(13)=(APIName="PLKillZack",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.81-Unlocked',bHidden=true,LockedTex=Texture'PLAchievementIcons.Locked.81-Locked')
	Achievements(14)=(APIName="PLPisstraps",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.82-Unlocked',bHidden=true,LockedTex=Texture'PLAchievementIcons.Locked.82-Locked',ProgressStat=0)
	Achievements(15)=(APIName="PLBitchCake",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.83-Unlocked',bHidden=true,LockedTex=Texture'PLAchievementIcons.Locked.83-Locked',ProgressStat=0)
	Achievements(16)=(APIName="PLCash4Cats",DisplayName=,Description=,ProgressStat=22,UnlockValue_int=30,bGrindy=false,UnlockedTex=Texture'PLAchievementIcons.Unlocked.84-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.84-Locked')
	Achievements(17)=(APIName="PLVendingMachines",DisplayName=,Description=,ProgressStat=23,UnlockValue_int=2000,bGrindy=false,UnlockedTex=Texture'PLAchievementIcons.Unlocked.85-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.85-Locked')
	Achievements(18)=(APIName="PLDualWieldAchievement",DisplayName=,Description=,ProgressStat=25,UnlockValue_int=30,bGrindy=false,UnlockedTex=Texture'PLAchievementIcons.Unlocked.86-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.86-Locked')
	Achievements(19)=(APIName="PLSnowmanAchievement",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.87-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.87-Locked')
	Achievements(20)=(APIName="PLNutshotAchievement",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.88-Unlocked',ProgressStat=24,UnlockValue_int=10,bGrindy=false,LockedTex=Texture'PLAchievementIcons.Locked.88-Locked')
	Achievements(21)=(APIName="PissInFace",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.01-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.01-Unlocked-512',ProgressStat=0)
	Achievements(22)=(APIName="Fishy",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.02-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.02-Unlocked-512')
	Achievements(23)=(APIName="DogHelper",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.03-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.03-Unlocked-512',ProgressStat=0)
	Achievements(24)=(APIName="HerePiggyPiggy",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.04-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.04-Unlocked-512',ProgressStat=0)
	Achievements(25)=(APIName="CatSilencer",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.05-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.05-Unlocked-512',ProgressStat=0)
	Achievements(26)=(APIName="Resurrection",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.06-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.06-Unlocked-512');
	Achievements(27)=(APIName="DogKillsAchievement",DisplayName=,Description=,ProgressStat=21,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.15-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.15-Unlocked-512')
	Achievements(28)=(APIName="FireKillsAchievement",DisplayName=,Description=,ProgressStat=1,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.16-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.16-Unlocked-512')
	Achievements(29)=(APIName="CarsDestroyedAchievement",DisplayName=,Description=,ProgressStat=2,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.17-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.17-Unlocked-512')
	Achievements(30)=(APIName="DogsKickedAchievement",DisplayName=,Description=,ProgressStat=3,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.18-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.18-Unlocked-512')
	Achievements(31)=(APIName="PeopleScythedAchievement",DisplayName=,Description=,ProgressStat=4,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.19-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.19-Unlocked-512')
	Achievements(32)=(APIName="CatHoarder",DisplayName=,Description=,UnlockValue_int=15,LockedTex=Texture'AchievementIcons.Locked-512.20-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.20-Unlocked-512')
	Achievements(33)=(APIName="DogsKilledWithCatgunAchievement",DisplayName=,Description=,ProgressStat=5,UnlockValue_int=10,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.21-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.21-Unlocked-512')
	Achievements(34)=(APIName="BystandersKilledWhileGimpedAchievement",DisplayName=,Description=,ProgressStat=6,UnlockValue_int=10,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.22-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.22-Unlocked-512')
	Achievements(35)=(APIName="Jailbird",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.23-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.23-Unlocked-512')
	Achievements(36)=(APIName="IveSeenBiggerAchievement",DisplayName=,Description=,ProgressStat=8,UnlockValue_int=3,LockedTex=Texture'AchievementIcons.Locked-512.24-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.24-Unlocked-512')
	Achievements(37)=(APIName="RunningWithScissorsAchievement",DisplayName=,Description=,ProgressStat=9,UnlockValue_float=30.000000,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.25-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.25-Unlocked-512')
	Achievements(38)=(APIName="PeopleKilledAchievement",DisplayName=,Description=,ProgressStat=10,UnlockValue_int=1000,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.26-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.26-Unlocked-512')
	Achievements(39)=(APIName="EqualOpportunityKiller",DisplayName=,Description=,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.29-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.29-Unlocked-512')
	Achievements(40)=(APIName="SledgeFaceshotsAchievement",DisplayName=,Description=,ProgressStat=14,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.30-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.30-Unlocked-512')
	Achievements(41)=(APIName="FearAndLoathing",DisplayName=,Description=,UnlockValue_int=10,LockedTex=Texture'AchievementIcons.Locked-512.31-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.31-Unlocked-512')
	Achievements(42)=(APIName="GoodMorningVietnam",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.33-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.33-Unlocked-512')
	Achievements(43)=(APIName="ZombiesBeheadedAchievement",DisplayName=,Description=,ProgressStat=19,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.34-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.34-Unlocked-512')
	Achievements(44)=(APIName="HeadFetch",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.42-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.42-Unlocked-512')
	Achievements(45)=(APIName="KickSeveredHead",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.44-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.44-Unlocked-512')
	Achievements(46)=(APIName="AngerManagement",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.45-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.45-Unlocked-512',ProgressStat=0)
	Achievements(47)=(APIName="BovineProstateInspector",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.46-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.46-Unlocked-512')
	Achievements(48)=(APIName="DontTazeMeAchievement",DisplayName=,Description=,ProgressStat=18,UnlockValue_int=20,LockedTex=Texture'AchievementIcons.Locked-512.47-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.47-Unlocked-512',bGrindy=False)
	Achievements(49)=(APIName="SuicideBomber",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.48-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.48-Unlocked-512')
	Achievements(50)=(APIName="Newspaper",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.50-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.50-Unlocked-512')
	Achievements(51)=(APIName="WantedLevel",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.51-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.51-Unlocked-512')
	Achievements(52)=(APIName="CopBribery",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.53-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.53-Unlocked-512')
	Achievements(53)=(APIName="DoorKick",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.54-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.54-Unlocked-512')
	Achievements(54)=(APIName="FireExtinguisher",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.55-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.55-Unlocked-512')
	Achievements(55)=(APIName="ChokedOnPiss",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.56-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.56-Unlocked-512',bNoComment=True)
	Achievements(56)=(APIName="ArodWho",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.60-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.60-Unlocked-512')
	Achievements(57)=(APIName="Stumped",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.61-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.61-Unlocked-512')
	Achievements(58)=(APIName="BootToTheHead",DisplayName=,Description=,LockedTex=Texture'AchievementIcons.Locked-512.62-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.62-Unlocked-512')
	Achievements(59)=(APIName="MonsterKill",DisplayName=,Description=,bHidden=True,LockedTex=Texture'AchievementIcons.Locked-512.67-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.67-Unlocked-512')
	Achievements(60)=(bIgnore=true,APIName="",DisplayName="",Description="",bHidden=True,LockedTex=None,UnlockedTex=None)
	Achievements(61)=(bIgnore=true,APIName="",DisplayName="",Description="",bHidden=True,LockedTex=None,UnlockedTex=None)
	Achievements(62)=(bIgnore=true,APIName="",DisplayName="",Description="",bHidden=True,LockedTex=None,UnlockedTex=None)
	Achievements(63)=(bIgnore=true,APIName="",DisplayName="",Description="",bHidden=True,LockedTex=None,UnlockedTex=None)
	Achievements(64)=(bIgnore=true,APIName="",DisplayName="",Description="",bHidden=True,LockedTex=None,UnlockedTex=None)
	Achievements(65)=(bIgnore=true,APIName="",DisplayName="",Description="",bHidden=True,LockedTex=None,UnlockedTex=None)
	Achievements(66)=(bIgnore=true,APIName="",DisplayName="",Description="",bHidden=True,LockedTex=None,UnlockedTex=None)
	Achievements(67)=(bIgnore=true,APIName="",DisplayName="",Description="",bHidden=True,LockedTex=None,UnlockedTex=None)
	Achievements(68)=(bIgnore=true,APIName="",DisplayName="",Description="",bHidden=True,LockedTex=None,UnlockedTex=None)
	
	AchievementsDisplayName[0]=""
	AchievementsDisplayName[1]="GABAGOOOOOL!"
	AchievementsDisplayName[2]="Holocaust: Part Deux"
	AchievementsDisplayName[3]="Rain on your Wedding Day"
	AchievementsDisplayName[4]="Watchu' Talkin' 'Bout Muhammad"
	AchievementsDisplayName[5]="Better than POSTAL III"
	AchievementsDisplayName[6]="My Name is Jesus"
	AchievementsDisplayName[7]="Harder than r/gonewild"
	AchievementsDisplayName[8]="Adderall4All"
	AchievementsDisplayName[9]="Ape Rape"
	AchievementsDisplayName[10]="Dick Message"
	AchievementsDisplayName[11]="PooMasher"
	AchievementsDisplayName[12]="Hobo Sexual"
	AchievementsDisplayName[13]="Ginger Mint"
	AchievementsDisplayName[14]="Ode to Eddings"
	AchievementsDisplayName[15]="Bitches Love Cake"
	AchievementsDisplayName[16]="Rich on Reddit"
	AchievementsDisplayName[17]="BioShocked"
	AchievementsDisplayName[18]="Reddit's Famous Double Dong"
	AchievementsDisplayName[19]="You Snow Nothing John Blow"
	AchievementsDisplayName[20]="RAFIBOMB!!!"
	AchievementsDisplayName[21]="R. Kelly's Protege"
	AchievementsDisplayName[22]="Fuck Duck Dynasty!"
	AchievementsDisplayName[23]="Here, Wilfred"
	AchievementsDisplayName[24]="Chapelle's Show"
	AchievementsDisplayName[25]="Taxidermy with Chuck Testa"
	AchievementsDisplayName[26]="Michonne ain't got shit on me"
	AchievementsDisplayName[27]="Cesar Millan is Gay"
	AchievementsDisplayName[28]="OMG WE'RE HAVING A FIRE...sale"
	AchievementsDisplayName[29]="Rebecca Black's Nightmare"
	AchievementsDisplayName[30]="Hello, Newman"
	AchievementsDisplayName[31]="Darth Maul'd and shit!"
	AchievementsDisplayName[32]="Reddit would be proud."
	AchievementsDisplayName[33]="Pussy on a pedestal"
	AchievementsDisplayName[34]="I swear, I am NOT Marcellus Wallace"
	AchievementsDisplayName[35]="Uncle T-Bag"
	AchievementsDisplayName[36]="Do you even Enzyte, bro?"
	AchievementsDisplayName[37]="Running With Scissors"
	AchievementsDisplayName[38]="Hutton Gibson Can't Deny This!"
	AchievementsDisplayName[39]="Sheriff Arpaio would be proud."
	AchievementsDisplayName[40]="Can't Touch This"
	AchievementsDisplayName[41]="Fear and Loathing"
	AchievementsDisplayName[42]="GOOD MORNING VIETNAM!"
	AchievementsDisplayName[43]="Rick Grimes 4 Life"
	AchievementsDisplayName[44]="It's not cheating, because it's YOUR dog"
	AchievementsDisplayName[45]="Finkle is Einhorn"
	AchievementsDisplayName[46]="Anger Management with Roger Clemens"
	AchievementsDisplayName[47]="Shiva Blast"
	AchievementsDisplayName[48]="Don't Taze Me Bro"
	AchievementsDisplayName[49]="I Am Legend"
	AchievementsDisplayName[50]="I should buy a boat"
	AchievementsDisplayName[51]="Friend of Dorothy"
	AchievementsDisplayName[52]="Paid the Piper"
	AchievementsDisplayName[53]="Well, aren't YOU a badass"
	AchievementsDisplayName[54]="I don't know whether to kiss you or kill you"
	AchievementsDisplayName[55]="It's sterile and I like the taste"
	AchievementsDisplayName[56]="A-Rod Who?"
	AchievementsDisplayName[57]="Door Mat"
	AchievementsDisplayName[58]="Chuck Norris'd!"
	AchievementsDisplayName[59]="John Rambo'd!"
	
	AchievementsDescription[0]=""
	AchievementsDescription[1]="Reunited with an old friend."
	AchievementsDescription[2]="Reunited with an old enemy."
	AchievementsDescription[3]="Reunited with an old flame."
	AchievementsDescription[4]="Reunited with a former child star and an infamous terrorist leader."
	AchievementsDescription[5]="Rescued your loyal companion."
	AchievementsDescription[6]="Completed Paradise Lost with no kills."
	AchievementsDescription[7]="Completed Paradise Lost on POSTAL difficulty."
	AchievementsDescription[8]="Completed Paradise Lost with a total play time of 1:45:00 or less. (Excludes cutscenes and loading times.)"
	AchievementsDescription[9]="Escaped the Animal Control Center with all six monkeys alive."
	AchievementsDescription[10]="Wasted no time with the Wise Wang."
	AchievementsDescription[11]="Bought the toilet paper instead of stealing it."
	AchievementsDescription[12]="Collected money for charity without stealing from Zack Ward."
	AchievementsDescription[13]="Killed Zack Ward."
	AchievementsDescription[14]="Deactivated all of the Vend-A-Cure XJ-2 units."
	AchievementsDescription[15]="Defeated your hateful ex-wife with delicious cake."
	AchievementsDescription[16]="Sold 30 cats at the Cash 4 Cats vendors."
	AchievementsDescription[17]="Spent $2,000 on vending machines."
	AchievementsDescription[18]="Made 30 kills while dual-wielding."
	AchievementsDescription[19]="Peed on all of the snowmen in the Nuclear Winter zone."
	AchievementsDescription[20]="Kicked 10 people in the balls."
	AchievementsDescription[21]="Pissed in someone's face until they puked from it."
	AchievementsDescription[22]="Used a Bass Sniffer Radar."
	AchievementsDescription[23]="Gained your first dog helper."
	AchievementsDescription[24]="Lured a police officer with a piss-soaked donut."
	AchievementsDescription[25]="Used a cat to 'accessorize' your gun."
	AchievementsDescription[26]="Resurrected a zombie corpse for your own nefarious purposes."
	AchievementsDescription[27]="Mauled 30 people with your dog."
	AchievementsDescription[28]="Roasted 30 people with fire."
	AchievementsDescription[29]="Totaled 30 cars."
	AchievementsDescription[30]="Kicked 30 dogs."
	AchievementsDescription[31]="Sliced 30 people in half with the scythe."
	AchievementsDescription[32]="Hoarded 15 or more cats at a time."
	AchievementsDescription[33]="Slaughtered 10 dogs with a kitty-silenced shotgun."
	AchievementsDescription[34]="Killed 10 bystanders while wearing the gimp outfit."
	AchievementsDescription[35]="Escaped from the maximum-security jail cell."
	AchievementsDescription[36]="Unzipped your pants and got 3 women to laugh at it."
	AchievementsDescription[37]="Ran 30 miles while holding the scissors."
	AchievementsDescription[38]="Killed 1,000 people."
	AchievementsDescription[39]="Killed 30 or more people of each skin color."
	AchievementsDescription[40]="Exploded 30 heads via sledgehammer to the face."
	AchievementsDescription[41]="Smoked over 10 'health' pipes and 10 tins of catnip in one play session."
	AchievementsDescription[42]="Burned 5 people with one can of napalm."
	AchievementsDescription[43]="Made 30 zombies lose their heads."
	AchievementsDescription[44]="Played 'fetch' with your dog... using a severed human head."
	AchievementsDescription[45]="Gave a kickoff to a severed head."
	AchievementsDescription[46]="Flung a sledgehammer at a fleeing bystander."
	AchievementsDescription[47]="'Lost' your sledgehammer to a cow."
	AchievementsDescription[48]="Zapped 20 innocent bystanders with the tazer while wearing the police officer's uniform."
	AchievementsDescription[49]="Committed suicide... the Taliban way."
	AchievementsDescription[50]="Read the newspaper every day."
	AchievementsDescription[51]="Successfully hid from the police at max wanted level."
	AchievementsDescription[52]="Successfully bribed a police officer when arrested."
	AchievementsDescription[53]="Kicked open a door."
	AchievementsDescription[54]="Put out someone that's on fire."
	AchievementsDescription[55]="Choked on your own piss."
	AchievementsDescription[56]="Whacked a severed head 50 meters or more with a shovel."
	AchievementsDescription[57]="Severed all of somebody's limbs without killing them."
	AchievementsDescription[58]="Killed someone with a jump kick to the head."
	AchievementsDescription[59]="Made a very long killing spree."
}