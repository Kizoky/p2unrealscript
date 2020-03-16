///////////////////////////////////////////////////////////////////////////////
// AnimNotifyActor
//
//	An actor simply meant to be spawned and destroyed by animation 
// notifications for extra visual effect. 
// It has no collision/no interaction the world, by default
///////////////////////////////////////////////////////////////////////////////
class AnimNotifyActor extends Actor;

defaultproperties
{
	 DrawType=DT_StaticMesh
	 StaticMesh=StaticMesh'stuff.stuff1.grenade'
	 bBlockZeroExtentTraces=false
	 bBlockNonZeroExtentTraces=false
	 Lifespan=10.0
}