///////////////////////////////////////////////////////////////////////////////
// RaptorController
// Copyright 2014 Running With Scissors, Inc. All Rights Reserved
//
// These guys behave a lot like dogs, except they're bigger and meaner
///////////////////////////////////////////////////////////////////////////////
class RaptorController extends DogController;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
const HIT_MOMENTUM			= 1250000;
const Z_DIFF_TO_JUMP		= 100.f;
const RAPTOR_POUNCE_RADIUS	= 250.f;
const RAPTOR_POUNCE_DOT		= 0.5;
const RAPTOR_SLOW_JUMP		= 200.f;		// If we get slowed down to this value or below by an obstacle, try and jump out of the way
const MAX_GIVE_UP_COUNT		= 3;			// Max number of attempts to attack the target. Any successful hit will reset the count
const WHIMPER_AND_RUN_FREQ	= 0;
const POUNCE_DIST			= 100;
const POUNCE_SPEED			= 1.25;			// Percentage of fullspeed we can pounce at
const POUNCE_DELTA_T		= 0.555556;
const MIN_DAMAGE_TO_REACT	= 50;
const BACK_UP_DIST			= 500;
const MAX_STUCK_TIME		= 1.0;
const RAPTOR_BODY_HEALTH	= 150;			// Health restored from eating a body
const RAPTOR_HEAD_HEALTH	= 50;			// Health restored from eating a head
const ATTACK_DEAD			= 0;

var() int BiteDamage;						// How much damage we do with our bite attack

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Notify stubs (defined in states)
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Notify_RaptorPounce();
function Notify_RaptorBite();

///////////////////////////////////////////////////////////////////////////////
// Return true if this is a thing we might potentially want to attack
///////////////////////////////////////////////////////////////////////////////
function bool ShouldAttack(FPSPawn AttackMe)
{
	// FIXME will need to adjust for hero
	return !SameGang(AttackMe);
}

///////////////////////////////////////////////////////////////////////////////
// Something died here... dinnertime!
///////////////////////////////////////////////////////////////////////////////
function MarkerIsHere(class<TimedMarker> bliphere,
					  FPSPawn CreatorPawn, 
					  Actor OriginActor,
					  vector blipLoc)
{
	log("marker is here"@bliphere@CreatorPawn@OriginActor@blipLoc);
	// Only if we're not in combat
	if (ClassIsChildOf(bliphere, class'DeadBodyMarker') && (Attacker == None || Attacker.Health <= 0 || Attacker.bDeleteMe ))
	{
		InterestPawn = CreatorPawn;
		InterestActor = OriginActor;
		SetEndPoint(InterestActor.Location, PAWN_END_RADIUS);
		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		SetNextState('InvestigateDeadThing');
		GotoStateSave('WalkToTarget');
	}
	else
		Super.MarkerIsHere(bliphere, CreatorPawn, OriginActor, blipLoc);
}

///////////////////////////////////////////////////////////////////////////////
// Look for hated enemies
///////////////////////////////////////////////////////////////////////////////
function CheckForEnemies(float RadCheck, optional out byte StateChange)
{
	local P2Pawn CheckP, AttackMe;
	local string usegang;
	local float closest, dist;
	local vector catbutt;
	
	closest = RadCheck;

	// check all the pawns around me.
	ForEach VisibleCollidingActors(class'P2Pawn', CheckP, RadCheck, MyPawn.Location)
	{
		// Only check cats not behind obstructions.
		if(!SameGang(CheckP)
			&& CheckP.Health > 0
			&& FastTrace(MyPawn.Location, CheckP.Location)
			&& CheckP != MyPawn
			&& CheckP != Hero)
		{
			dist = VSize(CheckP.Velocity);
			if (dist < closest)
				AttackMe = CheckP;
		}
	}
	
	// sic 'em!
	if (AttackMe != None)
	{
		SetAttacker(AttackMe);
		SetNextState('RecognizeTarget');
		StateChange = 1;
	}
}

///////////////////////////////////////////////////////////////////////////
// When attacked
// Raptors no-sell attacks below a certain threshold (mostly bullets)
///////////////////////////////////////////////////////////////////////////
function damageAttitudeTo(pawn Other, float Damage)
{
	local vector dir;
	local vector HitNormal, HitLocation, dest;
	local Actor HitActor;
	local FPSPawn OldAttacker;

	if(Damage > 0)
	{
		MyPawn.PlayHurtSound();
		// Don't attack other raptors
		if (!ShouldAttack(FPSPawn(Other)))
			return;
		if ( (FPSPawn(Other) != None) && (Other != Pawn))
		{
			if(Other == Hero)
			{
				GotoStateSave('RunAway');
			}
			else
			{
				OldAttacker = Attacker;
				SetAttacker(FPSPawn(Other));
				
				// If we haven't attacked yet, roar at them first
				if (OldAttacker == None)
				{
					GotoState('RecognizeTarget');
				}
				// Ignore damage below a certain amount
				else if (Damage >= MIN_DAMAGE_TO_REACT)
				{
					dest = VRand();
					dest.z=0;
					dest = (RETREAT_DIST + FRand()*RETREAT_DIST)*dest + MyPawn.Location;

					HitActor = Trace(HitLocation, HitNormal, dest, MyPawn.Location, true);

					// Move away from obstruction
					if(HitActor != None)
					{
						MovePointFromWall(HitLocation, HitNormal, MyPawn);
					}
					else // set up hit location to raise from ground
						HitLocation = dest;
					
					// Make sure it's not floating in space
					RaisePointFromGround(HitLocation, MyPawn);
					dest = HitLocation;
					
					// Run to a point just behind me
					SetEndPoint(dest, DEFAULT_END_RADIUS);
					// Run away first, then get mad and attack
					if(IsInState('LegMotionToTarget'))
						bPreserveMotionValues=true;
					SetNextState('AttackTarget');
					GotoStateSave('RunningScared');
				}
			}
		}
		else if (Damage >= MIN_DAMAGE_TO_REACT)	// hit by something like a cactus
		{
			dest = VRand();
			dest.z=0;
			dest = (RETREAT_DIST + FRand()*RETREAT_DIST)*dest + MyPawn.Location;

			HitActor = Trace(HitLocation, HitNormal, dest, MyPawn.Location, true);

			// Move away from obstruction
			if(HitActor != None)
			{
				MovePointFromWall(HitLocation, HitNormal, MyPawn);
			}
			else // set up hit location to raise from ground
				HitLocation = dest;
			
			// Make sure it's not floating in space
			RaisePointFromGround(HitLocation, MyPawn);
			dest = HitLocation;

			// Run to a point just behind me
			SetEndPoint(dest, DEFAULT_END_RADIUS);
			// Run away first, then get mad and attack
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			SetNextState('AttackTarget');
			GotoStateSave('RunningScared');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// We don't eat doggy treats... raptor wants something with a little more meat
///////////////////////////////////////////////////////////////////////////////
function CheckDesiredThing(Actor DesireMaker, class<TimedMarker> blip, optional out byte StateChange);

///////////////////////////////////////////////////////////////////////////
// Ignore this function when we're already attacking the guy
///////////////////////////////////////////////////////////////////////////
function StartAttacking()
{
	GotoStateSave('RecognizeTarget');
}

///////////////////////////////////////////////////////////////////////////////
// Given a target destination, returns true if the raptor should try a jump
// to get there.
// Poached shamelessly from APawn::SuggestJumpVelocity
///////////////////////////////////////////////////////////////////////////////
function bool ShouldAttemptJump(Vector Destination, out Vector JumpVector, optional float CollisionHeight)
{
	local float XYDist, ZDist, ReachTime, XYSpeed;
	local Vector TraceDest;
	
	// Do a z-diff check first, don't bother for low-height jumps
	if (abs(Pawn.Location.Z - Destination.Z) < Z_DIFF_TO_JUMP)
		return false;
		
	// If we don't have a reasonable line of sight to our destination, don't try the jump
	TraceDest = Destination;
	TraceDest.Z += CollisionHeight * 1.2;
	if (!FastTrace(TraceDest, Pawn.Location))
		return false;
	
	JumpVector = Pawn.Location - Destination;
	ZDist = JumpVector.Z;
	JumpVector.Z = 0;
	XYDist = VSize(JumpVector);
	JumpVector = JumpVector / XYDist;
	
	// Check for negative gravity
	if (Pawn.PhysicsVolume.Gravity.Z >= 0)
	{
		JumpVector.X *= Pawn.GroundSpeed;
		return true;
	}
	
	ReachTime = XYDist / Pawn.GroundSpeed;
	JumpVector.Z = ZDist/ReachTime - 0.5 * Pawn.PhysicsVolume.Gravity.Z * ReachTime;	
	
	if ( (JumpVector.Z <= Pawn.JumpZ) && (Pawn.PhysicsVolume.Gravity.Z != 0.f) )
	{
		// reduce XYSpeed
		// solve quadratic for ReachTime
		ReachTime = (-1.f * Pawn.JumpZ + Sqrt(Pawn.JumpZ * Pawn.JumpZ + 2.f * Pawn.PhysicsVolume.Gravity.Z * ZDist))/Pawn.PhysicsVolume.Gravity.Z;
		ReachTime = FMax(ReachTime, 0.05f);
		XYSpeed = FMin(Pawn.GroundSpeed,XYDist/ReachTime);
	}
	else
		return false;	// Can't make it

	// clamp to jump speed
	JumpVector.X *= -XYSpeed;
	JumpVector.Y *= -XYSpeed;
	JumpVector.Z = Pawn.JumpZ;
	
	return true;	
}

///////////////////////////////////////////////////////////////////////////////
// Given a jump vector, go airborne flying toward our attacker
///////////////////////////////////////////////////////////////////////////////
function JumpTowardTarget(Vector JumpVector)
{
	Focus = Attacker;
	Pawn.Velocity = JumpVector;
	Pawn.Acceleration = Vect(0,0,0);
	Pawn.SetPhysics(PHYS_Falling);	
	GotoState('Jumping');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run this target down and pounce on them till they're dead
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state AttackTarget
{
	ignores GetReadyToReactToDanger, StartAttacking;
	
	///////////////////////////////////////////////////////////////////////////////
	// If you Touch the attacker, go into a shredding anim to hurt him
	///////////////////////////////////////////////////////////////////////////////
	event Touch(actor Other);
	/*
	{
		local FPSPawn otherpawn;

		otherpawn = FPSPawn(Other);

		if(otherpawn != None
			&& otherpawn.Health > 0
			&& otherpawn == Attacker
			&& (otherpawn != Hero))
		{
			GotoStateSave('ShredAttack');
		}
	}
	*/

	///////////////////////////////////////////////////////////////////////////////
	// Check to make sure your attacker is alive.. if not, then go to thinking
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local byte StateChange;
		
		// Don't attack anymore
		if(Attacker == None
			|| Attacker.bDeleteMe)
			GotoStateSave('Thinking');
		else if(Attacker.Health <= 0)
		{
			// Look around for any other hated pawns
			CheckForEnemies(ENEMY_SEARCH_RADIUS, StateChange);
			if (StateChange == 0)
			{
				// If the player attacked us, and he's still alive, go right back after him
				if(PlayerAttackedMe != None
					&& PlayerAttackedMe.Health > 0)
					GoAfterPlayerAgain();
				else if(Frand() < STOP_ATTACKING_FREQ)
				{
					GotoStateSave('Thinking');
				}
				else
				{
					if(VSize(Attacker.Location - MyPawn.Location) > DEFAULT_END_RADIUS+Attacker.CollisionRadius)
					{
						SetEndPoint(Attacker.Location, DEFAULT_END_RADIUS);
						SetNextState('ShredAttack');
						GotoStateSave('RunToAttacker');
					}
					else
						GotoStateSave('ShredAttack');
				}
			}
		}
	}
	
Begin:
	MyPawn.PlayAngrySound();
	SetNextState('PounceOnTarget');
	SetEndGoal(Attacker, POUNCE_DIST + (2*FRand()*POUNCE_DIST));
	GotoStateSave('RunToPounce');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Jump on this guy and hurt him
// Unlike dogs, we have a specific point in our animation where we want to
// hurt things
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PounceOnTarget
{
	event Touch(actor Other);

	///////////////////////////////////////////////////////////////////////////////
	// If touched by normal people run, otherwise, jump in the player's inventory
	///////////////////////////////////////////////////////////////////////////////
	function Notify_RaptorPounce()
	{
		local FPSPawn otherpawn;
		local vector hitpos, dir;
		
		// Hurt things around us
		foreach VisibleCollidingActors(class'FPSPawn', otherpawn, RAPTOR_POUNCE_RADIUS, Pawn.Location)
		{
			if(otherpawn != None
				&& otherpawn.Health > 0
				&& otherpawn != Pawn
				&& ShouldAttack(OtherPawn))
			{
				// Make sure they're generally in front of us, first.
				dir = otherpawn.Location - Pawn.Location;
				dir.z = 0;
				dir = Normal(dir);
				if (Vector(Pawn.Rotation) dot dir > RAPTOR_POUNCE_DOT)
				{			
					GiveUpCount = 0;	// Reset our give-up count if we successfully hurt something.
					// give it an extra boost
					dir = Normal(otherpawn.Location - MyPawn.Location) + VRand();
					hitpos = otherpawn.Location - otherpawn.CollisionRadius*dir;
					otherpawn.TakeDamage(PounceDamage, MyPawn, hitpos, HIT_MOMENTUM*dir, AttackDamageType);
					MakePeopleScared(class'AnimalAttackMarker');
				}
			}
		}
	}
	
	event BeginState()
	{
		CalcEndGoal();
		Super.BeginState();
		Focus = Attacker;
	}

	///////////////////////////////////////////////////////////////////////////////
	// CalcEndGoal
	// Calculates where the raptor should pounce
	///////////////////////////////////////////////////////////////////////////////
	function CalcEndGoal()
	{
		local Vector LeadPos;
		local float PounceSpeed;
		local Vector PounceVect;
		
		LeadPos = Attacker.Location + Attacker.Velocity * POUNCE_DELTA_T;
		PounceSpeed = Pawn.GroundSpeed * POUNCE_SPEED;
		PounceVect = LeadPos - Pawn.Location;
		
		// Have them pounce in that general direction even if it's too far away to reach
		if (VSize(PounceVect) > PounceSpeed)
			PounceVect = Normal(PounceVect) * PounceSpeed;
		
		//Pawn.Velocity = PounceVect;
		SetEndGoal(None, 0);
		SetEndPoint(LeadPos, 0);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Wrestling the thing back and forth, hurting it
// Unlike dogs, we have a specific point in our animation where we want to
// hurt things
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShredAttack
{
	event Touch(actor Other);

	///////////////////////////////////////////////////////////////////////////////
	// If touched by normal people run, otherwise, jump in the player's inventory
	///////////////////////////////////////////////////////////////////////////////
	function Notify_RaptorBite()
	{
		local FPSPawn otherpawn;
		local vector hitpos, dir;
		
		// Hurt things around us
		foreach VisibleCollidingActors(class'FPSPawn', otherpawn, RAPTOR_POUNCE_RADIUS, Pawn.Location)
		{
			if(otherpawn != None
				&& otherpawn.Health > 0
				&& otherpawn != Pawn
				&& ShouldAttack(OtherPawn))
			{
				// Make sure they're generally in front of us, first.
				dir = otherpawn.Location - Pawn.Location;
				dir.z = 0;
				dir = Normal(dir);
				if (Vector(Pawn.Rotation) dot dir > RAPTOR_POUNCE_DOT)
				{			
					GiveUpCount = 0;	// Reset our give-up count if we successfully hurt something.
					// give it an extra boost
					dir = Normal(otherpawn.Location - MyPawn.Location) + VRand();
					hitpos = otherpawn.Location - otherpawn.CollisionRadius*dir;
					otherpawn.TakeDamage(BiteDamage, MyPawn, hitpos, HIT_MOMENTUM*dir, AttackDamageType);
					MakePeopleScared(class'AnimalAttackMarker');
				}
			}
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);

		if(channel == 0)
		{
			// If our attacker is a cat or dog, or small like us, then chunk him up
			if(!Attacker.bDeleteMe
				//&& Attacker.Health <= 0
				&& Attacker.CollisionHeight <= class'DogPawn'.Default.CollisionHeight)
			{
				Attacker.ChunkUp(Attacker.Health);
				SetAttacker(None);
				// If the player attacked us, and he's still alive, go right back after him
				if(PlayerAttackedMe != None
					&& PlayerAttackedMe.Health > 0)
					GoAfterPlayerAgain();
				else	// Otherwise just stand around over your kill
					GotoStateSave('Standing');
			}
			else if(Attacker.Health > 0)
				GotoStateSave('AttackTarget');
			else
				GotoStateSave('Standing');
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Play pounce anim
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		if(Attacker == None
			|| Attacker.bDeleteMe)
			GotoStateSave('Thinking');
		else
		{
			Focus = Attacker;
			// He swings his head back and, forth hurting the target
			MyPawn.PlayAttack1();
			MyPawn.StopAcc();
			bHurtTarget=false;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunToAttacker
// Every so often, see if we can reach our attacker with a long jump.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToAttacker
{
	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{	
		local Vector JumpVector;
		
		Super.InterimChecks();
		if (ShouldAttemptJump(Attacker.Location, JumpVector, Attacker.CollisionHeight))
			JumpTowardTarget(JumpVector);
		else
		{
			Statecount = 2;
			CurrentFloat = 0;
		}
	}
	// If we kind of slow down, try and jump around our obstacle
	event Tick(float dT)
	{
		local Vector JumpVector;
		local vector dir;
		local vector HitNormal, HitLocation, dest;
		local Actor HitActor;
		
		if (Statecount != 2 && VSize(Velocity) < RAPTOR_SLOW_JUMP)
		{
			// Don't continually call this function, slows things down.
			Statecount = 1;
			if (ShouldAttemptJump(Attacker.Location, JumpVector, Attacker.CollisionHeight))
				JumpTowardTarget(JumpVector);
			else
			{
				CurrentFloat += dT;
				if (CurrentFloat > MAX_STUCK_TIME)
				{
					// Back up and try to find another path
					CurrentFloat = 0;
					dest = VRand();
					dest.z=0;
					dest = (BACK_UP_DIST + FRand()*BACK_UP_DIST)*dest + MyPawn.Location;

					HitActor = Trace(HitLocation, HitNormal, dest, MyPawn.Location, true);

					// Move away from obstruction
					if(HitActor != None)
					{
						MovePointFromWall(HitLocation, HitNormal, MyPawn);
					}
					else // set up hit location to raise from ground
						HitLocation = dest;
					
					// Make sure it's not floating in space
					RaisePointFromGround(HitLocation, MyPawn);
					dest = HitLocation;

					// Run to a point just behind me
					SetEndPoint(dest, DEFAULT_END_RADIUS);
					// Run away first, then get mad and attack
					if(IsInState('LegMotionToTarget'))
						bPreserveMotionValues=true;
					SetNextState('AttackTarget');
					GotoStateSave('RunToTarget');
				}
			}
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// If we can't find a good path, try and jump there anyway.
	///////////////////////////////////////////////////////////////////////////////
	function CantFindPath(Actor Dest, optional vector DestPoint)
	{
		local Vector JumpVector;
		if (ShouldAttemptJump(Attacker.Location, JumpVector, Attacker.CollisionHeight))
			JumpTowardTarget(JumpVector);
	}
}
state RunToPounce
{
	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{	
		local Vector JumpVector;
		
		Super.InterimChecks();
		if (ShouldAttemptJump(Attacker.Location, JumpVector, Attacker.CollisionHeight))
			JumpTowardTarget(JumpVector);

		else
		{
			Statecount = 2;
			CurrentFloat = 0;
		}
	}
	// If we kind of slow down, try and jump around our obstacle
	event Tick(float dT)
	{
		local Vector JumpVector;
		local vector dir;
		local vector HitNormal, HitLocation, dest;
		local Actor HitActor;
		
		if (Statecount != 2 && VSize(Velocity) < RAPTOR_SLOW_JUMP)
		{
			// Don't continually call this function, slows things down.
			Statecount = 1;
			if (ShouldAttemptJump(Attacker.Location, JumpVector, Attacker.CollisionHeight))
				JumpTowardTarget(JumpVector);
			else
			{
				CurrentFloat += dT;
				if (CurrentFloat > MAX_STUCK_TIME)
				{
					// Back up and try to find another path
					CurrentFloat = 0;
					dest = VRand();
					dest.z=0;
					dest = (BACK_UP_DIST + FRand()*BACK_UP_DIST)*dest + MyPawn.Location;

					HitActor = Trace(HitLocation, HitNormal, dest, MyPawn.Location, true);

					// Move away from obstruction
					if(HitActor != None)
					{
						MovePointFromWall(HitLocation, HitNormal, MyPawn);
					}
					else // set up hit location to raise from ground
						HitLocation = dest;
					
					// Make sure it's not floating in space
					RaisePointFromGround(HitLocation, MyPawn);
					dest = HitLocation;

					// Run to a point just behind me
					SetEndPoint(dest, DEFAULT_END_RADIUS);
					// Run away first, then get mad and attack
					if(IsInState('LegMotionToTarget'))
						bPreserveMotionValues=true;
					SetNextState('AttackTarget');
					GotoStateSave('RunToTarget');
				}
			}
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// If we can't find a good path, try and jump there anyway.
	///////////////////////////////////////////////////////////////////////////////
	function CantFindPath(Actor Dest, optional vector DestPoint)
	{
		local Vector JumpVector;
		if (ShouldAttemptJump(Attacker.Location, JumpVector, Attacker.CollisionHeight))
			JumpTowardTarget(JumpVector);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Jump state
// Things to do while airborne
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Jumping
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas,
		StartledBySomething, GetReadyToReactToDanger, RespondToTalker, StartAttacking;
		
	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after this
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterGoal()
	{
		local vector DestPoint;
		
		bPreserveMotionValues=true;

		if(Attacker == None)
		{
			GotoStateSave('Thinking');
		}
		else if(Attacker.Health > 0)
		{
			DestPoint = POUNCE_DEST_DIST*(Normal(Attacker.Location - MyPawn.Location)) + MyPawn.Location;
			RaisePointFromGround(DestPoint, MyPawn);
			SetEndPoint(DestPoint, TIGHT_END_RADIUS);
			GotoState('RunToAttacker');
			SetNextState('AttackTarget');
		}
		else
		{
			SetEndGoal(Attacker, TIGHT_END_RADIUS);
			GotoState('RunToAttacker');
			SetNextState('AttackTarget');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// If touched by normal people run, otherwise, jump in the player's inventory
	///////////////////////////////////////////////////////////////////////////////
	function DamagePawnsOnLanding()
	{
		local FPSPawn otherpawn;
		local vector hitpos, dir;
		
		// Hurt things around us
		foreach VisibleCollidingActors(class'FPSPawn', otherpawn, RAPTOR_POUNCE_RADIUS, Pawn.Location)
		{
			if(otherpawn != None
				&& otherpawn.Health > 0
				&& otherpawn != Pawn)
			{
				GiveUpCount = 0;	// Reset our give-up count if we successfully hurt something.
				// give it an extra boost
				dir = Normal(otherpawn.Location - MyPawn.Location) + VRand();
				hitpos = otherpawn.Location - otherpawn.CollisionRadius*dir;
				otherpawn.TakeDamage(PounceDamage, MyPawn, hitpos, HIT_MOMENTUM*dir, AttackDamageType);
				MakePeopleScared(class'AnimalAttackMarker');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	event bool NotifyLanded(vector HitNormal)
	{
		DamagePawnsOnLanding();
		FPSPawn(Pawn).StopAcc();
		RaptorPawn(Pawn).PlayJumpLanding();
		Pawn.SetPhysics(PHYS_Walking);
		Pawn.ChangeAnimation();
		NextStateAfterGoal();
		return true;
	}		
Begin:
	Pawn.ChangeAnimation();
	RaptorPawn(MyPawn).PlayJump();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Decide what to do next
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Thinking
{
	///////////////////////////////////////////////////////////////////////////////
	// Clear your prospects 
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		if(MyBone != None)
		{
			MyBone.Destroy();
		}
		MyBone = None;
		PreviousActor=None;
		MyPawn.ChangeAnimation();
	}

Begin:
	Sleep(0.0);

	CheckForEnemies(ENEMY_SEARCH_RADIUS);
	
	GotoHero();

	if(!bPreparingMove)
	{
		if(FRand() <= WALK_AROUND_FREQ)
		{
			SetNextState('Thinking');
			if(!PickRandomDest())
				Goto('Begin');	// Didn't find a valid point, try again

			GotoStateSave('WalkToTarget');
		}
HangAround:
		if(Hero != None
			&& HeroLove > 0)
		{
			/*if(MyPawn.Health < MyPawn.HealthMax
				&& Frand() < LIMP_IF_HURT_FREQ)
				GotoStateSave('LimpByHero');
			else*/
				GotoStateSave('StandByHero');
		}
		else if(FRand() <= 0.5)
		{
			GotoStateSave('Standing');
		}
		else
			GotoStateSave('Idling');
	}
	else
	{
		Sleep(2.0);
		Goto('Begin');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Sit and look around
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Idling
{
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		local byte StateChange;

		MyPawn.AnimEnd(channel);
		//log("anim end "$channel$" state count "$statecount);
		// Check for the base channel only
		if(channel == 0)
		{
			GoToHero(true, StateChange);

			if(StateChange == 0)
			{
				GotoStateSave('Thinking');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		MyPawn.ChangeAnimation();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Stop and zero out things
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
		statecount=0;
	}

Begin:
	// sit down
	MyPawn.PlayInvestigate();
	statecount=0;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run this target down and pounce on them till they're dead
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RecognizeTarget
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas,
		StartledBySomething, GetReadyToReactToDanger, RespondToTalker, StartAttacking;
		
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		local byte StateChange;

		MyPawn.AnimEnd(channel);
		//log("anim end "$channel$" state count "$statecount);
		// Check for the base channel only
		if(channel == 0)
		{
			GotoState(GetStateName(),'DoAttack');
		}
	}
Begin:
	Focus = Attacker;
	MyPawn.StopAcc();
	MyPawn.PlayGetAngered();
	Goto('Waiting');
DoAttack:
	GotoState('AttackTarget');
Waiting:
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Something died here... dinner!
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state InvestigateDeadThing
{
	event BeginState()
	{
		MyPawn.StopAcc();
		// Thing might have died before we got there		
		if (InterestActor == None || InterestActor.bDeleteMe)
			GotoState('Thinking');
	}
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);

		if(channel == 0)
		{
			// Destroy the thing we were eating
			if (InterestActor != None && !InterestActor.bDeleteMe)
			{
				if (Pawn(InterestActor) != None)
				{
					// Explode into delicious gibs				
					Pawn(InterestActor).ChunkUp(-1);
					// Restore a bit of health from it
					MyPawn.AddHealth(RAPTOR_BODY_HEALTH);
				}
				else if (Head(InterestActor) != None)
				{
					// This explodes the head
					InterestActor.EncroachedBy(Pawn);
					// Restore a bit of health from it
					MyPawn.AddHealth(RAPTOR_HEAD_HEALTH);
				}
				else
				{
					// Otherwise destroy the thing we were eating
					InterestActor.Destroy();
					// Restore a bit of health from it
					MyPawn.AddHealth(RAPTOR_HEAD_HEALTH);
				}					
			}
			
			// Go back to thinking
			GotoState('Thinking');
		}
	}
Begin:
	Focus = InterestActor;
	FinishRotation();
	RaptorPawn(Pawn).PlayEating();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	BiteDamage=30
}