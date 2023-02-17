/**
 * CashierDialogPawn
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * A special cashier Pawn that causes the player to play out some dialog
 * between the cashier and the Dude.
 *
 * @author Gordon Cheng
 */
class CashierDialogPawn extends Bystander
    placeable;

/** Different types of speakers for the dialog */
enum ESpeaker {
    SPKR_Self,
    SPKR_Dude,
    SPKR_Corey
};

/** A single line of dialog spoken by the NPC, the Dude, or Corey */
struct DialogLine {
    var() array<sound> Sounds;
    var() array<name> GestureAnims;
    var() ESpeaker Speaker;
};

/** List of DialogLines that come together to create a short dialog script */
struct DialogScript {
    var() array<DialogLine> Script;
};

/**
 * Set of DialogScripts that all basically convey the same mesage, but we can
 * vary how we say it, like do we do it in a friendly, annoyed, or angry way.
 * It also includes policies on choosing the right response
 */
struct Responses {
    var() int ResponseLevel;
    var() bool bRandomizeResponses;
    var() bool bIncrOnComplete, bIncrOnLeave, bIncrOnBuy;
    var() bool bDecrOnComplete, bDecrOnLeave, bDecrOnBuy;
    var() array<DialogScript> DialogScripts;
};

/** Dialog chances can now be influenced by the mapper */
var(DialogScript) float NicetiesChance, DoesntBuyChance;

/** Different responses that a mapper can setup */
var(DialogScript) Responses DudeHasNoItemsResponses, DudeOrdersResponses,
    DudeHasInsufficientFundsResponses, DudeHasNoMoneyPreCostResponses,
    DudeHasNoMoneyPostCostResponses, DudeBuysResponses;

defaultproperties
{
	ActorID="Cashier"
    DudeHasNoItemsResponses=(DialogScripts=((script=((Sounds=(Sound'WFemaleDialog.wf_hello',Sound'WFemaleDialog.wf_hi',Sound'WFemaleDialog.wf_hey'),GestureAnims=("s_gesture1")),(Sounds=(Sound'DudeDialog.dude_hithere'),Speaker=SPKR_Dude),(Sounds=(Sound'WFemaleDialog.wf_hmmmm')),(Sounds=(Sound'WFemaleDialog.wf_howcanihelpyou',Sound'WFemaleDialog.wf_cananyonehelpyou'),GestureAnims=("s_gesture1","s_gesture2","s_gesture3")),(Sounds=(Sound'DudeDialog.dude_imsowrong',Sound'DudeDialog.dude_imsorry',Sound'DudeDialog.dude_oops',Sound'DudeDialog.oops',Sound'DudeDialog.dude_mybad',Sound'DudeDialog.mybad',Sound'DudeDialog.dude_thatwasbadofme'),Speaker=SPKR_Dude)))))
    DudeOrdersResponses=(DialogScripts=((script=((Sounds=(Sound'WFemaleDialog.wf_hello',Sound'WFemaleDialog.wf_hi',Sound'WFemaleDialog.wf_hey'),GestureAnims=("s_gesture1")),(Sounds=(Sound'DudeDialog.dude_hithere'),Speaker=SPKR_Dude),(Sounds=(Sound'WFemaleDialog.wf_isthiseverything'),GestureAnims=("s_gesture1","s_gesture2","s_gesture3")),(Sounds=(Sound'DudeDialog.dude_yes'),Speaker=SPKR_Dude)))))
    DudeHasInsufficientFundsResponses=(DialogScripts=((script=((Sounds=(Sound'WFemaleDialog.wf_hmmmm'),GestureAnims=("s_gesture1","s_gesture2","s_gesture3")),(Sounds=(Sound'WFemaleDialog.wf_comebackwhenyou',Sound'WFemaleDialog.wf_imsorrybutyouneed'),GestureAnims=("s_gesture1","s_gesture2","s_gesture3")),(Sounds=(Sound'DudeDialog.dude_imsowrong',Sound'DudeDialog.dude_imsorry',Sound'DudeDialog.dude_oops',Sound'DudeDialog.oops',Sound'DudeDialog.dude_mybad',Sound'DudeDialog.mybad',Sound'DudeDialog.dude_thatwasbadofme'),Speaker=SPKR_Dude)))))
    DudeHasNoMoneyPreCostResponses=(DialogScripts=((script=((Sounds=(Sound'WFemaleDialog.wf_hello',Sound'WFemaleDialog.wf_hi',Sound'WFemaleDialog.wf_hey'),GestureAnims=("s_gesture1")),(Sounds=(Sound'DudeDialog.dude_hithere'),Speaker=SPKR_Dude)))))
    DudeHasNoMoneyPostCostResponses=(DialogScripts=((script=((Sounds=(Sound'WFemaleDialog.wf_hmmmm'),GestureAnims=("s_gesture1")),(Sounds=(Sound'WFemaleDialog.wf_comebackwhenyou',Sound'WFemaleDialog.wf_imsorrybutyouneed'),GestureAnims=("s_gesture1","s_gesture2","s_gesture3")),(Sounds=(Sound'DudeDialog.dude_imsowrong',Sound'DudeDialog.dude_imsorry',Sound'DudeDialog.dude_oops',Sound'DudeDialog.oops',Sound'DudeDialog.dude_mybad',Sound'DudeDialog.mybad',Sound'DudeDialog.dude_thatwasbadofme'),Speaker=SPKR_Dude),(Sounds=(Sound'DudeDialog.dude_hmmalloutofcash',Sound'DudeDialog.dude_hmmalloutofcash2'),Speaker=SPKR_Dude)))))
    DudeBuysResponses=(DialogScripts=((script=((Sounds=(Sound'WFemaleDialog.wf_okaygreatandthank',Sound'WFemaleDialog.wf_andcomeagain',Sound'WFemaleDialog.wf_thatllworkthanks'),GestureAnims=("s_take")),(Sounds=(Sound'DudeDialog.dude_sure',Sound'DudeDialog.dude_ifyousayso',Sound'DudeDialog.dude_soundsreasonable',Sound'DudeDialog.dude_okay'),Speaker=SPKR_Dude)))))

    bUsePawnSlider=true

	Skins(0)=texture'ChameleonSkins.FM__122__Fem_LS_Pants'
	Mesh=Mesh'Characters.Fem_LS_Pants'

	ChameleonSkins.Empty
	RandomizedBoltons.Empty

	NicetiesChance=0.25
	DoesntBuyChance=0.1

	bInnocent=true

    ControllerClass=class'CashierDialogController'
	AmbientGlow=30
	bCellUser=false
}