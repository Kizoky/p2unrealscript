///////////////////////////////////////////////////////////////////////////////
// PukeTrailStarter
// Set numbers particular to Puke.
// No visual representation
///////////////////////////////////////////////////////////////////////////////
class PukeTrailStarter extends FluidTrailStarter;

defaultproperties
{
     SpawnClass=Class'Fx.PukeFlowTrail'
     PuddleClass=Class'Fx.PukePuddle'
	 VolumeGravityVector=(Z=-300)
	 MaxVelocity=(X=200.000000,Y=200.000000,Z=200.000000)
     MyType=FLUID_TYPE_Puke
	 DripFeederClass = Class'PukeDripFeeder'
}
