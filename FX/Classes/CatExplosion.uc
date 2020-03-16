class CatExplosion extends MeatExplosion;


const DIST_FOR_FULL_BLAST	=	150;
const VEL_MAX = 300;


///////////////////////////////////////////////////////////////////////////////
// Based on how close the hurting thing was to the cat that made this explosion
// like a shotgun blast, change the explosiveness of the effect,
// farther away==less explosive
///////////////////////////////////////////////////////////////////////////////
function ReduceMagBasedOnProx(vector FiringLoc, float mag)
{
	local int i;
	local float pct, dist;

	dist = VSize(Location - FiringLoc)/mag;

	if(dist < DIST_FOR_FULL_BLAST)
		pct = 1.0;
	else
		pct = DIST_FOR_FULL_BLAST/dist;

	for(i=0; i<Emitters.Length; i++)
	{
		Emitters[i].StartVelocityRange.X.Max*=pct;
		Emitters[i].StartVelocityRange.X.Min*=pct;
		Emitters[i].StartVelocityRange.Y.Max*=pct;
		Emitters[i].StartVelocityRange.Y.Min*=pct;
		Emitters[i].StartVelocityRange.Z.Max*=pct;
		Emitters[i].StartVelocityRange.Z.Min*=pct;
		Emitters[i].LifetimeRange.Max*=pct;
		Emitters[i].LifetimeRange.Min*=pct;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function FitToNormal(vector HNormal)
{
	local int i;

	// Don't do this to the last one
	for(i=0; i<Emitters.Length-1; i++)
	{
		Emitters[i].StartVelocityRange.X.Max+=HNormal.x*VEL_MAX;
		Emitters[i].StartVelocityRange.Y.Max+=HNormal.y*VEL_MAX;
		Emitters[i].StartVelocityRange.Z.Max+=HNormal.z*VEL_MAX;
		Emitters[i].StartVelocityRange.X.Min-=HNormal.x*VEL_MAX;
		Emitters[i].StartVelocityRange.Y.Min-=HNormal.y*VEL_MAX;
		Emitters[i].StartVelocityRange.Z.Min-=HNormal.z*VEL_MAX;
/*
		Emitters[0].VelocityLossRange.X.Max=abs(HNormal.x*VEL_LOSS);
		Emitters[0].VelocityLossRange.X.Min=Emitters[0].VelocityLossRange.X.Max;
		Emitters[0].VelocityLossRange.Y.Max=abs(HNormal.y*VEL_LOSS);
		Emitters[0].VelocityLossRange.Y.Min=Emitters[0].VelocityLossRange.Y.Max;
		Emitters[0].VelocityLossRange.Z.Max=abs(HNormal.z*VEL_LOSS);
		Emitters[0].VelocityLossRange.Z.Min=Emitters[0].VelocityLossRange.Z.Max;
		*/
	}
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter3
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-600.000000)
        MaxParticles=5
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=2.000000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=5.000000,Max=35.000000))
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.bloodchunks1'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        UseRandomSubdivision=True
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Max=500.000000))
        Name="SpriteEmitter3"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter3'
    Begin Object Class=MeshEmitter Name=MeshEmitter0
		SecondsBeforeInactive=0.0
        StaticMesh=StaticMesh'Timb_mesh.fooo.nasty_deli2_timb'
        Acceleration=(Z=-1000.000000)
        RespawnDeadParticles=False
        UseCollision=True
        DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
        SpinParticles=True
		MaxParticles=5
        SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=0.250000,Max=0.500000),Y=(Min=0.250000,Max=0.500000),Z=(Min=0.500000,Max=1.000000))
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
        LifetimeRange=(Min=2.500000,Max=4.000000)
        StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Max=300.000000))
        Name="MeshEmitter0"
    End Object
    Emitters(1)=MeshEmitter'MeshEmitter0'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter5
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
        MaxParticles=4
        RespawnDeadParticles=False
        StartLocationRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-15.000000,Max=15.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.100000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=60.000000,Max=100.000000))
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=3.000000,Max=3.000000)
        Name="SpriteEmitter5"
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter5'
    AutoDestroy=true
}