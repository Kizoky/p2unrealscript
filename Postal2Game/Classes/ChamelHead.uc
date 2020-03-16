///////////////////////////////////////////////////////////////////////////////
// ChamelHead.uc
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
//		MWA__025__Dude
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
//		Body:		A - average
//					F - fat
//
// Next is a unique 3-digit number with leading zeros.  This number must be
// unique across ALL head skins.  Gaps in the numbers are not a problem
// although the maximum number should be kept to a reasonable value (we
// currently assume a range of 000 to 499).
//
// Last is the name of the mesh the texture is designed to use.  The mesh
// is assumed to be located in one of the packages listed in the pawn's
// ChamelHeadMeshPkgs array.
//
///////////////////////////////////////////////////////////////////////////////
class ChamelHead extends Info
	config(system);


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

// This is for testing purposes only!  If this value is anything but 0 then
// ALL THE SKINS WILL BE LOADED to make sure they all exist.  This is intended
// to be used to check for typos whenever new skins are added.
var() config bool			bValidate;

// Default mesh in case something goes wrong
var() Mesh					DefaultMesh;

// Reference counts for skins.  Each skin has a unique number embedded in
// its name.  That number is used as an index into this array.  We currently
// assume a range of 000 to 499.
var int						SkinRefCounts[500];
var name					SkinNames[500];			// Used to report usage statistics


// Some consts indicating positions of various elements in the skin name
const SKIN_GENDER			= 0;
const SKIN_RACE				= 1;
const SKIN_BODY				= 2;
const SKIN_SEPARATOR1		= 3;
const SKIN_UNIQUE			= 5;
const SKIN_SEPARATOR2		= 8;
const SKIN_MESH				= 10;


///////////////////////////////////////////////////////////////////////////////
// Display usage statistics in log
///////////////////////////////////////////////////////////////////////////////
function LogUsage()
	{
	local int i;

	Log("=========================================================");
	Log("ChamelHead Usage Statistics");
	Log("=========================================================");
	Log("Skin usage");
	for (i = 0; i < ArrayCount(SkinRefCounts); i++)
		{
		if (SkinRefCounts[i] > 0)
			Log("   "$SkinRefCounts[i]$"   "/*$SkinNames[i]*/);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Pick a random head that matches the specified attributes.
///////////////////////////////////////////////////////////////////////////////
function Pick(P2MoCapPawn P, FPSPawn.EGender ReqGender, FPSPawn.ERace ReqRace, FPSPawn.EBody ReqBody)
	{
	local Material FoundSkin;
	local Mesh FoundMesh;
	local int FoundID;

	if (Find(P, ReqGender, ReqRace, ReqBody, FoundSkin, FoundMesh, FoundID))
		{
		Assign(P, FoundSkin, FoundMesh, FoundID);
		}
	else
		{
		Warn("No matching or valid skins found (requested "$ReqGender$ReqRace$ReqBody$"), using default mesh and no skin for "$P);
		P.HeadSkin = None;
		P.HeadMesh = DefaultMesh;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Find a head matching the specified attributes
///////////////////////////////////////////////////////////////////////////////
function bool Find(
	P2MoCapPawn P,
	FPSPawn.EGender ReqGender,
	FPSPawn.ERace ReqRace,
	FPSPawn.EBody ReqBody,
	out Material FoundSkin,
	out Mesh FoundMesh,
	out int FoundID)
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
	local String LowestMeshName;
	local bool bTryAgain;
	local bool bSuccess;

	if (bValidate)
		Log(self @ "Validation start");
		
	// We don't have "tall" heads -- have 'em use the normal ones
	if (ReqBody == Body_Tall)
		ReqBody = Body_Avg;

	// Make sure at least one skin is available
	if (P.ChamelHeadSkins.length > 0)
		{

		do {
			bTryAgain = false;

			// Find the least-used skin that matches the specified attributes
			LowestSkin = -1;
			LowestRefCount = 10000;
			for (skin = 0; skin < P.ChamelHeadSkins.Length && P.ChamelHeadSkins[skin] != 'end'; skin++)
				{
				if (P.ChamelHeadSkins[skin] != 'None')
					{
					if (ParseSkin(String(P.ChamelHeadSkins[skin]), UniqueID, Gender, Race, Body, MeshName))
						{
						// If we're validating then try to load skin and mesh (this must NEVER be enabled for released product!)
						if (bValidate)
							{
							GetSkin(P, String(P.ChamelHeadSkins[skin]));
							GetMesh(P, MeshName);
							}

						if (ReqGender == Gender &&
							ReqRace == Race &&
							ReqBody == Body)
							{
							if (SkinRefCounts[UniqueID] < LowestRefCount)
								{
								LowestRefCount = SkinRefCounts[UniqueID];
								LowestSkin = skin;
								LowestUniqueID = UniqueID;
								LowestMeshName = MeshName;
								}
							}
						}
					else
						Warn("Couldn't parse info from skin "$P.ChamelHeadSkins[skin]$" for "$P);
					}
				}

			// Check if we found one
			if (LowestSkin >= 0)
				{
				// Try to use skin.  If it works then inc the ref count, otherwise set it
				// so this skin won't get picked again and then try to find another one.
				FoundSkin = GetSkin(P, String(P.ChamelHeadSkins[LowestSkin]));
				FoundMesh = GetMesh(P, LowestMeshName);
				FoundID = LowestUniqueID;
				if (FoundSkin != None && FoundMesh != None)
					{
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
		Warn("No ChamelHeadSkins defined for "$P);
		}

	if (!bSuccess)
		{
		Warn("No matching or valid skins found (requested "$ReqGender$ReqRace$ReqBody$") for "$P);
		FoundSkin = None;
		FoundMesh = DefaultMesh;
		}

	if (bValidate)
		Log(self @ "Validation end");

	return bSuccess;
	}

///////////////////////////////////////////////////////////////////////////////
// Assign the skin and mesh
///////////////////////////////////////////////////////////////////////////////
function Assign(P2MoCapPawn P, Material UseSkin, Mesh UseMesh, int UseUniqueID)
	{
	// Use this skin and mesh
	P.HeadSkin = UseSkin;
	P.HeadMesh = UseMesh;

	// Inc ref count
	SkinRefCounts[UseUniqueID]++;

	// Do some random scaling to create different head shapes.  After
	// some testing, decided it was best to only scale in one direction
	// at a time and never in Y.
	// Kamek 12/2 - let ChameleonPlus shrink the heads a tiiiiny bit to stop hats clipping
	P.HeadScale.X = FMax(P.HeadScale.X, 1.00);
	P.HeadScale.Y = FMax(P.HeadScale.Y, 1.00);
	P.HeadScale.Z = FMax(P.HeadScale.Z, 1.00);

	// Don't scale certain pawns heads (no players, and no important pawns)
	if(!P.bPlayer
		&& !P.bPersistent
		&& P.bRandomizeHeadScale)
		{
		switch Rand(4)
			{
			case 0:
				P.HeadScale.x = 1.10;	// width
				break;

			case 1:
				P.HeadScale.z = 1.15;	// height
				break;
			}
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Get the mesh related to the specified skin.  If the skin does not match
// the naming convention then the returned mesh is None.
///////////////////////////////////////////////////////////////////////////////
function Mesh GetRelatedMesh(P2MocapPawn P, Material HeadSkin)
	{
	local int UniqueID;
	local FPSPawn.EGender Gender;
	local FPSPawn.ERace Race;
	local FPSPawn.EBody Body;
	local String MeshName;

	// Parse the name and try to get the mesh.
	if (ParseSkin(String(HeadSkin), UniqueID, Gender, Race, Body, MeshName))
		return GetMesh(P, MeshName);

	return None;
	}

///////////////////////////////////////////////////////////////////////////////
// Get the specified skin.
///////////////////////////////////////////////////////////////////////////////
static function Material GetSkin(P2MocapPawn P, String SkinName)
	{
	local Material NewSkin;

	NewSkin = Material(DynamicLoadObject(SkinName, class'Material'));

	if (NewSkin == None)
		Warn("Couldn't find skin '"$SkinName$"' for "$P);

	return NewSkin;
	}

///////////////////////////////////////////////////////////////////////////////
// Get specified mesh.
// This tries to load the mesh from any of the packages specified by
// the pawn's ChamelHeadMeshPkgs array.
///////////////////////////////////////////////////////////////////////////////
static function Mesh GetMesh(P2MocapPawn P, String MeshName)
	{
	local int meshpkg;
	local Mesh NewMesh;

	for (meshpkg = 0; meshpkg < P.ChamelHeadMeshPkgs.length; meshpkg++)
		{
		NewMesh = Mesh(DynamicLoadObject(P.ChamelHeadMeshPkgs[meshpkg]$"."$MeshName, class'Mesh', true));
		if (NewMesh != None)
			break;
		}

	if (NewMesh == None)
		Warn("Couldn't find mesh '"$MeshName$"' in any ChamelHeadMeshPkgs for "$P);

	return NewMesh;
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
	local String BodyStr;

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

	// Get body
	BodyStr = Mid(SkinName, SKIN_BODY, 1);
	if (BodyStr ~= "A")
		Body = Body_Avg;
	else if (BodyStr ~= "F")
		Body = Body_Fat;
	else
		return false;

	// Get mesh name
	MeshName = Mid(SkinName, SKIN_MESH, 100);

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
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	DefaultMesh = Mesh'Heads.AvgMale'
	}
