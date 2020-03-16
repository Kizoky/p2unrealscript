//=============================================================================
// LookTarget
//
// A convenience actor that you can point a matinee camera at.
//
// Isn't bStatic so you can attach these to movers and such.
//
//=============================================================================
class LookTarget extends KeyPoint
	hidecategories(Collision,Lighting,LightColor,Karma,Force,Shadow,Sound)
	native;

// Sprite.
#exec Texture Import File=Textures\lookattarget.bmp Name=S_LookTarget Mips=Off MASKED=1
#exec Texture Import File=Textures\target.bmp Name=S_Target Mips=Off MASKED=1

defaultproperties
{
     bStatic=false
	 bNoDelete=true
     bHidden=True
     SoundVolume=0
	 Texture=S_Target
	DrawScale=0.25
}
