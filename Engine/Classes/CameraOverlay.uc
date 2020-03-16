class CameraOverlay extends CameraEffect
	native
	noexport
	editinlinenew
	collapsecategories;

var() color		OverlayColor;				// Color of overlay
var() Material	OverlayMaterial;			// Material to overlay

defaultproperties
{
	OverlayColor=(R=255,G=255,B=255,A=255)
	FinalEffect=False
}