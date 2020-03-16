//=============================================================================
// DustHeadShotPuff
//
// Used in the place of blood
//=============================================================================
class SkeletonHeadEffects extends BodyEffects;

function SetRelativeMotion(vector Momentum, vector MakerVelocity)
{
	local int i, end;

	end = Emitters.Length-2;
	// all others move with owner
	for(i=0; i<end; i++)
	{
		Emitters[i].StartVelocityRange.X.Max += MakerVelocity.x;
		//Emitters[i].StartVelocityRange.X.Min = 	0;
		Emitters[i].StartVelocityRange.Y.Max += MakerVelocity.y;
		//Emitters[i].StartVelocityRange.Y.Min = 	0;
		Emitters[i].StartVelocityRange.Z.Max += MakerVelocity.z;
		//Emitters[i].StartVelocityRange.Z.Min = 	0;
	}
	// mist moves with blast
	Momentum*=ImpactRatio;
	//log(self$" momentum "$Momentum);
	Emitters[end].StartVelocityRange.X.Max = 	Momentum.x;
	Emitters[end].StartVelocityRange.X.Min = 	0;
	Emitters[end].StartVelocityRange.Y.Max = 	Momentum.y;
	Emitters[end].StartVelocityRange.Y.Min = 	0;
	Emitters[end].StartVelocityRange.Z.Max = 	Momentum.z;
	Emitters[end].StartVelocityRange.Z.Min = 	0;
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter57
        Acceleration=(Z=-1000.000000)
        UseCollision=True
        DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Max=0.300000))
        UseColorScale=True
        ColorScale(0)=(Color=(B=103,G=123,R=138,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=103,G=123,R=138,A=255))
        MaxParticles=12
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=1.000000))
        DampRotation=True
        RotationDampingFactorRange=(X=(Min=0.100000,Max=0.300000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=4.000000,Max=10.000000))
        InitialParticlesPerSecond=300.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.concrete1'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=5.000000,Max=7.000000)
        StartVelocityRange=(X=(Min=-120.000000,Max=120.000000),Y=(Min=-120.000000,Max=120.000000),Z=(Max=300.000000))
        Name="SpriteEmitter57"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter57'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter58
        UseDirectionAs=PTDU_Forward
        Acceleration=(Z=-1000.000000)
        UseCollision=True
        DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Max=0.300000))
        UseColorScale=True
        ColorScale(0)=(Color=(B=103,G=123,R=138,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=103,G=123,R=138,A=255))
        MaxParticles=6
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=1.500000,Max=2.500000))
        DampRotation=True
        RotationDampingFactorRange=(X=(Min=0.100000,Max=0.300000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=7.000000,Max=12.000000))
        UniformSize=True
        InitialParticlesPerSecond=300.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.concrete1'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Max=5.000000)
        StartVelocityRange=(X=(Min=-120.000000,Max=120.000000),Y=(Min=-120.000000,Max=120.000000),Z=(Max=240.000000))
        Name="SpriteEmitter58"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter58'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter59
        UseColorScale=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        MaxParticles=4
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.100000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=40.000000,Max=90.000000))
        InitialParticlesPerSecond=300.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=2.000000,Max=3.000000)
        Name="SpriteEmitter59"
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter59'
}
