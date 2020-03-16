///////////////////////////////////////////////////////////////////////////////
//  Prop piece as to support the game visually and physically. Small and 
// large things to be placed around the levels, ie, chairs, tables, cans, 
// bottles, tvs, etc.
///////////////////////////////////////////////////////////////////////////////

class Prop extends actor
	placeable;

defaultproperties
{
    bCollideActors=True
    bBlockActors=True
    bBlockPlayers=True
    bStatic=False
	bEdShouldSnap=true
}

