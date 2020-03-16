//=============================================================================
// Feeder to be dripping off of roofs and ledges where a stream led up to.
//=============================================================================
class GasDripFeeder extends FluidDripFeeder;

const CHECK_DIST_TO_GROUND = 3000;
const DRIP_SIZE1 = 250;
const DRIP_SIZE2 = 1000;

const QUANTITY_MOD_BY_Z	=	0.7;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function InitFlow()
{
	local vector newhit, newnormal, endpt;

	// Check distance to ground to determine what 
	// effects will accompany this
	endpt=Location;
	endpt.z-=CHECK_DIST_TO_GROUND;
	if(Trace(newhit, newnormal, endpt, Location, false) != None)
	{
		//log("making new FSplash for "$self);
		DistToGround = VSize(newhit-Location);
		if(FSplash != None)
		{
			//log("destroying "$FSplash);
			FSplash.Destroy();
		}
		// based on the size, make certain splashes
		if(DistToGround < DRIP_SIZE1)
		{
			FSplash = spawn(class'GasSplashEmitterSmall',self);
		}
		else if(DistToGround < DRIP_SIZE2)
		{
			FSplash = spawn(class'GasSplashEmitterMed',self);
		}
		else
		{
			FSplash = spawn(class'GasSplashEmitterLarge',self);
		}
		FSplash.EnableSpawnAll(false);

		//log("gas splash made as a "$FSplash);
		//log("dist was "$DistToGround);
	}

	Super.InitFlow();
}

defaultproperties
{
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter5
		SecondsBeforeInactive=0.0
        UseDirectionAs=PTDU_Up
        Acceleration=(Z=-550.000000)
        UseColorScale=True
        ColorScale(0)=(RelativeTime=0.000000,Color=(R=140,G=130,B=130))
        ColorScale(1)=(RelativeTime=0.400000,Color=(R=120,G=120,B=190))
        ColorScaleRepeats=2.000000
        FadeOutStartTime=0.700000
        FadeOut=True
        MaxParticles=20
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeTime=0.000000,RelativeSize=0.500000)
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.300000)
        SizeScaleRepeats=2.000000
        StartSizeRange=(X=(Min=0.900000,Max=1.400000),Y=(Min=25.000000,Max=35.000000))
        InitialParticlesPerSecond=0.000000
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.gaspour1'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=1.800000,Max=2.200000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=150.000000,Max=150.000000),Z=(Min=200.000000,Max=200.000000))
        Name="SuperSpriteEmitter5"
    End Object
    Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter5'
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter6
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-200.000000)
        UseDirectionAs=PTDU_Up
        FadeInEndTime=0.100000
        FadeIn=True
        FadeOutStartTime=0.150000
        FadeOut=True
        MaxParticles=8
        StartLocationRange=(X=(Min=-4.000000,Max=4.000000),Y=(Min=-4.000000,Max=4.000000),Z=(Max=5.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=0.100000,RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.000000)
        StartSizeRange=(X=(Min=8.000000,Max=12.000000),Y=(Min=22.000000,Max=32.000000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.gassplat1'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=0.800000,Max=1.200000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=20.000000,Max=30.000000))
        Name="SuperSpriteEmitter6"
    End Object
    Emitters(1)=SuperSpriteEmitter'Fx.SuperSpriteEmitter6'
    MyType=FLUID_TYPE_Gas
	SpawnDripTime=0.4
	QuantityPerHit=25
	Quantity=400
	SplashClass = Class'GasSplashEmitterMed'
	TrailClass = Class'GasTrail'
	TrailStarterClass = Class'GasTrailStarter'
	PuddleClass = Class'GasPuddle'
    bCanBeDamaged=true
	bCollideActors=true
	AutoDestroy=true
}
