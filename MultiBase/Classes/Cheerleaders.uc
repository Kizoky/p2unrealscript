///////////////////////////////////////////////////////////////////////////////
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Postal babes for the winners in MP games.
///////////////////////////////////////////////////////////////////////////////
class Cheerleaders extends Actor;


const BLEND_TIME = 0.4;

var Sound CheerSound;

///////////////////////////////////////////////////////////////////////////////
// Start off the cheering. Make sure it's simulated so it will work in MP.
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	PlayCheer();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Reset()
{
	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event AnimEnd(int Channel)
	{
	PlayCheer();
	}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayCheer()
{
	PlayAnim(GetAnimCheer(), 1.0, BLEND_TIME);

	// Make some body-grinding, moaning noises
	if(Level.NetMode != NM_DedicatedServer)
	{
									// pitch them slightly around
		PlaySound(CheerSound,,1.0,,,0.8+Frand()*0.4,true);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function name GetAnimCheer()
{
	// Change by NickP: MP fix
	/*local int rnd;

	rnd = Rand(3);
	switch(rnd)
	{
	case 0:
		return 's_cheer1';
		break;
	case 1:
		return 's_cheer2';
		break;
	case 2:
		return 's_cheer3';
		break;
	}*/
	switch( Rand(4) )
	{
		case 0:
			return 'dropped';
			break;
		case 1:
			return 's_cheer1';
			break;
		case 2:
			return 's_cheer3';
			break;
		case 3:
			return 's_cheer4';
			break;
		default:
			return 's_cheer4';
	}
	// End
}


defaultproperties
{
	// Don't want to collide with anything
	bCollideActors=False
	bCollideWorld=False
	bBlockActors=False
	bBlockPlayers=False
 	bBlockZeroExtentTraces=False
 	bBlockNonZeroExtentTraces=False

	DrawType=DT_Mesh
 	TransientSoundRadius=300

	// keeps them from looking like vampires.. thought that's pretty hot too
	AmbientGlow=100
}