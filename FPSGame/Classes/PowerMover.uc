///////////////////////////////////////////////////////////////////////////////
// PowerMover
// Able to reset back to 0, rather than 'close' and do all the keyframes in 
// reverse.
///////////////////////////////////////////////////////////////////////////////
class PowerMover extends Mover;

var ()bool bSnapClosed;	// If you want it to not reverse it's keyframes when
						// closing, and just go straight back to 0, set this to true.

///////////////////////////////////////////////////////////////////////////////
// Close the mover.
// If bSnapClosed is set to true, it will go straight to the 0th keyframe. 
///////////////////////////////////////////////////////////////////////////////
function DoClose()
{
	bOpening = false;
	bDelaying = false;

	if(bSnapClosed)
		InterpolateTo( 0, MoveTime );
	else
		InterpolateTo( Max(0,KeyNum-1), MoveTime );

	PlaySound( ClosingSound, SLOT_None, SoundVolume / 255.0, false, SoundRadius, SoundPitch / 64.0);
	UntriggerEvent(Event, self, Instigator);
	AmbientSound = MoveAmbientSound;
}

defaultproperties
{
}
