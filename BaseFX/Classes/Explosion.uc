///////////////////////////////////////////////////////////////////////////////
// Explosion
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
// 
// Emitter effect with damaging explosion.
//
// Kamek 5-8 added I Am Legion achievement because I'm a dumbass and forgot it
///////////////////////////////////////////////////////////////////////////////
class Explosion extends Wemitter;

var sound ExplodingSound;			// Sound played when it breaks
var float ExplosionMag;				// How strong (momentum, damage, radius) the explosion is
var float ExplosionDamage;			// how much it hurts
var float ExplosionRadius;			// how far the hurt reaches
var vector ForceLocation;			// spot we use to actually hurt things from

var float DelayToHurtTime;			// Time you need to wait till you hurt things with your explosion blast
							// This usually only gets set when you are triggered/hurt by a another explosion
							// in order to make good 'explosion chains'
var float DelayToNotifyTime;		// Time till you tell people it exploded. Happens after DelayToHurtTime
							// so factor that in as well.
var class<damageType> MyDamageType;	// Type of explosive damage

// Multiplayer values for different balancing
var float ExplosionMagMP;				// How strong (momentum, damage, radius) the explosion is
var float ExplosionDamageMP;			// how much it hurts
var float ExplosionRadiusMP;			// how far the hurt reaches

var int   TeamIndex;			// To know who made this on a team, in case we need to keep it from 
								// harming whole teams
var Controller Dropper;			// Know who made this, in case the pawn dies and restarts, keep
								// him from dying on 'his own' trap after he respawns. The controller
								// should stay around.

const MAX_SHAKE_DIST		=	2500.0;
const SHAKE_ADD_RATIO		=	0.35;
const SHAKE_BASE_RATIO		=	0.25;
const SHAKE_CAMERA_MAX_MAG	=	200;

var int Kills;
const KILLS_FOR_ACHIEVEMENT = 5;
var int PeopleBurned;

var bool bIgnoreInstigator;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();
	// Default it to where we currently are
	ForceLocation = Location;
	// Copy over new values if they differ from SP defaults. 
	// The only reason this is okay is because we don't directly access the default props
	if(ExplosionMagMP == 0)
		ExplosionMagMP = ExplosionMag;
	if(ExplosionDamageMP == 0)
		ExplosionDamageMP = ExplosionDamage;
	if(ExplosionRadiusMP == 0)
		ExplosionRadiusMP = ExplosionRadius;

	// Wipe the owner so that in single player, slow motion will work properly.
	// Anything who's owner is player still goes at normal speed, but if not
	// it goes in slow motion. 
	// But we definitely want the owner transferred correctly in MP for network relevance
	if(Level.Game != None
		&& Level.Game.bIsSinglePlayer)
		SetOwner(None);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	// Save controller who spawned me
	if(Instigator != None)
		Dropper = Instigator.Controller;
	// Save his team too.
	if(Dropper != None
		&& Dropper.PlayerReplicationInfo != None
		&& Dropper.PlayerReplicationInfo.Team != None)
		TeamIndex = Dropper.PlayerReplicationInfo.Team.TeamIndex;
	//log(self$" Owner "$Owner$" saved team "$TeamIndex$" saved controller "$Dropper);
}

///////////////////////////////////////////////////////////////////////////////
// For some reason HurtRadius is flakey, so we use this slower version to
// make sure it hits stuff
///////////////////////////////////////////////////////////////////////////////
simulated final function CheckHurtRadius( float DamageAmount, float DamageRadius, 
										 class<DamageType> DamageType, float MomMag, vector HitLocation )
{
	local int bSuicideTaliban;
	local PlayerController PlayerLocal;
	
	// Call explosion form of HurtRadiusEX, with checks for Kumquats and Fanatics for the related achievement.
	Kills += HurtRadiusEX(DamageAmount, DamageRadius, DamageType, MomMag, HitLocation,,,true,,,,true,"Kumquat,Fanatic",bSuicideTaliban);
	
	/*
	local actor Victims;
	local float damageScale, dist, OldHealth;
	local vector dir;
	local vector Momentum;
	local bool bDoHurt;
	
	foreach CollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		if( (!Victims.bHidden)
			&& (Victims != self) 
			&& (Victims.Role == ROLE_Authority) )
		{
			// If it's a player pawn (main player in single, or anyone in multi)
			// then check to have explosions blocked by 'walls'. 
			if(Pawn(Victims) != None
				&& PlayerController(Pawn(Victims).Controller) != None)
			{
				// solid check
				if(FastTrace(Victims.Location, Location))
					bDoHurt=true;
				else // something in the way, so don't do hurt this time
					bDoHurt=false;
			}
			else
				bDoHurt=true;
				
			// New bIgnoreInstigator flag
			if (bIgnoreInstigator
				&& Victims == Instigator)
				bDoHurt=false;

			if(bDoHurt)
			{
				if (Pawn(Victims) != None)				
					OldHealth = Pawn(Victims).Health;
				else
					OldHealth = 0;
				dir = Victims.Location - HitLocation;
				dist = FMax(1,VSize(dir));
				dir = dir/dist; 
				damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
				Momentum = (damageScale * MomMag * dir);
				// Create a fake momentum vector which emphasizes being thrown into the air
				if(dir.z > 0)
					Momentum.z += (MomMag*(1- dist/DamageRadius));
				Victims.TakeDamage
				(
					damageScale * DamageAmount,
					Instigator, 
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					Momentum,
					DamageType
				);
				// Kamek 6-19 napalm check
				if (Self.IsA('NapalmExplosion'))
				{
					if (PeopleBurned >= 5
						&& Instigator != None
						&& Instigator.Controller != None
						&& PlayerController(Instigator.Controller) != None)
						PlayerController(Instigator.Controller).GetEntryLevel().EvaluateAchievement(PlayerController(Instigator.Controller),'GoodMorningVietnam');
					PeopleBurned++;
					//debuglog(self@"people burned"@peopleburned);
				}	
				if (Pawn(Victims) != None
					&& OldHealth > 0
					&& Pawn(Victims).Health <= 0)
				{
					//log(self@"killed"@Victims,'Debug');
					Kills++;
					if (Victims.IsA('Kumquat') || Victims.IsA('Fanatic'))
						bSuicideTaliban=True;
				}
			}
		} 
	}
	*/

	// Can't override this function in GrenadeHeadExplosion, so check for the I AM LEGION achievement here.
	if (Kills >= KILLS_FOR_ACHIEVEMENT
		&& (Self.IsA('GrenadeHeadExplosion') 
			|| Self.IsA('MiniNukeHeadExplosion')))	// xPatch: Fix to allow unlocking this achievement in Enhanced Game too.
		{
			foreach DynamicActors(class'PlayerController',PlayerLocal)
				break;
			
			if( Level.NetMode != NM_DedicatedServer ) PlayerLocal.GetEntryLevel().EvaluateAchievement(PlayerLocal,'SuicideBomber');
		}
		
	// Check for taliban suicide here, because checking in the pawn won't work.
	if (bSuicideTaliban == 1
		&& (Self.IsA('GrenadeHeadExplosion')
			|| Self.IsA('MiniNukeHeadExplosion')))	// xPatch: Fix to allow unlocking this achievement in Enhanced Game too.
		{
			foreach DynamicActors(class'PlayerController',PlayerLocal)
				break;
			
			if( Level.NetMode != NM_DedicatedServer ) PlayerLocal.GetEntryLevel().EvaluateAchievement(PlayerLocal,'ReversePsychology');
		}
}

///////////////////////////////////////////////////////////////////////////////
// Tell the pawns around this area, that an explosion happened.
///////////////////////////////////////////////////////////////////////////////
function NotifyPawns()
{
	// STUB, defined in P2Explosion
}

///////////////////////////////////////////////////////////////////////////////
// Expects mags under SHAKE_CAMERA_MAX_MAG for reasonable shakes
// Over 200 or so, and the camera shakes through the ground.
///////////////////////////////////////////////////////////////////////////////
function ShakeCamera(float Mag)
{
	local controller con;
	local float usemag, usedist;
	local vector Rotv, Offsetv;

	// Put a cap on the shake to make sure no one accidentally puts too much in
	if(Mag > SHAKE_CAMERA_MAX_MAG)
		Mag = SHAKE_CAMERA_MAX_MAG;

	// Shake the view from the big explosion!
	// Move this somewhere else?
	for(con = Level.ControllerList; con != None; con=con.NextController)
	{
		// Find who did it first, then shake them
		if(con.bIsPlayer && con.Pawn!=None
			&& con.Pawn.Physics != PHYS_FALLING)
		{
			usedist = VSize(con.Pawn.Location - Location);
			
			if(usedist < MAX_SHAKE_DIST)
			{
				usemag = ((MAX_SHAKE_DIST - usedist)/MAX_SHAKE_DIST)*SHAKE_ADD_RATIO*Mag;
				usemag += SHAKE_BASE_RATIO*Mag;
				// If you're actually hurt by the explosion bump up the shake a lot more
				if(usedist < ExplosionRadius)
				{
					Rotv=vect(1.0,1.0,2.0);
					Offsetv=vect(1.0,1.0,2.5);
				}
				else
				{
					Rotv=vect(1.0,1.0,1.0);
					Offsetv=vect(1.0,1.0,1.0);
				}

				con.ShakeView((usemag * 0.2 + 1.0)*Rotv, 
				   vect(1000,1000,1000),
				   1.0 + usemag*0.02,
				   (usemag * 0.3 + 1.0)*Offsetv,
				   vect(800,800,800),
				   1.0 + usemag*0.02);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Exploding
{
Begin:
	Kills = 0;
	PlaySound(ExplodingSound,,1.0,,,,true);
	Sleep(DelayToHurtTime);

	if(Level.Game != None
		&& FPSGameInfo(Level.Game).bIsSinglePlayer)
		CheckHurtRadius(ExplosionDamage, ExplosionRadius, MyDamageType, ExplosionMag, ForceLocation);
	else
		CheckHurtRadius(ExplosionDamageMP, ExplosionRadiusMP, MyDamageType, ExplosionMagMP, ForceLocation);

	Sleep(DelayToNotifyTime);
	NotifyPawns();
}

defaultproperties
{
	bStatic=false
	bShadowCast=false
	bCollideActors=true
	bCollideWorld=false
	bBlockActors=false
	bBlockNonZeroExtentTraces=true
	bBlockZeroExtentTraces=true
	bBlockPlayers=false
	bWorldGeometry=false
	bBlockKarma=false
	bAcceptsProjectors=false

	DelayToHurtTime=0.05
	DelayToNotifyTime = 0.5
	ExplosionMag=50000
	ExplosionRadius=500
	ExplosionDamage=100
	MyDamageType = class'ExplodedDamage'
    ExplodingSound=Sound'WeaponSounds.explosion_long'

	LifeSpan=1.0
	TransientSoundRadius=800
	bIgnoreInstigator=false
}
