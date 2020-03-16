//=============================================================================
// a trail of urine on a surface
//=============================================================================
class UrineTrail extends FluidTrail;

const LOCATION_RANGE_MAX=   5;

function FitToNormal(vector HNormal)
{
	local int i;

	HNormal.x = 1-abs(HNormal.x);
	HNormal.y = 1-abs(HNormal.y);
	HNormal.z = 1-abs(HNormal.z);

	for(i=0; i<Emitters.Length; i++)
	{
		Emitters[i].StartLocationRange.X.Max=HNormal.x*LOCATION_RANGE_MAX;
		Emitters[i].StartLocationRange.X.Min=-Emitters[i].StartLocationRange.X.Max;
		Emitters[i].StartLocationRange.Y.Max=HNormal.y*LOCATION_RANGE_MAX;
		Emitters[i].StartLocationRange.Y.Min=-Emitters[i].StartLocationRange.Y.Max;
		Emitters[i].StartLocationRange.Z.Max=HNormal.z*LOCATION_RANGE_MAX;
		Emitters[i].StartLocationRange.Z.Min=-Emitters[i].StartLocationRange.Z.Max;
	}
}

defaultproperties
{
   Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter8
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Normal
        UseColorScale=True
        ColorScale(0)=(RelativeTime=0.000000,Color=(A=255,R=255,G=255,B=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(A=255,R=255,G=255,B=255))
        FadeOut=True
        MaxParticles=40
        RespawnDeadParticles=False
        UseSizeScale=True
		UniformSize=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.004000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=9.000000,Max=13.000000))
        ParticlesPerSecond=0.000000
        InitialParticlesPerSecond=0.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.urinesplat'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=15.000000,Max=15.000000)
        Name="SuperSpriteEmitter8"
   End Object
   Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter8'
   DripTrailClass=Class'Fx.UrineDripTrail'
   MyType=FLUID_TYPE_Urine
   CollisionRadius=600.000000
   CollisionHeight=600.000000
   UseColRadius=40
   bCollideActors=true;
   LifeSpan=15.000000
   AutoDestroy=true
}