///////////////////////////////////////////////////////////////////////////////
// P2Explosion
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
// 
// Explosion that alerts people around it, that it occurred.
///////////////////////////////////////////////////////////////////////////////
class P2Explosion extends Explosion;

var class<TimedMarker> ExplosionMarkerMade;		// danger made when explosion occurs

///////////////////////////////////////////////////////////////////////////////
// Tell the pawns around this area, that an explosion happened.
///////////////////////////////////////////////////////////////////////////////
function NotifyPawns()
{
	ExplosionMarkerMade.static.NotifyControllersStatic(
		Level,
		ExplosionMarkerMade,
		FPSPawn(Instigator), 
		FPSPawn(Instigator), 
		ExplosionMarkerMade.default.CollisionRadius,
		Location);
}


defaultproperties
{
	ExplosionMarkerMade=class'ExplosionMarker'
}
