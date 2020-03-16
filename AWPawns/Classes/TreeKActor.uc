///////////////////////////////////////////////////////////////////////////////
// TreeKActor
// Able to be pushed by elephants only, not other pawns
///////////////////////////////////////////////////////////////////////////////

class TreeKActor extends KActor;

var() class<Pawn> PawnBumpFilter;	// Pawns we allow to bump us over.
var() bool bBlockBumpFilter;		// True means you'll accept all pawns bumping you except PawnBumpFilter
									// false means you'll only accept PawnBumpFilter bumping you.(default is false)
var() class<DamageType> DamageFilter;// Damage type we're concerned about.
									// To allow all damage types, have this be none (default)
var() bool bBlockDamageFilter;		// True means you'll accept all damages except DamageFilter
									// false means you'll only accept DamageFilter.(default is false)
var() float MomentumRatio;			// 1.0 is whatever comes is stays the same, we lower it by 
									// default to make explosions barely knock over trees
var() Sound FallSound;				// sound we make once as we crash to the ground.

var bool bFallen;					// If it's fallen over yet

const FALL_TIME	= 1.0;

///////////////////////////////////////////////////////////////////////////////
// Don't allow the impact sounds to be loaded
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super(Actor).PostBeginPlay();
	// Try for stasis first,.. things will wake you up later
	bStasis=true;
}

///////////////////////////////////////////////////////////////////////////////
// Only do this once, play a sound also if we have it.
///////////////////////////////////////////////////////////////////////////////
function StartFall()
{
	if(!bFallen)
	{
		PlaySound(FallSound, , , , , 0.96 + FRand()*0.08);
		GotoState('FallingOver');
	}
}

///////////////////////////////////////////////////////////////////////////////
// If DamageFilter is set, 
// and bBlockDamageFilter is false only allow this damage
// else don't allow only this damage
///////////////////////////////////////////////////////////////////////////////
function bool AcceptThisDamage(class<DamageType> damageType)
{
	if(damageType == None)
		return true;

	if(DamageFilter != None)
	{
		// accept only filter
		if(!bBlockDamageFilter)
		{
			if(!ClassIsChildOf(damageType, DamageFilter))
				return false;
		}
		else	// block the filter type
		{
			if(ClassIsChildOf(damageType, DamageFilter))
				return false;
		}
	}

	return true;
}

///////////////////////////////////////////////////////////////////////////////
// See who's allowed to knock us over
///////////////////////////////////////////////////////////////////////////////
function bool AcceptBump(Pawn BumperPawn)
{
	if(BumperPawn == None)
		return false;

	if(PawnBumpFilter != None)
	{
		// accept only filter
		if(!bBlockBumpFilter)
		{
			if(!ClassIsChildOf(BumperPawn.class, PawnBumpFilter))
				return false;
		}
		else	// block the filter type
		{
			if(ClassIsChildOf(BumperPawn.class, PawnBumpFilter))
				return false;
		}
	}
	
	// Quick fix for elephants walking into trees and knocking them over. We want them to be charging to knock us over
	if (!BumperPawn.Controller.IsInState('Attacking')
		&& !BumperPawn.Controller.IsInState('RunToTarget')
		&& !BumperPawn.Controller.IsInState('Rampaging')
		&& !BumperPawn.Controller.IsInState('ChargeAtTarget'))
		return false;

	return bPawnMovesMe;
}

///////////////////////////////////////////////////////////////////////////////
// Default behaviour when shot is to apply an impulse and kick the KActor.
// Certain types of damage amkes me fall down. 
// Explosive is the only right now.
///////////////////////////////////////////////////////////////////////////////
function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	if(AcceptThisDamage(damageType))
	{
		StartFall();

		Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum*MomentumRatio, damageType);
	}
}

///////////////////////////////////////////////////////////////////////////////
// By default, only elephants can move me.
///////////////////////////////////////////////////////////////////////////////
event Bump( Actor Other )
{
	if(AcceptBump(Pawn(Other)))
	{
		StartFall();
	
		Super.Bump(Other);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FallingOver
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FallingOver
{
	ignores StartFall;
Begin:
	Sleep(FALL_TIME);
	bFallen=true;
	GotoState('');
}

defaultproperties
{
     PawnBumpFilter=Class'AWPawns.AWElephantPawn'
     DamageFilter=Class'BaseFX.ExplodedDamage'
     MomentumRatio=0.010000
     FallSound=Sound'LevelSoundsFo.Misc.treecrash2'
     StaticMesh=StaticMesh'Zo_poundmesh.Other.zo_treecollision'
     TransientSoundVolume=2.000000
     TransientSoundRadius=600.000000
}
