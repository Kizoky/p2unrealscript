///////////////////////////////////////////////////////////////////////////////
// HungryTrigger
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Like the name suggests, this trigger "eats" anything that triggers it.
// Intended for powerup pickups and class proximitys
///////////////////////////////////////////////////////////////////////////////
class HungryTrigger extends Trigger;

///////////////////////////////////////////////////////////////////////////////
// Called when something touches the trigger.
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
			
		// OM NOM NOM
		Other.Destroy();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	TriggerType=TT_ClassProximity
	ClassProximityType=class'P2PowerupPickup'
}