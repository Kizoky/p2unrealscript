//=============================================================================
// Cloud of deadly gas
//=============================================================================
class AnthCloud extends Anth;

var	float RadVel;
var	vector MainAcc;
var	vector Velocity;
var	vector colpt1, colpt2;
var	float CollisionTime;
var vector VelocityMax;

const EXPANDING_TIME = 10;
const VEL_MAG_COL_MULT=5;
const COLLISION_MOVEMENT_FREQ_TIME = 1.0;
const HURTING_TIME = 10;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	RadVel = (CollisionRadius/2 - DamageDistMag)/EXPANDING_TIME;
	VelocityMax = Emitters[0].MaxAbsVelocity;
}

/*
function MoveCenter(float DeltaTime)
{
	local int i;

	Velocity+=MainAcc*DeltaTime;
	CollisionLocation += Velocity*DeltaTime;
	for(i=0; i<Emitters.length; i++)
	{
		Emitters[i].StartLocationOffset = CollisionLocation - Location;
	}
}

*/

function CapVel(out float vx, float vmax)
{
	if(vx > vmax)
		vx = vmax;
	else if(vx < -vmax)
		vx = -vmax;
}

function MoveCenter(float DeltaTime)
{
	Velocity+=MainAcc*DeltaTime;
	SetLocation(Location + Velocity*DeltaTime);
	CollisionLocation = Location;
	// cap velocity
	CapVel(Velocity.x, VelocityMax.x);
	CapVel(Velocity.y, VelocityMax.y);
	CapVel(Velocity.z, VelocityMax.z);
}

auto state Expanding
{
	simulated function Timer()
	{
		GoToState('Hurting');
	}
	
	simulated function Tick(float DeltaTime)
	{
		// increase the radius of the cloud
		DamageDistMag+=RadVel*DeltaTime;
		// increase the area to emit little particles
		Emitters[1].StartLocationRange.X.Max += RadVel*DeltaTime;
		Emitters[1].StartLocationRange.X.Min = -Emitters[1].StartLocationRange.X.Max;
		Emitters[1].StartLocationRange.Y.Max =  Emitters[1].StartLocationRange.X.Max;
		Emitters[1].StartLocationRange.Y.Min =  Emitters[1].StartLocationRange.X.Min;
		Emitters[1].StartLocationRange.Z.Max =  Emitters[1].StartLocationRange.X.Max;
		Emitters[1].StartLocationRange.Z.Min =  Emitters[1].StartLocationRange.X.Min;
		Emitters[2].StartLocationRange = Emitters[1].StartLocationRange;
		Emitters[0].StartLocationRange.X.Max = Emitters[1].StartLocationRange.X.Max/2;
		Emitters[0].StartLocationRange.X.Min = -Emitters[0].StartLocationRange.X.Max;
		Emitters[0].StartLocationRange.Y.Max =  Emitters[0].StartLocationRange.X.Max;
		Emitters[0].StartLocationRange.Y.Min =  Emitters[0].StartLocationRange.X.Min;
		Emitters[0].StartLocationRange.Z.Max =  Emitters[0].StartLocationRange.X.Max;
		Emitters[0].StartLocationRange.Z.Min =  Emitters[0].StartLocationRange.X.Min;

		// perform collisions
		CheckToHitActors(DeltaTime);
		CheckWalls();
		// move center emitter to match particles
		MoveCenter(DeltaTime);
	}

	simulated function BeginState()
	{
		SetTimer(EXPANDING_TIME, false);
	}
}

state Hurting
{
	simulated function Tick(float DeltaTime)
	{
		CheckToHitActors(DeltaTime);
		// move center emitter to match particles
		MoveCenter(DeltaTime);
	}

	simulated function BeginState()
	{
		// set up collision movement timer
		SetTimer(COLLISION_MOVEMENT_FREQ_TIME, true);
	}
}

state WaitAndFade
{
	ignores Timer;

	simulated function Tick(float DeltaTime)
	{
		// don't hurt things here
	}

	// Don't hurt stuff here, in this state
	simulated function BeginState()
	{
		local int i;
		for(i=0; i<Emitters.length; i++)
		{
			AutoDestroy=true;
			Emitters[i].ParticlesPerSecond=0;
			Emitters[i].RespawnDeadParticles=false;
		}
	}
}

function ApplyWindEffects(vector NewAcc, vector OldAcc)
{
	local vector newhit, newnormal;
	local float vdist;

	// Scale accelerations down so we don't get too quickly
	// swept away by wind.
	NewAcc/=32;
	OldAcc/=32;
	// Get moved by the wind (a fractional amount though)
	MainAcc -= OldAcc;
	MainAcc += NewAcc;
	Super.ApplyWindEffects(NewAcc, OldAcc);
}

function CheckWalls()
{
	local vector newhit, newnormal;
	local float vdist, cfull, chalf;
	local vector NewAcc, OldAcc;

	OldAcc=vect(0, 0, 0);
	// do collision based on velocity
	vdist = VSize(Velocity);
	if(vdist > 0)
	{
		// start with cloud center
		colpt1 = CollisionLocation;
		colpt2 = VEL_MAG_COL_MULT*Velocity;
		/*
		cfull = Emitters[0].StartLocationRange.X.Max;
		chalf = chalf/2;
		// for second point, extend out a multiple of the velocity, and add
		// some randomness based on the cloud size
		colpt2.x+=(FRand()*cfull - chalf);
		colpt2.y+=(FRand()*cfull - chalf);
		colpt2.z+=(FRand()*cfull - chalf);
		*/
		colpt2 += CollisionLocation;
		if(Trace(newhit, newnormal, colpt2, colpt1, false) != None)
		{
			//log("mainacc before "$MainAcc);
			//log("wind acc before "$NewAcc);
			//NewAcc += (Velocity - 2 * newnormal * (Velocity Dot newnormal))/4;
			Velocity = (Velocity - 2 * newnormal * (Velocity Dot newnormal));
			//Velocity/=2;
			//log("new acc "$NewAcc);
		}
		MainAcc += NewAcc;
		Super.ApplyWindEffects(NewAcc, OldAcc);
	}
}

// Perform collision operations
simulated function Timer()
{
	CheckWalls();

	// keep approx time of how long you've been doing this
	CollisionTime += COLLISION_MOVEMENT_FREQ_TIME;
	if(CollisionTime > HURTING_TIME)
		GotoState('WaitAndFade');
}

simulated event RenderOverlays( canvas Canvas )
{
/*
	Super.RenderOverlays(Canvas);
	if(SHOW_LINES == 1)
		Canvas.Draw3Line(colpt1, colpt2, 0);
*/
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter12
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(G=100,R=255))
        ColorScale(1)=(RelativeTime=0.800000,Color=(G=16,R=128))
        ColorScale(2)=(RelativeTime=1.000000)
        MaxParticles=10
        StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=100.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.050000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=350.000000,Max=450.000000))
        InitialParticlesPerSecond=6.000000
        ParticlesPerSecond=1.500000
        AutomaticInitialSpawning=False
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.wispsmoke'
        TextureUSubdivisions=2
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=4.000000,Max=5.000000)
        StartVelocityRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000),Z=(Min=-35.000000,Max=35.000000))
		MaxAbsVelocity=(X=50,Y=50,Z=50);
        Name="SpriteEmitter12"
    End Object
    Emitters(0)=SpriteEmitter'Fx.SpriteEmitter12'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter13
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(G=128,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=31,G=58,R=78))
        MaxParticles=6
        StartLocationRange=(X=(Min=-60.000000,Max=60.000000),Y=(Min=-60.000000,Max=60.000000),Z=(Min=-60.000000,Max=60.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.100000,Max=0.200000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000)
        SizeScaleRepeats=3.000000
        StartSizeRange=(X=(Min=3.000000,Max=5.000000))
        InitialParticlesPerSecond=3.000000
        ParticlesPerSecond=1.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.bubbles'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Max=3.000000)
        StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-3.000000,Max=3.000000))
        Name="SpriteEmitter13"
    End Object
    Emitters(1)=SpriteEmitter'Fx.SpriteEmitter13'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter14
		SecondsBeforeInactive=0.0
        UseColorScale=True
        ColorScale(0)=(Color=(G=128,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=38,G=72,R=89))
        MaxParticles=6
        StartLocationRange=(X=(Min=-60.000000,Max=60.000000),Y=(Min=-60.000000,Max=60.000000),Z=(Min=-60.000000,Max=60.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.200000,Max=0.300000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000)
        SizeScaleRepeats=2.000000
        StartSizeRange=(X=(Min=3.000000,Max=5.000000))
        InitialParticlesPerSecond=3.000000
        ParticlesPerSecond=1.000000
        AutomaticInitialSpawning=False
        Texture=Texture'nathans.Skins.bubbles'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Max=3.000000)
        StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-3.000000,Max=3.000000))
        Name="SpriteEmitter14"
    End Object
    Emitters(2)=SpriteEmitter'Fx.SpriteEmitter14'
	LifeSpan=120.000000
	AutoDestroy=true
	CollisionRadius=800
	CollisionHeight=400
	RemoteRole = ROLE_SimulatedProxy
}