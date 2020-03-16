class ACTION_FreezeOnAnimEnd extends Action_PLAYANIM;

function bool InitActionFor(ScriptedController C)
{
	C.CurrentAnimation = self;
	return true;	
}

function SetCurrentAnimationFor(ScriptedController C)
{
	C.CurrentAnimation = self;
}

function bool PawnPlayBaseAnim(ScriptedController C, bool bFirstPlay)
{
	if ( C.Pawn != None )
	{
		C.Pawn.bPhysicsAnimUpdate = false;
		C.Pawn.StopAnimating();
		C.Pawn.SetPhysics(PHYS_None);
	}
	return true;
}