///////////////////////////////////////////////////////////////////////////////
// AW7/AWP/P2C Chameleon
// Provide chameleon functionality, plus add silly hats and shit to people.
///////////////////////////////////////////////////////////////////////////////
class ChameleonPlus extends Chameleon;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
var() Mesh FemLHMesh;							// Long-haired females can't wear hats
var globalconfig bool bUseExtendedBoltons;		// Whether or not to use extended boltons (user configurable)
var globalconfig bool bTestExtraMeshes;			// For testing only, forces all "alternate" meshes to be used

var Material ColemansCrewSkin;

var array<Name> UsedRares;

// "Variant" character meshes to use randomly (potbelly, shorter females etc.)
struct MeshReplacement
{
	var Mesh OldMesh;
	var array<Mesh> NewMesh;
	var float SwapRate;
};

var array<MeshReplacement> VariantMesh;			// Allows for variants on stock meshes (potbellies, taller/shorter skeletons etc)

///////////////////////////////////////////////////////////////////////////////
// Setup the balance.  If the level contains a tuner then we use it's
// balance settings, otherwise we use the defaults.
///////////////////////////////////////////////////////////////////////////////
function SetupBalance()
{
	Super.SetupBalance();

	// Make everyone jolly and fat for the holiday
	if (Level.Month == 12
		&& Level.Day >= 15
		&& Level.Day <= 25)
	DesiredBalance.OverallFat = 50;
}
	
///////////////////////////////////////////////////////////////////////////////
// Is it safe to overwrite this bolton record.
///////////////////////////////////////////////////////////////////////////////
function bool UnusedBolton(P2MoCapPawn.SBolton Bolt)
{
	return (Bolt.bInActive ||
		(Bolt.Mesh == None && Bolt.StaticMesh == None));
}

///////////////////////////////////////////////////////////////////////////////
// Some people don't want to have purses or things because they're on
// duty, like police officers or cashiers.
///////////////////////////////////////////////////////////////////////////////
function bool OnOfficialBusiness(P2MocapPawn P)
{
	return (
		CashierController(P.Controller) != None
		|| P.bAuthorityFigure
		|| MarcherController(P.Controller) != None
		|| P.IsA('AWZombie'));
}

///////////////////////////////////////////////////////////////////////////////
// Find the first unused bolton record
///////////////////////////////////////////////////////////////////////////////
function int GetNextBolton(P2MocapPawn P, optional int CurrBolt)
{
	while (CurrBolt < ArrayCount(P.Boltons) && !UnusedBolton(P.Boltons[CurrBolt]))
		CurrBolt++;

	if (CurrBolt >= ArrayCount(P.Boltons))
		return -1;
	else
		return CurrBolt;
}

function RandomizeScale(out float DScale)
{
	DScale = DScale + (MyRand() - 0.5)/1;
}

function dlog(string S, optional name N)
{
	if (false)
		log(S,'Debug');
}

///////////////////////////////////////////////////////////////////////////////
// Pick a random appearance for this pawn's body.
// Add in silly hats, purses, briefcases etc.
// Also set up new dialog here
///////////////////////////////////////////////////////////////////////////////
function ExtraSetup(P2MocapPawn P)
{
	local int NextBolton;
	local int i,j,k;
	local bool bUse;
	local bool bHasHat;
	local bool bHasGlasses;
	local vector NewScale;
	local bool bOk, bWhitelisted, bFound;
	local float seed;
	local int loopcount;

	//log(self@"AW7Chameleon :: Pick for"@P@"gender"@ReqGender,'Debug');
	//log(self@"Calling Super.Pick",'Debug');
	//Super.Pick(P, ReqGender);
	//log(self@"Back from Super",'Debug');

	// STUB -- now defined in the individual classes
	/*
	// Certain people don't get these boltons, no matter what
	if (Fanatics(P) != None			// Tali-banana don't care
		|| P.IsA('AWFanatics')		// Taliban still don't care
		|| Bums(P) != None			// Bums can't afford them
		|| Gary(P) != None			// Gary doesn't care
		|| P.IsA('AWGary')			// Gary still doesn't care
		|| Gimp_AMW(P) != None		// The gimp already looks fucking silly enough
		|| Krotchy(P) != None		// As does Krotchy
		|| Kumquat(P) != None		// Taliban don't care
		|| Dude(P) != None			// He's the motherfucking Postal Dude
		|| AWDude(P) != None		// Doooooooood
		|| P.IsA('AWRWSStaff')		// RWS don't care
		|| RWSStaff(P) != None		// RWS won't care
		|| UncleDave(P) != None		// Dave doesn't care
		|| P.IsA('AWMilitary')		// Military don't care
		|| P.bNoChamelBoltons)		// General "catch-all"
		return;
	*/
	
	if (P.bNoChamelBoltons)
		return;
		
	// If turned off via config, skip
	if (!bUseExtendedBoltons)
		return;

	NextBolton = GetNextBolton(P);
//	log(self@"Next bolton index is"@NextBolton);
	if (NextBolton == -1)
		return;

	// Look at the Pawn and decide what it wants to do with boltons.
	for (i=0; i<P.RandomizedBoltons.Length; i++)
	{
		// If we ever hit a "None" bolton, stop processing immediately -- this class has no more boltons to add.
		if (P.RandomizedBoltons[i] == None)
			break;
		
		// Each bolton has a chance of activating.		
		seed = MyRand();
		dlog(P@"Bolton"@P.RandomizedBoltons[i].Name@"chance"@P.RandomizedBoltons[i].UseChance@"seed"@seed,'Debug');
		
		// If any other boltons worn match the IncludeTags for this bolton, try to wear it too, automatically
		for (j=0; j < P.BoltonTagsUsed.Length; j++)
			for (k=0; k < P.RandomizedBoltons[i].IncludeTags.Length; k++)
				if (P.BoltonTagsUsed[j] == P.RandomizedBoltons[i].IncludeTags[k])
				{
					dlog("Picking seed 0 based on included tag"@P.RandomizedBoltons[i].IncludeTags[k]);
					seed = 0;
				}
		
		if (P.RandomizedBoltons[i] != None
			&& (seed < P.RandomizedBoltons[i].UseChance || P.RandomizedBoltons[i].UseChance >= 1))
		{
			bOk = true;
			
			// Date check.
			if (P.RandomizedBoltons[i].ValidDates.YearMin != 0
				&& Level.Year < P.RandomizedBoltons[i].ValidDates.YearMin)
				bOk = false;
			if (P.RandomizedBoltons[i].ValidDates.YearMax != 0
				&& Level.Year > P.RandomizedBoltons[i].ValidDates.YearMax)
				bOk = false;
			if (P.RandomizedBoltons[i].ValidDates.MonthMin != 0
				&& Level.Month < P.RandomizedBoltons[i].ValidDates.MonthMin)
				bOk = false;
			if (P.RandomizedBoltons[i].ValidDates.MonthMax != 0
				&& Level.Month > P.RandomizedBoltons[i].ValidDates.MonthMax)
				bOk = false;
			if (P.RandomizedBoltons[i].ValidDates.DayMin != 0
				&& Level.Day < P.RandomizedBoltons[i].ValidDates.DayMin)
				bOk = false;
			if (P.RandomizedBoltons[i].ValidDates.DayMax != 0
				&& Level.Day > P.RandomizedBoltons[i].ValidDates.DayMax)
				bOk = false;
				
			// Holiday check.
			if (P.RandomizedBoltons[i].ValidHoliday != ''
				&& P2GameInfoSingle(Level.Game) != None
				&& !P2GameInfoSingle(Level.Game).IsHoliday(P.RandomizedBoltons[i].ValidHoliday))
				bOk = false;
			
			if (P.RandomizedBoltons[i].InvalidHoliday != ''
				&& P2GameInfoSingle(Level.Game) != None
				&& P2GameInfoSingle(Level.Game).IsHoliday(P.RandomizedBoltons[i].InvalidHoliday))
				bOk = false;
			
			// If this is a "rare" bolton that's already appeared this map, don't use it.
			if (P.RandomizedBoltons[i].RareTag != '')	// Ignore the empty tag
				for (j=0; j < UsedRares.Length; j++)
				{
					dlog(bOk@"rare tag"@P.RandomizedBoltons[i].RareTag@"vs"@UsedRares[j]);
					if (P.RandomizedBoltons[i].RareTag == UsedRares[j])
						bOk = false;
				}

			dlog(bOk@"Checking bolton tags",'Debug');
			// Check to make sure the tag hasn't been used yet.
			for (j=0; j < P.BoltonTagsUsed.Length; j++)
				for (k=0; k < P.RandomizedBoltons[i].ExcludeTags.Length; k++)				
					if (P.BoltonTagsUsed[j] == P.RandomizedBoltons[i].ExcludeTags[k])
						bOk = false;
					
			dlog(bOk@"Checking whitelist skins",'Debug');
			// If we have a whitelist, ensure that the pawn's skin is in the whitelist.
			if (P.RandomizedBoltons[i].IncludeSkins.Length > 0)
			{
				//log("Include skins check",'Debug');
				bWhitelisted = false;
				for (j=0; j<P.RandomizedBoltons[i].IncludeSkins.Length; j++)
					if (P.Skins[0] == P.RandomizedBoltons[i].IncludeSkins[j])
						bWhitelisted = true;
						
				if (!bWhitelisted)
					bOk = false;
					
				//log("Whitelisted:"@bWhitelisted,'Debug');
			}
			
			dlog(bOk@"Check blacklist skins",'Debug');
			// If there's a blacklist, make sure we're not on it.
			for (j=0; j<P.RandomizedBoltons[i].ExcludeSkins.Length; j++)
				if (P.Skins[0] == P.RandomizedBoltons[i].ExcludeSkins[j])
					bOk = false;					

			for (j=0; j<P.RandomizedBoltons[i].ExcludedMeshes.Length; j++)
				if (P.Mesh == P.RandomizedBoltons[i].ExcludedMeshes[j])
					bOk = false;
			//log(bOk,'Debug');
			
			/*
			//log("Fat check",'Debug');
			if (P.bIsFat && P.RandomizedBoltons[i].bNoFat)
				bOk = false;
			//log(bOk,'Debug');
			
			//log("Male check",'Debug');
			if (P.bIsFemale && P.RandomizedBoltons[i].bMalesOnly)
				bOk = false;
			//log(bOk,'Debug');
			
			//log("Female check",'Debug');
			if (!P.bIsFemale && P.RandomizedBoltons[i].bFemalesOnly)
				bOk = false;
			//log(bOk,'Debug');

			//log("Gay Male check",'Debug');
			if (!P.bIsFemale && !P.bIsFeminine && P.RandomizedBoltons[i].bMalesOnlyIfGay)
				bOk = false;
			//log(bOk,'Debug');
			*/
			
			//debuglog("prior to new boltons checks: ok is"@bOk);
			
			// Body type check.
			dlog(bOk@"Body Type Check"@P.RandomizedBoltons[i].BodyType@"vs"@P.MyBody);
			if (P.RandomizedBoltons[i].BodyType != Body_Any
				&& P.RandomizedBoltons[i].BodyType != P.MyBody)
				bOk = false;
				
			// Gender check.
			dlog(bOk@"Gender Check"@P.RandomizedBoltons[i].Gender@"vs"@P.MyGender);
			if (P.RandomizedBoltons[i].Gender != Gender_Any
				&& P.RandomizedBoltons[i].Gender != P.MyGender)
				bOk = false;
				
			// Race check.
			dlog(bOk@"Race Check"@P.RandomizedBoltons[i].Race@"vs"@P.MyRace);
			if (P.RandomizedBoltons[i].Race != Race_Any
				&& P.RandomizedBoltons[i].Race != P.MyRace)
				bOk = false;
				
			// Lifestyle check.
			dlog(bOk@"Lifestyle Check"@P.RandomizedBoltons[i].Lifestyle@"vs"@P.bIsGay);
			if (P.RandomizedBoltons[i].Lifestyle != Lifestyle_Any
				&& (
				(P.RandomizedBoltons[i].Lifestyle == Lifestyle_Straight && P.bIsGay)
				|| (P.RandomizedBoltons[i].Lifestyle == Lifestyle_Gay && !P.bIsGay)
				))
				bOk = false;
			
			//log("FemLH check",'Debug');
			//if (P.HeadMesh == FemLHMesh && P.RandomizedBoltons[i].bNoFemLH)
			//	bOk = false;
			//log(bOk,'Debug');

			// Parse through Allowed Heads and see if any match.
			if (P.RandomizedBoltons[i].AllowedHeads.Length > 0)
			{
				bFound = false;
				for (j=0; j<P.RandomizedBoltons[i].AllowedHeads.Length; j++)
				{
					dlog(bOk@"Allowed heads check"@P.HeadMesh@"vs"@P.RandomizedBoltons[i].AllowedHeads[j]);
					if (P.HeadMesh == P.RandomizedBoltons[i].AllowedHeads[j])
						bFound = true;
				}
						
				if (!bFound)
					bOk = false;
			}
			
			// Parse through Allowed Meshes and see if any match.
			if (P.RandomizedBoltons[i].IncludedMeshes.Length > 0)
			{
				bFound = false;
				for (j=0; j<P.RandomizedBoltons[i].IncludedMeshes.Length; j++)				
				{
					dlog(bOk@"Included Meshes check"@P.Mesh@"vs"@P.RandomizedBoltons[i].IncludedMeshes[j]);
					if (P.Mesh == P.RandomizedBoltons[i].IncludedMeshes[j])
						bFound = true;
				}
						
				if (!bFound)
					bOk = false;
			}
			
			// Parse through Excluded Heads and see if any match.
			for (j=0; j<P.RandomizedBoltons[i].ExcludedHeads.Length; j++)
			{
				dlog(bOk@"Excluded Heads check"@P.HeadMesh@"vs"@P.RandomizedBoltons[i].ExcludedHeads[j]);
				if (P.HeadMesh == P.RandomizedBoltons[i].ExcludedHeads[j])
					bOk = false;					
			}
					
			// If it's a large/bulky bolton, don't assign it if they're set to stand in a q (or run the q!)
			if (P.RandomizedBoltons[i].SpecialFlags.bLargeAndBulky
				&& (P.PawnInitialState == EP_GoStandInQueue
					|| CashierController(P.Controller) != None
					|| P.PawnInitialState == EP_Dance
					|| P.PawnInitialState == EP_StandWithGun
					|| P.PawnInitialState == EP_StandWithGunReady
					|| P.PawnInitialState == EP_PlayArcade
					|| P.PawnInitialState == EP_KeyboardType
					)
				)
				bOk = false;
	
			// Okay to go, assign the bolton.
			if (bOk)
			{
				dlog("Okay to go, assign the bolton.",'Debug');
				j = Int(MyRand() * P.RandomizedBoltons[i].Boltons.Length);
				// Direct assignment doesn't work I think
				//P.Boltons[NextBolton] = P.RandomizedBoltons[i].Boltons[j];
				P.Boltons[NextBolton].Bone = P.RandomizedBoltons[i].Boltons[j].Bone;
				P.Boltons[NextBolton].Mesh = P.RandomizedBoltons[i].Boltons[j].Mesh;
				P.Boltons[NextBolton].StaticMesh = P.RandomizedBoltons[i].Boltons[j].StaticMesh;
				P.Boltons[NextBolton].Skin = P.RandomizedBoltons[i].Boltons[j].Skin;
				P.Boltons[NextBolton].bCanDrop = P.RandomizedBoltons[i].Boltons[j].bCanDrop;
				P.Boltons[NextBolton].bInActive = P.RandomizedBoltons[i].Boltons[j].bInActive;
				//log(P.RandomizedBoltons[i].Boltons[j].StaticMesh@"attach to head ="@P.RandomizedBoltons[i].Boltons[j].bAttachToHead,'Debug');
				P.Boltons[NextBolton].bAttachToHead = P.RandomizedBoltons[i].Boltons[j].bAttachToHead;
				//log("P.Boltons[NextBolton].bAttachToHead ="@P.Boltons[NextBolton].bAttachToHead,'Debug');
				P.Boltons[NextBolton].DrawScale = P.RandomizedBoltons[i].Boltons[j].DrawScale;
				
				// If a rare bolton, register it as being used this map
				if (P.RandomizedBoltons[i].RareTag != '')
				{
					UsedRares.Insert(0,1);
					UsedRares[0] = P.RandomizedBoltons[i].RareTag;
					//log("rare tag added"@UsedRares[0]);
				}
				//log(P.Boltons[NextBolton].Bone@P.Boltons[NextBolton].Mesh@P.Boltons[NextBolton].StaticMesh@P.Boltons[NextBolton].Skin@P.Boltons[NextBolton].bCanDrop@P.Boltons[NextBolton].bInActive@P.Boltons[NextBolton].bAttachToHead,'Debug');
				
				P.BoltonTagsUsed.Length = P.BoltonTagsUsed.Length + 1;
				P.BoltonTagsUsed[P.BoltonTagsUsed.Length - 1] = P.RandomizedBoltons[i].Tag;
				if (P.RandomizedBoltons[i].SpecialFlags.bLargeAndBulky)
				{
					P.bNoExtendedAnims = true;
					P.bCellUser = false;
				}
				
				// Valentines Day stuff
				if (P.RandomizedBoltons[i].SpecialFlags.SpecialHoldWalkAnim != '')
					P.SpecialHoldWalkAnim = P.RandomizedBoltons[i].SpecialFlags.SpecialHoldWalkAnim;
				if (P.RandomizedBoltons[i].SpecialFlags.SpecialHoldStandAnim != '')
					P.SpecialHoldStandAnim = P.RandomizedBoltons[i].SpecialFlags.SpecialHoldStandAnim;
					
				if (P.RandomizedBoltons[i].SpecialFlags.bValentine)
				{
					P.bValentine = True;
					P.HoldingVase = NextBolton;
					// Make them super-talkative, so they'll have a high chance to give away their roses/kiss
					P.Talkative = 1.00;
				}					
				
				if (P.RandomizedBoltons[i].SpecialFlags.bHalloween)
					P.bHalloween = True;
					
				if (P.RandomizedBoltons[i].SpecialFlags.bCigarette)
					P.HoldingCigarette = NextBolton;
					
				if (P.RandomizedBoltons[i].SpecialFlags.bIsHelmet)
				{
					AWPerson(P).TakesSledgeDamage /= 4.0;
					P.TakesShotgunHeadShot /= 4.0;
					P.TakesRifleHeadShot /= 2.0;	// Change by Man Chrzan: 4.0 to 2.0
					P.TakesShovelHeadShot /= 4.0;
					P.TakesPistolHeadShot /= 4.0;
				}
					
				// Very slightly increase head bolton size to prevent clipping.
				/*
				if (P.Boltons[NextBolton].bAttachToHead)
					P.Boltons[NextBolton].DrawScale = 1.03;
				*/
				/*
				{
					P.bRandomizeHeadScale = False;
					P.HeadScale.X = 0.9;
					P.HeadScale.Y = 0.9;
					P.HeadScale.Z = 0.9;
				}
				*/
				
				// Replace head and body skin, if specified.
				if (P.RandomizedBoltons[i].BodySkin != None)
					P.Skins[0] = P.RandomizedBoltons[i].BodySkin;
				if (P.RandomizedBoltons[i].HeadSkin != None)
					P.HeadSkin = P.RandomizedBoltons[i].HeadSkin;
				if (P.RandomizedBoltons[i].HeadMesh != None)
					P.HeadMesh = P.RandomizedBoltons[i].HeadMesh;
			}
		}

		// If we're out of bolton slots, stop now
		NextBolton = GetNextBolton(P);
	//	log(self@"Next bolton index is"@NextBolton);
		if (NextBolton == -1)
			break;
			
		// xPatch: Runaway loop Crash Fix
		if (loopcount > 1000)	
			break;
		
		loopcount++;
		// End
	}
	
	// Assign new dialog class.
	if (P.DialogClass == None)
	{
		if (P.MyRace == Race_Black)
		{
			if (P.MyGender == Gender_Female)
				P.DialogClass = class'DialogFemaleBlack';
			else if (P.MyGender == Gender_Male)
				P.DialogClass = class'DialogMaleBlack';
		}
		else if (P.MyRace == Race_Mexican)
		{
			if (P.MyGender == Gender_Female)
				P.DialogClass = class'DialogFemaleMex';
			else if (P.MyGender == Gender_Male)
				P.DialogClass = class'DialogMaleMex';
		}
		else if (P.MyRace == Race_White)
		{
			if (P.MyGender == Gender_Female)
			{
				if (MyRand() <= 0.5)
					P.DialogClass = class'DialogFemaleAlt';
				else
					P.DialogClass = class'DialogFemale';
			}
			else if (P.MyGender == Gender_Male)
			{				
				if (P.bIsGay)
				{
					P.DialogClass = class'DialogGay';
					//log(P@"was assigned a Dialog Gay!");
				}
				else if (MyRand() <= 0.5)
					P.DialogClass = class'DialogMaleAlt';
				else
					P.DialogClass = class'DialogMale';
			}
		}		
	}
	
	// Dialog overrides based on skin
	if (P.Skins[0] == ColemansCrewSkin)
		P.DialogClass = class'DialogMaleBlack';

/*
	// Head scale and height variance
	if (P.bRandomizeHeadScale)
	{
		log(self@"randomizing head and body scale for"@P);

		NewScale = P.DrawScale3D;
		RandomizeScale(NewScale.Y);
		log(self@"new body scale is"@NewScale);
		P.SetDrawScale3D(NewScale);

		NewScale = P.MyHead.DrawScale3D;
		RandomizeScale(NewScale.X);
		RandomizeScale(NewScale.Y);
		RandomizeScale(NewScale.Z);
		log(self@"new head scale is"@NewScale);
		P.MyHead.SetDrawScale3D(NewScale);

	}
*/
}

///////////////////////////////////////////////////////////////////////////////
// Use MyRand() to give a pseudo-random number from Low to High
///////////////////////////////////////////////////////////////////////////////
function int MyRandRange(int Low, int High)
{
	local float f;
	local int i;

	f = MyRand() * (High - Low);
	i = Int(f);
	return i;
}

/*
function float MyRand()
{
	if (!bRandomized)	
		Randomize();
		
	return Super.MyRand();
}
*/

/*
///////////////////////////////////////////////////////////////////////////////
// Get a random number from 0.0 to 1.0
///////////////////////////////////////////////////////////////////////////////
function float MyRand()
	{
	RandSeed = (RandSeed * 25173 + 13849) % 65536;
	return float(RandSeed) / float(65536 - 1);
	}
*/

///////////////////////////////////////////////////////////////////////////////
// Get specified mesh.
// This tries to load the mesh from any of the packages specified by
// the pawn's ChameleonMeshPkgs array.
///////////////////////////////////////////////////////////////////////////////
static function Mesh GetMesh(P2MocapPawn P, String MeshName)
{
	local Mesh ReturnMesh;
	local int i;
	local Chameleon MyCham;
	
	// grumble grumble static functions
	MyCham = P2GameInfo(P.Level.Game).myChameleon;
	
	ReturnMesh = Super.GetMesh(P, MeshName);

	if (P.bNoChamelBoltons)
		return ReturnMesh;
		
	// If turned off via config, skip
	if (!Default.bUseExtendedBoltons)
		return ReturnMesh;

	// Chance to swap out this mesh with a variant mesh.
	for (i=0; i<Default.VariantMesh.Length; i++)
		if (ReturnMesh == Default.VariantMesh[i].OldMesh
			&& (MyCham.MyRand() <= Default.VariantMesh[i].SwapRate || Default.bTestExtraMeshes))
			// Found a replacement mesh. Use it instead.
			return Default.VariantMesh[i].NewMesh[ChameleonPlus(MyCham).MyRandRange(0,Default.VariantMesh[i].NewMesh.Length - 1)];
			
	return ReturnMesh;
}

function bool UseExtendedBoltons()
{
	return bUseExtendedBoltons;
}
	
///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	FemLHMesh=SkeletalMesh'Heads.FemLH'
	bUseExtendedBoltons=true
	ColemansCrewSkin=Texture'ChameleonSkins.Special.Colemans_Crew'
	
	VariantMesh[0]=(OldMesh=SkeletalMesh'Characters.Avg_M_SS_Shorts',NewMesh=(SkeletalMesh'Characters.Avg_M_SS_Shorts_PB_D'),SwapRate=0.2)
	VariantMesh[1]=(OldMesh=SkeletalMesh'Characters.Fem_SS_Shorts',NewMesh=(SkeletalMesh'Characters.Fem_SS_Shorts_02_D',SkeletalMesh'Characters.Fem_SS_Shorts_D'),SwapRate=0.2)
	VariantMesh[2]=(OldMesh=SkeletalMesh'Characters.Fem_LS_Skirt',NewMesh=(SkeletalMesh'Characters.Fem_LS_Skirt_D'),SwapRate=0.2)
}