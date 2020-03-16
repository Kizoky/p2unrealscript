///////////////////////////////////////////////////////////////////////////////
// PathBlockingVolume:  
//
// Same as a blocking volume but it gets destroyed on level startup. It effectively
// is there to block paths when they are built, but then go away when the level is played.
//
///////////////////////////////////////////////////////////////////////////////

class PathBlockingVolume extends BlockingVolume;

///////////////////////////////////////////////////////////////////////////////
// Since script only gets called when the level is run--not it the editor--we'll
// just destroy the object here.
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();
	Destroy();
}

defaultproperties
{
	 bPathColliding=true
     bStatic=false
     bNoDelete=false
	 bWorldGeometry=true
	 bBlockNonZeroExtentTraces=true
	 bBlockZeroExtentTraces=true
     bCollideActors=true
     bBlockActors=true
     bBlockPlayers=true
	 bColored=true
	 BrushColor=(A=255,B=0,G=0,R=150)
}