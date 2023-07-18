///////////////////////////////////////////////////////////////////////////////
// PLAchievementManager
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Enables PL achievements.
//
// Edit by Piotr S. 2022-10-18
// Enables P2 achievements too (for Two Weeks Game).
///////////////////////////////////////////////////////////////////////////////
class PLAchievementManager extends P2AchievementManager;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Block P2-only achievements
function bool EvaluateAchievement(PlayerController Achiever, name AchievementName, optional bool bDisplayInConsole)
{
	if (AchievementName == 'PetitionKill')
	{
		if (TWPGameInfo(Achiever.Level.Game) != None && TWPGameInfo(Achiever.Level.Game).IsSecondWeek()	// Two Weeks In Paradise, Second Week
			|| PLGameInfo(Achiever.Level.Game) != None)	// Paradise Lost
			return false;
	}
		
	return Super.EvaluateAchievement(Achiever, AchievementName, bDisplayInConsole);
}

// All Stats and Achievements go here.
defaultproperties
{
	// ========================================================================
	// STATS
	// ========================================================================
	
	// Cats Sold at Cash 4 Cats
	Stats(23)=(APIName="PLCatsSold",bIncrementOnly=True,StatType=STATTYPE_INT,DefaultValue_int=0,DisplayName="Cats Sold",RelatedAchievementName="PLCash4Cats")
	
	// Money Spent at Vending Machines
	Stats(24)=(APIName="PLVendingSpent",bIncrementOnly=True,StatType=STATTYPE_INT,DefaultValue_int=0,DisplayName="Money Spent on Vending Machines",RelatedAchievementName="PLVendingMachines")
	
	// Dual Wield Kills
	Stats(25)=(APIName="PLDualWieldKills",bIncrementOnly=True,StatType=STATTYPE_INT,DefaultValue_int=0,DisplayName="Dual Wield Kills",RelatedAchievementName="PLDualWieldAchievement")
	
	// ========================================================================
	// ACHIEVEMENTS
	// ========================================================================
	Achievements(71)=(APIName="PLMondayComplete",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.69-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.69-Locked')
	Achievements(72)=(APIName="PLTuesdayComplete",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.70-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.70-Locked')
	Achievements(73)=(APIName="PLWednesdayComplete",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.71-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.71-Locked')
	Achievements(74)=(APIName="PLThursdayComplete",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.72-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.72-Locked')
	Achievements(75)=(APIName="PLFridayComplete",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.73-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.73-Locked')
	Achievements(76)=(APIName="PLJesusRun",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.74-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.74-Locked')
	Achievements(77)=(APIName="PLPOSTALRun",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.75-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.75-Locked')
	Achievements(78)=(APIName="PLSpeedRun",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.76-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.76-Locked')
	Achievements(79)=(APIName="PLMonkeysSurvived",DisplayName=,Description=,bHidden=true,UnlockedTex=Texture'PLAchievementIcons.Unlocked.77-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.77-Locked')
	Achievements(80)=(APIName="PLKrotchySkip",DisplayName=,Description=,bHidden=True,UnlockedTex=Texture'PLAchievementIcons.Unlocked.78-Unlocked',bHidden=true,LockedTex=Texture'PLAchievementIcons.Locked.78-Locked')
	Achievements(81)=(APIName="PLBuyTP",DisplayName=,Description=,bHidden=True,UnlockedTex=Texture'PLAchievementIcons.Unlocked.79-Unlocked',bHidden=true,LockedTex=Texture'PLAchievementIcons.Locked.79-Locked')
	Achievements(82)=(APIName="PLCollectMoney",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.80-Unlocked',bHidden=true,LockedTex=Texture'PLAchievementIcons.Locked.80-Locked')
	Achievements(83)=(APIName="PLKillZack",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.81-Unlocked',bHidden=true,LockedTex=Texture'PLAchievementIcons.Locked.81-Locked')
	Achievements(84)=(APIName="PLPisstraps",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.82-Unlocked',bHidden=true,LockedTex=Texture'PLAchievementIcons.Locked.82-Locked',ProgressStat=0)
	Achievements(85)=(APIName="PLBitchCake",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.83-Unlocked',bHidden=true,LockedTex=Texture'PLAchievementIcons.Locked.83-Locked',ProgressStat=0)
	Achievements(86)=(APIName="PLCash4Cats",DisplayName=,Description=,ProgressStat=22,UnlockValue_int=30,bGrindy=false,UnlockedTex=Texture'PLAchievementIcons.Unlocked.84-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.84-Locked')
	Achievements(87)=(APIName="PLVendingMachines",DisplayName=,Description=,ProgressStat=23,UnlockValue_int=2000,bGrindy=false,UnlockedTex=Texture'PLAchievementIcons.Unlocked.85-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.85-Locked')
	Achievements(88)=(APIName="PLDualWieldAchievement",DisplayName=,Description=,ProgressStat=25,UnlockValue_int=30,bGrindy=false,UnlockedTex=Texture'PLAchievementIcons.Unlocked.86-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.86-Locked')
	Achievements(89)=(APIName="PLSnowmanAchievement",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.87-Unlocked',LockedTex=Texture'PLAchievementIcons.Locked.87-Locked')
//	Achievements(90)=(APIName="PLNutshotAchievement",DisplayName=,Description=,UnlockedTex=Texture'PLAchievementIcons.Unlocked.88-Unlocked',ProgressStat=24,UnlockValue_int=10,bGrindy=false,LockedTex=Texture'PLAchievementIcons.Locked.88-Locked')
	
	AchievementsDisplayName[71]="GABAGOOOOOL!"
	AchievementsDisplayName[72]="Holocaust: Part Deux"
	AchievementsDisplayName[73]="Rain on your Wedding Day"
	AchievementsDisplayName[74]="Watchu' Talkin' 'Bout Muhammad"
	AchievementsDisplayName[75]="Better than POSTAL III"
	AchievementsDisplayName[76]="My Name is Jesus"
	AchievementsDisplayName[77]="Harder than r/gonewild"
	AchievementsDisplayName[78]="Adderall4All"
	AchievementsDisplayName[79]="Ape Rape"
	AchievementsDisplayName[80]="Dick Message"
	AchievementsDisplayName[81]="PooMasher"
	AchievementsDisplayName[82]="Hobo Sexual"
	AchievementsDisplayName[83]="Ginger Mint"
	AchievementsDisplayName[84]="Ode to Eddings"
	AchievementsDisplayName[85]="Bitches Love Cake"
	AchievementsDisplayName[86]="Rich on Reddit"
	AchievementsDisplayName[87]="BioShocked"
	AchievementsDisplayName[88]="Reddit's Famous Double Dong"
	AchievementsDisplayName[89]="You Snow Nothing John Blow"
//	AchievementsDisplayName[90]="RAFIBOMB!!!"
	
	AchievementsDescription[71]="Reunited with an old friend."
	AchievementsDescription[72]="Reunited with an old enemy."
	AchievementsDescription[73]="Reunited with an old flame."
	AchievementsDescription[74]="Reunited with a former child star and an infamous terrorist leader."
	AchievementsDescription[75]="Rescued your loyal companion."
	AchievementsDescription[76]="Completed Paradise Lost with no kills."
	AchievementsDescription[77]="Completed Paradise Lost on POSTAL difficulty."
	AchievementsDescription[78]="Completed Paradise Lost with a total play time of 1:45:00 or less. (Excludes cutscenes and loading times.)"
	AchievementsDescription[79]="Escaped the Animal Control Center with all six monkeys alive."
	AchievementsDescription[80]="Wasted no time with the Wise Wang."
	AchievementsDescription[81]="Bought the toilet paper instead of stealing it."
	AchievementsDescription[82]="Collected money for charity without stealing from Zack Ward."
	AchievementsDescription[83]="Killed Zack Ward."
	AchievementsDescription[84]="Deactivated all of the Vend-A-Cure XJ-2 units."
	AchievementsDescription[85]="Defeated your hateful ex-wife with delicious cake."
	AchievementsDescription[86]="Sold 30 cats at the Cash 4 Cats vendors."
	AchievementsDescription[87]="Spent $2,000 on vending machines."
	AchievementsDescription[88]="Made 30 kills while dual-wielding."
	AchievementsDescription[89]="Peed on all of the snowmen in the Nuclear Winter zone."
//	AchievementsDescription[90]="Kicked 10 people in the balls."
}