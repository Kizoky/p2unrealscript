///////////////////////////////////////////////////////////////////////////////
// FlavinClientInc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Horrible hack to communicate with all clients to increase the flavin on a
// guy
// 
///////////////////////////////////////////////////////////////////////////////
class FlavinClientInc extends Actor;

const FLAVIN_BONE_NAME = 'MALE01 spine1';
const CHANGE_SCALE   = 0.1;
const PITCH_SCALE   = 0.05;

simulated function PostNetBeginPlay()
{
	local FlavinMesh fm;
	local bool bIncreased;

	Super.PostNetBeginPlay();

	if(Owner != None)
	{
		// search for the accompaning flavin mesh
		foreach DynamicActors(class'FlavinMesh', fm)
		{
			if(fm.Owner == Owner)
			{
				fm.SetDrawScale(fm.DrawScale + CHANGE_SCALE);
				bIncreased=true;
			}
		}
		// Make a new mesh then for us
		if(!bIncreased)
		{
			if(Level.NetMode != NM_Client)
			{
				fm = spawn(class'FlavinMesh',Owner);
				Owner.AttachToBone(fm, FLAVIN_BONE_NAME);
			}
		}
	}
}

defaultproperties
	{
	NetPriority=+00003.000000
	LifeSpan=2.0
	bHidden=true
	}
