//=============================================================================
// Material: Abstract material class
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Material extends Object
	native
	hidecategories(Object)
	collapsecategories
	noexport;

//#exec Texture Import File=Textures\DefaultTexture.pcx
//#exec Texture Import File=Textures\checker256.dds NAME=DefaultTexture_256
//#exec Texture Import File=Textures\checker512.dds NAME=DefaultTexture_512
#exec Texture Import File=Textures\checker512_gray.dds NAME=DefaultTexture

var() Material FallbackMaterial;

var Material DefaultMaterial;
var const transient bool UseFallback;	// Render device should use the fallback.
var const transient bool Validated;		// Material has been validated as renderable.

var() Actor.ESurfaceType SurfaceType;

function Trigger( Actor Other, Actor EventInstigator )
{
	if( FallbackMaterial != None )
		FallbackMaterial.Trigger( Other, EventInstigator );
}

defaultproperties
{
	FallbackMaterial=None
	DefaultMaterial=DefaultTexture
}