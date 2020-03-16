///////////////////////////////////////////////////////////////////////////////
// DayTrigger
// Copyright 2014, Running With Scissors Inc. All Rights Reserved
//
// Just like a normal Trigger, but only goes off on certain days.
// We already have ways to do this (groups, ACTION_IfGameState), but the
// mappers wanted an easier way. Thus, DayTrigger was born
///////////////////////////////////////////////////////////////////////////////
class DayTrigger extends TriggerSuper;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
struct DayEvent
{
	var() string DayName;		// Name of day (DAY_A, etc.)
	var() name Event;		// Event to trigger on this day
};

var(Days) array<DayEvent> DayEvents;	// If set, activates certain Events on certain days.

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

defaultproperties
{
	Texture=Texture'PostEd.Icons_256.DayTrigger'
}