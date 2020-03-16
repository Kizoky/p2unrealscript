//=============================================================================
// JumpDest.
// specifies positions that can be reached with greater than normal jump
// forced paths will check for greater than normal jump capability
// NOTE these have NO relation to JumpPads
//=============================================================================
class JumpDest extends NavigationPoint
	native;

cpptext
{
	virtual void SetupForcedPath(APawn* Scout, UReachSpec* Path);
	void ClearPaths();
}

var int NumUpstreamPaths;
var ReachSpec UpstreamPaths[8];
var vector NeededJump[8]; 

function int GetPathIndex(ReachSpec Path)
{
	local int i;

	if ( Path == None )
		return 0;

	for ( i=0; i<4; i++ )
		if ( UpstreamPaths[i] == Path )
			return i;
	return 0;
}

event int SpecialCost(Pawn Other, ReachSpec Path)
{
	local int Num;

	Num = GetPathIndex(Path);
	if ( Abs(Other.JumpZ/Other.PhysicsVolume.Gravity.Z) >= Abs(NeededJump[Num].Z/Other.PhysicsVolume.Default.Gravity.Z) ) 
		return 100;

	return 10000000;
}

event bool SuggestMovePreparation(Pawn Other)
{
	local int Num;
	if ( Other.Controller == None )
		return false;

	Num = GetPathIndex(Other.Controller.CurrentPath);
	if ( Abs(Other.JumpZ/Other.PhysicsVolume.Gravity.Z) < Abs(NeededJump[Num].Z/Other.PhysicsVolume.Default.Gravity.Z) ) 
		return false;

	Other.Controller.MoveTarget = self;
	Other.Controller.Destination = Location;
	Other.bNoJumpAdjust = true;
	Other.Velocity = NeededJump[Num];
	Other.Acceleration = vect(0,0,0);
	Other.SetPhysics(PHYS_Falling);
	Other.Controller.SetFall();
	Other.DestinationOffset = CollisionRadius;
	return false;
}

defaultproperties
{
	bSpecialForced=true
}