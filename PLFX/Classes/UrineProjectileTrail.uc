/**
 * UrineProjectileTrail
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Trail of piss behind the main urine projectile
 *
 * @author Gordon Cheng
 */
class UrineProjectileTrail extends P2Emitter;

const LONG_STREAM_INDEX = 2;
const STREAM_RANGE = 5;

function UpdateLongStream(vector vel) {

    if (Emitters.length > LONG_STREAM_INDEX) {
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
     Begin Object class=SpriteEmitter name=SpriteEmitter0
         UseDirectionAs=PTDU_Up
         UseColorScale=true
         ColorScale(0)=(RelativeTime=0,Color=(R=255,G=255,B=128))
         ColorScale(1)=(RelativeTime=1,Color=(R=255,G=255,B=128))
         FadeOut=true
         CoordinateSystem=PTCS_Relative
         MaxParticles=12
         SpinsPerSecondRange=(X=(Max=0.1))
         UseSizeScale=true
         UseRegularSizeScale=false
         SizeScale(0)=(RelativeSize=0.2)
         SizeScale(1)=(RelativeTime=1,RelativeSize=1)
         StartSizeRange=(X=(Min=5,Max=10),Y=(Min=40,Max=50))
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.waterblobs'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.5,Max=0.6)
         StartVelocityRange=(X=(Min=-70,Max=-80))
         Name="SpriteEmitter0"
     End Object
     Emitters(0)=SpriteEmitter'SpriteEmitter0'

     Begin Object class=SpriteEmitter name=SpriteEmitter1
         UseColorScale=true
         ColorScale(0)=(RelativeTime=0,Color=(R=255,G=255,B=128))
         ColorScale(1)=(RelativeTime=1,Color=(R=255,G=255,B=128))
         FadeOut=true
         CoordinateSystem=PTCS_Relative
         MaxParticles=15
         StartLocationRange=(X=(Min=-2,Max=2),Y=(Min=-2,Max=2),Z=(Min=-2,Max=2))
         UseSizeScale=true
         UseRegularSizeScale=false
         SizeScale(0)=(RelativeSize=1)
         SizeScale(1)=(RelativeTime=1,RelativeSize=0.5)
         StartSizeRange=(X=(Min=4,Max=7))
         Texture=Texture'nathans.Skins.softwhitedot'
         LifetimeRange=(Min=0.4,Max=0.6)
         StartVelocityRange=(X=(Min=-30,Max=-50))
         Name="SpriteEmitter1"
     End Object
     Emitters(1)=SpriteEmitter'SpriteEmitter1'

     Begin Object class=SpriteEmitter name=SpriteEmitter2
         UseDirectionAs=PTDU_Up
         UseColorScale=true
         ColorScale(0)=(RelativeTime=0,Color=(R=255,G=255,B=128))
         ColorScale(1)=(RelativeTime=1,Color=(R=255,G=255,B=128))
         FadeOut=true
         MaxParticles=80
         SpinsPerSecondRange=(X=(Max=0.1))
         UseSizeScale=true
         UseRegularSizeScale=false
         SizeScale(0)=(RelativeSize=0.2)
         SizeScale(1)=(RelativeTime=1,RelativeSize=1)
         StartSizeRange=(X=(Min=5,Max=10),Y=(Min=40,Max=50))
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.waterblobs'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         LifetimeRange=(Min=2.250000,Max=2.250000)
         StartVelocityRange=(X=(Min=-20,Max=-20))
         Name="SpriteEmitter2"
     End Object
     Emitters(2)=SpriteEmitter'SpriteEmitter2'

     AutoDestroy=true
     bTrailerSameRotation=true
     bReplicateMovement=true

     Physics=PHYS_Trailer

     LifeSpan=25
}
