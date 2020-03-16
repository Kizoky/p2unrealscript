//=============================================================================
// The light class.
//=============================================================================
class Light extends Actor
	hidecategories(Collision,Force,Karma,Shadow,Sound)
	placeable
	native;

#exec Texture Import File=Textures\light.bmp  Name=S_Light Mips=Off MASKED=1

var (Corona)	float	MinCoronaSize;
var (Corona)	float	MaxCoronaSize;

defaultproperties
{
     bStatic=True
     bHidden=True
     bNoDelete=True
     Texture=S_Light
     CollisionRadius=+00024.000000
     CollisionHeight=+00024.000000
     LightType=LT_Steady
     LightBrightness=64
     LightSaturation=255
     LightRadius=64
     LightPeriod=32
     LightCone=128
	 bMovable=False
	DrawScale=0.125
	 MinCoronaSize=0;
	 MaxCoronaSize=1000;
}
