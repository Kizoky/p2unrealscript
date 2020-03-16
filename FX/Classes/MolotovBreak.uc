///////////////////////////////////////////////////////////////////////////////
// MolotovBreak
// 
// Fire and glass effects for start of molotov breaking
//
///////////////////////////////////////////////////////////////////////////////
class MolotovBreak extends P2Emitter;

const VEL_MAX			=   300;

function FitToNormal(vector HNormal)
{
	Emitters[0].StartVelocityRange.X.Max=(HNormal.x+1)*VEL_MAX;
	Emitters[0].StartVelocityRange.X.Min=(HNormal.x-1)*VEL_MAX;
	Emitters[0].StartVelocityRange.Y.Max=(HNormal.y+1)*VEL_MAX;
	Emitters[0].StartVelocityRange.Y.Min=(HNormal.y-1)*VEL_MAX;
	Emitters[0].StartVelocityRange.Z.Max=(HNormal.z+1)*VEL_MAX;
	Emitters[0].StartVelocityRange.Z.Min=(HNormal.z-1)*VEL_MAX;
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter40
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-800.000000)
        UseCollision=True
        UseMaxCollisions=True
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
        MaxCollisions=(Min=3.000000,Max=3.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(B=38,G=52,R=81))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=38,G=52,R=81))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=3.000000))
        StartSizeRange=(X=(Min=4.000000,Max=10.000000))
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaModulate_MightNotFogCorrectly
        Texture=Texture'nathans.Skins.glassshards'
        TextureUSubdivisions=2
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=10.000000,Max=10.000000)
        StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=200.000000,Max=400.000000))
        Name="SpriteEmitter40"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter40'
    AutoDestroy=true
}
