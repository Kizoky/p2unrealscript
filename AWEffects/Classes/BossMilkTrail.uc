///////////////////////////////////////////////////////////////////////////////
// BossMilkTrail 
// 
// goes with bossmilkprojectile
///////////////////////////////////////////////////////////////////////////////
class BossMilkTrail extends P2Emitter;

const LONG_STREAM_INDEX = 2;
const STREAM_RANGE = 5;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function UpdateLongStream(vector vel)
{
	if(Emitters.Length > LONG_STREAM_INDEX)
	{
		Emitters[LONG_STREAM_INDEX].StartVelocityRange.X.Max=vel.x + STREAM_RANGE;
		Emitters[LONG_STREAM_INDEX].StartVelocityRange.X.Min=vel.x - STREAM_RANGE;
		Emitters[LONG_STREAM_INDEX].StartVelocityRange.Y.Max=vel.y + STREAM_RANGE;
		Emitters[LONG_STREAM_INDEX].StartVelocityRange.Y.Min=vel.y - STREAM_RANGE;
		Emitters[LONG_STREAM_INDEX].StartVelocityRange.Z.Max=vel.z + STREAM_RANGE;
		Emitters[LONG_STREAM_INDEX].StartVelocityRange.Z.Min=vel.z - STREAM_RANGE;
	}
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter33
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=187,G=255,R=187))
         FadeOut=True
         CoordinateSystem=PTCS_Relative
         MaxParticles=6
         SpinsPerSecondRange=(X=(Max=0.100000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=10.000000),Y=(Min=40.000000,Max=50.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.waterblobs'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.600000)
         StartVelocityRange=(X=(Min=-70.000000,Max=-80.000000))
         Name="SpriteEmitter33"
     End Object
     Emitters(0)=SpriteEmitter'AWEffects.SpriteEmitter33'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter100
         UseColorScale=True
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=196,G=255,R=196))
         FadeOut=True
         CoordinateSystem=PTCS_Relative
         MaxParticles=6
         StartLocationRange=(X=(Min=-2.000000,Max=2.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-2.000000,Max=2.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
         StartSizeRange=(X=(Min=4.000000,Max=7.000000))
         Texture=Texture'nathans.Skins.softwhitedot'
         LifetimeRange=(Min=0.400000,Max=0.600000)
         StartVelocityRange=(X=(Min=-30.000000,Max=-50.000000))
         Name="SpriteEmitter100"
     End Object
     Emitters(1)=SpriteEmitter'AWEffects.SpriteEmitter100'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter34
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=187,G=255,R=187))
         FadeOut=True
         MaxParticles=20
         SpinsPerSecondRange=(X=(Max=0.100000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=10.000000),Y=(Min=40.000000,Max=50.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.waterblobs'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         LifetimeRange=(Min=2.250000,Max=2.250000)
         StartVelocityRange=(X=(Min=-20.000000,Max=-20.000000))
         Name="SpriteEmitter34"
     End Object
     Emitters(2)=SpriteEmitter'AWEffects.SpriteEmitter34'
     AutoDestroy=True
     bTrailerSameRotation=True
     bReplicateMovement=True
     Physics=PHYS_Trailer
     LifeSpan=25.000000
}
