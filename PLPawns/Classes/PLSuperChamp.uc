///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
class PLSuperChamp extends SuperChamp;

function PlayFireballAttack()
{
	AnimBlendParams(MOVEMENTCHANNEL,0.0);
	PlayAnim(GetAnimBark(), 1.0, 0.3);
	PlaySound(MeanBark, SLOT_Talk,,,,GenPitch());
}

defaultproperties
{
	HeroTag="PLPostalDude"
	AmbientGlow=30
	ControllerClass=class'PLSuperChampController'
}
