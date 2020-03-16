///////////////////////////////////////////////////////////////////////////////
// Tells everyone that will listen there's something 
// they really want here. 
//
// Started to be used for donut and money pickups that the player has dropped.
//
///////////////////////////////////////////////////////////////////////////////
class DesiredThingMarker extends BlipMarker;

var bool bRunToDesire;

defaultproperties
{
	CollisionRadius=1500
	CollisionHeight=400
	NotifyTime=5.0
	LifeSpan=0
	bNotifyOnStart=false
}
