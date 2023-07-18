///////////////////////////////////////////////////////////////////////////////
// Chameleon.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This class creates a random distribution of character attributes (skins,
// meshes, heads, dialog, etc.) for all the characters in a level.
//
// History:
//	08/31/02 MJR	Started it.
//
///////////////////////////////////////////////////////////////////////////////
//
// All character skins (textures) must use a special naming convention as
// shown in this example:
//
//		MW__025__Avg_M_SS_Pants
//
// There are three sections, each separated by double underscores.
//
// First is a description of the skin so we can pick a matching head, use
// the correct voice, and so on.  The description consists of two letters
// giving the gender and race:
//
//		Gender:		M - male
//					F - female
//
//		Race:		W - white	
//					M - mexican
//					B - black
//					A - asian
//					F - fanatic
//
// Next is a unique 3-digit number with leading zeros.  This number must be
// unique across ALL character skins.  Gaps in the numbers are not a problem
// although the maximum number should be kept to a reasonable value (we
// currently assume a range of 000 to 499).
//
// Last is the name of the mesh the texture is designed to use.  The mesh
// is assumed to be located in one of the packages listed in the pawn's
// ChameleonMeshPkgs array.
//
///////////////////////////////////////////////////////////////////////////////
class Chameleon extends Info
	config(system);


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var config bool				bValidate;				// Set this to 1 in .ini file to validate all skins and meshes

var() Mesh					DefaultMesh;			// Default mesh in case something goes wrong

var int						SkinRefCounts[999];		// Reference counts (skin's unique number is used as index)
var name					SkinNames[999];			// Used to report usage statistics

var ChameleonTuner.SPeopleBalance	CurrentBalance;	// Current balance of people in this level
var ChameleonTuner.SPeopleBalance	DesiredBalance;	// Desired balance of people in this level
var float					TotalPeople;			// Total people in this level (float makes for less casting)

var bool					bDidSetupBalance;		// Whether balance was already setup

var int						RandSeed;

// Some consts indicating positions of various elements in the skin name
const SKIN_GENDER			= 0;
const SKIN_RACE				= 1;
const SKIN_SEPARATOR1		= 2;
const SKIN_UNIQUE			= 4;
const SKIN_SEPARATOR2		= 7;
const SKIN_MESH				= 9;

///////////////////////////////////////////////////////////////////////////////
// Display usage statistics in log
///////////////////////////////////////////////////////////////////////////////
function LogUsage()
	{
	local int i;
	local int count;

	Log("=========================================================");
	Log("Chameleon Usage Statistics");
	Log("=========================================================");
	Log("");
	Log("Skin usage");
	for (i = 0; i < ArrayCount(SkinRefCounts); i++)
		{
		if (SkinRefCounts[i] > 0)
			if (SkinNames[i] == '')
				Log("   "$SkinRefCounts[i]$"   (preset)");
			else
				Log("   "$SkinRefCounts[i]$"   "$SkinNames[i]);
		count += SkinRefCounts[i];
		}
	Log("Sum of all ref counts = "$count);
	Log("");
	Log("                       Count    Actual   Desired");
	Log("Total.................."$int(TotalPeople));
	Log("");
	Log("Gender");
	Log("  Male................."$CurrentBalance.Gender.Males$"       "$float(CurrentBalance.Gender.Males) / TotalPeople$"     "$float(DesiredBalance.Gender.Males) / 100);
	Log("    Race");
	Log("      White............"$CurrentBalance.RacialMale.Whites$"       "$float(CurrentBalance.RacialMale.Whites) / CurrentBalance.Gender.Males$"     "$float(DesiredBalance.RacialMale.Whites) / 100);
	Log("      Black............"$CurrentBalance.RacialMale.Blacks$"       "$float(CurrentBalance.RacialMale.Blacks) / CurrentBalance.Gender.Males$"     "$float(DesiredBalance.RacialMale.Blacks) / 100);
	Log("      Mexican.........."$CurrentBalance.RacialMale.Mexicans$"       "$float(CurrentBalance.RacialMale.Mexicans) / CurrentBalance.Gender.Males$"     "$float(DesiredBalance.RacialMale.Mexicans) / 100);
	Log("      Other............"$CurrentBalance.Gender.Males - CurrentBalance.RacialMale.Whites - CurrentBalance.RacialMale.Blacks - CurrentBalance.RacialMale.Mexicans);
	Log("    Lifestyle Choice");
	Log("      Straight........."$CurrentBalance.Gender.Males - CurrentBalance.OverallMaleGay);
	Log("      Gay.............."$CurrentBalance.OverallMaleGay);
	Log("");
	Log("  Female..............."$CurrentBalance.Gender.Females$"       "$float(CurrentBalance.Gender.Females) / TotalPeople$"     "$float(DesiredBalance.Gender.Females) / 100);
	Log("    Race");
	Log("      White............"$CurrentBalance.RacialFemale.Whites$"       "$float(CurrentBalance.RacialFemale.Whites) / CurrentBalance.Gender.Females$"     "$float(DesiredBalance.RacialFemale.Whites) / 100);
	Log("      Black............"$CurrentBalance.RacialFemale.Blacks$"       "$float(CurrentBalance.RacialFemale.Blacks) / CurrentBalance.Gender.Females$"     "$float(DesiredBalance.RacialFemale.Blacks) / 100);
	Log("      Mexican.........."$CurrentBalance.RacialFemale.Mexicans$"       "$float(CurrentBalance.RacialFemale.Mexicans) / CurrentBalance.Gender.Females$"     "$float(DesiredBalance.RacialFemale.Mexicans) / 100);
	Log("      Other............"$CurrentBalance.Gender.Females - CurrentBalance.RacialFemale.Whites - CurrentBalance.RacialFemale.Blacks - CurrentBalance.RacialFemale.Mexicans);
	Log("    Type of Lesbian");
	Log("      Butch............"$CurrentBalance.Gender.Females - CurrentBalance.OverallFemaleFem);
	Log("      Not.............."$CurrentBalance.OverallFemaleFem);
	Log("");
	Log("Body Type");
	Log("  Average.............."$int(TotalPeople) - CurrentBalance.OverallFat - CurrentBalance.OverallTall);
	Log("  Fat.................."$CurrentBalance.OverallFat$"       "$float(CurrentBalance.OverallFat) / TotalPeople$"     "$float(DesiredBalance.OverallFat) / 100);
	Log("  Tall................."$CurrentBalance.OverallTall$"       "$float(CurrentBalance.OverallTall) / TotalPeople$"     "$float(DesiredBalance.OverallTall) / 100);
	Log("");
	}

///////////////////////////////////////////////////////////////////////////////
// Register a skin that is being used by a non-chameleon pawn.  This allows
// the skin to be included in the usage statistics, which helps reduce the
// number of repeated skins in a level.
///////////////////////////////////////////////////////////////////////////////
function Register(P2MocapPawn P)
	{
	local int UniqueID;
	local FPSPawn.EGender Gender;
	local FPSPawn.ERace Race;
	local FPSPawn.EBody Body;
	local String MeshName;
	local String SkinName;

	// If skin fits the naming convention then increment its reference count.
	SkinName = GetItemName(String(P.Skins[0]));
	if (ParseSkin(SkinName, UniqueID, Gender, Race, Body, MeshName))
	{
		// MyBody, etc. not always set properly on spawned-in pawns. Set them now.
		P.MyGender = Gender;
		P.MyRace = Race;
		P.MyBody = Body;
		
		// Check for fat
		if (Left(MyGetItemName(String(P.Mesh)),3) ~= "Fat")
			P.MyBody = Body_Fat;
		
		SkinRefCounts[UniqueID]++;
	}

	// Since we decided that chameleons that only support one gender should
	// not count towards the overall balance, it seemed to follow that we
	// shouldn't count "hardwired" pawns, either, so this call was removed.
	//UpdateBalance(P);
	}

///////////////////////////////////////////////////////////////////////////////
// Pick a random appearance for this pawn's body.  If the pawn's HeadSkin is
// None then a random head is also picked -- otherwise, the existing HeadSkin
// preserved.
//
// Gender can be requested but if there is no matching skin then it will be
// ignored.
//
// The overall balance of gender, race, and so on are controlled by the
// settings in a ChameleonTuner object placed in the level.
///////////////////////////////////////////////////////////////////////////////
function Pick(P2MocapPawn P, FPSPawn.EGender ReqGender)
	{
	local bool bSuccess;
	local FPSPawn.ERace ReqRace;
	local FPSPawn.EBody ReqBody;
	local ChameleonTuner.SRacialBalance CurrentRacial;
	local ChameleonTuner.SRacialBalance DesiredRacial;
	local float TotalGender;
	local float WhiteDiff;
	local float BlackDiff;
	local float MexicanDiff;
	local float MaleDiff;
	local float FemaleDiff;
	local ChamelHead heads;

	heads = P2GameInfo(Level.Game).GetChamelHead();

	if (!bDidSetupBalance)
		SetupBalance();

	// Check if this set of chameleon skins supports more than one gender.
	if (P.ChameleonOnlyHasGender == Gender_Any)
		{
		// If no specific gender was requested then pick the one that's furthest from its desired percentage.
		if (ReqGender == Gender_Any)
			{
			// Calculate diffs for male and female (values range from -1 (too few) to +1 (too many) and 0 is "just right").
			if (TotalPeople > 0)
				{
				MaleDiff = float(CurrentBalance.Gender.Males) / TotalPeople - float(DesiredBalance.Gender.Males) / 100;
				FemaleDiff = float(CurrentBalance.Gender.Females) / TotalPeople - float(DesiredBalance.Gender.Females) / 100;
				}
			else
				{
				MaleDiff = -1;
				FemaleDiff = -1;
				}

			// FIX: This should work pretty well, but the original idea was to calculate the skew from the
			// diff values so the more we need a particular gender, the more likely it is we'd get it.
			if (MaleDiff < FemaleDiff)
				ReqGender = RandGender(Gender_Male, 0.90);
			else
				ReqGender = RandGender(Gender_Female, 0.90);
			}
		}
	else
		{
		// No choice on gender -- use the only one it supports
		ReqGender = P.ChameleonOnlyHasGender;
		}

	// Get racial stats for male or female
	if (ReqGender == Gender_Male)
		{
		CurrentRacial = CurrentBalance.RacialMale;
		DesiredRacial = DesiredBalance.RacialMale;
		TotalGender = CurrentBalance.Gender.Males;
		}
	else
		{
		CurrentRacial = CurrentBalance.RacialFemale;
		DesiredRacial = DesiredBalance.RacialFemale;
		TotalGender = CurrentBalance.Gender.Females;
		}

	// Calculate diffs for male and female (values range from -1 (too few) to +1 (too many) and 0 is "just right").
	// Then pick the race that's furthest from it's desired percentage.
	if(TotalGender > 0)
	{
		WhiteDiff = float(CurrentRacial.Whites) / TotalGender - float(DesiredRacial.Whites) / 100.0;
		BlackDiff = float(CurrentRacial.Blacks) / TotalGender - float(DesiredRacial.Blacks)/ 100.0;
		MexicanDiff = float(CurrentRacial.Mexicans) / TotalGender - float(DesiredRacial.Mexicans) / 100.0;
	}
	else
	{
		WhiteDiff = -1;
		BlackDiff = -1;
		MexicanDiff = -1;
	}

	if (WhiteDiff < BlackDiff)
		{
		if (WhiteDiff < MexicanDiff)
			ReqRace = Race_White;
		else
			ReqRace = Race_Mexican;
		}
	else
		{
		if (BlackDiff < MexicanDiff)
			ReqRace = Race_Black;
		else
			ReqRace = Race_Mexican;
		}

	// If we're under the fatness quota then randomly choose the fat body once in a while
	ReqBody = Body_Avg;

	if (TotalPeople > 0
		&& (float(CurrentBalance.OverallFat) / TotalPeople) < (float(DesiredBalance.OverallFat) / 100.0))
		{
		if (MyRand() < float(DesiredBalance.OverallFat) / 100.0)
			ReqBody = Body_Fat;
		}
		
	// Randomly pick tall people
	if (ReqBody == Body_Avg
		&& TotalPeople > 0
		&& (float(CurrentBalance.OverallTall) / TotalPeople) < (float(DesiredBalance.OverallTall) / 100.0))
		{
		if (MyRand() < float(DesiredBalance.OverallTall) / 100.0)
			ReqBody = Body_Tall;
		}
		
	// Try to find what we want.  Note that all combos are not available for
	// all characters since available skins vary for each character.
	bSuccess = TryPick(P, heads, ReqGender, ReqRace, ReqBody, bValidate);
	if (!bSuccess)
		{
		// If we wanted fat, try it again with avg.  If we wanted avg we DON'T try
		// it with fat because we don't want to end up with too many fat people.
		if (ReqBody == Body_Fat || ReqBody == Body_Tall)
			bSuccess = TryPick(P, heads, ReqGender, ReqRace, Body_Avg, false);

		if (!bSuccess)
			{
			// Try dropping the race requirement
			bSuccess = TryPick(P, heads, ReqGender, Race_Any, Body_Avg, false);
			if (!bSuccess)
				{
				// Try with no requirements (this REALLY ought to work!)
				bSuccess = TryPick(P, heads, Gender_Any, Race_Any, Body_Avg, false);
				}
			}
		}

	if (!bSuccess)
		{
		Warn("No matching or valid skins were found, using default mesh and no skin for "$P);
		P.SetMySkin(None);
		P.SetMyMesh(DefaultMesh);
		}

	// Randomly set male gayness and female femininity (but never exceed the specified quotas)
	if(TotalPeople > 0)
	{
		if (P.bIsFemale)
			{
			if (float(CurrentBalance.OverallFemaleFem) / TotalPeople < float(DesiredBalance.OverallFemaleFem) / 100.0)
				if (MyRand() < float(DesiredBalance.OverallFemaleFem) / 100.0)
					P.bIsFeminine = true;
			}
		else
			{
			if (float(CurrentBalance.OverallMaleGay) / TotalPeople < float(DesiredBalance.OverallMaleGay) / 100.0)
				if (MyRand() < float(DesiredBalance.OverallMaleGay) / 100.0)
				{
					P.bIsFeminine = true;
					P.bIsGay = true;
				}
			}
	}

	// Only include pawn in the balance statistics if it offered a choice of gender.
	// We have several types of characters that are only males and when large numbers
	// of those were used in a level, the chameleon code would try to compensate by
	// spawning mostly female characters.  While this would lead to an overall balance
	// between male and female, it really wasn't very good because it meant a lot of
	// male skins were being ignored, so we ended up with less variety overall.
	// The solution is not to count pawns that don't have a gender choice in the
	// statistics, thereby resulting in a good overall balance.
	if (P.ChameleonOnlyHasGender == Gender_Any)
		UpdateBalance(P);
	}

///////////////////////////////////////////////////////////////////////////////
// Try to find a random appearance matching the specified requirements.
//
// This looks through all the chameleon skins available to the pawn and uses
// the one that's been used the least in the current level.  The pawn's skin
// and mesh are updated, as are various attributes such as gender and race.
///////////////////////////////////////////////////////////////////////////////
function bool TryPick(P2MocapPawn P, ChamelHead heads, FPSPawn.EGender ReqGender, FPSPawn.ERace ReqRace, FPSPawn.EBody ReqBody, bool bDoValidation)
	{
	local int skin;
	local int UniqueID;
	local FPSPawn.EGender Gender;
	local FPSPawn.ERace Race;
	local FPSPawn.EBody Body;
	local String MeshName;
	local int LowestRefCount;
	local int LowestSkin;
	local int LowestUniqueID;
	local FPSPawn.EGender LowestGender;
	local FPSPawn.ERace LowestRace;
	local FPSPawn.EBody LowestBody;
	local String LowestMeshName;
	local bool bTryAgain;
	local bool bSuccess;
	local FPSPawn.EGender GenderTest;
	local Material FoundHeadSkin;
	local Mesh FoundHeadMesh;
	local int FoundHeadID;
	local Material LowestHeadSkin;
	local Mesh LowestHeadMesh;
	local int LowestHeadID;
	local name SkinName;

	if (bDoValidation)
		Log(self @ "Validation start");

	// Make sure at least one skin is available
	if (P.ChameleonSkins.length > 0)
		{
		
		do {
			bTryAgain = false;

			// Find the least-used skin
			LowestSkin = -1;
			LowestRefCount = 10000;
			for (skin = 0; skin < P.ChameleonSkins.Length && P.ChameleonSkins[skin] != 'end'; skin++)
				{
				if (P.ChameleonSkins[skin] != 'None')
					{
					if (ParseSkin(String(P.ChameleonSkins[skin]), UniqueID, Gender, Race, Body, MeshName))
						{
						if (bDoValidation)
							{
							// Try to load skin and mesh (this must NEVER be enabled for released product!)
							if (DynamicLoadObject(String(P.ChameleonSkins[skin]), class'Material', true) == None)
								Warn("Couldn't find skin '"$P.ChameleonSkins[skin]$"'");
							GetMesh(P, MeshName);
							}

						if ((ReqGender == Gender_Any || ReqGender == Gender) &&
							(ReqRace == Race_Any || ReqRace == Race) &&
							(ReqBody == Body_Any || ReqBody == Body))
							{
							if (SkinRefCounts[UniqueID] < LowestRefCount)
								{
								// If headskin is already assigned then we assume it's okay, otherwise we
								// try to find a matching head for this body.
								if ((P.HeadSkin != None) ||
									heads.Find(P, Gender, Race, Body, FoundHeadSkin, FoundHeadMesh, FoundHeadID))
									{
									LowestRefCount = SkinRefCounts[UniqueID];
									LowestSkin = skin;
									LowestUniqueID = UniqueID;
									LowestGender = Gender;
									LowestRace = Race;
									LowestBody = Body;
									LowestMeshName = MeshName;
									if (P.HeadSkin != None)
										{
										LowestHeadSkin = P.HeadSkin;
										LowestHeadMesh = P.HeadMesh;
										}
									else
										{
										LowestHeadSkin = FoundHeadSkin;
										LowestHeadMesh = FoundHeadMesh;
										}
									LowestHeadID = FoundHeadID;
									}
								}
							}
						}
					else
						Warn("Couldn't parse info from skin "$P.ChameleonSkins[skin]$" for "$P);
					}
				}

			// Check if we found one
			if (LowestSkin >= 0)
				{
				// Try to use skin.  If it works then inc the ref count, otherwise set it
				// so this skin won't get picked again and then try to find another one.
				SkinName = P.ChameleonSkins[LowestSkin];
				if (UseSkin(P, String(SkinName), LowestGender, LowestRace, LowestBody, LowestMeshName))
					{
					SkinRefCounts[LowestUniqueID]++;
					SkinNames[LowestUniqueID] = SkinName;

					// Assign the head
					heads.Assign(P, LowestHeadSkin, LowestHeadMesh, LowestHeadID);

					bSuccess = true;
					}
				else
					{
					Warn("Couldn't use skin, checking for another one...");
					SkinRefCounts[LowestUniqueID] = 10000;
					bTryAgain = true;
					}
				}

			} until (bTryAgain == false);
		}
	else
		{
		Warn("No ChameleonSkins defined for "$P);
		}

	if (bDoValidation)
		Log(self @ "Validation end");

	return bSuccess;
	}

///////////////////////////////////////////////////////////////////////////////
// This is called when the user changes a pawns skin in the editor.
// This function must be static because there are no instances of this class
// when we're running in the editor.
///////////////////////////////////////////////////////////////////////////////
static function UseCurrentSkin(P2MocapPawn P)
	{
	local int UniqueID;
	local FPSPawn.EGender Gender;
	local FPSPawn.ERace Race;
	local FPSPawn.EBody Body;
	local String MeshName;

	// Parse the name and try to use it.  If this fails we can only assume
	// (or hope) that the user is manually setting up all the other stuff
	// in the pawn, like the mesh and various attributes.
	if (ParseSkin(String(P.Skins[0]), UniqueID, Gender, Race, Body, MeshName))
		UseSkin(P, String(P.Skins[0]), Gender, Race, Body, MeshName);
	}

///////////////////////////////////////////////////////////////////////////////
// Use the specified skin.  This changes the pawn's mesh and the vars
// describing its body, gender and race.
///////////////////////////////////////////////////////////////////////////////
static function bool UseSkin(P2MocapPawn P, String SkinName, FPSPawn.EGender Gender, FPSPawn.ERace Race, FPSPawn.EBody Body, String MeshName)
	{
	local bool bSuccess;
	local Material TheSkin;
	local Mesh TheMesh;

	// Try to load skin
	TheSkin = Material(DynamicLoadObject(SkinName, class'Material'));
	if (TheSkin != None)
		{
		// Try to load mesh
		TheMesh = GetMesh(P, MeshName);
		if (TheMesh != None)
			{
			// Assign mesh and skin
			P.SetMySkin(TheSkin);
			P.SetMyMesh(TheMesh);

			// Set body type
			P.MyBody = Body;
			P.bIsFat = false;
			P.bIsTall = false;
			if (Body == Body_Fat)
				P.bIsFat = true;
			else if (Body == Body_Tall)
				P.bIsTall = true;

			// Set gender
			P.MyGender = Gender;
			P.bIsFemale = false;
			if (Gender == Gender_Female)
				P.bIsFemale = true;

			// Set race
			P.MyRace = Race;
			P.bIsBlack = false;
			P.bIsMexican = false;
			P.bIsAsian = false;
			P.bIsHindu = false;
			P.bIsFanatic = false;
			switch Race
				{
				case Race_Black:
					P.bIsBlack = true;
					break;
				case Race_Mexican:
					P.bIsMexican = true;
					break;
				case Race_Asian:
					P.bIsAsian = true;
					break;
				case Race_Hindu:
					P.bIsHindu = true;
					break;
				case Race_Fanatic:
					P.bIsFanatic = true;
					break;
				}

			// Everything worked
			bSuccess = true;
			}
		}

	return bSuccess;
	}

///////////////////////////////////////////////////////////////////////////////
// Get specified mesh.
// This tries to load the mesh from any of the packages specified by
// the pawn's ChameleonMeshPkgs array.
///////////////////////////////////////////////////////////////////////////////
static function Mesh GetMesh(P2MocapPawn P, String MeshName)
	{
	local int meshpkg;
	local Mesh NewMesh;

	for (meshpkg = 0; meshpkg < P.ChameleonMeshPkgs.length; meshpkg++)
		{
		NewMesh = Mesh(DynamicLoadObject(P.ChameleonMeshPkgs[meshpkg]$"."$MeshName, class'Mesh', true));
		if (NewMesh != None)
			break;
		}

	if (NewMesh == None)
		Warn("Couldn't find mesh '"$MeshName$"' in any ChameleonMeshPkgs for "$P);

	return NewMesh;
	}

///////////////////////////////////////////////////////////////////////////////
// Setup the balance.  If the level contains a tuner then we use it's
// balance settings, otherwise we use the defaults.
///////////////////////////////////////////////////////////////////////////////
function SetupBalance()
	{
	local ChameleonTuner tuner;

	foreach AllActors(class'ChameleonTuner', tuner)
		{
		if (bDidSetupBalance)
			Warn("Found multiple ChameleonTuner's in the current level -- there must only be one!");

		// Copy balance settings from tuner
		DesiredBalance = tuner.Balance;
		bDidSetupBalance = true;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Update statistics about which people are in this map
///////////////////////////////////////////////////////////////////////////////
function UpdateBalance(P2MocapPawn P)
	{
	if (P.bIsFemale)
		{
		CurrentBalance.Gender.Females++;
		if (P.bIsBlack)
			CurrentBalance.RacialFemale.Blacks++;
		else if (P.bIsMexican)
			CurrentBalance.RacialFemale.Mexicans++;
		else if (!P.bIsAsian && !P.bIsHindu && !P.bIsFanatic)
			CurrentBalance.RacialFemale.Whites++;

		if (P.bIsFeminine)
			CurrentBalance.OverallFemaleFem++;
		}
	else
		{
		CurrentBalance.Gender.Males++;
		if (P.bIsBlack)
			CurrentBalance.RacialMale.Blacks++;
		else if (P.bIsMexican)
			CurrentBalance.RacialMale.Mexicans++;
		else if (!P.bIsAsian && !P.bIsHindu && !P.bIsFanatic)
			CurrentBalance.RacialMale.Whites++;

		if (P.bIsFeminine)
			CurrentBalance.OverallMaleGay++;
		}

	if (P.bIsFat)
		CurrentBalance.OverallFat++;
	if (P.bIsTall)
		CurrentBalance.OverallTall++;

	TotalPeople += 1.0;
	}

///////////////////////////////////////////////////////////////////////////////
// Pick random gender but skew it towards the specified gender by the
// specified factor (0.0 would never pick it, 1.0 would always pick it).
///////////////////////////////////////////////////////////////////////////////
function FPSPawn.EGender RandGender(FPSPawn.EGender PrefGender, float Skew)
	{
	if (MyRand() < Skew)
		return PrefGender;
	else
		{
		if (PrefGender == Gender_Male)
			return Gender_Female;
		else
			return Gender_Male;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Parse various info out of the skin name.
// Returns true if name was parsed properly, false otherwise.
///////////////////////////////////////////////////////////////////////////////
static function bool ParseSkin(String SkinName, out int UniqueID, out FPSPawn.EGender Gender, out FPSPawn.ERace Race, out FPSPawn.EBody Body, out String MeshName)
	{
	local int Digit;
	local String GenderStr;
	local String RaceStr;

	// Strip down to just the item name
	SkinName = MyGetItemName(SkinName);

	// Check for underscores in the correct positions
	if (Mid(SkinName, SKIN_SEPARATOR1, 2) != "__" || Mid(SkinName, SKIN_SEPARATOR2, 2) != "__")
		return false;
	
	// Get skin index (3 digits)
	Digit = Asc(Mid(SkinName, SKIN_UNIQUE+0, 1)) - 48;
	if (Digit < 0 || Digit > 10)
		return false;
	UniqueID = Digit * 100;
	Digit = Asc(Mid(SkinName, SKIN_UNIQUE+1, 1)) - 48;
	if (Digit < 0 || Digit > 10)
		return false;
	UniqueID = UniqueID + Digit * 10;
	Digit = Asc(Mid(SkinName, SKIN_UNIQUE+2, 1)) - 48;
	if (Digit < 0 || Digit > 10)
		return false;
	UniqueID = UniqueID + Digit;

	// Get gender
	GenderStr = Mid(SkinName, SKIN_GENDER, 1);
	if (GenderStr ~= "M")
		Gender = Gender_Male;
	else if (GenderStr ~= "F")
		Gender = Gender_Female;
	else
		return false;

	// Get race
	RaceStr = Mid(SkinName, SKIN_RACE, 1);
	switch RaceStr
		{
		case "W":
		case "w":
			Race = Race_White;
			break;
		case "B":
		case "b":
			Race = Race_Black;
			break;
		case "M":
		case "m":
			Race = Race_Mexican;
			break;
		case "A":
		case "a":
			Race = Race_Asian;
			break;
		case "H":
		case "h":
			Race = Race_Hindu;
			break;
		case "F":
		case "f":
			Race = Race_Fanatic;
			break;
		default:
			return false;
		}

	// Get mesh name
	MeshName = Mid(SkinName, SKIN_MESH, 100);

	// Get body type
	Body = Body_Avg;
	if (Left(MeshName, 3) ~= "Fat")
		Body = Body_Fat;
	else if (Left(MeshName, 4) ~= "Tall")
		Body = Body_Tall;
		
	return true;
	}

///////////////////////////////////////////////////////////////////////////////
// Get item name from the full name (strips away package and groups names).
// The only difference between this version and the one in Actor.uc is that
// this version is static, which is what the one in Actor should have been.
///////////////////////////////////////////////////////////////////////////////
static function String MyGetItemName(String FullName)
	{
	local int pos;

	pos = InStr(FullName, ".");
	While ( pos != -1 )
		{
		FullName = Right(FullName, Len(FullName) - pos - 1);
		pos = InStr(FullName, ".");
		}
	return FullName;
	}

///////////////////////////////////////////////////////////////////////////////
// Split full name into package name and item name.  Package name may also
// contain an optional group name.
///////////////////////////////////////////////////////////////////////////////
static function SplitName(string FullName, String PackageName, String ItemName)
	{
	local int pos;

	ItemName = FullName;
	pos = InStr(ItemName, ".");
	While ( pos != -1 )
		{
		ItemName = Right(ItemName, Len(ItemName) - pos - 1);
		pos = InStr(ItemName, ".");
		}

	PackageName = Left(FullName, Len(FullName) - Len(ItemName) - 1);
	}

///////////////////////////////////////////////////////////////////////////////
// Get a random number from 0.0 to 1.0
///////////////////////////////////////////////////////////////////////////////
function float MyRand()
	{
	RandSeed = (RandSeed * 25173 + 13849) % 65536;
	return float(RandSeed) / float(65536 - 1);
	}

///////////////////////////////////////////////////////////////////////////////
// Extra Setup for boltons, dialog etc
///////////////////////////////////////////////////////////////////////////////
function ExtraSetup(P2MoCapPawn P)
{
	// STUB, filled out in ChameleonPlus
}

function bool UseExtendedBoltons()
{
	// STUB, filled out in ChameleonPlus
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	DefaultMesh = Mesh'Characters.Avg_M_SS_Pants'

	// NOTE: If a level contains a ChameleonTuner then these defaults will NOT be used and instead the values from that object are used.
	DesiredBalance=(Gender=(Females=50,Males=50),RacialFemale=(Blacks=10,Mexicans=15,Whites=75),RacialMale=(Blacks=10,Mexicans=15,Whites=75),OverallMaleGay=3,OverallFemaleFem=10,OverallFat=5,OverallTall=3)
	}
