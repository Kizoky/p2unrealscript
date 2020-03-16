///////////////////////////////////////////////////////////////////////////////
// MultiPickup
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// A pickup that can be anything in an array of other pickups. Changes
// with each touch.
//
// It has to spawn all the various pickups in order for each one to give
// the dude the proper things. It holds them in a list and cycles through them
// as they are picked up--not just randomly changing it as it sits there. 
//
///////////////////////////////////////////////////////////////////////////////

class MultiPickup extends P2PowerupPickup;

// List set in the editor of pickups to cycle through
var ()array< class<Pickup> > PickupClasses;
// List used internally of those pickups
var array< Pickup >			PickupList;
// index into above array of pickup currently used
var int CurrIndex;
// Whether or not to randomize the next pickup
var()bool bRandomize;


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();

	//log(self$" class size "$PickupClasses.Length);
	// Make room for the new pickups
	PickupList.Insert(0, PickupClasses.Length);

	// Fill in the array
	for(i=0; i<PickupClasses.Length; i++)
	{
		PickupList[i] = spawn(PickupClasses[i], Owner,,Location);
		PickupList[i].SetCollision(false, false, false);
		ResetPickup(i);
	}
	// Don't draw anything, but don't be hidden either. (we need to
	// not be hidden in order for our pickup parts to work properly)
	//SetDrawType(DT_Mesh);
	bHidden=true;

	// Pick your starting pickup (defaults to 0)
	if(bRandomize)
		CurrIndex = Rand(PickupList.Length);
}

///////////////////////////////////////////////////////////////////////////////
// reset actor to initial state - used when restarting level without reloading.
///////////////////////////////////////////////////////////////////////////////
function Reset()
{
	local int i;

	for(i=0; i<PickupClasses.Length; i++)
		ResetPickup(i);
	if(bRandomize)
		CurrIndex = Rand(PickupList.Length);
	else
		CurrIndex = 0;
	GotoState('Pickup');
}

///////////////////////////////////////////////////////////////////////////////
// Change out one class for another.
// Only to be called by a mutator at PreBeginPlay
///////////////////////////////////////////////////////////////////////////////
function SwapClass(class<Pickup> removethis, class<Pickup> replacer)
{
	local int i;
	// replace the class
	for(i=0; i<PickupClasses.Length; i++)
	{
		if(removethis == PickupClasses[i])
		{
			PickupClasses[i] = replacer;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ResetPickup(int checkint)
{
	PickupList[checkint].GotoState('');
	PickupList[checkint].bHidden=true;
//	log(PickupList[checkint]$" reset my state "$PickupList[checkint].GetStateName());
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PrepPickup(int checkint)
{
	PickupList[checkint].GotoState('Pickup');
	PickupList[checkint].bHidden=false;
//	log(PickupList[checkint]$" prep, my state "$PickupList[checkint].GetStateName());
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function CyclePickup()
{
	ResetPickup(CurrIndex);
	if(bRandomize)
		CurrIndex = Rand(PickupList.Length);
	else
	{
		CurrIndex++;
		if(CurrIndex >= PickupList.Length)
			CurrIndex=0;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Take damage and be force around
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
{
	// STUB out--don't let it move
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Pickup.. add the health instantly in MP, store it in inventory in SP
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Pickup
{	
	///////////////////////////////////////////////////////////////////////////////
	// When touched by an actor.
	// Allow pawns to pick this up any time--even in the air just after dropping
	// it, but don't allow the one that dropped it, to grab it before it hits the
	// ground.
	///////////////////////////////////////////////////////////////////////////////
	function Touch( actor Other )
	{
		PickupList[CurrIndex].Touch(Other);

		if(PickupList[CurrIndex].GetStateName() != 'Pickup')
		{
			CyclePickup();
			// Send me to my sleeping state
			SetRespawn();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
	
		PrepPickup(CurrIndex);
		bHidden=true;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
    DrawType=DT_Sprite
    Texture=S_Actor
	bAllowMovement=false
	bNoBotPickup=true
	MaxDesireability = -1.0
	}
