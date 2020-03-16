//=============================================================================
// MatObject
//
// A base class for all Matinee classes.  Just a convenient place to store
// common elements like enums.
//=============================================================================

class MatObject extends Object
	abstract
	native;

struct Orientation
{
	var() ECamOrientation	CamOrientation;
	var() actor LookAt;
// RWS CHANGE: add support for looking at a tag (so we can look at spawned actors)
	var() Name LookAtTag;
// RWS CHANGE: add support for looking at a tag (so we can look at spawned actors)
	var() float EaseIntime;
	var() int bReversePitch;
	var() int bReverseYaw;
	var() int bReverseRoll;

	var int MA;
	var float PctInStart, PctInEnd, PctInDuration;
	var rotator StartingRotation;
};

defaultproperties
{
}
