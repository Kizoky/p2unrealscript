///////////////////////////////////////////////////////////////////////////////
// NowServingBoard
// Copyright 2014, Running With Scissors, Inc.
//
// One of those "waiting room" boards where you get a number and you wait for
// your number to be called.
//
// Gradually ticks up from its current value as long as the following
// requirements are met:
//
//		* Dude must be within a Volume which is linked to this actor via
//			AssociatedActorTag and in state AssociatedTouch
//		* Dude must be in possession of the RequiredInventoryClass
//
// The board will tick up continually until it hits DudeNumber, at which point
// it will stop. If the Dude leaves the volume, the board will remain at its
// current number until the Dude returns.
///////////////////////////////////////////////////////////////////////////////
class NowServingBoard extends NumericSign;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
struct TriggerNumber
{
	var() int TriggerNumber;		// Number to trigger on
	var() name TriggerEvent;		// Event to trigger
};
var(Events) array<TriggerNumber> NumberEvents;	// Array of events to trigger on each number

var() class<Inventory> RequiredInventoryClass;	// Class of inventory Dude must have (like a waiting ticket)
var() int DudeNumber;							// The number given to the Dude (we stop counting here)
var() int StartingNumber;						// Number at the start
var() float TimeBetweenTicks;					// Length of time between increments
var() float TimeVariance;						// Multiplier to randomize time a bit
var() Sound TickSound;							// Sound to play when number changes

var Pawn DudeWaiting;							// Set to the Dude inside the waiting volume.
var bool bTimerStarted;							// Set to true when we've actually started our timer to change the number.
												// Otherwise, Timer event checks for Dude eligibility

///////////////////////////////////////////////////////////////////////////////
// Initialize
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	SetValue(StartingNumber);
	Super.PostBeginPlay();
	UpdateTimer();
}

///////////////////////////////////////////////////////////////////////////////
// SetValue: trigger Event numbers
///////////////////////////////////////////////////////////////////////////////
function SetValue(int NewValue)
{
	local int i;
	
	Super.SetValue(NewValue);
	
	// Trigger our event, if any.
	if (Event != '')
		TriggerEvent(Event, Self, Instigator);
		
	// Trigger any specific events for this number
	for (i = 0; i < NumberEvents.Length; i++)
		if (NumberEvents[i].TriggerNumber == NewValue
			&& NumberEvents[i].TriggerEvent != '')
			TriggerEvent(NumberEvents[i].TriggerEvent, Self, Instigator);
}


///////////////////////////////////////////////////////////////////////////////
// Receive Touch and UnTouch events from linked volume.
///////////////////////////////////////////////////////////////////////////////
event Touch(Actor Other)
{
	Super.Touch(Other);
	if (Pawn(Other) != None
		&& Pawn(Other).Controller != None
		&& PlayerController(Pawn(Other).Controller) != None)
	{
		DudeWaiting = Pawn(Other);
		Instigator = Pawn(Other);
		UpdateTimer();
	}
}
event UnTouch(Actor Other)
{
	Super.UnTouch(Other);
	if (Pawn(Other) != None
		&& Pawn(Other).Controller != None
		&& PlayerController(Pawn(Other).Controller) != None)
	{
		DudeWaiting = None;
		UpdateTimer();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set up our timer
///////////////////////////////////////////////////////////////////////////////
function UpdateTimer()
{
	if (DudeWaiting != None
		&& DudeWaiting.FindInventoryType(RequiredInventoryClass) != None)
		// If the dude walks in and has his ticket, go ahead and start the timer.
	{
		bTimerStarted = true;
		SetTimer(TimeBetweenTicks * (1 + FRand() * TimeVariance * 2 - TimeVariance), false);
	}
	else
		// Otherwise, keep setting timers to wait on the Dude
	{
		bTimerStarted = false;
		SetTimer(1.0, false);
	}
}

///////////////////////////////////////////////////////////////////////////////
// The all-important Timer
///////////////////////////////////////////////////////////////////////////////
event Timer()
{
	// If our wait timer has started, then tick up our current number.
	if (bTimerStarted
		&& GetValue() < DudeNumber)
	{
		if (TickSound != None)
			PlaySound(TickSound,,,,,(0.96 + FRand()*0.08));
		SetValue(GetValue() + 1);
		// We've hit our target, we can stop now.
		if (GetValue() >= DudeNumber)
		{
			bTimerStarted = false;
		}
		else
			// Keep going
			UpdateTimer();
	}
	else
		// Otherwise, check and see if the Dude is ready to wait
		UpdateTimer();
}

///////////////////////////////////////////////////////////////////////////////
// Defaults
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	StaticMesh=StaticMesh'PL_PlaceholderMesh.nssign.nowservingsign'
	DigitSkinIndex[0]=3
	DigitSkinIndex[1]=2
	DigitMaterials[0]=Texture'MrD_PL_Tex.Numbers.R1_0'
	DigitMaterials[1]=Texture'MrD_PL_Tex.Numbers.R1_1'
	DigitMaterials[2]=Texture'MrD_PL_Tex.Numbers.R1_2'
	DigitMaterials[3]=Texture'MrD_PL_Tex.Numbers.R1_3'
	DigitMaterials[4]=Texture'MrD_PL_Tex.Numbers.R1_4'
	DigitMaterials[5]=Texture'MrD_PL_Tex.Numbers.R1_5'
	DigitMaterials[6]=Texture'MrD_PL_Tex.Numbers.R1_6'
	DigitMaterials[7]=Texture'MrD_PL_Tex.Numbers.R1_7'
	DigitMaterials[8]=Texture'MrD_PL_Tex.Numbers.R1_8'
	DigitMaterials[9]=Texture'MrD_PL_Tex.Numbers.R1_9'
	TickSound=Sound'arcade.arcade_147'
	StartingNumber=1
}