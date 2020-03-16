//=============================================================================
// AWHead
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
//=============================================================================
class AWHead extends Head
	placeable;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var int TimeAtCut;		// time that we popped off the body

const TIME_TILL_SCYTHE_KILL = 2.0;


///////////////////////////////////////////////////////////////////////////////
// Switch to a burned texture
///////////////////////////////////////////////////////////////////////////////
simulated function SwapToBurnVictim()
{
	if(class'P2Player'.static.BloodMode())
		Skins[0] = BurnVictimHeadSkin;
}

///////////////////////////////////////////////////////////////////////////////
// Remove head from body and prep the collision because it's flying off his body
// and through the air, so it needs to bounce around
///////////////////////////////////////////////////////////////////////////////
function bool SetupAfterDetach()
{
	TimeAtCut = Level.TimeSeconds;
	bCollideWorld=true;
	SetCollision(true,true,false);
 	bBlockZeroExtentTraces=true;
 	bBlockNonZeroExtentTraces=true;
	if(IsInState('Exploding'))
		return false;
	else
		return true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool CanDoDying()
{
	if(IsInState('Exploding'))
		return false;
	else
		return true;
}

///////////////////////////////////////////////////////////////////////////////
// Move around or explode
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
					Vector momentum, class<DamageType> ThisDamage)
{
	local vector dir;
	local float DistToMe, CheckDist;
	local bool bCheckExplode;

//	log(self$" take damage "$thisdamage);
//	if(class'P2Player'.static.BloodMode())
//	{
		if(ClassIsChildOf(ThisDamage, class'SledgeDamage')
			|| ClassIsChildOf(ThisDamage, class'SwipeSmashDamage')
			// Don't let the machete kill a head until it's off the body for a while
			|| (ClassIsChildOf(ThisDamage, class'MacheteDamage')
				&& Level.TimeSeconds - TimeAtCut > TIME_TILL_SCYTHE_KILL)
			// Don't let the scythe kill a head until it's off the body for a while
			|| (ClassIsChildOf(ThisDamage, class'ScytheDamage')
				&& Level.TimeSeconds - TimeAtCut > TIME_TILL_SCYTHE_KILL))
		{
			// Only explode here if we're not attached
			if(myBody == None)
			{
				// Tell the dude if he did it
				if(AWDude(InstigatedBy) != None)
					AWDude(InstigatedBy).CrushedHead(FPSPawn(Owner));
				PinataStyleExplodeEffects(HitLocation, Momentum);
				return;
			}
		}
//	}

	Super.TakeDamage(Dam, instigatedBy, hitlocation, momentum, ThisDamage);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Exploding
// Forgot to block those two functions, otherwise, heads can explode,
// but then get removed from this state and not really destroyed--bad for zombies!
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Exploding
{
	ignores HitWall, TakeDamage;
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     HeadBounce(0)=Sound'MiscSounds.People.head_bounce'
     HeadBounce(1)=Sound'MiscSounds.People.head_bounce2'
}
