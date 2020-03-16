//=============================================================================
// FluidSurfaceOscillator.
//=============================================================================
class FluidSurfaceOscillator extends Actor
	native
	placeable;

cpptext
{
	void UpdateOscillation( FLOAT DeltaTime );
	virtual void PostEditChange();
	virtual void Destroy();
}

#exec Texture Import File=Textures\FluidSurfaceOscillator.bmp Name=S_FluidSurfaceOscillator Mips=Off MASKED=1

// FluidSurface to oscillate
var() edfindable FluidSurfaceInfo	FluidInfo;
var() float							Frequency;
var() byte							Phase;
var() float							Strength;
var() float							Radius;

var transient const float			OscTime;

defaultproperties
{
	bHidden=true
	Frequency=1
	Phase=0
	Strength=10
	Radius=0
	Texture=Texture'S_FluidSurfaceOscillator'
	DrawScale=0.25
}