///////////////////////////////////////////////////////////////////////////
// CullVolume
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved
//
// Just a differently-colored volume with suitable defaults for a culling-
// only volume
//
// IMPORTANT NOTES:
// For performance reasons, the CullVolume feature had to be implemented
// in PhysicsVolume and not a normal Volume. As a result the engine code
// only checks the PhysicsVolume property of the player's pawn (or whatever
// the current ViewTarget is), so if the pawn is in a physicsvolume WITHIN
// a cullvolume, only the CullTag of THAT Physicsvolume will be looked at.
// So if you have physicsvolumes inside the area that you need to use
// CullTags, make sure you set CullTags in ALL the physicsvolumes there.
// This includes subclasses of PhysicsVolume such as WaterVolume,
// InterestVolume etc...
// Another restriction: this won't take effect in the editor, because
// the PhysicsVolume property of the viewport cameras won't be updated.
///////////////////////////////////////////////////////////////////////////
class CullVolume extends PhysicsVolume;

defaultproperties
{
	BrushColor=(A=255,B=255,G=192,R=64)
}
