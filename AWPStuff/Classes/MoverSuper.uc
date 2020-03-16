//=============================================================================
// MoverSuper.
//=============================================================================
class MoverSuper extends Mover;

var(Mover) bool bOscillatingLoop;	// If we should loop back and forth between keyframes (1-2-3-2-1) instead of going back to frame 1 (1-2-3-1-2-3)
var(Mover) name LoopEvent;			// Event triggered on each loop
var(MoverSounds) sound LoopSound;	// Sound Played on Loop

var int StepDirection;

function MoverLooped()	// Cause the LoopEvent and play the Loop Sound
{
	// Event and sound

	TriggerEvent(LoopEvent, Self, Instigator);
	If (LoopSound!=None)
		PlaySound( LoopSound, SLOT_None, SoundVolume / 255.0, false, SoundRadius, SoundPitch / 64.0);
}

// -----------------------------
// Loop this mover from the moment we begin

state() ConstantLoop
{
    event KeyFrameReached()
    {
		if (bOscillatingLoop)
		{

			if ( (KeyNum==0) || (KeyNum==NumKeys-1) )	// Flip
			{
				StepDirection*= -1;
				MoverLooped();
			}

			KeyNum += StepDirection;
			InterpolateTo( KeyNum, MoveTime );
		}
		else
		{
  			InterpolateTo( (KeyNum + 1) % NumKeys, MoveTime );
			if (KeyNum==0)
				MoverLooped();
		}
	
    }

	function BeginState()
	{
		bOpening = false;
    	bDelaying = false;
	}

Begin:
	StepDirection=1;
	InterpolateTo( 1, MoveTime );

Running:
	FinishInterpolation();
	GotoState( 'ConstantLoop', 'Running' );

}

