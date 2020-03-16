//=============================================================================
// PathNode.
//=============================================================================
class PathNode extends NavigationPoint
	placeable
	native;

#exec Texture Import File=Textures\pathnode.bmp  Name=S_PathNode Mips=Off MASKED=1

var PathNode NextNode;		// Next path node in the linked list of nodes similar
							// to this one. Homenodes use this to link each other
							// together by tag. Pathnodes use it to just link 
							// all remaining non-home pathnodes together.

var()bool bNoRandomCost;	// If true, then it won't generate a random cost
							// for each pathnode/homenode. 

cpptext
{
	virtual UBOOL ReviewPath(APawn* Scout);
	virtual void CheckSymmetry(ANavigationPoint* Other);
}

// RWS Change 01/28/03 To make the conga-line effect go away
const COST_BASE			= 5000;

///////////////////////////////////////////////////////////////////////////////
// Default a crazy cost on this unless a cost has been specified. This is to
// keep the 'conga-line' effect from happening. That was when everyone would
// walk down a street in a row, picking the best path, even when several other
// lines of pathnodes were there for picking.
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(!bNoRandomCost)
		ExtraCost += Rand(COST_BASE);
}
// RWS Change 01/28/03 end

defaultproperties
{
     Texture=S_PathNode
	 DrawScale=0.125
     SoundVolume=128
}
