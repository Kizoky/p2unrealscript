///////////////////////////////////////////////////////////////////////////////
// ShockerBurnSplat.
// dark spot from an electrical burn
///////////////////////////////////////////////////////////////////////////////
class ShockerBurnSplat extends Splat;

simulated function PostBeginPlay()
{
	SetDrawScale(DrawScale + Frand()/3);
	Super.PostBeginPlay();
}

defaultproperties
{
	ProjTexture=Material'nathans.skins.tazerhitblend'
	DrawScale=0.25
}