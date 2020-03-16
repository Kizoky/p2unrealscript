///////////////////////////////////////////////////////////////////////////////
// DialogCowBoss
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for all cowboss monster
//
///////////////////////////////////////////////////////////////////////////////
class DialogCowBoss extends DialogGeneric;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	// introduces himself
	Clear(lgreeting);
	Addto(lgreeting,							"AWDialog.MikeJ.Mikej_KosherZombie2", 1);

	// spitting out heads
	Clear(lSpitting);
	Addto(lSpitting,							"AWDialog.MikeJ.Mikej_WAH", 1);
	Addto(lSpitting,							"AWDialog.MikeJ.Mikej_OOah", 1);
	Addto(lSpitting,							"AWDialog.MikeJ.Mikej_Rawr", 2);
	
	// monster noises
	Clear(lhmm);
	Addto(lhmm,									"AWDialog.MikeJ.Mikej_DieGoy", 1);
	Addto(lhmm,									"AWDialog.MikeJ.Mikej_grunt", 1);
	Addto(lhmm,									"AWDialog.MikeJ.Mikej_Rawr", 2);
	Addto(lhmm,									"AWDialog.MikeJ.Mikej_OOah", 2);
	Addto(lhmm,									"AWDialog.MikeJ.Mikej_WAH", 3);

	// squirting milk
	Clear(ltrashtalk);
	Addto(ltrashtalk,							"AWDialog.MikeJ.Mikej_Youknow", 1);
	Addto(ltrashtalk,							"AWDialog.MikeJ.Mikej_Suckteets", 1);
	Addto(ltrashtalk,							"AWDialog.MikeJ.Mikej_BeholdNipples", 1);
	Addto(ltrashtalk,							"AWDialog.MikeJ.Mikej_BeholdNipples", 2);
	Addto(ltrashtalk,							"AWDialog.MikeJ.Mikej_UH", 3);
	Addto(ltrashtalk,							"AWDialog.MikeJ.Mikej_Uhyeah", 3);

	// Screams of pain as it's hit
	Clear(lgothit);
	Addto(lgothit,								"AWDialog.MikeJ.Mikej_AHHH", 1);
	addto(lgothit,								"AWDialog.MikeJ.Mikej_grunt", 1);	
	addto(lgothit,								"AWDialog.MikeJ.Mikej_shit", 1);
	addto(lgothit,								"AWDialog.MikeJ.Mikej_fuck", 2);

	// throwing fireballs
	Clear(lWhileFighting);
	Addto(lWhileFighting,						"AWDialog.MikeJ.Mikej_bendover", 1);	
	Addto(lWhileFighting,						"AWDialog.MikeJ.Mikej_Yourass", 1);
	Addto(lWhileFighting,						"AWDialog.MikeJ.Mikej_YourchinMyballs", 1);

	// Tourettes babbling
	Clear(lGenericAnswer);	
	Addto(lGenericAnswer,						"AWDialog.MikeJ.Mikej_tourette1", 1);
	Addto(lGenericAnswer,						"AWDialog.MikeJ.Mikej_tourette2", 1);
	Addto(lGenericAnswer,						"AWDialog.MikeJ.Mikej_tourette3", 2);
	Addto(lGenericAnswer,						"AWDialog.MikeJ.Mikej_tourette4", 3);

	// laughs at ineffective damage
	Clear(llaughing);
	Addto(llaughing,							"AWDialog.MikeJ.Mikej_Laugh", 1);
	Addto(llaughing,							"AWDialog.MikeJ.Mikej_Laugh2", 1);
	Addto(llaughing,							"AWDialog.MikeJ.Mikej_Laugh3", 2);
	Addto(llaughing,							"AWDialog.MikeJ.Mikej_Laugh4", 3);

	// dying
	Clear(ldying);
	Addto(ldying,								"AWDialog.MikeJ.Mikej_JDLDeath", 1);
	Addto(ldying,								"AWDialog.MikeJ.Mikej_Myballs", 1);
	}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     TestModeClasses(0)="BasePeople.DialogDude"
     TestModeClasses(1)="BasePeople.DialogFemale"
     TestModeClasses(2)="BasePeople.DialogFemaleCop"
     TestModeClasses(3)="BasePeople.DialogGary"
     TestModeClasses(4)="BasePeople.DialogGeneric"
     TestModeClasses(5)="BasePeople.DialogHabib"
     TestModeClasses(6)="BasePeople.DialogKrotchy"
     TestModeClasses(7)="BasePeople.DialogMale"
     TestModeClasses(8)="BasePeople.DialogMaleCop"
     TestModeClasses(9)="BasePeople.DialogMaleMilitary"
     TestModeClasses(10)="BasePeople.DialogPriest"
     TestModeClasses(11)="BasePeople.DialogRedneck"
     TestModeClasses(12)="BasePeople.DialogVince"
}
