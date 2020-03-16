///////////////////////////////////////////////////////////////////////////////
// DialogZombie
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for all zombies
//
///////////////////////////////////////////////////////////////////////////////
class DialogZombie extends DialogGeneric;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	// Gurgling noises when it doesn't have a head but is trying to say something
	Clear(lSpitting);
	Addto(lSpitting,							"AWDialog.Zombie.zombie_barf1", 1);
	Addto(lSpitting,							"AWDialog.Zombie.zombie_barf2", 1);
	Addto(lSpitting,							"AWDialog.Zombie.zombie_barf3", 1);
	
	// Moaning noises as it walks
	Clear(lhmm);
	Addto(lhmm,									"AWDialog.Zombie.zombie_moan1", 1);
	Addto(lhmm,									"AWDialog.Zombie.zombie_moan2", 1);
	Addto(lhmm,									"AWDialog.Zombie.zombie_moan3", 1);
	Addto(lhmm,									"AWDialog.Zombie.zombie_moan4", 1);
	Addto(lhmm,									"AWDialog.Zombie.zombie_moan5", 1);
	Addto(lhmm,									"AWDialog.Zombie.zombie_moan6", 1);

	// These are the zombies Tourette's lines
	Clear(ltrashtalk);
	Addto(ltrashtalk,							"AWDialog.Zombie.zombie_curse1", 1);
	Addto(ltrashtalk,							"AWDialog.Zombie.zombie_curse2", 1);
	Addto(ltrashtalk,							"AWDialog.Zombie.zombie_curse3", 1);
	Addto(ltrashtalk,							"AWDialog.Zombie.zombie_curse4", 1);
	Addto(ltrashtalk,							"AWDialog.Zombie.zombie_curse5", 1);
	Addto(ltrashtalk,							"AWDialog.Zombie.zombie_curse6", 1);
	Addto(ltrashtalk,							"AWDialog.Zombie.zombie_curse7", 1);

	// Screams of pain as it's hit
	Clear(lgothit);
	Addto(lgothit,								"AWDialog.Zombie.zombie_pain1", 1);
	addto(lgothit,								"AWDialog.Zombie.zombie_pain2", 1);	
	addto(lgothit,								"AWDialog.Zombie.zombie_pain3", 1);
	addto(lgothit,								"AWDialog.Zombie.zombie_pain4", 1);
	addto(lgothit,								"AWDialog.Zombie.zombie_pain5", 1);
	addto(lgothit,								"AWDialog.Zombie.zombie_pain6", 1);

	// Sounds they make when they attack
	Clear(lWhileFighting);
	Addto(lWhileFighting,							"AWDialog.Zombie.zombie_anger1", 1);	
	Addto(lWhileFighting,							"AWDialog.Zombie.zombie_anger2", 1);
	Addto(lWhileFighting,							"AWDialog.Zombie.zombie_anger3", 1);
	Addto(lWhileFighting,							"AWDialog.Zombie.zombie_anger4", 1);
	Addto(lWhileFighting,							"AWDialog.Zombie.zombie_anger5", 1);
	Addto(lWhileFighting,							"AWDialog.Zombie.zombie_anger6", 1);
	Addto(lWhileFighting,							"AWDialog.Zombie.zombie_anger7", 1);
	Addto(lWhileFighting,							"AWDialog.Zombie.zombie_anger8", 1);

	// Zombie recognizes player with this moan/grunt
	Clear(linvadeshome);	
	Addto(linvadeshome,							"AWDialog.Zombie.zombie_anger2", 1);
	Addto(linvadeshome,							"AWDialog.Zombie.zombie_curse5", 1);
	Addto(linvadeshome,							"AWDialog.Zombie.zombie_anger8", 1);
	Addto(linvadeshome,							"AWDialog.Zombie.zombie_curse3", 1);
	Addto(linvadeshome,							"AWDialog.Zombie.zombie_anger4", 1);
	Addto(linvadeshome,							"AWDialog.Zombie.zombie_anger3", 1);

	// Zombie dodges to side, out of the way of a sledge hammer
	Clear(lSeesEnemy);	
	Addto(lSeesEnemy,							"AWDialog.Zombie.zombie_pain2", 1);
	Addto(lSeesEnemy,							"AWDialog.Zombie.zombie_pain6", 1);
	Addto(lSeesEnemy,							"AWDialog.Zombie.zombie_anger6", 1);

	// Tourette's like cussing and babbling
	Clear(lGenericAnswer);	
	Addto(lGenericAnswer,						"AWDialog.Zombie.zombie_curse1", 1);
	Addto(lGenericAnswer,						"AWDialog.Zombie.zombie_curse2", 1);
	Addto(lGenericAnswer,						"AWDialog.Zombie.zombie_curse3", 1);
	Addto(lGenericAnswer,						"AWDialog.Zombie.zombie_curse4", 1);
	Addto(lGenericAnswer,						"AWDialog.Zombie.zombie_curse5", 1);
	Addto(lGenericAnswer,						"AWDialog.Zombie.zombie_curse6", 1);
	Addto(lGenericAnswer,						"AWDialog.Zombie.zombie_curse7", 1);
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
