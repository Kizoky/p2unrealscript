class GurgleBlood extends P2Emitter;
/*
    Begin Object Class=SpriteEmitter Name=SpriteEmitter56
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-300.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(G=128,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        FadeOut=True
        MaxParticles=5
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
        SpinParticles=True
		RespawnDeadParticles=false
        SpinsPerSecondRange=(X=(Max=0.500000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=2.000000,Max=8.000000))
        InitialParticlesPerSecond=40.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.bloodchunks1'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=100.000000,Max=110.000000))
        Name="SpriteEmitter56"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter56'
*/

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter16
         UseDirectionAs=PTDU_Up
         CoordinateSystem=PTCS_Relative
         RespawnDeadParticles=False
         SpinsPerSecondRange=(X=(Max=0.100000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=2.000000,Max=6.000000),Y=(Min=10.000000,Max=20.000000))
         InitialParticlesPerSecond=7.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.bloodanim2'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.300000,Max=0.350000)
         StartVelocityRange=(X=(Min=80.000000,Max=120.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         Name="SpriteEmitter16"
     End Object
     Emitters(0)=SpriteEmitter'AWEffects.SpriteEmitter16'
     AutoDestroy=True
     bTrailerSameRotation=True
     Physics=PHYS_Trailer
     Mass=20.000000
}
