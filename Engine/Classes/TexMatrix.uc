class TexMatrix extends TexModifier
	native;

cpptext
{
	// UTexModifier interface
	virtual FMatrix* GetMatrix(FLOAT TimeSeconds) { return &Matrix; }
}

var Matrix Matrix;
