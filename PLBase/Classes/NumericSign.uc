///////////////////////////////////////////////////////////////////////////////
// NumericSign
// Copyright 2014, Running With Scissors, Inc.
//
// Base class for actors that display numeric data (price points, number
// served, etc.)
///////////////////////////////////////////////////////////////////////////////
class NumericSign extends Prop
	abstract;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var() array<int> DigitSkinIndex;	// Indexes to the skins of the price changer, starting from the RIGHT.
									// DigitSkinIndex[0] is the index for the ones column, DigitSkinIndex[1] for the tens column, and so on.
									// Warning, there is no handling for overflow - if only two digits are specified, "100" will show up as "00".
									
var() array<Material> DigitMaterials;	// Array of Materials for each digit. The index is equal to the digit - DigitMaterials[0] should point to a Material that says "0",
										// DigitMaterials[1] should point to a Material that says "1", and so on.
										
var int CurrentValue;				// Current value of display										
										
///////////////////////////////////////////////////////////////////////////////
// PostBeginPlay
// Initialize and update a price
// Subclass should assign a CurrentValue, then call Super
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	// Sanity-check digit skins and digit materials
	if (DigitMaterials.Length < 10)
		warn(self@"NOT ALL DIGIT MATERIALS WERE DEFINED ==========================================================");
	else if (DigitSkinIndex.Length == 0)
		warn(self@"NO DIGIT SKIN INDEXES DEFINED =================================================================");
	
	UpdateBoard();
}

///////////////////////////////////////////////////////////////////////////////
// SetValue
// Called by external script to update current value.
///////////////////////////////////////////////////////////////////////////////
function SetValue(int NewValue)
{
	CurrentValue = NewValue;
	UpdateBoard();
}

///////////////////////////////////////////////////////////////////////////////
// GetValue
// Called by external script to get current value
///////////////////////////////////////////////////////////////////////////////
function int GetValue()
{
	return CurrentValue;
}

///////////////////////////////////////////////////////////////////////////////
// UpdateBoard
// Changes the actual skins of the display mesh to reflect the current price.
///////////////////////////////////////////////////////////////////////////////
function UpdateBoard()
{
	local String StrPrice;
	local int i;
	
	// Zero all digits first
	for (i = 0; i < DigitSkinIndex.Length; i++)
		Skins[DigitSkinIndex[i]] = DigitMaterials[0];
	
	StrPrice = String(CurrentValue);
	log(self@"updating value to"@StrPrice);
	for (i = 0; i < Len(StrPrice); i++)
		if (Len(StrPrice) - i <= DigitSkinIndex.Length)
			Skins[DigitSkinIndex[Len(StrPrice) - i - 1]] = DigitMaterials[int(Mid(StrPrice, i, 1))];
}

///////////////////////////////////////////////////////////////////////////////
// Default properties, including a sample setup
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	DrawType=DT_StaticMesh
	bEdShouldSnap=True
	bStaticLighting=True
	bShadowCast=True
	StaticMesh=StaticMesh'PL_PlaceholderMesh.tpsign.tpprice'
}
