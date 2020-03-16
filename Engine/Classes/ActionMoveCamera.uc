//=============================================================================
// ActionMoveCamera:
//
// Moves the camera to a specified interpolation point.
//=============================================================================
class ActionMoveCamera extends MatAction
	native;

var(Path) config enum EPathStyle
{
	PATHSTYLE_Linear,
	PATHSTYLE_Bezier,
} PathStyle;	// Moves camera along a linear (straight) or bezier (curved) path.

defaultproperties
{
	PathStyle=PATHSTYLE_Linear
}
