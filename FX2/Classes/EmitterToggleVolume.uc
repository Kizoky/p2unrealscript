///////////////////////////////////////////////////////////////////////////////
// EmitterToggleVolume
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
//
// Volume that sends Trigger() when player enters, and Trigger() again when
// player leaves.
///////////////////////////////////////////////////////////////////////////////
class EmitterToggleVolume extends Volume;

var(Events) array<Name> MoreEvents;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
event Touch(Actor Other)
{
	CheckForPlayerTouch(Other);
	Super.Touch(Other);
}
event UnTouch(Actor Other)
{
	CheckForPlayerTouch(Other);
	Super.Touch(Other);
}

///////////////////////////////////////////////////////////////////////////////
// If this is a player, trigger our Event
///////////////////////////////////////////////////////////////////////////////
function CheckForPlayerTouch(Actor Other)
{
	local int i;
	if (Pawn(Other) != None
		&& Pawn(Other).Controller != None
		&& PlayerController(Pawn(Other).Controller) != None)
	{
		if (Event != '')
			TriggerEvent(Event, Self, Pawn(Other));
		for (i = 0; i < MoreEvents.Length; i++)
			if (MoreEvents[i] != '')
				TriggerEvent(MoreEvents[i], Self, Pawn(Other));
	}
}
