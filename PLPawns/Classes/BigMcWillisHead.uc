///////////////////////////////////////////////////////////////////////////////
// BigMcWillisHead
///////////////////////////////////////////////////////////////////////////////
class BigMcWillisHead extends Head;

///////////////////////////////////////////////////////////////////////////////
// Setup the head
///////////////////////////////////////////////////////////////////////////////
simulated function Setup(Mesh NewMesh, Material NewSkin, Vector NewScale, byte NewAmbientGlow)
{
	// Ambient glow should match body
	AmbientGlow = NewAmbientGlow;

	// Each head can be differently shaped
	RealScale = NewScale;
	SetDrawScale3D(NewScale);	
}

defaultproperties
{
	Skins[0]=Texture'PLCharacterSkins.Big_McWillis_Head.mcwillis_head'
	Skins[1]=Texture'PLCharacterSkins.Big_McWillis_Head.mcwillis_hair'
	Skins[2]=Texture'PLCharacterSkins.Big_McWillis_Head.mcwillis_eye'
	Mesh=SkeletalMesh'PLHeads.PL_McWillis'
}