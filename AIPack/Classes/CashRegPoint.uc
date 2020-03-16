///////////////////////////////////////////////////////////////////////////////
// Marks a cash register
///////////////////////////////////////////////////////////////////////////////
class CashRegPoint extends OperateMePoint;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
// External variables
var() Name CustomerStandTag;		// Tag for place where customer is told to stand while
									// they work with me
var() Name NextOperatorStandTag;	// Tag for StandHerePoint to mark where to stand
									// for the next guy to work at this cash register
var() float WorkShiftTime;			// How long a work shift is

var() int ItemCostMax;				// Max amount the item/deal picked will cost
var() int ItemCostMin;				// Min amount the item/deal picked will cost
									// These max and min costs override the prices on
									// inventory items such as milk. This so any inventory
									// item can theoretically be sold, not just ones
									// the few that extend from p2powerupinv.
									// Plus it allows certain dealers to charge more or less.
									// The dude is always charged the max, ItemCostMax, when
									// he visits. The min is really just there for variation
									// for hearing other people buy things.
var() int DealNumberMax;			// Max number of deals offered by this cashier
var() int MaxNumberOfItemsGiven;	// Max number of the items given (from this number down to 1)
var() class<Inventory> ItemGiven;	// Item given to customer after a sale
var() bool bCanUseStasis;			// This determines if the line/cashregister/cashier can all go into
									// stasis if it's appropriate. This should only be used for non-errand lines.
var(Events) name TriggerBeforeDudeUse;		// Event to trigger just as the dude starts the transaction.
var(Events) name TriggerAfterDudeUse;		// Event to trigger after the dude uses the cashier point (whether he pays or not)
var(Events) name TriggerAfterDudePays;		// Event to trigger after the dude pays and receives the item.
var(Events) name TriggerAfterDudeDoesntPay;	// Event to trigger if the dude leaves early or can't afford the item.

// Internal variables
var CashierController CashOp;		// controller for pawn that operates me
var QStartPoint	MyQPoint;			// the queue I take customers from
var KeyPoint CustomerStand;			// Place where customers stand
var KeyPoint NextOperatorStand;		// Place where next guy stands to start work
var P2Pawn NextGuyWaiting;			// Next guy is waiting, ready for work

///////////////////////////////////////////////////////////////////////////////
// Remove the guy who's running me right now
///////////////////////////////////////////////////////////////////////////////
function RemoveCurrentOperator(Controller UseCont)
{
	local BuyerStandPoint BuyerPoint;
	local CashierController CashCont;
	local Actor Other;

	CashCont = CashierController(UseCont);
	if(CashCont == None)
		warn(self$" ERROR, cashop bad or operator not a pawn, cashop: "$UseCont);

	// Tell it about the cashier (don't if it's a qpoint)
	BuyerPoint = BuyerStandPoint(CustomerStand);
	if(BuyerPoint != None)
	{
		BuyerPoint.CashOp = None; // unhook this operator
	}

	// unlink cashier to her stand spot
	CashCont.CustomerStand = None;
	
	// Tell the q if he's getting used, and by who
	if(CustomerStand == MyQPoint)
		MyQPoint.UsingMeAsStand = -1;//currentcashierIndex;
	// unlink with a function
	MyQPoint.RemoveOperator(CashCont);

	// unlink cashier and q together
	CashCont.MyQPoint = None;

	// unlink CashCont
	CashCont = None;

	//log(self$" remove my q point now "$MyQPoint);
}

///////////////////////////////////////////////////////////////////////////////
// Link operator to me
///////////////////////////////////////////////////////////////////////////////
function LinkOperator(int useI)
{
	local P2Pawn p2p;
	local CashierController checkCont;
	local Actor CheckA;

	//log(self$" search LinkOperator ");
	UseTagToNearestActor(OperatorTagList[useI], CheckA, 1.0, , true);
	p2p = P2Pawn(CheckA);
	if(p2p != None)
	{
		checkCont = CashierController(p2p.Controller);
		checkCont.MyCashReg = self;  
	}
	else
		warn(self$" My operator does not exist "$OperatorTagList[useI]);
}

///////////////////////////////////////////////////////////////////////////////
// Get who's to run me now
///////////////////////////////////////////////////////////////////////////////
function SetupCurrentOperator()
{
	local P2Pawn p2p;
	local BuyerStandPoint BuyerPoint;
	local int currentcashierIndex;
	local Actor Other;

	// assign our cashier operator
	UseTagToNearestActor(OperatorTagList[OperatorIndex], MyOperator, 1.0, , true);
	p2p = P2Pawn(MyOperator);

	if(p2p != None)
		CashOp = CashierController(p2p.Controller);

	if(CashOp == None
		|| p2p == None)
	{
		warn(self$" ERROR, cashop bad or operator not a pawn, cashop: "$CashOp$" p2p: "$p2p);
		return;
	}

	// Tell it about the cashier (don't if it's a qpoint)
	BuyerPoint = BuyerStandPoint(CustomerStand);
	if(BuyerPoint != None)
	{
		BuyerPoint.CashOp = CashOp;
	}

	// Link cashier to her stand spot
	CashOp.CustomerStand = CustomerStand;
	
	// Link cashier and q together
	CashOp.MyQPoint = MyQPoint;

	if(MyQPoint != None)
	{
		// This Q could be pointing to other cashiers, so link with a function
		currentcashierIndex = MyQPoint.AddOperator(CashOp);

		// Tell the q if he's getting used, and by who
		if(CustomerStand == MyQPoint)
			MyQPoint.UsingMeAsStand = currentcashierIndex;
	}

	//log(self$" add my q point now "$MyQPoint);
	// Setup our work clock, set it once here, so each time a new person
	// gets setup, there shift starts
	SetTimer(WorkShiftTime, false);
}

///////////////////////////////////////////////////////////////////////////////
// Call this specific guy into work
///////////////////////////////////////////////////////////////////////////////
function CallHimIntoWork(int useI)
{
	local Actor CheckA;
	local P2Pawn NextGuy;
	local CashierController cashcont;

	UseTagToNearestActor(OperatorTagList[useI], CheckA, 1, , true);

	NextGuy = P2Pawn(CheckA);
	cashcont = CashierController(NextGuy.Controller);

	if(NextGuy == None
		|| cashcont == None)
	{
		warn(self$" ERROR: next guy "$NextGuy$" none or not a cashier controller "$cashcont);
		return;
	}

	//log(self$" get this guy into work "$NextGuy);
	// Tell the next guy to go to work now that we have him
	LinkOperator(useI);
	if(cashcont.Attacker == None)
		cashcont.GotoState('GotoWork');
}

///////////////////////////////////////////////////////////////////////////////
// Work whistle has blown, tell the other guys in the list they need to get
// their butts to work
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	local int NextGuyI; 

	NextGuyI = GetNextOperatorIndex();

	//log(self$" trying to call someone else in to work");
	// We must have multiple guys to call
	if(NextGuyI != OperatorIndex)
	{
		CallHimIntoWork(NextGuyI);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Link up pointers and find tags
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state LinkUp
{
	///////////////////////////////////////////////////////////////////////////////
	// Trigger: we can now be triggered to call our cashier into work.
	// WARNING, we cannot detect if we're currently being operated, so do NOT
	// trigger a cash register that's already manned, or else it will break.
	///////////////////////////////////////////////////////////////////////////////
	event Trigger(Actor Other, Pawn EventInstigator)
	{
		PerformLinkup();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Get the closest to the cashier that the customer can stand (generally
	// with their body pressed up against the counter front)
	///////////////////////////////////////////////////////////////////////////////
	function GetCounterFront()
	{
		local KeyPoint UseStand;

		if(MyQPoint != None
			&& !MyQPoint.bDeleteMe)
		{
			if(CustomerStandTag != 'None')
				UseStand = CustomerStand;
			MyQPoint.FindCounterFront(Location, UseStand);
		}
	}

	function PerformLinkup()
	{
		local Actor Other;
		//log("linking me "$self);
		// Find the Queue
		UseTagToNearestActor(InputTag, MyInput, 1.0);
		MyQPoint = QStartPoint(MyInput);
		if(MyQPoint == None)
			warn(self$" ERROR, my qpoint is none");

		// Find place where customers stand for me
		UseTagToNearestActor(CustomerStandTag, Other, 1.0);
		CustomerStand = KeyPoint(Other);
		// Link the customer stand to the cashier
		if(CustomerStand == None)
		{
			// If we couldn't find it, or there is none, then just link it
			// to the queue start
			CustomerStand = MyQPoint;
		}

		if(CustomerStand == None)
			warn(self$" ERROR: customer stand invalid, no q point either");

		// Find place where next operator to work stands
		UseTagToNearestActor(NextOperatorStandTag, Other, 1.0);
		NextOperatorStand = KeyPoint(Other);
		if(NextOperatorStand == None)
		{
			// If we couldn't find it, or there is none, then just link it
			// to the cash register itself, though this is not ideal
			NextOperatorStand = self;
			//log(self$" no valid customer stand, using queue "$MyQPoint);
		}

		// Find the cashier
		LinkOperator(OperatorIndex);
		// Tell him to go to work, this first guy
		CallHimIntoWork(OperatorIndex);
	}
Begin:
	Sleep(0.0);
	PerformLinkup();
	GetCounterFront();
}

defaultproperties
{
	Texture=Texture'PostEd.Icons_256.CashRegPoint'
	WorkShiftTime=8
	ItemCostMax=40
	ItemCostMin=5
	DealNumberMax=5
	MaxNumberOfItemsGiven=1
	ItemGiven=class'Inventory.CrackInv'
	DrawScale=0.25
}
