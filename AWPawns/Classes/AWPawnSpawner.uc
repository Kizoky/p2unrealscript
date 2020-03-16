///////////////////////////////////////////////////////////////////////////////
// AWPawnSpawner
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Handles pawns for AW pack
//
///////////////////////////////////////////////////////////////////////////////

class AWPawnSpawner extends AWBasePawnSpawner;

/*
var ()float InitTakesSledgeDamage;
var ()float InitTakesMacheteDamage;
var ()float InitTakesScytheDamage;
var (Dervish)float InitAttackFreq;
var (Dervish)float InitDervishTimeMax;
var ()int InitbStartMissingLegs;
var ()float InitTimeTillDissolve;
var (Zombie) float InitChargeFreq;
var (Zombie) float InitVomitFreq;
var (Zombie) float InitMoanFreq;
var ()int InitbCheapBloodSpouts;
var ()float InitTakesZombieSmashDamage;
var ()int InitbLookForZombies;
var ()Material SpawnHeadSkin;
var (Dog)float InitCatchProjFreq;
*/

var bool bHookedToTrigger;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Save that a trigger controls us
	if(bSetActiveAfterTrigger)
		bHookedToTrigger=true;
}


///////////////////////////////////////////////////////////////////////////////
// Do specific things to the spawned object, like to pawns
///////////////////////////////////////////////////////////////////////////////
function SpecificInits(Actor spawned)
{
	Super.SpecificInits(spawned);

	// If you have them to be triggered each time, individually by a trigger
	// and not just triggered once and let loose, then unhook the event
	// that would retrigger this spawner
	if(SpawnRate == 0
		&& bHookedToTrigger)
	{
		spawned.Event='';
	}

	if(P2MocapPawn(spawned) != None
		&& SpawnHeadSkin != None)
	{
		P2MocapPawn(spawned).HeadSkin = SpawnHeadSkin;
		P2MocapPawn(spawned).SetupHead();
	}
}

///////////////////////////////////////////////////////////////////////////////
// If the spawner's event is set, trigger an event using the event field when we get triggered.
// If the event field is empty, it will not relay any event.
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, pawn EventInstigator )
{
	TriggerEvent(Event, Other, EventInstigator);

	Super.Trigger(Other, EventInstigator);
}

defaultproperties
{
     InitTakesSledgeDamage=-1.000000
     InitTakesMacheteDamage=-1.000000
     InitTakesScytheDamage=-1.000000
     InitAttackFreq=-1.000000
     InitDervishTimeMax=-1.000000
     InitbStartMissingLegs=-1
     InitTimeTillDissolve=-1.000000
     InitChargeFreq=-1.000000
     InitVomitFreq=-1.000000
     InitMoanFreq=-1.000000
     InitbCheapBloodSpouts=-1
     InitTakesZombieSmashDamage=-1.000000
     InitbLookForZombies=-1
     InitCatchProjFreq=-1.000000
}
