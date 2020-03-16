//=============================================================================
// InterpolationPoint.
// Used as destinations to move the camera to in Matinee scenes.
//=============================================================================
class InterpolationPoint extends Keypoint
	hidecategories(Collision,Lighting,LightColor,Karma,Force,Shadow,Sound)
	native;

#exec Texture Import File=Textures\matineecamera.bmp Name=S_Interp Mips=Off MASKED=1
#exec TEXTURE IMPORT File=Textures\InterpCamera_Tex.dds Name=InterpCamera_Tex
#exec NEW STATICMESH File=Models\InterpCamera_SM.ASE Name=InterpCamera_SM

defaultproperties
{
	bDirectional=True
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'InterpCamera_SM'
	Skins[0]=InterpCamera_Tex
	bUnlit=True
	DrawScale=1.00
}
