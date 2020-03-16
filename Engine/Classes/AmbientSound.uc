//=============================================================================
// Ambient sound, sits there and emits its sound.  This class is no different 
// than placing any other actor in a level and setting its ambient sound.
//=============================================================================
class AmbientSound extends Keypoint
	hidecategories(Collision,Force,Karma,LightColor,Lighting,Shadow);

// Import the sprite.
#exec Texture Import File=Textures\speaker_blu.bmp Name=S_Ambient Mips=Off MASKED=1

defaultproperties
{
	 Texture=S_Ambient
	 SoundRadius=64
	 SoundVolume=190
	 SoundPitch=64
	DrawScale=0.25
}
