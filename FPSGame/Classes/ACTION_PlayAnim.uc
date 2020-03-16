class ACTION_PlayAnim extends ScriptedAction;

var(Action) name BaseAnim;
var(Action) float BlendInTime;
var(Action) float BlendOutTime;
var(Action) float AnimRate;
var(Action) byte AnimIterations;
var(Action) bool bLoopAnim;

const FALLINGCHANNEL = 1;
const MOVEMENTCHANNEL = 2;

function bool InitActionFor(ScriptedController C)
{
	// play appropriate animation
	C.AnimsRemaining = AnimIterations;
	if ( PawnPlayBaseAnim(C,true) )
		C.CurrentAnimation = self;
	return false;	
}

function SetCurrentAnimationFor(ScriptedController C)
{
	if ( C.Pawn.IsAnimating(0) )
		C.CurrentAnimation = self;
	else
		C.CurrentAnimation = None;
}

function bool PawnPlayBaseAnim(ScriptedController C, bool bFirstPlay)
{
	if ( (BaseAnim == 'None') || (BaseAnim == '') )
		return false;
	
	C.bControlAnimations = true;
	if ( bFirstPlay )
		FPSPawn(C.Pawn).ActionPlayAnim(BaseAnim, AnimRate, BlendInTime);
	else if ( bLoopAnim || (C.AnimsRemaining > 0) )
		FPSPawn(C.Pawn).ActionLoopAnim(BaseAnim,AnimRate);
	else
		return false;
	return true;
}

function string GetActionString()
{
	return ActionString@BaseAnim;
}

defaultproperties
{
    BlendInTime=0.200000
    BlendOutTime=0.200000
	AnimRate=1.000000
	ActionString="play animation"
	bValidForTrigger=false
}