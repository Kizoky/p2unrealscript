///////////////////////////////////////////////////////////////////////////////
// FlavinClientDec
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Horrible hack to communicate with all clients to decrease the flavin on a
// guy
// 
///////////////////////////////////////////////////////////////////////////////
class FlavinClientDec extends Actor;

const CHANGE_SCALE   = 0.1;
const PITCH_SCALE   = 0.05;

simulated function PostNetBeginPlay()
{
	local FlavinMesh fm;

	Super.PostNetBeginPlay();

	if(Owner != None)
	{
		// search for the accompaning flavin mesh
		foreach DynamicActors(class'FlavinMesh', fm)
		{
			if(fm.Owner == Owner)
			{
				if(fm.DrawScale == fm.default.DrawScale)
				{
					fm.Destroy();
					break;
				}
				else
				{
					fm.SetDrawScale(fm.DrawScale - CHANGE_SCALE);
					break;
				}
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
