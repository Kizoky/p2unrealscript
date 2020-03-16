class ACTION_ShakeCamera extends ScriptedAction;

// Check out weapon and explosion shakes in script for tips on number useage
var(Action) vector ShakeOffsetMag;
var(Action) vector ShakeOffsetRate;
var(Action) float  ShakeOffsetTime;
var(Action) vector ShakeRotMag;
var(Action) vector ShakeRotRate;
var(Action) float  ShakeRotTime;
var(Action) name   ShakeHereTag;		// Tag for actor to shake from. Shake the camera from this point
										// so the close you are, the more it will shake.
										// Otherwise, it always shakes the camera by the amount you say
										// no matter where the player is.
var(Action) float  MaxShakeDistance;		// Past this, we don't recongnize the shake

function bool InitActionFor(ScriptedController C)
{
	local controller con;
	local float usemag, usedist;
	local Actor ShakeHereActor;

	// Get shake here actor point
	if ( (ShakeHereTag != 'None') && (ShakeHereTag != '') )
	{
		ForEach C.AllActors(class'Actor',ShakeHereActor,ShakeHereTag)
			break;
	}

	// Shake the view from the big explosion!
	for(con = C.Level.ControllerList; con != None; con=con.NextController)
	{
		// Find who did it first, then shake them
		if(con.bIsPlayer && con.Pawn!=None
			&& con.Pawn.Physics != PHYS_FALLING)
		{
			if(ShakeHereActor != None)
			{
				usedist = VSize(con.Pawn.Location - ShakeHereActor.Location);
				
				if(usedist > MaxShakeDistance)
					usemag = 0;
				else
					usemag = ((MaxShakeDistance - usedist)/MaxShakeDistance);
			}
			else
				usemag = 1.0;

			if(usemag > 0.0)
			{
				con.ShakeView(
				   usemag*ShakeRotMag,
				   ShakeRotRate,
				   usemag*ShakeRotTime,
				   usemag*ShakeOffsetMag,
				   ShakeOffsetRate,
				   usemag*ShakeOffsetTime);
			}
		}
	}

	return false;	
}

function string GetActionString()
{
	return ActionString;
}

defaultproperties
{
	ActionString="Shake Camera"

	ShakeOffsetMag=(X=30.0,Y=30.0,Z=30.0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=6.0
	ShakeRotMag=(X=300.0,Y=300.0,Z=300.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=6.0
	MaxShakeDistance=3000.0
}
