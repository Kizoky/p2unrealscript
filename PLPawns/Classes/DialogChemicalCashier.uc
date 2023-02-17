///////////////////////////////////////////////////////////////////////////////
// Panther Pilsner Chemical Cashier
///////////////////////////////////////////////////////////////////////////////
class DialogChemicalCashier extends DialogFemale;

///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
{
	// Let super go first
	Super.FillInLines();

	Clear(lCashier_PleaseTakeATicket);
	AddTo(lCashier_PleaseTakeATicket,			"PL-Dialog2.ThursdayErrandA.FemaleReceptionist-1TakeANumber", 1);

	Clear(lCashier_PleaseWaitYourTurn);
	AddTo(lCashier_PleaseWaitYourTurn,			"PL-Dialog2.ThursdayErrandA.FemaleReceptionist-2ICannotServeYou", 1);
	AddTo(lCashier_PleaseWaitYourTurn,			"PL-Dialog2.ThursdayErrandA.FemaleReceptionist-2PleaseWait", 1);

	Clear(lCashier_NowServing);
	AddTo(lCashier_NowServing,					"PL-Dialog2.ThursdayErrandA.FemaleReceptionist-3ServingNumberThirty", 1);

	Clear(lChemCashier_ThankYou);
	AddTo(lChemCashier_ThankYou,				"PL-Dialog2.ThursdayErrandA.FemaleReceptionist-4ThankYouForPatronage", 1);

	Clear(lChemCashier_ThatllBe);
	AddTo(lChemCashier_ThatllBe,					"PL-Dialog2.ThursdayErrandA.FemaleReceptionist-4ThankYouForShopping", 1);
}