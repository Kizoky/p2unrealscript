//=============================================================================
// Volume:  a bounding volume
// touch() and untouch() notifications to the volume as actors enter or leave it
// enteredvolume() and leftvolume() notifications when center of actor enters the volume
// pawns with bIsPlayer==true  cause playerenteredvolume notifications instead of actorenteredvolume()
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================

// RWS Change 12/18/02
// Set default properties bBlockZeroExtentTraces to false so they
// don't block bullets. BlockingVolume sets it back, so it seemed okay.
// RWS Change 12/18/02

class Volume extends Brush
	native;

var Actor AssociatedActor;			// this actor gets touch() and untouch notifications as the volume is entered or left
var() name AssociatedActorTag;		// Used by L.D. to specify tag of associated actor
var() int LocationPriority;
var() localized string LocationName;
var() edfindable decorationlist DecoList;		// A list of decorations to be spawned inside the volume when the level starts

var(ZoneSound) const array<ZoneInfo.ZoneSound> ZoneSounds;

native function bool Encompasses(Actor Other); // returns true if center of actor is within volume

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( (AssociatedActorTag != '') && (AssociatedActorTag != 'None') )
		ForEach AllActors(class'Actor',AssociatedActor, AssociatedActorTag)
			break;
	if ( AssociatedActor != None )
	{
		GotoState('AssociatedTouch');
		InitialState = GetStateName();
	}
}

function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Super.DisplayDebug(Canvas,YL,YPos);
	Canvas.DrawText("AssociatedActor "$AssociatedActor, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}	

State AssociatedTouch
{
	event touch( Actor Other )
	{
		AssociatedActor.touch(Other);
	}

	event untouch( Actor Other )
	{
		AssociatedActor.untouch(Other);
	}

	function BeginState()
	{
		local Actor A;

		ForEach TouchingActors(class'Actor', A)
			Touch(A);
	}
}

defaultproperties
{
	bCollideActors=True
	LocationName="unspecified"
	bSkipActorPropertyReplication=true
	bBlockZeroExtentTraces=false
}