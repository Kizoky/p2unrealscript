class FGrenadeExplosion extends P2Explosion;

var Sound  FlashExplodeSound;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Exploding
{
Begin:
	PlaySound(FlashExplodeSound,,1.0,,,,true);
	Sleep(DelayToHurtTime);

	CheckFlashbangRadius(ExplosionDamage, ExplosionRadius, MyDamageType, ExplosionMag, Location);
	NotifyPawns();
}

///////////////////////////////////////////////////////////////////////////////
// CheckHurtRadius fails when damage is 0 (as it will be for flashbangs)
// so we have to use this slower unrealscript version.
///////////////////////////////////////////////////////////////////////////////
simulated function CheckFlashbangRadius( float DamageAmount, float DamageRadius, 
										 class<DamageType> DamageType, float MomMag, vector HitLocation )
{
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
			}
		} 
	}
}

defaultproperties
{
	ExplosionMag=20000
	TransientSoundRadius=600
	ExplosionRadius=450
	ExplosionDamage=0

    Begin Object Class=SpriteEmitter Name=SpriteEmitter59
        MaxParticles=7
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.100000,RelativeSize=0.500000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Max=150.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
        InitialParticlesPerSecond=100.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.expl1color'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=2.000000,Max=2.500000)
        StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=-100.000000,Max=100.000000))
        VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
        Name="SpriteEmitter59"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter59'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter60
        Acceleration=(Z=-600.000000)
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=2.000000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=5.000000,Max=5.000000),Y=(Min=5.000000,Max=5.000000),Z=(Min=5.000000,Max=5.000000))
        InitialParticlesPerSecond=100.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.darkchunks'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=1.000000,Max=1.500000)
        StartVelocityRange=(X=(Min=-600.000000,Max=600.000000),Y=(Min=-600.000000,Max=600.000000),Z=(Max=500.000000))
        Name="SpriteEmitter60"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter60'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter64
        Acceleration=(X=30.000000,Y=-10.000000,Z=-20.000000)
        FadeOutStartTime=5.000000
        FadeOut=True
        MaxParticles=50
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-40.000000,Max=40.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.200000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=80.000000,Max=200.000000))
        InitialParticlesPerSecond=100.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=5.000000,Max=10.000000)
        StartVelocityRange=(X=(Min=-80.000000,Max=80.000000),Y=(Min=-80.000000,Max=80.000000),Z=(Min=30.000000,Max=100.000000))
        Name="SpriteEmitter64"
		UseCollision=true
  End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter64'
	LifeSpan=0 // GrenadeExplosion autodestroys after 5 seconds, we want the flashbang smoke to last so turn this off.
	FlashExplodeSound=Sound'PL_FlashGrenadeSound.FlashGrenade_Explosion'
    AutoDestroy=true
	MyDamageType = class'FlashBangDamage'
}