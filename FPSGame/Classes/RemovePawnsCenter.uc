///////////////////////////////////////////////////////////////////////////////
// RemovePawnsCenter
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
//
// Easily-identifiable marker for ACTION_RemoveNonMoviePawns
///////////////////////////////////////////////////////////////////////////////
class RemovePawnsCenter extends Keypoint
	hidecategories(Movement,Lighting,LightColor,Karma,Force,Shadow);

defaultproperties
{
	bBlockZeroExtentTraces=false
	bBlockNonZeroExtentTraces=false
	bCollideActors=true
	bUseCylinderCollision=true
	CollisionRadius=50
	CollisionHeight=50
	Texture=Texture'PostEd.Icons_256.RemovePawn'
}
