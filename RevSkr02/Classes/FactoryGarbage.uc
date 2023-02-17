//=============================================================================
// Erik Rossik.
// Revival Games 2015.
// FactoryGarbage.
//=============================================================================
class FactoryGarbage extends PropBreakable;

var Actor AttachmentH;
var () name AttachAliasH;

simulated function bump (actor other)
{
SetPhysics(PHYS_projectile);
 If(Pawn(other) != none)
 {
  other.velocity = velocity*2;
 }
}

defaultproperties
{
     bFitEffectToProp=False
     bTriggerControlled=True
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Timb_mesh.fooo.barstool_timb'
     CollisionHeight=20.000000
     bCollideWorld=True
     bUseCylinderCollision=True
     bBounce=True
     Mass=0.000000
}
