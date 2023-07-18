///////////////////////////////////////////////////////////////////////////////
// CatRocketPawn ( CatNado )
// 
// by Man Chrzan for xPatch 2.0
//
// Ported from AWP to Postal 2 Cumplete.
// Now with random skins! 
//
///////////////////////////////////////////////////////////////////////////////

class CatRocketPawn extends AWCatPawn;

var() array<Material> CatSkins;		// Skins for cat

event PostBeginPlay()
{
	Skins[0] = CatSkins[Rand(CatSkins.Length)];
	Super.PostBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// Check to chunk up from some attacks/attackers
///////////////////////////////////////////////////////////////////////////////
function bool TryToChunk(Pawn instigatedBy, class<DamageType> damageType)
{
	// always gib rocket cats
	if(damageType != None )
	{
		ChunkUp(Health);
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
     DervishTimeMax=10.000000
     ControllerClass=Class'CatRocketController'
	 
	 CatSkins[0]=Texture'AnimalSkins.Cat_Black'
	 CatSkins[1]=Texture'AnimalSkins.Cat_Grey'
	 CatSkins[2]=Texture'AnimalSkins.Cat_Orange'
	 CatSkins[3]=Texture'AnimalSkins.Cat_Siamese'
	 CatSkins[4]=Shader'AW_Characters.Animals.Cat_Gimp_Shader'
}
