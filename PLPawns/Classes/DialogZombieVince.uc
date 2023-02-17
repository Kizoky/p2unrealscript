///////////////////////////////////////////////////////////////////////////////
// DialogZombie
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Dialog for all zombies
///////////////////////////////////////////////////////////////////////////////
class DialogZombieVince extends DialogZombie;


///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();

	// Gurgling noises when it doesn't have a head but is trying to say something
	Clear(lSpitting);
	Addto(lSpitting,							"PL-Dialog.ZombieVince.ZombieVince-3Heave1", 1);
	Addto(lSpitting,							"PL-Dialog.ZombieVince.ZombieVince-3Heave2", 1);
	Addto(lSpitting,							"PL-Dialog.ZombieVince.ZombieVince-3Heave3", 1);
	Addto(lSpitting,							"PL-Dialog.ZombieVince.ZombieVince-3Heave4", 1);
	
	// Moaning noises as it walks
	Clear(lhmm);
	Addto(lhmm,									"PL-Dialog.ZombieVince.ZombieVince-5Moan1", 1);
	Addto(lhmm,									"PL-Dialog.ZombieVince.ZombieVince-5Moan2", 1);
	Addto(lhmm,									"PL-Dialog.ZombieVince.ZombieVince-5Moan3", 1);

	// These are the zombies Tourette's lines
	Clear(ltrashtalk);
	Addto(ltrashtalk,							"PL-Dialog.ZombieVince.ZombieVince-4Curse1", 1);
	Addto(ltrashtalk,							"PL-Dialog.ZombieVince.ZombieVince-4Curse2", 1);
	Addto(ltrashtalk,							"PL-Dialog.ZombieVince.ZombieVince-4Curse3", 1);
	Addto(ltrashtalk,							"PL-Dialog.ZombieVince.ZombieVince-4Curse4", 1);
	Addto(ltrashtalk,							"PL-Dialog.ZombieVince.ZombieVince-4Curse5", 1);

	// Screams of pain as it's hit
	Clear(lgothit);
	Addto(lgothit,								"PL-Dialog.ZombieVince.ZombieVince-6Pain1", 1);
	Addto(lgothit,								"PL-Dialog.ZombieVince.ZombieVince-6Pain2", 1);
	Addto(lgothit,								"PL-Dialog.ZombieVince.ZombieVince-6Pain3", 1);
	Addto(lgothit,								"PL-Dialog.ZombieVince.ZombieVince-6Pain4", 1);
	Addto(lgothit,								"PL-Dialog.ZombieVince.ZombieVince-6Pain5", 1);
	Addto(lgothit,								"PL-Dialog.ZombieVince.ZombieVince-6Pain6", 1);

	// Sounds they make when they attack
	Clear(lWhileFighting);
	Addto(lWhileFighting,							"PL-Dialog.ZombieVince.ZombieVince-2Grunt1", 1);	
	Addto(lWhileFighting,							"PL-Dialog.ZombieVince.ZombieVince-2Grunt2", 1);	
	Addto(lWhileFighting,							"PL-Dialog.ZombieVince.ZombieVince-2Grunt3", 1);	
	Addto(lWhileFighting,							"PL-Dialog.ZombieVince.ZombieVince-2Grunt4", 1);	
	Addto(lWhileFighting,							"PL-Dialog.ZombieVince.ZombieVince-2Grunt5", 1);	

	// Zombie recognizes player with this moan/grunt
	Clear(linvadeshome);	
	Addto(linvadeshome,							"PL-Dialog.ZombieVince.ZombieVince-4Curse1", 1);
	Addto(linvadeshome,							"PL-Dialog.ZombieVince.ZombieVince-4Curse2", 1);
	Addto(linvadeshome,							"PL-Dialog.ZombieVince.ZombieVince-4Curse3", 1);
	Addto(linvadeshome,							"PL-Dialog.ZombieVince.ZombieVince-4Curse4", 1);
	Addto(linvadeshome,							"PL-Dialog.ZombieVince.ZombieVince-4Curse5", 1);
	Addto(linvadeshome,							"PL-Dialog.ZombieVince.ZombieVince-2Grunt1", 1);
	Addto(linvadeshome,							"PL-Dialog.ZombieVince.ZombieVince-2Grunt2", 1);
	Addto(linvadeshome,							"PL-Dialog.ZombieVince.ZombieVince-2Grunt3", 1);
	Addto(linvadeshome,							"PL-Dialog.ZombieVince.ZombieVince-2Grunt4", 1);
	Addto(linvadeshome,							"PL-Dialog.ZombieVince.ZombieVince-2Grunt5", 1);

	// Zombie dodges to side, out of the way of a sledge hammer
	Clear(lSeesEnemy);	
	Addto(lSeesEnemy,							"PL-Dialog.ZombieVince.ZombieVince-6Pain3", 1);
	Addto(lSeesEnemy,							"PL-Dialog.ZombieVince.ZombieVince-6Pain6", 1);
	Addto(lSeesEnemy,							"PL-Dialog.ZombieVince.ZombieVince-2Grunt1", 2);

	// Tourette's like cussing and babbling
	Clear(lGenericAnswer);	
	Addto(lGenericAnswer,						"PL-Dialog.ZombieVince.ZombieVince-4Curse1", 1);
	Addto(lGenericAnswer,						"PL-Dialog.ZombieVince.ZombieVince-4Curse2", 1);
	Addto(lGenericAnswer,						"PL-Dialog.ZombieVince.ZombieVince-4Curse3", 1);
	Addto(lGenericAnswer,						"PL-Dialog.ZombieVince.ZombieVince-4Curse4", 1);
	Addto(lGenericAnswer,						"PL-Dialog.ZombieVince.ZombieVince-4Curse5", 1);
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
