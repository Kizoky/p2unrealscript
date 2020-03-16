//=============================================================================
// TriggerStatic
// Trigger that ensures all static/non-static actors are attempted to be triggered
// (much slower)
//=============================================================================
class TriggerStatic extends Trigger;

/* 
Trigger an event
*/
event TriggerEvent( Name EventName, Actor Other, Pawn EventInstigator )
{
	local Actor A;

	if ( (EventName == '') || (EventName == 'None') )
		return;

	ForEach AllActors( class 'Actor', A, EventName )
		A.Trigger(Other, EventInstigator);
}

/*
Untrigger an event
*/
function UntriggerEvent( Name EventName, Actor Other, Pawn EventInstigator )
{
	local Actor A;

	if ( (EventName == '') || (EventName == 'None') )
		return;

	ForEach AllActors( class 'Actor', A, EventName )
		A.Untrigger(Other, EventInstigator);
}

defaultproperties
{
	Texture=Texture'PostEd.Icons_256.TriggerStatic'
	DrawScale=0.25
}
