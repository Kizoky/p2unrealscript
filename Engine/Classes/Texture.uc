//=============================================================================
// Texture: An Unreal texture map.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Texture extends BitmapMaterial
	safereplace
	native
	noteditinlinenew
	dontcollapsecategories
	noexport;

// Palette.
var(Texture) palette Palette;

// Internal info.
var const color MipZero;
var const color MaxColor;
var const int   InternalTime[2];

// JWB: Detail Texture addition
var(texture) Material Detail;           // Detail texture to apply.
var(texture) float    DetailScale;      // Detail texture scale.

// Subtextures.
var deprecated texture DetailTexture;	// Detail texture to apply.
var deprecated texture EnvironmentMap;// Environment map for this texture

// Surface properties.
var deprecated enum EEnvMapTransformType
{
	EMTT_ViewSpace,
	EMTT_WorldSpace,
	EMTT_LightSpace,
} EnvMapTransformType;

var deprecated float Specular;		// Specular lighting coefficient.

// Texture flags.

var(Surface) editconst	bool bMasked;
var(Surface)			bool bAlphaTexture;
var(Surface)			bool bTwoSided;
var(Quality) private	bool bHighColorQuality;   // High color quality hint.
var(Quality) private	bool bHighTextureQuality; // High color quality hint.
var private				bool bRealtime;           // Texture changes in realtime.
var private				bool bParametric;         // Texture data need not be stored.
var private transient	bool bRealtimeChanged;    // Changed since last render.
var const editconst private  bool bHasComp;		//!!OLDVER Whether a compressed version exists.

// Level of detail set.
var(Quality) enum ELODSet
{
	LODSET_None,   // No level of detail mipmap tossing.
	LODSET_World,  // World level-of-detail set.
	LODSET_Skin,   // Skin level-of-detail set.
	LODSET_Lightmap, // Lightmap level-of-detail set.
	LODSET_Terrain, // RWS CHANGE: Added new set
	LODSET_Weapon // RWS CHANGE: Added new set
} LODSet;

var() int NormalLOD;
var int MinLOD;
var transient int MaxLOD;

// Animation.
var(Animation) texture AnimNext;
var transient  texture AnimCurrent;
var(Animation) byte    PrimeCount;
var transient  byte    PrimeCurrent;
var(Animation) float   MinFrameRate, MaxFrameRate;
var transient  float   Accumulator;

// Mipmaps.
var private native const array<int> Mips;
var const editconst ETextureFormat CompFormat; //!!OLDVER

var const transient int	RenderInterface;
var const transient int	__LastUpdateTime[2];

defaultproperties
{
    DetailScale=8.0
	Specular=1
	LODSet=LODSET_World
	EnvMapTransformType=EMTT_ViewSpace
	MipZero=(R=64,G=128,B=64,A=0)
	MaxColor=(R=255,G=255,B=255,A=255)
}
