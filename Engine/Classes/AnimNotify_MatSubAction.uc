class AnimNotify_MatSubAction extends AnimNotify
	native;

var() editinline MatSubAction	SubAction;

cpptext
{
	// AnimNotify interface.
	virtual void Notify( UMeshInstance *Instance, AActor *Owner );
}
