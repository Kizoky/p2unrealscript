///////////////////////////////////////////////////////////////////////////////
// EnsmallenTrigger
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Special trigger for firing off events when the Ensmallen Cure hits someone
///////////////////////////////////////////////////////////////////////////////
class EnsmallenTrigger extends Triggers;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
struct EnsmallenEvent
{
	var() name ActorTag;		// Tag of Actor that needs to be Ensmallen'd
	var() name TriggerEvent;	// Name of Event to trigger when that actor is Ensmallen'd
	var() bool bDontShrink;		// True if this spawns a cutscene and we don't want to shrink the pawn.
};

var() array<EnsmallenEvent> Events;

///////////////////////////////////////////////////////////////////////////////
// The dude just jabbed someone with the Ensmallen Cure. Should we trigger
// an event? Returns true if we go into a cutscene and we don't want to shrink
// the victim (the cutscene will handle it)
///////////////////////////////////////////////////////////////////////////////
function bool MaybeTrigger(Pawn Victim, Pawn EventInstigator)
{
	local int i;
	local bool bDontShrink;
	
	for (i = 0; i < Events.Length; i++)
		if (Events[i].ActorTag == Victim.Tag)
		{
			TriggerEvent(Events[i].TriggerEvent, Self, EventInstigator);
			bDontShrink = bDontShrink || Events[i].bDontShrink;
		}
		
	return bDontShrink;
}

defaultproperties
{
	DrawScale=0.25
	Texture=Texture'PL-KamekTex.Actors.EnsmallenTrigger'
}