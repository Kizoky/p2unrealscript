///////////////////////////////////////////////////////////////////////////
// Used to pee your pants.
// Won't show a visible stream, but will make puddles and trails the same.
///////////////////////////////////////////////////////////////////////////
class UrineBodyFeeder extends BloodBodyFeeder;

defaultproperties
{
    MyType=FLUID_TYPE_Urine
	SplashClass = None
	TrailClass = Class'UrineTrail'
	TrailStarterClass = Class'UrineTrailStarter'
	PuddleClass = Class'UrinePuddleNoBubbles'
	QuantityPerHit=7
	SpawnDripTime=0.15
	MomentumTransfer=1.0
	Quantity=20
	LifeSpan=6
}
