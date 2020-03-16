///////////////////////////////////////////////////////////////////////////////
// LevelLoadingView.uc
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Simple object used by the level loading progress bar
// Place one of these in the Entry map so it's facing the surface
// that contains the progress bar material.
///////////////////////////////////////////////////////////////////////////////
class LevelLoadingView extends SmallNavigationPoint
	placeable
	native;


defaultproperties
	{
	bDirectional=true;
	}