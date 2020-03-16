class SubActionCameraEffect extends MatSubAction
	native
	noexport
	collapsecategories;

var() editinline CameraEffect	CameraEffect;
var() float						StartAlpha,
								EndAlpha;
var() bool						DisableAfterDuration;

defaultproperties
{
	Icon=SubActionFade
	Desc="Camera effect"
	StartAlpha=0.0
	EndAlpha=1.0
	DisableAfterDuration=False
}