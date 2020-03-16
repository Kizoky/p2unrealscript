///////////////////////////////////////////////////////////////////////////////
// ATM Trigger
// Copyright 2014 Running With Scissors Inc.
//
// A trigger that, when triggered, stays off throughout the entire day, even
// if the Dude changes maps.
// Named ATMTrigger because it's primarily used for kickable ATM's, but can
// have other uses too - just put it anywhere you want to use a Trigger that
// can't be set off again for the rest of the day.
// These also set off Danger Markers now, so the cops will bust us for
// busting up an ATM.
///////////////////////////////////////////////////////////////////////////////
class ATMTrigger extends TriggerSuper;

var bool bTriggered;	// Set to true after being triggered
var() class<TimedMarker>DangerMarker;// Danger notifier (if any) this makes when broken

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local TimedMarker ADanger;

	if ( bInitiallyActive && (TriggerType == TT_Shoot) && (Damage >= DamageThreshold) && (instigatedBy != None) )
	{
		if ( ReTriggerDelay > 0 )
		{
			if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
				return;
			TriggerTime = Level.TimeSeconds;
		}
		// Broadcast the Trigger message to all matching actors.
		TriggerEvent(Event, self, instigatedBy);

		if( Message != "" )
			// Send a string message to the toucher.
			instigatedBy.Instigator.ClientMessage( Message );

		if( bTriggerOnceOnly )
			// Ignore future touches.
			SetCollision(False);
			
		bTriggered = true;

		// If we were destroyed with damage, send out the appropriate blip marker.
		if(DangerMarker != None
			&& (ClassIsChildOf(damageType, class'CuttingDamage')
				|| ClassIsChildOf(damageType, class'BludgeonDamage')))
		{
			ADanger = spawn(DangerMarker,,,HitLocation);
			ADanger.CreatorPawn = FPSPawn(InstigatedBy);
			ADanger.OriginActor = self;
			// This will cause people to see if they noticed and decide what to do
			ADanger.NotifyAndDie();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Touch( actor Other )
{
	local int i;

	if( IsRelevant( Other ) )
	{
		if ( ReTriggerDelay > 0 )
		{
			if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
				return;
			TriggerTime = Level.TimeSeconds;
		}
		// Broadcast the Trigger message to all matching actors.
		TriggerEvent(Event, self, Other.Instigator);

		if ( (Pawn(Other) != None) && (Pawn(Other).Controller != None) )
		{
			for ( i=0;i<4;i++ )
				if ( Pawn(Other).Controller.GoalList[i] == self )
				{
					Pawn(Other).Controller.GoalList[i] = None;
					break;
				}
		}	
				
		if( (Message != "") && (Other.Instigator != None) )
			// Send a string message to the toucher.
			Other.Instigator.ClientMessage( Message );

		if( bTriggerOnceOnly )
			// Ignore future touches.
			SetCollision(False);
		else if ( RepeatTriggerTime > 0 )
			SetTimer(RepeatTriggerTime, false);
			
		bTriggered = true;	// Set that we've been triggered, and can't be triggered again for the rest of the day.
	}	
}

///////////////////////////////////////////////////////////////////////////////
// "Disabled" state
// Forced into this state by GameState if the trigger has already been set off
// today.
///////////////////////////////////////////////////////////////////////////////
state Disabled
{
Begin:
	SetCollision(False);
}

defaultproperties
{
	Texture=Texture'PostEd.Icons_256.ATMTrigger'
	DrawScale=0.25
	bTriggerOnceOnly=true
	DangerMarker=class'PropBreakMarker'
}
