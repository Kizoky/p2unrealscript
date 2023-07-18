///////////////////////////////////////////////////////////////////////////////
// P2Projectile.
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Buffer class from Projectile to Postal 2 stuff.
// Has some common functions in it
//
///////////////////////////////////////////////////////////////////////////////
class P2Projectile extends Projectile;

var float DetonateTime;			// How long till we explode
var float MinSpeedForBounce;	// If the speed hits this or goes below it will stop bouncing.
var float VelDampen;			// Velocity dampening effects on hit
var float RotDampen;			// Rotation dampening effects on hit
var float StartSpinMag;			// Starting spin speed
var int	  Health;				// What health we have. This can be reduce by hits or kicks
var float DamageMP;				// Damage we take off things in MP games only
var int   TeamIndex;			// To know who made this on a team, in case we need to keep it from 
								// harming whole teams
var Controller Dropper;			// Know who made this, in case the pawn dies and restarts, keep
								// him from dying on 'his own' trap after he respawns. The controller
								// should stay around.


const DIST_CHECK_BELOW = 100;

///////////////////////////////////////////////////////////////////////////////
// Reset actor to initial state - used when restarting level without reloading.
///////////////////////////////////////////////////////////////////////////////
function Reset()
{
	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	// Save controller who spawned me
	SetDropper(Instigator);
}

///////////////////////////////////////////////////////////////////////////////
// Save our instigator
///////////////////////////////////////////////////////////////////////////////
function SetDropper(Pawn NewP)
{
	// Save our new instigator
	if(NewP != None)
		Dropper = Instigator.Controller;
	// Save his team too.
	if(Dropper != None
		&& Dropper.PlayerReplicationInfo != None
		&& Dropper.PlayerReplicationInfo.Team != None)
		TeamIndex = Dropper.PlayerReplicationInfo.Team.TeamIndex;
	//log(self$" saved team "$TeamIndex$" saved controller "$Dropper);
}

///////////////////////////////////////////////////////////////////////////////
// Transfer this new instigator as the one who the damage is attributed to. 
///////////////////////////////////////////////////////////////////////////////
function TransferInstigator(Pawn NewInst)
{
	// In MP games, the guy that destroyed the grenade(or other projectile) now gets kills for anyone the
	// grenade kills. And now, if this grenade blows up other grenades, he'll also
	// get credit from the damage from those too.
	if(NewInst != None
		&& NewInst != Instigator
		&& (FPSGameInfo(Level.Game) == None
			|| !FPSGameInfo(Level.Game).bIsSinglePlayer))
	{
		Instigator = NewInst;
		SetDropper(Instigator);
		//log(self$" setting new instigator "$NewInst$" dropper "$Dropper);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Decide if it was made by a pawn of this team
///////////////////////////////////////////////////////////////////////////////
simulated function bool SameTeam(Pawn CheckMe)
{
	//log(self$" same team, theirs "$CheckMe.Controller.PlayerReplicationInfo.Team.TeamIndex$" mine "$TeamIndex);
	return (CheckMe != None
			&& CheckMe.Controller != None
			&& CheckMe.Controller.PlayerReplicationInfo != None
			&& CheckMe.Controller.PlayerReplicationInfo.Team != None
			&& CheckMe.Controller.PlayerReplicationInfo.Team.TeamIndex == TeamIndex);
}

///////////////////////////////////////////////////////////////////////////////
// Decide if this pawn passed in is the one who made me
///////////////////////////////////////////////////////////////////////////////
simulated function bool MadeMe(Pawn CheckMe)
{
			
	return (CheckMe != None
			// If we have a team, make sure he's from that team (he could have switched
			// after he made it, so we don't want him switching teams and running
			// around picking up his old traps in the enemies base
			&& (TeamIndex < 0
				|| SameTeam(CheckMe))
			// Was the instigator
			&& (CheckMe == Instigator
				// or same controller owned original pawn instigator
				|| CheckMe.Controller == Dropper));
}
///////////////////////////////////////////////////////////////////////////////
// Decide if this pawn passed in is one who either made me, or is friends
// with my maker
///////////////////////////////////////////////////////////////////////////////
simulated function bool RelatedToMe(Pawn CheckMe)
{
	//log(self$" related "$CheckMe$" inst "$Instigator);
	return (CheckMe != None
			// Was the instigator
			&& (CheckMe == Instigator
				// or same controller owned original pawn instigator
				|| CheckMe.Controller == Dropper)
				// or we were made for a team and this guy is on that team
				|| (TeamIndex >= 0
					&& SameTeam(CheckMe))
);
}

///////////////////////////////////////////////////////////////////////////////
// Return the instigator, or if you don't have one, the pawn of the
// original controller that made you
///////////////////////////////////////////////////////////////////////////////
simulated function Pawn GetMaker()
{
	if(Instigator != None)
		return Instigator;
	else if(Dropper != None
		&& Dropper.Pawn != None)
		return Dropper.Pawn;
	else
		return None;
}

///////////////////////////////////////////////////////////////////////////////
// Rockets can sometimes be controlled by the player
///////////////////////////////////////////////////////////////////////////////
simulated function bool AllowControl()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Just a little randomness for the pitch, around 1.0
///////////////////////////////////////////////////////////////////////////////
simulated function float GetRandPitch()
{
	return (0.96 + FRand()*0.08);
}

///////////////////////////////////////////////////////////////////////////////
// Use the current speed, not the default one, like the original function in Projectile::GetTossVelocity
///////////////////////////////////////////////////////////////////////////////
simulated function vector GetThrownVelocity(Pawn P, Rotator R, float ThrowMod)
{
	local vector V;
	local float veldot;

	V = Vector(R);
	if(P != None)
		veldot = (P.Velocity Dot V);
	if(veldot < 0)
		veldot = 0;
	V *= (veldot*ThrowMod + Speed);
	V.Z += TossZ;
	return V;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function AddRelativeVelocity(vector OwnerVel)
{
	local float dotval;
	local vector NewVel, LookDir;

	LookDir = Normal(vector(Rotation));
	dotval = LookDir Dot OwnerVel;
	NewVel = dotval * LookDir;
	Velocity += NewVel;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function BounceRecoil(vector HitNormal)
{
	Velocity = VelDampen * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
	StartSpinMag = RotDampen*StartSpinMag;
	RandSpin(StartSpinMag);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function HitWall (vector HitNormal, actor Wall)
{
	if ( Role == ROLE_Authority )
	{
		if ( Mover(Wall) != None )
		{
			// Balance damage differently in SP vs MP.
			if(Level.NetMode == NM_Standalone)
//			if(Level.Game != None
//				&& FPSGameInfo(Level.Game).bIsSinglePlayer)
				Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			else
				Wall.TakeDamage( DamageMP, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
		}

		MakeNoise(1.0);
	}
	Explode(Location + ExploWallOut * HitNormal, HitNormal);
	if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
		Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function BlowUp(vector HitLocation)
{
	// Balance damage differently in SP vs MP.
	if(Level.NetMode == NM_Standalone)
//	if(Level.Game != None
//		&& FPSGameInfo(Level.Game).bIsSinglePlayer)
		HurtRadius(Damage,DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
	else
		HurtRadius(DamageMP,DamageRadius, MyDamageType, MomentumTransfer, HitLocation );

	if ( Role == ROLE_Authority )
		MakeNoise(1.0);
}

// Stub used in many subclasses
simulated function GenExplosion(vector HitLocation, vector HitNormal, Actor Other);

// xPatch: Stub used in AltDynamiteProjectile
simulated function HitByMatch();

defaultproperties
{
	TransientSoundRadius=100
	DamageMP=0.0
	TeamIndex=-1
}
