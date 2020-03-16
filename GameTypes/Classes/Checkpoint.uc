// Checkpoint.
// Trigger actor that saves the game when the player runs over it.
// Default is to set to a standard checkpoint
// Since it extends from Trigger it can also be used as a regular Trigger
// that saves the game in addition to triggering an event.
class Checkpoint extends Trigger;

enum ESaveType
{
	SAVE_Auto,
	SAVE_Easy,
	SAVE_Checkpoint
};

var() ESaveType SaveSlot;

//
// Called when something touches the trigger.
//
function Touch( actor Other )
{
	local int i;
	local P2Player p2p;

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
		
		// Perform the actual save here.		

		if ( (Pawn(Other) != None) && (Pawn(Other).Controller != None) )
		{
			if (P2Player(Pawn(Other).Controller) != None)
			{
				p2p = P2Player(Pawn(Other).Controller);
				if (SaveSlot == SAVE_Auto)
					P2GameInfoSingle(Level.Game).TryAutoSave(p2p, true);
				else if (SaveSlot == SAVE_Easy)
					P2GameInfoSingle(Level.Game).TryQuickSave(p2p, true);
				else
					P2GameInfoSingle(Level.Game).TryCheckpointSave(p2p, true);
			}
			
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
	TriggerType = TT_HumanPlayerProximity
	bTriggerOnceOnly = true
	bInitiallyActive = true
	Texture=Texture'PostEd.Icons_256.checkpoint'	
	DrawScale=0.25
	SaveSlot=SAVE_Checkpoint
}