class TexOscillator extends TexModifier
	editinlinenew
	native;

cpptext
{
	// UTexModifier interface
	virtual FMatrix* GetMatrix(FLOAT TimeSeconds);
}

enum ETexOscillationType
{
	OT_Pan,
	OT_Stretch,
	OT_StretchRepeat
};

var() Float UOscillationRate;
var() Float VOscillationRate;
var() Float UOscillationPhase;
var() Float VOscillationPhase;
var() Float UOscillationAmplitude;
var() Float VOscillationAmplitude;
var() ETexOscillationType UOscillationType;
var() ETexOscillationType VOscillationType;
var() float UOffset;
var() float VOffset;

var Matrix M;

defaultproperties
{
	UOscillationRate=1
	VOscillationRate=1
	UOscillationAmplitude=0.1
	VOscillationAmplitude=0.1
	UOscillationType=OT_Pan
	VOscillationType=OT_Pan
}
