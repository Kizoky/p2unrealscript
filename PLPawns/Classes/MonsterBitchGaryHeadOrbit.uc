//////////////////////////////////////////////////////////////////////////////
// MonsterBitchGaryHeadOrbit
// Copyright 2015 Running With Scissors Inc. All Rights Reserved
//
// Orbiting gary heads, MB can spit these out on occasion.
// Just need to override a couple functions, AW code handles the rest.
//////////////////////////////////////////////////////////////////////////////
class MonsterBitchGaryHeadOrbit extends GaryHeadOrbit;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	if(!bDeleteMe)
	{
		if(MonsterBitch(Owner) != None)
			MonsterBitch(Owner).RemoveOrbitHead(self);
	}
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// If there is an eye, link to it, if there's not, make one
///////////////////////////////////////////////////////////////////////////////
function CheckForEye()
{
	local Actor findeye;

	foreach DynamicActors(bigeyeclass, findeye)
	{
		if(AWBossEye(findeye) != None
			&& !AWBossEye(findeye).bDying)
		{
			BigEye = AWBossEye(findeye);
			break;
		}
	}

	if(BigEye == None)
	{
		BigEye = spawn(bigeyeclass, Owner, , Owner.Location);
		// Link it up to the cowboss
		if(MonsterBitch(Owner) != None)
		{
			MonsterBitch(Owner).GreatEye = BigEye;
			BigEye.BossOffset = MonsterBitch(Owner).EyeOffset;
		}
	}

	// Update the eye
	if(BigEye != None)
	{
		BigEye.HeadAdded();
		SetTarget(BigEye);
	}
}

// Make these a lot bigger and easier to kill because the bitch monster is so huge
defaultproperties
{
	DrawScale=4.5
	CollisionRadius=80.000000
	CollisionHeight=80.000000
	SoundRadius=150.000000
	TransientSoundRadius=150.000000
}