// Why hello there!
// ============================================================================
// P2AchievementManager
// Class file for handling anything and everything involving Postal 2
// Achievements.
// ============================================================================

class P2AchievementManager extends AchievementManager;

var globalconfig bool bDisplayAchievements;
var localized string HiddenAchievementString;

function AchievementTest()
{
	Level.EvaluateAchievement(None,'TEST_ACHIEVEMENT');
}

// Some basic functions for MenuAchievementList.
function string GetAchievementName(int i)
{
	while (i < Achievements.Length)
	{
		if (Achievements[i].bIgnore)
			//i++;
			return "";
		else
			//ErikFOV Change: for localization
			//return Achievements[i].DisplayName;
			return AchievementsDisplayName[i];
			//end
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
			//ErikFOV Change: for localization
			//return Achievements[i].Description;
			return AchievementsDescription[i];
			//end
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

	for (i = 0; i < Achievements.Length; i++)
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

// ============================================================================
// PreBeginPlay
// DEBUG: Print out all stats and achievements.
// ============================================================================
event PreBeginPlay()
{
	Super.PreBeginPlay();
	//log(self@"PostBeginPlay",'Debug');
	//StatsDump();
}

function StatsDump()
{
	local int i;

	log("STATS DUMP ============================================================",'Debug');

	for (i=0; i<Stats.Length; i++)
		log(Stats[i].APIName,'Debug');

	for (i = 0; i < Achievements.Length; i++)
		log(Achievements[i].APIName,'Debug');
	
	log("DUMP COMPLETE =========================================================",'Debug');
}

// ============================================================================
// StatsReady
// Called by Entry's LevelInfo when the stats download is complete.
// ============================================================================
event StatsReady()
{
	Super.StatsReady();
	// Zero out any stats we want reset on each play session.
	
	Level.RequestUpdateStatInt('CrackSmoked', 0);
	Level.RequestUpdateStatInt('CatnipSmoked', 0);
	
	// Check if they're on Linux
	//if (Level.PlatformIsUnix())
	//	EvaluateAchievement()
	
	// Re-dump stats when Steam fills them in
	//StatsDump();
}

// Dude comments on grinding.
function CommentOnGrinding(PlayerController Statter)
{
	if (P2Player(Statter) != None)
		P2Player(Statter).CommentOnGrinding();
}

// ============================================================================
// EvaluateAchievement
// Attempt to unlock achievement. Check that cheats are disabled and that the
// necessary requirements to unlock the achievement are met.
// ============================================================================
function bool EvaluateAchievement(PlayerController Achiever, name AchievementName, optional bool bDisplayInConsole)
{
	local Inventory Inv;
	local P2PowerupInv Cats;
	local int i, AchNum;
	
	//log("Evaluating to unlock achievement"@AchievementName@"made by"@Achiever,'Debug');	
	
	// Test achievement always returns true.
	if (AchievementName == 'TEST_ACHIEVEMENT')
		return true;

	// Refuse any achievement or stat updates if cheats enabled.
	if (
		(AchievementName == 'None')	// Don't try to evaulate empty achievements
		|| (P2Player(Achiever) == None)
		|| P2GameInfoSingle(Achiever.Level.Game).TheGameState.DidPlayerCheat()
		
			// Even if they have cheats turned off, TheGameState now remembers when players cheat, and
			// marks that save file as a cheater (it would be too easy to spawn a bunch of shit with cheat codes
			// then reload the game with cheats off and whore achievements this way).
			// Must get Level.Game from the PlayerController, because to us, Level is Entry.
		)
		return false;

	// Check for achievement status and validity here. Return "true" if the achievement can be unlocked.
	AchNum = -1;

	for (i = 0; i < Achievements.Length; i++)
		if (AchievementName == Achievements[i].APIName)
		{
			AchNum = i;
			break;
		}
		
	if (AchNum == -1)
		return false;
		
	if (Achievements[AchNum].bUnlocked)
		return false;	// Don't unlock it again
		
	if (Achievements[AchNum].bIgnore)
		return false;
		
	// Validate achievements here
	
	// Cat Hoarder
	if (AchievementName == 'CatHoarder')
	{
		if (Achiever.Pawn != None)
			for (Inv = Achiever.Pawn.Inventory; Inv != None; Inv = Inv.Inventory)
				if (P2PowerupInv(Inv) != None && Inv.IsA('CatInv'))
				{
					Cats = P2PowerupInv(Inv);
					break;
				}
				
		if (Cats == None || Cats.Amount < Achievements[AchNum].UnlockValue_int)
			return false;
	}
	// Equal Opportunity Killer
	else if (AchievementName == 'EqualOpportunityKiller')
	{
		// For this one, make sure the number of kills for all three races matches.
		if (Stats[11].StatValue_int < Achievements[AchNum].UnlockValue_int
			|| Stats[12].StatValue_int < Achievements[AchNum].UnlockValue_int
			|| Stats[13].StatValue_int < Achievements[AchNum].UnlockValue_int)
			return false;
	}
	// Game Complete
	else if (AchievementName == 'GameComplete')
	{
		if (!P2GameInfoSingle(Achiever.Level.Game).FinallyOver()
			|| !P2GameInfoSingle(Achiever.Level.Game).GinallyOver()
			)
			return false;
	}
	// Other achievements with related stats
	else if (Stats[Achievements[AchNum].ProgressStat].StatType != STATTYPE_None)	// This should never happen, if it does it indicates that a progress stat does not exist
	{
		if (Stats[Achievements[AchNum].ProgressStat].StatType == STATTYPE_Int
			&& Stats[Achievements[AchNum].ProgressStat].StatValue_int < Achievements[AchNum].UnlockValue_int)
			return false;
		if (Stats[Achievements[AchNum].ProgressStat].StatType == STATTYPE_Float
			&& Stats[Achievements[AchNum].ProgressStat].StatValue_float < Achievements[AchNum].UnlockValue_float)
			return false;
	}
	
	
	//log("== DEBUG UNLOCK ACHIEVEMENT ==",'Debug');
	//log("Achievement Unlocked:"@AchievementName,'Debug');
	//Achiever.ClientMessage("=DEBUG= Achievement Unlocked:"@AchievementName@"'"$Achievements[AchNum].DisplayName$"'");
	
	// bDisplayInConsole is set for achievements that typically don't happen during actual gameplay. On Steam we won't care, but for this testing build
	// (and for the non-Steam version we'll release), display these achievements in the console so the player can be proud of themselves and not
	// wonder where this mystery achievement came from.
	if (bDisplayAchievements)
	{
		if (bDisplayInConsole)	
			//ErikFOV Change: for localization
			//Achiever.ClientMessage("Achievement Unlocked!"@Achievements[AchNum].DisplayName);
			Achiever.ClientMessage("Achievement Unlocked!"@AchievementsDisplayName[AchNum]);
			//end
		else
		{
			//Achiever.ReceiveLocalizedMessage(class'AchievementUnlockMessage', AchNum);
			//Achiever.ReceiveLocalizedMessage(class'AchievementUnlockChildMessage', AchNum);
			//ErikFOV Change: for localization
			//AchievementHUD(Achiever.MyHud).AchievementUnlocked(Achievements[AchNum].DisplayName,Achievements[AchNum].Description,Achievements[AchNum].UnlockedTex);
			AchievementHUD(Achiever.MyHud).AchievementUnlocked(AchievementsDisplayName[AchNum],AchievementsDescription[AchNum],Achievements[AchNum].UnlockedTex);
			//end
		}
		if (!Achievements[AchNum].bNoComment)
			P2Player(Achiever).CommentOnAchievement(AchNum);
	}
		
	Achievements[AchNum].bUnlocked = True;
	AchievementValues[AchNum].bUnlocked = Achievements[AchNum].bUnlocked;
	SaveConfig();
	return true;
}

// ============================================================================
// UpdateStatInt
// Updates an int-based stat.
// ============================================================================
function UpdateStatInt(PlayerController Statter, name StatName, int Delta, optional bool bUnlockAchievement)
{
	// Refuse any achievement or stat updates if cheats enabled.
	if ((P2Player(Statter) == None) /* || (P2Player(Statter).CheatsAllowed()) */ 
		|| (P2GameInfoSingle(Statter.Level.Game).TheGameState.DidPlayerCheat())
		)
		return;
	else
		Super.UpdateStatInt(Statter, StatName, Delta, bUnlockAchievement);
}

// ============================================================================
// UpdateStatFloat
// Updates a float-based stat.
// ============================================================================
function UpdateStatFloat(PlayerController Statter, name StatName, float Delta, optional bool bUnlockAchievement)
{
	// Refuse any achievement or stat updates if cheats enabled.
	if ((P2Player(Statter) == None) /* || (P2Player(Statter).CheatsAllowed()) */ 
		|| (P2GameInfoSingle(Statter.Level.Game).TheGameState.DidPlayerCheat())
		)
		return;
	else
		Super.UpdateStatFloat(Statter, StatName, Delta, bUnlockAchievement);
}

// All Stats and Achievements go here.
defaultproperties
{
	// ========================================================================
	// STATS
	// ========================================================================
	
	// Fire Kills
	Stats(1)=(APIName="FireKills",bIncrementOnly=True,StatType=STATTYPE_INT,DefaultValue_int=0,DisplayName="Fire Kills",RelatedAchievementName="FireKillsAchievement")
	
	// Cars Destroyed
	Stats(2)=(APIName="CarsDestroyed",bIncrementOnly=True,StatType=STATTYPE_INT,DefaultValue_int=0,DisplayName="Cars Blown Up",RelatedAchievementName="CarsDestroyedAchievement")
	
	// Dogs Kicked
	Stats(3)=(APIName="DogsKicked",bIncrementOnly=True,StatType=STATTYPE_INT,DefaultValue_int=0,DisplayName="Dogs Kicked",RelatedAchievementName="DogsKickedAchievement")
	
	// People Scythe'd
	Stats(4)=(APIName="PeopleScythed",bIncrementOnly=True,StatType=STATTYPE_INT,DefaultValue_int=0,DisplayName="People Sliced in Half",RelatedAchievementName="PeopleScythedAchievement")
	
	// Dogs Killed with Catgun
	Stats(5)=(APIName="DogsKilledWithCatgun",bIncrementOnly=True,StatType=STATTYPE_INT,DefaultValue_int=0,DisplayName="Dogs Killed With Cat-Silenced Shotgun",RelatedAchievementName="DogsKilledWithCatgunAchievement")
	
	// Bystanders Killed While Gimped
	Stats(6)=(APIName="BystandersKilledWhileGimped",bIncrementOnly=True,StatType=STATTYPE_INT,DefaultValue_int=0,DisplayName="Bystanders Killed While Wearing Gimp Suit",RelatedAchievementName="BystandersKilledWhileGimpedAchievement")
	
	// Times Escaped From Jail (Current Day)
	Stats(7)=(APIName="DailyJailEscapes",StatType=STATTYPE_INT,DefaultValue_int=0,DisplayName="Times escaped from jail in one day",RelatedAchievementName="Jailbird")
	
	// I've Seen Bigger
	Stats(8)=(APIName="IveSeenBigger",StatType=STATTYPE_Int,bIncrementOnly=True,DefaultValue_int=0,DisplayName="I've seen bigger",RelatedAchievementName="IveSeenBiggerAchievement")
	
	// Running With Scissors
	Stats(9)=(APIName="RunningWithScissors",StatType=STATTYPE_Float,bIncrementOnly=True,DefaultValue_float=0.000000,DisplayName="Miles ran with scissors",RelatedAchievementName="RunningWithScissorsAchievement")
	
	// Total People Killed
	Stats(10)=(APIName="PeopleKilled",StatType=STATTYPE_Int,bIncrementOnly=True,DefaultValue_int=0,DisplayName="Total people killed",RelatedAchievementName="PeopleKilledAchievement")
	
	// Blacks Killed
	Stats(11)=(APIName="BlacksKilled",StatType=STATTYPE_Int,bIncrementOnly=True,DefaultValue_int=0,DisplayName="Blacks killed")
	// Mexicans Killed
	Stats(12)=(APIName="MexicansKilled",StatType=STATTYPE_Int,bIncrementOnly=True,DefaultValue_int=0,DisplayName="Mexicans killed")
	// Whites Killed
	Stats(13)=(APIName="WhitesKilled",StatType=STATTYPE_Int,bIncrementOnly=True,DefaultValue_int=0,DisplayName="Whites killed")
	// Stats 11-13 all come together for the Equal Opportunity Killer achievement. Let's say 30 of each	
	
	// Sledge Faceshots
	Stats(14)=(APIName="SledgeFaceshots",StatType=STATTYPE_Int,bIncrementOnly=True,DefaultValue_int=0,DisplayName="Sledge Faceshots",RelatedAchievementName="SledgeFaceshotsAchievement")
	
	// Crack Smoked
	Stats(15)=(APIName="CrackSmoked",StatType=STATTYPE_Int,DefaultValue_int=0,DisplayName="Health Pipes Smoked")
	
	// Catnip Smoked
	Stats(16)=(APIName="CatnipSmoked",StatType=STATTYPE_Int,DefaultValue_int=0,DisplayName="Catnip Smoked")
	
	// Donuts Eaten On Duty
	Stats(17)=(APIName="DonutsEaten",StatType=STATTYPE_Int,bIncrementOnly=True,DefaultValue_int=0,DisplayName="Donuts Eaten While Wearing Cop Outfit",RelatedAchievementName="DonutsEatenAchievement")
	
	// Bystanders Tazed On Duty
	Stats(18)=(APIName="BystandersTazed",StatType=STATTYPE_Int,DefaultValue_int=0,bIncrementOnly=True,DisplayName="Bystanders Tazed While Wearing Cop Outfit",RelatedAchievementName="DontTazeMeAchievement")
	
	// Zombies Beheaded
	Stats(19)=(APIName="ZombiesBeheaded",StatType=STATTYPE_Int,DefaultValue_int=0,bIncrementOnly=True,DisplayName="Zombies Beheaded",RelatedAchievementName="ZombiesBeheadedAchievement")
	
	// Taliban Killed
	Stats(20)=(APIName="FanaticsKilled",StatType=STATTYPE_Int,DefaultValue_int=0,bIncrementOnly=True,DisplayName="Fanatics Killed")
	
	// Dog Helper Kills
	Stats(21)=(APIName="DogKills",bIncrementOnly=True,StatType=STATTYPE_INT,DefaultValue_int=0,DisplayName="Dog Helper Kills",RelatedAchievementName="DogKillsAchievement")
	
	// Nutshots
	Stats(22)=(APIName="PLNutshots",bIncrementOnly=True,StatType=STATTYPE_INT,DefaultValue_int=0,DisplayName="Nutshots Scored",RelatedAchievementName="PLNutshotAchievement")
	
	// ========================================================================
	// ACHIEVEMENTS
	// ========================================================================
	
	// Take A Piss
	//ErikFOV Change: for localization
	//Achievements(0)=(APIName="PissInFace",DisplayName="R. Kelly's Protege",Description="Pissed in someone's face until they puked from it.",LockedTex=Texture'AchievementIcons.Locked-512.01-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.01-Unlocked-512')
	Achievements(0)=(APIName="PissInFace",LockedTex=Texture'AchievementIcons.Locked-512.01-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.01-Unlocked-512')
	AchievementsDisplayName(0)="R. Kelly's Protege"
	AchievementsDescription(0)="Pissed in someone's face until they puked from it."
	//end
	
	// Use a Fish Finder
	//ErikFOV Change: for localization
	//Achievements(1)=(APIName="Fishy",DisplayName="Fuck Duck Dynasty!",Description="Used a Bass Sniffer Radar.",LockedTex=Texture'AchievementIcons.Locked-512.02-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.02-Unlocked-512')
	Achievements(1)=(APIName="Fishy",LockedTex=Texture'AchievementIcons.Locked-512.02-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.02-Unlocked-512')
	AchievementsDisplayName(1)="Fuck Duck Dynasty!"
	AchievementsDescription(1)="Used a Bass Sniffer Radar."
	//end
	
	// Befriend a dog
	//ErikFOV Change: for localization
	//Achievements(2)=(APIName="DogHelper",DisplayName="Here, Wilfred",Description="Gained your first dog helper.",LockedTex=Texture'AchievementIcons.Locked-512.03-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.03-Unlocked-512')
	Achievements(2)=(APIName="DogHelper",LockedTex=Texture'AchievementIcons.Locked-512.03-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.03-Unlocked-512')
	AchievementsDisplayName(2)="Here, Wilfred"
	AchievementsDescription(2)="Gained your first dog helper."
	//end

	// Lure a cop with a donut
	//ErikFOV Change: for localization
	//Achievements(3)=(APIName="HerePiggyPiggy",DisplayName="Chapelle's Show",Description="Lured a police officer with a piss-soaked donut.",LockedTex=Texture'AchievementIcons.Locked-512.04-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.04-Unlocked-512')
	Achievements(3)=(APIName="HerePiggyPiggy",LockedTex=Texture'AchievementIcons.Locked-512.04-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.04-Unlocked-512')
	AchievementsDisplayName(3)="Chapelle's Show"
	AchievementsDescription(3)="Lured a police officer with a piss-soaked donut."
	//end
	
	// Used the Cat Silencer
	//ErikFOV Change: for localization
	//Achievements(4)=(APIName="CatSilencer",DisplayName="Taxidermy with Chuck Testa",Description="Used a cat to 'accessorize' your gun.",LockedTex=Texture'AchievementIcons.Locked-512.05-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.05-Unlocked-512')
	Achievements(4)=(APIName="CatSilencer",LockedTex=Texture'AchievementIcons.Locked-512.05-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.05-Unlocked-512')
	AchievementsDisplayName(4)="Taxidermy with Chuck Testa"
	AchievementsDescription(4)="Used a cat to 'accessorize' your gun."
	//end
	
	// Resurrect a Zombie
	//ErikFOV Change: for localization
	//Achievements(5)=(APIName="Resurrection",DisplayName="Michonne ain't got shit on me",Description="Resurrected a zombie corpse for your own nefarious purposes.",LockedTex=Texture'AchievementIcons.Locked-512.06-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.06-Unlocked-512');
	Achievements(5)=(APIName="Resurrection",LockedTex=Texture'AchievementIcons.Locked-512.06-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.06-Unlocked-512');
	AchievementsDisplayName(5)="Michonne ain't got shit on me"
	AchievementsDescription(5)="Resurrected a zombie corpse for your own nefarious purposes."
	//end

	// Finish Monday
	//ErikFOV Change: for localization
	//Achievements(6)=(APIName="MondayComplete",DisplayName="Someone's got a case of the Mondays!",Description="Survived Monday.",LockedTex=Texture'AchievementIcons.Locked-512.07-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.07-Unlocked-512');
	Achievements(6)=(APIName="MondayComplete",LockedTex=Texture'AchievementIcons.Locked-512.07-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.07-Unlocked-512');
	AchievementsDisplayName(6)="Someone's got a case of the Mondays!"
	AchievementsDescription(6)="Survived Monday."
	//end
	
	// Finish Tuesday
	//ErikFOV Change: for localization
	//Achievements(7)=(APIName="TuesdayComplete",DisplayName="C U Next Tuesday",Description="Survived Tuesday.",LockedTex=Texture'AchievementIcons.Locked-512.08-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.08-Unlocked-512');
	Achievements(7)=(APIName="TuesdayComplete",LockedTex=Texture'AchievementIcons.Locked-512.08-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.08-Unlocked-512');
	AchievementsDisplayName(7)="C U Next Tuesday"
	AchievementsDescription(7)="Survived Tuesday."
	//end
	
	// Finish Wednesday
	//ErikFOV Change: for localization
	//Achievements(8)=(APIName="WednesdayComplete",DisplayName="OMG, NEW MODERN FAMILY TONIGHT!",Description="Survived Wednesday.",LockedTex=Texture'AchievementIcons.Locked-512.09-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.09-Unlocked-512');
	Achievements(8)=(APIName="WednesdayComplete",LockedTex=Texture'AchievementIcons.Locked-512.09-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.09-Unlocked-512');
	AchievementsDisplayName(8)="OMG, NEW MODERN FAMILY TONIGHT!"
	AchievementsDescription(8)="Survived Wednesday."
	//end
	
	// Finish Thursday
	//ErikFOV Change: for localization
	//Achievements(9)=(APIName="ThursdayComplete",DisplayName="It must be Thursday, I could never get the hang of Thursdays",Description="Survived Thursday.",LockedTex=Texture'AchievementIcons.Locked-512.10-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.10-Unlocked-512');
	Achievements(9)=(APIName="ThursdayComplete",LockedTex=Texture'AchievementIcons.Locked-512.10-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.10-Unlocked-512');
	AchievementsDisplayName(9)="It must be Thursday, I could never get the hang of Thursdays"
	AchievementsDescription(9)="Survived Thursday."
	//end
	
	// Finish Friday
	//ErikFOV Change: for localization
	//Achievements(10)=(APIName="FridayComplete",DisplayName="Workin' For The Weekend",Description="Survived Friday.",LockedTex=Texture'AchievementIcons.Locked-512.11-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.11-Unlocked-512');
	Achievements(10)=(APIName="FridayComplete",LockedTex=Texture'AchievementIcons.Locked-512.11-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.11-Unlocked-512');
	AchievementsDisplayName(10)="Workin' For The Weekend"
	AchievementsDescription(10)="Survived Friday."
	//end
	
	// Finish Saturday
	//ErikFOV Change: for localization
	//Achievements(11)=(APIName="SaturdayComplete",DisplayName="Screw Bill Lumbergh!",Description="Survived Saturday.",LockedTex=Texture'AchievementIcons.Locked-512.12-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.12-Unlocked-512');
	Achievements(11)=(APIName="SaturdayComplete",LockedTex=Texture'AchievementIcons.Locked-512.12-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.12-Unlocked-512');
	AchievementsDisplayName(11)="Screw Bill Lumbergh!"
	AchievementsDescription(11)="Survived Saturday."
	//end
		
	// Finish Sunday
	//ErikFOV Change: for localization
	//Achievements(12)=(APIName="SundayComplete",DisplayName="I swear, I thought it was a home fill",Description="Exploded a nuclear bomb.",bIgnore=False,LockedTex=Texture'AchievementIcons.Locked-512.14-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.14-Unlocked-512');	
	Achievements(12)=(APIName="SundayComplete",bIgnore=False,LockedTex=Texture'AchievementIcons.Locked-512.14-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.14-Unlocked-512');
	AchievementsDisplayName(12)="I swear, I thought it was a home fill"
	AchievementsDescription(12)="Exploded a nuclear bomb."
	//end
	
	// Completed both P2 and AW
	//ErikFOV Change: for localization
	//Achievements(13)=(APIName="GameComplete",DisplayName="Thanks for the Money!",Description="Completed both POSTAL 2 and Apocalypse Weekend.",LockedTex=Texture'AchievementIcons.Locked-512.13-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.13-Unlocked-512');
	Achievements(13)=(APIName="GameComplete",LockedTex=Texture'AchievementIcons.Locked-512.13-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.13-Unlocked-512');
	AchievementsDisplayName(13)="Thanks for the Money!"
	AchievementsDescription(13)="Completed both POSTAL 2 and Apocalypse Weekend."
	//end
	
	// Dog Helper Kills
	//ErikFOV Change: for localization
	//Achievements(14)=(APIName="DogKillsAchievement",DisplayName="Cesar Millan is Gay",Description="Mauled 30 people with your dog.",ProgressStat=21,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.15-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.15-Unlocked-512')
	Achievements(14)=(APIName="DogKillsAchievement",ProgressStat=21,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.15-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.15-Unlocked-512')
	AchievementsDisplayName(14)="Cesar Millan is Gay"
	AchievementsDescription(14)="Mauled 30 people with your dog."
	//end
	
	// Fire Kills
	//ErikFOV Change: for localization
	//Achievements(15)=(APIName="FireKillsAchievement",DisplayName="OMG WE'RE HAVING A FIRE...sale",Description="Roasted 30 people with fire.",ProgressStat=1,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.16-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.16-Unlocked-512')
	Achievements(15)=(APIName="FireKillsAchievement",ProgressStat=1,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.16-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.16-Unlocked-512')
	AchievementsDisplayName(15)="OMG WE'RE HAVING A FIRE...sale"
	AchievementsDescription(15)="Roasted 30 people with fire."
	//end
	
	// Cars Destroyed
	//ErikFOV Change: for localization
	//Achievements(16)=(APIName="CarsDestroyedAchievement",DisplayName="Rebecca Black's Nightmare",Description="Totaled 30 cars.",ProgressStat=2,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.17-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.17-Unlocked-512')
	Achievements(16)=(APIName="CarsDestroyedAchievement",ProgressStat=2,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.17-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.17-Unlocked-512')
	AchievementsDisplayName(16)="Rebecca Black's Nightmare"
	AchievementsDescription(16)="Totaled 30 cars."
	//end
	
	// Dogs Kicked
	//ErikFOV Change: for localization
	//Achievements(17)=(APIName="DogsKickedAchievement",DisplayName="Hello, Newman",Description="Kicked 30 dogs.",ProgressStat=3,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.18-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.18-Unlocked-512')
	Achievements(17)=(APIName="DogsKickedAchievement",ProgressStat=3,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.18-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.18-Unlocked-512')
	AchievementsDisplayName(17)="Hello, Newman"
	AchievementsDescription(17)="Kicked 30 dogs."
	//end
		
	// People Sliced In Half
	//ErikFOV Change: for localization
	//Achievements(18)=(APIName="PeopleScythedAchievement",DisplayName="Darth Maul'd and shit!",Description="Sliced 30 people in half with the scythe.",ProgressStat=4,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.19-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.19-Unlocked-512')
	Achievements(18)=(APIName="PeopleScythedAchievement",ProgressStat=4,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.19-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.19-Unlocked-512')
	AchievementsDisplayName(18)="Darth Maul'd and shit!"
	AchievementsDescription(18)="Sliced 30 people in half with the scythe."
	//end
		
	// Cat Hoarder
	//ErikFOV Change: for localization
	//Achievements(19)=(APIName="CatHoarder",DisplayName="Reddit would be proud.",Description="Hoarded 15 or more cats at a time.",UnlockValue_int=15,LockedTex=Texture'AchievementIcons.Locked-512.20-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.20-Unlocked-512')
	Achievements(19)=(APIName="CatHoarder",UnlockValue_int=15,LockedTex=Texture'AchievementIcons.Locked-512.20-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.20-Unlocked-512')
	AchievementsDisplayName(19)="Reddit would be proud."
	AchievementsDescription(19)="Hoarded 15 or more cats at a time."
	//end
		
	// Dogs Killed With Catgun
	//ErikFOV Change: for localization
	//Achievements(20)=(APIName="DogsKilledWithCatgunAchievement",DisplayName="Pussy on a pedestal",Description="Slaughtered 10 dogs with a kitty-silenced shotgun.",ProgressStat=5,UnlockValue_int=10,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.21-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.21-Unlocked-512')
	Achievements(20)=(APIName="DogsKilledWithCatgunAchievement",ProgressStat=5,UnlockValue_int=10,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.21-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.21-Unlocked-512')
	AchievementsDisplayName(20)="Pussy on a pedestal"
	AchievementsDescription(20)="Slaughtered 10 dogs with a kitty-silenced shotgun."
	//end
		
	// Bystanders Killed While Gimped
	//ErikFOV Change: for localization
	//Achievements(21)=(APIName="BystandersKilledWhileGimpedAchievement",DisplayName="I swear, I am NOT Marcellus Wallace",Description="Killed 10 bystanders while wearing the gimp outfit.",ProgressStat=6,UnlockValue_int=10,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.22-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.22-Unlocked-512')
	Achievements(21)=(APIName="BystandersKilledWhileGimpedAchievement",ProgressStat=6,UnlockValue_int=10,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.22-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.22-Unlocked-512')
	AchievementsDisplayName(21)="I swear, I am NOT Marcellus Wallace"
	AchievementsDescription(21)="Killed 10 bystanders while wearing the gimp outfit."
	//end
	
	// Jailbird
	//ErikFOV Change: for localization
	//Achievements(22)=(APIName="Jailbird",DisplayName="Uncle T-Bag",Description="Escaped from the maximum-security jail cell.",LockedTex=Texture'AchievementIcons.Locked-512.23-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.23-Unlocked-512')
	Achievements(22)=(APIName="Jailbird",LockedTex=Texture'AchievementIcons.Locked-512.23-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.23-Unlocked-512')
	AchievementsDisplayName(22)="Uncle T-Bag"
	AchievementsDescription(22)="Escaped from the maximum-security jail cell."
	//end
		
	// I've Seen Bigger
	//ErikFOV Change: for localization
	//Achievements(23)=(APIName="IveSeenBiggerAchievement",DisplayName="Do you even Enzyte, bro?",Description="Unzipped your pants and got 3 women to laugh at it.",ProgressStat=8,UnlockValue_int=3,LockedTex=Texture'AchievementIcons.Locked-512.24-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.24-Unlocked-512')
	Achievements(23)=(APIName="IveSeenBiggerAchievement",ProgressStat=8,UnlockValue_int=3,LockedTex=Texture'AchievementIcons.Locked-512.24-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.24-Unlocked-512')
	AchievementsDisplayName(23)="Do you even Enzyte, bro?"
	AchievementsDescription(23)="Unzipped your pants and got 3 women to laugh at it."
	//end
		
	// Running With Scissors
	//ErikFOV Change: for localization
	//Achievements(24)=(APIName="RunningWithScissorsAchievement",DisplayName="Running With Scissors",Description="Ran 30 miles while holding the scissors.",ProgressStat=9,UnlockValue_float=30.000000,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.25-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.25-Unlocked-512')
	Achievements(24)=(APIName="RunningWithScissorsAchievement",ProgressStat=9,UnlockValue_float=30.000000,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.25-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.25-Unlocked-512')
	AchievementsDisplayName(24)="Running With Scissors"
	AchievementsDescription(24)="Ran 30 miles while holding the scissors."
	//end
	
	// 1000 People Killed
	//ErikFOV Change: for localization
	//Achievements(25)=(APIName="PeopleKilledAchievement",DisplayName="Hutton Gibson Can't Deny This!",Description="Killed 1,000 people.",ProgressStat=10,UnlockValue_int=1000,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.26-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.26-Unlocked-512')
	Achievements(25)=(APIName="PeopleKilledAchievement",ProgressStat=10,UnlockValue_int=1000,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.26-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.26-Unlocked-512')
	AchievementsDisplayName(25)="Hutton Gibson Can't Deny This!"
	AchievementsDescription(25)="Killed 1,000 people."
	//end
	
	// Killed Book Burners
	//ErikFOV Change: for localization
	//Achievements(26)=(APIName="KilledBookBurners",DisplayName="And THAT'S why you never get out of the tree.",Description="Killed all of the book protestors in the library.",LockedTex=Texture'AchievementIcons.Locked-512.27-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.27-Unlocked-512')
	Achievements(26)=(APIName="KilledBookBurners",LockedTex=Texture'AchievementIcons.Locked-512.27-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.27-Unlocked-512')
	AchievementsDisplayName(26)="And THAT'S why you never get out of the tree."
	AchievementsDescription(26)="Killed all of the book protestors in the library."
	//end
		
	// Killed RWS Protestors
	//ErikFOV Change: for localization
	//Achievements(27)=(APIName="KilledRWSProtestors",DisplayName="Lieberman is our Leader!",Description="Killed all of the video game protestors at the RWS Office.",LockedTex=Texture'AchievementIcons.Locked-512.28-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.28-Unlocked-512')
	Achievements(27)=(APIName="KilledRWSProtestors",LockedTex=Texture'AchievementIcons.Locked-512.28-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.28-Unlocked-512')
	AchievementsDisplayName(27)="Lieberman is our Leader!"
	AchievementsDescription(27)="Killed all of the video game protestors at the RWS Office."
	//end
	
	// Equal Opportunity Killer
	//ErikFOV Change: for localization
	//Achievements(28)=(APIName="EqualOpportunityKiller",DisplayName="Sheriff Arpaio would be proud.",Description="Killed 30 or more people of each skin color.",UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.29-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.29-Unlocked-512')
	Achievements(28)=(APIName="EqualOpportunityKiller",UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.29-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.29-Unlocked-512')
	AchievementsDisplayName(28)="Sheriff Arpaio would be proud."
	AchievementsDescription(28)="Killed 30 or more people of each skin color."
	//end
		
	// Sledgehammer Faceshots
	//ErikFOV Change: for localization
	//Achievements(29)=(APIName="SledgeFaceshotsAchievement",DisplayName="Can't Touch This",Description="Exploded 30 heads via sledgehammer to the face.",ProgressStat=14,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.30-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.30-Unlocked-512')
	Achievements(29)=(APIName="SledgeFaceshotsAchievement",ProgressStat=14,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.30-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.30-Unlocked-512')
	AchievementsDisplayName(29)="Can't Touch This"
	AchievementsDescription(29)="Exploded 30 heads via sledgehammer to the face."
	//end
		
	// Fear and Loathing
	//ErikFOV Change: for localization
	//Achievements(30)=(APIName="FearAndLoathing",DisplayName="Fear and Loathing",Description="Smoked over 10 'health' pipes and 10 tins of catnip in one play session.",UnlockValue_int=10,LockedTex=Texture'AchievementIcons.Locked-512.31-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.31-Unlocked-512')
	Achievements(30)=(APIName="FearAndLoathing",UnlockValue_int=10,LockedTex=Texture'AchievementIcons.Locked-512.31-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.31-Unlocked-512')
	AchievementsDisplayName(30)="Fear and Loathing"
	AchievementsDescription(30)="Smoked over 10 'health' pipes and 10 tins of catnip in one play session."
	//end
		
	// Donuts Eaten On Duty
	//ErikFOV Change: for localization
	//Achievements(31)=(APIName="DonutsEatenAchievement",DisplayName="Senor Cornballer",Description="Ate 30 donuts while wearing the police officer's uniform.",ProgressStat=17,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.32-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.32-Unlocked-512')
	Achievements(31)=(APIName="DonutsEatenAchievement",ProgressStat=17,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.32-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.32-Unlocked-512')
	AchievementsDisplayName(31)="Senor Cornballer"
	AchievementsDescription(31)="Ate 30 donuts while wearing the police officer's uniform."
	//end
		
	// Napalm Burn
	//ErikFOV Change: for localization
	//Achievements(32)=(APIName="GoodMorningVietnam",DisplayName="GOOD MORNING VIETNAM!",Description="Burned 5 people with one can of napalm.",LockedTex=Texture'AchievementIcons.Locked-512.33-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.33-Unlocked-512')
	Achievements(32)=(APIName="GoodMorningVietnam",LockedTex=Texture'AchievementIcons.Locked-512.33-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.33-Unlocked-512')
	AchievementsDisplayName(32)="GOOD MORNING VIETNAM!"
	AchievementsDescription(32)="Burned 5 people with one can of napalm."
	//end
		
	// Zombies Beheaded
	//ErikFOV Change: for localization
	//Achievements(33)=(APIName="ZombiesBeheadedAchievement",DisplayName="Rick Grimes 4 Life",Description="Made 30 zombies lose their heads.",ProgressStat=19,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.34-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.34-Unlocked-512')
	Achievements(33)=(APIName="ZombiesBeheadedAchievement",ProgressStat=19,UnlockValue_int=30,bGrindy=False,LockedTex=Texture'AchievementIcons.Locked-512.34-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.34-Unlocked-512')
	AchievementsDisplayName(33)="Rick Grimes 4 Life"
	AchievementsDescription(33)="Made 30 zombies lose their heads."
	//end
		
	// Jesus Freak
	//ErikFOV Change: for localization
	//Achievements(34)=(APIName="JesusEnding",DisplayName="Anustart!",Description="Completed POSTAL 2 with no kills.",LockedTex=Texture'AchievementIcons.Locked-512.35-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.35-Unlocked-512')
	Achievements(34)=(APIName="JesusEnding",LockedTex=Texture'AchievementIcons.Locked-512.35-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.35-Unlocked-512')
	AchievementsDisplayName(34)="Anustart!"
	AchievementsDescription(34)="Completed POSTAL 2 with no kills."
	//end
		
	// Speedrun Ending
	//ErikFOV Change: for localization
	//Achievements(35)=(APIName="SpeedrunEnding",DisplayName="40 Year Old Virgin",Description="Completed POSTAL 2, normal mode, with a total play time under 1:30:00. (Excludes cutscenes and load times.)",LockedTex=Texture'AchievementIcons.Locked-512.36-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.36-Unlocked-512')
	Achievements(35)=(APIName="SpeedrunEnding",LockedTex=Texture'AchievementIcons.Locked-512.36-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.36-Unlocked-512')
	AchievementsDisplayName(35)="40 Year Old Virgin"
	AchievementsDescription(35)="Completed POSTAL 2, normal mode, with a total play time under 1:30:00. (Excludes cutscenes and load times.)"
	//end
		
	// Shovel Ending
	//ErikFOV Change: for localization
	//Achievements(36)=(APIName="ShovelEnding",DisplayName="CAN YOU DIG IT!",Description="Completed POSTAL 2 using only the Shovel to kill. (Must kill at least 30 people.)",LockedTex=Texture'AchievementIcons.Locked-512.37-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.37-Unlocked-512')
	Achievements(36)=(APIName="ShovelEnding",LockedTex=Texture'AchievementIcons.Locked-512.37-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.37-Unlocked-512')
	AchievementsDisplayName(36)="CAN YOU DIG IT!"
	AchievementsDescription(36)="Completed POSTAL 2 using only the Shovel to kill. (Must kill at least 30 people.)"
	//end
		
	// Hestonworld Ending
	//ErikFOV Change: for localization
	//Achievements(37)=(APIName="HestonworldEnding",DisplayName="Planet Of The Apes: The Musical",Description="Finished POSTAL 2 or Apocalypse Weekend on Hestonworld difficulty.",LockedTex=Texture'AchievementIcons.Locked-512.38-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.38-Unlocked-512')
	Achievements(37)=(APIName="HestonworldEnding",LockedTex=Texture'AchievementIcons.Locked-512.38-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.38-Unlocked-512')
	AchievementsDisplayName(37)="Planet Of The Apes: The Musical"
	AchievementsDescription(37)="Finished POSTAL 2 or Apocalypse Weekend on Hestonworld difficulty."
	//end
		
	// They Hate Me Ending
	//ErikFOV Change: for localization
	//Achievements(38)=(APIName="NightmareEnding",DisplayName="Scientology Level OT VIII",Description="Finished A Week in Paradise on POSTAL difficulty.",LockedTex=Texture'AchievementIcons.Locked-512.39-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.39-Unlocked-512')
	Achievements(38)=(APIName="NightmareEnding",LockedTex=Texture'AchievementIcons.Locked-512.39-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.39-Unlocked-512')
	AchievementsDisplayName(38)="Scientology Level OT VIII"
	AchievementsDescription(38)="Finished A Week in Paradise on POSTAL difficulty."
	//end
		
	// RWS Staff Kills
	//ErikFOV Change: for localization
	//Achievements(39)=(APIName="RWSStaffKills",DisplayName="Fur Sure!",Description="Showed Vince and Mike J. what you thought of them.",LockedTex=Texture'AchievementIcons.Locked-512.40-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.40-Unlocked-512')
	Achievements(39)=(APIName="RWSStaffKills",LockedTex=Texture'AchievementIcons.Locked-512.40-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.40-Unlocked-512')
	AchievementsDisplayName(39)="Fur Sure!"
	AchievementsDescription(39)="Showed Vince and Mike J. what you thought of them."
	//end
		
	// Linux
	//ErikFOV Change: for localization
	//Achievements(40)=(APIName="LinuxAchievement",DisplayName="Mr. POSTAL's Penguins",Description="Played the Linux version of the game.",LockedTex=Texture'AchievementIcons.Locked-512.41-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.41-Unlocked-512',bIgnore=true)
	Achievements(40)=(APIName="LinuxAchievement",LockedTex=Texture'AchievementIcons.Locked-512.41-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.41-Unlocked-512',bIgnore=true)
	AchievementsDisplayName(40)="Mr. POSTAL's Penguins"
	AchievementsDescription(40)="Played the Linux version of the game."
	//end
		
	// Head Fetch
	//ErikFOV Change: for localization
	//Achievements(41)=(APIName="HeadFetch",DisplayName="It's not cheating, because it's YOUR dog",Description="Played 'fetch' with your dog... using a severed human head.",LockedTex=Texture'AchievementIcons.Locked-512.42-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.42-Unlocked-512')
	Achievements(41)=(APIName="HeadFetch",LockedTex=Texture'AchievementIcons.Locked-512.42-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.42-Unlocked-512')
	AchievementsDisplayName(41)="It's not cheating, because it's YOUR dog"
	AchievementsDescription(41)="Played 'fetch' with your dog... using a severed human head."
	//end
		
	// Krotchy Kill
	//ErikFOV Change: for localization
	//Achievements(42)=(APIName="KilledKrotchy",DisplayName="Where's Mr. McGibblets",Description="Gave Krotchy the bad touch.",LockedTex=Texture'AchievementIcons.Locked-512.43-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.43-Unlocked-512')
	Achievements(42)=(APIName="KilledKrotchy",LockedTex=Texture'AchievementIcons.Locked-512.43-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.43-Unlocked-512')
	AchievementsDisplayName(42)="Where's Mr. McGibblets"
	AchievementsDescription(42)="Gave Krotchy the bad touch."
	//end
		
	// Boot to the Head
	//ErikFOV Change: for localization
	//Achievements(43)=(APIName="KickSeveredHead",DisplayName="Finkle is Einhorn",Description="Gave a kickoff to a severed head.",LockedTex=Texture'AchievementIcons.Locked-512.44-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.44-Unlocked-512')
	Achievements(43)=(APIName="KickSeveredHead",LockedTex=Texture'AchievementIcons.Locked-512.44-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.44-Unlocked-512')
	AchievementsDisplayName(43)="Finkle is Einhorn"
	AchievementsDescription(43)="Gave a kickoff to a severed head."
	//end
		
	// Anger Management
	//ErikFOV Change: for localization
	//Achievements(44)=(APIName="AngerManagement",DisplayName="Anger Management with Roger Clemens",Description="Flung a sledgehammer at a fleeing bystander.",LockedTex=Texture'AchievementIcons.Locked-512.45-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.45-Unlocked-512')
	Achievements(44)=(APIName="AngerManagement",LockedTex=Texture'AchievementIcons.Locked-512.45-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.45-Unlocked-512')
	AchievementsDisplayName(44)="Anger Management with Roger Clemens"
	AchievementsDescription(44)="Flung a sledgehammer at a fleeing bystander."
	//end
		
	// Bovine Prostate Inspector
	//ErikFOV Change: for localization
	//Achievements(45)=(APIName="BovineProstateInspector",DisplayName="Shiva Blast",Description="'Lost' your sledgehammer to a cow.",LockedTex=Texture'AchievementIcons.Locked-512.46-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.46-Unlocked-512')
	Achievements(45)=(APIName="BovineProstateInspector",LockedTex=Texture'AchievementIcons.Locked-512.46-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.46-Unlocked-512')
	AchievementsDisplayName(45)="Shiva Blast"
	AchievementsDescription(45)="'Lost' your sledgehammer to a cow."
	//end
		
	// Don't Taze Me
	//ErikFOV Change: for localization
	//Achievements(46)=(APIName="DontTazeMeAchievement",DisplayName="Don't Taze Me Bro",Description="Zapped 20 innocent bystanders with the tazer while wearing the police officer's uniform.",ProgressStat=18,UnlockValue_int=20,LockedTex=Texture'AchievementIcons.Locked-512.47-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.47-Unlocked-512',bGrindy=False)
	Achievements(46)=(APIName="DontTazeMeAchievement",ProgressStat=18,UnlockValue_int=20,LockedTex=Texture'AchievementIcons.Locked-512.47-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.47-Unlocked-512',bGrindy=False)
	AchievementsDisplayName(46)="Don't Taze Me Bro"
	AchievementsDescription(46)="Zapped 20 innocent bystanders with the tazer while wearing the police officer's uniform."
	//end
		
	// Suicide Bomb
	//ErikFOV Change: for localization
	//Achievements(47)=(APIName="SuicideBomber",DisplayName="I Am Legend",Description="Committed suicide... the Taliban way.",LockedTex=Texture'AchievementIcons.Locked-512.48-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.48-Unlocked-512')
	Achievements(47)=(APIName="SuicideBomber",LockedTex=Texture'AchievementIcons.Locked-512.48-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.48-Unlocked-512')
	AchievementsDisplayName(47)="I Am Legend"
	AchievementsDescription(47)="Committed suicide... the Taliban way."
	//end
		
	// Band Camp
	//ErikFOV Change: for localization
	//Achievements(48)=(APIName="BandCamp",DisplayName="One time, at band camp...",Description="Saved the marching band from explody death.",LockedTex=Texture'AchievementIcons.Locked-512.49-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.49-Unlocked-512')
	Achievements(48)=(APIName="BandCamp",LockedTex=Texture'AchievementIcons.Locked-512.49-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.49-Unlocked-512')
	AchievementsDisplayName(48)="One time, at band camp..."
	AchievementsDescription(48)="Saved the marching band from explody death."
	//end
		
	// Newspapers
	//ErikFOV Change: for localization
	//Achievements(49)=(APIName="Newspaper",DisplayName="I should buy a boat",Description="Read the newspaper every day.",LockedTex=Texture'AchievementIcons.Locked-512.50-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.50-Unlocked-512')
	Achievements(49)=(APIName="Newspaper",LockedTex=Texture'AchievementIcons.Locked-512.50-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.50-Unlocked-512')
	AchievementsDisplayName(49)="I should buy a boat"
	AchievementsDescription(49)="Read the newspaper every day."
	//end
		
	// Wanted Level
	//ErikFOV Change: for localization
	//Achievements(50)=(APIName="WantedLevel",DisplayName="Friend of Dorothy",Description="Successfully hid from the police at max wanted level.",LockedTex=Texture'AchievementIcons.Locked-512.51-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.51-Unlocked-512')
	Achievements(50)=(APIName="WantedLevel",LockedTex=Texture'AchievementIcons.Locked-512.51-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.51-Unlocked-512')
	AchievementsDisplayName(50)="Friend of Dorothy"
	AchievementsDescription(50)="Successfully hid from the police at max wanted level."
	//end
		
	// No Way Pinko
	//ErikFOV Change: for localization
	//Achievements(51)=(APIName="NoWayPinko",DisplayName="Officer McLovin'",Description="Asked a police officer to sign your petition.",LockedTex=Texture'AchievementIcons.Locked-512.52-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.52-Unlocked-512')
	Achievements(51)=(APIName="NoWayPinko",LockedTex=Texture'AchievementIcons.Locked-512.52-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.52-Unlocked-512')
	AchievementsDisplayName(51)="Officer McLovin'"
	AchievementsDescription(51)="Asked a police officer to sign your petition."
	//end
		
	// Bribed a cop
	//ErikFOV Change: for localization
	//Achievements(52)=(APIName="CopBribery",DisplayName="Paid the Piper",Description="Successfully bribed a police officer when arrested.",LockedTex=Texture'AchievementIcons.Locked-512.53-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.53-Unlocked-512')
	Achievements(52)=(APIName="CopBribery",LockedTex=Texture'AchievementIcons.Locked-512.53-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.53-Unlocked-512')
	AchievementsDisplayName(52)="Paid the Piper"
	AchievementsDescription(52)="Successfully bribed a police officer when arrested."
	//end
		
	// Kicked a door
	//ErikFOV Change: for localization
	//Achievements(53)=(APIName="DoorKick",DisplayName="Well, aren't YOU a badass",Description="Kicked open a door.",LockedTex=Texture'AchievementIcons.Locked-512.54-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.54-Unlocked-512')
	Achievements(53)=(APIName="DoorKick",LockedTex=Texture'AchievementIcons.Locked-512.54-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.54-Unlocked-512')
	AchievementsDisplayName(53)="Well, aren't YOU a badass"
	AchievementsDescription(53)="Kicked open a door."
	//end
		
	// Pissed out someone's fire
	//ErikFOV Change: for localization
	//Achievements(54)=(APIName="FireExtinguisher",DisplayName="I don't know whether to kiss you or kill you",Description="Put out someone that's on fire.",LockedTex=Texture'AchievementIcons.Locked-512.55-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.55-Unlocked-512')
	Achievements(54)=(APIName="FireExtinguisher",LockedTex=Texture'AchievementIcons.Locked-512.55-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.55-Unlocked-512')
	AchievementsDisplayName(54)="I don't know whether to kiss you or kill you"
	AchievementsDescription(54)="Put out someone that's on fire."
	//end
		
	// Choked On Urine
	//ErikFOV Change: for localization
	//Achievements(55)=(APIName="ChokedOnPiss",DisplayName="It's sterile and I like the taste",Description="Choked on your own piss.",LockedTex=Texture'AchievementIcons.Locked-512.56-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.56-Unlocked-512',bNoComment=True)
	Achievements(55)=(APIName="ChokedOnPiss",LockedTex=Texture'AchievementIcons.Locked-512.56-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.56-Unlocked-512',bNoComment=True)
	AchievementsDisplayName(55)="It's sterile and I like the taste"
	AchievementsDescription(55)="Choked on your own piss."
	//end
		
	// Kill Petition Refuser
	//ErikFOV Change: for localization
	//Achievements(56)=(APIName="PetitionKill",DisplayName="It's OK, we got Greenlit anyway",Description="Killed someone who refused to sign the petition.",LockedTex=Texture'AchievementIcons.Locked-512.57-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.57-Unlocked-512')
	Achievements(56)=(APIName="PetitionKill",LockedTex=Texture'AchievementIcons.Locked-512.57-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.57-Unlocked-512')
	AchievementsDisplayName(56)="It's OK, we got Greenlit anyway"
	AchievementsDescription(56)="Killed someone who refused to sign the petition."
	//end
		
	// Fabulous
	//ErikFOV Change: for localization
	//Achievements(57)=(APIName="Fabulous",DisplayName="FAB-U-LOUS",Description="Wore all three outfits.",LockedTex=Texture'AchievementIcons.Locked-512.58-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.58-Unlocked-512')
	Achievements(57)=(APIName="Fabulous",LockedTex=Texture'AchievementIcons.Locked-512.58-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.58-Unlocked-512')
	AchievementsDisplayName(57)="FAB-U-LOUS"
	AchievementsDescription(57)="Wore all three outfits."
	//end
		
	// Reverse Psychology
	//ErikFOV Change: for localization
	//Achievements(58)=(APIName="ReversePsychology",DisplayName="I don't need virgins for this",Description="Suicide-bombed a Taliban member.",LockedTex=Texture'AchievementIcons.Locked-512.59-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.59-Unlocked-512')
	Achievements(58)=(APIName="ReversePsychology",LockedTex=Texture'AchievementIcons.Locked-512.59-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.59-Unlocked-512')
	AchievementsDisplayName(58)="I don't need virgins for this"
	AchievementsDescription(58)="Suicide-bombed a Taliban member."
	//end
		
	// Arod Who?
	//ErikFOV Change: for localization
	//Achievements(59)=(APIName="ArodWho",DisplayName="A-Rod Who?",Description="Whacked a severed head 50 meters or more with a shovel.",LockedTex=Texture'AchievementIcons.Locked-512.60-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.60-Unlocked-512')
	Achievements(59)=(APIName="ArodWho",LockedTex=Texture'AchievementIcons.Locked-512.60-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.60-Unlocked-512')
	AchievementsDisplayName(59)="A-Rod Who?"
	AchievementsDescription(59)="Whacked a severed head 50 meters or more with a shovel."
	//end
		
	// Stumped
	//ErikFOV Change: for localization
	//Achievements(60)=(APIName="Stumped",DisplayName="Door Mat",Description="Severed all of somebody's limbs without killing them.",LockedTex=Texture'AchievementIcons.Locked-512.61-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.61-Unlocked-512')
	Achievements(60)=(APIName="Stumped",LockedTex=Texture'AchievementIcons.Locked-512.61-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.61-Unlocked-512')
	AchievementsDisplayName(60)="Door Mat"
	AchievementsDescription(60)="Severed all of somebody's limbs without killing them."
	//end
		
	// Boot to the Head
	//ErikFOV Change: for localization
	//Achievements(61)=(APIName="BootToTheHead",DisplayName="Chuck Norris'd!",Description="Killed someone with a jump kick to the head.",LockedTex=Texture'AchievementIcons.Locked-512.62-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.62-Unlocked-512')
	Achievements(61)=(APIName="BootToTheHead",LockedTex=Texture'AchievementIcons.Locked-512.62-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.62-Unlocked-512')
	AchievementsDisplayName(61)="Chuck Norris'd!"
	AchievementsDescription(61)="Killed someone with a jump kick to the head."
	//end
		
	// Secret Bank Exit
	//ErikFOV Change: for localization
	//Achievements(62)=(APIName="SecretBankExit",DisplayName="There's always money in the banana stand",Description="Found the secret bank exit on Monday.",bHidden=True,LockedTex=Texture'AchievementIcons.Locked-512.63-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.63-Unlocked-512')
	Achievements(62)=(APIName="SecretBankExit",bHidden=True,LockedTex=Texture'AchievementIcons.Locked-512.63-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.63-Unlocked-512')
	AchievementsDisplayName(62)="There's always money in the banana stand"
	AchievementsDescription(62)="Found the secret bank exit on Monday."
	//end
		
	// Russian Postal
	//ErikFOV Change: for localization
	//Achievements(63)=(APIName="RussianPostal",DisplayName="Screw that game!",Description="Found the hidden copy of POSTAL III and pissed on it.",bHidden=True,LockedTex=Texture'AchievementIcons.Locked-512.64-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.64-Unlocked-512')
	Achievements(63)=(APIName="RussianPostal",bHidden=True,LockedTex=Texture'AchievementIcons.Locked-512.64-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.64-Unlocked-512')
	AchievementsDisplayName(63)="Screw that game!"
	AchievementsDescription(63)="Found the hidden copy of POSTAL III and pissed on it."
	//end
		
	// Found Tora Bora
	//ErikFOV Change: for localization
	//Achievements(64)=(APIName="ToraBora",DisplayName="Found 'em faster than GWB",Description="Discovered the hidden Taliban base.",bHidden=True,LockedTex=Texture'AchievementIcons.Locked-512.65-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.65-Unlocked-512')
	Achievements(64)=(APIName="ToraBora",bHidden=True,LockedTex=Texture'AchievementIcons.Locked-512.65-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.65-Unlocked-512')
	AchievementsDisplayName(64)="Found 'em faster than GWB"
	AchievementsDescription(64)="Discovered the hidden Taliban base."
	//end
		
	// Troll Toll
	//ErikFOV Change: for localization
	//Achievements(65)=(APIName="TrollToll",DisplayName="Gotta pay the Troll Toll",Description="Found one of the hidden underground sewers.",bHidden=True,LockedTex=Texture'AchievementIcons.Locked-512.66-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.66-Unlocked-512')
	Achievements(65)=(APIName="TrollToll",bHidden=True,LockedTex=Texture'AchievementIcons.Locked-512.66-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.66-Unlocked-512')
	AchievementsDisplayName(65)="Gotta pay the Troll Toll"
	AchievementsDescription(65)="Found one of the hidden underground sewers."
	//end
		
	// Monster Kill
	//ErikFOV Change: for localization
	//Achievements(66)=(APIName="MonsterKill",DisplayName="John Rambo'd!",Description="Made a very long killing spree.",bHidden=True,LockedTex=Texture'AchievementIcons.Locked-512.67-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.67-Unlocked-512')
	Achievements(66)=(APIName="MonsterKill",bHidden=True,LockedTex=Texture'AchievementIcons.Locked-512.67-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.67-Unlocked-512')
	AchievementsDisplayName(66)="John Rambo'd!"
	AchievementsDescription(66)="Made a very long killing spree."
	//end
		
	// Gary Vs Krotchy
	//ErikFOV Change: for localization
	//Achievements(67)=(APIName="GaryVsKrotchy",DisplayName="Gary vs. a Giant Penis",Description="Discovered the Gary vs. Krotchy arena during the Apocalypse.",bHidden=True,LockedTex=Texture'AchievementIcons.Locked-512.68-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.68-Unlocked-512')
	Achievements(67)=(APIName="GaryVsKrotchy",bHidden=True,LockedTex=Texture'AchievementIcons.Locked-512.68-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.68-Unlocked-512')
	AchievementsDisplayName(67)="Gary vs. a Giant Penis"
	AchievementsDescription(67)="Discovered the Gary vs. Krotchy arena during the Apocalypse."
	//end
		
	// NPC Postal
	//ErikFOV Change: for localization
	//Achievements(68)=(APIName="NPCsGoPostal",DisplayName="You are not alone",Description="Observed an NPC going POSTAL!",bHidden=True,LockedTex=Texture'AchievementIcons.Locked-512.69-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.69-Unlocked-512')
	Achievements(68)=(APIName="NPCsGoPostal",bHidden=True,LockedTex=Texture'AchievementIcons.Locked-512.69-Locked-512',UnlockedTex=Texture'AchievementIcons.Unlocked-512.69-Unlocked-512')
	AchievementsDisplayName(68)="You are not alone"
	AchievementsDescription(68)="Observed an NPC going POSTAL!"
	//end
		
	// Nutshots
	//ErikFOV Change: for localization
	//Achievements(69)=(APIName="PLNutshotAchievement",DisplayName="RAFIBOMB!!!",Description="Kicked 10 people in the balls.",UnlockedTex=Texture'AchievementIcons.Unlocked-512.88-Unlocked',ProgressStat=22,UnlockValue_int=10,bGrindy=false,LockedTex=Texture'AchievementIcons.Locked-512.88-Locked')
	Achievements(69)=(APIName="PLNutshotAchievement",UnlockedTex=Texture'AchievementIcons.Unlocked-512.88-Unlocked',ProgressStat=22,UnlockValue_int=10,bGrindy=false,LockedTex=Texture'AchievementIcons.Locked-512.88-Locked')
	AchievementsDisplayName(69)="RAFIBOMB!!!"
	AchievementsDescription(69)="Kicked 10 people in the balls."
	//end
		
	// June 2016 Mall
	//ErikFOV Change: for localization
	//Achievements(70)=(APIName="June2016Mall",DisplayName="I'm not even supposed to be here today!",Description="Waited 13 real world years to see an in-game Easter egg. Thanks for sticking with us!",bHidden=True,LockedTex=Texture'AchievementIcons.Locked-512.89-Locked',UnlockedTex=Texture'AchievementIcons.Unlocked-512.89-Unlocked')
	Achievements(70)=(APIName="June2016Mall",bHidden=True,LockedTex=Texture'AchievementIcons.Locked-512.89-Locked',UnlockedTex=Texture'AchievementIcons.Unlocked-512.89-Unlocked')
	AchievementsDisplayName(70)="I'm not even supposed to be here today!"
	AchievementsDescription(70)="Waited 13 real world years to see an in-game Easter egg. Thanks for sticking with us!"
	//end
		
	HiddenAchievementString="????????????????????"
	
	bDisplayAchievements=True
}