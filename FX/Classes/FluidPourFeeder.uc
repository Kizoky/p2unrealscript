///////////////////////////////////////////////////////////////////////////
// Feeder that attaches to other objects to be poured out (like a gas tank)
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
///////////////////////////////////////////////////////////////////////////
class FluidPourFeeder extends FluidPosFeeder;

var float VaryTime;
var vector VaryDirMax;
var vector VaryDirMaxUse;
var vector VaryDir;
var bool VaryUp;

var float InitialPourSpeed;
var float InitialSpeedZPlus;
var float SpeedVariance;
var SteamEmitter MySteam;
var float UpwardsZMin;	// Inside this cone, you're hitting yourself with this liquid

const VEL_Z_DOT_PLUS	= 30;
const VARY_INTERP_TIME	= 0.2;


///////////////////////////////////////////////////////////////////////////
// The feeder itself is on fire, so the source if it
// needs to explode and get hurt really badly
///////////////////////////////////////////////////////////////////////////
function SetAblaze(vector StartPos, bool NewStart)
{
	local vector EndPos;
	local FireStarterFeeder fsf;
	local vector v1;
	local bool bGoingToEnd;
	local int i;

	//log("SETABLAZE for pour hit "$self);
	// Make sure you're not already on fire.
	if(!bOnFire
		&& bCanBeDamaged)
	{
		StartPos = LastHitPos;
		EndPos = Location;

		//log("next "$Next);
		//log("Prev "$Prev);
		if(Next != None && !Next.bOnFire)
		{
//					log("start pos1 "$StartPos);
//					log("prev  was :"$Next);
			Next.SetAblaze(StartPos, false);
		}
		v1 = EndPos - StartPos;
		//log("start pos "$LastHitPos);
		//log("End pos "$Location);
		fsf = spawn(class 'FireStarterFeeder',,,StartPos);
		fsf.Instigator = Instigator;
		fsf.ArcIndex = i;
		fsf.Velocity = fsf.VEL_MAG*Normal(v1);
//		log("point s "$StartPos);
//		log("point e "$EndPos);
//		log("location "$fsf.Location);
		//log("STARTING vel "$fsf.Velocity);
		//fsf.SetLifeSpan(VSize(v1)/fsf.VEL_MAG);
		fsf.SpawnClass = None;//Class'FireStreak';
		fsf.GasSource = self;
		fsf.bGoingToEnd = bGoingToEnd;
		//MyFire = fsf;
		bOnFire=true;
	}
}

///////////////////////////////////////////////////////////////////////////
// Try in interpolate points
///////////////////////////////////////////////////////////////////////////
function EstimateArc()
{
	local int i;
	local float usetime, timesqr;
	local vector useacc, usedir, used;

	// Estimate an arc of movement for the particles
	//log(self$" ---------------init arc at "$CollisionStart$" acc "$Emitters[0].Acceleration$" vel "$CollisionVelocity);
	usetime = SpawnDripTime;
	useacc = Emitters[0].Acceleration;
	used = CollisionVelocity*usetime;
	// Figure out a vague arc for all the points in ArcPos. Move them along as though
	// they'd been moving already and assign velocities also
	for(i=0; i<ArcPos.Length; i++)
	{
		timesqr = usetime*usetime;

		if(i > 0)
			used += (ArcPos[i] - ArcPos[i-1]);
		usedir = Normal(CollisionVelocity)*(CollisionVelocity*CollisionVelocity);
		
		usedir = usedir + useacc*used;
		ArcVel[i] = sqrt(VSize(usedir))*Normal(usedir);

		// x = x0 + v0t + 0.5a*t*t
		ArcPos[i]=CollisionStart + CollisionVelocity*usetime + 0.5*useacc*timesqr;
		usetime +=SpawnDripTime;
		//log(self$" init new pos "$i$" at "$ArcPos[i]$" vel "$ArcVel[i]$" time "$usetime);
	}
	LastArcIndex=0;
}

///////////////////////////////////////////////////////////////////////////
// Make the emitter shoot out of Rotation
///////////////////////////////////////////////////////////////////////////
function SetDir(vector newloc, vector startdir, optional float velmag, optional bool bInitArc)
{
	local int i;
	local vector dir;
	local float addzmag, usevelmag, zcheck;
	local vector ownervel;

	// Save our collision location each time--could be different than our visual location
	CollisionStart = newloc;

	dir = Normal(startdir);

	// find a factor of how inline with velocity motion, this direction is
	usevelmag = VSize(MyOwner.Velocity);
	if(usevelmag > 0)
		addzmag = ((VEL_Z_DOT_PLUS*(MyOwner.Velocity Dot dir))/usevelmag);
	else
		addzmag = 0;
	addzmag += InitialSpeedZPlus;
	ownervel = -0.8*MyOwner.Velocity;//VSize(MyOwner.Velocity)*(vector(StartRotation + rotator(MyOwner.Velocity)));

	// record velocity for collision particles
	CollisionVelocity = InitialPourSpeed*dir - ownervel;
	CollisionVelocity.z+= addzmag;

	// make it wobble a little
	dir += VaryDir;

	for(i=0; i<Emitters.length; i++)
	{
		if(Emitters[i] != None)
		{
			Emitters[i].StartVelocityRange.X.Max = 	InitialPourSpeed*dir.x + -ownervel.x ;
			Emitters[i].StartVelocityRange.X.Min = 	Emitters[i].StartVelocityRange.X.Max;
			Emitters[i].StartVelocityRange.Y.Max = 	InitialPourSpeed*dir.y + -ownervel.y ;
			Emitters[i].StartVelocityRange.Y.Min = 	Emitters[i].StartVelocityRange.Y.Max;
			Emitters[i].StartVelocityRange.Z.Max = 	InitialPourSpeed*dir.z + -ownervel.z + addzmag;
			Emitters[i].StartVelocityRange.Z.Min = 	Emitters[i].StartVelocityRange.Z.Max;
		}
	}
	for(i=1; i<Emitters.length; i++)
	{
		if(Emitters[i] != None)
		{
			Emitters[i].StartVelocityRange.X.Max += (SpeedVariance);
			Emitters[i].StartVelocityRange.X.Min -= (SpeedVariance);
			Emitters[i].StartVelocityRange.Y.Max += (SpeedVariance);
			Emitters[i].StartVelocityRange.Y.Min -= (SpeedVariance);
			Emitters[i].StartVelocityRange.Z.Max += (SpeedVariance);
			Emitters[i].StartVelocityRange.Z.Min -= (SpeedVariance);
		}
	}

	// Check for hitting the owner here, since we have the direction of flow
	dir = Normal(startdir);

	HittingOwner(dir);

	if(bInitArc)
		EstimateArc();
}

///////////////////////////////////////////////////////////////////////////
// Make the emitter shoot out of Rotation
///////////////////////////////////////////////////////////////////////////
function ServerSetDir(vector newloc, vector startdir, optional float velmag, optional bool bInitArc)
{
	local int i;
	local vector dir;
	local float addzmag, usevelmag, zcheck;
	local vector ownervel;

	// Update our position
	SetLocation(newloc);

	// Save our collision location each time--could be different than our visual location
	CollisionStart = newloc;

	dir = Normal(startdir);
	//log(self$" serverdir "$dir);

	// find a factor of how inline with velocity motion, this direction is
	usevelmag = VSize(MyOwner.Velocity);
	if(usevelmag > 0)
		addzmag = ((VEL_Z_DOT_PLUS*(MyOwner.Velocity Dot dir))/usevelmag);
	else
		addzmag = 0;
	addzmag += InitialSpeedZPlus;
	ownervel = -0.8*MyOwner.Velocity;//VSize(MyOwner.Velocity)*(vector(StartRotation + rotator(MyOwner.Velocity)));

	// record velocity for collision particles
	CollisionVelocity = InitialPourSpeed*dir - ownervel;
	CollisionVelocity.z+= addzmag;

	// make it wobble a little
	dir += VaryDir;

	// Check for hitting the owner here, since we have the direction of flow
	dir = Normal(startdir);

	HittingOwner(dir);

	if(bInitArc)
		EstimateArc();
}

///////////////////////////////////////////////////////////////////////////
// Make the emitter shoot out of Rotation
///////////////////////////////////////////////////////////////////////////
simulated function ClientSetDir(vector newpos, vector newloc, vector startdir, optional float velmag)
{
	local int i;
	local vector dir;
	local float addzmag, usevelmag, zcheck;
	local vector ownervel;

	startdir/=VECTOR_RATIO;

	dir = Normal(startdir);

	// Update our position
	SetLocation(newpos);

	// find a factor of how inline with velocity motion, this direction is
	usevelmag = VSize(MyOwner.Velocity);
	if(usevelmag > 0)
		addzmag = ((VEL_Z_DOT_PLUS*(MyOwner.Velocity Dot dir))/usevelmag);
	else
		addzmag = 0;
	addzmag += InitialSpeedZPlus;
	ownervel = -0.8*MyOwner.Velocity;//VSize(MyOwner.Velocity)*(vector(StartRotation + rotator(MyOwner.Velocity)));

	// make it wobble a little
	dir += VaryDir;

	for(i=0; i<Emitters.length; i++)
	{
		if(Emitters[i] != None)
		{
			Emitters[i].StartVelocityRange.X.Max = 	InitialPourSpeed*dir.x + -ownervel.x ;
			Emitters[i].StartVelocityRange.X.Min = 	Emitters[i].StartVelocityRange.X.Max;
			Emitters[i].StartVelocityRange.Y.Max = 	InitialPourSpeed*dir.y + -ownervel.y ;
			Emitters[i].StartVelocityRange.Y.Min = 	Emitters[i].StartVelocityRange.Y.Max;
			Emitters[i].StartVelocityRange.Z.Max = 	InitialPourSpeed*dir.z + -ownervel.z + addzmag;
			Emitters[i].StartVelocityRange.Z.Min = 	Emitters[i].StartVelocityRange.Z.Max;
		}
	}
	for(i=1; i<Emitters.length; i++)
	{
		if(Emitters[i] != None)
		{
			Emitters[i].StartVelocityRange.X.Max += (SpeedVariance);
			Emitters[i].StartVelocityRange.X.Min -= (SpeedVariance);
			Emitters[i].StartVelocityRange.Y.Max += (SpeedVariance);
			Emitters[i].StartVelocityRange.Y.Min -= (SpeedVariance);
			Emitters[i].StartVelocityRange.Z.Max += (SpeedVariance);
			Emitters[i].StartVelocityRange.Z.Min -= (SpeedVariance);
		}
	}
}
/*
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
function CapChildPuddleRadii()
{
	local float FirstRadMax;
	local FluidPuddle gp;
	local Fluid checkfluid;
	local int ct;

//	log("looking forward ");
	// Save the radius of the puddle we're pouring into.
	FirstRadMax = FPuddle.UseColRadius;
	checkfluid = FPuddle.Next;
	// With this pour feeder ending, go to the first puddle (assuming there is one)
	// record it's radius, and then move from it down through any child puddles.
	// For each of those whose radius maxes are larger than the parent's, cap them.
	while(!checkfluid.bDeleteMe
		&& checkfluid != None
		&& ct < 5000)
	{
//		log("checkfluid "$self);
		if(checkfluid.IsA('FluidPuddle'))
		{
//			log("found a puddle");
			if(FluidPuddle(checkfluid).RadMax > FirstRadMax)
			{
//				log("too far over.. capping");
				FluidPuddle(checkfluid).RadMax = FirstRadMax;
			}
		}
		checkfluid = checkfluid.Next;
		ct++;
	}
//	log("end of looking forward");
}
*/
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
function ToggleFlow(float TimeToStop, bool bIsOn)
{
	local int i;

	for(i=0; i<Emitters.length; i++)
	{
		Emitters[i].AutomaticInitialSpawning=false;
		Emitters[i].RespawnDeadParticles=false;
	}
/*
	if(FPuddle != None)
	{
		CapChildPuddleRadii();
	}
*/
	Super.ToggleFlow(TimeToStop, bIsOn);
}

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
function VaryStream(float DeltaTime)
{
	local float vdirsize;

	vdirsize = VSize(VaryDir);

	if(vdirsize > 0.0002)
	{
		VaryTime -= DeltaTime; 
//	log("VarDir "$VaryDir);
		// interpolate
		VaryDir = (VaryTime*(VaryDirMaxUse + VaryDirMaxUse))/VARY_INTERP_TIME;
		if(VaryTime <=0)
		{
			VaryTime=VARY_INTERP_TIME;
			if(VaryUp)
			{
				VaryDirMaxUse = -1.2*VaryDirMaxUse;
				if(vdirsize > 0.01)
				VaryUp=false;
			}
			else
				VaryDirMaxUse = -0.8*VaryDirMaxUse;
		}
	}
	else
	{
		VaryDirMaxUse.x=(0.2*(FRand())-0.1);
		VaryDirMaxUse.y=(0.2*(FRand())-0.1);
		VaryDirMaxUse.z=(0.2*(FRand())-0.1);
		VaryDirMaxUse/=10;
		VaryDir = VaryDirMaxUse;
		VaryUp=true;
	}
}

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
{
	VaryStream(DeltaTime);

	Super.Tick(DeltaTime);
}

defaultproperties
{
	InitialPourSpeed=700
	InitialSpeedZPlus=175
	SpeedVariance=15
	UpwardsZMin=0.988
}
