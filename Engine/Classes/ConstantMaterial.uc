class ConstantMaterial extends RenderedMaterial
	editinlinenew
	abstract
	native;

cpptext
{
	//
	// UConstantMaterial interface
	//
	virtual FColor GetColor(FLOAT TimeSeconds) { return FColor(0,0,0,0); }
}