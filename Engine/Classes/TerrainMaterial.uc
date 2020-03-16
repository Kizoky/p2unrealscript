class TerrainMaterial extends RenderedMaterial
	native
	noteditinlinenew;

cpptext
{
	virtual UMaterial* CheckFallback();
	virtual UBOOL HasFallback();
}

struct native TerrainMaterialLayer
{
	var material		Texture;
	var bitmapmaterial	AlphaWeight;
	var matrix			TextureMatrix;
};

var const array<TerrainMaterialLayer> Layers;
var const byte RenderMethod;
var const bool FirstPass;