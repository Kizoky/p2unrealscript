///////////////////////////////////////////////////////////////////////////////
// Added by Man Chrzan: xPatch 2.0
// P2ShellCase based on EDShellCase
///////////////////////////////////////////////////////////////////////////////
class P2ShellCase extends P2Projectile;

var bool bHasBounced;
var int  numBounces;
var array<Sound> HitSounds;
//var Sound WaterHitSound;
var() float SoundVol;

simulated function HitWall(vector HitNormal,actor Wall)
{
	local vector RealHitNormal;

	if( bHasBounced && ( numBounces > 4 || Velocity.Z > -100 ) )
		bBounce = false;
	numBounces++;

	if( numBounces > 5 )
	{
		return;
	}
	else if ( !PhysicsVolume.bWaterVolume && HitSounds.Length > 0 && SoundVol > 0.00)
	{
		PlaySound(HitSounds[Rand(HitSounds.Length)],SLOT_Misc,SoundVol,,TransientSoundRadius,GetRandPitch());
		// Only play once
		HitSounds.Length = 0;
	}

	RealHitNormal = HitNormal;
	HitNormal     = normal(HitNormal + 0.4 * vRand());

	if ((HitNormal Dot RealHitNormal) < 0)
		HitNormal *= -0.5;

	Velocity      = 0.5 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
	RandSpin(100000);
	bHasBounced   = True;
}

/*
simulated function PhysicsVolumeChange( PhysicsVolume NewVolume )
{
	if (NewVolume.bWaterVolume && !PhysicsVolume.bWaterVolume)
	{
		Velocity    = 0.2 * Velocity;

		if (WaterHitSound != None && SoundVol > 0.00)
			PlaySound(WaterHitSound,SLOT_Misc,SoundVol,,TransientSoundRadius,GetRandPitch());

		bHasBounced = True;
	}
}
*/

simulated function Landed(vector HitNormal)
{
	local rotator RandRot;

	if( numBounces > 4 )
	{
		return;
	}

	SetPhysics(PHYS_None);
	RandRot = Rotation;
	RandRot.Pitch = 0;
	RandRot.Roll  = 0;
	SetRotation(RandRot);
}

function Eject(vector Vel)
{
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).xManager != None)
	{
		LifeSpan = P2GameInfoSingle(Level.Game).xManager.ShellLifetime;
		SoundVol = P2GameInfoSingle(Level.Game).xManager.ShellSoundVol;
	}
	
	Velocity = Vel;
	RandSpin(100000);
	if ((Instigator != none) && Instigator.HeadVolume.bWaterVolume)
	{
		Velocity    = Velocity * (0.2 + fRand() * 0.2);
		bHasBounced = True;
	}
}

defaultproperties
{
	MaxSpeed=1000
	Physics=PHYS_Falling
	DrawType=DT_StaticMesh
	RemoteRole=ROLE_None
	LifeSpan=3
	DrawScale=1.0
	bCollideActors=False
	bBounce=True
	bFixedRotationDir=True
	NetPriority=1.4
	SoundVol=0.5
	//WaterHitSound=Sound'Footsteps.BFootstepWater1'
}
