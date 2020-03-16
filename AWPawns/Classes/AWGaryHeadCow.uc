//=============================================================================
// AWGaryHeadCow
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Head of Gary Coleman that's really a cowhead.
//=============================================================================
class AWGaryHeadCow extends AWGaryHead
	placeable;


var class<AnthCloud> cloudclass;

///////////////////////////////////////////////////////////////////////////////
// Do crazy effects
// In addition to exploding the head like normal, he creates
// a anthrax cloud around him
///////////////////////////////////////////////////////////////////////////////
function PinataStyleExplodeEffects(vector HitLocation, vector Momentum)
{
	local AnthCloud MyCloud;

	Super.PinataStyleExplodeEffects(HitLocation, Momentum);

	if(cloudclass != None)
	{
		MyCloud = spawn(cloudclass,Owner,,Location);
		MyCloud.PlaySound(ExplodeHeadSound,,,,100,GetRandPitch());
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     cloudclass=Class'FX.AnthCloud'
     StartRotation=(Pitch=8500,Yaw=16384,Roll=-16384)
     HeadBounce(0)=Sound'MiscSounds.People.head_bounce'
     HeadBounce(1)=Sound'MiscSounds.People.head_bounce2'
     DrawType=DT_StaticMesh
     RelativeRotation=(Pitch=8500,Yaw=16384,Roll=-16384)
     StaticMesh=StaticMesh'stuff.stuff1.CowHead'
}
