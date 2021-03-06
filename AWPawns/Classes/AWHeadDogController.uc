///////////////////////////////////////////////////////////////////////////////
// AWHeadDogController
// Copyright 2004 RWS, Inc.  All Rights Reserved.
//
// Makes the dog search for and explode zombie heads
///////////////////////////////////////////////////////////////////////////////
class AWHeadDogController extends AWDogController;

var ZombieHead HeadToEat;			// Head we'll eat
var class<P2Damage> EatHeadDamage;	// damage we apply to heads to eat and explode them


///////////////////////////////////////////////////////////////////////////
// Piss is hitting me, decide what to do
///////////////////////////////////////////////////////////////////////////
function BodyJuiceSquirtedOnMe(P2Pawn Other, bool bPuke)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////
// Something annoying, but not really gross or life threatening
// has been done to me, so check to maybe notice
///////////////////////////////////////////////////////////////////////////
function InterestIsAnnoyingUs(Actor Other, bool bMild)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////
// A bouncing, disembodied head/dead body just hit us, decide what to do
///////////////////////////////////////////////////////////////////////////
function GetHitByDeadThing(Actor DeadThing, FPSPawn KickerPawn)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////
// Gas is hitting me, decide what to do
///////////////////////////////////////////////////////////////////////////
function GettingDousedInGas(P2Pawn Other)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// We can't be touched
///////////////////////////////////////////////////////////////////////////////
event Touch(actor Other)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Don't go after heads like a normal dog
///////////////////////////////////////////////////////////////////////////////
function RespondToAnimalCaller(FPSPawn Thrower, Actor Other, out byte StateChange)
{
	if(ZombieHead(Other) == None)
	{
		Super.RespondToAnimalCaller(Thrower, Other, StateChange);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Find a decapped zombie head to chomp
///////////////////////////////////////////////////////////////////////////////
function FindHeads()
{
	local ZombieHead zhead;
	foreach DynamicActors(class'ZombieHead', zhead)
	{
		//log(Self$" seeing "$zhead$" body "$zhead.MyBody);
		if(zhead.MyBody == None
			&& !zhead.bDeleteMe
			&& !zhead.IsDissolving())
		{
			HeadToEat = zhead;
			SetEndGoal(zhead, DEFAULT_END_RADIUS);
			SetNextState('EatHead');
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			//MyPawn.PlayHappySound();
			GotoStateSave('RunToHead');
		}
	}
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
		HeadToEat = None;
	}

Begin:
	Sleep(0.0);

	GotoHero();

	FindHeads();

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
			if(MyPawn.Health < MyPawn.HealthMax
				&& Frand() < LIMP_IF_HURT_FREQ)
				GotoStateSave('LimpByHero');
			else
				GotoStateSave('StandByHero');
		}
		else if(FRand() <= 0.5)
		{
			GotoStateSave('Standing');
		}
		else
			GotoStateSave('Sitting');
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
// Go to eat the head
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToHead extends RunToTarget
{
	ignores FindHeads;

	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		if(EndGoal == None
			|| EndGoal.bDeleteMe)
		{
			HeadToEat = None;
			EndGoal = None;
			GotoStateSave('Thinking');
		}
		else
			Super.InterimChecks();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Grab a head and wrestle back and forth till it explodes
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state EatHead extends AttackTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);

		if(channel == 0)
		{
			if(HeadToEat == None
				|| HeadToEat.bDeleteMe)
				GotoStateSave('Thinking');
			else
			{
				HeadToEat.TakeDamage(1, MyPawn, HeadToEat.Location, vect(0,0,1),
								EatHeadDamage);
				SetAttacker(None);
				GotoStateSave('Thinking');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		log(self$" end eat head, head "$HeadToEat$" delete "$HeadToEat.bDeleteMe);
		bHurtTarget=false;
		MyPawn.ChangeAnimation();
		if(MyBone != None
			&& !MyBone.bDeleteMe)
			MyBone.Destroy();
		MyBone= None;
		if(HeadToEat != None
			&& !HeadToEat.bDeleteMe)
			HeadToEat.Destroy();
		HeadToEat= None;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Play pounce anim
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local Rotator rel;
		local int i;

		// Go back to thinking if the head's bad
		if(HeadToEat == None
			|| HeadToEat.bDeleteMe)
			GotoStateSave('Thinking');
		else
		{
			PrintThisState();

			FocalPoint = HeadToEat.Location;
			// Stop the head from moving/colliding
			HeadToEat.bBlockZeroExtentTraces=false;
 			HeadToEat.bBlockNonZeroExtentTraces=false;
			HeadToEat.bCollideWorld=false;
			HeadToEat.SetCollision(false, false, false);
			HeadToEat.Acceleration = vect(0,0,0);
			HeadToEat.Velocity = vect(0,0,0);
			HeadToEat.SetPhysics(PHYS_none);
			HeadToEat.SetDrawScale(0.0001);
			HeadToEat.GotoState('');
			Focus = HeadToEat;

			// Make a copy to put in your mouth because
			// just putting the head in there won't work
			MyBone = spawn(class'AnimNotifyActor',MyPawn);
			// Copy over visuals
			if(Focus.Mesh != None)
			{
				MyBone.SetDrawType(DT_Mesh);
				MyBone.LinkMesh(Focus.Mesh);
				if(Focus.Skins.Length > 0)
				{
					MyBone.Skins.Insert(0, Focus.Skins.Length);
					for(i=0; i<Focus.Skins.Length; i++)
					{
						MyBone.Skins[i] = Focus.Skins[i];
					}
				}
			}
			else
			{
				MyBone.SetStaticMesh(Focus.StaticMesh);
				if(Focus.Skins.Length > 0)
				{
					MyBone.Skins.Insert(0, Focus.Skins.Length);
					for(i=0; i<Focus.Skins.Length; i++)
					{
						MyBone.Skins[i] = Focus.Skins[i];
					}
				}
			}
			// stick it in his mouth
			MyPawn.AttachToBone(MyBone, MouthBone);
			rel.Pitch=16000;
			MyBone.SetRelativeRotation(rel);

			// He swings his head back and, forth hurting the target
			MyPawn.PlayAttack1();
			MyPawn.StopAcc();
			bHurtTarget=false;
		}
	}

Begin:
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     EatHeadDamage=Class'AWEffects.SledgeDamage'
}
