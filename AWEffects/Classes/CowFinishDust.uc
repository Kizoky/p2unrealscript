///////////////////////////////////////////////////////////////////////////////
// CowFinishDust
///////////////////////////////////////////////////////////////////////////////
class CowFinishDust extends P2Emitter;

const DUST_RANGE	= 50;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetVel(vector vel)
{
	if(Emitters.Length > 0)
	{
		Emitters[0].StartVelocityRange.X.Min = vel.x - DUST_RANGE;
		Emitters[0].StartVelocityRange.X.Max = vel.x + DUST_RANGE;
		Emitters[0].StartVelocityRange.Y.Min = vel.y - DUST_RANGE;
		Emitters[0].StartVelocityRange.Y.Max = vel.y + DUST_RANGE;
		//Emitters[0].StartVelocityRange.Z.Min = vel.z;
		//Emitters[0].StartVelocityRange.Z.Max = vel.z + DUST_RANGE;
	}
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter97
         UseColorScale=True
         ColorScale(0)=(Color=(B=58,G=84,R=126))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=61,G=100,R=182))
         MaxParticles=15
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-60.000000,Max=60.000000),Y=(Min=-60.000000,Max=60.000000),Z=(Min=-10.000000,Max=10.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=30.000000,Max=65.000000))
         InitialParticlesPerSecond=50.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.smoke5'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Max=5.000000)
         StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Max=25.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=1.500000),Y=(Min=1.000000,Max=1.500000))
         Name="SpriteEmitter97"
     End Object
     Emitters(0)=SpriteEmitter'AWEffects.SpriteEmitter97'
     AutoDestroy=True
}
