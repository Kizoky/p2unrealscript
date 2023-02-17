///////////////////////////////////////////////////////////////////////////////
// Cash 4 Cats Dialog
///////////////////////////////////////////////////////////////////////////////
class DialogCash4Cats extends DialogMale;

///////////////////////////////////////////////////////////////////////////////
// Find a number that fits with the numbers dialog
// NUMBER_SYSTEM_MAX is the highest our number system goes
///////////////////////////////////////////////////////////////////////////////
function int GetValidNumber(optional int Min, optional int Max)
{
	local int usenum;

	if(Max == 0 || Max > NUMBER_SYSTEM_MAX)
		Max = NUMBER_SYSTEM_MAX;

	usenum = Min + Rand((Max - Min) + 1);

	//log(self$" use num generated "$usenum);

	// 1 through 5 are handled properly, except 0
	if(usenum == 0)
		usenum = 1;
	else if(usenum <= 19)
	{
		// just let the number pass on through
	}
	//else if(usenum > 5 && usenum <= 20)
		//usenum = 10;
	else if(usenum < 30)
		usenum = 20;
	else if(usenum < 40)
		usenum = 30;
	else if(usenum < 50)
		usenum = 40;
	else if(usenum < 60)
		usenum = 50;
	else if(usenum < 70)
		usenum = 60;
	else if(usenum < 80)
		usenum = 70;
	else if(usenum < 90)
		usenum = 80;
	else if(usenum < 100)
		usenum = 90;
	else if(usenum < 200)
		usenum = 100;
	else if(usenum < 300)
		usenum = 200;
	else if(usenum < 400)
		usenum = 300;
	else if(usenum < 500)
		usenum = 400;
	else if(usenum < 600)
		usenum = 500;
	else if(usenum < 700)
		usenum = 600;
	else if(usenum < 800)
		usenum = 700;
	else if(usenum < 900)
		usenum = 800;
	else
		usenum = 900;

	//log(self$" use num returned "$usenum);

	return usenum;
}

///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
{
	// Let super go first
	Super.FillInLines();

	Clear(lGreeting);
	Addto(lGreeting,							"PL-Dialog.TuesdayA.Cash4Cats-PussyForSale", 1);
	AddTo(lGreeting,							"PL-Dialog.TuesdayA.Cash4Cats-SparePussyCats", 1);
	
	Clear(lCashier_ForThatIllGive);
	Addto(lCashier_ForThatIllGive,				"PL-Dialog.TuesdayA.Cash4CatsCashier-2ForThatLot", 1);
	AddTo(lCashier_ForThatIllGive,				"PL-Dialog.TuesdayA.Cash4Cats-IllBuyThoseFor", 1);
}