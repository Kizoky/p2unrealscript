///////////////////////////////////////////////////////////////////////////
// Feeder that attaches to other objects to be poured out (like a gas tank)
///////////////////////////////////////////////////////////////////////////
class UrinePourFeeder extends FluidPourFeeder;

var Actor CurrentSteamAttach;			// The current thing the steam is attached to

const VEL_Z_DOT_PLUS = 20;
const FLIP_TIME = 2;
const VARY_INTERP_TIME=0.2;
const PLAYER_PUT_OUT	=	0.05;
const PAWN_PUT_OUT		=	0.05;

const MIN_USE_RAD						=	10;

simulated function Destroyed()
{
	// Null out owner's fluid spout
	if (P2Pawn(MyOwner) != None)
		P2Pawn(MyOwner).RemoveFluidSpout();

	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////
// The fluid is hitting a pawn.
///////////////////////////////////////////////////////////////////////////
function HittingPawn(FPSPawn fpawn, vector HitLocation)
{
	local LambController lambc;

	// Short-circuit the controller if necessary
	if (ScriptedController(fpawn.Controller) != None)
		ScriptedController(fpawn.Controller).ShortCircuit();

	lambc = LambController(fpawn.Controller);

	// Only happens if guy is still alive
	if(lambc != None)
	{
		// Set me to dripping in pee
		lambc.HitWithFluid(MyType, HitLocation);

		lambc.BodyJuiceSquirtedOnMe(P2Pawn(MyOwner), false);
	}
	// Tell zombies
	else if (P2Pawn(fpawn) != None) {
	    P2Pawn(fpawn).HitWithFluid(MyType, HitLocation);
		P2Pawn(fpawn).AttemptZombieRevival(P2Pawn(MyOwner));
	}


	if(fpawn.MyBodyFire != None)
	{
		MakeSteam();
		MySteam.SetLocation(HitLocation);

		// Put out the fire
		fpawn.MyBodyFire.TakeDamage
		(
			PAWN_PUT_OUT*Quantity,
			Pawn(MyOwner),
			HitLocation,
			vect(0, 0, 0),
			class'ExtinguishDamage'
		);

		// Achievement time!
		if (PlayerController(Pawn(MyOwner).Controller) != None)
		{
			if( Level.NetMode != NM_DedicatedServer ) 	PlayerController(Pawn(MyOwner).Controller).GetEntryLevel().EvaluateAchievement(PlayerController(Pawn(MyOwner).Controller),'FireExtinguisher');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Make steam for peeing out fires
///////////////////////////////////////////////////////////////////////////////
function MakeSteam()
{
	if(MySteam == None
		|| MySteam.GetStateName() == 'FinishingUp')
	{
		MySteam = spawn(class'SteamEmitter',MyOwner);
	}
	else
	{
		MySteam.Refresh();
		MySteam.SetBase(None);
	}
}

///////////////////////////////////////////////////////////////////////////
// Feeder hit an actor other than a puddle
// Check to see if you hit some fire
///////////////////////////////////////////////////////////////////////////
function int FeederHitActor(Actor Other, vector HitLocation, vector HitNormal,
						vector FeederStart, vector FeederEnd, float DeltaTime)
{
	local FireEmitter fem;
	local FireStreak fs;
	local FirePuddle fp;
	local FireTorsoEmitter fte;
	local float userad, useheight;
	local vector diff, useloc;
	local bool bwillsteam;

	fs = FireStreak(Other);

	//log(self$" hit actor "$Other);

	// Check for hits on fire streaks
	if(fs != None)
	{
		// Calc the line segment that is the feeder segment
		// Find an approximate radius and height with this segment.
		// Approximate a center location
		diff = FeederStart - FeederEnd;
		useloc = diff/2 + FeederEnd;
		useheight = abs(diff.z)/2;
		diff.z=0;

		userad = VSize(diff)/2 + MIN_USE_RAD;

		// If it's not already extinguished and if the feeder
		// line hits vaguely around the fire streak, then put it out some
		if(fs.Health > 0
			&& ThickLineCylinderCollide(SuperSpriteEmitter(fs.Emitters[0]).LineStart,
									SuperSpriteEmitter(fs.Emitters[0]).LineEnd,
									fs.DefCollRadius/2,
									fs.DefCollHeight,
									useloc,
									userad,
									useheight))
		{
			// Make some steam come out
			// if there isn't already steam,
			// or if you have steam almost ready to go away and the fire is still raging
			/*
			if(MySteam == None
				|| (MySteam.Emitters[0].MaxParticles - MySteam.Emitters[0].ActiveParticles < MIN_STEAM_PARTICLES_FOR_RESPAWN))
			{
				//log("creating new one! after hitting "$fs);
				// create one
				MySteam = spawn(class'SteamEmitter',,,HitLocation);
				//MySteam.MyParent = self;	// link us
			}
			else	// update location
			*/
			MakeSteam();
			MySteam.SetLocation(HitLocation);

			// Put out the fire
			fs.TakeDamage
			(
				DeltaTime*10*Quantity,
				Pawn(MyOwner),
				HitLocation,
				vect(0, 0, 0),
				class'ExtinguishDamage'
			);
			return 2;
		}
		return 1;
	}
	else // if not a fire streak
	{
		// Check for hits on fire puddles
		fp = FirePuddle(Other);
		if(fp != None)
		{
			//log("hit fire puddle");
			// Get ready to do distance test
			// Since we know the hit pretty much hit on the ground with the puddle
			// eleminate the z component of the test.
			diff = FeederEnd;
			diff.z=0;
			useloc = fp.Location;
			useloc.z=0;
			diff = diff - useloc;
			// Check to see if the end of the feeder is inside the fire
			// puddle's radius if the fire puddle's still alive, if so,
			// then extinguish it
			if(fp.Health > 0
				&& VSize(diff) < fp.Emitters[0].SphereRadiusRange.Max + MIN_USE_RAD)
			{
				// Make some steam come out
				// if there isn't already steam,
				// or if you have steam almost ready to go away and the fire is still raging
				/*
				if(MySteam == None
					|| (MySteam.Emitters[0].MaxParticles - MySteam.Emitters[0].ActiveParticles < MIN_STEAM_PARTICLES_FOR_RESPAWN))
				{
					//log("creating new one! after hitting "$fp);
					// create one
					MySteam = spawn(class'SteamEmitter',,,HitLocation);
					//MySteam.MyParent = self;	// link us
				}
				else	// update location
					MySteam.SetLocation(HitLocation);
				*/
				MakeSteam();
				MySteam.SetLocation(HitLocation);
				// Don't actually hurt a fire puddle--it's probably too
				// hot, so you won't be able to kill one right now, with pee

				return 2;
			}
			return 1;
		}
		else // if not a fire puddle
		{
			// Check for hits on burning people
			fte = FireTorsoEmitter(Other);
			if(fte != None)
			{
				// Get ready to do distance test
				// Since we know the hit pretty much hit on the ground with the puddle
				// eleminate the z component of the test.
				diff = FeederEnd;
				diff.z=0;
				useloc = fte.Location;
				useloc.z=0;
				diff = diff - useloc;
				// Check to see if the end of the feeder is inside the fire
				// puddle's radius if the fire puddle's still alive, if so,
				// then extinguish it
				if(fte.Health > 0
					&& VSize(diff) < fte.Emitters[0].SphereRadiusRange.Max + MIN_USE_RAD)
				{
					// Make some steam come out
					// if there isn't already steam,
					// or if you have steam almost ready to go away and the fire is still raging
					/*
					if(MySteam == None
						|| (MySteam.Emitters[0].MaxParticles - MySteam.Emitters[0].ActiveParticles < MIN_STEAM_PARTICLES_FOR_RESPAWN))
					{
						//log("creating new one! after hitting "$fp);
						// create one
						MySteam = spawn(class'SteamEmitter',,,HitLocation);
						//MySteam.MyParent = self;	// link us
					}
					else	// update location
						MySteam.SetLocation(HitLocation);
					*/
					MakeSteam();
					MySteam.SetLocation(HitLocation);

					// Don't actually hurt a fire torso emitter for the moment.

					return 2;
				}
				return 1;
			}
			else	// just put out all other fires without steam
			{
				if(FireEmitter(Other) != None)
//					|| (PhysicsVolume(Other) != None
//						&& ClassIsChildOf(PhysicsVolume(Other).DamageType, class'BurnedDamage')))
				{
					MakeSteam();
					MySteam.SetLocation(HitLocation);
					// Put out the fire
					Other.TakeDamage
					(
						Quantity,
						Pawn(MyOwner),
						HitLocation,
						vect(0, 0, 0),
						class'ExtinguishDamage'
					);
					return 0;
				}
				else if(PeoplePart(Other) != None
					|| KActorExplodable(Other) != None)
//					|| (PhysicsVolume(Other) != None
//						&& ClassIsChildOf(PhysicsVolume(Other).DamageType, class'BurnedDamage')))
				{
					if(PeoplePart(Other) != None)
						bwillsteam = PeoplePart(Other).WillSteam();
					else if(KActorExplodable(Other) != None)
						bwillsteam = KActorExplodable(Other).WillSteam();

					if(bwillsteam)
					{
						MakeSteam();
						MySteam.SetLocation(HitLocation);
						// Put out the fire
						Other.TakeDamage
						(
							Quantity,
							Pawn(MyOwner),
							HitLocation,
							vect(0, 0, 0),
							class'ExtinguishDamage'
						);
					}
					return 0;
				}
				else if(P2PowerupPickup(Other) != None)		// if it hits a pickup, then taint it
				{
					//log(self$" did hit "$Other);
					P2PowerupPickup(Other).Taint();
				}
			}
		}


	}
	return 0;
}

///////////////////////////////////////////////////////////////////////////
// Manually check if you're hitting you're owner, since Trace won't let you
// and we can do it more cheaply.
// Trace checks to not hit the owner, and besides, we don't need that
// sort of accurate collision for this
// Do this by checking direction of pouring
// This is merely for DETECTION of the collision, not for the splashing and all
///////////////////////////////////////////////////////////////////////////
function HittingOwner(vector Dir)
{
	local LambController lambc;
	local P2Player pplayer;

	local P2Pawn p2p;
	local vector toppos;

	p2p = P2Pawn(Owner);

	if(p2p != None)
	{
		// If it's getting poured/pushed upwards, then it's going to fall back
		// down and hit the owner
		if(Dir.z > UpwardsZMin)
		{
			toppos = p2p.Location;
			toppos.z += p2p.CollisionRadius;

			lambc = LambController(p2p.Controller);
			if(LambController(p2p.Controller) != None)
				HittingPawn(p2p, toppos);
			else
			{
				pplayer = P2Player(p2p.Controller);
				if(pplayer != None)
				{
					// Only let the pee hit him in the face if he's been
					// peeing long enough for a stream to hit him, *or* let
					// it hit him immediately if he's on fire (to put him out quicker)
					if(bFullyActive
						|| p2p.MyBodyFire != None)
						pplayer.PissedOnHimself();

					if(p2p.MyBodyFire != None)
					{
						// Stick the steam on the dude.
						MakeSteam();
						CurrentSteamAttach = p2p;
						MySteam.SetBase(CurrentSteamAttach);

						// Put out the fire
						p2p.MyBodyFire.TakeDamage
						(
							PLAYER_PUT_OUT*Quantity,
							Pawn(MyOwner),
							p2p.Location,
							vect(0, 0, 0),
							class'ExtinguishDamage'
						);
					}
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check for collisions and move particles
///////////////////////////////////////////////////////////////////////////////
function SetStartSpeeds(float SpeedBase, float RealLife, optional vector StartRotationOffset)
{
}

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
function VaryStream(float DeltaTime)
{
	// STUB OUT to not do this anymore for the urine
}

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
function Timer()
{
	// STUB OUT
	//AdjustLighting();
}

defaultproperties
{
    Begin Object Class=StripEmitter Name=StripEmitter0
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-2000.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(B=128,G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=255,R=255))
        FadeInEndTime=0.300000
        FadeIn=True
	    FadeOut=True
        MaxParticles=13
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScaleRepeats=3.000000
        StartSizeRange=(X=(Min=0.500000,Max=2.500000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.pour1'
        LifetimeRange=(Min=0.500000,Max=0.500000)
        StartVelocityRange=(X=(Min=-1000.000000,Max=-1000.000000),Z=(Min=300.000000,Max=300.000000))
		//ZTest=false
		//ZWrite=true
        Name="StripEmitter0"
    End Object
    Emitters(0)=StripEmitter'StripEmitter0'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-1800.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(B=128,G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=255,R=255))
        FadeOutStartTime=1.100000
        FadeOut=True
        MaxParticles=20
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.200000,Max=0.500000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.600000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=0.800000,Max=1.800000),Y=(Min=0.800000,Max=1.800000))
        InitialParticlesPerSecond=0.000000
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.drips1'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=1.300000,Max=1.600000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=150.000000,Max=150.000000),Z=(Min=200.000000,Max=200.000000))
		//ZTest=false
		//ZWrite=true
        Name="SpriteEmitter1"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter1'
    MyType=FLUID_TYPE_Urine
	SplashClass = class'UrineSplashEmitter'
	TrailClass = class'UrineTrail'
	TrailStarterClass = class'UrineTrailStarter'
	PuddleClass = class'UrinePuddle'
	bCollideActors=true
	QuantityPerHit=8
	SpawnDripTime=0.15
	bCanHitActors=true
	MomentumTransfer=1.0
	InitialPourSpeed=600
	InitialSpeedZPlus=500
	SpeedVariance=15
	Quantity=30
	MyDamageType=class'UrineDamage'
    AutoDestroy=true
	ArcMax=8
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	UpwardsZMin=0.9
}
