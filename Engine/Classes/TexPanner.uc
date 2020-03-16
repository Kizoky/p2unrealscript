class TexPanner extends TexModifier
	editinlinenew
	native;

cpptext
{
	// UTexModifier interface
	virtual FMatrix* GetMatrix(FLOAT TimeSeconds);
}

var() rotator PanDirection;
var() float PanRate;
var Matrix M;

defaultproperties
{
	PanRate=0.1
	PanDirection=(Yaw=0)
}
