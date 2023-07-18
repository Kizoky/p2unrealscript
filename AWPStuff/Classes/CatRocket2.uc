///////////////////////////////////////////////////////////////////////////////
// CatRocket2 ( Normal Cats )
// 
// by Man Chrzan for xPatch 2.0
//
// This class just extends P2's CatRocket (shoot off by cat-silenced shotgun).
// and adds in random Cat skins for our epic Cat Launcher.
//
///////////////////////////////////////////////////////////////////////////////
class CatRocket2 extends CatRocket;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

var() float LifeTime;				// After this much time we explode even if we haven't hit anything
var() array<Material> CatSkins;		// Skins for cat

simulated event PostBeginPlay()
{
	Skins[0] = CatSkins[Rand(CatSkins.Length)];
	Super.PostBeginPlay();
	SetTimer(LifeTime, false);
}

defaultproperties
{
	LifeSpan=0
	LifeTime=30
	CatSkins[0]=Texture'AnimalSkins.Cat_Black'
	CatSkins[1]=Texture'AnimalSkins.Cat_Grey'
	CatSkins[2]=Texture'AnimalSkins.Cat_Orange'
	CatSkins[3]=Texture'AnimalSkins.Cat_Siamese'
	CatSkins[4]=Shader'AW_Characters.Animals.Cat_Gimp_Shader'
}
