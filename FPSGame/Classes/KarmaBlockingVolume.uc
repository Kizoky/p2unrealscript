///////////////////////////////////////////////////////////////////////////////
// KarmaBlockingVolume
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved
//
// A volume that blocks Karma collision, nothing more, nothing less.
///////////////////////////////////////////////////////////////////////////////
class KarmaBlockingVolume extends BlockingVolume
	hidecategories(BlockingVolume);
	
defaultproperties
{
	bBlockKarma=true
	bWorldGeometry=false
	bCollideActors=false
	bBlockActors=false
	bBlockPlayers=false	
	bColored=true
	BrushColor=(A=255,B=192,G=192,R=192)
}