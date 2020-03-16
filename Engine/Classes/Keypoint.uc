//=============================================================================
// Keypoint, the base class of invisible actors which mark things.
//=============================================================================
class Keypoint extends Actor
	abstract
	placeable
	native;

// Sprite.
#exec Texture Import File=Textures\keypoint.bmp Name=S_Keypoint Mips=Off MASKED=1

defaultproperties
{
     bStatic=True
     bHidden=True
     SoundVolume=0
     CollisionRadius=+00010.000000
     CollisionHeight=+00010.000000
	 Texture=S_Keypoint
	DrawScale=0.25
}
