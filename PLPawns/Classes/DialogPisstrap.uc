///////////////////////////////////////////////////////////////////////////////
// Pisstrap partner dialog
///////////////////////////////////////////////////////////////////////////////
class DialogPisstrap extends DialogGeneric;

///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
// This is only for a partner pawn so we don't need very many lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
{
	// Let super go first
	Super.FillInLines();

	Clear(lSeesEnemy);
	Addto(lSeesEnemy,							"PisstrapDialog.CombatTaunts.PissTrap-FloppyDrive", 1);
	Addto(lSeesEnemy,							"PisstrapDialog.CombatTaunts.PissTrap-IntoWatersports", 1);
	Addto(lSeesEnemy,							"PisstrapDialog.CombatTaunts.PissTrap-MotherFlusher", 1);
	Addto(lSeesEnemy,							"PisstrapDialog.CombatTaunts.PissTrap-PissedOffRobotMode", 1);
	Addto(lSeesEnemy,							"PisstrapDialog.CombatTaunts.PissTrap-SuckItDown", 1);
	Addto(lSeesEnemy,							"PisstrapDialog.CombatTaunts.PissTrap-TearThisMeatbag", 1);
	Addto(lSeesEnemy,							"PisstrapDialog.CombatTaunts.PissTrap-URINATE", 1);	
	Addto(lSeesEnemy,							"PisstrapDialog.CombatTaunts.PissTrap-YourOwnMedicine", 1);
	
	Clear(lgothit);
	Addto(lgothit,								"PisstrapDialog.Pain.PissTrap-LeaveADent", 1);	
	Addto(lgothit,								"PisstrapDialog.Pain.PissTrap-NotInTheDrain", 1);	
	Addto(lgothit,								"PisstrapDialog.Pain.PissTrap-OwMyRam", 1);	
	Addto(lgothit,								"PisstrapDialog.Pain.PissTrap-PainAck", 1);	
	Addto(lgothit,								"PisstrapDialog.Pain.PissTrap-PainAiee", 1);	
	Addto(lgothit,								"PisstrapDialog.Pain.PissTrap-PainArgh", 1);	
	Addto(lgothit,								"PisstrapDialog.Pain.PissTrap-PainAugh", 1);	
	Addto(lgothit,								"PisstrapDialog.Pain.PissTrap-PainOw", 1);	
	Addto(lgothit,								"PisstrapDialog.Pain.PissTrap-PainOwie", 1);	
	Addto(lgothit,								"PisstrapDialog.Pain.PissTrap-PainSensoryUnit", 1);	
	Addto(lgothit,								"PisstrapDialog.Pain.PissTrap-PissedMeOff", 1);	
	Addto(lgothit,								"PisstrapDialog.Pain.PissTrap-WannaPlayRough", 1);	
	Addto(lgothit,								"PisstrapDialog.Pain.PissTrap-WhyWasIProgrammed", 1);	

	Clear(lgreeting);
	Addto(lgreeting,							"PisstrapDialog.Greetings.PissTrap-AdjustAimingReticule", 1);
	Addto(lgreeting,							"PisstrapDialog.Greetings.PissTrap-CallMePissTrap", 1);
	Addto(lgreeting,							"PisstrapDialog.Greetings.PissTrap-PeeBuddy", 1);
	Addto(lgreeting,							"PisstrapDialog.Greetings.PissTrap-ProperMaintenance", 1);
	Addto(lgreeting,							"PisstrapDialog.Greetings.PissTrap-WouldYouLikeHelp", 1);

	Clear(lGenericQuestion);	
	Addto(lGenericQuestion,						"PisstrapDialog.Idle.PissTrap-BeautifulDay", 1);
	Addto(lGenericQuestion,						"PisstrapDialog.Idle.PissTrap-DaisyDaisy", 1);
	Addto(lGenericQuestion,						"PisstrapDialog.Idle.PissTrap-DontWhizOn", 1);
	Addto(lGenericQuestion,						"PisstrapDialog.Idle.PissTrap-FartboxTime", 1);
	Addto(lGenericQuestion,						"PisstrapDialog.Idle.PissTrap-HateMyLife", 1);
	Addto(lGenericQuestion,						"PisstrapDialog.Idle.PissTrap-Humming", 1);
	Addto(lGenericQuestion,						"PisstrapDialog.Idle.PissTrap-MoreToLife", 1);
	Addto(lGenericQuestion,						"PisstrapDialog.Idle.PissTrap-WonderWhatItsLike", 1);
}