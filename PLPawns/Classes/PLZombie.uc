///////////////////////////////////////////////////////////////////////////////
// PLZombie
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
//
// Base class for all PL zombies. Set some common properties like gang etc.
///////////////////////////////////////////////////////////////////////////////
class PLZombie extends AWZombie
	placeable;
	
///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var(PawnAttributes) float GenDifficultyMod;		// Adds this number to the game's difficulty to make this zombie easier/harder	
var(PawnAttributes) float AttackChanceSmash;	// Chance to attack with a double-hand smash instead of a regular attack. Must have both arms
var(PawnAttributes) bool bVomitLeadsTarget;		// If true, vomit attacks lead the player's velocity for a better hit chance
var(PawnAttributes) float VomitDamage;			// Amount of damage caused by vomit attacks
var(PawnAttributes) float ZWalkPct;				// Percent of maximum speed used when walking
var(PawnAttributes) float SwipeDamage;			// Amount of damage done by the zombie's swipe attack (two hits)
var(PawnAttributes) float SmashDamage;			// Amount of damage done by the zombie's two-hand smash attack (one hit)

const PI_OVER_TWO = 1.5707963267949;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	WalkingPct = ZWalkPct;
}

function PlayAnimSwipeLeft()
{
	//log(Self$" anim swipe left, speed "$GenAnimSpeed);
	PlayAnim(GetAnimSwipeLeft(), GenAnimSpeed * 1.5, 0.2);
}
function PlayAnimSwipeRight()
{
	//log(Self$" anim swipe right, speed "$GenAnimSpeed);
	PlayAnim(GetAnimSwipeRight(), GenAnimSpeed * 1.5, 0.2);
}
function PlayAnimSmash()
{
	//log(Self$" anim smash, speed "$GenAnimSpeed);
	PlayAnim(GetAnimSmash(), GenAnimSpeed, 0.2);
}
function PlayAnimVomitAttack()
{
	//log(Self$" anim vomit attack ");
	PlayAnim(GetAnimVomitAttack(), GenAnimSpeed * 1.5, 0.2);
}

///////////////////////////////////////////////////////////////////////////////
// Notifies
///////////////////////////////////////////////////////////////////////////////
function NotifySwipeLeft()
{
	local vector HitPos, Rot, HitMomentum;

	if(!bDeleteMe
		&& Health > 0)
	{
		// for point around where to hurt things
		HitPos = Location;
		Rot = vector(Rotation);
		Rot.z = 0;
		// move it forwards
		HitPos += 0.8*CollisionRadius*Rot;
		// form momentum
		HitMomentum.x = -Rot.x;
		HitMomentum.y = -Rot.y;
		HitMomentum.z = 0.0;
		HitMomentum*=(SWIPE_IMPULSE);

		ZHurtThings(HitPos, HitMomentum,
					SWIPE_DAMAGE_RADIUS,
					SwipeDamage, MyDamage);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function NotifySwipeRight()
{
	local vector HitPos, Rot, HitMomentum;

	if(!bDeleteMe
		&& Health > 0)
	{
		// for point around where to hurt things
		HitPos = Location;
		Rot = vector(Rotation);
		Rot.z = 0;
		// move it forwards
		HitPos += 0.8*CollisionRadius*Rot;
		// form momentum
		HitMomentum.x = -Rot.x;
		HitMomentum.y = -Rot.y;
		HitMomentum.z = 0.0;
		HitMomentum*=(SWIPE_IMPULSE);

		ZHurtThings(HitPos, HitMomentum,
					SWIPE_DAMAGE_RADIUS,
					SwipeDamage, MyDamage);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function NotifySmash()
{
	local vector HitPos, Rot, HitMomentum;

	if(!bDeleteMe
		&& Health > 0)
	{
		// for point around where to hurt things
		HitPos = Location;
		Rot = vector(Rotation);
		Rot.z = 0;
		// move it forwards
		HitPos += 0.8*CollisionRadius*Rot;
		// form momentum
		HitMomentum.x = -Rot.x;
		HitMomentum.y = -Rot.y;
		HitMomentum.z = 0.0;
		HitMomentum*=(SMASH_IMPULSE);

		ZHurtThings(HitPos, HitMomentum,
					SMASH_DAMAGE_RADIUS,
					SmashDamage, 
					BigSmashDamage, 
					true);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function NotifySpitBall()
{
	local vector loc;
	local coords headloc;
	local PLVomitProjectile vproj;
	local vector usev;
	local float dist, usetime, zvel;
	local Rotator UseRot;
	local Vector TargetPos, TargetVel;
	local FPSPawn Attacker;

	if(!bDeleteMe
		&& Health > 0)
	{
		if(vomitclass != None)
		{
			if(bHasHead)
				headloc = GetBoneCoords(BONE_HEAD);
			else
				headloc = GetBoneCoords(BONE_NECK);

			loc = headloc.Origin;
			loc = BALL_FORWARD*(vector(Rotation)) + loc;
			vproj = PLVomitProjectile(spawn(vomitclass, self, , loc));
			if(vproj != None)
			{
				// Determine velocity of shot
				vproj.Speed = FRand()*(SpitSpeedMax - SpitSpeedMin) + SpitSpeedMin;

				if(LambController(Controller) != None)
					Attacker = LambController(Controller).Attacker;
					
				// Check distance to target
				if(Attacker != None
					&& FastTrace(Location, Attacker.Location)
					&& Controller.CanSee(Attacker))
				{
					TargetPos = Attacker.Location;
					TargetVel = Attacker.Velocity;
					dist = VSize(TargetPos - Location);
					UseRot = GetProjectileTrajectory(Location, TargetPos, vproj.Speed, TargetVel, 0, vproj.Acceleration.z, bVomitLeadsTarget);
					//log(self@"hitting target with"@UseRot);
					usev = vproj.Speed*(vector(UseRot));
				}
				else
				{
					dist = DEFAULT_SPIT_DIST + FRand()*DEFAULT_SPIT_DIST;
					// xy direction is vside*t
					// z direction is vup*t + 0.5at^2
					UseRot = Rotation;
					usetime = dist/vproj.Speed;
					zvel = -0.5*vproj.Acceleration.z*usetime;
					usev = vproj.Speed*(vector(UseRot));
					usev.z += zvel;
				}
				// Put velocity into projectile
				vproj.SetupThrown(usev, VomitDamage);
			}
		}

		// spitting noise
		Say(myDialog.lSpitting,true);
	}
}	

///////////////////////////////////////////////////////////////////////////////
// Returns the trajector a projectile should take in order to hit a target. We
// also include options such as whether or not we should lead our target and
// whether or not to use the higher projectile travel arc
///////////////////////////////////////////////////////////////////////////////
function rotator GetProjectileTrajectory(vector ProjStart, vector ProjEnd,
                                         float ProjSpeed, vector TargetVelocity,
                                         int Spread, float Gravity,
                                         optional bool bLeadTarget,
                                         optional bool bUseHigherArc,
                                         optional bool bUseUpwardArc)
{
    local float dx, dy;
    local float LowerTrajectoryPitch, HigherTrajectoryPitch;
    local vector LatStart, LatEnd;
    local rotator ReturnTrajectory;

    local float LowerLatSpeed, HigherLatSpeed;
    local vector LeadTargetLocation;

    // If we can't hit our target simply fire as far as you can
    if (!CanHitTargetWithProjectile(ProjStart, ProjEnd, ProjSpeed, Gravity)) {

        ReturnTrajectory = rotator(ProjEnd - ProjStart);
        ReturnTrajectory.Pitch = 8192;

        return ReturnTrajectory;
    }

    // First perform calculations for the default position
    LatStart = ProjStart;
    LatStart.Z = 0;

    LatEnd = ProjEnd;
    LatEnd.Z = 0;

    // Calculate the dx and dy first so we can use these default values to
    // do lead time predictions
    dx = VSize(LatEnd - LatStart);
    dy = ProjEnd.Z - ProjStart.Z;

    // Perform lead time prediction with the default values if we choose to
    if (bLeadTarget) {

        LowerLatSpeed = cos(float(GetTrajectoryPitch(dx, dy, ProjSpeed,
            Gravity, true)) / 16384.0) * ProjSpeed;

        HigherLatSpeed = cos(float(GetTrajectoryPitch(dx, dy, ProjSpeed,
            Gravity, false)) / 16384.0) * ProjSpeed;

        if (bUseHigherArc)
            LeadTargetLocation = ProjEnd + TargetVelocity *
                (VSize(ProjEnd - ProjStart) / HigherLatSpeed);
        else
            LeadTargetLocation = ProjEnd + TargetVelocity *
                (VSize(ProjEnd - ProjStart) / LowerLatSpeed);

        // If we can't hit our lead location simply fire straight at the
        // lead target location
        if (!CanHitTargetWithProjectile(ProjStart, LeadTargetLocation, ProjSpeed, Gravity)) {

            ReturnTrajectory = rotator(LeadTargetLocation - ProjStart);
            ReturnTrajectory.Pitch = 8192;

            return ReturnTrajectory;
        }

        LatEnd = LeadTargetLocation;
        LatEnd.Z = 0;

        dx = VSize(LatEnd - LatStart);
        dy = LeadTargetLocation.Z - ProjStart.Z;

        ReturnTrajectory = rotator(LeadTargetLocation - ProjStart);
    }
    else
        ReturnTrajectory = rotator(ProjEnd - ProjStart);

    // Calculate both angles which we can use to hit the target
    LowerTrajectoryPitch = GetTrajectoryPitch(dx, dy, ProjSpeed, Gravity, true);
    HigherTrajectoryPitch = GetTrajectoryPitch(dx, dy, ProjSpeed, Gravity, false);

    if (bUseHigherArc)
        ReturnTrajectory.Pitch = HigherTrajectoryPitch;
    else
        ReturnTrajectory.Pitch = LowerTrajectoryPitch;

    if (bUseUpwardArc && LowerTrajectoryPitch < 0)
        ReturnTrajectory.Pitch = HigherTrajectoryPitch;

    ReturnTrajectory.Pitch += int(FRand() * float(Spread));
    ReturnTrajectory.Pitch -= int(FRand() * float(Spread));

    ReturnTrajectory.Yaw += int(FRand() * float(Spread));
    ReturnTrajectory.Yaw -= int(FRand() * float(Spread));


    return ReturnTrajectory;
}

///////////////////////////////////////////////////////////////////////////////
// Returns whether or not with the given projectile start and desired end
// locations, projectile speed, and gravity or projectile z downward
// acceleration, we can hit the ProjEnd
//
// Basically copied from P2EMath
///////////////////////////////////////////////////////////////////////////////
function bool CanHitTargetWithProjectile(vector ProjStart, vector ProjEnd,
                                         float ProjSpeed, float Gravity)
{
    local float g, dx, dy;
    local vector LatStart, LatEnd;

    LatStart = ProjStart;
    LatStart.Z = 0;

    LatEnd = ProjEnd;
    LatEnd.Z = 0;

    g = Abs(Gravity);
    dx = VSize(LatEnd - LatStart);
    dy = ProjEnd.Z - ProjStart.Z;

    return Square(Square(ProjSpeed)) - g * (g * Square(dx) +
        2 * dy * Square(ProjSpeed)) >= 0;
}

///////////////////////////////////////////////////////////////////////////////
// Returns the pitch component for the projectile trajector
//
// Also copied from P2EMath
///////////////////////////////////////////////////////////////////////////////
function int GetTrajectoryPitch(float dx, float dy, float ProjSpeed,
                                float Gravity, bool bCalcLowerTrajectory)
{
    local float g, radian, ratio;

    g = Abs(Gravity);

    if (bCalcLowerTrajectory)
        radian = Atan((Square(ProjSpeed) - Sqrt(Square(Square(ProjSpeed))
            - g * (g * Square(dx) + 2 * dy * Square(ProjSpeed)))) / (g * dx));
    else
        radian = Atan((Square(ProjSpeed) + Sqrt(Square(Square(ProjSpeed))
            - g * (g * Square(dx) + 2 * dy * Square(ProjSpeed)))) / (g * dx));

    ratio = radian / PI_OVER_TWO;

    return int(ratio * 16384.0);
}

///////////////////////////////////////////////////////////////////////////////
// Returns the height above it's original spawn height which it'll travel
// We use this mainly for checking if a projectile can be thrown up over
// obstacles to hit the target
//
// Also copied from P2EMath
///////////////////////////////////////////////////////////////////////////////
function float GetMaxProjectileHeight(int Pitch, float ProjSpeed, float Gravity)
{
    local float rad, vi, g, t, yf;

    if (Pitch <= 0)
        return 0;

    rad = (float(Pitch) / 16384.0) * PI_OVER_TWO;
    vi = sin(rad) * ProjSpeed;
    g = Abs(Gravity);
    t = vi / g;

    return vi * t + 0.5 * -g * t;
}

///////////////////////////////////////////////////////////////////////////////
// Samples the area around a given TargetLocation that's behind cover and sees
// which location in the world is reachable by the projectile and is closest
// to the target for flushing them out of cover
///////////////////////////////////////////////////////////////////////////////
function vector GetCoverFlushLocation(vector ProjStart, vector TargetLocation,
                                      float ProjSpeed, float Gravity,
									  int GridXSize, int GridYSize,
									  float GridSize,
									  optional bool bUseHigherArc)
{
    local int i, j;
    local float dx, dy, g;
    local vector X, Y, Z;

    local float MaxHeight;
    local float Distance, ShortestDist;

    local vector LatStart, LatEnd;
    local vector TestFlushOffset, TestFlushLocation, HeightTestStart;

    local float TestTrajectoryPitch;

    local vector CoverFlushLoc;

    g = Abs(Gravity);

    ShortestDist = 3.4028e38;

    for (i=0;i<GridXSize;i++)
	{
        for (j=0;j<GridYSize;j++)
		{
            GetAxes(rot(0,0,0), X, Y, Z);

            // First calculate an offset from our player to test for viability
            TestFlushOffset.X = GridSize * i - GridSize * (GridXSize / 2);
            TestFlushOffset.Y = GridSize * j - GridSize * (GridYSize / 2);

            TestFlushLocation = TargetLocation + X * TestFlushOffset.X +
                Y * TestFlushOffset.Y + Z * TestFlushOffset.Z;

			// Calculate the distance from the target
            Distance = VSize(TestFlushLocation - TargetLocation);

            // Prune off locations that are clearly farther than an existing
            // cover flush location solution
            if (Distance >= ShortestDist)
                continue;

            // If the flush location can't be reached by the projectile, continue
            if (!CanHitTargetWithProjectile(ProjStart, TestFlushLocation, ProjSpeed, g))
                 continue;

            // Calculate the Pitch component so we can do a height check
            LatStart = ProjStart;
            LatStart.Z = 0;

            LatEnd = TestFlushLocation;
            LatEnd.Z = 0;

            dx = VSize(LatEnd - LatStart);
            dy = TestFlushLocation.Z - ProjStart.Z;

            // If we can hit it, then can calculate the trajector,
            TestTrajectoryPitch = GetTrajectoryPitch(dx, dy, ProjSpeed, g, bUseHigherArc);

            // Now that we have the throwing trajectory pitch, we can calculate
            // the maximum throwing height. Height is important for seeing
            // if the grenade can possibly hit
            MaxHeight = GetMaxProjectileHeight(TestTrajectoryPitch, ProjSpeed, g);

            HeightTestStart = ProjStart;
            HeightTestStart.Z += MaxHeight;

            if (FastTrace(TargetLocation, TestFlushLocation) &&
                FastTrace(TestFlushLocation, HeightTestStart)) {

                ShortestDist = Distance;
                CoverFlushLoc = TestFlushLocation;
            }
        }
    }

    return CoverFlushLoc;
}

defaultproperties
{
	ActorID="PLZombie"

	ControllerClass=class'PLZombieController'
	Skins(0)=Texture'AW7_EDZombies.Misc.XX__142__Fem_SS_Shorts'
	Gang="ZombieGang"

	GenDifficultyMod=3
	ChargeFreq=0.450000
	VomitFreq=0.500000
	SpitSpeedMin=600.000000
	SpitSpeedMax=1000.000000
	WalkAttackTimeHalf=1.000000
	ChargeAttackTimeHalf=0.500000
	CrawlAttackTimeHalf=1.500000
	PreSledgeChargeFreq=0.700000
	PreSledgeAttackFreq=0.700000
	PreSledgeFleeFreq=0.900000
	AttackChanceSmash=0.5
	bVomitLeadsTarget=true
	VomitClass=class'PLVomitProjectile'
	VomitDamage=50
	ZWalkPct=0.35
	SwipeDamage=20
	SmashDamage=50
	AmbientGlow=30
	bCellUser=false
}
