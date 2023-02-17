///////////////////////////////////////////////////////////////////////////////
// MonsterBitchRockExplosion
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
//
// Explosion for a flaming rock projectile
///////////////////////////////////////////////////////////////////////////////
class MonsterBitchRockExplosion extends P2Explosion;

var vector BallPoint;
var vector UseNormal;
var Actor  ImpactActor;
var class<FirePuddle> puddclass;
var class<FirePillar> pillclass;
var class<FireBall>   ballclass;

//const RING_GROW_TIME=	0.7;
const FLAT_GROUND	=	0.8;
const RING_RADIUS	=	200;

///////////////////////////////////////////////////////////////////////////////
// Set a few more vars before we get going
///////////////////////////////////////////////////////////////////////////////
simulated function SetupExp(vector HitNormal, Actor Other)
{
	UseNormal = HitNormal;
	ImpactActor = Other;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Exploding
{
	///////////////////////////////////////////////////////////////////////////////
	// Make the explosion of tiny broken glass
	// Make the ring of expanding fire with puddle, if we're on a flat enough surface
	///////////////////////////////////////////////////////////////////////////////
	function MakeBase()
	{
		local vector loc;
		local DynamicFireStarterRing fr;

		if(UseNormal.z > FLAT_GROUND
			&& puddclass != None)
		{
			loc = 2*UseNormal + Location;
			fr = spawn(class'DynamicFireStarterRing',Owner,,loc);
			// We don't make a fire puddle and link it now.. this is a dynamic 
			// fire ring, and it will make it for us.
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Central fire pillar
	///////////////////////////////////////////////////////////////////////////////
	function MakePillar()
	{
		local FirePillar fp;
		local vector loc;

		loc = 2*UseNormal + Location;
		fp = spawn(pillclass,,,loc);
		fp.CheckCeiling(UseNormal);

		BallPoint = fp.Location;
		BallPoint.z += fp.BallHeight;
	}
	///////////////////////////////////////////////////////////////////////////////
	// Top fireball
	///////////////////////////////////////////////////////////////////////////////
	function MakeBall()
	{
		local FireBall fp;
		fp = spawn(ballclass,,,BallPoint);
	}
Begin:
	MakeBase();	
	PlaySound(ExplodingSound,,1.0,,,,true);
	CheckHurtRadius(ExplosionDamage, ExplosionRadius, MyDamageType, ExplosionMag, Location);
	NotifyPawns();

	MakePillar();
	Sleep(0.4);
	MakeBall();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ExplodingSound=Sound'WeaponSounds.Grenade_ExplodeGround'
	ExplosionMag=80000
	TransientSoundRadius=1200
	ExplosionRadius=800
	ExplosionDamage=130
	MyDamageType = class'FireExplodedDamage'
	Lifespan=10
	puddclass = class'FirePuddle'
	pillclass = class'FirePillar'
	ballclass = class'FireBall'
	
	Begin Object Class=MeshEmitter Name=Rock02Emitter1
		StaticMesh=StaticMesh'MrD_PL_Mesh.FX.Rock02'
		Acceleration=(Z=-1000.000000)
		UseCollision=True
		DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
		MaxParticles=40
		RespawnDeadParticles=False
		SpinParticles=True
		SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
		StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
		UseSizeScale=True
		SizeScale(0)=(RelativeSize=0.300000)
		SizeScale(1)=(RelativeTime=0.300000)
		StartSizeRange=(X=(Min=0.300000,Max=1.500000),Y=(Min=0.300000,Max=1.500000),Z=(Min=0.800000,Max=1.500000))
		InitialParticlesPerSecond=300.000000
		AutomaticInitialSpawning=False
		SecondsBeforeInactive=0.000000
		LifetimeRange=(Min=2.500000)
		StartVelocityRange=(X=(Min=-600.000000,Max=600.000000),Y=(Min=-600.000000,Max=600.000000),Z=(Max=600.000000))
	End Object
	Emitters(0)=MeshEmitter'Rock02Emitter1'
	Begin Object Class=MeshEmitter Name=Rock03Emitter1
		StaticMesh=StaticMesh'MrD_PL_Mesh.FX.Rock03'
		Acceleration=(Z=-975.000000)
		UseCollision=True
		DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
		RespawnDeadParticles=False
		SpinParticles=True
		SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
		StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
		UseSizeScale=True
		UseRegularSizeScale=False
		SizeScale(0)=(RelativeSize=0.200000)
		SizeScale(1)=(RelativeTime=1.000000)
		InitialParticlesPerSecond=300.000000
		AutomaticInitialSpawning=False
		SecondsBeforeInactive=0.000000
		LifetimeRange=(Min=2.500000)
		StartVelocityRange=(X=(Min=-600.000000,Max=600.000000),Y=(Min=-600.000000,Max=600.000000),Z=(Max=600.000000))
	End Object
	Emitters(1)=MeshEmitter'Rock03Emitter1'
	Begin Object Class=SpriteEmitter Name=Smoke5Emitter1
		UseColorScale=True
		ColorScale(0)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255))
		ColorScale(1)=(RelativeTime=0.900000,Color=(B=255,G=255,R=255))
		ColorScale(2)=(RelativeTime=0.300000,Color=(B=255,G=255,R=255))
		MaxParticles=15
		RespawnDeadParticles=False
		StartLocationRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-15.000000,Max=15.000000))
		SpinParticles=True
		SpinsPerSecondRange=(X=(Max=0.100000))
		StartSizeRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Min=500.000000))
		DrawStyle=PTDS_AlphaBlend
		Texture=Texture'nathans.Skins.smoke5'
		TextureUSubdivisions=1
		TextureVSubdivisions=4
		BlendBetweenSubdivisions=True
		LifetimeRange=(Min=0.500000,Max=0.800000)
	End Object
	Emitters(2)=SpriteEmitter'Smoke5Emitter1'
    Begin Object Class=SpriteEmitter Name=Expl1ColorEmitter1
		SecondsBeforeInactive=0.0
        MaxParticles=7
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeTime=0.000000,RelativeSize=0.000000)
        SizeScale(1)=(RelativeTime=0.100000,RelativeSize=0.700000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=170.000000,Max=220.000000))
        InitialParticlesPerSecond=100.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.expl1color'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.00000,Max=2.500000)
        StartVelocityRange=(X=(Min=-600.000000,Max=600.000000),Y=(Min=-600.000000,Max=600.000000),Z=(Min=-200.000000,Max=200.000000))
        VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
    End Object
    Emitters(3)=SpriteEmitter'Expl1ColorEmitter1'
    Begin Object Class=SpriteEmitter Name=DarkChunksEmitter1
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-600.000000)
        MaxParticles=20
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=2.000000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=5.000000,Max=15.000000))
        InitialParticlesPerSecond=300.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.darkchunks'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=1.000000,Max=1.500000)
        StartVelocityRange=(X=(Min=-1200.000000,Max=1200.000000),Y=(Min=-1200.000000,Max=1200.000000),Z=(Max=1000.000000))
    End Object
    Emitters(4)=SpriteEmitter'DarkChunksEmitter1'
    Begin Object Class=SpriteEmitter Name=Pour2Emitter1
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-1.000000)
        UseDirectionAs=PTDU_Up
        UseColorScale=True
        ColorScale(0)=(Color=(B=100,G=120,R=160))
        ColorScale(1)=(RelativeTime=0.200000,Color=(B=100,G=100,R=128))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=100,G=100,R=128))
        FadeOut=True
        MaxParticles=12
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-50.000000,Max=-20.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeTime=0.000000,RelativeSize=0.000000)
        SizeScale(1)=(RelativeTime=0.300000,RelativeSize=0.700000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Max=200.000000),Y=(Min=200.000000,Max=400.000000))
        InitialParticlesPerSecond=3000.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaModulate_MightNotFogCorrectly
        Texture=Texture'nathans.Skins.pour2'
        LifetimeRange=(Min=2.200000,Max=2.700000)
        StartVelocityRange=(X=(Min=-800.000000,Max=800.000000),Y=(Min=-800.000000,Max=800.000000),Z=(Min=440.000000,Max=640.000000))
        VelocityLossRange=(X=(Min=1.500000,Max=1.500000),Y=(Min=1.500000,Max=1.500000),Z=(Min=1.500000,Max=1.500000))
    End Object
    Emitters(5)=SpriteEmitter'Pour2Emitter1'
}