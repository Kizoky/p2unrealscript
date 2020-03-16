///////////////////////////////////////////////////////////////////////////////
// TriggerMapReminder.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Can turn off/reset the map reminder functionality in P2Player. That is there
// to remind the player that he has errands to complete. 
// This can also force the reminder system to start putting up reminders
//
///////////////////////////////////////////////////////////////////////////////
class TriggerMapReminder extends Trigger;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var() enum	EReminderFunction	// What to do when hit
{
	ERF_ResetReminder,
	ERF_TriggerReminder,
//	ERF_DisableReminder,
//	ERF_EnableReminder
} ReminderFunction;

///////////////////////////////////////////////////////////////////////////////
// Called when something touches us
///////////////////////////////////////////////////////////////////////////////
function Touch( actor Other )
{
	local P2Player p2p;
	local P2HUD hud;

	if (IsRelevant(Other))
	{
		if (Other.Instigator != None
			&& P2GameInfo(Level.Game).AllowReminderHints())
		{
			p2p = P2Player(Pawn(Other).Controller);
			if(p2p != None)
			{
				if(ReminderFunction == ERF_ResetReminder)
					p2p.ResetMapReminder();
				else if(ReminderFunction == ERF_TriggerReminder)
					p2p.TriggerMapReminder();
				//else if(ReminderFunction == ERF_DisableReminder)
				//	p2p.ResetMapReminder();
				//else if(ReminderFunction == ERF_EnableReminder)
				//	p2p.ResetMapReminder();
			}
		}
	}
	Super.Touch(Other);
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	Texture=Texture'PostEd.Icons_256.mapremindertrigger'
	DrawScale=0.25
	}
