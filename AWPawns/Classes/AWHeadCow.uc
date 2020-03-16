//=============================================================================
// AWHeadCow
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Static mesh, not an animating mesh
//=============================================================================
class AWHeadCow extends AWHead;

var class<P2Emitter> HeadExplodeClass;	// what explodes

///////////////////////////////////////////////////////////////////////////////
// Do crazy effects
///////////////////////////////////////////////////////////////////////////////
function PinataStyleExplodeEffects(vector HitLocation, vector Momentum)
{
	local P2Emitter headeffects;

	if(HeadExplodeClass != None)
	{
		// Do blood effects
		headeffects = spawn(HeadExplodeClass, , ,Location);
		headeffects.PlaySound(ExplodeHeadSound,,,,100,GetRandPitch()-0.3);
	}

	// Have the head wait just a moment
	GotoState('Exploding');
}

///////////////////////////////////////////////////////////////////////////////
// Setup animations
///////////////////////////////////////////////////////////////////////////////
function SetupAnims()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Play the eyes close animation, and turn off all blending
///////////////////////////////////////////////////////////////////////////////
function PlayAnimDead()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     HeadExplodeClass=Class'AWEffects.CowHeadExplode'
     ExplodeHeadSound=Sound'AWSoundFX.Cow.CowHeadExplode'
     HeadBounce(0)=Sound'MiscSounds.People.head_bounce'
     HeadBounce(1)=Sound'MiscSounds.People.head_bounce2'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'awpeoplestatic.Limbs.Cow_head'
     Skins(0)=Texture'AW_Characters.Zombie_Cows.AW_Cow3'
     bCollideActors=True
     bCollideWorld=True
     bBlockZeroExtentTraces=True
     bBlockNonZeroExtentTraces=True
}
