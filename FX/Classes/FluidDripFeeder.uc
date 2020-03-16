///////////////////////////////////////////////////////////////////////////////
// Feeder to be dripping off of roofs and ledges where a stream led up to.
///////////////////////////////////////////////////////////////////////////////
class FluidDripFeeder extends FluidPosFeeder;

var float DistToGround;
var float DampenEffects;

var Sound SplashingSound;

const SPLASH_VEL_MAG = 150;
const VEL_EXTRA =	60;
const QUANTITY_MOD_BY_Z	=	0.5;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Instigator = None;
	Super.PostBeginPlay();
	Next=FStarter;
}

///////////////////////////////////////////////////////////////////////////////
// Make the emitter shoot out of Velocity
///////////////////////////////////////////////////////////////////////////////
function SetDir(vector newloc, vector dir, optional float velmag, optional bool bInitArc)
{
	local int i;

	// record velocity for collision particles
	CollisionVelocity = velmag*dir;

	// make it wobble a little
	//dir += VaryDir;
	if(Emitters.Length > 0)
	{
		Emitters[0].StartVelocityRange.X.Max = 	velmag*dir.x;
		Emitters[0].StartVelocityRange.X.Min = 	Emitters[0].StartVelocityRange.X.Max;
		Emitters[0].StartVelocityRange.Y.Max = 	velmag*dir.y;
		Emitters[0].StartVelocityRange.Y.Min = 	Emitters[0].StartVelocityRange.Y.Max;
		Emitters[0].StartVelocityRange.Z.Max = 	velmag*dir.z;
		Emitters[0].StartVelocityRange.Z.Min = 	Emitters[0].StartVelocityRange.Z.Max;
	}

	if(Emitters.Length > 1)
	{
		Emitters[1].StartVelocityRange.X.Max = 	SPLASH_VEL_MAG*dir.x;
		Emitters[1].StartVelocityRange.X.Min = 	Emitters[1].StartVelocityRange.X.Max/4;
		Emitters[1].StartVelocityRange.Y.Max = 	SPLASH_VEL_MAG*dir.y;
		Emitters[1].StartVelocityRange.Y.Min = 	Emitters[1].StartVelocityRange.Y.Max/4;
		Emitters[1].StartVelocityRange.Z.Max = 	SPLASH_VEL_MAG*dir.z;
		Emitters[1].StartVelocityRange.Z.Min = 	Emitters[1].StartVelocityRange.Z.Max/4;
		Emitters[1].StartVelocityRange.X.Max += (VEL_EXTRA);
		Emitters[1].StartVelocityRange.X.Min -= (VEL_EXTRA);
		Emitters[1].StartVelocityRange.Y.Max += (VEL_EXTRA);
		Emitters[1].StartVelocityRange.Y.Min -= (VEL_EXTRA);
		Emitters[1].StartVelocityRange.Z.Max += (VEL_EXTRA);
		Emitters[1].StartVelocityRange.Z.Min -= (VEL_EXTRA);
	}
}

///////////////////////////////////////////////////////////////////////////////
// The feeder itself is on fire, so the source if it
// needs to explode and get hurt really badly
///////////////////////////////////////////////////////////////////////////////
function SetAblaze(vector StartPos, bool NewStart)
{
	local vector EndPos;
	local FireStarterFollow fsf;
	local vector v1;
	local bool bGoingToEnd;

	//log("SETABLAZE "$self);
	// Make sure you're not already on fire.
	if(!bOnFire
		&& bCanBeDamaged)
	{
//		log("not already on fire");
		// Find which end is closer to the given position
		if(VSize(StartPos - Location) <=
			VSize(StartPos - NewSpawnPoint))
		{
//			log("go to end true");
			StartPos = Location;
			EndPos = NewSpawnPoint;
			bGoingToEnd=false;
			if(NewStart)
			{
//				log("newstart check for "$Prev);
				if(Prev != None && !Prev.bOnFire)
				{
//					log("start pos2 "$StartPos);
//					log("next  was :"$Prev);
					Prev.SetAblaze(StartPos, false);
				}
			}
		}
		else
		{
//			log("go to end FALSE");
			StartPos = NewSpawnPoint;
			EndPos = Location;
			bGoingToEnd=true;
			if(NewStart)
			{
//				log("newstart check for "$Next);
				if(Next != None && !Next.bOnFire)
				{
//					log("start pos1 "$StartPos);
//					log("prev  was :"$Next);
					Next.SetAblaze(StartPos, false);
				}
			}
		}
		v1 = EndPos - StartPos;
		fsf = spawn(StarterClass,,,StartPos);
		fsf.Instigator = Instigator;
		fsf.Emitters[0].Texture=Texture'nathans.Skins.firegroup3';
		fsf.Velocity = fsf.VelMag*Normal(v1);
//		log("point s "$StartPos);
//		log("point e "$EndPos);
//		log("location "$fsf.Location);
//		log("vel "$fsf.Velocity);
		fsf.SetLifeSpan(VSize(v1)/fsf.VelMag);
		fsf.SpawnClass = None;//Class'FireStreak';
		fsf.GasSource = self;
		fsf.bGoingToEnd = bGoingToEnd;
		MyFire = fsf;
		bOnFire=true;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ToggleFlow(float TimeToStop, bool bIsOn)
{
	Super.ToggleFlow(TimeToStop, bIsOn);

	//log(self$" stopping ");
	if(bStoppedFlow
		&& !IsInState('FinishingUp'))
	{
		//log(self$" stopping really ");
		// Change visuals but still allow to flow
		GotoState('FinishingUp');
	}
		/*
	// Don't stop a drip feeder for a little while longer than normal (too
	// make sure it connects with the ground
	StopFlowTime = DRIP_FEEDER_STOP_FLOW_TIME;
	*/
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function CheckForFluidHit(vector StartLoc, vector EndLoc, 
						  vector HitVel, vector GroundHit, 
						 vector HitNormal, float DeltaTime)
{
	// Make a starter with this feeder, no matter what the 
	// flatness of the ground
	if(HitNormal.z > MIN_Z_NORMAL_FOR_STARTER
		&& HitNormal.z < FLAT_GROUND_Z)
		HandleStarter(GroundHit, HitNormal, HitVel, DeltaTime);
	else
		HandlePuddle(GroundHit, HitNormal, DeltaTime);
}

///////////////////////////////////////////////////////////////////////////////
// Set the quantity based on how far it is to the floor. This drip feeder
// gets it's quantity decremented each tick by QuantityPerHit*DeltaTime.
// Setting this high, ensures it will form a puddle on the ground.
///////////////////////////////////////////////////////////////////////////////
function SetQuantityBasedOnFloor(float ZDist)
{
	Quantity = ZDist;
	//log("DRIP FEEDER dist down "$ZDist);
	Quantity*=QUANTITY_MOD_BY_Z;
	//log("my new quantity "$Quantity);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// starting up
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Starting
{
	function Timer()
	{
		AmbientSound=SplashingSound;

		Super.Timer();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Actually dripping
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Pouring
{
	function Timer()
	{
		if(TryToMake == MAKE_STARTER)
		{
			//log(self$" before make "$FFlowTrail);
			if(TrailStarterClass != None)
			{
				FStarter = spawn(TrailStarterClass, self,,NewSpawnPoint);
				FStarter.SetFluidType(MyType);
				//log(self$" making a FStarter "$FStarter);
				// Start the trail and
				// link this to the feeder
				Next = FStarter.StartFirstTrail(vect(0, 0, 1));
				FFlowTrail = FluidFlowTrail(Next);
				//log(self$" get fflow "$FFlowTrail);
				if(Next != None)
				{
					Next.Prev = self;
				}
				else // was destroyed upon creation, so cleanup
				{
					if(FStarter != None)
					{
						if(!FStarter.bDeleteMe)
						{
							FStarter.ToggleFlow(0, false);
							FStarter.Destroy();
						}
						FStarter = None;
					}
					Next = None;
					FFlowTrail = None;
				}
				//log(self$" my links after next "$Next$" prev "$Prev);
			}
		}
		else if(TryToMake == MAKE_PUDDLE)
		{
			if(PuddleClass != None)
			{
				//log("SPAWN PUDDLE");
				FPuddle = spawn(PuddleClass, self,,NewSpawnPoint);
				FPuddle.SetFluidType(MyType);
				// Link puddle to feeder
				FPuddle.Prev = self;
				Next = FPuddle;
				if(!bAllowPuddleRipples)
					FPuddle.RemoveRipples();
			}
		}
		TryToMake = 0;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FinishingUp
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FinishingUp
{
	function ShrinkSize()
	{
		local int i;

		for(i=0; i<Emitters.Length; i++)
		{
			Emitters[i].StartSizeRange.X.Min*=DampenEffects;
			Emitters[i].StartSizeRange.X.Max*=DampenEffects;
			Emitters[i].StartSizeRange.Y.Min*=DampenEffects;
			Emitters[i].StartSizeRange.Y.Max*=DampenEffects;
			Emitters[i].StartVelocityRange.X.Min*=DampenEffects;
			Emitters[i].StartVelocityRange.X.Max*=DampenEffects;
			Emitters[i].StartVelocityRange.Y.Min*=DampenEffects;
			Emitters[i].StartVelocityRange.Y.Max*=DampenEffects;
			Emitters[i].StartVelocityRange.Z.Min*=DampenEffects;
			Emitters[i].StartVelocityRange.Z.Max*=DampenEffects;
		}
		//log(self$" start size x "$Emitters[0].StartSizeRange.X.Max);
		// check to kill it 
		if(Emitters[0].StartSizeRange.X.Max < 0.1)
		{
			SeverLinks(0, false);
			GotoState('Dying');
		}
	}

	function BeginState()
	{
		QuantityPerHit = 0;
	}

Begin:
	ShrinkSize();

	Sleep(1.0);

	Goto('Begin');
}

defaultproperties
{
	SpawnDripTime=0.4
	QuantityPerHit=40
	DampenEffects=0.7

	bAllowPuddleRipples=false
	SplashingSound = Sound'WeaponSounds.blood_squirt_loop'
 //   SoundVolume=90
}
