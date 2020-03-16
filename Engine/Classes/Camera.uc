//=============================================================================
// A camera, used in UnrealEd.
//=============================================================================
class Camera extends PlayerController
	native;

// Sprite.
#exec Texture Import File=Textures\S_Camera.pcx Name=S_Camera Mips=Off MASKED=1

defaultproperties
{
     Location=(X=-500.000000,Y=-300.000000,Z=300.000000)
     Texture=S_Camera
     CollisionRadius=+00016.000000
     CollisionHeight=+00039.000000
     LightBrightness=100
     LightRadius=16
	 bDirectional=1
}

