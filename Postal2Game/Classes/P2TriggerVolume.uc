///////////////////////////////////////////////////////////////////////////////
// P2TriggerVolume
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
//
// A volume class that works like linking a trigger up to a volume via
// AssociatedActorTag, but without actually having to place a trigger and
// link it up. Hooray for laziness!
///////////////////////////////////////////////////////////////////////////////
class P2TriggerVolume extends PhysicsVolume;

struct DayEvent
{
	var() string DayName;		// Name of day (DAY_A, etc.)
	var() name Event;		// Event to trigger on this day
};

var(Days) array<DayEvent> DayEvents;	// If set, activates certain Events on certain days.

var() enum ETriggerType
{
	TT_PlayerProximity,	// Trigger is activated by player proximity.
	TT_PawnProximity,	// Trigger is activated by any pawn's proximity
	TT_ClassProximity,	// Trigger is activated by actor of ClassProximityType only
	TT_AnyProximity,    // Trigger is activated by any actor in proximity.
	TT_Shoot,		    // Trigger is activated by player shooting it.
	TT_HumanPlayerProximity,	// Trigger activated by human player (not bot)
} TriggerType;

var() localized string Message;
var() bool bTriggerOnceOnly;
var() bool bInitiallyActive;
var() class<actor> ClassProximityType;
var() float RepeatTriggerTime; //if > 0, repeat trigger message at this interval is still touching other
var() float ReTriggerDelay; //minimum time before trigger can be triggered again
var() float DamageThreshold; //minimum damage to trigger if TT_Shoot

var float TriggerTime;

// AI vars
var	actor TriggerActor;	// actor that triggers this trigger
var actor TriggerActor2;

// store for reset

var bool bSavedInitialCollision;
var bool bSavedInitialActive;

///////////////////////////////////////////////////////////////////////////////
// Set our Event to whatever day it is.
///////////////////////////////////////////////////////////////////////////////
function GameInfoIsNowValid()
{
	local int i;
	
	for (i = 0; i < DayEvents.Length; i++)
		if (P2GameInfoSingle(Level.Game).IsDay(DayEvents[i].DayName))
			Event = DayEvents[i].Event;
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( (TriggerType == TT_PlayerProximity)
		|| (TriggerType == TT_PawnProximity)
		|| (TriggerType == TT_HumanPlayerProximity)
		|| ((TriggerType == TT_ClassProximity) && ClassIsChildOf(ClassProximityType,class'Pawn')) )
		OnlyAffectPawns(true);
}

simulated function PostBeginPlay()
{
	if ( !bInitiallyActive )
		FindTriggerActor();
	if ( TriggerType == TT_Shoot )
	{
		bHidden = false;
		bProjTarget = true;
		SetDrawType(DT_None);
	}
	bSavedInitialActive = bInitiallyActive;
	bSavedInitialCollision = bCollideActors;
	Super.PostBeginPlay();
}

function Reset()
{
	Super.Reset();

	// collision, bInitiallyactive
	bInitiallyActive = bSavedInitialActive;
	SetCollision(bSavedInitialCollision, bBlockActors, bBlockPlayers );
}


function FindTriggerActor()
{
	local Actor A;

	TriggerActor = None;
	TriggerActor2 = None;
	ForEach AllActors(class 'Actor', A)
		if ( A.Event == Tag)
		{
			if (TriggerActor == None)
				TriggerActor = A;
			else
			{
				TriggerActor2 = A;
				return;
			}
		}
}

function Actor SpecialHandling(Pawn Other)
{
	local Actor A;

	if ( bTriggerOnceOnly && !bCollideActors )
		return None;

	if ( (TriggerType == TT_HumanPlayerProximity) && !Other.IsHumanControlled() )
		return None;

	if ( (TriggerType == TT_PlayerProximity) && !Other.IsPlayerPawn() )
		return None;

	if ( !bInitiallyActive )
	{
		if ( TriggerActor == None )
			FindTriggerActor();
		if ( TriggerActor == None )
			return None;
		if ( (TriggerActor2 != None)
			&& (VSize(TriggerActor2.Location - Other.Location) < VSize(TriggerActor.Location - Other.Location)) )
			return TriggerActor2;
		else
			return TriggerActor;
	}

	// is this a shootable trigger?
	if ( TriggerType == TT_Shoot )
		return Other.ShootSpecial(self);

	// can other trigger it right away?
	if ( IsRelevant(Other) )
	{
		ForEach TouchingActors(class'Actor', A)
			if ( A == Other )
				Touch(Other);
		return self;
	}

	return self;
}

function CheckTouchList()
{
	local Actor A;

	ForEach TouchingActors(class'Actor', A)
		Touch(A);
}

state() NormalTrigger
{
}

state() OtherTriggerToggles
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		bInitiallyActive = !bInitiallyActive;
		if ( bInitiallyActive )
			CheckTouchList();
	}
}

state() OtherTriggerTurnsOn
{
	function Trigger(Actor Other, Pawn EventInstigator)
	{
		local bool bWasActive;

		bWasActive = bInitiallyActive;
		bInitiallyActive = true;

		if (!bWasActive)
			CheckTouchList();
	}
}

state() OtherTriggerTurnsOff
{
	function Trigger(Actor Other, pawn EventInstigator)
	{
		bInitiallyActive = false;
	}
}

function bool IsRelevant(Actor Other)
{
	if(!bInitiallyActive)
		return false;
	switch(TriggerType)
	{
	    case TT_HumanPlayerProximity:    return (Pawn(Other) != None) && Pawn(Other).IsHumanControlled();
		case TT_PlayerProximity:         return (Pawn(Other) != None) && (Pawn(Other).IsPlayerPawn() || Pawn(Other).WasPlayerPawn());
		//case TT_PawnProximity:           return (Pawn(Other) != None) && Pawn(Other).CanTrigger(self);
		case TT_ClassProximity:          return ClassIsChildOf(Other.Class, ClassProximityType);
		case TT_AnyProximity:            return true;
		case TT_Shoot:                   return ((Projectile(Other) != None) && (Projectile(Other).Damage >= DamageThreshold));
	}
}

simulated function PawnEnteredVolume(Pawn Other)
{
	local int i;

	if(IsRelevant(Other))
	{
		if (ReTriggerDelay > 0)
		{
			if (Level.TimeSeconds - TriggerTime < ReTriggerDelay)
				return;

			TriggerTime = Level.TimeSeconds;
		}

		TriggerEvent(Event, self, Other.Instigator);

		if (Other != None && Other.Controller != None)
		{
			for (i=0;i<4;i++)
				if (Other.Controller.GoalList[i] == self)
				{
					Other.Controller.GoalList[i] = None;
					break;
				}
		}

		if((Message != "") && (Other.Instigator != None))
			Other.Instigator.ClientMessage( Message );

		if(bTriggerOnceOnly)
			SetCollision(false);
		else if (RepeatTriggerTime > 0)
			SetTimer(RepeatTriggerTime, false);
	}
}

function Timer()
{
	local bool bKeepTiming;
	local Actor A;

	bKeepTiming = false;

	foreach TouchingActors(class'Actor', A)
		if (IsRelevant(A))
		{
			bKeepTiming = true;
			Touch(A);
		}

	if (bKeepTiming)
		SetTimer(RepeatTriggerTime, false);
}

function TakeDamage(int Damage, Pawn instigatedBy, vector hitlocation, vector momentum, class<DamageType> DamageType)
{
	if (bInitiallyActive && (TriggerType == TT_Shoot) && (Damage >= DamageThreshold) && (instigatedBy != None))
	{
		if (ReTriggerDelay > 0)
		{
			if (Level.TimeSeconds - TriggerTime < ReTriggerDelay)
				return;

			TriggerTime = Level.TimeSeconds;
		}

		TriggerEvent(Event, self, instigatedBy);

		if (Message != "")
			InstigatedBy.Instigator.ClientMessage(Message);

		if (bTriggerOnceOnly)
			SetCollision(False);
	}
}

simulated function PawnLeavingVolume(Pawn Other)
{
	if (IsRelevant(Other))
		UntriggerEvent(Event, self, Other.Instigator);
}

/*
simulated function PostBeginPlay();

simulated function PhysicsChangedFor(Actor Other);
simulated function ActorEnteredVolume(Actor Other);
simulated function ActorLeavingVolume(Actor Other);
simulated function PawnEnteredVolume(Pawn Other);
simulated function PawnLeavingVolume(Pawn Other);
*/

function TimerPop(VolumeTimer T);
function Trigger(Actor Other, Pawn EventInstigator);
event touch(Actor Other);
function PlayEntrySplash(Actor Other);
event untouch(Actor Other);
function PlayExitSplash(Actor Other);
function CausePainTo(Actor Other);

defaultproperties
{
	bInitiallyActive=True
	Gravity=(Z=-3000.000000)
	bColored=true
	BrushColor=(A=255,B=254,G=249,R=33)
	bStatic=false
}
