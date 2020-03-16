///////////////////////////////////////////////////////////////////////////////
// SizableWoof is a FireWoof. (mushroom cloud of fire that makes the sound 'WOOF')
//
// that can be comfortably sized for different explosions (like for cars and barrels and kactors)
//
///////////////////////////////////////////////////////////////////////////////
class SizeableWoof extends FireWoof;

const PARTICLE_MAX_RATIO = 0.45;
const RADIUS_MAX_RATIO	 = 0.7;

function SetSize(float Radius)
{
	local float newmax;
	local float userad;

	newmax = Radius*PARTICLE_MAX_RATIO;
	userad = Radius*RADIUS_MAX_RATIO;
	// Decrease fire detail 
	newmax = P2GameInfo(Level.Game).ModifyByFireDetail(newmax);
	SuperSpriteEmitter(Emitters[0]).SetMaxParticles(newmax);
	Emitters[0].InitialParticlesPerSecond = 4*Emitters[0].MaxParticles;
	Emitters[0].StartLocationRange.X.Max = userad;
	Emitters[0].StartLocationRange.X.Min = -userad;
	Emitters[0].StartLocationRange.Y.Max = userad;
	Emitters[0].StartLocationRange.Y.Min = -userad;
//	Emitters[0].StartLocationRange.Z.Max += Radius/8;
}

defaultproperties
{
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter16
		SecondsBeforeInactive=0.0
         FadeInEndTime=0.300000
         FadeIn=True
         FadeOutStartTime=2.000000
         FadeOut=True
         MaxParticles=15
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-60.000000,Max=60.000000),Y=(Min=-60.000000,Max=60.000000),Z=(Min=-20.000000,Max=20.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.500000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.400000)
         SizeScale(1)=(RelativeTime=0.100000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=40.000000,Max=100.000000))
         InitialParticlesPerSecond=0.000000
         ParticlesPerSecond=0.000000
         AutomaticInitialSpawning=False
 		 DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.firegroup'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=3.000000)
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=100.000000,Max=200.000000))
         VelocityLossRange=(X=(Min=0.750000,Max=0.750000))
         VelocityLossRange=(Y=(Min=0.750000,Max=0.750000))
         VelocityLossRange=(Z=(Min=0.650000,Max=0.650000))
         Name="SuperSpriteEmitter16"
     End Object
     Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter16'
     bDynamicLight=True
     LifeSpan=14.000000
     AutoDestroy=true
}
