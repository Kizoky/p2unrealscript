//=============================================================================
// FireStarterFeeder
//=============================================================================
class FireStarterFeeder extends FireStarterFollow;
// Fire starter specifically for a feeder

var int ArcIndex;
const VEL_MAG = 900;

function Tick(float DeltaTime)
{
	local vector v1;
	local FluidPosFeeder fposf;

	// check to stop the flame if it hasn't been stopped yet
	if(GasSource != None)
	{
		fposf = FluidPosFeeder(GasSource);
		//log("my loc "$Location);
		//log("gas type "$GasSource);
		//log("gas loc "$ff.ArcPos[ff.LastArcIndex]);
		v1 = fposf.ArcPos[fposf.LastArcIndex] - Location;
		Velocity = VEL_MAG*Normal(v1);
		//log("new vel "$Velocity);
		if(VSize(v1) < CollisionRadius)
		{
			//log("killing gassource");
			fposf.Exploding(Location);
			StopStarter(true);
		}
	}
	Super.Tick(DeltaTime);
}

function Destroyed()
{
	TriggerNextPuddle();
	Super.Destroyed();
}

function TriggerNextPuddle()
{
	// STUB OUT  because we don't want it any more (use 'ignore'??)
}

function StopStarter(bool TriggerNext)
{
	if(AutoDestroy == false)
	{
		log("stop starter feeder ");
		LifeSpan = WAIT_TIME;
		Super.StopStarter(TriggerNext);
	}
}
/*
simulated event RenderOverlays( canvas Canvas )
{

	//local vector endline;
	local color tempcolor;

		// show collision radius
		//endline = Location + vect(200, 0, 200);
		tempcolor.G=255;
		Canvas.DrawColor = tempcolor;
		Canvas.Draw3Circle(Location, CollisionRadius*10*FRand(), 0);
		//log("damage dist "$DamageDistMag);
		//Location, endline, 0);
}
*/

defaultproperties
{
     SpawnClass=Class'Fx.FireStreak'
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter3
		SecondsBeforeInactive=0.0
         FadeOutStartTime=1.000000
         FadeOut=True
         MaxParticles=20
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.500000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=20.000000,Max=45.000000))
         ParticlesPerSecond=20.000000
         InitialParticlesPerSecond=20.000000
         AutomaticInitialSpawning=False
		 DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.firegroup3'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=0.800000,Max=1.500000)
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=30.000000,Max=100.000000))
         Name="SuperSpriteEmitter3"
     End Object
     Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter3'
     LifeSpan=2000.000000
     CollisionRadius=30.000000
}
