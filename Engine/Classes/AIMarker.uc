//=============================================================================
// AIMarker.
//=============================================================================
class AIMarker extends SmallNavigationPoint
	native;

cpptext
{
	virtual UBOOL IsIdentifiedAs(FName ActorName);
}

var AIScript markedScript;

defaultproperties
{
     bCollideWhenPlacing=False
	 bHiddenEd=true
}
