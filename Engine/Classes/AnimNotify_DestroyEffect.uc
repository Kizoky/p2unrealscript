class AnimNotify_DestroyEffect extends AnimNotify
	native;

var() name DestroyTag;			// Tag of effect to destroy
var() bool bExpireParticles;	// If true, lets particles expire before destroying

cpptext
{
	// AnimNotify interface.
	virtual void Notify( UMeshInstance *Instance, AActor *Owner );
}

defaultproperties
{
	bExpireParticles=True
}