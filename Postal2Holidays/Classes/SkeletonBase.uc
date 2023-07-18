///////////////////////////////////////////////////////////////////////////////
// SkeletonBase
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Base class for skeletons
///////////////////////////////////////////////////////////////////////////////
class SkeletonBase extends AWZombie
	abstract;

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

var(Character) MeshAnimation BaseMeshAnim; // more single player anims for AW characters

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	WalkingPct = ZWalkPct;
}

///////////////////////////////////////////////////////////////////////////////
// This is the part where I, as a crappy programmer, completely rip apart the
// existing animation stuff and replace it with my own
///////////////////////////////////////////////////////////////////////////////
simulated function name GetAnimStand();
simulated event ChangeAnimation();
simulated function SetAnimWalking();
simulated event PlayFalling();
simulated event PlayJump();
simulated function PlayLanded(float ImpactVel);

simulated function SetupAnims()
{
	LinkAnims();
}

simulated function LinkAnims()
{
    LinkSkelAnim(CoreMeshAnim);
	// xPatch: T-Pose Fix
	LinkSkelAnim(BaseMeshAnim);
}

function SetupHead()
{
    super.SetupHead();
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

// Skeletons can't catch on fire
function SetOnFire(FPSPawn Doer, optional bool bIsNapalm);

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
	local SkeletonProjectileZombie vproj;
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
			vproj = SkeletonProjectileZombie(spawn(vomitclass, self, , loc));
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

///////////////////////////////////////////////////////////////////////////////
// Make heads explode easier without actually killing the body
// Also allow heads to be shoveled off, unlike AWZombie.
///////////////////////////////////////////////////////////////////////////////
function bool HandleSpecialShots(int Damage, vector HitLocation, vector Momentum, out class<DamageType> ThisDamage,
							vector XYdir, Pawn InstigatedBy, out int returndamage, out byte HeadShot)
{
	local float PercentUpBody, ZDist, DistToMe;

	// Only let the player get special head shots
	// Projectile weapons
	if(FPSPawn(InstigatedBy).bPlayer)
	{
		if(Health > 0)
		{
			if(ThisDamage == class'ShotgunDamage'
				|| ThisDamage == class'RifleDamage')
			{
				// For if no damage is done
				if(TakesShotgunHeadShot == 0.0
					|| TakesRifleHeadShot == 0.0)
				{
					// Make a ricochet sound and puff out some smoke and sparks
					SparkHit(HitLocation, Momentum, 1);//Rand(2));
					DustHit(HitLocation, Momentum);
					returndamage = 0;
					return true;
				}

				PercentUpBody = (hitlocation.z - Location.z)/CollisionHeight;
				//log("dist to head for explode try "$VSize(XYDir));
				//log("percent up body "$PercentUpBody);
				// Check to see if we're in fake head shot range
				if(PercentUpBody > HEAD_RATIO_OF_FULL_HEIGHT)
				{
					DistToMe = VSize(XYdir);
					
					if(DistToMe < DISTANCE_TO_EXPLODE_HEAD
						&& ThisDamage == class'ShotgunDamage')
					// Is close enough with a shotgun to explode the head
					{
						// Check a little more accurately, if you actually hit the head or not
						if(CheckHeadForHit(HitLocation, ZDist))
						{
							// We've hit the head, now blow their head up
							if(bHeadCanComeOff)
							{
								if(class'P2Player'.static.BloodMode())
								{
									ExplodeHead(HitLocation, Momentum);
								}
							}
							HeadShot = 1;
							return true;
						}
						// Over the head but not hitting the head means this guy won't take damage
						// If we had hit the head, the above would have returned already
						if(ZDist > 0)
							return false;
					}
					else if(ThisDamage == class'RifleDamage')
					// Sniper rifle rounds knock their heads off--they blow them up when the head
					// is decapitated.
					{
						HandleSever(instigatedBy, momentum, ThisDamage, HEAD_INDEX, Damage, hitlocation);
						HeadShot = 1;
						return true;
					}
				}
				// continue on, if this didn't take
			}
		}
	}

	// Melee
	if(ClassIsChildOf(ThisDamage, class'BludgeonDamage'))
	{
		if(CheckHeadForHit(HitLocation, ZDist, true))
		{
			// shovel's knock heads off
			if(ThisDamage == class'ShovelDamage')
			{
				// Decide randomly to knock the head off. If you're closer to
				// death, then be more likely to make the head pop off
				// Let the player take off heads, and let NPCs take off each
				// others heads
				if(bHeadCanComeOff
					&& class'P2Player'.static.BloodMode())
				{
					// We've hit the head, now pop off the head
					PopOffHead(HitLocation, Momentum);
					HeadShot = 1;
					PlaySound(ShovelCleaveHead,,,,,GetRandPitch());
				}
				else // Otherwise, they just get hit in the head, hard
					PlaySound(ShovelHitHead,,,,,GetRandPitch());
			}
			return true;
		}
		else // if it was a bludgeon attack, but didn't hit the
			// face, then don't draw blood
		{
			if(ThisDamage == class'ShovelDamage')
			{
				PlaySound(ShovelHitBody,,,,,GetRandPitch());
			}
			else if(ThisDamage == class'KickingDamage')
			{
				PlaySound(FootKickBody,,,,,GetRandPitch());
			}
			// Cutting attacks always draw blood, but if not, at this point
			// we only want a dust hit, so change the damage type.
			if(!ClassIsChildOf(ThisDamage, class'CuttingDamage'))
			{
				if (ThisDamage == class'CuttingDamageShovel'
					|| ThisDamage == class'ShovelDamage')
					ThisDamage = class'BodyDamageShovel';
				else
				{
					//log(ThisDamage@"converted to Body Damage");
					ThisDamage = class'BodyDamage';
				}
			}
		}
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Don't do zombie-style invincibility. These guys take regular damage
// like any other pawn
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local bool bUseSuper;
	local int actualDamage, StartDamage;
	local Controller Killer;
	local byte StateChange;	
	
	// Don't care about the head. It can die independently of the body
	if (DamageType == class'HeadKillDamage')
		return;
	
	// Don't take damage from our fellow zombies
	if (AWZombie(instigatedBy) != none)
	    return;

	//debuglog(self@"take damage of"@DamageType);

	/*
	// If we're using the no-dismemberment or no-blood mode,
	// convert dismembering damage types to non-dismembering ones.
	if (!P2GameInfo(Level.Game).bEnableDismemberment
		|| !class'P2Player'.Static.BloodMode())
	{	
		if (DamageType == class'SuperShotgunBodyDamage')
			DamageType = class'ShotgunDamage';
		else if (ClassIsChildOf(DamageType, class'MacheteDamage')
			|| ClassIsChildOf(DamageType, class'ScytheDamage'))
			ConvertToCuttingDamage(DamageType);
	}
	*/
	
	//log(self$" take damage "$damagetype$" takes "$TakesZombieSmashDamage);
	// If we don't have a controller then we're either the player in a movie, or
	// we're an NPC starting out in a pain volume--either way, we don't
	// want to take damage in this state, without a controller.
	// For the player, this gives him god mode, while a movie is playing.
	if(Controller == None)
		return;

	StartDamage = Damage;
	DamageInstigator = instigatedBy;

	// Reduce damage as necessary
	if(ClassIsChildOf(damageType, class'MacheteDamage'))
		Damage = TakesMacheteDamage*Damage;
	else if(ClassIsChildOf(damageType, class'SledgeDamage'))
		Damage = TakesSledgeDamage*Damage;
	else if(ClassIsChildOf(damageType, class'SwipeSmashDamage'))
		Damage = TakesZombieSmashDamage*Damage;
	else if(ClassIsChildOf(damageType, class'ScytheDamage'))
		Damage = TakesScytheDamage*Damage;
	// Cat handles this
	//else if(ClassIsChildOf(damageType, class'DervishDamage'))
	//	Damage = TakesDervishDamage*Damage;

	if(// Can't cut off player limbs
		P2Player(Controller) == None)
	{
		// If it's a damage type and hasn't been lowered, allow limb severance
		// but if TakesMacheteDamage (for instance) is less than 1.0, then don't let limbs be cut
		if(ClassIsChildOf(damageType, class'MacheteDamage'))
		{
			if(Damage >= StartDamage)
				bUseSuper = !(HandleSever(InstigatedBy, momentum, damagetype, INVALID_LIMB, Damage, HitLocation));
			else // convert to lower damage type
				ConvertToCuttingDamage(DamageType);
		}
		else if(ClassIsChildOf(damageType, class'SledgeDamage')
				|| ClassIsChildOf(damageType, class'SwipeSmashDamage'))
		{
			if(Damage >= StartDamage)
				bUseSuper = !(HandleSledge(InstigatedBy, momentum, damagetype, Damage, HitLocation));
			else if(TakesSledgeDamage > 0) // convert to lower damage type unless it was blocked completely
				damageType = class'BludgeonDamage';
		}
		else if(ClassIsChildOf(damageType, class'ScytheDamage'))
		{
			if(Damage >= StartDamage)
				bUseSuper = !(HandleScythe(InstigatedBy, momentum, damagetype, Damage, HitLocation));
			else // convert to lower damage type
				ConvertToCuttingDamage(DamageType);
		}
		else if(ClassIsChildOf(damageType, class'BaliDamage'))
		{
			ConvertToCuttingDamage(DamageType);
		}
		else
			bUseSuper=true;

	}
	else // Make sure the player picks the super take damage
		bUseSuper=true;

	if(!bUseSuper)
	{
		// Multiply damage as necessary per pawn
		//Damage = FPSPawn(InstigatedBy).DamageMult*Damage;

		// Modify as necessary per game
		actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);

		// Save the type that just hurt us
		LastDamageType = class<P2Damage>(DamageType);

		// Armor check.
		// Intercept damage, and if you have armor on, and it's a certain type of damage, 
		// modify the damage amount, based on the what hurt you.
		// Armor doesn't do anything for head shots
		if(Armor > 0
			&& bHasHead
			&& (Controller == None
				|| !Controller.bGodMode))
			ArmorAbsorbDamage(instigatedby, actualDamage, DamageType, HitLocation);

		// Don't call at all if you didn't get hurt
		// The above function does a better check on the head, so you may have shot too high or
		// something, at which point, it'll set the damage to 0, causing this to exit early
		if(Damage <= 0)
		{
			// Tell the character about the non-damage. Most of them will ignore this damage
			// but some people (like Krotchy) will use this to do things
			// Report the original damage asked to be delivered as a negative, so it's not
			// used as actual damage, but it's used to know how bad the damage would have been.
			if ( Controller != None )
				Controller.NotifyTakeHit(instigatedBy, HitLocation, -StartDamage, DamageType, Momentum);
			return;
		}

		// Send the real momentum to this function, please
		PlayHit(actualDamage, hitLocation, damageType, Momentum);

		// Take off health from damage
		Health = Health - actualDamage;

		// Check if he's dead
		if ( Health <= 0 )
		{
			// pawn died
			if ( instigatedBy != None )
				Killer = InstigatedBy.GetKillerController();
			if ( bPhysicsAnimUpdate )
				TearOffMomentum = Momentum / Mass;
			Died(Killer, damageType, HitLocation);
		}
		else
		{
			// Don't make things shoot you up into the air unless it's specific damage types
			if(class<P2Damage>(damageType) == None
				|| !class<P2Damage>(damageType).default.bAllowZThrow)
			{
				if(Physics == PHYS_Walking)
					momentum.z=0;
			}
			AddVelocity( momentum ); 

			// Tell the character about the damage
			if ( Controller != None )
				Controller.NotifyTakeHit(instigatedBy, HitLocation, Damage, DamageType, Momentum);
		}
	}
	else
	{
		//debuglog("going to super.");
		Super(PersonPawn).TakeDamage(Damage, InstigatedBy, HitLocation, momentum, damageType);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Handle chopping off limbs and heads
// Skeleton limbs can't come off, mainly because we won't have time to do
// proper skeleton limbs. But we do want their heads to come off, so we can't
// just use bNoDismemberment
///////////////////////////////////////////////////////////////////////////////
function bool HandleSever(Pawn instigatedBy, vector momentum, out class<DamageType> damageType,
						  int cutindex, out int Damage, out vector hitlocation)
{
	// Don't allow in non-dismemberment mode
	if (!P2GameInfo(Level.Game).bEnableDismemberment
		|| bNoDismemberment
		// Or in pussy non-blood mode
		|| !class'P2Player'.Static.BloodMode())
	{
		// Convert into normal cutting damage and run super instead
		ConvertToCuttingDamage(DamageType);		
		return false;
	}

	// Check where the hit was, if we weren't already passed one
	if(cutindex == INVALID_LIMB)
		cutindex = DecideSeverBone(HitLocation, damageType);
	// Make sure DecideSeverBone got a good limb
	if(cutindex != HEAD_INDEX)
	{
		// it's not there, so turn the damage into normal cutting damage
		ConvertToCuttingDamage(DamageType);
		return false;
	}
	else // cut off head
	{
		if(bHeadCanComeOff
			&& MyHead != None)
		{
			// momentum for head is different
			Momentum = HeadMomMag*(vect(0,0,1.0) + 0.05*VRand());
			PopOffHead(HitLocation, Momentum);
			PlaySound(BladeCleaveNeckSound,,,,,GetRandPitch());
			//Damage = Health;
			// Tell the dude if he did it
			if(AWDude(InstigatedBy) != None)
				AWDude(InstigatedBy).CutOffHead(self);

			return true;
		}
		else // it's not there, so turn the damage into normal cutting damage
		{
			ConvertToCuttingDamage(DamageType);
			return true;
		}
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Check to take off the head, cut in half, or cut off both legs, or nothing (return false)
// As above, we only want the head to be able to come off, but not the limbs
// or torso or etc.
///////////////////////////////////////////////////////////////////////////////
function bool DecideScytheChop(Pawn instigatedBy, out vector momentum, out class<DamageType> damageType,
						  out int Damage, out vector hitlocation)
{
	local int cutindex;
	local bool breturn1, breturn2;
	local coords usecoords;
	local float checkdist;
	
	// Don't bother in non-dismemberment or non-blood mode
	if (!P2GameInfo(Level.Game).bEnableDismemberment
		|| bNoDismemberment
		|| !class'P2Player'.Static.BloodMode())
		return false;

	cutindex = INVALID_LIMB;
	// If the person is alive and standing up
	if(Health > 0
		&& !bIsDeathCrawling
		&& !bIsCrouched)
	{
		// Check to cut off the head first
		usecoords = GetBoneCoords(BONE_NECK);
		if(HitLocation.z > (usecoords.origin.z - HEAD_OFFSET_SCYTHE))
		{
			if(!bMissingTopHalf
				&& MyHead != None)
				cutindex = HEAD_INDEX;
		}
		// check to cut off both legs
		else if(HitLocation.z < Location.z - LEG_OFFSET_SCYTHE)
		{
			if(!bMissingBottomHalf)
				cutindex = LEFT_LEG;
		}
		// chop them in half
		else if(!bMissingTopHalf
			&& !bMissingBottomHalf)
		{
			cutindex = TORSO_INDEX;
		}
	}
	else // Dead or crouching--either way it's much harder to gauge their parts
	{
		// Check first to cut in half
		usecoords = GetBoneCoords(TOP_TORSO);
		checkdist = VSize(usecoords.origin - hitlocation);
		if(checkdist < CHOP_MIN
			&& !bMissingTopHalf
			&& !bMissingBottomHalf)
			cutindex = TORSO_INDEX;
		else
		{
			usecoords = GetBoneCoords(BONE_NECK);
			checkdist = VSize(usecoords.origin - hitlocation);
			if(!bMissingTopHalf
				&& MyHead != None)
			{
				// If they crawling, still alive, and it's a flying
				// scythe, then bias to most likley hit the head
				if(bMissingLegParts
					&& Health > 0
					&& damageType == class'FlyingScytheDamage')
					checkdist*=CRAWLING_BIAS;

				if(checkdist < CHOP_MIN)
					cutindex = HEAD_INDEX;
			}

			if(cutindex == INVALID_LIMB)
			{
				usecoords = GetBoneCoords(SeverBone[LEFT_LEG]);
				checkdist = VSize(usecoords.origin - hitlocation);
				if(checkdist < CHOP_MIN
					&& !bMissingBottomHalf)
					cutindex = LEFT_LEG;
			}
		}
	}

	if(cutindex == TORSO_INDEX)
		return false;
	else if(cutindex != INVALID_LIMB)
	{
		breturn1 = HandleSever(instigatedBy, momentum, damageType, cutindex, Damage, hitlocation);
		// With the scythe, if your cutting off the left, also try to cut off the right leg
		if(cutindex == LEFT_LEG)
			breturn2 = HandleSever(instigatedBy, momentum, damageType, RIGHT_LEG, Damage, hitlocation);
		return (breturn1 || breturn2);
	}
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Stub out various functions relating to blood (skeletons don't have it!)
///////////////////////////////////////////////////////////////////////////////
simulated function SwapToBurnVictim();
function AttachBloodEffectsWhenDead();
function PunctureHead(vector HitLocation, vector Momentum);
function DripBloodOnGround(vector Momentum);
function DoNeckGurgle();
function BloodHit(vector BloodHitLocation, vector Momentum)
{
	DustHit(BloodHitLocation, Momentum);
}

///////////////////////////////////////////////////////////////////////////////
// When you hit something
///////////////////////////////////////////////////////////////////////////////
event KImpact(actor other, vector pos, vector impactVel, vector impactNorm)
{
	local Actor HitActor;
	local vector checkpoint, HitLocation, HitNormal;

	//log(self$" hit this hard "$impactVel$" mag "$VSize(impactVel));
	// Make hit noises
	if(Level.TimeSeconds > (LastBodyHitTime + TimeBetweenPainSounds))
	{
		PlaySound(BodyHitSounds[Rand(BodyHitSounds.Length)], SLOT_Pain, 1.0, , 100, GetRandPitch());
		LastBodyHitTime = Level.TimeSeconds;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Detonate head
///////////////////////////////////////////////////////////////////////////////
function ExplodeHead(vector HitLocation, vector Momentum)
{
	local int i, BloodDrips;
	
	if (HitLocation == vect(0,0,0))
		HitLocation = MyHead.Location;

	Super(MpPawn).ExplodeHead(HitLocation, Momentum);

	Head(MyHead).PinataStyleExplodeEffects(HitLocation, Momentum);
}

///////////////////////////////////////////////////////////////////////////////
//	Decapitate the head and send it flying.
///////////////////////////////////////////////////////////////////////////////
function PopOffHead(vector HitLocation, vector Momentum)
{
	local PoppedHeadEffects headeffects;
	local P2Emitter HeadBloodTrail;			// Blood trail I drip if I'm detached.

	Super(MpPawn).PopOffHead(HitLocation, Momentum);

	// Pop off the head
	DetachFromBone(MyHead);

	// Get it ready to fly
	Head(MyHead).StopPuking();
	Head(MyHead).StopDripping();
	MyHead.SetupAfterDetach();

	MyHead.GotoState('Dead');

	// Send it flying
	MyHead.GiveMomentum(Momentum);

	//Remove connection to head but don't destroy it
	DissociateHead(false);
}

///////////////////////////////////////////////////////////////////////////////
// Very early setup
///////////////////////////////////////////////////////////////////////////////
simulated function PreBeginPlay()
{
	Super.PreBeginPlay();
	
	// P2MocapPawn PreBeginPlay overrides MyRace setting, so set it here
	MyRace = RACE_Skeleton;
}

// xPatch: T-Pose Fix
simulated function name GetAnimDeathFallForward()
{
	return 'p_death1';
}

defaultproperties
{
	ActorID="Skeleton"
	ControllerClass=class'ZombieController'
	Mesh=SkeletalMesh'Halloweeen_Anims.DirtyHarry'
	Skins(0)=Texture'Halloweeen_Tex.skulljaw_diff'
	HeadMesh=SkeletalMesh'Halloweeen_Anims.Skull'
	HeadSkin=Texture'Halloweeen_Tex.skull_diff'
	HeadClass=class'SkeletonHead'
	Gang="Skeletons"
	GibsClass=class'SkeletonExplosion'
	FleshHit=Sound'AWSoundFX.Machete.machetehitwall'
	CutLimbSound=Sound'AWSoundFX.Machete.machetehitwall'
	CutInHalfSound=Sound'AWSoundFX.Scythe.scythehitwall'
	BladeCleaveNeckSound=Sound'AWSoundFX.Machete.machetehitwall'

	HealthMax=120
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
	VomitClass=class'SkeletonProjectileZombie'
	VomitDamage=50
	ZWalkPct=0.35
	SwipeDamage=20
	SmashDamage=50
	
	MovementAnims(0)=""
    MovementAnims(1)=""
    MovementAnims(2)=""
    MovementAnims(3)=""

    TurnLeftAnim=""
    TurnRightAnim=""
	
	BaseMeshAnim=MeshAnimation'Halloweeen_Anims.animAvg'	// xPatch
}
