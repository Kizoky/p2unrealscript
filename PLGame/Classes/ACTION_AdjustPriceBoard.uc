///////////////////////////////////////////////////////////////////////////////
// ACTION_AdjustPriceBoard
// Copyright 2014, Running With Scissors, Inc.
//
// A nice little scripted action to drive our frustrating toilet paper errand
///////////////////////////////////////////////////////////////////////////////
class ACTION_AdjustPriceBoard extends P2ScriptedAction;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
enum EAction {
	EA_Add,			// Simply adds/subtracts to current price. Nothing special.
	EA_Multiply,	// Multiplies/integer-divides current price
	EA_SetValue,	// Sets value to PriceActionAmount. No addition or multiplication.
	EA_LoadFromGameState	// Loads value from game state (if non-zero)
};

var(Action) EAction PriceAction;		// What action to take regarding the price
var(Action) bool bSetToDudeCashFirst;	// Sets value to the amount that the Dude has on hand, then performs PriceAction
var(Action) int CatsAsCashMultiplier;	// Count cats as this many dollars when setting price to dude cash
var(Action) float PriceActionAmount;	// How much to adjust price by
var(Action) name PriceBoardTag;			// Tag of price board to adjust.
var(Action) bool bSaveToGameState;		// Saves price to game state after setting.
var(Action) Range PriceRange;			// Lowest and highest valid prices.

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool InitActionFor(ScriptedController C)
{
	local PriceBoard MyBoard;
	local P2Pawn PlayerPawn;
	local int NewPrice;
	local P2PowerupInv MyMoney, MyCats;
	
	// Find our price board
	foreach C.DynamicActors(class'PriceBoard', MyBoard, PriceBoardTag)
		break;
		
	if (MyBoard == None)
	{
		warn(self@"========== NO PRICE BOARD FOUND");
		return false;
	}
	
	// Read in current price
	NewPrice = MyBoard.GetPrice();
	
	// See if we want to set the price to the dude's cash value, first.
	PlayerPawn = GetPlayerPawn(C);
	if (bSetToDudeCashFirst)
	{
		MyMoney = P2PowerupInv(PlayerPawn.FindInventoryType(class'MoneyInv'));
		// If the dude has no money, assume they threw it, and don't use "zero" as the baseline here
		if (MyMoney != None)
		{
			NewPrice = int(MyMoney.Amount);
			// Now, add in the cats, if applicable.
			if (CatsAsCashMultiplier != 0)
			{
				MyCats = P2PowerupInv(PlayerPawn.FindInventoryType(class'CatInv'));
				NewPrice = NewPrice + int(MyCats.Amount) * CatsAsCashMultiplier;
			}
		}
	}
	
	// Now that we have a price, perform the action
	if (PriceAction == EA_Add)
		NewPrice += int(PriceActionAmount);
	else if (PriceAction == EA_Multiply)
		NewPrice *= PriceActionAmount;
	else if (PriceAction == EA_SetValue)
		NewPrice = int(PriceActionAmount);
	else
		NewPrice = PLGameState(P2GameInfoSingle(C.Level.Game).TheGameState).SavedPriceBoard;
		
	if (NewPrice != 0)
	{
		// Clamp the price to the valid range
		NewPrice = Clamp(NewPrice, PriceRange.Min, PriceRange.Max);
	
		// Now set the new price
		MyBoard.SetPrice(NewPrice);
		
		// Save to the game state if necessary.
		if (bSaveToGameState)
			PLGameState(P2GameInfoSingle(C.Level.Game).TheGameState).SavedPriceBoard = NewPrice;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Defaults
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	PriceAction=EA_Add
	PriceActionAmount=0
	bSetToDudeCashFirst=false
	CatsAsCashMultiplier=10
	ActionString="adjust price board"
	PriceRange=(Min=1,Max=999)
}