//=============================================================================
// Erik Rossik.
// Revival Games 2015.
// ActorVelTrigger.
//=============================================================================
class ActorVelTrigger extends Trigger
	placeable;

var () vector NewVelocity;
var ()  Bool DestroyInstigator;

function Touch( actor Other )
{
	local int i;
	
	if( IsRelevant( Other ) )
	{
		if ( ReTriggerDelay > 0 )
		{
			if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay && TriggerTime != 0.0 )
				return;
			TriggerTime = Level.TimeSeconds;
		}
		// Broadcast the Trigger message to all matching actors.
		TriggerEvent(Event, Other, Other.Instigator);
        
        If(Other != none) 
        {
         If(DestroyInstigator) 
         {
          If(FactoryGarbage(Other).AttachmentH != none) FactoryGarbage(Other).AttachmentH.Destroy();
          Other.destroy();
         }
         else
         {
          Other.SetPhysics(PHYS_projectile);
          Other.velocity = NewVelocity;
         }
        }
       

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
	}
}

defaultproperties
{
}
