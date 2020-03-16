///////////////////////////////////////////////////////////////////////////////
// HomeNode.
//
// Path node used to specify a point in a restricted area so normal people
// won't use this as their DESTINATION point even though they might possibly
// use it in order to get to a normal pathnode.
//
// The theory would be if you path node a house with these instead of normal
// pathnodes, then people want randomly try to walk into the house and will
// stick to the streets where normal pathnodes are.
//
///////////////////////////////////////////////////////////////////////////////
class HomeNode extends PathNode
	native;

///////////////////////////////////////////////////////////////////////////////
// Toggle the blocked status of the pathnode
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, pawn EventInstigator )
{
	bBlocked=!bBlocked;
}

defaultproperties
{
	Texture=Texture'PostEd.Icons_256.HomeNode'
	Cost = 25000
	ExtraCost = 25000
	DrawScale=0.125
}
