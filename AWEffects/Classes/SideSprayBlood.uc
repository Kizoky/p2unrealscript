///////////////////////////////////////////////////////////////////////////////
// SideSprayBlood
///////////////////////////////////////////////////////////////////////////////
class SideSprayBlood extends P2Emitter;

const SPRAY_SPEED		= 400;
const SPRAY_SPEED_RAND	= 80;
const SPRAY_INDEX		=	0;
const LINE_RANGE		= 50;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetSpray(vector dir)
{
	local vector umin, umax;

	umax = (SPRAY_SPEED + Rand(SPRAY_SPEED_RAND))*dir;
	umin = (SPRAY_SPEED)*dir;

	// Only give a direction to the first group
	Emitters[SPRAY_INDEX].StartVelocityRange.X.Max=umax.x;
	Emitters[SPRAY_INDEX].StartVelocityRange.Y.Max=umax.y;
	Emitters[SPRAY_INDEX].StartVelocityRange.Z.Max+=umax.z;
	Emitters[SPRAY_INDEX].StartVelocityRange.X.Min=umin.x;
	Emitters[SPRAY_INDEX].StartVelocityRange.Y.Min=umin.y;
	Emitters[SPRAY_INDEX].StartVelocityRange.Z.Min+=umin.z;
	// Make the spray happen over a line instead of just a point
	SuperSpriteEmitter(Emitters[SPRAY_INDEX]).LineStart = Location - LINE_RANGE*dir;
	SuperSpriteEmitter(Emitters[SPRAY_INDEX]).LineEnd = Location + LINE_RANGE*dir;
}

defaultproperties
{
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter66
         LocationShapeExtend=PTLSE_Line
         UseDirectionAs=PTDU_Up
         MaxParticles=15
         RespawnDeadParticles=False
         SpinsPerSecondRange=(X=(Max=0.100000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=15.000000),Y=(Min=60.000000,Max=120.000000))
         InitialParticlesPerSecond=70.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.bloodanim2'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.600000,Max=0.900000)
         StartVelocityRange=(Z=(Min=-25.000000,Max=25.000000))
         Name="SuperSpriteEmitter66"
     End Object
     Emitters(0)=SuperSpriteEmitter'AWEffects.SuperSpriteEmitter66'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter17
         FadeOut=True
         MaxParticles=4
         RespawnDeadParticles=False
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.300000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.400000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=11.000000,Max=19.000000))
         InitialParticlesPerSecond=30.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.bloodimpacts'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.400000,Max=0.600000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         Name="SpriteEmitter17"
     End Object
     Emitters(1)=SpriteEmitter'AWEffects.SpriteEmitter17'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter10
         Acceleration=(Z=-300.000000)
         MaxParticles=4
         RespawnDeadParticles=False
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.500000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=4.000000,Max=7.000000))
         InitialParticlesPerSecond=30.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.bloodchunks1'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.600000,Max=0.800000)
         StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=100.000000,Max=500.000000))
         Name="SpriteEmitter10"
     End Object
     Emitters(2)=SpriteEmitter'AWEffects.SpriteEmitter10'
     AutoDestroy=True
     SoundRadius=20.000000
     SoundVolume=80
     SoundPitch=128
}
