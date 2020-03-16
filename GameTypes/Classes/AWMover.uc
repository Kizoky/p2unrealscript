///////////////////////////////////////////////////////////////////////////////
// AWMover
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
// 
///////////////////////////////////////////////////////////////////////////////
class AWMover extends Mover;

var (Mover) bool bTriggerEventOnDamage;		// When damaged, if it's past the threshold and
									// bDamageTriggered isn't true, then trigger my event

var (Mover) bool bTriggerEventOnDamageOnce; // turn off the above, once it happens, if this is true

///////////////////////////////////////////////////////////////////////////////
// When damaged
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	if(Damage >= DamageThreshold)
	{
		if ( bDamageTriggered )
			self.Trigger(self, instigatedBy);
		else if(bTriggerEventOnDamage)
		{
			// Keep it from happening again if they want it like that.
			if(bTriggerEventOnDamageOnce)
				bTriggerEventOnDamage=false;
			TriggerEvent(Event, Self, Instigator);
		}
	}
}

defaultproperties
{
     bTriggerEventOnDamageOnce=True
}
