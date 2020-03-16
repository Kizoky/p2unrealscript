//=============================================================================
// MoveableStaticMeshActor.
// An actor that is drawn using a static mesh(a mesh that never changes, and
// can be cached in video memory, resulting in a speed boost).
//=============================================================================

class MoveableStaticMeshActor extends StaticMeshActor
	placeable;

defaultproperties
{
	bStatic=False
}