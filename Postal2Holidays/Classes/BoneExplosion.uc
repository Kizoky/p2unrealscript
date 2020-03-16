///////////////////////////////////////////////////////////////////////////////
// VomitExplosion
// 
// Explosion for a vomit projectile from zombies
///////////////////////////////////////////////////////////////////////////////
class BoneExplosion extends P2Explosion;

///////////////////////////////////////////////////////////////////////////////
// Blow up in the air, so make it carry
///////////////////////////////////////////////////////////////////////////////
function AddVelocity(vector vel)
{
	local int i;

	if(Emitters.Length > 0)
	{
		for(i=0; i<Emitters.Length; i++)
		{
			Emitters[i].StartVelocityRange.X.Min += vel.x;
			Emitters[i].StartVelocityRange.X.Max += vel.x;
			Emitters[i].StartVelocityRange.Y.Min += vel.y;
			Emitters[i].StartVelocityRange.Y.Max += vel.y;
			Emitters[i].StartVelocityRange.Z.Min += vel.z;
			Emitters[i].StartVelocityRange.Z.Max += vel.z;
		}
	}
}


///////////////////////////////////////////////////////////////////////////////
// Just a little randomness for the pitch, around 1.0
///////////////////////////////////////////////////////////////////////////////
function float GetRandPitch()
{
	return (0.94 + FRand()*0.08);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Exploding
{
Begin:
	PlaySound(ExplodingSound,,1.0,,,GetRandPitch(),true);
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
     ExplodingSound=Sound'WeaponSounds.foot_kickguy'
     ExplosionMag=5000.000000
     ExplosionDamage=30.000000
     ExplosionRadius=100.000000
     MyDamageType=Class'VomitDamage'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter58
        Acceleration=(Z=-400.000000)
        ColorScale(0)=(Color=(G=128,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        FadeOut=True
        MaxParticles=8
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.500000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
        InitialParticlesPerSecond=300.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.darkchunks'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        BlendBetweenSubdivisions=True
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Max=100.000000))
        Name="SpriteEmitter56"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter58'
    Begin Object Class=MeshEmitter Name=MeshEmitter11
        StaticMesh=StaticMesh'Timb_mesh.Champ.champ_bone_timb'
        Acceleration=(Z=-500.000000)
        MaxParticles=6
        RespawnDeadParticles=False
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=0.100000,Max=0.300000),Y=(Min=0.100000,Max=0.300000),Z=(Min=0.500000,Max=0.600000))
        InitialParticlesPerSecond=300.000000
        AutomaticInitialSpawning=False
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=1.500000,Max=1.500000)
        StartVelocityRange=(X=(Min=-80.000000,Max=80.000000),Y=(Min=-80.000000,Max=80.000000),Z=(Max=250.000000))
        Name="MeshEmitter1"
    End Object
    Emitters(1)=MeshEmitter'MeshEmitter11'
     AutoDestroy=True
     LifeSpan=5.000000
     TransientSoundRadius=200.000000
}
