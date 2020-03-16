///////////////////////////////////////////////////////////////////////////////
// DogController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
//	Dogs can gain heroes, if that person throws things for them to bring back.
//	While the dog has a hero, he has double the default healthmax.
//
///////////////////////////////////////////////////////////////////////////////
class DogController extends AnimalController;

///////////////////////////////////////////////////////////////////////////////
// vars
///////////////////////////////////////////////////////////////////////////////

// Different ways decide to catch up
enum MoveType{
	DOGM_Walk,
	DOGM_Trot,
	DOGM_Run,
};

var int PounceDamage;	// Damage inflicted on pounced-on victim

var bool bHurtTarget;	// Turn this off and on, so as to only hurt something once
						// a try
var FPSPawn ProspectiveHero;	// He could be your friend, so don't growl at him

var AnimNotifyActor MyBone;	// Thing I'm holding in my mouth;
var Actor   PreviousActor;	// Save everything about the actor we just grabbed in our mouths

var int		HeroLove;		// How much we love our hero
var bool	bBotherHeroForLove;	// We just stopped loving our hero, so when we can, we should tell him
var MoveType Catchup;		// specifies how fast we move to catch up--walk, trot, run
var int		CrapCount;		// How many times he needs to crap. Goes up with each piece of food you give him
var StaticMesh turdmesh;
var FPSPawn	PlayerAttackedMe;// If the player attacked me, mark it in SetAttacker. Then look at this
							// again, so we can go hunt him down, when we're done with our old attacker
var class<DamageType> AttackDamageType;		// Damage we cause.
var int		GiveUpCount;	// If we can't get to the target, give up after a certain number of tries.

///////////////////////////////////////////////////////////////////////////////
// consts
///////////////////////////////////////////////////////////////////////////////
const BARK_FREQ  = 0.7;
const GROWL_FREQ = 0.6;

const SNIFF_FREQ    = 0.4;
const PISS_FREQ    = 0.35;
const SIT_LOOP_FREQ = 0.15;
const STAND_LOOP_FREQ = 0.1;
const WALK_AROUND_FREQ = 0.6;
const STOP_ATTACKING_FREQ	=	0.25;

const WHIMPER_AND_RUN_FREQ	=	0.25;

//const WALKING_MEOW_FREQ	=	0.01;

const MIN_VELOCITY_FOR_REAL_MOVEMENT = 30;
const LEG_MOTION_CAUGHT_MAX=1;

const POUNCE_DIST	   = 200;
const POUNCE_DEST_DIST = 400;
const RETREAT_DIST	   = 300;
const ATTACK_RADIUS	   = 150;
const HIT_MOMENTUM	   = 50000;

const GO_AFTER_CAT_FREQ=	0.75;

const HANG_AROUND_HERO	=	450;
const CATCH_AGAIN		=	400;

const ATTACK_DEAD		=	0.3;

const PAWN_END_RADIUS	=	140;

const DISPERSE_RADIUS	=	250;

const HERO_END_RADIUS	=	400;

const ENEMY_SEARCH_RADIUS	=	512;

const LIMP_IF_HURT_FREQ	=	0.4;

const BORED_OF_THROW_MAX=	3;

const MAKE_THROWER_HERO_COUNT=	3;

var name MouthBone;

const HERO_LOVE_MAX		=	130;
const HERO_LOVE_INC_FOOD=	15;		// love goes up by this much when he feeds me
const HERO_LOVE_INC_PLAY=	5;		// love goes up by this much when plays throw with me once
const HERO_LOVE_START_TIME= 30;		// Time you love hero at first without changing anything
const HERO_LOVE_SUB_TIME=	10;		// Subsequent time checks on love of hero
const HERO_LOVE_WALK	=	8;
const HERO_LOVE_TROT	=   20;
const ATTACKER_START_LOVE=	-30;
const PLAYER_DOG_DAMAGE_REDUCTION = 0.35;	// How much less damage our dog takes
const DOG_DAMAGE_DIFF_RATIO		  =	0.02;	// Factor for each game difficulty change average = 5 to 12?
											// that we lower the damage he takes
const MIN_DAMAGE_REDUCTION		  = 0.1;

const MAX_GIVE_UP_COUNT	=	1;		// Max number of attempts to attack the target. Any successful hit will reset the count


///////////////////////////////////////////////////////////////////////////////
// Called before this pawn is "teleported" with the player so it can save
// essential information that will later be passed to PostTeleportWithPlayer().
///////////////////////////////////////////////////////////////////////////////
function PreTeleportWithPlayer(out FPSGameState.TeleportedPawnInfo info, P2Pawn PlayerPawn)
{
	//log(MyPawn$" tried to send me ");
	Super.PreTeleportWithPlayer(info, PlayerPawn);

	// Check if player should be considered enemy
	if((Attacker != None 
		&& Attacker.bPlayer)
			|| MyPawn.bPlayerIsEnemy)
		info.bPlayerIsEnemy = true;
	else
		info.bPlayerIsEnemy = false;

	// Save friends
	info.bPlayerIsFriend = MyPawn.bPlayerIsFriend;

	// Check if the player is a hero
	if(Hero != None
		&& Hero.bPlayer
		&& HeroLove > 0)
	{
		info.bPlayerIsHero=true;
		// If we're too far away from the player, modify our offset
		if(VSize(info.Offset) > class'Telepad'.default.TravelRadius)
		{
			info.Offset = class'Telepad'.default.TravelRadius*Normal(info.Offset);
		}
	}

	// Save our love
	info.FloatVal1 = HeroLove;
	// Save how much we crapped
	info.FloatVal2 = CrapCount;
}

///////////////////////////////////////////////////////////////////////////////
// Called after this pawn was "teleported" with the player so it can restore
// itself using the previously-saved information.  See PreTeleportWithPlayer().
///////////////////////////////////////////////////////////////////////////////
function PostTeleportWithPlayer(FPSGameState.TeleportedPawnInfo info, P2Pawn PlayerPawn)
{
	Super.PostTeleportWithPlayer(info, PlayerPawn);

	if (info.bPlayerIsEnemy)
		SetToAttackPlayer(PlayerPawn);

	// Rehook up the player if he was our hero
	if(info.bPlayerIsHero)
	{
		HookHero(PlayerPawn);
	}

	// Set our hero love
	HeroLove=0;
	ChangeHeroLove(info.FloatVal1, HERO_LOVE_START_TIME);

	// Reset how much we crapped
	CrapCount = info.FloatVal2;
}

///////////////////////////////////////////////////////////////////////////////
// I'm attacking or about to attack, so scare everyone around me
///////////////////////////////////////////////////////////////////////////////
function MakePeopleScared(class<AnimalAttackMarker> ADanger)
{
	ADanger.static.NotifyControllersStatic(
		Level,
		ADanger,
		MyPawn, 
		MyPawn, 
		ADanger.default.CollisionRadius,
		MyPawn.Location);
}

///////////////////////////////////////////////////////////////////////////////
// start: set up functions (from spawner and the like)
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Just stand where you are, sort of like a security guard on duty or something
///////////////////////////////////////////////////////////////////////////////
function SetToHoldPosition()
{
	SetNextState('HoldPosition');
}
///////////////////////////////////////////////////////////////////////////////
// Find a player and kick his butt
///////////////////////////////////////////////////////////////////////////////
function SetToAttackPlayer(FPSPawn PlayerP)
{
	local FPSPawn keepp;

	log(MyPawn$" SetToAttackPlayer "$PlayerP);
	// When we get triggered, we attack the player.

	if(PlayerP == None)
		keepp = GetRandomPlayer().MyPawn;
	else
		keepp = PlayerP;

	// check for some one to attack
	if(keepp != None)
	{
		// If the player is our hero, unhook him and start over
		if(Hero == keepp)
			UnhookHero();
		SetAttacker(keepp);
		SetNextState('AttackTarget');
	}
}
///////////////////////////////////////////////////////////////////////////////
// Find a closet actor with this tag (should be a pawn) and kick his butt
///////////////////////////////////////////////////////////////////////////////
function SetToAttackTag(Name AttackTag)
{
	local FPSPawn AttackHim;

	AttackHim = FPSPawn(FindNearestActorByTag(AttackTag));

	// check for some one to attack
	if(AttackHim != None)
	{
		SetAttacker(AttackHim);
		SetNextState('AttackTarget');
	}
}
///////////////////////////////////////////////////////////////////////////////
// Run screaming from where you are
///////////////////////////////////////////////////////////////////////////////
function SetToPanic()
{
	SetNextState('RunAway');
}

///////////////////////////////////////////////////////////////////////////////
// Find a player and be scared of him
///////////////////////////////////////////////////////////////////////////////
function SetToBeScaredOfPlayer(FPSPawn PlayerP)
{
	SetToPanic();
}
///////////////////////////////////////////////////////////////////////////////
// Find a closet actor with this tag (should be a pawn) and be scared of him
///////////////////////////////////////////////////////////////////////////////
function SetToBeScaredOfTag(Name RunTag)
{
	SetToPanic();
}

///////////////////////////////////////////////////////////////////////////////
// Make pawns start dead and at the end of a given animation
///////////////////////////////////////////////////////////////////////////////
function SetToDead()
{
	MyPawn.TakeDamage(MyPawn.HealthMax, None, MyPawn.Location, vect(0, 0, 1), class'P2Damage');
	SetNextState('Destroying');
}

///////////////////////////////////////////////////////////////////////////////
// end: set up functions (from spawner and the like)
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Decide what to about that tastey donut before you
///////////////////////////////////////////////////////////////////////////////
function CheckDesiredThing(Actor DesireMaker, class<TimedMarker> blip, optional out byte StateChange)
{
	local P2PowerupPickup p2p;

	p2p = P2PowerupPickup(DesireMaker);

	if(p2p != None)
	{
		if(p2p.bEdible)
		{
			RespondToAnimalCaller(FPSPawn(p2p.Instigator), p2p, StateChange);
			StateChange=1;
			return;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Something important occurred
///////////////////////////////////////////////////////////////////////////////
function MarkerIsHere(class<TimedMarker> bliphere,
					  FPSPawn CreatorPawn, 
					  Actor OriginActor,
					  vector blipLoc)
{
	local byte Reacted;

	if(ClassIsChildOf(bliphere, class'DesiredThingMarker'))
	{
		CheckDesiredThing(OriginActor, bliphere);
	}
	else if(bliphere == class'DeadCatHitGuyMarker')
	{
	// Don't bark at dead cats on guys
	}
	else if(bliphere == class'HeadExplodeMarker')
	{
	// Don't bark at exploding heads
	}
	else if(ClassIsChildOf(bliphere, class'DeadBodyMarker'))
	{
	// Don't bark at dead bodies
	}
	else if(blipLoc != Pawn.Location
		&& MyBone == None)
	{
		GetReadyToReactToDanger(bliphere, CreatorPawn, OriginActor, blipLoc);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Local spot to set my attacker, only assigns old when not none.
///////////////////////////////////////////////////////////////////////////////
function SetAttacker(FPSPawn NewAttacker)
{
	if(Attacker != NewAttacker)
	{
		Attacker = NewAttacker;
		
		if(Attacker != None)
		{
			if(Attacker.bPlayer)
				PlayerAttackedMe=Attacker;
		}
		
		// Reset our give-up count
		GiveUpCount = 0;
	}
}
/*
Not needed anymore, because dogs and cats can interpenetrate and call 'Touches' like 
normal to hurt one another. Kept for reference.

///////////////////////////////////////////////////////////////////////////////
// Hurt the area in front of us, but only hit our attacker/victim if it's a cat
// because normally you bump into the pawn, but cats don't collide like that--
// they don't block, so we have to detect it otherwise
///////////////////////////////////////////////////////////////////////////////
function HurtCatAttacker(float DamageAmount)
{
	local FPSPawn Victims;
	local vector HurtLoc, dir;

	if(!bHurtTarget
		&& CatController(Attacker.Controller) != None)
	{
		HurtLoc = MyPawn.Location;
		HurtLoc+=CollisionRadius*vector(MyPawn.Rotation);

		foreach VisibleCollidingActors( class 'FPSPawn', Victims, ATTACK_RADIUS, HurtLoc)
		{
			if(Victims == Attacker)
			{
				bHurtTarget=true;
				dir = Normal(MyPawn.Location - Victims.Location);
				Victims.TakeDamage(DamageAmount, MyPawn, 
							(Victims.Location + (Victims.CollisionRadius)*dir),
							-HIT_MOMENTUM*dir, AttackDamageType);
				MakePeopleScared(class'AnimalAttackMarker');
			}
		}
	}
}
*/
///////////////////////////////////////////////////////////////////////////////
// We *were* attacking the player, so now go looking to attack him again
///////////////////////////////////////////////////////////////////////////////
function GoAfterPlayerAgain()
{
	SetAttacker(PlayerAttackedMe);

	GotoStateSave('AttackTarget');
}

///////////////////////////////////////////////////////////////////////////
// Ignore this function when we're already attacking the guy
///////////////////////////////////////////////////////////////////////////
function StartAttacking()
{
	GotoStateSave('AttackTarget');
}

///////////////////////////////////////////////////////////////////////////////
// You've been blinded by a flash grenade. Run away whimpering and attack later
///////////////////////////////////////////////////////////////////////////////
function BlindedByFlashBang(P2Pawn Doer)
{
	local vector dir;
	local vector HitNormal, HitLocation, dest;
	local Actor HitActor;
	local FPSPawn OldAttacker;
	
	SetAttacker(Doer);

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

///////////////////////////////////////////////////////////////////////////
// When attacked
///////////////////////////////////////////////////////////////////////////
function damageAttitudeTo(pawn Other, float Damage)
{
	local vector dir;
	local vector HitNormal, HitLocation, dest;
	local Actor HitActor;
	local FPSPawn OldAttacker;

	if(Damage > 0)
	{
		if ( (FPSPawn(Other) != None) && (Other != Pawn))
		{
			if(Other == Hero)
			{
				GotoStateSave('RunAway');
			}
			else if(Frand() < WHIMPER_AND_RUN_FREQ)
			{
				SetAttacker(FPSPawn(Other));

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
			else 
			{
				// Play a got hurt noise, no matter what
				MyPawn.PlayHurtSound();

				OldAttacker = Attacker;

				SetAttacker(FPSPawn(Other));

				if(OldAttacker == None
					|| OldAttacker != Attacker)
				{
					StartAttacking();
				}
			}
		}
		else	// hit by something like a cactus
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
// See about this prey
///////////////////////////////////////////////////////////////////////////////
function InvestigatePrey(AnimalPawn Prey)
{
	if(FRand() < GO_AFTER_CAT_FREQ)
	{
		MyPawn.ChangeAnimation();
		SetAttacker(Prey);
		GotoStateSave('AttackTarget');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Cats are the only ones say they want to be sniffed.. when you receive this
// report go attack!
///////////////////////////////////////////////////////////////////////////////
function bool ReadyForASniff(FPSPawn Sniffer)
{
	if(CatController(Sniffer.Controller) != None)
		InvestigatePrey(AnimalPawn(Sniffer));

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// When triggered, they will attack the player, wherever he is
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, pawn EventInstigator )
{
	if(!MyPawn.bNoTriggerAttackPlayer
		&& !MyPawn.bPlayerIsFriend)
	{
		// When we get triggered, we attack the player.
		SetToAttackPlayer(FPSPawn(Other));
		GotoNextState();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Decide what to do about this danger
///////////////////////////////////////////////////////////////////////////////
function GetReadyToReactToDanger(class<TimedMarker> dangerhere, 
								FPSPawn CreatorPawn, 
								Actor OriginActor,
								vector blipLoc,
								optional out byte StateChange)
{
	// If this thing doesn't care about things going on around him
	if(MyPawn.bIgnoresSenses
		|| MyPawn.bIgnoresHearing)
		return;

	// If we have a hero, check to protect him
	if(Hero != None
		&& HeroLove > 0
		&& CreatorPawn != None)
	{
		// Someone is attacking our hero
		if((PersonController(CreatorPawn.Controller) != None
				&& PersonController(CreatorPawn.Controller).Attacker == Hero)
			|| (AnimalController(CreatorPawn.Controller) != None
				&& AnimalController(CreatorPawn.Controller).Attacker == Hero))
		{
			SetAttacker(CreatorPawn); 
			GotoStateSave('AttackTarget');
			return;
		}
		// Our hero is attacking someone
		else if(CreatorPawn == Hero)
		{
			if(PersonController(Hero.Controller) != None
					&& PersonController(Hero.Controller).Attacker != None
					&& PersonController(Hero.Controller).Attacker.Health > 0)
			{
				SetAttacker(PersonController(Hero.Controller).Attacker);
				GotoStateSave('AttackTarget');
				return;
			}
			// If the player has a live enemy, go after them
			else if(P2Player(Hero.Controller) != None
					&& FPSPawn(P2Player(Hero.Controller).Enemy) != None
					&& !FPSPawn(P2Player(Hero.Controller).Enemy).bPlayerIsFriend
					&& P2Player(Hero.Controller).Enemy.Health > 0)
			{
				SetAttacker(FPSPawn(P2Player(Hero.Controller).Enemy));
				GotoStateSave('AttackTarget');
				return;
			}
		}
		// If another dog friend of our hero is attacking someone, go help them
		// As long as he's not attacking the player, or a friend
		if(P2Player(Hero.Controller) != None
			&& P2Player(Hero.Controller).IsAnimalFriend(CreatorPawn)
			&& AnimalController(CreatorPawn.Controller) != None
			&& AnimalController(CreatorPawn.Controller).Attacker != None
			&& AnimalController(CreatorPawn.Controller).Attacker != Hero
			&& !AnimalController(CreatorPawn.Controller).Attacker.bPlayerIsFriend)
		{
			SetAttacker(AnimalController(CreatorPawn.Controller).Attacker); 
			GotoStateSave('AttackTarget');
			return;
		}
	}

	DangerPos = blipLoc;

	if(dangerhere.default.bCreatorIsAttacker
		&& MyPawn.bGunCrazy
		&& dangerhere != class'AnimalAttackMarker'
		&& CreatorPawn != None)
	// If we're insane, go attack them just for making a bad noise
	{
		SetAttacker(CreatorPawn); 
		GotoStateSave('AttackTarget');
	}
	else if (CreatorPawn != None
		&& MyPawn.HateGangTag != ""
		&& CreatorPawn.Gang == MyPawn.HateGangTag)
	{
		// If we hate them, attack
		SetAttacker(P2Pawn(CreatorPawn)); 
		GotoStateSave('AttackTarget');
	}
	else
		BarkOrStare(CreatorPawn);

	StateChange=1;
	return;
}

///////////////////////////////////////////////////////////////////////////////
// Because animals are more simple, we can have a general 'startled' function
///////////////////////////////////////////////////////////////////////////////
function StartledBySomething(Pawn Meanie)
{
	if(Meanie != None)
		DangerPos = Meanie.Location;
		
	// If we hate them, attack
	if (Meanie != None
		&& MyPawn.HateGangTag != ""
		&& FPSPawn(Meanie).Gang == MyPawn.HateGangTag)
	{
		SetAttacker(P2Pawn(Meanie)); 
		GotoStateSave('AttackTarget');
	}
	else
		BarkOrStare(FPSPawn(Meanie));
}

///////////////////////////////////////////////////////////////////////////
// Something splashed him or something, so he may hiss, but might also run
///////////////////////////////////////////////////////////////////////////
function BarkOrStare(FPSPawn Other)
{
	Focus = Other;
	if(FRand() <= BARK_FREQ)
	{
		GotoStateSave('Barking');
	}
	else
	{
		GotoStateSave('Stare');
	}
}

///////////////////////////////////////////////////////////////////////////
// Piss is hitting me, decide what to do
///////////////////////////////////////////////////////////////////////////
function BodyJuiceSquirtedOnMe(P2Pawn Other, bool bPuke)
{
	if(Other != Hero)
	{
		SetAttacker(Other);
		GotoStateSave('AttackTarget');
	}
	else
		BarkOrStare(Other);
}

///////////////////////////////////////////////////////////////////////////
// Something annoying, but not really gross or life threatening
// has been done to me, so check to maybe notice
///////////////////////////////////////////////////////////////////////////
function InterestIsAnnoyingUs(Actor Other, bool bMild)
{
	if(FRand() < GROWL_FREQ
		|| (Hero == Other
			&& HeroLove > 0))
	{
		Focus = Other;
		GotoStateSave('Growling');
	}
	else if(P2Pawn(Other) != None) //ignore animals
	{
		SetAttacker(P2Pawn(Other));
		GotoStateSave('AttackTarget');
	}
}

///////////////////////////////////////////////////////////////////////////
// A bouncing, disembodied head/dead body just hit us, decide what to do
///////////////////////////////////////////////////////////////////////////
function GetHitByDeadThing(Actor DeadThing, FPSPawn KickerPawn)
{
	// Don't growl at/attack dead bodies
	// unless we don't have a hero (always growl at dead heads)
	if(Pawn(DeadThing) == None
		|| Hero == None)

	{
		if(FRand() < GROWL_FREQ
			|| AnimalPawn(KickerPawn) != None
			|| (Hero == KickerPawn
				&& HeroLove > 0))
		{
			Focus = KickerPawn;
			GotoStateSave('Growling');
		}
		else if(KickerPawn != None)
		{
			SetAttacker(KickerPawn);
			GotoStateSave('AttackTarget');
		}
	}
}

///////////////////////////////////////////////////////////////////////////
// Gas is hitting me, decide what to do
///////////////////////////////////////////////////////////////////////////
function GettingDousedInGas(P2Pawn Other)
{
	Super.GettingDousedInGas(Other);

	if(Other != Hero)
	{
		SetAttacker(Other);
		GotoStateSave('AttackTarget');
	}
	else
		BarkOrStare(Other);
}

///////////////////////////////////////////////////////////////////////////
// See if someone is close by
///////////////////////////////////////////////////////////////////////////
function P2Pawn CheckForPersonAroundMe(float RadCheck)
{
	local P2Pawn CheckP;

	// check all the pawns around me.
	ForEach VisibleCollidingActors(class'P2Pawn', CheckP, RadCheck, MyPawn.Location)
	{
		return CheckP;
	}

	return None;
}
/*
///////////////////////////////////////////////////////////////////////////
// See if someone is close by doing something scary like running
//
// Returns the closest nice person
// 
///////////////////////////////////////////////////////////////////////////
function P2Pawn CheckForScaryPerson(float RadCheck)
{
	local P2Pawn CheckP, PickMe;
	local float closest, dist;

	closest = RadCheck;

	// check all the pawns around me.
	ForEach VisibleCollidingActors(class'P2Pawn', CheckP, RadCheck, MyPawn.Location)
	{
		// Only check people not behind obstructions.
		if(FastTrace(MyPawn.Location, CheckP.Location))
		{
			dist = VSize(CheckP.Velocity);
			// If he's moving and not walking (so running) run away
			if(dist > ((CheckP.GroundSpeed)/2 + 1))
			{
				DangerPos = CheckP.Location;

				MyPawn.PlayScaredSound();

				BarkOrStare(CreatorPawn);

				return None;
			}
			// if not, then check how close the nice person is
			if(dist <= closest)
			{
				PickMe = CheckP;
			}
		}
	}

	// Say this person around me was nice
	return PickMe;
}
*/
///////////////////////////////////////////////////////////////////////////////
// Someone might have shouted get down, said hi, or asked for money.. see what to do
// Go to state to see if we care to get down after someone told us to
///////////////////////////////////////////////////////////////////////////////
function RespondToTalker(Pawn Talker, Pawn AttackingShouter, ETalk TalkType, out byte StateChange)
{
	switch(TalkType)
	{
		case TALK_getdown:
			// Run away when someone yells
			BarkOrStare(FPSPawn(Talker));
			StateChange=1;
		break;
		case TALK_askformoney:
			BarkOrStare(FPSPawn(Talker));
			StateChange=1;
		break;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Look for other cats around me
///////////////////////////////////////////////////////////////////////////////
function CheckForCatsAroundMe(float RadCheck)
{
	local AnimalPawn CheckP;
	local float closest, dist;
	local vector catbutt;

	closest = RadCheck;

	// check all the pawns around me.
	ForEach VisibleCollidingActors(class'AnimalPawn', CheckP, RadCheck, MyPawn.Location)
	{
		// Only check cats not behind obstructions.
		if(FastTrace(MyPawn.Location, CheckP.Location)
			&& CheckP != MyPawn)
		{
			dist = VSize(CheckP.Velocity);
			// If he's walking or not moving, walk over to him
			if(dist < (CheckP.WalkingPct*CheckP.GroundSpeed))
			{
/*				// if we get to one cat, decide to do it or not
				if(FRand() > SNIFF_BUTT_FREQ)
					return;

				if(AnimalController(CheckP.Controller).ReadyForASniff(MyPawn))
				{
					DangerPos = CheckP.Location;

					InterestPawn = CheckP;
					// Walk to behind the other cat's butt
					catbutt = CheckP.Location;
					catbutt = catbutt - (CheckP.CollisionRadius*2.0)*vector(CheckP.Rotation);
					//log(" cat loc "$CheckP.Location$" cat butt "$catbutt);
					SetEndPoint(catbutt, CheckP.CollisionRadius);
					SetNextState('DoButtSniffing');
					MyPawn.ChangeAnimation();
					GotoStateSave('WalkToCat');

					return;
				}
				*/
			}
		}
	}
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
	
	// Don't bother if we have no enemies
	usegang = MyPawn.HateGangTag;
	if (usegang == "")
		return;

	closest = RadCheck;

	// check all the pawns around me.
	ForEach VisibleCollidingActors(class'P2Pawn', CheckP, RadCheck, MyPawn.Location)
	{
		// Only check cats not behind obstructions.
		if(CheckP.Gang == usegang
			&& CheckP.Health > 0
			&& FastTrace(MyPawn.Location, CheckP.Location)
			&& CheckP != MyPawn)
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
		SetNextState('AttackTarget');
		StateChange = 1;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Send me flying
///////////////////////////////////////////////////////////////////////////////
function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, 
					   class<DamageType> damageType, vector Momentum)
{
	Super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, damageType, Momentum);
	// if he's up in the air, send him falling
	if(Momentum.z != 0)
		GotoStateSave('FallingFar');
} 

///////////////////////////////////////////////////////////////////////////////
// If bumped 
///////////////////////////////////////////////////////////////////////////////
event Bump(actor Other)
{
	Touch(Other);
}

///////////////////////////////////////////////////////////////////////////////
// If touched 
///////////////////////////////////////////////////////////////////////////////
event Touch(actor Other)
{
	local vector HitMomentum, HitLocation;
	local FPSPawn otherpawn;
	local P2Pawn ppawn;
	local float fcheck;
	local P2PowerupInv Copy;
	local FPSGameInfo checkg;
	local Texture usedskin;

	otherpawn = FPSPawn(Other);

	if(otherpawn != None
		&& otherpawn.Health > 0)
	{
		if(ProspectiveHero != otherpawn)
		{
			// If it's bigger than us or the same, only growl
			if(otherpawn.CollisionHeight >= MyPawn.CollisionHeight)
			{
				ppawn = P2Pawn(otherpawn);

				// If you bump a person without a weapon (you can sense
				// the fear) and they're already getting attacked, then attack them!
				if(ppawn != None
					&& !ppawn.bHasViolentWeapon
					&& PersonController(ppawn.Controller) != None
					&& PersonController(ppawn.Controller).Attacker != None)
				{
					SetAttacker(ppawn);
					GotoStateSave('AttackTarget');
				}
				// If your insane, then bump them just for bumping you
				else if(ppawn != None
					&& MyPawn.bGunCrazy)
				{
					SetAttacker(ppawn);
					GotoStateSave('AttackTarget');
				}
				else if(Hero == otherpawn
						&& HeroLove > 0)
				{
					BarkOrStare(otherpawn);
				}
				else if(Hero == None)	
					// only stop to growl if we don't
					// have a hero to catch up with
				{
					// If you bump your attacker, go after him
					if(Attacker == otherpawn
						&& otherpawn.Health > 0)
					{
						GotoStateSave('AttackTarget');
					}
					// If we're running to grab something, or
					// have an attacker, don't stop to growl.
					else if(PreviousActor == None
						&& Attacker == None)
					{
						Focus = otherpawn;
						GotoStateSave('Growling');
					}
				}
			}
			// If we're running to grab something, or
			// have an attacker, don't stop to growl.
			else if(PreviousActor == None
				&& Attacker == None)
			{
				SetAttacker(otherpawn);
				GotoStateSave('AttackTarget');
			}
		}
	}
	else if(Mover(Other) != None)	
		// if it's a thing that can move like a mover smashing me, run
	{
		// If you have a hero, run to him
		if(Hero != None
			&& HeroLove > 0)
		{
			if(!IsInState('RunToHero'))
			{
				SetEndGoal(Hero, (DEFAULT_END_RADIUS + FRand()*HERO_END_RADIUS));
				if(MyNextState == '')
					SetNextState('DisperseAroundHero');
				GotoStateSave('RunToHero');
			}
		}
		else
		{
			DangerPos = Other.Location;
			if(MyNextState == '')
				SetNextState('Thinking');
			GotoStateSave('RunAwayFromBumper');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// An animal caller is trying to get you to come to it
// Dogs that have you as their enemy will go after food only, and then keep
// attacking you. Eventually, however you can win them over.
///////////////////////////////////////////////////////////////////////////////
function RespondToAnimalCaller(FPSPawn Thrower, Actor Other, out byte StateChange)
{
	// Bother hero will clear the hero on exit anyway, so do it now, so the hero 
	// will be cleared, but we'll pick up the Thrower as a new ProspectiveHero
	// and rehook him properly.
	if(HeroLove <= 0
		&& IsInState('BotherHero'))
		UnHookHero();

	// If our hero is throwing us something, or if we don't have a hero, go
	// after it
	if(Thrower != None
		&& (Hero == Thrower
			|| Hero == None)
		&& (Attacker == None
			|| Attacker == Thrower))
	{
		// If we're attacking the thrower, then only go after food
		if(Attacker != Thrower
			|| (P2PowerupPickup(Other) != None
				&& P2PowerupPickup(Other).bEdible))
		{
			StateChange=1;
			
			//log(self@"interested in food",'Debug');

			InterestPawn = Thrower;

			// If we don't have a hero yet, mark this guy as someone we could make
			// as our hero
			if(Hero == None)
			{
				// Don't let others take the players prospective status, if he has any
				if(Thrower.bPlayer)
				{
					if(ProspectiveHero != Thrower)
					{
						ProspectiveHero = Thrower;
					}
				}
				else if(ProspectiveHero == None)
				{
					ProspectiveHero = Thrower;
				}
				//log(self@"no hero yet - prospective hero"@ProspectiveHero,'Debug');
			}

			PreviousActor = Other;
			SetEndGoal(Other, DEFAULT_END_RADIUS);
			SetNextState('GrabPickup');
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			// Bark on the way to running to grab it for your new possible hero
			MyPawn.PlayHappySound();
			GotoStateSave('RunToTarget');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// You're getting electricuted
///////////////////////////////////////////////////////////////////////////////
function GetShocked(P2Pawn Doer, vector HitLocation)
{
	if(MyPawn.Physics == PHYS_WALKING)
	{
		if(Doer != Hero)
			SetAttacker(Doer);

		MakeShockerSteam(HitLocation, ANIMAL_BONE_PELVIS);

		GotoState('BeingShocked');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set our new hero
///////////////////////////////////////////////////////////////////////////////
function HookHero(FPSPawn NewHero, optional out byte Worked)
{
	local float diffoffset;
	
	//log("attempting to hook hero current hero"@Hero@"new hero"@NewHero,'Debug');
	
	// Fail if untrainable.
	if (MyPawn.bCannotTrain)
	{
		Worked = 0;
		return;
	}

	if(NewHero != Hero)
	{
		Super.HookHero(NewHero);

		if(NewHero == Hero)
		{
			// If our attacker is also our hero (happens if we're attacking the dude
			// and he throws out food) then set love of him in the negative. We'll
			// continue to attack, but eventually he can win us over.
			if(Attacker == NewHero)
				HeroLove = ATTACKER_START_LOVE;
			else
			{
				HeroLove = 0;
			}
			//log("hooking new hero"@NewHero@"love is"@HeroLove,'Debug');

			// If we have a hero, don't let us be travelled between levels (if
			// our hero is the player, he'll specifically travel us himself)
			MyPawn.bCanTeleportWithPlayer=false;

			// Automatically set full love for an NPC and a dog
			if(!NewHero.bPlayer)
				ChangeHeroLove(HERO_LOVE_MAX, 0);
			else // Dogs going with player
			{
				diffoffset = P2GameInfo(Level.Game).GetDifficultyOffset()*DOG_DAMAGE_DIFF_RATIO;
				// Dogs with player heroes take less damage for any attack
				MyPawn.TakeDamageModifier = PLAYER_DOG_DAMAGE_REDUCTION - diffoffset;
				if(MyPawn.TakeDamageModifier <= MIN_DAMAGE_REDUCTION)
					MyPawn.TakeDamageModifier = MIN_DAMAGE_REDUCTION;
				// Don't let dogs be removed for movies
				MyPawn.bKeepForMovie=true;
			}

			Worked=1;
		}
	}

	ProspectiveHero = None;
}

///////////////////////////////////////////////////////////////////////////////
// Unset the current hero
///////////////////////////////////////////////////////////////////////////////
function UnhookHero()
{
	if(Hero != None
		&& Hero.bPlayer)
		MyPawn.TakeDamageModifier = 1.0;	// Normal damage returned.

	Super.UnhookHero();

	MyPawn.bCanTeleportWithPlayer=true;
	MyPawn.bKeepForMovie=false;

	HeroLove = 0;
	CrapCount=0;
}

///////////////////////////////////////////////////////////////////////////////
// Get closer to our hero
///////////////////////////////////////////////////////////////////////////////
function GoToHero(optional bool bPlayerOnly, optional out byte StateChange)
{
	local float dist, vel;

	if(Hero == None
		|| HeroLove < 0)
		return;

	if(bPlayerOnly
		&& !Hero.bPlayer)
		return;

	// We're done loving him, so tell him
	if(bBotherHeroForLove)
	{
		bBotherHeroForLove=false;
		GotoStateSave('BotherHero');
		StateChange=1;
		return;
	}

	if(IsInState('LegMotionToTarget'))
		bPreserveMotionValues=true;

	SetNextState('DisperseAroundHero');

	dist = VSize(Hero.Location - MyPawn.Location);

	if(dist < HANG_AROUND_HERO)
	{
//		vel = VSize(Hero.Velocity);
//		// If he's stopped, then stop with him
//		if(vel == 0)
//		{
			if(!IsInState('LegMotionToTarget')
				&& !IsInState('Standing')
				&& !IsInState('Sitting'))
			{
				StateChange=1;
				GotoStateSave('Thinking', 'HangAround');
				return;
			}
/*		}
		else	// If he's still moving around, then keep up
		{
			StateChange=1;
			SetEndGoal(Hero, (DEFAULT_END_RADIUS + FRand()*HERO_END_RADIUS));
			if(bRunToHero)
			{
				GotoStateSave('TrotToHero');
			}
			else // run to catch up
			{
				GotoStateSave('RunToHero');
			}
		}
		*/
	}
	else
	{
		switch(Catchup)
		{
			case DOGM_Run:
				if(!IsInState('RunToHero'))
				{
					StateChange=1;
					SetEndGoal(Hero, (DEFAULT_END_RADIUS + FRand()*HERO_END_RADIUS));
					GotoStateSave('RunToHero');
				}
			break;
			case DOGM_Trot:
				if(!IsInState('TrotToHero'))
				{
					StateChange=1;
					SetEndGoal(Hero, (DEFAULT_END_RADIUS + FRand()*HERO_END_RADIUS));
					GotoStateSave('TrotToHero');
				}
			break;
			case DOGM_Walk:
				if(!IsInState('WalkToHero'))
				{
					StateChange=1;
					SetEndGoal(Hero, (DEFAULT_END_RADIUS + FRand()*HERO_END_RADIUS));
					GotoStateSave('WalkToHero');
				}
			break;
		}
	}
	/*
	if(dist < HANG_AROUND_HERO)
	{
		vel = VSize(Hero.Velocity);
		// If he's stopped, then stop with him
		if(vel == 0)
		{
			if(!IsInState('LegMotionToTarget')
				&& !IsInState('Standing')
				&& !IsInState('Sitting'))
			{
				StateChange=1;
				GotoState('Thinking', 'HangAround');
				return;
			}
		}
		else	// If he's still moving around, then keep up
		{
			StateChange=1;
			SetEndGoal(Hero, (DEFAULT_END_RADIUS + FRand()*HERO_END_RADIUS));
			if(vel <= Hero.WalkingPct*Hero.GroundSpeed)
			{
				GotoStateSave('TrotToHero');
			}
			else // run to catch up
			{
				GotoStateSave('RunToHero');
			}
		}
	}
	else
	{
		StateChange=1;
		SetEndGoal(Hero, (DEFAULT_END_RADIUS + FRand()*HERO_END_RADIUS));
		if(dist < WalkToHeroRadius) // walk if he's too far away
		{
			GotoStateSave('WalkToHero');
		}
		else if(dist < TrotToHeroRadius) // trot if he's too far away
		{
			GotoStateSave('TrotToHero');
		}
		else // run to catch up
		{
			GotoStateSave('RunToHero');
		}
	}
	*/
}

///////////////////////////////////////////////////////////////////////////////
// Unhook us from our hero
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	UnhookHero();

	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Take a crap after eating something
///////////////////////////////////////////////////////////////////////////////
function CheckToTakeCrap()
{
	//STUB--handled in legmotion functions
}
///////////////////////////////////////////////////////////////////////////////
// Take a crap after eating something--only do it when not seen
///////////////////////////////////////////////////////////////////////////////
function CheckToTakeCrapBase()
{
	local float usedot;

	usedot = vector(Hero.Rotation) dot Normal(Hero.Location - MyPawn.Location);

	if(CrapCount > 0
		&& usedot > 0)
		GotoStateSave('TakeCrap');
}

///////////////////////////////////////////////////////////////////////////////
// How much love to add--also start the timer again
///////////////////////////////////////////////////////////////////////////////
function ChangeHeroLove(int loveinc, int timeseg)
{
	local int OldLove;
	local MoveType OldType;

	// Can only change love if it's not at max
	if(HeroLove != HERO_LOVE_MAX)
	{
		OldLove = HeroLove;
		OldType = Catchup;
		HeroLove += loveinc;

		// If our hero is our attacker, and we used to have negative love, but have finally
		// crossed over, then unset him as the attacker.
		if(OldLove < 0
			&& HeroLove >= 0
			&& Attacker == Hero)
		{
			SetAttacker(None);
			PlayerAttackedMe = None;
		}
		//log("hero love +"$LoveInc@"new love"@HeroLove,'Debug');

		// We don't love him anymore, so when we go back to thinking, tell the hero
		// Only if we're not actively attacking him
		if(HeroLove <= 0)
		{
			if(Attacker != Hero)
				bBotherHeroForLove=true;
		}
		else // we still love him, so set our chase rates based on how much we love him
		{
			// Kamek 4-22 unlock dog lover achievement
			//log(self@"test dog achievement hero love"@HeroLove,'Debug');
			if (HeroLove > 0)
			{
				if( Level.NetMode != NM_DedicatedServer )  PlayerController(Hero.Controller).GetEntryLevel().EvaluateAchievement(PlayerController(Hero.Controller), 'DogHelper');
			}

			// If he gave us something, be excited for a moment
			if(loveinc > 0)
			{
				// Run for a bit, then immediately revert to our interest level
				Catchup = DOGM_Run;
				// Clear the bother, if we played with me somehow
				bBotherHeroForLove=false;
			}
			else if(HeroLove <= HERO_LOVE_WALK)
				Catchup = DOGM_Walk;
			else if(HeroLove <= HERO_LOVE_TROT)
				Catchup = DOGM_Trot;
			else
				Catchup = DOGM_Run;
			
			// We loved him more and now we're about to love him less, so tell him
			if(Catchup < OldType)
				bBotherHeroForLove=true;

			if(HeroLove >= HERO_LOVE_MAX)
				HeroLove = HERO_LOVE_MAX;
			else // Continue to love him
				SetTimer(timeseg, false);
		}

		//log(MyPawn$" hero love "$HeroLove$" old love "$OldLove$" move type is "$Catchup);
	}
	else	// update timer for other things happening in Timer()
		SetTimer(timeseg, false);
}

///////////////////////////////////////////////////////////////////////////////
// A segment of hero love time has ended, check about changing our perception
// around the hero
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	ChangeHeroLove(-1, HERO_LOVE_SUB_TIME);

	// Check to take a crap
	CheckToTakeCrap();
}

///////////////////////////////////////////////////////////////////////////////
// I ate some food.. get healed, and love your hero
///////////////////////////////////////////////////////////////////////////////
function AteFood()
{
	local FoodCrumbs foodbits;
	local Actor useowner;

	ChangeHeroLove(HERO_LOVE_INC_FOOD, HERO_LOVE_START_TIME);

	// Give the food bits to the hero if we have one, so they aren't effected by
	// time dilation
	if(Hero != None)
		useowner = Hero;
	else
		useowner = MyPawn;

	foodbits = spawn(class'FoodCrumbs',useowner,,Location);
	MyPawn.AttachToBone(foodbits, MouthBone);

	MyPawn.Health = MyPawn.HealthMax;

	CrapCount++;
	if(CrapCount > 10)
		CrapCount=10;
}

///////////////////////////////////////////////////////////////////////////////
// My hero played catch with me, love him more
///////////////////////////////////////////////////////////////////////////////
function PlayedCatch()
{
	ChangeHeroLove(HERO_LOVE_INC_PLAY, HERO_LOVE_START_TIME);
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
// DisperseAroundHero
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DisperseAroundHero
{
	ignores BarkOrStare;

	///////////////////////////////////////////////////////////////////////////////
	// Try to pick a spot around the hero to hang around, so when we have multiple
	// dogs, we don't look so ugly
	///////////////////////////////////////////////////////////////////////////////
	function PickHeroSpot()
	{
		local vector checkpoint, dir;

		dir = DISPERSE_RADIUS*VRand();
		dir.z=0;
		checkpoint = MyPawn.Location + dir;
		GetMovePointOrHugWalls(checkpoint, MyPawn.Location, DISPERSE_RADIUS, true);
		SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
	}
Begin:
	PrintThisState();
	PickHeroSpot();
	SetNextState('Thinking');
	GotoStateSave('WalkToTarget');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Stand and look around
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Standing
{
	///////////////////////////////////////////////////////////////////////////////
	// Decide to go through this state again
	///////////////////////////////////////////////////////////////////////////////
	function bool StandAgain()
	{
		if((Hero != None
			&& HeroLove > 0
			&& VSize(Hero.Velocity) == 0)
			|| Hero == None)
			return (FRand() <= STAND_LOOP_FREQ);
		else
			return false;
	}

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
				if(statecount == 0)
					GotoState(GetStateName(), 'LookingAround');
				else if(statecount == 1)
					GotoState(GetStateName(), 'CheckToStandAgain');
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
		Focus = None;
		FocalPoint = MyPawn.Location + (1024*VRand());
	}

Begin:
	MyPawn.PlayAnimStanding();
	statecount=0;
	Goto('Waiting');

LookingAround:
	if(FRand() <= 0.5)
		MyPawn.PlayContentSound();
		
	CheckForEnemies(ENEMY_SEARCH_RADIUS);

	// sometimes sniff some
	if(FRand() <= SNIFF_FREQ)
	{
		MyPawn.PlayInvestigate();
		statecount=1;
		Goto('Waiting');
	}
	// Very rarely, decide to piss
	if(FRand() <= PISS_FREQ)
	{
		GotoStateSave('Pissing');
	}

CheckToStandAgain:
	// Sometimes stand again
	if(StandAgain())
		Goto('Begin');

	GotoStateSave('Thinking');

Waiting:
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Stand ready to run after hero
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state StandByHero extends Standing
{
	///////////////////////////////////////////////////////////////////////////////
	// Take a crap after eating something--only do it when not seen
	///////////////////////////////////////////////////////////////////////////////
	function CheckToTakeCrap()
	{
		CheckToTakeCrapBase();
	}

Begin:
	MyPawn.PlayAnimStanding();
	if(FRand() <= 0.5)
		MyPawn.PlayContentSound();
	statecount=0;
	Goto('Waiting');

LookingAround:

CheckToStandAgain:
	GotoStateSave('Thinking');

Waiting:
	Sleep((Frand()*0.5)+0.1);
	GoToHero(true);
	Goto('Waiting');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Ready to run by your hero, but you're whining with a hurt leg.. you need
// health
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state LimpByHero extends Standing
{
Begin:
	Focus = Hero;
	MyPawn.PlayAnimLimping();
	MyPawn.PlayScaredSound();
	statecount=0;
	Goto('Waiting');

LookingAround:

CheckToStandAgain:
	if(Frand() < LIMP_IF_HURT_FREQ)
	{
		statecount = 0;
		Goto('Begin');
	}
	else
		GotoStateSave('Thinking');

Waiting:
	Sleep((Frand()*0.5)+0.1);
	GoToHero(true);
	Goto('Waiting');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Stand and look around forever (until provoked)
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state HoldPosition extends Standing
{
	///////////////////////////////////////////////////////////////////////////////
	// Always go through this state again, if we have our druthers
	///////////////////////////////////////////////////////////////////////////////
	function bool StandAgain()
	{
		return true;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Look at this guy for a minute
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Stare extends Standing
{
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		//log("anim end "$channel$" state count "$statecount);
		// Check for the base channel only
		if(channel == 0)
		{
			GotoState('Thinking');
		}
	}

Begin:
	MyPawn.PlayAnimStanding();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Sit and look around
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Sitting
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
				if(statecount == 0)
					GotoState(GetStateName(), 'LoopSitting');
				else if(statecount == 1)
				{
					// Sometimes sit again
					if(FRand() <= SIT_LOOP_FREQ
						&& Hero == None)
						GotoState(GetStateName(), 'LoopSitting');
					else
						GotoState(GetStateName(), 'StandBackUp');
				}
				else
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
	MyPawn.PlaySitDown();
	statecount=0;
	Goto('Waiting');

LoopSitting:
	MyPawn.PlayContentSound();

	MyPawn.PlaySitting();
	statecount=1;
	Goto('Waiting');

StandBackUp:
	MyPawn.PlayStandUp();
	statecount=2;

Waiting:

}
/*
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Lay down and let them pet me, maybe
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state LetThemPetMe
{
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		//log("anim end "$channel$" state count "$statecount);
		// Check for the base channel only
		if(channel == 0)
		{
			if(statecount == 0)
				GotoState(GetStateName(), 'LoopLaying');
			else if(statecount == 1)
			{
				// Sometimes sit again
				if(FRand() <= LAY_LOOP_FREQ)
					GotoState(GetStateName(), 'LoopLaying');
				else
					GotoState(GetStateName(), 'GetBackUp');
			}
			else
			{
				MyPawn.ChangeAnimation();
				// Always walk somewhere after you just laid down, don't just sit and think
				SetEndGoal(FindRandomDest(), DEFAULT_END_RADIUS);
				SetNextState('Thinking');
				GotoStateSave('WalkToTarget');
			}
		}
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
	MyPawn.PlayLayDown();
	statecount=0;
	Goto('Waiting');

LoopLaying:
	// See if someone around me might scare me into running or something
	//CheckForScaryPerson(SCARY_PERSON_RAD);

	MyPawn.PlayLaying();
	statecount=1;
	Goto('Waiting');

	// Sometimes sit again
	if(FRand() <= LAY_LOOP_FREQ)
		Goto('LoopLaying');

GetBackUp:
	MyPawn.PlayGetBackUp();
	statecount=2;

Waiting:
}
*/
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Barking at interest
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Barking
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, BarkOrStare,
		StartledBySomething, GettingDousedInGas, RespondToTalker;

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		//log("anim end "$channel$" state count "$statecount);
		// Check for the base channel only
		if(channel == 0)
		{
			if(Frand() < 0.5)
				GotoState(GetStateName(), 'Begin');
			else if(MyNextState == '')
				GotoStateSave('Thinking');
			else
				GotoNextState();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		MyPawn.ChangeAnimation();
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop moving
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
	}

Begin:
	MyPawn.PlayAnimStanding();
	Sleep(Frand());
	MyPawn.PlayGetScared();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Barking at hero high up
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state HeroBarking extends Barking
{
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		//log("anim end "$channel$" state count "$statecount);
		// Check for the base channel only
		if(channel == 0)
		{
			if(MyNextState == '')
				GotoStateSave('Thinking');
			else
				GotoNextState();
		}
	}

Begin:
	MyPawn.PlayGetScared();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Bark at the hero to tell him you want love
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state BotherHero extends Barking
{
	function EndState()
	{
		Super.EndState();
		if(HeroLove <= 0)
			UnhookHero();
	}
	function BeginState()
	{
		Super.BeginState();
		Focus = Hero;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Growl at interest
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Growling extends Barking
{
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			if(MyNextState == '')
				GotoStateSave('Thinking');
			else
				GotoNextState();
		}
	}
Begin:
	MyPawn.PlayAnimStanding();
	Sleep(2*Frand());
	MyPawn.PlayGetAngered();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Growl at attacker high up
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state AttackerGrowling extends Growling
{
Begin:
	MyPawn.PlayGetAngered();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Pee on the ground
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Pissing
{
	///////////////////////////////////////////////////////////////////////////////
	// In the pissing state, say pissing is valid, only then
	///////////////////////////////////////////////////////////////////////////////
	function bool PissingValid()
	{
		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			GotoStateSave('Thinking');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Make sure to terminate the stream
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		MyPawn.ChangeAnimation();
		MyPawn.Notify_PissStop();
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
	MyPawn.ChangeAnimation();
	// modify the speed for faster and slower
	MyPawn.PlayPissing(0.5 + FRand()/2);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// TakeCrap, no real action, just leave a turd somewhere and catch back up
// to the player
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TakeCrap
{
	function LeaveTurd()
	{
		local AnimNotifyActor turd;
		local Rotator rot;
		local vector pos, HitLocation, HitNormal;
		local Actor HitActor;

		// pick a random area behind the dog
		pos = (VRand()*MyPawn.CollisionRadius*0.75) - (Normal(vector(MyPawn.Rotation))*MyPawn.CollisionRadius);
		pos.z=0;
		pos = pos + MyPawn.Location;
		pos.z-=(2*MyPawn.CollisionHeight);
		HitActor = Trace(HitLocation, HitNormal, pos, MyPawn.Location, true);
		if(HitActor != None
			&& HitActor.bStatic)
		{
			HitLocation.z+=2;
			turd = spawn(class'AnimNotifyActor',,,HitLocation);
			if(turd != None)
			{
				turd.SetDrawType(DT_StaticMesh);
				turd.SetStaticMesh(turdmesh);
				turd.SetDrawScale(1.0 + Frand()/4);
				turd.Lifespan=1000;
				rot = turd.Rotation;
				rot.Yaw += Rand(65535);
				turd.SetRotation(rot);
				CrapCount--;
			}
		}
	}
	function BeginState()
	{
		PrintThisState();
	}
Begin:
	MyPawn.StopAcc();
	// try to spawn turd where I am
	LeaveTurd();
	GotoHero();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToTarget
{
	ignores BarkOrStare;

	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		local byte StateChange;
		
		// Look for enemies
		CheckForEnemies(ENEMY_SEARCH_RADIUS, StateChange);

		//log(MyPawn$" interim after "$StateChange);
		if(StateChange == 0)
			Super.InterimChecks();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Move to the left or right, if we notice we're hung up, when we should be 
	// moving
	///////////////////////////////////////////////////////////////////////////////
	function DodgeThinWall()
	{
		local vector startdir, usevect;

		//log("dodge "$VSize(Pawn.Velocity));
		// If we're stopped or in the same spot.
		if(VSize(Pawn.Velocity) < MIN_VELOCITY_FOR_REAL_MOVEMENT)
		{
			LegMotionCaughtCount++;
			if(LegMotionCaughtCount > LEG_MOTION_CAUGHT_MAX)
				NextStateAfterGoal();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToHero
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToHero extends WalkToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// Take a crap after eating something--only do it when not seen
	///////////////////////////////////////////////////////////////////////////////
	function CheckToTakeCrap()
	{
		CheckToTakeCrapBase();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		local byte StateChange;
		
		// Look for enemies
		CheckForEnemies(ENEMY_SEARCH_RADIUS, StateChange);

		// Check if we need to speed up to catch our guy
		if (StateChange == 0)
			GotoHero(,StateChange);		

		//log(MyPawn$" interim after "$StateChange);
		if(StateChange == 0)
			Super.InterimChecks();
	}
	///////////////////////////////////////////////////////////////////////////////
	// If the SetActorTarget functions below can't find a proper path and end up
	// just setting the next move target as the destination itself, this function
	// will be called, so you can possibly exit your state and do something else instead.
	///////////////////////////////////////////////////////////////////////////////
	function CantFindPath(Actor Dest, optional vector DestPoint)
	{
		//GotoStateSave('WatchHeroHighUp');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// TrotToTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TrotToTarget extends WalkToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	//	clean up anims
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		MyPawn.SetToTrot(false);
	}
	///////////////////////////////////////////////////////////////////////////////
	//	Set up anims
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		MyPawn.SetToTrot(true);
	}
Begin:
	if(Pawn.Physics == PHYS_FALLING)
		WaitForLanding();
	else
	{
		if(MoveTarget != None)
			MoveTowardWithRadius(MoveTarget,Focus,UseEndRadius,MyPawn.TrottingPct);
		else //if(bMovePointValid)
			MoveToWithRadius(MovePoint,Focus,UseEndRadius,MyPawn.TrottingPct);
		InterimChecks();
		Sleep(0.0);
	}
	Goto('Begin');// run this state again
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// TrotToHero
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TrotToHero extends TrotToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// Take a crap after eating something--only do it when not seen
	///////////////////////////////////////////////////////////////////////////////
	function CheckToTakeCrap()
	{
		CheckToTakeCrapBase();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		local byte StateChange;

		// Look for enemies
		CheckForEnemies(ENEMY_SEARCH_RADIUS, StateChange);

		// Check if we need to speed up to catch our guy
		if (StateChange == 0)
			GotoHero(,StateChange);

		if(StateChange == 0)
			Super.InterimChecks();
	}
	///////////////////////////////////////////////////////////////////////////////
	// If the SetActorTarget functions below can't find a proper path and end up
	// just setting the next move target as the destination itself, this function
	// will be called, so you can possibly exit your state and do something else instead.
	///////////////////////////////////////////////////////////////////////////////
	function CantFindPath(Actor Dest, optional vector DestPoint)
	{
		//GotoStateSave('WatchHeroHighUp');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// TrotWithBone
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TrotWithBone extends TrotToTarget
{
	ignores RespondToAnimalCaller;

	///////////////////////////////////////////////////////////////////////////////
	//	No matter what, make sure to get rid of the bone in your mouth and
	// redrop the pickup
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		local vector useloc;
		local Actor DroppedBone;
		local Actor UseActor;
		local vector newvel;
		local bool bWorked;

		Super.EndState();

		if(MyBone != None)
		{
			useloc = MyBone.Location;
			MyBone.Destroy();
			MyBone = None;
			// Reset all saved values
			DroppedBone = PreviousActor;

			// Position it to fall now
			newvel.z = -200;
			if(PeoplePart(DroppedBone) != None)
			{
				PeoplePart(DroppedBone).GiveMomentum(newvel);
				DroppedBone.SetDrawScale(1.0);
			}
			else
			{
				DroppedBone.bHidden=false;
				DroppedBone.bStasis=false;
				DroppedBone.Instigator = MyPawn;
				DroppedBone.SetPhysics(PHYS_Falling);
				DroppedBone.Velocity = newvel;
			}

			// The item didn't place properly
			bWorked = DroppedBone.SetLocation(useloc);

			// We check to make sure the newly picked location makes sense.
			// It could have been a location from MyBone that didn't properly get
			// updatted by the animation code, so it thinks it's way far away
			if(!bWorked
				|| (VSize(DroppedBone.Location - MyPawn.Location) > DEFAULT_END_RADIUS + MyPawn.CollisionRadius))
			{
				// We have someone to give it to and it's a pickup, so just
				// stick it in him
				if(ProspectiveHero != None
					&& Pickup(DroppedBone) != None)
					UseActor = ProspectiveHero;
				else
					UseActor = MyPawn;
				//log(self$" putting bone in him "$UseActor);
				// Put it on top of the dog or in the dude.. we know this is safe
				if(!DroppedBone.SetLocation(UseActor.Location))
					log(self$" PUTTING THE DROPPED THING BACK didn't work----------------------!!!!!!!!!!!!!!!!!!!!!!!");
			}
			if(PeoplePart(DroppedBone) == None)
			{
				DroppedBone.bBlockZeroExtentTraces=DroppedBone.default.bBlockZeroExtentTraces;
 				DroppedBone.bBlockNonZeroExtentTraces=DroppedBone.default.bBlockNonZeroExtentTraces;
				DroppedBone.bCollideWorld=DroppedBone.default.bCollideWorld;
				DroppedBone.SetCollision(DroppedBone.default.bCollideActors, DroppedBone.default.bBlockActors, DroppedBone.default.bBlockPlayers);
			}
			else
			{
				PeoplePart(DroppedBone).SetupAfterDetach();
			}

			PreviousActor=None;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunToHero
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToHero extends RunToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// Take a crap after eating something--only do it when not seen
	///////////////////////////////////////////////////////////////////////////////
	function CheckToTakeCrap()
	{
		CheckToTakeCrapBase();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		local byte StateChange;

		// Look for enemies
		CheckForEnemies(ENEMY_SEARCH_RADIUS, StateChange);

		// Check if we need to speed up to catch our guy
		if (StateChange == 0)
			GotoHero(,StateChange);

		if(StateChange == 0)
			Super.InterimChecks();
	}
	///////////////////////////////////////////////////////////////////////////////
	// If the SetActorTarget functions below can't find a proper path and end up
	// just setting the next move target as the destination itself, this function
	// will be called, so you can possibly exit your state and do something else instead.
	///////////////////////////////////////////////////////////////////////////////
	function CantFindPath(Actor Dest, optional vector DestPoint)
	{
		//GotoStateSave('WatchHeroHighUp');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// GrabPickup
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GrabPickup
{
	ignores RespondToAnimalCaller;

	///////////////////////////////////////////////////////////////////////////////
	// Check for a pickup nearest you, and grab it. If none, go back to thinking
	///////////////////////////////////////////////////////////////////////////////
	function FindPickup(bool PickItUp)
	{
		local Actor CheckP, UseP;
		local float dist, keepdist;
		local Rotator rel;
		local byte Worked;
		local int i;

		dist = 65536;
		keepdist = dist;

		// check all the actors around me.
		foreach CollidingActors(class'Actor', CheckP, DEFAULT_END_RADIUS+MyPawn.CollisionRadius, MyPawn.Location)
		{
			if(CheckP == PreviousActor)
			{
				UseP = CheckP;
				break;
			}
			// Only pick up heads and pickups
			else if((P2PowerupPickup(CheckP) != None
					|| P2WeaponPickup(CheckP) != None
					|| BodyPart(CheckP) != None)
				&& !CheckP.bStatic
				&& !CheckP.bHidden)
			{
				// find the closest one to us
				dist = VSize(CheckP.Location - MyPawn.Location);
				if(dist < keepdist)
				{
					keepdist = dist;
					UseP = CheckP;
				}
			}
		}
		// If you find one, go for it
		if(UseP != None)
		{
			Focus = UseP;

			// Actually grab it in your mouth now
			if(PickItUp)
			{
				//log("Attempt to hook prospective hero"@ProspectiveHero,'Debug');
				// We enjoyed that so start loving this guy
				HookHero(ProspectiveHero, Worked);

				// If you started training a new dog (or even an old one but
				// as long as he's not currently you're friend) then record it
				if(Worked == 1)
				{
					if(P2GameInfoSingle(Level.Game) != None
						&& P2GameInfoSingle(Level.Game).TheGameState != None)
					{
						P2GameInfoSingle(Level.Game).TheGameState.DogsTrained++;
					}
				}

				// If you throw out something edible.. he'll eat it! Not retrieve it
				if(P2PowerupPickup(Focus) != None
					&& P2PowerupPickup(Focus).bEdible)
				{
					AteFood();
					FocalPoint = Focus.Location;
					Focus.Destroy();
					Focus = None;
					GotoState('GrabPickup', 'AtePickup');
				}
				else	// Anything else, he brings back to you and drops it at your feet.
				{
					PlayedCatch();
					// If it's a head, give them an achievement for doing it
					if (Focus.IsA('Head')
						&& PlayerController(Hero.Controller) != None)
						{
							if( Level.NetMode != NM_DedicatedServer ) PlayerController(Hero.Controller).GetEntryLevel().EvaluateAchievement(PlayerController(Hero.Controller),'HeadFetch');
						}
						
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
					// Save the pickup class, then destroy it
					PreviousActor=Focus;
					if(PeoplePart(PreviousActor) != None)
						PreviousActor.SetDrawScale(0.001);
					else
						PreviousActor.bHidden=true;
					PreviousActor.GotoState('');
					// Blank out all collision on the thing we left hidden, behind
					// We'll reset it when he drops it again
					PreviousActor.bBlockZeroExtentTraces=false;
 					PreviousActor.bBlockNonZeroExtentTraces=false;
					PreviousActor.bCollideWorld=false;
					PreviousActor.SetCollision(false, false, false);
					Focus = None;
				}
			}
		}
		else	// default to thinking when you can find anything
		{
			GotoState('Thinking');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check for a pickup nearest you, and grab it. If none, go back to thinking
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		FindPickup(false);
	}

AtePickup:
	MyPawn.PlayGrabPickupOnGround();
	MyPawn.PlayHappySound();
	Sleep(0.3);
	MyPawn.ChangeAnimation();
	// If the new hero is also (currently) our attacker, then go back to attacking
	// him, otherwise, be ready to play again with him
	if(Attacker != None)
		GotoStateSave('AttackTarget');
	else
		GotoStateSave('WaitForNewThrow');

Begin:
	MyPawn.PlayGrabPickupOnGround();
	Sleep(0.2);
	MyPawn.ChangeAnimation();
	// See if we can still get it
	FindPickup(true);
	// Now go back to the guy who threw it
	SetEndGoal(InterestPawn, PAWN_END_RADIUS);
	SetNextState('PrepAfterThrow');
	if(IsInState('LegMotionToTarget'))
		bPreserveMotionValues=true;
	GotoStateSave('TrotWithBone');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PrepAfterThrow
// He's just walked over and dropped something at your feet, so make him 
// back away from it and then jump around to play some
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PrepAfterThrow
{
	///////////////////////////////////////////////////////////////////////////////
	// Move forward of the dude, and stand around, ready to play
	///////////////////////////////////////////////////////////////////////////////
	function MoveAway()
	{
		local vector pt;

		pt = InterestPawn.Location + Normal(vector(InterestPawn.Rotation))*CATCH_AGAIN;

		GetMovePointOrHugWalls(pt, MyPawn.Location, CATCH_AGAIN, true);

		SetEndPoint(pt, DEFAULT_END_RADIUS);
		SetNextState('WaitForNewThrow');
		GotoStateSave('TrotToTarget');
	}
	function BeginState()
	{
		PrintThisState();
	}
Begin:
	MoveAway();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WaitForNewThrow
// Our hero/prospective hero has played a game of catch with us. Wait for 
// a while for him to do it again
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitForNewThrow
{
	///////////////////////////////////////////////////////////////////////////////
	// If our hero isn't close enough, or can't be seen, forget this stuff and
	// just chase after him
	///////////////////////////////////////////////////////////////////////////////
	function CheckForNearHero(optional out byte StateChange)
	{
		if(Hero != None
			&& (VSize(MyPawn.Location - Hero.Location) > 2*HANG_AROUND_HERO
				|| !FastTrace(MyPawn.Location , Hero.Location)))
			GotoHero(,StateChange);
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		local byte StateChange;

		MyPawn.AnimEnd(channel);

		if(channel == 0)
		{
			CheckForNearHero(StateChange);

			if(StateChange == 0)
			{
				if(statecount > CurrentFloat)
					GotoState('WaitForNewThrow', 'BoredNow');
				else
				{
					GotoState('WaitForNewThrow', 'BarkingNow');
				}
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		MyPawn.ChangeAnimation();
	}

	function BeginState()
	{
		PrintThisState();
		Focus = InterestPawn;
		statecount = 0;
		CurrentFloat = Rand(BORED_OF_THROW_MAX) + 1.0;
	}

BoredNow:
	MyPawn.PlayAnimStanding();
	MyPawn.PlayContentSound();
	Sleep(2.0);
	GotoStateSave('Thinking');

BarkingNow:
	MyPawn.PlayGetScared();
	statecount++;
	Sleep(Frand() + 0.8);

Begin:
	MyPawn.PlayJump();
	Sleep(1.0);
	CheckForNearHero();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunToAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToAttacker extends RunToTarget
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas,
		StartledBySomething, GetReadyToReactToDanger, RespondToTalker, StartAttacking;

	///////////////////////////////////////////////////////////////////////////////
	// If you touch the attacker, go into a shredding anim to hurt him
	///////////////////////////////////////////////////////////////////////////////
	event Touch(actor Other)
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
	///////////////////////////////////////////////////////////////////////////////
	// Short circuit and just attack like a wild man.. or.. dog.. anyway.
	///////////////////////////////////////////////////////////////////////////////
	function CantFindPath(Actor Dest, optional vector DestPoint)
	{
		//GotoStateSave('AttackTarget');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunToPounce
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToPounce extends RunToAttacker
{
	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after you got hung up on something
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterHangUp()
	{
		// Make them give up after getting hung up too often. Useful for dogs locked up
		// in a kennel that can't get out, etc
		// However, don't give up if the attacker is still close by
		if (VSize(Attacker.Location - MyPawn.Location) > POUNCE_DEST_DIST)
			GiveUpCount++;
		if (GiveUpCount >= MAX_GIVE_UP_COUNT)
		{
			// Give up and go back to thinking.
			SetAttacker(None);
			PlayerAttackedMe = None;
			GotoStateSave('Thinking');
		}
		else
		{
			// Default to just going to the next state
			NextStateAfterGoal();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after this
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterGoal()
	{
		local vector DestPoint;

		// Don't stop, go to the next state, and calculate the point just past your
		// target
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
			GotoNextState();
			SetNextState('AttackTarget');
		}
		else
		{
			SetEndGoal(Attacker, TIGHT_END_RADIUS);
			GotoState('RunToAttacker');
			SetNextState('AttackTarget');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunningScared
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunningScared extends RunToTarget
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas, 
		StartledBySomething, GetReadyToReactToDanger, RespondToTalker, Touch;

	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after this
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterGoal()
	{
		FPSPawn(Pawn).StopAcc();
		if(Attacker != None
			&& Attacker != Hero
			&& Attacker.Health > 0)
			GotoStateSave('AttackTarget');
		else
			//log(Pawn$" NextStateAfterGoal goal was "$MoveTarget$" move point "$MovePoint);
			GotoState(MyNextState, MyNextLabel);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Move to the left or right, if we notice we're hung up, when we should be 
	// moving
	///////////////////////////////////////////////////////////////////////////////
	function DodgeThinWall()
	{
		local vector startdir, usevect;

		//log("dodge "$VSize(Pawn.Velocity));
		// If we're stopped or in the same spot.
		if(VSize(Pawn.Velocity) < MIN_VELOCITY_FOR_REAL_MOVEMENT)
		{
			LegMotionCaughtCount++;
			if(LegMotionCaughtCount > LEG_MOTION_CAUGHT_MAX)
				NextStateAfterGoal();
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Play my scared running
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		MyPawn.PlayScaredSound();
		Super.BeginState();
		MyPawn.SetAnimRunningScared();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Start playing our normal run cycle again
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		if(MyPawn.Health > 0.0)
			MyPawn.SetAnimRunning();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunAway
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunAway extends Thinking
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas, 
		StartledBySomething, GetReadyToReactToDanger, RespondToTalker;

	///////////////////////////////////////////////////////////////////////////////
	// Collide this way and search for the distance most closely matching our
	// desired distance.
	///////////////////////////////////////////////////////////////////////////////
	function TryThisDirection()
	{
		local vector checkpoint;
		local Actor HitActor;
		local vector HitLocation, HitNormal;

		// Try to make dir fit terrain
		checkpoint = EndGoal.Location;//MyPawn.Location + (CurrentDist*InterestVect);

		GetMovePointOrHugWalls(checkpoint, MyPawn.Location, 2048, true);

		SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
	}

	///////////////////////////////////////////////////////////////////////////////
	// come back to this state again
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.SetAnimRunning();
		SetNextState('Thinking');
	}
Begin:
	Sleep(0.1);
	if(!PickRandomDest())
		// Didn't find a valid point, so get nearest
	{
		UseNearestPathNode(2048);
	}

	GotoStateSave('RunningScared');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunAwayFromBumper
// Something has bumped me so run directly away from it, a short distance
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunAwayFromBumper extends RunAway
{
	///////////////////////////////////////////////////////////////////////////////
	// Collide this way and search for the distance most closely matching our
	// desired distance.
	///////////////////////////////////////////////////////////////////////////////
	function TryThisDirection()
	{
		local vector checkpoint, dir;
		local Actor HitActor;
		local vector HitLocation, HitNormal;

		// pick direction away from bumper
		dir = MyPawn.Location - DangerPos;
		512*Normal(dir);

		// Try to make dir fit terrain
		checkpoint = 512*Normal(dir) + MyPawn.Location;

		GetMovePointOrHugWalls(checkpoint, MyPawn.Location, 512, true);

		SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
	}

Begin:
	Sleep(0.1);
	TryThisDirection();
	GotoStateSave('RunningScared');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Running around on fire
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunOnFire extends RunToTarget
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas, 
		RespondToTalker, ForceGetDown, 
		MarkerIsHere, damageAttitudeTo, CatchOnFire, CheckForObstacles, Touch,
		StartledBySomething, GetShocked, RespondToAnimalCaller, InvestigatePrey, ReadyForASniff, Trigger;

	///////////////////////////////////////////////////////////////////////////////
	// Things to do while you're in locomotion
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		Super.InterimChecks();
		statecount++;
		if(statecount == 2)
		{
			//Say(MyPawn.myDialog.lScreaming);
			statecount=0;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Handle scared flag
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		//Say(MyPawn.myDialog.lScreaming);
		statecount=0;
		MyPawn.SetAnimRunningScared();
		MyPawn.PlayScaredSound();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Start playing our normal run cycle again
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		if(MyPawn.Health > 0.0)
			MyPawn.SetAnimRunning();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ImOnFire
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ImOnFire
{
	ignores CatchOnFire, GettingDousedInGas, Touch, 
		MarkerIsHere, damageAttitudeTo, StartledBySomething, GetReadyToReactToDanger, 
		InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, RespondToTalker, GetShocked,
		RespondToAnimalCaller, InvestigatePrey, ReadyForASniff, Trigger;
	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////
	function CheckToReturnToNormal()
	{
		if(MyPawn.MyBodyFire == None
			|| MyPawn.MyBodyFire.bDeleteMe)
		{
			MyPawn.MyBodyFire = None;

			if(Attacker == None)
				SetAttacker(InterestPawn);

			DangerPos = MyPawn.Location;
			UseSafeRangeMin = 2*MyPawn.SafeRangeMin;
			GotoStateSave('Thinking');
		}
	}

	///////////////////////////////////////////////////////////////////////////
	// Pick a random spot not through a wall
	///////////////////////////////////////////////////////////////////////////
	function PickNextDest()
	{
		local Actor HitActor;
		local vector HitLocation, HitNormal, checkpoint;

		checkpoint = MyPawn.Location;
		checkpoint.x+=(FRand()*1024) - 512;
		checkpoint.y+=(FRand()*1024) - 512;

		// check for walls
		GetMovePointOrHugWalls(checkpoint, MyPawn.Location, FRand()*512 + 512, true);

		SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
	}

	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
	}

Begin:
	CheckToReturnToNormal();

	SetNextState('ImOnFire');

	PickNextDest();

	GotoStateSave('RunOnFire');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Falling through the air (probably thrown)
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FallingFar
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, RespondToTalker, ForceGetDown, 
		MarkerIsHere, damageAttitudeTo, CheckForObstacles, Touch, RespondToAnimalCaller, InvestigatePrey, 
		ReadyForASniff, Trigger;

	///////////////////////////////////////////////////////////////////////////////
	// I've fallen to the ground
	///////////////////////////////////////////////////////////////////////////////
	function bool NotifyLanded(vector HitNormal)
	{
		MyPawn.SetAnimWalking();

		GotoStateSave('RunAway');

		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Make us flail our legs
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		MyPawn.SetPhysics(PHYS_FALLING);

		MyPawn.PlayThrownSound();

		MyPawn.PlayFalling();
	}
Begin:
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Shake a lot and then maybe pee or something
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state BeingShocked
{
	ignores InterestIsAnnoyingUs, GetHitByDeadThing, BodyJuiceSquirtedOnMe, GettingDousedInGas, RespondToTalker, ForceGetDown, 
		MarkerIsHere, damageAttitudeTo, CatchOnFire, CheckForObstacles, Touch,
		StartledBySomething, RespondToAnimalCaller, InvestigatePrey, ReadyForASniff, Trigger;

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function EndingGettingShocked()
	{
		MyPawn.ChangeAnimation();

		InterestPawn = Attacker;

		GotoStateSave('RunAway');
	}
/*
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			EndingGettingShocked();
		}
	}
*/
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.ShouldCrouch(false);
	}

Begin:
	if(Focus != None)
		FocalPoint = Focus.Location;
	Focus = None;	// stop looking around or rotating
	MyPawn.StopAcc();
	MyPawn.PlayShockedAnim();
	Sleep(1.0);
	EndingGettingShocked();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Jump on this guy and hurt him
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PounceOnTarget extends RunToAttacker
{
	ignores NextStateAfterGoal, CantFindPath;

	///////////////////////////////////////////////////////////////////////////////
	// If touched by normal people run, otherwise, jump in the player's inventory
	///////////////////////////////////////////////////////////////////////////////
	event Touch(actor Other)
	{
		local FPSPawn otherpawn;
		local vector hitpos, dir;

		otherpawn = FPSPawn(Other);

		if(otherpawn != None
			&& otherpawn.Health > 0
			&& otherpawn == Attacker
			&& !bHurtTarget)
		{
			bHurtTarget=true;
			GiveUpCount = 0;	// Reset our give-up count if we successfully hurt something.
			// give it an extra boost
			dir = Normal(Other.Location - MyPawn.Location) + VRand();
			hitpos = Other.Location - Other.CollisionRadius*dir;
			otherpawn.TakeDamage(PounceDamage, MyPawn, hitpos, HIT_MOMENTUM*dir, AttackDamageType);
			MakePeopleScared(class'AnimalAttackMarker');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		// Check for the base channel only
		if(channel == 0)
		{
			GotoStateSave('AttackTarget');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Play pounce anim
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		// He pounces in this anim
		MyPawn.PlayAttack2();
		bHurtTarget=false;
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		bHurtTarget=false;
		MyPawn.ChangeAnimation();
		// Take him back to normal speed
		MyPawn.GroundSpeed = MyPawn.default.GroundSpeed;
	}
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
	event Touch(actor Other)
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
					// Sometimes piss on the body, sometimes just go back to thinking
					if(FRand() <= PISS_FREQ)
					{
						SetNextState('Pissing');
						SetEndPoint(Attacker.Location, DEFAULT_END_RADIUS);
						SetAttacker(None);
						GotoStateSave('WalkToTarget');
					}
					else
					{
						GotoStateSave('Thinking');
					}
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
	// Make the randomly jump at you, some farther away than others
	SetEndGoal(Attacker, POUNCE_DIST + (2*FRand()*POUNCE_DIST));
	GotoStateSave('RunToPounce');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Wrestling the thing back and forth, hurting it
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShredAttack extends AttackTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// If touched by normal people run, otherwise, jump in the player's inventory
	///////////////////////////////////////////////////////////////////////////////
	event Touch(actor Other)
	{
		local FPSPawn otherpawn;
		local vector hitpos, dir;

		otherpawn = FPSPawn(Other);

		if(otherpawn != None
//			&& otherpawn.Health > 0
			&& otherpawn == Attacker
			&& !bHurtTarget)
		{
			bHurtTarget=true;
			GiveUpCount = 0;	// Reset our give-up count if we successfully hurt something.
			dir = Normal(Other.Location - MyPawn.Location);
			hitpos = Other.Location - Other.CollisionRadius*dir;
			otherpawn.TakeDamage(PounceDamage, MyPawn, hitpos, HIT_MOMENTUM*VRand(), AttackDamageType);
			MakePeopleScared(class'AnimalAttackMarker');
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
				&& Attacker.CollisionHeight <= MyPawn.CollisionHeight)
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
			else if(Attacker.Health > 0
				|| FRand() > ATTACK_DEAD)
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
		// Make it so you sort of hurt/shake people as their are dead.
		if(P2Pawn(Attacker) != None
			&& Attacker.Health <= 0
			&& !Attacker.bDeleteMe)
			GotoStateSave('ShredDead');
		else
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
	function EndState()
	{
		bHurtTarget=false;
		MyPawn.ChangeAnimation();
	}

Begin:
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Wrestling the thing back and forth, hurting it
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShredDead extends ShredAttack
{
	///////////////////////////////////////////////////////////////////////////////
	// Make it so you sort of hurt/shake people as their are dead.
	///////////////////////////////////////////////////////////////////////////////
	function DoShredDead()
	{
		if(P2Pawn(Attacker) != None
			&& Attacker.Health <= 0
			&& !Attacker.bDeleteMe)
			Touch(Attacker);
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
Begin:
	// Repeatedly jerk him around
	DoShredDead();
	Sleep(0.3);
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WatchHeroHighUp
// Bark and wait for our hero to come down
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchHeroHighUp
{
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		//log("anim end "$channel$" state count "$statecount);
		// Check for the base channel only
		if(channel == 0)
		{
			SetNextState(GetStateName(), 'TryForHim');
			GotoStateSave('Thinking');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		MyPawn.ChangeAnimation();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.StopAcc();
	}

TryForHim:
	SetActorTargetPoint(Hero.Location);
	// If it worked, go for him
	GotoHero();

Begin:
	MyPawn.PlayAnimStanding();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WatchHeroHighUp
// Bark and wait for our hero to come down
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchAttackerHighUp extends WatchHeroHighUp
{
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		//log("anim end "$channel$" state count "$statecount);
		// Check for the base channel only
		if(channel == 0)
		{
			SetNextState(GetStateName(), 'TryForHim');
			GotoStateSave('AttackerGrowling');
		}
	}

TryForHim:
	SetActorTargetPoint(Attacker.Location);
	// If it worked, go for him
	//log(self$" going for it");
	SetEndPoint(Attacker.Location, DEFAULT_END_RADIUS);
	SetNextState('AttackTarget');
	GotoStateSave('RunToAttacker');

Begin:
	MyPawn.PlayAnimStanding();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	PounceDamage = 15
	turdmesh = StaticMesh'timb_mesh.Champ.poo_log'
	AttackDamageType = class'DogBiteDamage'
	MouthBone="Dummy07"
}
