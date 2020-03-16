///////////////////////////////////////////////////////////////////////////////
// MachineGunBulletSplat.
// Bullet hole in the wall from a machine gun hit
///////////////////////////////////////////////////////////////////////////////
class MachineGunBulletSplat extends Splat;

defaultproperties
{
	MaterialBlendingOp=PB_None
	FrameBufferBlendingOp=PB_AlphaBlend
	ProjTexture=Material'nathans.skins.machinegunhitblend'
	DrawScale=0.25
	CullDistance=1500.0
}