//////////////////////////////////////////////////////////////////////////////
// MolotovAltProjectile.
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// This is the actual Molotov that falls on the ground, ready to blow up
// Explicit extra projectiles are made so multiplayer works better. This is
// because by setting default props ahead of time you can avoid 
// trying to replicate things after spawning.
//
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Changed by Man Chrzan: xPatch 2.0
// Molotov now plays burning sounds when placed on ground.
// Originally this file was empty and just extending MolotovProjectile.
// (with exception for default properties)
///////////////////////////////////////////////////////////////////////////////

class MolotovAltProjectile extends MolotovProjectile;

var Sound   MolotovFuse;

///////////////////////////////////////////////////////////////////////////////
// Make the fire and new sound too
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	local Rotator uprot;

	Super(GrenadeProjectile).PostBeginPlay();

	// Call this on client or single player
	if ( Level.NetMode != NM_DedicatedServer)
	{
		wickfire = spawn(class'MolotovWickFire', self,,Location);
		wickfire.SetBase(self);
		
		PlayFuseSound();
	}
}

simulated function PlayFuseSound()
{
	PlaySound(MolotovFuse, SLOT_Misc, 6.0, false, 64.0, 1.0);
}

///////////////////////////////////////////////////////////////////////////////
// Blow up and generate effects + cancel sound
///////////////////////////////////////////////////////////////////////////////
simulated function GenExplosion(vector HitLocation, vector HitNormal, Actor Other)
{
	local MolotovExplosion me;

	if(Role == ROLE_Authority)
	{
		me = spawn(class'MolotovExplosion',GetMaker(),,HitLocation);
		me.SetupExp(HitNormal, Other);
		me.UseNormal = HitNormal;
		me.ImpactActor = Other;
	}

 	Destroy();
	KillFuseSound();
}

function KillFuseSound()
{
	if(MolotovFuse != None)
	{
		PlaySound(MolotovFuse, SLOT_Misc, 0.01);
		MolotovFuse = None;
	}
}

defaultproperties
{
	bArmed=false
	DetonateTime=8.0
	
	// Added by Man Chrzan: xPatch 2.0
	MolotovFuse=Sound'WeaponSoundsToo.molotov_lightloop_8sec'
}
