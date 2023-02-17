/**
 * CashierDialogController
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * A special AI Cashier Controller that's paired with the CashierDialogPawn
 * which can have various dialog with the Dude customized fully by the mapper
 * allowing for custom buy, no money, no enough money, etc, back and forth
 * conversations between the Cashier and the Dude.
 *
 * @author Gordon Cheng
 */
class CashierDialogController extends FFCashierController;

/** Our dialog Pawn that contains all the mapper made dialog scripts */
var bool bCompletedDialogScript;
var int ScriptPtr;
var CashierDialogPawn DialogPawn;
var Head DialogHead;
var CashierDialogPawn.DialogScript DialogScript;

const CHANNEL_MOUTH = 2;

const MAX_TALK_TIME = 10.0;

// This seems unnecessary as it only prevents dialog cashiers from being triggered to attack the player.
// function Trigger(Actor Other, Pawn EventInstigator);

/**
 * Overriden so we create a reference to a CashierDialogPawn that contains our
 * mapper created dialogs
 */
function Possess(Pawn aPawn) {
    DialogPawn = CashierDialogPawn(aPawn);

    if (DialogPawn != none) {
        HowAreYouFreq = DialogPawn.NicetiesChance;
        CustomerDoesntBuy = DialogPawn.DoesntBuyChance;

        DialogHead = Head(DialogPawn.myHead);
    }

    super.Possess(aPawn);
}

/**
 * Given a set of possible responses, return a DialogScript that contains the
 * back and forth conversation for the Cashier and Postal Dude
 *
 * @param Responses - Basically a set of DialogScripts and response level
 * @return A DialogScript that contains the back and forth between
 */
function CashierDialogPawn.DialogScript GetDialogScript(
    CashierDialogPawn.Responses Responses) {

    if (Responses.bRandomizeResponses)
        return Responses.DialogScripts[Rand(Responses.DialogScripts.length)];
    else
        return Responses.DialogScripts[Responses.ResponseLevel];
}

/**
 * Returns a random animation from the list
 *
 * @param Anims - A list of animation names to choose a random one from
 * @param A random animation name from the given list of animation names
 */
function name GetRandomAnim(array<name> Anims) {
    if (Anims.length == 0)
        return '';

    return Anims[Rand(Anims.length)];
}

/**
 * Returns a random sound from the list
 *
 * @param Sounds - A list of sounds to choose a random one from
 * @return A random sound from the given list of sounds
 */
function sound GetRandomSound(array<sound> Sounds) {
    if (Sounds.length == 0)
        return none;

    return Sounds[Rand(Sounds.length)];
}

/**
 * Enable or disable the head talking animation
 *
 * @param bLoopAnim - If TRUE, play and loop the animation; FALSE, we stop it
 */
function SetHeadTalking(bool bLoopAnim) {

    if (DialogHead == none)
        return;

    if (bLoopAnim) {

        DialogHead.AnimBlendParams(CHANNEL_MOUTH, 1);
	    DialogHead.LoopAnim('talk', 1, 0.1, CHANNEL_MOUTH);
    }
    else {

        // May need a cleaner way of stopping animations, this should
        // suffice for now though
        DialogHead.AnimBlendParams(CHANNEL_MOUTH, 0, 0.1);
    }
}

/**
 * Enables or disables the HUD effect when Corey speaks
 *
 * @param bShowEffect - If TRUE, we would show the effect; FALSE, we hide it
 */
function SetCoreyEffect(bool bShowEffect) {

    if (AWDude(CustomerPawn) == none ||
        P2Hud(PlayerController(CustomerPawn.Controller).myHUD) == none)
        return;

    if (bShowEffect) {

        AWDude(CustomerPawn).HasHeadInjury = 1;
        P2Hud(PlayerController(CustomerPawn.Controller).myHUD).DoWalkHeadInjury();
    }
    else {

        AWDude(CustomerPawn).HasHeadInjury = 0;
        P2Hud(PlayerController(CustomerPawn.Controller).myHUD).StopHeadInjury();
    }
}

/**
 * Updates a specified response based on whether or not we've completed the
 * dialog script or not
 *
 * @param Response - The Response in which we'll update the response level of
 * @param bCompletedScript - Whether or not the Pawn completed the dialog
 */
function UpdateResponseLevel(CashierDialogPawn.Responses Response,
                             bool bCompletedScript) {
    if (bCompletedScript) {

        //log("Updating the script after completing DialogScript");

        if (Response.bIncrOnComplete)
            Response.ResponseLevel = Min(Response.ResponseLevel + 1,
                Response.DialogScripts.length - 1);

        if (Response.bDecrOnComplete)
            Response.ResponseLevel = Max(Response.ResponseLevel - 1, 0);
    }
    else {

        //log("Updating the script after leaving DialogScript");

        if (Response.bIncrOnLeave)
            Response.ResponseLevel = Min(Response.ResponseLevel + 1,
                Response.DialogScripts.length - 1);

        if (Response.bDecrOnLeave)
            Response.ResponseLevel = Max(Response.ResponseLevel - 1, 0);
    }
}

/** Updates all the responses after a purchase has been made */
function UpdateResponseAfterBuy(CashierDialogPawn.Responses Response) {

    if (Response.bIncrOnComplete)
        Response.ResponseLevel = Min(Response.ResponseLevel + 1,
            Response.DialogScripts.length - 1);

    if (Response.bDecrOnComplete)
        Response.ResponseLevel = Max(Response.ResponseLevel - 1, 0);
}

/**
 * Similar to the TalkSome function, only here we use sounds directly as
 * opposed to dialog entries so mappers can set them up.
 *
 * @param DialogLine - A struct containing all the info for a line of dialog
 * @return Time in seconds the sound will take to finish speaking
 */
function float SayDialogLine(CashierDialogPawn.DialogLine DialogLine) {
    local float SayTime, AnimRate;
    local name GestureAnim;
    local sound Line;

    if (DialogLine.Sounds.length == 0 || MyPawn == none || CustomerPawn == none)
        return 0.1;

    Line = GetRandomSound(DialogLine.Sounds);

    if (Line == none)
        return 0.1;

    SayTime = GetSoundDuration(Line);

    if (SayTime <= 1.0)
        AnimRate = 1.0 + (1.0 - SayTime);
    else if (SayTime < MAX_TALK_TIME)
        AnimRate = 1.0 - (SayTime / (2 * MAX_TALK_TIME));
    else
        AnimRate = 0.5;

    GestureAnim = GetRandomAnim(DialogLine.GestureAnims);

    if (GestureAnim != '' && GestureAnim != 'None')
        MyPawn.PlayAnim(GestureAnim, AnimRate, 0.15);

    switch (DialogLine.Speaker) {
        case SPKR_Self:
            MyPawn.PlaySound(Line, SLOT_Talk, 1, false, 300);
            break;

        case SPKR_Dude:
            CustomerPawn.PlaySound(Line, SLOT_Talk, 1, false, 300);
            break;

        case SPKR_Corey:
            CustomerPawn.PlaySound(Line, SLOT_Talk, 1, false, 300);
            break;
    }

    return SayTime;
}

/**
 * I believe this is the state in which the Dude doesn't have the item he
 * needs to pay with, such as Money for in most cases
 */
state DudeHasNoItem
{
    function EndState() {
        super.EndState();

        SetCoreyEffect(false);
        SetHeadTalking(false);

        UpdateResponseLevel(DialogPawn.DudeHasNoItemsResponses,
            bCompletedDialogScript);

        bCompletedDialogScript = true;
    }

Begin:

    if (DialogPawn == none || DialogHead == none)
	    GotoState('WaitForCustomers');

    if (CheckToGiggle())
		Sleep(SayTime);

    bCompletedDialogScript = false;

    DialogScript = GetDialogScript(DialogPawn.DudeHasNoItemsResponses);

    for (ScriptPtr=0;ScriptPtr<DialogScript.Script.length;ScriptPtr++) {

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Corey)
            SetCoreyEffect(true);

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Self)
            SetHeadTalking(true);

        Sleep(SayDialogLine(DialogScript.Script[ScriptPtr]) + FRand());

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Corey)
            SetCoreyEffect(false);

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Self)
            SetHeadTalking(false);
    }

    bCompletedDialogScript = true;

	if (MyCashReg != none) {
		TriggerEvent(MyCashReg.TriggerAfterDudeUse, MyPawn, InterestPawn);
		TriggerEvent(MyCashReg.TriggerAfterDudeDoesntPay, MyPawn, InterestPawn);
	}

    GotoState('WaitForCustomers');
}

/**
 * This is the most common state players would encounter, and this is basically
 * the Postal Dude getting asked to confirm his order, and the cashier stating
 * how much the item will cost.
 */
state WaitOnDudeToPay
{
    function EndState() {
        super.EndState();

        SetCoreyEffect(false);
        SetHeadTalking(false);

        UpdateResponseLevel(DialogPawn.DudeOrdersResponses,
            bCompletedDialogScript);

        bCompletedDialogScript = true;
    }

Begin:

	if (DialogPawn == none || DialogHead == none)
	    GotoState('WaitForCustomers');

    if (CheckToGiggle())
		Sleep(SayTime);

    bCompletedDialogScript = false;

    if (MyCashReg != None)
		TriggerEvent(MyCashReg.TriggerBeforeDudeUse, MyPawn, InterestPawn);

    DialogScript = GetDialogScript(DialogPawn.DudeOrdersResponses);

    for (ScriptPtr=0;ScriptPtr<DialogScript.Script.length;ScriptPtr++) {

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Corey)
            SetCoreyEffect(true);

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Self)
            SetHeadTalking(true);

        Sleep(SayDialogLine(DialogScript.Script[ScriptPtr]) + FRand());

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Corey)
            SetCoreyEffect(false);

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Self)
            SetHeadTalking(false);
    }

    statecount = GetTotalCostOfYourProducts(CustomerPawn, MyPawn);
	Sleep(Say(MyPawn.myDialog.lNumbers_Thatllbe, bImportantDialog));
	//Sleep(SayTime);

    Sleep(SayThisNumber(statecount,,bImportantDialog));
	//Sleep(SayTime + 0.1);

    if (statecount > 1)
		Sleep(Say(MyPawn.myDialog.lNumbers_Dollars, bImportantDialog));
	else
		Sleep(Say(MyPawn.myDialog.lNumbers_SingleDollar, bImportantDialog));

	bCompletedDialogScript = true;

    //Sleep(SayTime + FRand());
}

/**
 * As the name of the state implies, this is the state where the Postal Dude
 * is told that he has money, but doesn't have enough to buy the product
 */
state DudeHasInsufficientFunds
{
    function EndState() {
        super.EndState();

        SetCoreyEffect(false);
        SetHeadTalking(false);

        UpdateResponseLevel(DialogPawn.DudeHasInsufficientFundsResponses,
            bCompletedDialogScript);

        bCompletedDialogScript = true;
    }

Begin:

    if (DialogPawn == none || DialogHead == none)
	    GotoState('WaitForCustomers');

    if (CheckToGiggle())
		Sleep(SayTime);

    bCompletedDialogScript = false;

    DialogScript = GetDialogScript(DialogPawn.DudeHasInsufficientFundsResponses);

    for (ScriptPtr=0;ScriptPtr<DialogScript.Script.length;ScriptPtr++) {

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Corey)
            SetCoreyEffect(true);

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Self)
            SetHeadTalking(true);

        Sleep(SayDialogLine(DialogScript.Script[ScriptPtr]) + FRand());

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Corey)
            SetCoreyEffect(false);

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Self)
            SetHeadTalking(false);
    }

	if (MyCashReg != None) {
		TriggerEvent(MyCashReg.TriggerAfterDudeUse, MyPawn, InterestPawn);
		TriggerEvent(MyCashReg.TriggerAfterDudeDoesntPay, MyPawn, InterestPawn);
	}

	bCompletedDialogScript = true;

	GotoState('WaitForCustomers');
}

/**
 * In this state, we do have a Money in our inventory, but the amount is less
 * than or equal to zero. Not sure if we ever want to differentiate between
 * this and DudeHasNoItem, but it's here
 */
state DudeHasNoFunds
{
    function EndState() {
        super.EndState();

        SetCoreyEffect(false);
        SetHeadTalking(false);

        UpdateResponseLevel(DialogPawn.DudeHasNoMoneyPreCostResponses,
            bCompletedDialogScript);

        UpdateResponseLevel(DialogPawn.DudeHasNoMoneyPostCostResponses,
            bCompletedDialogScript);

        bCompletedDialogScript = true;
    }

Begin:
	if (DialogPawn == none || DialogHead == none)
	    GotoState('WaitForCustomers');

    if (CheckToGiggle())
		Sleep(SayTime);

    bCompletedDialogScript = false;

    DialogScript = GetDialogScript(DialogPawn.DudeHasNoMoneyPreCostResponses);

    for (ScriptPtr=0;ScriptPtr<DialogScript.Script.length;ScriptPtr++) {

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Corey)
            SetCoreyEffect(true);

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Self)
            SetHeadTalking(true);

        Sleep(SayDialogLine(DialogScript.Script[ScriptPtr]) + FRand());

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Corey)
            SetCoreyEffect(false);

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Self)
            SetHeadTalking(false);
    }

	statecount = GetTotalCostOfYourProducts(CustomerPawn, MyPawn);
	Sleep(Say(MyPawn.myDialog.lNumbers_Thatllbe, bImportantDialog));
	//Sleep(SayTime);

    Sleep(SayThisNumber(statecount,,bImportantDialog));
	//Sleep(SayTime + 0.1);

    if (statecount > 1)
		Sleep(Say(MyPawn.myDialog.lNumbers_Dollars, bImportantDialog));
	else
		Sleep(Say(MyPawn.myDialog.lNumbers_SingleDollar, bImportantDialog));

    //Sleep(SayTime + FRand());

	DialogScript = GetDialogScript(DialogPawn.DudeHasNoMoneyPostCostResponses);

    for (ScriptPtr=0;ScriptPtr<DialogScript.Script.length;ScriptPtr++)
        Sleep(SayDialogLine(DialogScript.Script[ScriptPtr]) + FRand());

	if (MyCashReg != none) {
		TriggerEvent(MyCashReg.TriggerAfterDudeUse, MyPawn, InterestPawn);
		TriggerEvent(MyCashReg.TriggerAfterDudeDoesntPay, MyPawn, InterestPawn);
	}

	bCompletedDialogScript = true;

	GotoState('WaitForCustomers');
}

/**
 * Here is another common state that players would likely see, this is the
 * state where the player hits the Enter key, pays, and gets his or her item.
 */
state TakePaymentFromDude
{
    function BeginState() {
        super.BeginState();

        SetCoreyEffect(false);
        SetHeadTalking(false);

        UpdateResponseAfterBuy(DialogPawn.DudeHasNoItemsResponses);
        UpdateResponseAfterBuy(DialogPawn.DudeOrdersResponses);
        UpdateResponseAfterBuy(DialogPawn.DudeHasInsufficientFundsResponses);
        UpdateResponseAfterBuy(DialogPawn.DudeHasNoMoneyPreCostResponses);
        UpdateResponseAfterBuy(DialogPawn.DudeHasNoMoneyPostCostResponses);
        UpdateResponseAfterBuy(DialogPawn.DudeBuysResponses);
    }

    function EndState() {
        super.EndState();

        UpdateResponseLevel(DialogPawn.DudeBuysResponses,
            bCompletedDialogScript);

        bCompletedDialogScript = true;
    }

Begin:

	if (DialogPawn == none || DialogHead == none)
	    GotoState('WaitForCustomers');

    bCompletedDialogScript = false;

    DialogScript = GetDialogScript(DialogPawn.DudeBuysResponses);

    for (ScriptPtr=0;ScriptPtr<DialogScript.Script.length;ScriptPtr++) {

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Corey)
            SetCoreyEffect(true);

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Self)
            SetHeadTalking(true);

        Sleep(SayDialogLine(DialogScript.Script[ScriptPtr]) + FRand());

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Corey)
            SetCoreyEffect(false);

        if (DialogScript.Script[ScriptPtr].Speaker == SPKR_Self)
            SetHeadTalking(false);
    }

    InterestInventoryClass = MyCashReg.ItemGiven;
	MyPawn.PlayGiveGesture();

	Sleep(DudePaidWaitTime);

	if (MyCashReg != none) {
		TriggerEvent(MyCashReg.TriggerAfterDudeUse, MyPawn, InterestPawn);
		TriggerEvent(MyCashReg.TriggerAfterDudePays, MyPawn, InterestPawn);
	}

	bCompletedDialogScript = true;

	GotoState('WaitForCustomers');
}

defaultproperties
{
}