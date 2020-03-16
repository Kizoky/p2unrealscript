class TerrainInfo extends Info
	noexport
	showcategories(Movement,Collision,Lighting,LightColor,Karma,Force)
	native
	placeable;

#exec Texture Import File=Textures\terrainzone.bmp Name=S_TerrainInfo Mips=Off MASKED=1
#exec Texture Import File=Textures\S_WhiteCircle.pcx Name=S_WhiteCircle Mips=Off MASKED=1
#exec Texture Import File=Textures\Bad.pcx Name=TerrainBad Mips=Off
#exec Texture Import File=Textures\DecoPaint.pcx Name=DecoPaint Mips=Off

struct NormalPair
{
	var vector Normal1;
	var vector Normal2;
};

enum ETexMapAxis
{
	TEXMAPAXIS_XY,
	TEXMAPAXIS_XZ,
	TEXMAPAXIS_YZ,
};

enum ESortOrder
{
	SORT_NoSort,
	SORT_BackToFront,
	SORT_FrontToBack
};

struct TerrainLayer
{
	var() Material	Texture;
	var() Texture	AlphaMap;
	var() float		UScale;
	var() float		VScale;
	var() float		UPan;
	var() float		VPan;
	var() ETexMapAxis TextureMapAxis;
	var() float		TextureRotation;
	var() Rotator	LayerRotation;
	var   Matrix	TerrainMatrix;
	var() float		KFriction;
	var() float		KRestitution;
	var   Texture	LayerWeightMap;
};

struct DecorationLayer
{
	var() int			ShowOnTerrain;
	var() Texture		ScaleMap;
	var() Texture		DensityMap;
	var() Texture		ColorMap;
	var() StaticMesh	StaticMesh;
	var() rangevector	ScaleMultiplier;
	var() range			FadeoutRadius;
	var() range			DensityMultiplier;
	var() int			MaxPerQuad;
	var() int			Seed;
	var() int			AlignToTerrain;
	var() ESortOrder	DrawOrder;
	var() int			ShowOnInvisibleTerrain;
	var() int			LitDirectional;
	var() int			DisregardTerrainLighting;
	var() int			RandomYaw;
};


struct DecoInfo
{
	var vector	Location;
	var rotator	Rotation;
	var vector	Scale;
	var vector	TempScale;
	var color	Color;
	var int		Distance;
}; 

struct DecoSectorInfo
{
	var array<DecoInfo>	DecoInfo;
	var vector			Location;
	var float			Radius;
};

struct DecorationLayerData
{
	var array<DecoSectorInfo> Sectors;
};

var() int						TerrainSectorSize;
var() Texture					TerrainMap;
var() vector					TerrainScale;
var() TerrainLayer				Layers[32];
var() array<DecorationLayer>	DecoLayers;
var() bool						Inverted;

//
// Internal data
//
var transient int							JustLoaded;
var	native const array<DecorationLayerData> DecoLayerData;
var native const array<TerrainSector>		Sectors;
var native const array<vector>				Vertices;
var native const int						HeightmapX;
var native const int 						HeightmapY;
var native const int 						SectorsX;
var native const int 						SectorsY;
var native const TerrainPrimitive 			Primitive;
var native const array<NormalPair>			FaceNormals;
var native const vector						ToWorld[4];
var native const vector						ToHeightmap[4];
var native const array<int>					SelectedVertices;
var native const int						ShowGrid;
var const array<int>						QuadVisibilityBitmap;
var const array<int>						EdgeTurnBitmap;
var native const array<int>					RenderCombinations;
var native const array<int>					VertexStreams;
var native const array<color>				VertexColors;
var native const array<color>				PaintedColor;		// editor only

// OLD
var native const Texture OldTerrainMap;
var native const array<byte> OldHeightmap;


defaultproperties
{
	Texture=S_TerrainInfo
	TerrainScale=(X=64,Y=64,Z=64)
	bStatic=True
	bStaticLighting=True
	bWorldGeometry=true
	TerrainSectorSize=16
	DrawScale=0.25
}
