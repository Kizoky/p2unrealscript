//=============================================================================
// SmokeStreak. (line of smoke)
//=============================================================================
class SmokeStreak extends SmokeEmitter;

var	int		OrigLifeSpan;

const DAMAGE_FOR_NON_LINE=200;
const MIN_PARTICLES = 12;
const DIST_TO_PARTICLE_RATIO=4;
const PARTICLE_EMISSION_RATIO=0.025;
const VEL_RATIO = 0.65;
const PLACEMENT_RATIO = 0.35;

function CalcParticleNeed(float newdist)
{
	local int newmax;
	
	newmax = newdist/DIST_TO_PARTICLE_RATIO;
	if(newmax < MIN_PARTICLES)
		newmax = MIN_PARTICLES;
	// Decrease smoke detail 
	newmax = P2GameInfo(Level.Game).ModifyBySmokeDetail(newmax);
	if(newmax > 0)
	{
		Emitters[0].ParticlesPerSecond = PARTICLE_EMISSION_RATIO*newmax;
		if(Emitters[0].ParticlesPerSecond < 0)
			Emitters[0].ParticlesPerSecond=1;
		Emitters[0].InitialParticlesPerSecond = Emitters[0].ParticlesPerSecond;
		SuperSpriteEmitter(Emitters[0]).SetMaxParticles(newmax);
	}
	else
		Emitters[0].Disabled=true;
}

function SetLine(vector lstart, vector lend, rangevector StartVelocity, vector UNormal)
{
	local vector usevel, placement;

	usevel.x = (StartVelocity.X.Max + StartVelocity.X.Min)*VEL_RATIO;
	usevel.y = (StartVelocity.Y.Max + StartVelocity.Y.Min)*VEL_RATIO;
	usevel.z = (StartVelocity.Z.Max + StartVelocity.Z.Min)*VEL_RATIO;
	placement = usevel/6;
	placement += VSize(placement)*UNormal;

	SuperSpriteEmitter(Emitters[0]).LocationShapeExtend=PTLSE_Line;
	SuperSpriteEmitter(Emitters[0]).LineStart = lstart;
	SuperSpriteEmitter(Emitters[0]).LineEnd = lend;

	SuperSpriteEmitter(Emitters[0]).LineStart += placement;
	SuperSpriteEmitter(Emitters[0]).LineEnd += placement;
	SuperSpriteEmitter(Emitters[0]).StartVelocityRange.X.Max = StartVelocity.X.Max*PLACEMENT_RATIO;
	SuperSpriteEmitter(Emitters[0]).StartVelocityRange.X.Min = StartVelocity.X.Min*PLACEMENT_RATIO;
	SuperSpriteEmitter(Emitters[0]).StartVelocityRange.Y.Max = StartVelocity.Y.Max*PLACEMENT_RATIO;
	SuperSpriteEmitter(Emitters[0]).StartVelocityRange.Y.Min = StartVelocity.Y.Min*PLACEMENT_RATIO;
	SuperSpriteEmitter(Emitters[0]).StartVelocityRange.Z.Max = StartVelocity.Z.Max*PLACEMENT_RATIO;
	SuperSpriteEmitter(Emitters[0]).StartVelocityRange.Z.Min = StartVelocity.Z.Min*PLACEMENT_RATIO;
	WindCheckDist=2*VSize(SuperSpriteEmitter(Emitters[0]).LineStart - SuperSpriteEmitter(Emitters[0]).LineEnd);
	if(WindCheckDist < WIND_CHECK_DIST_MIN)
		WindCheckDist = WIND_CHECK_DIST_MIN;
	CheckWallsForWind();
}

simulated event RenderOverlays( canvas Canvas )
{
/*	local color tempcolor;

	if(SHOW_LINES==1)
	{
		tempcolor.R=100;
		Canvas.DrawColor = tempcolor;
		Canvas.Draw3Line(SuperSpriteEmitter(Emitters[0]).LineStart, 
			SuperSpriteEmitter(Emitters[0]).LineEnd, 0);
	}
		*/
}

/*
        UseColorScale=True
        ColorScale(0)=(Color=(B=128,G=128,R=128))
        ColorScale(1)=(RelativeTime=0.800000,Color=(B=128,G=128,R=128))
        ColorScale(2)=(RelativeTime=1.000000)
        MaxParticles=40
        StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-60.000000,Max=60.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.250000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=200.000000,Max=300.000000))
        ParticlesPerSecond=35.000000
        InitialParticlesPerSecond=25.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_Darken
        Texture=Texture'nathans.Skins.wispsmoke'
        TextureUSubdivisions=2
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=1.500000,Max=2.500000)
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=50.000000,Max=100.000000))
*/

defaultproperties
{
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter13
		SecondsBeforeInactive=0.0
        MaxParticles=30
        StartLocationRange=(Z=(Min=-60.000000,Max=60.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.300000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=80.000000,Max=150.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=70.000000,Max=120.000000))
        Name="SuperSpriteEmitter13"
     End Object
     Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter13'
     LifeSpan=20.000000
     AutoDestroy=true
}
