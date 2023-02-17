///////////////////////////////////////////////////////////////////////////////
// PriceBoard
// Copyright 2014, Running With Scissors, Inc.
//
// This is a dynamically-adjusting price board that can be used with
// PriceBoardCashiers. Its price can be set with triggers, scripts, etc. and
// the cashier will read the price from the board to sell items.
//
// Only basic price-changing functionality is implemented here. Scripted
// actions are required to change the actual displayed price by calling
// SetPrice().
///////////////////////////////////////////////////////////////////////////////
class PriceBoard extends NumericSign;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var() int DefaultPrice;	// Default price of goods										
									
///////////////////////////////////////////////////////////////////////////////
// PostBeginPlay
// Initialize and update a price
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{	
	CurrentValue = DefaultPrice;
	Super.PostBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// SetPrice
// Called by external script to update current price.
///////////////////////////////////////////////////////////////////////////////
function SetPrice(int NewPrice)
{
	SetValue(NewPrice);
}

///////////////////////////////////////////////////////////////////////////////
// GetPrice
// Called by external script to get current price
///////////////////////////////////////////////////////////////////////////////
function int GetPrice()
{
	return GetValue();
}

///////////////////////////////////////////////////////////////////////////////
// Default properties, including a sample setup
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	DefaultPrice=30
	DigitSkinIndex[0]=3
	DigitSkinIndex[1]=2
	DigitSkinIndex[2]=1
	DigitMaterials[0]=Texture'PL_PlaceholderTex.tpsign.0'
	DigitMaterials[1]=Texture'PL_PlaceholderTex.tpsign.1'
	DigitMaterials[2]=Texture'PL_PlaceholderTex.tpsign.2'
	DigitMaterials[3]=Texture'PL_PlaceholderTex.tpsign.3'
	DigitMaterials[4]=Texture'PL_PlaceholderTex.tpsign.4'
	DigitMaterials[5]=Texture'PL_PlaceholderTex.tpsign.5'
	DigitMaterials[6]=Texture'PL_PlaceholderTex.tpsign.6'
	DigitMaterials[7]=Texture'PL_PlaceholderTex.tpsign.7'
	DigitMaterials[8]=Texture'PL_PlaceholderTex.tpsign.8'
	DigitMaterials[9]=Texture'PL_PlaceholderTex.tpsign.9'
}
