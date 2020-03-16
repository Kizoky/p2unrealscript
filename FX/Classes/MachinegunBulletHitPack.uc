///////////////////////////////////////////////////////////////////////////////
// MachinegunBulletSparkPack
//
///////////////////////////////////////////////////////////////////////////////
class MachinegunBulletHitPack extends BulletHitPack;

defaultproperties
{
	mysplatclass=Fx.MachineGunBulletSplat
	mysmokeclass=Fx.SmokeHitPuffMachinegun
	mysparkclass=Fx.SparkHitMachinegun
	mydirtclass=Fx.DirtClodsMachineGun
	mytracerclass=BulletTracer
	RandSpark=0.15
	CullDistance=2000.0
}
