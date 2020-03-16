class ConstantColor extends ConstantMaterial
	native
	editinlinenew;

cpptext
{
	//
	// UConstantMaterial interface
	//
	virtual FColor GetColor(FLOAT TimeSeconds) { return Color; }
}

var() Color Color;