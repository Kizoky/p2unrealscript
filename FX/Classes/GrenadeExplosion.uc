///////////////////////////////////////////////////////////////////////////////
// GrenadeExplosion
// 
// explosion for a grenade
///////////////////////////////////////////////////////////////////////////////
class GrenadeExplosion extends P2Explosion;

var bool bGroundHit;
const	FIRE_INDEX	=	0;
const	DIRT_INDEX	=	1;
const	DUST_INDEX	=	2;
const	BLOOD_INDEX	=	3;
var Sound  GrenadeExplodeAir;
var Sound  GrenadeExplodeGround;

replication
{
	// server sends this to client if enough bandwidth 
	unreliable if(Role==ROLE_Authority)
		ClientMakeBlood, ClientMakeAir;
}

///////////////////////////////////////////////////////////////////////////////
// Perhaps do something special if you hit a wall
///////////////////////////////////////////////////////////////////////////////
function CheckForHitType(Actor Other)
{
	local vector endpt;

	// Make bloody explosion
	if(Pawn(Other) != None)
	{
		ClientMakeBlood();
	}
	else
	{
		endpt = Location;
		endpt.z -= CollisionRadius;
		if(FastTrace(endpt, Location))
		// We *didn't* hit ground, so turn *off* dirt effects
		{
			ClientMakeAir();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function ClientMakeAir()
{
	Emitters[DIRT_INDEX].Disabled=true;
	Emitters[DUST_INDEX].Disabled=true;
	bGroundHit=false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function ClientMakeBlood()
{
	Emitters[DIRT_INDEX].Disabled=true;
	Emitters[DUST_INDEX].Disabled=true;
	// Only if we allow blood
	if(class'P2Player'.static.BloodMode())
		Emitters[BLOOD_INDEX].Disabled=false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Exploding
{
Begin:
	if(bGroundHit)
 		PlaySound(GrenadeExplodeGround,,1.0,,,,true);
	else
		PlaySound(GrenadeExplodeAir,,1.0,,,,true);
	Sleep(DelayToHurtTime);

	CheckHurtRadius(ExplosionDamage, ExplosionRadius, MyDamageType, ExplosionMag, Location);
	NotifyPawns();
}

defaultproperties
{
	ExplosionMag=60000
	TransientSoundRadius=600
	ExplosionRadius=450
	ExplosionDamage=130

    Begin Object Class=SpriteEmitter Name=SpriteEmitter21
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
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.expl1color'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.00000,Max=2.500000)
        StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=-100.000000,Max=100.000000))
        VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
        Name="SpriteEmitter21"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter21'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter27
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-600.000000)
        MaxParticles=10
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
        InitialParticlesPerSecond=75.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.darkchunks'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=1.000000,Max=1.500000)
        StartVelocityRange=(X=(Min=-600.000000,Max=600.000000),Y=(Min=-600.000000,Max=600.000000),Z=(Max=500.000000))
        Name="SpriteEmitter27"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter27'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter29
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-1.000000)
        UseDirectionAs=PTDU_Up
        UseColorScale=True
        ColorScale(0)=(Color=(B=100,G=120,R=160))
        ColorScale(1)=(RelativeTime=0.200000,Color=(B=100,G=100,R=128))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=100,G=100,R=128))
        FadeOut=True
        MaxParticles=6
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-50.000000,Max=-20.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeTime=0.000000,RelativeSize=0.000000)
        SizeScale(1)=(RelativeTime=0.300000,RelativeSize=0.700000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Max=200.000000),Y=(Min=200.000000,Max=400.000000))
        InitialParticlesPerSecond=900.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaModulate_MightNotFogCorrectly
        Texture=Texture'nathans.Skins.pour2'
        LifetimeRange=(Min=2.200000,Max=2.700000)
        StartVelocityRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Min=220.000000,Max=320.000000))
        VelocityLossRange=(X=(Min=1.500000,Max=1.500000),Y=(Min=1.500000,Max=1.500000),Z=(Min=1.500000,Max=1.500000))
        Name="SpriteEmitter29"
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter29'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter15
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-600.000000)
        MaxParticles=8
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=2.000000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
		Disabled=true
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=5.000000,Max=35.000000))
        InitialParticlesPerSecond=50.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.bloodchunks1'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        UseRandomSubdivision=True
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Max=500.000000))
        Name="SpriteEmitter15"
    End Object
    Emitters(3)=SpriteEmitter'SpriteEmitter15'
	LifeSpan=5.0
	GrenadeExplodeAir=Sound'WeaponSounds.Grenade_ExplodeAir'
	GrenadeExplodeGround=Sound'WeaponSounds.Grenade_ExplodeGround'
	bGroundHit=true
    AutoDestroy=true
	MyDamageType = class'GrenadeDamage'
}