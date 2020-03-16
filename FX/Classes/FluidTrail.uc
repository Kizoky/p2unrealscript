///////////////////////////////////////////////////////////////////////////////
// a trail of fluid on a surface
///////////////////////////////////////////////////////////////////////////////
class FluidTrail extends Fluid;

var vector StartLineDirection;
var vector LastEndPoint;
var vector RightVector;
var class<FluidDripTrail> DripTrailClass;
var class<FireStarterFollow> StarterClass;
var FluidDripTrail Dripper;
var FluidFeeder Feeder;

const COL_RAD_INCREASE_FACTOR		= 10;
const LOCATION_RANGE_MAX			= 10;
const PARTICLE_RATIO_MULT			= 0.75;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	if (Feeder != None && !Feeder.bDeleteMe && Feeder.FTrail == Self)
		Feeder.FTrail = None;
		
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	local float OldLife;
	local float ScaleRatio;
	local int i,j;

	Super.PostBeginPlay();

	// Modify lifespan based on gameinfo
	if (FPSGameInfo(Level.Game) != None
		&& LifeSpan != 0)
	{
		OldLife = LifeSpan;
		LifeSpan = FPSGameInfo(Level.Game).ModifyByFluidDetail(LifeSpan);
		//log(self@"modified lifespan via gameinfo old"@OldLife@"new"@LifeSpan,'Debug');
		if (LifeSpan == 0)
			ScaleRatio = 0;
		else
			ScaleRatio = OldLife / LifeSpan;
			
		// Set time/color scales as if they were using the "old" lifespan
		for (i = 0; i < Emitters.Length; i++)
		{
			for (j = 0; j < Emitters[i].SizeScale.Length; j++)
				Emitters[i].SizeScale[j].RelativeTime *= ScaleRatio;
			for (j = 0; j < Emitters[i].ColorScale.Length; j++)
				Emitters[i].ColorScale[j].RelativeTime *= ScaleRatio;
		}
	}

	// Reset the owner, so we don't appear to be part of the dude's, so we won't
	// be affected by 'catnip time'.
	SetOwner(None);

	//StripEmitter(Emitters[0]).LineEnd = Location;
	//StripEmitter(Emitters[0]).ForceInit();
	//Emitters[0].Owner = self;

	for(i=0; i<Emitters.Length; i++)
	{
		//SuperSpriteEmitter(Emitters[i]).LineStart = Location;
		//SuperSpriteEmitter(Emitters[i]).LineEnd = Location;

		// don't set LastEndPoint here, let it be 0,0,0 and be set on the fly
		Emitters[i].Owner = self;
		Emitters[i].LifetimeRange.Max = LifeSpan-1;
		Emitters[i].LifetimeRange.Min = LifeSpan-1;
	    if(LifeSpan > 5)
			Emitters[i].FadeOutStartTime =  LifeSpan-5;
//		log("Emitters[i].LifetimeRange.Max"$Emitters[i].LifetimeRange.Max);
//		log("Emitters[i].FadeOutStartTime"$Emitters[i].FadeOutStartTime);
//		log("Emitters[i].FadeOut"$Emitters[i].FadeOut);
	}

	SuperSpriteEmitter(Emitters[0]).LocationShapeExtend=PTLSE_Line;
	SuperSpriteEmitter(Emitters[0]).LineEnd=Location;
	SuperSpriteEmitter(Emitters[0]).LineStart=Location;

//	TrailRipples = spawn(TrailRippleClass,self,,Location);

	LastEndPoint = Location;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function CalcParticleNeed(float particleratio)
{
	local float multpart, pluspart;
	local int newmax;
	
	// Base particle creation rate on linear speed and 
	multpart = PARTICLE_RATIO_MULT*Emitters[0].InitialParticlesPerSecond;
	pluspart = Emitters[0].InitialParticlesPerSecond - multpart;
	newmax = (multpart)*particleratio + pluspart;
	//Emitters[0].ParticlesPerSecond = newmax;
	Emitters[0].InitialParticlesPerSecond = newmax;
	//log("ParticlesPerSecond "$Emitters[0].InitialParticlesPerSecond);

//	log("calc particle need for "$self);
//	log("new particle max decided "$newmax);
//	log("particle ratio "$particleratio);
//	Emitters[0].ParticlesPerSecond = PARTICLE_EMISSION_RATIO*newmax;
//	log("ParticlesPerSecond "$Emitters[0].ParticlesPerSecond);
//	Emitters[0].InitialParticlesPerSecond = Emitters[0].ParticlesPerSecond;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function EndingFeederConnection()
{
	// Only allow fluid trails to be damaged after they've been disconnected from 
	// the feeder
	SetCanBeDamaged(true);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetProjectionNormal(vector HitNormal)
{
	local int i;

	//StripEmitter(Emitters[0]).SetProjectionNormal(HitNormal);
	for(i=0; i<Emitters.Length; i++)
	{
		SuperSpriteEmitter(Emitters[i]).SetProjectionNormal(HitNormal);
	}

	// Make a dripper if we need to
	// Only if this emitter is stuck to something like a 'ceiling' that is
	// something with a negative Z normal component
	if(HitNormal.z < 0
		&& DripTrailClass != None)
	{
		Dripper = spawn(DripTrailClass,,,Location);
		Dripper.SetFluidType(MyType);
		Dripper.SetProjectionNormal(HitNormal);
		Dripper.SetLine(Location, Location);
	}

//	if(TrailRipples != None)
//		TrailRipples.SetProjectionNormal(HitNormal);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetLineEnd(vector StartPos, vector EndPos)
{
	SuperSpriteEmitter(Emitters[0]).LineStart = StartPos;
	SuperSpriteEmitter(Emitters[0]).LineEnd = EndPos;
	LastEndPoint = EndPos;

	if(Dripper != None)
	{
		if(Dripper.Emitters[0] != None)
			Dripper.SetLine(StartPos, EndPos);
		else
		{
			Dripper.Destroy();
			Dripper = None;
		}
	}

//	if(TrailRipples != None)
//		TrailRipples.Reposition(EndPos);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function UpdateLineEnd(vector Pos)
{
	CheckToSpawnParticles(Pos);

	if(Dripper != None)
	{
		if(Dripper.Emitters[0] != None)
			SuperSpriteEmitter(Dripper.Emitters[0]).LineEnd = Pos;
		else
		{
			Dripper.Destroy();
			Dripper = None;
		}
	}

//	if(TrailRipples != None)
//		TrailRipples.Reposition(Pos);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function CheckToSpawnParticles(vector Pos)
{
	SuperSpriteEmitter(Emitters[0]).SpawnParticleLength(SuperSpriteEmitter(Emitters[0]).LineStart, 
														Pos,
														Emitters[0].StartSizeRange.X.Min);
	LastEndPoint = SuperSpriteEmitter(Emitters[0]).LineEnd;
}
/*
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	EndingFeederConnection();

	if(Next != None)
	{
		Next.ToggleFlow(DEFAULT_STOP_FLOW_TIME, !bStoppedFlow);
	}
}
*/
///////////////////////////////////////////////////////////////////////////////
// stop all together
///////////////////////////////////////////////////////////////////////////////
function ToggleFlow(float TimeToStop, bool bIsOn)
{
	EndingFeederConnection();

	Super.ToggleFlow(TimeToStop, bIsOn);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function int ParticlesInactive()
{
	return(Emitters[0].MaxParticles - Emitters[0].ActiveParticles);
}

///////////////////////////////////////////////////////////////////////////////
// If the fluid that just caught on fire gets to the end and doesn't connect
// it could be because as the fluid was being poured, it was seperated by
// a terrain spike, or a floor lip, or the player turned too quickly, but really
// we'd want the two fluid trails to connect. So in order to a more smooth
// lighting of the gas, when it comes to an end, just have it check all around
// it for a possible better connection.
///////////////////////////////////////////////////////////////////////////////
function FindBestNext(vector StartPos, bool NewStart)
{
	local float closedist, newdist;
	local Fluid Victims, PickFluid;

	//log(self$"			FindBestNext checking around me with "$CollisionRadius);
	closedist = CollisionRadius;
	foreach RadiusActors( class 'Fluid', Victims, CollisionRadius, Location)
	{
		if(Victims != self)
		{
			newdist = VSize(Victims.Location - Location);
			if(newdist < closedist
				&& !Victims.bOnFire)
			{
				PickFluid = Victims;
				closedist = newdist;
			}
		}
	}

	if(PickFluid != None)
	{
		PickFluid.SetAblaze(Location, true);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetAblaze(vector StartPos, bool NewStart)
{
	local vector EndPos;
	local FireStarterFollow fsf;
	local FireStreak fs;
	local vector v1;
	local bool bGoingToEnd;
	local float newdist;

	// Make sure you're not already on fire.
	if(!bOnFire
		&& bCanBeDamaged)
	{
		bOnFire=true;

		//log("SETABLAZE "$self$" start "$StartPos$" lastend "$LastEndPoint$" loc "$Location);
		//log(self$" prev was "$Prev);
		//log(self$" next was "$Next);
		//log("not already on fire"$self);
		// Find which end is closer to the given position
		if(VSize(StartPos - Location) <=
			VSize(StartPos - LastEndPoint))
		//if(GoToEnd) 
		{
			//log("go to end true");
			StartPos = Location;
			EndPos = LastEndPoint;
			bGoingToEnd=true;
			if(NewStart)
			{
				//log("newstart check for "$Next);
				if(Next != None)
				{
					if(!Next.bOnFire)
					{
						//log("start pos2 "$StartPos);
						//log(self$" next  was :"$Next);
						Next.SetAblaze(StartPos, false);
					}
				}
				else
					FindBestNext(StartPos, true);
			}
		}
		else
		{
			//log("go to end FALSE");
			StartPos = LastEndPoint;
			EndPos = Location;
			bGoingToEnd=false;
			if(NewStart)
			{
				//log("newstart check for "$Prev);
				if(Prev != None)
				{
					if(!Prev.bOnFire)
					{
						//log("start pos1 "$StartPos);
						//log(self$" prev  was :"$Prev);
						Prev.SetAblaze(StartPos, false);
					}
				}
				else
					FindBestNext(StartPos, true);
			}
		}
		v1 = EndPos - StartPos;
		newdist = VSize(v1);
		fsf = spawn(StarterClass,,,StartPos);
		fsf.Instigator = Instigator;
		fsf.Velocity = fsf.velmag*Normal(v1);
		//log("FINISHED point s "$Location);
		//log("point e "$SuperSpriteEmitter(Emitters[0]).LineEnd);
		//log("fsf location "$fsf.Location);
		//log("starter vel "$fsf.Velocity$" v1 "$v1$" mag "$fsf.velmag$" new dist "$newdist$" life "$newdist/fsf.velmag);
		fsf.SetLifeSpan(newdist/fsf.velmag);
		fsf.SpawnClass = FireClass;
		fsf.GasSource = self;
		fsf.bGoingToEnd = bGoingToEnd;
		fs = FireStreak(fsf.SpawnStreak());
		fs.FitToNormal(SpriteEmitter(Emitters[0]).ProjectionNormal);
		//fs.FindRightDir(SpriteEmitter(Emitters[0]).ProjectionNormal, Normal(fsf.Velocity));
		fs.CalcStartupNeeds(newdist);
		//log("fire starter life "$fsf.LifeSpan);

		// Tell everyone along the way, we're about to be lit
		if(!bBeingLit)
			MarkBeingLit();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
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

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SlowlyDestroy()
{
	local int i;

	//log(self$" slowly destroying");
	for(i=0; i<Emitters.length; i++)
	{
		SuperSpriteEmitter(Emitters[i]).SetLiveParticleTimes(Emitters[i].FadeOutStartTime);
		Emitters[i].RespawnDeadParticles=False;
	}
	// forces a death very soon (but won't be noticed because it has faded away by this time)
	if(LifeSpan > 5)
		LifeSpan=5;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event RenderOverlays( canvas Canvas )
{
	local color tempcolor;
	local vector usevect, usevect2;

	tempcolor.R=255;
	tempcolor.G=255;
	Canvas.DrawColor = tempcolor;
	Canvas.Draw3DLine(Location, LastEndPoint);

	tempcolor.B=255;
	Canvas.DrawColor = tempcolor;
	usevect = Location;
	usevect.z+=UseColRadius;
	usevect2 = Location;
	usevect2.z-=UseColRadius;
	Canvas.Draw3DLine(usevect, usevect2);
	tempcolor.B=255;
	Canvas.DrawColor = tempcolor;
	usevect = Location;
	usevect.x+=UseColRadius;
	usevect2 = Location;
	usevect2.x-=UseColRadius;
	Canvas.Draw3DLine(usevect, usevect2);
}

defaultproperties
{
    DripTrailClass=class'Fx.FluidDripTrail'
	CollisionRadius=600.000000
	CollisionHeight=600.000000
	UseColRadius=100
	FireClass=class'FireStreak'
	StarterClass=class'FireStarterFollow'
}