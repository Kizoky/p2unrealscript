//=============================================================================
// MPHead
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
//	Multiplayer head
//
//=============================================================================
class MPHead extends Head;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
// Get your head skins out of the pawn itself. They must be specified there
// in order for them to show up correctly on remote clients. The gimp for
// instance uses a robber head. By default that shows up. We change it here
// to be the proper robber head.
///////////////////////////////////////////////////////////////////////////////
simulated function PostNetBeginPlay()
{
	local xMpPawn usepawn;
	Super.PostNetBeginPlay();

	usepawn = xMpPawn(Owner);
	if(usepawn != None)
	{
		Instigator = usepawn;
		Setup(usepawn.HeadMesh, 
			usepawn.HeadSkin, 
			usepawn.HeadScale, 
			usepawn.AmbientGlow);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
