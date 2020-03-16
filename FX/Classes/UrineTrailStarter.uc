///////////////////////////////////////////////////////////////////////////////
// UrineTrailStarter
// Set numbers particular to urine.
// No visual representation
///////////////////////////////////////////////////////////////////////////////
class UrineTrailStarter extends FluidTrailStarter;

defaultproperties
{
     SpawnClass=Class'Fx.UrineFlowTrail'
     PuddleClass=Class'Fx.UrinePuddle'
     MyType=FLUID_TYPE_Urine
	 DripFeederClass = Class'UrineDripFeeder'
}
