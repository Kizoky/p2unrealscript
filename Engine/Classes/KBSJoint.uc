//=============================================================================
// The Ball-and-Socket joint class.
//=============================================================================

#exec Texture Import File=Textures\KBSJoint.bmp Name=S_KBSJoint Mips=Off MASKED=1

class KBSJoint extends KConstraint
    native
    placeable;

defaultproperties
{
	Texture=S_KBSJoint
	DrawScale=0.25
}