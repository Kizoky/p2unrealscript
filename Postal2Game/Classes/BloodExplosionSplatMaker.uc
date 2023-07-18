///////////////////////////////////////////////////////////////////////////////
// BloodExplosionSplatMaker.
// Blood sticks to wall after body hits wall from being hurt by explosion
//
// Thing that makes the splat on the client
///////////////////////////////////////////////////////////////////////////////
class BloodExplosionSplatMaker extends SplatMaker;

defaultproperties
{
	mysplatclass=class'BloodExplosionSplat'
	//mysplatclassEnh = class'xBloodDripSplat'
	//mysplatclassAWP = class'xAWPBloodDripSplat'
}