///////////////////////////////////////////////////////////////////////////////
// BoltonPart
// Copyright 2013 Running With Scissors, Inc.  All Rights Reserved.
//
// Subclass of PeoplePart used just for boltons.
//
///////////////////////////////////////////////////////////////////////////////
class BoltonPart extends PeoplePart;

// Hack fix for boltons spawning and just staying there without actually connecting to their owners.
event PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(1.0, false);
}

// After we get spawned, make sure we're attached to something, if not then go away because we didn't get set up right for some reason.
event Timer()
{
	if (Base == None)
	{
		warn(self@staticmesh@"has no base!!!");
		Destroy();
	}
}

// Destroy anything attached to us, like cigarette smoke
event Destroyed()
{
	local int i;
	
	for (i = 0; i < Attached.Length; i++)
		Attached[i].Destroy();
}