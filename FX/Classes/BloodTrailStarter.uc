///////////////////////////////////////////////////////////////////////////////
// BloodTrailStarter
// Set numbers particular to Blood.
// No visual representation
///////////////////////////////////////////////////////////////////////////////
class BloodTrailStarter extends FluidTrailStarter;

defaultproperties
{
     SpawnClass=Class'Fx.BloodFlowTrail'
     PuddleClass=Class'Fx.BloodPuddle'
     MyType=FLUID_TYPE_Blood
	 DripFeederClass = Class'BloodDripFeeder'
}
