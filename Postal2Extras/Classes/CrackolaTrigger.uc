///////////////////////////////////////////////////////////////////////////////
// Crackola Vending Machine Trigger
// by Man Chrzan for xPatch 3.0.
//
// A special trigger that allows us to buy or steal Crackola 
// works like ATM trigger, when triggered, stays off throughout the entire day, 
// even if the Dude changes maps. Can be used for other items too.
///////////////////////////////////////////////////////////////////////////////
class CrackolaTrigger extends ATMTrigger;

var() class<UseTrigger> UseTriggerClass;
var() edfindable UseTrigger MyUseTrigger;

///////////////////////////////////////////////////////////////////////////////
// Spawn our Use Trigger if needed
///////////////////////////////////////////////////////////////////////////////
function Touch( Actor Other )
{
	local P2Player p2p;

	if (!bTriggered
		&& Pawn(Other) != None
		&& P2Player(Pawn(Other).Controller) != None)
	{
		if(MyUseTrigger == None)
		{
			MyUseTrigger = Spawn(UseTriggerClass,,, self.Location);
			//MyUseTrigger.CollisionHeight = CollisionHeight;
			//MyUseTrigger.CollisionRadius = CollisionRadius;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local TimedMarker ADanger;

	if ( bInitiallyActive && (TriggerType == TT_Shoot) && (Damage >= DamageThreshold) && (instigatedBy != None) )
	{
		if(CrackolaUseTrigger(MyUseTrigger) != None 
			&& CrackolaUseTrigger(MyUseTrigger).QuantityAvailable <= 0)
		return;
		
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
			
		if(MyUseTrigger != None)
			MyUseTrigger.Destroy();
			
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

defaultproperties
{
	UseTriggerClass=class'CrackolaUseTrigger'
}