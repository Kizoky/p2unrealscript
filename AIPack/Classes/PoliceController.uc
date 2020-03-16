///////////////////////////////////////////////////////////////////////////////
// PoliceController
// Copyright 2002 RWS, Inc.  All Rights Reserved.
//
// High-level RWS AI Controllers for cops
//
// Cops determine their loyalties on the fly. They always respect bAuthorityFigure
// but their bTeamLeader and MyLeader get changed all the time. Don't set
// bTeamLeader or their gang to anything. They don't look at their gangs and
// they change bTeamLeader dynamically.
//
// Cops on patrol in the jail usually start with bIgnoresHearing set to true. This is
// so cops on higher floors in the jail, don't flood down at the first sound of gunfire.
// They are triggered to hear again as the player climbs the floors or is transported
// into a cell. We don't use ignoresenses here because we want them to be able to go 
// between floors and still respond if they see you (even if they can't hear you yet).
//
// We don't get converted into 'riot' mode. We're immune to the mind altering gases.
//
///////////////////////////////////////////////////////////////////////////////
class PoliceController extends PersonController;

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
// User set vars

// Internal vars
var float LastAttackedTime;		// Last Level.TimeSeconds value for when when heard a shot/were attacked.
								// This is only used to make sure the same gunfire/bullet hit pair doesn't	
								// piss us off twice as much
var bool bReportedPlayer;		// If you've already reported the player to the GameState
								// radio timer.
var array<Sound>	RadioSounds;// Sounds to play as we check our radio.
// 1, 2 fairly generic, .. 3-4 too specific?

var Sound HallwayFootstepSounds;// Loud footsteps in a hallway (for jail patrollers)
var bool bPatrolJail;			// If you're patrolling, use PatrolJailToTarget
var bool bHateAttacker;			// If this is true, then we've probably fought the attacker, or not
								// we're just not taking any more shit from him. This means, if he
								// pulls a weapon AT ALL anymore, as long as we know him, we'll just attack him

// Removed, because you could get arrested after a guy just runs into you and you didn't except it
//var bool bReadDudeHisRights;	// If true, it means we've already read the dude his Miranda rights, 
//								// so I won't do it again.

var bool bAllowHints;			// Though the guy may have been spotted earlier, only allow hints at all
								// if this cop has yelled at the player to freeze or whatever. The cop could
								// be running to him before yelling--in which case, we don't want the hints just yet.
								// But once he's yelled once, the hints can come on and act like normal.
								
var bool bRejectedBribe;		// If true we already rejected a bribe-out-of-arrest offer								
var bool bIgnoreFutureBribes;	// If they keep bribing us to avoid arrest, just set this and we'll
								// ignore future bribery requests.
const BRIBE_MIN = 100; // Minimum amount of money for bribe

var float LastWarnTime;
const MIN_WARN_TIME = 10.0;

///////////////////////////////////////////////////////////////////////////////
// Const
///////////////////////////////////////////////////////////////////////////////
const FREEZE_ADD_DIST				=	700;
const FREEZE_BASE_DIST				=	400;
const FACING_ME_CONE				=	0.6;

const CLOSE_ENOUGH_FOR_FINAL_CUFF	=	100;
const TALK_WHILE_WALKING_DIST		=	256;
const TOO_CLOSE_FOR_SMALL_ARMS		=	375;
const CHECK_FOR_LEADER_RADIUS		=	2048;
const NON_LEADER_SLEEP_TIME			=	4.0;
const NON_LEADER_DIST_TO_ATTACKER	=	1024;
const NON_LEADER_MOUTHS_OFF			=	0.3;

const INTERFERENCE_DIST				=	150;

const GUN_OUT_WAIT_COUNT			=	4;

const KILL_LIMIT_DISOBEYED_WHILE_ARRESTING=	0.8;

const RUN_TO_NEW_POINT				=	0.05;
const TALK_TO_GUY_HIGH_UP			=	0.2;

const ASK_FOR_SHOOTER_RADIUS		=	2048;
const MANAGE_PEOPLE_RADIUS			=	2048;

const WALK_PATROL_STATE				='PatrolJailToTarget';
const RUN_PATROL_STATE				='RunPatrolJailToTarget';

const REPORT_LOOKS_FREQ	= 0.50;

///////////////////////////////////////////////////////////////////////////////
// You just got beat up Rodney King style
///////////////////////////////////////////////////////////////////////////////
function HitByBaton(P2Pawn Doer)
{
	const STUN_CHANCE = 0.5;
	
	// How to react
	if (!MyPawn.bMissingLimbs && FRand() <= STUN_CHANCE)	
		GotoStateSave('RestAfterBatonHit');
}

///////////////////////////////////////////////////////////////////////////////
// You just got kicked in the balls
///////////////////////////////////////////////////////////////////////////////
function TookNutShot(P2Pawn Doer)
{
	// If you're a male and have a pain tolerance of anything below 1.0 this hurts you big time
	if (!MyPawn.bMissingLimbs && MyPawn.MyGender == Gender_Male
		&& MyPawn.PainThreshold < 1.0)
		GotoStateSave('RestAfterNutShot');
}

///////////////////////////////////////////////////////////////////////////////
// This function checks first if we should be switching to our best weapon
// just yet.
// Cops will not use their baton and switch to their gun if they really need
// their best weapon.
///////////////////////////////////////////////////////////////////////////////
function bool DecideToPickBestWeapon()
{
	return (P2Weapon(Pawn.Weapon) == None
			|| P2Weapon(Pawn.Weapon).ViolenceRank <= 0
			|| Pawn.Weapon.bMeleeWeapon);
}

///////////////////////////////////////////////////////////////////////////////
// Similar to SwitchToBestWeapon, this only switches if you currently have
// nothing violent out, or if you were previously using a melee weapon.
// Hopefully you actually have a gun (cops have pistols *and* batons) when
// you call this
///////////////////////////////////////////////////////////////////////////////
exec function SwitchToBestWeapon()
{
	// The guy has out a violent weapon, so get out a real weapon
	// Or it's an animal
	if(Attacker != None
		&& (AnimalPawn(Attacker) != None
			|| Attacker.IsA('AWZombie')
			|| (P2Weapon(Attacker.Weapon) != None
				&& P2Weapon(Attacker.Weapon).ViolenceRank > 0)))
	{
		Super.SwitchToBestWeapon();
	}
	else // default to baton for any other disturbance
	{
		// Set twitch time
		WorkFloat = (MyPawn.GetTwitch())/TWITCH_DIVIDER;
		// Pick whatever baton/shocker-like melee weapon they might have
		SwitchToLastWeaponInGroup(class'BatonWeapon'.default.InventoryGroup);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Go back to our hands
///////////////////////////////////////////////////////////////////////////////
function SwitchToHands()
{
	SwitchToThisWeapon(MyPawn.HandsClass.default.InventoryGroup,
						MyPawn.HandsClass.default.GroupOffset);
}

///////////////////////////////////////////////////////////////////////////
// Add yourself the cop radio list of cops who care about the player.
// As long as someone is in that list, the cop radio can't fall below
// a certain point
///////////////////////////////////////////////////////////////////////////
function PlayerFirstTimeAttacker()
{
	local P2GameInfoSingle p2g;
	p2g = P2GameInfoSingle(Level.Game);
	p2g.TheGameState.AddCopAfterPlayer(MyPawn);
}

///////////////////////////////////////////////////////////////////////////////
// All our attacker pointers are blanked out. This should not be called everywhere.
// Cops use this to remove themselves from the list of cops looking for the player.
// When that list is empty, the cop radio can go off (after it's out of time).
// Use SetAttacker(None) for minor clears of attackers.
///////////////////////////////////////////////////////////////////////////////
function FullClearAttacker(optional bool bClearPlayerOnly)
{
	local P2GameInfoSingle p2g;

	p2g = P2GameInfoSingle(Level.Game);
	if(p2g != None
		&& p2g.TheGameState != None)
		p2g.TheGameState.RemoveCopAfterPlayer(MyPawn);

	PlayerAttackedMe=None;

	if(bClearPlayerOnly)
		SetAttacker(None);
}

///////////////////////////////////////////////////////////////////////////
// Possibly another cop, or someone who's friend with authority. Return
// true if so, false otherwise.
///////////////////////////////////////////////////////////////////////////
function bool FriendWithMe(FPSPawn Other)
{
	// invalid, so not friend
	if(Other == None)
		return false;

	// Uphold the blue wall!
	if(Other.IsA('Police'))
		return true;

	// He's a fellow good guy, don't attack him
	if(P2Pawn(Other) != None
		&& P2Pawn(Other).bAuthorityFigure)
		return true;

	// He's trying to attack a good guy, or the dude/cop, so not a friend
	if(PersonController(Other.Controller) != None
		&& ((P2Pawn(PersonController(Other.Controller).Attacker) != None
				&& P2Pawn(PersonController(Other.Controller).Attacker).bAuthorityFigure)
			|| DudeDressedAsCop(PersonController(Other.Controller).Attacker)))
		return false;

	// He's a friend of good guys don't attack him
	if(PersonController(Other.Controller) != None
//		&& PersonController(Other.Controller).Attacker != MyPawn
		&& Other.bFriendWithAuthority)
		return true;

	return false;
}

///////////////////////////////////////////////////////////////////////////
// When attacked, just short circuit
///////////////////////////////////////////////////////////////////////////
function PolicedamageAttitudeTo(pawn Other, float Damage)
{
	local vector dir;

	if(Damage > 0
		&& Other != Pawn)
	{
		if (Other != None)
		{
			// We don't care about friendly fire
			if(FriendWithMe(FPSPawn(Other)))
			{
				PerformStrategicMoves(true);
				return;
			}

			SetAttacker(FPSPawn(Other));
			SaveAttackerData();
			GetAngryFromDamage(Damage);
			MakeMoreAlert();
			Say(MyPawn.myDialog.lGotHit);// cry out

			ReportAfterHit();
			
			// If we've got limb damage keep on running and screaming
			if (MyPawn.bMissingLimbs)
				return;

			if(MyNextState == 'Thinking'
				|| IsInState('WalkToTarget'))
			{
				GotoStateSave('ReactToAttack');
			}
			else if(MyNextState != '')
			{
				GotoNextState();
			}
			else
				GotoStateSave('ReactToAttack');

			return;
		}
		else	// If i bumped a thing that hurts me, like a cactus
		{
			Say(MyPawn.myDialog.lGotHit);		// cry out
			MyPawn.SetMood(MOOD_Angry, 1.0);
		}
	}
}

///////////////////////////////////////////////////////////////////////////
// When attacked, just short circuit
///////////////////////////////////////////////////////////////////////////
function damageAttitudeTo(pawn Other, float Damage)
{
	PolicedamageAttitudeTo(Other, Damage);
}

// Just real quick check for nearby zombies/skeletons
function bool ZombiePerimeterCheck(vector BlipLoc)
{
	local P2Pawn P;
	
	const ZOMBIE_PERIMETER = 2000.0;
	
	foreach VisibleCollidingActors(class'P2Pawn', P, ZOMBIE_PERIMETER, BlipLoc)
		if (P.IsA('AWZombie'))
			return true;
			
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// We've seen the pawn, now decide if we care
// Returns true if there state changes at some point
///////////////////////////////////////////////////////////////////////////////
function AuthorityActOnPawnLooks(FPSPawn LookAtMe, optional out byte StateChange)
{
	local P2Weapon p2weap;
	local vector dir, pawndiff, rot, crosscheck;
	local float dist;
	local bool bcheck, bRunAway;
	local P2GameInfoSingle checkg;
	local bool bIsGimp, bIsCop;

	// If this guy doesn't care about things going on around him
	if(MyPawn.bIgnoresSenses)
		return;

	// Handle zombies
	if(LookAtMe.IsA('AWZombie'))
	{
		if(MyPawn.bHasViolentWeapon)
		{
			// Drop things if you had them in your hands
			MyPawn.DropBoltons(MyPawn.Velocity);
			SetAttacker(LookAtMe);
			MakeMoreAlert();
			SaveAttackerData(LookAtMe);
			PrintDialogue("Animals must die!");
			Say(MyPawn.myDialog.lStartAttackingAnimal);
			GotoStateSave('ShootAtAttacker', 'WaitTillFacing');
			StateChange=1;
		}
		else
		{
			GenSafeRangeMin();
			InterestPawn = LookAtMe;
			SetAttacker(InterestPawn);
			DangerPos = Attacker.Location;
			GotoStateSave('FleeFromAttacker');
			StateChange=1;
		}
	}

	// If he's on fire, just watch him, if we're not already fighting
	if(Attacker == None
		&& LookAtMe.MyBodyFire != None)
	{
		GenSafeRangeMin();
		DangerPos = LookAtMe.Location;
		MakeMoreAlert();
		InterestPawn = LookAtMe;
		GotoStateSave('WatchGuyOnFire');
		StateChange = 1;
		return;
	}

	// If it's a crazy animal, run or fight it
	// Animals very rarely send out look requests--usually only when they're deadly
	if(AnimalPawn(LookAtMe) != None)
	{
		if(AnimalPawn(LookAtMe).bDangerous)
		{
			if(MyPawn.bHasViolentWeapon)
			{
				// Drop things if you had them in your hands
				MyPawn.DropBoltons(MyPawn.Velocity);
				SetAttacker(LookAtMe);
				MakeMoreAlert();
				SaveAttackerData(LookAtMe);
				GotoStateSave('RecognizeAttacker');
			}
			else
			{
				GenSafeRangeMin();
				InterestPawn = LookAtMe;
				SetAttacker(InterestPawn);
				DangerPos = Attacker.Location;
				GotoStateSave('FleeFromAttacker');
			}
			StateChange=1;
		}
		return;
	}

	// We don't care about other cops
	if(FriendWithMe(LookAtMe))
		return;

	// Check first (before we see the weapon) if he is possibly in your house
	// and not supposed to be, and you care about it
	CheckForIntruder(LookAtMe, StateChange);
	if(StateChange == 1)
		return;

	// Handle the dude-cop seperately. We don't care what he's looking
	// like, except if he's got his pants down
	if(DudeDressedAsCop(LookAtMe))
	{
		return;
	}
	// If the dude
	if(LookAtMe.bPlayer)
	{
		// And you're friends with him, don't care what he looks like
		if(MyPawn.bPlayerIsFriend)
			return;

		// Otherwise, if we've spotted the dude, and he's still wanted, then
		// arrest him
		checkg = P2GameInfoSingle(Level.Game);
		if((MyPawn.bHasRadio 
			&& checkg.TheGameState.CopsWantPlayer() > 0)
			|| checkg.TheGameState.bArrestPlayerInJail)
		{
			StartWithSuspect(LookAtMe);
			StateChange=1;
			return;
		}
	}

	// Check to see if we care what he's doing or what he looks like
	p2weap = P2Weapon(LookAtMe.Weapon);

	// Check to make sure the weapon is in our view (and he's
	// not walking backwards to us, with it or something)
	// Also, the weapon we see is anything we're interested in.
	if(p2weap != None
		&& WeaponTurnedToUs(LookAtMe, MyPawn))
	{
		dir = LookAtMe.Location - MyPawn.Location;
		dist = VSize(dir);

		// We're close enough to see what the weapon is, that he has
		if(dist < p2weap.RecognitionDist)
		{
			// If he's got a cowhead, stare at him
			if(P2Weapon(LookAtMe.Weapon) != None
						&& P2Weapon(LookAtMe.Weapon).bWeaponIsGross)
			{
				if(MyPawn.bHasViolentWeapon)
				{
					InterestPawn = LookAtMe;
					GotoStateSave('WatchGuyWithCowhead');
					StateChange=1;
					return;
				}
			}
			// If we even see a gas can, we're concerned
			else if(GasCanWeapon(LookAtMe.Weapon) != None)
			{
				if(MyPawn.bHasViolentWeapon)
				{
					InterestPawn = LookAtMe;
					GotoStateSave('WatchGuyWithGasCan');
					StateChange=1;
					return;
				}
			}
			// You're pants are down, so arrest you for it--unless you're doing this
			// in jail, in which case we don't care.
			else if(LookAtMe.HasPantsDown())
			{
				checkg = P2GameInfoSingle(Level.Game);
				if(MyPawn.bHasViolentWeapon
					&& (!checkg.TheGameState.bPlayerInCell
						|| checkg.TheGameState.bArrestPlayerInJail))
				{
					InterestPawn = LookAtMe;
					GotoStateSave('HandleGuyWithPantsDown');
					StateChange=1;
					return;
				}
			}
			else if(ConcernedAboutWeapon(p2weap))
			{
				if(p2weap.ViolenceRank >= p2weap.LEGAL_VIOLENCE_RANK
					&& !ZombiePerimeterCheck(LookAtMe.Location)) // He might be fighting a zombie/skeleton. If so don't arrest him, just watch, we can arrest him later if there are no zombies/skeletons
				// Handle pistol, shotgun, machinegun, rifle, grenade as soon
				// as you see them, with arrest mode/or attack him
				{
					if(!MyPawn.bHasViolentWeapon)
						bRunAway=true;
					else 						
					{
						SetAttacker(LookAtMe);
						InterestPawn = LookAtMe;
						GotoStateSave('HandleGuyWithBigGun');
						StateChange=1;
						return;
					}
				}
				else
				// Handle Shocker, scissors, cowhead, molotov, shovel, baton
				// by watching him carefully, as soon as you recognize these things
				// and either arrest him or attack him when he's too close.
				{
					InterestPawn = LookAtMe;
					GotoStateSave('HandleGuyWithSmallGun');
					StateChange=1;
					return;
				}
			}

			if(bRunAway)
			{
				// We're scared of cops shooting, but we won't really avoid them
				// like an attacker, we just run from where they shot
				// Run away like a little girl if you don't have a weapon
				// Check to see if we should flee or if we're an okay distance away
				// Find direction away from danger
				SetAttacker(LookAtMe);
				DangerPos = LookAtMe.Location;
				dir = (MyPawn.Location - DangerPos);
				dir.z=0;
				// Dist between attacker and me
				CurrentDist = VSize(dir);
				// Decide current safe min
				UseSafeRangeMin = MyPawn.SafeRangeMin + (MyPawn.Cowardice)*MyPawn.SafeRangeMin;
				//log("Check react to "$KnownDanger);

				GotoStateSave('FleeFromAttacker');
				StateChange=1;
				return;
			}
		}
		else if(dist < 2*p2weap.RecognitionDist
			&& ConcernedAboutWeapon(p2weap))
		// If he's got ANYTHING even vaguely dangerous, consider watching him for it if it's
		// close enough to see he has something, but not quite make out what it is
		{
			TryToSeeWeapon(LookAtMe);
			StateChange=1;
			return;
		}
	}

	bIsGimp = PersonDressedAsGimp(LookAtMe);

	if(MyPawn.Talkative > FRand()
		|| bIsGimp)
	// Consider talking to them
	{
		// If they don't have their pants down and have no weapon,
		// then check to talk to them
		if(p2weap == None
			|| (!ConcernedAboutWeapon(p2weap)
			&& !LookAtMe.HasPantsDown()))
		{
			TryToGreetPasserby(LookAtMe, bIsGimp, false, StateChange);
			if(StateChange == 1)
				return;
		}
	}

	// Since we're not doing anything else, if it's the player, then check to see what he's doing
	if(LookAtMe.bPlayer)
		HandlePlayerSightReaction(LookAtMe);

	/*
	// If it wasn't anything bad, then consider looking at the person
	// Check if they are too the sides or not
	rot = Normal(vector(MyPawn.Rotation));
	pawndiff = Normal(LookAtMe.Location - MyPawn.Location);

	crosscheck = rot cross pawndiff;

	log(MyPawn$" dot to guy "$rot dot pawndiff$" cross "$crosscheck);
	if(crosscheck.z > 0.0)
		MyPawn.PlayTurnHeadRightAnim(1.0, (1.0 - rot dot pawndiff) + 0.5);
	else
		MyPawn.PlayTurnHeadLeftAnim(1.0, (1.0 - rot dot pawndiff) + 0.5);
*/
	return;
}

///////////////////////////////////////////////////////////////////////////////
// We've seen the pawn, now decide if we care
// Returns true if there state changes at some point
///////////////////////////////////////////////////////////////////////////////
function ActOnPawnLooks(FPSPawn LookAtMe, optional out byte StateChange)
{
	AuthorityActOnPawnLooks(LookAtMe, StateChange);
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
	local float dist;
	local vector dir;
	local byte AttackingDudeCop, Worked;

	//log(self@"react to this danger"@dangerhere@"CreatorPawn"@CreatorPawn@"Origin"@OriginActor);

	// If this guy doesn't care about things going on around him
	if(MyPawn.bIgnoresSenses
		|| MyPawn.bIgnoresHearing)
		return;

	// Handle zombies
	if(CreatorPawn != None
		&& CreatorPawn.IsA('AWZombie'))
	{
		if(MyPawn.bHasViolentWeapon)
		{
			// Drop things if you had them in your hands
			MyPawn.DropBoltons(MyPawn.Velocity);
			SetAttacker(CreatorPawn);
			MakeMoreAlert();
			SaveAttackerData(CreatorPawn);
			PrintDialogue("Animals must die!");
			Say(MyPawn.myDialog.lStartAttackingAnimal);
			GotoStateSave('ShootAtAttacker', 'WaitTillFacing');
			StateChange=1;
		}
		else
		{
			GenSafeRangeMin();
			InterestPawn = CreatorPawn;
			SetAttacker(InterestPawn);
			DangerPos = Attacker.Location;
			GotoStateSave('FleeFromAttacker');
			StateChange=1;
		}
	}

	// Ignore dog attacks, if you're friends and they're not attacking you
	if(CreatorPawn != None
		&& CreatorPawn.IsA('DogPawn')
		&& P2MoCapPawn(Pawn).bDogFriend
		&& AnimalController(CreatorPawn.Controller) != None
		&& AnimalController(CreatorPawn.Controller).Attacker != MyPawn)
	{
		// STUB
		return;
	}

	// if it's a crazy animal, run or fight it
	if((Attacker == None
			|| Attacker == CreatorPawn)
		&& AnimalPawn(CreatorPawn) != None)
	{
		// If the animal *didn't* attack, then just be alarmed
		if(!dangerhere.default.bCreatorIsAttacker)
		{
			InterestPawn = CreatorPawn;
			DangerPos = blipLoc;
			LastAttackerPos = DangerPos;
			SetNextState('WatchForViolence');
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			GotoStateSave('ConfusedByDanger');
			StateChange=1;
			return;
		}
		else	// if did attack, so respond
		{
			if(MyPawn.bHasViolentWeapon)
			{
				// Drop things if you had them in your hands
				MyPawn.DropBoltons(MyPawn.Velocity);
				SetAttacker(CreatorPawn);
				MakeMoreAlert();
				SaveAttackerData(CreatorPawn);
				PrintDialogue("Animals must die!");
				Say(MyPawn.myDialog.lStartAttackingAnimal);
				GotoStateSave('ShootAtAttacker', 'WaitTillFacing');
				StateChange=1;
			}
			else
			{
				GenSafeRangeMin();
				InterestPawn = CreatorPawn;
				SetAttacker(InterestPawn);
				DangerPos = Attacker.Location;
				GotoStateSave('FleeFromAttacker');
				StateChange=1;
			}
			LastAttackedTime = Level.TimeSeconds;
		}
		return;
	}

	// If the dude, and you're friends with him, don't care what noises
	// he makes from guns or whatever
	if(CreatorPawn != None
		&& MyPawn.bPlayerIsFriend 
		&& CreatorPawn.bPlayer)
	{
		LastAttackedTime = Level.TimeSeconds;
		return;
	}

	// If they're shooting at nothing in particular but there's a zombie nearby, they
	// might have been shooting the zombie. Watch and be concerned.
	if (CreatorPawn != None
		&& (OriginActor == None || OriginActor == CreatorPawn || OriginActor.IsA('AWZombie'))
		&& ZombiePerimeterCheck(BlipLoc))
	{
		InterestPawn = CreatorPawn;
		DangerPos = blipLoc;
		LastAttackerPos = CreatorPawn.Location;
		SetNextState('WatchForViolence');
		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		// If we can see him, just be confused
		if(FastTrace(MyPawn.Location, CreatorPawn.Location))
			GotoStateSave('ConfusedByDanger');
		else	// if we can't see him, run kind of close to him
		{
			SetEndPoint(LastAttackerPos, DEFAULT_END_RADIUS);
			GotoStateSave('RunToTarget');
		}
		StateChange=1;
		return;
	}

	if(!MyPawn.bHasViolentWeapon)
	// Run away like a little girl if you don't have a weapon
	{
		// We're scared of cops shooting, but we won't really avoid them
		// like an attacker, we just run from where they shot
		if(!FriendWithMe(CreatorPawn))
		{
			// Check to see if we should flee or if we're an okay distance away
			// Find direction away from danger
			SetAttacker(CreatorPawn);
			DangerPos = blipLoc;
			dir = (MyPawn.Location - DangerPos);
			dir.z=0;
			// Dist between attacker and me
			CurrentDist = VSize(dir);
			// Decide current safe min
			UseSafeRangeMin = MyPawn.SafeRangeMin + (MyPawn.Cowardice)*MyPawn.SafeRangeMin;
			//log("Check react to "$KnownDanger);
			GotoStateSave('FleeFromDanger');
			StateChange=1;
			LastAttackedTime = Level.TimeSeconds;
			return;
		}
	}

	// Go to the rescue
	// Someone was shot and this bad. Start shooting at the 
	// attacker if you knew about him
	if(dangerhere == class'PawnShotMarker'
		&& Attacker != None
		&& CreatorPawn == Attacker
		)
	{
		// If they're fighting zombies, what the hell are you doing just staring? Do something!
		if (OriginActor.IsA('AWZombie'))
		{
			// Drop things if you had them in your hands
			MyPawn.DropBoltons(MyPawn.Velocity);
			SetAttacker(FPSPawn(OriginActor));
			MakeMoreAlert();
			SaveAttackerData(FPSPawn(OriginActor));
			PrintDialogue("Animals must die!");
			Say(MyPawn.myDialog.lStartAttackingAnimal);
			GotoStateSave('ShootAtAttacker', 'WaitTillFacing');
			StateChange=1;
			return;
		}

		if(!DudeDressedAsCop(CreatorPawn)
			|| OriginActor.IsA('Police'))
		{
			GotoStateSave('ShootAtAttacker');
			LastAttackedTime = Level.TimeSeconds;
		}
		else
		{
			TryToCauseInterference(CreatorPawn, FPSPawn(OriginActor));
		}
		StateChange=1;
		return;
	}
	else if(CreatorPawn != None)
	{
		if(!FriendWithMe(CreatorPawn))
			//CreatorPawn.IsA('Bystander')) 
		// For the moment, only investigate bystander shooting.. revamp investigate to
		// handle generic shooting (cops and all)
		// general danger, investigate attacker
		{
			DangerPos = blipLoc;
			// If it's the dude shooting around, run to see what's happening
			if(DudeDressedAsCop(CreatorPawn))
			{
				LastAttackedTime = Level.TimeSeconds;
				DangerPos = blipLoc;
				// if I can't directly see/get to the danger point, go investigate
				if(!FastTrace(MyPawn.Location, blipLoc))
				{
					// if we're close enough, seek out the attacker himself, not the
					// hit point
					if(VSize(CreatorPawn.Location - MyPawn.Location) <= class'GunfireMarker'.default.CollisionRadius)
						DangerPos = CreatorPawn.Location;
					// Run to that point
					GotoStateSave('PrepRunToInvestigate');
				}
				else
				{
					if(dangerhere == class'PawnShotMarker')
					{
						if(OriginActor.IsA('Police'))
						{
							SetAttacker(CreatorPawn);
							GotoStateSave('ShootAtAttacker');
							LastAttackedTime = Level.TimeSeconds;
						}
						else
							TryToCauseInterference(CreatorPawn, FPSPawn(OriginActor));
					}
					else
					{
						InterestPawn = CreatorPawn;
						GotoStateSave('WatchACop');
					}
					StateChange=1;
					return;
				}
			}
			else // Normal dude not dressed as cop.
			{
				// If this guy just broke something like a window
				// then just watch him, but don't get freaked unless
				// he has a weapon
				if(dangerhere == class'PropBreakMarker')
				{
					// If we have a clear shot of him, arrest him
					if(FastTrace(MyPawn.Location, CreatorPawn.Location))
					{
						DangerPos = blipLoc;
						SetAttacker(CreatorPawn);
						InterestPawn = CreatorPawn;
						GotoStateSave(GetAggressiveState());
						StateChange=1;
						LastAttackedTime = Level.TimeSeconds;
						return;
					}
					else	// if not, just watch
					{
						InterestPawn = CreatorPawn;
						DangerPos = blipLoc;
						LastAttackerPos = DangerPos;
						SetNextState('WatchForViolence');
						if(IsInState('LegMotionToTarget'))
							bPreserveMotionValues=true;
						GotoStateSave('ConfusedByDanger');
						StateChange=1;
						return;
					}
				}
				// Watch the crazy kicking person
				else if(ClassIsChildOf(dangerhere, class'MeleeHitNothingMarker'))
				{
					if(InterestPawn == None)
					{
						InterestPawn = CreatorPawn;
						DangerPos = blipLoc;
						LastAttackerPos = DangerPos;
						SetNextState('WatchForViolence');
						if(IsInState('LegMotionToTarget'))
							bPreserveMotionValues=true;
						GotoStateSave('ConfusedByDanger');
						StateChange=1;
					}
					return;
				}
				else if(dangerhere.default.bCreatorIsAttacker)
				{
					SetAttacker(CreatorPawn);
					InterestPawn = CreatorPawn;
					// if I can't directly see/get to the danger point, go investigate
					if(!FastTrace(MyPawn.Location, blipLoc))
					{
						// if we're close enough, seek out the attacker himself, not the
						// hit point
						if(VSize(Attacker.Location - MyPawn.Location) <= class'GunfireMarker'.default.CollisionRadius)
							DangerPos = Attacker.Location;
						// Run to that point
						GotoStateSave('PrepRunToInvestigate');
					}
					else
						GotoStateSave('RecognizeNearbyShooter');

					StateChange=1;
					LastAttackedTime = Level.TimeSeconds;
					return;
				}
				else
				{
					// if I can't directly see/get to the danger point, go investigate
					if(!FastTrace(MyPawn.Location, blipLoc))
					{
						// If we're close enough then start looking around now for trouble
						if(VSize(CreatorPawn.Location - MyPawn.Location) <= class'GunfireMarker'.default.CollisionRadius)
							DangerPos = CreatorPawn.Location;
						// Run to that point
						GotoStateSave('PrepRunToInvestigate');
					}
					else
						GotoStateSave('RecognizeNearbyShooter');

					StateChange=1;
					return;
				}
			}
			/*
			// if it's a friend of yours fight with them
			else
			{
				GainPartnersKnowledge(PersonController(CreatorPawn.Controller), Worked, AttackingDudeCop);
				if(AttackingDudeCop == 1)	// he's attacking our dude/cop friend! Attack him instead
				{
					InterestPawn = CreatorPawn;
					SetAttacker(CreatorPawn);
					GotoStateSave('AssessAttacker');
					StateChange=1;
					LastAttackedTime = Level.TimeSeconds;
					return;
				}
				else if(Worked == 1
					&& !MyPawn.bTeamLeader)	// it worked, so help
				{
					GotoStateSave('AssessAttacker');
					StateChange=1;
					LastAttackedTime = Level.TimeSeconds;
					return;
				}
			}
			*/
		}
		// If you don't have a good attacker, then help out the good guys
		else if(Attacker == None
				|| Attacker.Health <= 0)
		{
			// Someone around you yelled something and you didn't know about it yet
			if(dangerhere == class'AuthorityOrderMarker')
			{
				CheckAuthorityYell(CreatorPawn, blipLoc);
				StateChange=1;
				return;
			}
			else
			{
				GainPartnersKnowledge(PersonController(CreatorPawn.Controller), Worked, AttackingDudeCop);
				// If it's an authority figure and they're attacking the dude cop, then his cover's been blown. Attack/arrest him
				if (AttackingDudeCop == 1
					&& FriendWithMe(CreatorPawn))
				{					
					//log(CreatorPawn@"attacking the dudecop -- back them up");
					InterestPawn = PersonController(CreatorPawn.Controller).Attacker;
					SetAttacker(InterestPawn);
					GotoStateSave('AssessAttacker');
					StateChange=1;
					LastAttackedTime=Level.TimeSeconds;
				}
				else if(AttackingDudeCop == 1)	// he's attacking our dude/cop friend! Attack him instead
				{
					//log(CreatorPawn@"attacking the dudecop!");
					InterestPawn = CreatorPawn;
					SetAttacker(CreatorPawn);
					GotoStateSave('AssessAttacker');
					StateChange=1;
					LastAttackedTime = Level.TimeSeconds;
					return;
				}
				else if(Worked == 1
					&& !MyPawn.bTeamLeader)	// it worked, so help
				{
					GotoStateSave('AssessAttacker');
					StateChange=1;
					LastAttackedTime = Level.TimeSeconds;
					return;
				}
			}
		}
	}
	LastAttackedTime = Level.TimeSeconds;
	return;
}

///////////////////////////////////////////////////////////////////////////
// Piss is hitting me, decide what to do
// Used the cheesy bool bPuke so we wouldn't have another
// function to ignore in all the states
// If the dude is pissing on us from the jail cell, we run away
// instead and don't confront him
///////////////////////////////////////////////////////////////////////////
function BodyJuiceSquirtedOnMe(P2Pawn Other, bool bPuke)
{
	local P2GameInfoSingle checkg;

	// Only none-turrets use this
	if(MyPawn.PawnInitialState != MyPawn.EPawnInitialState.EP_Turret && !MyPawn.bMissingLimbs)
	{
		//log(self$" is getting pissed/puked on by "$Other);
		checkg = P2GameInfoSingle(Level.Game);
		if(!checkg.TheGameState.bPlayerInCell
			|| checkg.TheGameState.bArrestPlayerInJail)
		{
			InterestPawn=Other;
			GetAngryFromDamage(PISS_FAKE_DAMAGE);
			MakeMoreAlert();

			if(bPuke)
				// Definitely throw up from puke on me
				CheckToPuke(, true);
			else
				// possibly throw up from the yuckiness
				GotoStateSave('InvestigateWetness');
		}
		else	// Run far away and then go back to normal
			// if he's in his proper jail cell pissing on you
		{
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			SetNextState('Thinking');

			// Yell as he runs away
			MyPawn.SetMood(MOOD_Angry, 1.0);
			SayTime = Say(MyPawn.myDialog.lAfterGettingPissedOn, bImportantDialog);
			// If we're patrolling, go to our next node
			if(MyPawn.PatrolNodes.Length > 0)
				SetEndGoal(GetNextPatrolEndPoint(), DEFAULT_END_RADIUS);
			else
				PickRandomDest();

			GotoStateSave('RunToTarget');
		}
	}
}

///////////////////////////////////////////////////////////////////////////
// Check to see if you can/want to puke
// We don't go screaming away like little nancy-girls. We stand around
// and look important.
///////////////////////////////////////////////////////////////////////////
function CheckToPuke(optional float modifier, optional bool bForce, optional out byte StateChange)
{
	//	log(self$" Stomach possible "$MyPawn.Stomach*modifier$" stomach is "$MyPawn.Stomach$" force is "$bForce);

	if((MyPawn.Stomach < 1.0
		&& FRand() >= (MyPawn.Stomach*modifier)
		&& MyPawn.PukeCount == 0)
		|| bForce)
	{
		DangerPos = MyPawn.Location;
		GenSafeRangeMin();
		SetNextState('LookAroundForTrouble');
		GotoState('DoPuking');
		StateChange=1;
		return;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set the timer going for a scream
///////////////////////////////////////////////////////////////////////////////
function TimeToScream(optional int ScreamType, optional float UseThatScreamFreq)
{
	//local float UseRand;

	if(ScreamState == SCREAM_STATE_ACTIVE)
	{
		//if(ScreamType != NORMAL_SCREAM)
		//	UseRand = FRand();
		PrintDialogue("Aaaaah! or maybe no screaming sometimes");
//		if(ScreamType == FIRE_SCREAM && UseRand < UseThatScreamFreq)
		// Marphy - Restoring fire screams but still allowing for the original
		// screams with random chance.
		if(ScreamType == FIRE_SCREAM && MyPawn.MyBodyFire != None)
			{
			if(Frand() < 0.5)
				SayTime = Say(MyPawn.myDialog.lScreamingOnFire);
			else
				SayTime = Say(MyPawn.myDialog.lScreaming);
			}
		else
			SayTime = Say(MyPawn.myDialog.lScreaming);

		ScreamState = SCREAM_STATE_DONE;
		SetTimer(SayTime, false);
	}
}

///////////////////////////////////////////////////////////////////////////
// A bouncing, disembodied head just hit us, decide what to do
///////////////////////////////////////////////////////////////////////////
function GetHitByDeadThing(Actor DeadThing, FPSPawn KickerPawn)
{
	local Actor UseInterest;

	if(Attacker == None)
	{
		if((KickerPawn == None
				&& CanSeePoint(MyPawn, DeadThing.Location, 0.1))
			|| (KickerPawn != None
				&& CanSeePawn(MyPawn, KickerPawn, 0.1)))
		{
			// Clear our instigator after interaction
			DeadThing.Instigator = None;

			// Arrest the bad guy kicking a disembodied head at us
			if(MyPawn.bHasViolentWeapon)
			{
				if(KickerPawn != None)
				{
					InterestPawn = KickerPawn;
					SetAttacker(InterestPawn);
					DangerPos = InterestPawn.Location;
					GotoStateSave(GetAggressiveState());
				}
				else
				{
					DangerPos = DeadThing.Location;
					GotoStateSave('LookAroundDeadBody');
				}
			}
			else
			{
				// Get mad at the guy kicking it and kick it back!
				Focus = DeadThing;
				InterestActor = DeadThing;
				GotoStateSave('KickHeadBack');
			}
		}
		else // Can't see it so just turn around.
		{
			// Clear our instigator after interaction
			DeadThing.Instigator = None;
			if(KickerPawn != None)
				UseInterest = KickerPawn;
			else
				UseInterest = DeadThing;

			InterestIsAnnoyingUs(UseInterest, true);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// True if this pawn is the anyone (dude or otherwise) dressed up as the gimp
///////////////////////////////////////////////////////////////////////////////
function bool PersonDressedAsGimp(FPSPawn CheckP)
{
	if(GimpController(CheckP.Controller) != None
		|| (P2Player(CheckP.Controller) != None
			&& P2Player(CheckP.Controller).DudeIsGimp()))
		return true;

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// You're getting electricuted, but don't drop your baton
///////////////////////////////////////////////////////////////////////////////
function GetShocked(P2Pawn Doer, vector HitLocation)
{
	if(MyPawn.Physics == PHYS_WALKING)
	{
		SetAttacker(Doer);

		// Drop things if you had them in your hands
		MyPawn.DropBoltons(MyPawn.Velocity);
		
		// Drop your weapon too if you're weak, but if you 
		// have your baton out, don't drop that
		if(MyPawn.TakesShockerDamage == 1.0
			&& BatonWeapon(MyPawn.Weapon) == None)
			ThrowWeapon();

		MakeShockerSteam(HitLocation, PERSON_BONE_PELVIS);

		GotoState('BeingShocked');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get the state to handle someone who's aggressive around us. 
// Cops try to arrest him.. military just attacks.
///////////////////////////////////////////////////////////////////////////////
function Name GetAggressiveState()
{
	return 'TellHimToFreeze';
}

///////////////////////////////////////////////////////////////////////////////
// Go after our attacker again
///////////////////////////////////////////////////////////////////////////////
function FoundHim(FPSPawn OldA)
{
	//log(self$" Found Him "$OldA);
	SetAttacker(OldA);
	GotoStateSave(GetAggressiveState());
}

///////////////////////////////////////////////////////////////////////////////
// Someone's verbally threatened you.. arrest them or run
///////////////////////////////////////////////////////////////////////////////
function HandleMeanTalker(FPSPawn Meanie)
{
	InterestPawn = Meanie;
	SetAttacker(InterestPawn);
	DangerPos = InterestPawn.Location;
	if(MyPawn.bHasViolentWeapon)
		GotoStateSave(GetAggressiveState());
	else
		GotoStateSave('FleeFromAttacker');
}

///////////////////////////////////////////////////////////////////////////////
// During a fight, decide to stop fighting, if he sort of surrenders.
///////////////////////////////////////////////////////////////////////////////
function HandleSurrender(FPSPawn LookAtMe, out byte StateChange)
{
	// STUB--defined in ShootAtAttacker
}

///////////////////////////////////////////////////////////////////////////////
// see if you're close enough to make stuff happen
///////////////////////////////////////////////////////////////////////////////
function NeedToWalkCloser(float CheckDist, optional out byte StateChange)
{
	// STUB--defined in OnTheOffensive
}

///////////////////////////////////////////////////////////////////////////////
// Check the guy you told to drop his weapon. 
///////////////////////////////////////////////////////////////////////////////
function DecideNextStateBasedOnAttacker(optional bool bStart)
{
	// STUB--defined in OnTheOffensive
}

///////////////////////////////////////////////////////////////////////////////
// This guy is changing into a cop uniform right in front of us, arrest him
///////////////////////////////////////////////////////////////////////////////
function HandleNewImpersonator(FPSPawn LookAtMe)
{
	if(Attacker != LookAtMe)
	{
		SetAttacker(LookAtMe);
		InterestPawn = LookAtMe;
		GotoStateSave('HandleGuyChangingIntoCop');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get confused and start looking around for the attacker they just lost
// because he changed clothes when I wasn't able to see it
///////////////////////////////////////////////////////////////////////////////
function LostAttackerToDisguise(FPSPawn LookAtMe)
{
	if(Attacker == LookAtMe)
	{
		// Tell your leader too
		if(MyPawn.MyLeader != None
			&& PoliceController(MyPawn.MyLeader.Controller) != None
			&& !CanSeePawn(LookAtMe, MyPawn.MyLeader))
		{
			// If the leader can't see him
			PoliceController(MyPawn.MyLeader.Controller).LostAttackerToDisguise(LookAtMe);
		}

		// Clear your own vars, and go to where he is
		PlayerHintDropWeapon(Attacker, false);
		bHateAttacker=false;
		FullClearAttacker();
		InterestPawn = None;
		DangerPos = LookAtMe.Location;
		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		SetNextState('LookAroundForTrouble');
		SetEndPoint(DangerPos, CHECK_DANGER_DIST);
		GotoStateSave('RunToTarget');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Try to run interference between the dude and the person he's shooting at,
// this is becuase he's shooting at a civilian, and while we don't condone it
// we don't take lethal action against the dude. We simply try to keep him
// from doing it by getting physically in the way. If the dude shoots us
// we'll attack him
///////////////////////////////////////////////////////////////////////////////
function TryToCauseInterference(FPSPawn Shooter, FPSPawn ShotAt)
{
	InterestPawn = Shooter;
	InterestPawn2 = ShotAt;
	// Invalidate our interest vect so we can use it to keep where we are
	InterestVect = MyPawn.Location;
	InterestVect.x += 4096;
	GotoStateSave('CauseInterference');
}

///////////////////////////////////////////////////////////////////////////////
// An authority figure just yelled something, 
// so spin around and be confused for a second
///////////////////////////////////////////////////////////////////////////////
function CheckAuthorityYell(FPSPawn CreatorPawn, vector blipLoc)
{
	LastAttackedTime = Level.TimeSeconds;
	InterestPawn = PersonController(CreatorPawn.Controller).InterestPawn;
	InterestPawn2 = CreatorPawn;
	if(InterestPawn == None)
		InterestPawn = PersonController(CreatorPawn.Controller).Attacker;
	DangerPos = blipLoc;
	if(IsInState('LegMotionToTarget'))
		bPreserveMotionValues=true;
	SetNextState('PrepRunToInvestigate');
	GotoStateSave('ConfusedByDanger');
}

///////////////////////////////////////////////////////////////////////////////
// You're trying to see what weapon this guy has, but you're too far away
// currently
///////////////////////////////////////////////////////////////////////////////
function TryToSeeWeapon(FPSPawn LookAtMe)
{
	InterestPawn = LookAtMe;
	GotoStateSave('WatchGuyToIdentifyWeapon');
}

///////////////////////////////////////////////////////////////////////////////
// You've just spotted the suspect, so go in to handling mode
///////////////////////////////////////////////////////////////////////////////
function StartWithSuspect(FPSPawn LookAtMe)
{
	InterestPawn = LookAtMe;
	DetermineLeader();
	// If you're the leader, or your team leader doesn't have the situation in
	// hand, then handle it yourself
	if(MyPawn.bTeamLeader
		|| (MyPawn.MyLeader != None
			&& MyPawn.MyLeader.IsInState('OnTheOffensive')))
		GotoStateSave('HandlePossibleSuspect');
}

///////////////////////////////////////////////////////////////////////////////
// What to do once you've picked a sidestep place
///////////////////////////////////////////////////////////////////////////////
function AfterStrategicSideStep(vector checkpoint)
{
	// Now move to it and get ready to shoot again when you get there
	//log("side stepping");
	bDontSetFocus=true;
	SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
	if(Attacker != None)
		DangerPos = Attacker.Location;
	else
		DangerPos = Location;
	if(IsInState('LegMotionToTarget'))
		bPreserveMotionValues=true;
	SetNextState('PrepRunToInvestigate');
	bStraightPath=UseStraightPath();
	GotoStateSave('RunToTargetIgnoreAll');
}

///////////////////////////////////////////////////////////////////////////////
// Point out where this attacker is to someone else
///////////////////////////////////////////////////////////////////////////////
function RatOutAttacker(P2Pawn TheAttacker, P2Pawn Asker)
{
	// Never go after cops
	if(PoliceController(TheAttacker.Controller) == None)
	{
		SetAttacker(TheAttacker);
		InterestPawn = Asker;
		GotoStateSave('RatOutTarget');
	}
}

///////////////////////////////////////////////////////////////////////////////
// I yelled something important. Others might care (like 'drop your weapon')
///////////////////////////////////////////////////////////////////////////////
function OrderYelled(class<AuthorityOrderMarker> ADanger)
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
// We try to only call this once per encounter or really bad 
// thing. This sort of puts out an APB on the player and increases
// a global timer for whole long other cops will hate the player
// on sight.
// Only report the player once(usually). This gets reset usually in Thinking.
///////////////////////////////////////////////////////////////////////////////
function ReportAsWanted(FPSPawn Attacker, optional bool bForce)
{
	local P2GameInfoSingle checkg;

	if(Attacker != None
		&& Attacker.bPlayer
		&& MyPawn.bHasRadio)
	{
		if(!bReportedPlayer || bForce)
		{
			checkg = P2GameInfoSingle(Level.Game);
			checkg.TheGameState.IncreaseCopRadioTime();
			bReportedPlayer=true;
		}
		/*
		else
		{
			// If the cop radio is below the base, and I'm after him, and I'm seeing
			// him, then even if we're reported him, if we have a straight line of
			// sight to him, then keep it above the base
			checkg = P2GameInfoSingle(Level.Game);
			if(checkg.TheGameState.CopRadioBelowBase()
				&& FastTrace(Attacker.Location, MyPawn.Location))
			{
				checkg.TheGameState.CopRadioFloorBase();
			}
		}
		*/
	}
}

///////////////////////////////////////////////////////////////////////////////
// We just got hurt by our attacker, so report him, based on
// how hurt we are.
///////////////////////////////////////////////////////////////////////////////
function ReportAfterHit()
{
	// If we get hit by the player, bump it up based on how hurt we are
	// The more hurt we are, the more likely we will report him more
	if(FRand() > (MyPawn.Health/MyPawn.HealthMax))
		ReportAsWanted(Attacker, true);
}

///////////////////////////////////////////////////////////////////////////////
// If the player is still wanted, then play a sound as you radio headquarters
///////////////////////////////////////////////////////////////////////////////
function float RadioHQ()
{
	local P2GameInfoSingle checkg;
	local int i;

	checkg = P2GameInfoSingle(Level.Game);
	if(checkg.TheGameState.PlayCopRadio()
		&& MyPawn.bHasRadio)
	{
		// randomly pick a radio sound
		i = Rand(RadioSounds.Length);
		MyPawn.PlaySound(RadioSounds[i]);
		return MyPawn.GetSoundDuration(RadioSounds[i]);
	}
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// Here what bad thing just happened
///////////////////////////////////////////////////////////////////////////////
function HereAboutBadThing()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// As long as you have patrol tags, you'll and make footstep noises
///////////////////////////////////////////////////////////////////////////////
function SetToPatrolJail()
{
	//log(MyPawn$" SetToPatrolJail ");
	bPatrolJail=true;
	SetToPatrolPath();	
}

///////////////////////////////////////////////////////////////////////////////
// Start patrolling your PatrolNodes.
///////////////////////////////////////////////////////////////////////////////
function SetToPatrolPath()
{
	Super.SetToPatrolPath();
	if(bPatrolJail)
		SetNextState('PatrolJailToTarget');
		
	if (MyPawn.PatrolNodes.Length == 0)
		warn("================= I'M A PATROL OFFICER AND I HAVE NO PATROL NODES"@Self@MyPawn);
}

///////////////////////////////////////////////////////////////////////////////
// You've been bumped while in jail and want to check it out
///////////////////////////////////////////////////////////////////////////////
function CheckDisturbanceInJail(actor Other)
{
	InterestPawn = FPSPawn(Other);
	DangerPos = Other.Location;
	bPreserveMotionValues=true;
	SetNextState(GetStateName());
	GotoStateSave('ConfusedByDanger');
}

///////////////////////////////////////////////////////////////////////////////
// Depending on the situation, know the same thing your partner knows..
// if he's attacking someone, back him up, if he's telling someone to freeze,
// then follow along
// Don't help non-cops attack the dude cop,uphold the blue wall!
///////////////////////////////////////////////////////////////////////////////
function GainPartnersKnowledge(PersonController NewPartner, out byte Worked, out byte AttackingDudeCop)
{
	if(Attacker == None
		|| Attacker.Health <= 0)
	{
		if(NewPartner != None)
		{
			if(DudeDressedAsCop(NewPartner.Attacker))
				AttackingDudeCop=1;
			else
			{
				Focus = NewPartner.Focus;
				InterestPawn = NewPartner.InterestPawn;
				InterestPawn2 = NewPartner.MyPawn;	// Keep track of the guy who got us involved
				// Don't get any more info than your partner does on the attacker, make
				// sure to only copy over his version of where the attacker is
				SetAttacker(NewPartner.Attacker, true);
				LastAttackerPos = NewPartner.LastAttackerPos;
				Worked=1;
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Search the area for another cop, if you are the only cop in the area
// make yourself the leader. If there's another cop in the area already
// as the leader, make him your leader
///////////////////////////////////////////////////////////////////////////////
function DetermineLeader(optional bool bForceRedo)
{
	local P2Pawn CheckP, PickMe;
	local PersonController pcont;
	local float closest, dist, RadCheck;

	// Check if we have a valid leader
	if(MyPawn.MyLeader != None)
	{
		pcont = PersonController(MyPawn.MyLeader.Controller);

		if(MyPawn.MyLeader.Health > 0						// Our leader's alive
			&& MyPawn.MyLeader.bTeamLeader					// He still thinks he's a leader
			&& !MyPawn.MyLeader.bDeleteMe					// He's not deleted
			&& pcont != None								// He's actually got a controller still
			&& pcont.CanHelpOthers()						// If he's not hurt bad/distracted heavily.
			&& (pcont.Attacker != None						// and he's dealing with someone (other than none)
				|| pcont.InterestPawn != None))
		{
			// Use this leader if either we don't have an attacker, or we have the same
			// attacker as our leader
			if(Attacker == None
					|| Attacker == pcont.Attacker)
			{
				// If you have a line of sight to the attacker, but your leader doesn't
				// then make him not be the leader anymore
				if(Attacker != None
					&& !FastTrace(Attacker.Location, MyPawn.MyLeader.Location)
					&& FastTrace(Attacker.Location, MyPawn.Location))
				{
					// Say he's not a leader anymore
					MyPawn.MyLeader.bTeamLeader = false;
					MyPawn.MyLeader = None;
				}
				else
					return;	// have valid leader, so don't look again
			}
			else // If we don't pick/already have the same attacker as our leader, then
				// Be our own leader
			{
				MyPawn.bTeamLeader = true;
				MyPawn.MyLeader = None;
			}
		}
		else
		{
			MyPawn.MyLeader = None;
		}
	}

	// Already a leader, so don't look again, unless we want to
	// recheck with all our leaders
	if(!bForceRedo
		&& MyPawn.bTeamLeader)
		return;

	RadCheck = CHECK_FOR_LEADER_RADIUS;

	closest = RadCheck;

//	log(MyPawn$" look for a leader");

	// Check all the pawns around me.
	ForEach VisibleCollidingActors(class'P2Pawn', CheckP, RadCheck, MyPawn.Location)
	{
		if(CheckP != MyPawn)
		{
			//log(MyPawn$" saw him "$CheckP);
		
			if(CheckP.bTeamLeader)
			{
				MyPawn.bTeamLeader = false;
				MyPawn.MyLeader = CheckP;
			}
		}
	}

	// Couldn't find a leader already, so make me the leader
	if(MyPawn.MyLeader == None)
	{
//		log(MyPawn$" making me the leader");
		MyPawn.bTeamLeader = true;
	}
	//else
	//	log(MyPawn$" making him the leader "$MyPawn.MyLeader);
}

///////////////////////////////////////////////////////////////////////////////
// Search the area for other cops, and make sure they all do the same
// thing as you, if they have the same attacker as you
// Don't send me to this state too, I'll handle it on my own
///////////////////////////////////////////////////////////////////////////////
function FollowLeadersState(Name UseThisState, 
							optional Name UseNextState, 
							optional Name UseNextLabel,
							optional Actor UseGoal, 
							optional vector UsePoint,
							optional float UseRad,
							optional bool bUpdateAttackerLoc,
							optional bool bRequiresLineOfSight,
							optional bool bClearAttacking)
{
	local P2Pawn CheckP;
	local PoliceController pcont;
	local float RadCheck;

	RadCheck = CHECK_FOR_LEADER_RADIUS;

	// Tell all pawn cops around me with the same attacker
	// as me, to do this state
	ForEach VisibleCollidingActors(class'P2Pawn', CheckP, RadCheck, MyPawn.Location)
	{
		if(CheckP != MyPawn)
		{
			pcont = PoliceController(CheckP.Controller);
			if(pcont != None
				&& pcont != self
				&& pcont.CanHelpOthers()
				&& pcont.Attacker == Attacker
				&& (!bRequiresLineOfSight
					|| pcont.LineOfSightTo(Attacker)))
			{
				if(!pcont.IsInState(UseThisState))
				{
					if(UseNextState != '')
					{
						if(pcont.IsInState('LegMotionToTarget'))
							pcont.bPreserveMotionValues=true;
						pcont.SetNextState(UseNextState);
					}

					if(bUpdateAttackerLoc)
						pcont.SaveAttackerData();

					if(bClearAttacking)
					{
						pcont.Enemy = None;
						pcont.firecount = 0;
					}

					if(UseRad > 0)
					{
						if(UseGoal != None)
							pcont.SetEndGoal(UseGoal, UseRad);
						else 
							pcont.SetEndPoint(UsePoint, UseRad);
					}

					//log(CheckP$" Following leader state ... "$UseThisState@"MissingLimbs"@P2MocapPawn(CheckP).bMissingLimbs);
					pcont.GotoStateSave(UseThisState);
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Take the first one, as old leader, and turn him into a follower of NewLeader
// along with anyone else around who cares.
///////////////////////////////////////////////////////////////////////////////
function DoLeaderSwap(P2Pawn OldLeader, P2Pawn NewLeader)
{
	local P2Pawn CheckP;
	local PoliceController pcont;
	local float RadCheck;

	RadCheck = CHECK_FOR_LEADER_RADIUS;

	// Make sure the old leader, is no longer a leader
	OldLeader.bTeamLeader=false;
	OldLeader.MyLeader=None;

	// Make the new leader official
	NewLeader.bTeamLeader=true;
	NewLeader.MyLeader=None;

	ForEach VisibleCollidingActors(class'P2Pawn', CheckP, RadCheck, MyPawn.Location)
	{
		if(CheckP != OldLeader
			&& CheckP != NewLeader)
		{
			pcont = PoliceController(CheckP.Controller);
			if(pcont != None
				&& (CheckP.MyLeader == OldLeader
				|| CheckP.MyLeader == None))
			// If a cop without a leader, or an old leader, then
			// pick NewLeader
			{
				CheckP.bTeamLeader=false;
				CheckP.MyLeader=NewLeader;
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// This leader is no longer valid, so all those around, unhook them. The other
// stragglers will find out in time
///////////////////////////////////////////////////////////////////////////////
function UnhookLeader()
{
	local P2Pawn CheckP;
	local PoliceController pcont;
	local float RadCheck;

	RadCheck = CHECK_FOR_LEADER_RADIUS;

	MyPawn.bTeamLeader=false;
	MyPawn.MyLeader=None;

	// Tell all pawn cops around me he's no longer the leader
	ForEach VisibleCollidingActors(class'P2Pawn', CheckP, RadCheck, MyPawn.Location)
	{
		if(CheckP != MyPawn)
		{
			pcont = PoliceController(CheckP.Controller);
			if(pcont != None
				&& CheckP.MyLeader == MyPawn)
			{
				CheckP.bTeamLeader=false;
				CheckP.MyLeader=None;
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Someone else is at least as dangerous at the guy I'm dealing
// with, so send someone to handle them, or do it myself
///////////////////////////////////////////////////////////////////////////////
function HandleNewThreat(FPSPawn NewThreat)
{
/*
	local P2Pawn CheckP;
	local PoliceController pcont;
	local float RadCheck;

	RadCheck = CHECK_FOR_LEADER_RADIUS;

	// Check all the pawns around me.
	ForEach VisibleCollidingActors(class'P2Pawn', CheckP, RadCheck, MyPawn.Location)
	{
		if(CheckP != MyPawn)
		{
			// See if any other cops around don't already have this
			// guy as their attacker
			pcont = PoliceController(CheckP.Controller);
			if(pcont != none
				pcont.Attacker )
			{
				//log(MyPawn$" saw him "$CheckP);
			
				if(CheckP.bTeamLeader)
				{
					MyPawn.bTeamLeader = false;
					MyPawn.MyLeader = CheckP;
				}
			}
		}
	}
*/
	SetAttacker(NewThreat);
	InterestPawn = NewThreat;
	SetNextState('AssessAttacker');
	GotoStateSave('ConfusedByDanger');
}

///////////////////////////////////////////////////////////////////////////////
// Make sure the pawn is a player
// Set the player's last seen weapon to something
///////////////////////////////////////////////////////////////////////////////
function SetLastWeaponSeen(FPSPawn SetPawn, class<P2Weapon> NewType)
{
	local P2Player p2p;
	
	// If it's a weapon that can't be thrown then just say they have to put it away, not necessarily toss it.
	if (!NewType.Default.bCanThrow)
		return;

	if(SetPawn != None)
	{
		p2p = P2Player(SetPawn.Controller);
		if(p2p != None)
			p2p.LastWeaponSeen = NewType;
	}
}

///////////////////////////////////////////////////////////////////////////////
// If a leader, see if he knows the attacker still has a weapon, if so
// return true, otherwise, return false, including if you're not a leader.
///////////////////////////////////////////////////////////////////////////////
function bool LeaderSensesWeapon()
{
	local P2Player p2p;

	PlayerHintDropWeapon(Attacker, true);

	if(!MyPawn.bTeamLeader)
		return false;

	p2p = P2Player(Attacker.Controller);
	if(p2p != None
		&& p2p.LastWeaponSeen == None)
		return false;

	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Start killing with some banter
///////////////////////////////////////////////////////////////////////////////
function GoKilling()
{
	local float MouthOff;
	local bool bPantsDown;
	local name NState;

	bPantsDown = Attacker.HasPantsDown();
	if(bPantsDown)
		NState = 'ShootAtAttacker';
	else
		NState = 'AssessAttacker';

	if(MyPawn.bTeamLeader)
	{
		MouthOff = 1.0;
		FollowLeadersState(NState);
	}
	else
		MouthOff = NON_LEADER_MOUTHS_OFF;


	// If the attacker is looking mean (other than just concealing his weapon)
	// then say something mean to him, because you'll be attacking for a while
	if((!Attacker.ViolentWeaponNotEquipped()
			|| bPantsDown)
		&& FRand() > MouthOff)
	{
		Say(MyPawn.myDialog.lCop_SomeoneDisobeyed);
		PrintDialogue("Wrong move, shithead");
		MyPawn.StopAcc();
	}

	GotoStateSave(NState);
}

///////////////////////////////////////////////////////////////////////////////
// See if you're too pissed off that you start the killing
///////////////////////////////////////////////////////////////////////////////
function bool CheckToGoKilling(optional bool bShootNow)
{
	if(MyPawn.Anger > FRand())
	{
		// If the attacker is looking mean (other than just concealing his weapon)
		// then say something mean to him, because you'll be attacking for a while
		if((!Attacker.ViolentWeaponNotEquipped()
			|| Attacker.HasPantsDown())
			&& (MyPawn.bTeamLeader
			|| FRand() > NON_LEADER_MOUTHS_OFF))
		{
			Say(MyPawn.myDialog.lCop_SomeoneDisobeyed);
			PrintDialogue("Wrong move, shithead");
			MyPawn.StopAcc();
		}

		// If you're so mad you must shoot now, jump to it
		if(bShootNow)
		{
			if(!Attacker.HasPantsDown())
				GotoStateSave('ShootAtAttacker', 'FireNowPrep');
			else
				GotoStateSave('ShootAtAttacker');
		}
		else
			GotoStateSave('AssessAttacker');

		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Get a message from someone who said this guy attacked you
///////////////////////////////////////////////////////////////////////////////
function HearWhoAttackedMe(FPSPawn TheAttacker, Pawn Teller)
{
	// We know who did it, so focus on him now
	// Maybe check the validity of who told us this?
	SetAttacker(TheAttacker);
	Focus = TheAttacker;
	PrintDialogue("Thanks! "$Pawn);
	Say(MyPawn.myDialog.lThanks);
	GotoStateSave('AssessAttacker');
}

///////////////////////////////////////////////////////////////////////////////
// Get a message from someone telling you about a 'known' killer
///////////////////////////////////////////////////////////////////////////////
function HearAboutKiller(vector DangerLoc, FPSPawn TheAttacker, Pawn Teller, float WaitTime)
{
	InterestPawn = TheAttacker;	// He's not really an attacker yet
	Focus = Teller;
	SayTime = WaitTime;
	DangerPos = DangerLoc;
	LastAttackerPos = DangerPos;
	GotoStateSave('PrepRunToInvestigateKiller');
}

///////////////////////////////////////////////////////////////////////////////
// Get a message from someone telling you about danger
///////////////////////////////////////////////////////////////////////////////
function HearAboutDangerHere(vector DangerLoc, Pawn Teller, float WaitTime)
{
	Focus = Teller;
	SayTime = WaitTime;
	DangerPos = DangerLoc;
	GotoStateSave('PrepRunToInvestigateDanger');
}

///////////////////////////////////////////////////////////////////////////////
// Cop calls to someone that he needs to make sure they don't have
// a weapon
///////////////////////////////////////////////////////////////////////////////
function INeedToSeeYouHaveNoWeapon(FPSPawn Asker, FPSPawn CheckPawn)
{
	local PersonController lbcheck;

	lbcheck = PersonController(CheckPawn.Controller);
	if(lbcheck != None)
	{
		// See if we have a real weapon or not
		lbcheck.SwitchToBestWeapon();
		if(CheckPawn.Weapon != None
			&& ConcernedAboutWeapon(P2Weapon(CheckPawn.Weapon)))
		{
			// if we do, then we freak out and attack the asker
			lbcheck.SetAttacker(Asker);
			lbcheck.GotoStateSave('AssessAttacker');
		}
		// we comply
		else
		{
			Focus = Asker;
			RespondToCopBother();
		}
	}
}

///////////////////////////////////////////////////////////////////////////
// This function shouldn't be ignored (though it's counterpart below certainly
// may be). This registers with the pawn that 
///////////////////////////////////////////////////////////////////////////
function HitWithFluid(Fluid.FluidTypeEnum ftype, vector HitLocation)
{
	// Hit the pawn, so make it drip
	MyPawn.MakeDrip(ftype, HitLocation);
}

///////////////////////////////////////////////////////////////////////////////
// There was fire in our way, decide what to do
///////////////////////////////////////////////////////////////////////////////
function HandleFireInWay(FireEmitter ThisFire)
{
	local byte DoRun;

	//log("fire emitter owner "$ThisFire.Owner);

	InterestActor = ThisFire;

	if(Attacker != None)
	{
		GotoStateSave('ShootAttackerBehindFire');
	}
	else
	{
		SetupWatchFire(DoRun);
		GotoState('');// clear out of walking, maybe
		SetNextState('ManageBystandersAroundFire');
		if(DoRun == 1)
			GotoStateSave('RunToFireSafeRange');
		else
			GotoStateSave('WalkToFireSafeRange');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Someone might have shouted get down, said hi, or asked for money.. see what to do
// Go to state to see if we care to get down after someone told us to
///////////////////////////////////////////////////////////////////////////////
function RespondToTalker(Pawn Talker, Pawn AttackingShouter, ETalk TalkType, out byte StateChange)
{
	if(MyPawn.MyBodyFire != None)
		return;

	// Check first if the guy talking to us is in our home!
	CheckForIntruder(FPSPawn(Talker), StateChange);
	if(StateChange == 1)
		return;

	// He's not in our home, so proceed
	switch(TalkType)
	{
		case TALK_getdown:
			// More often you've been told to get down and didn't, more likely you are to just skip
			// this state
			if(!(ToldGetDownCount > 2					// min times they can be told and still pay attention
				&& FRand() <= ToldGetDownCount/MAX_GET_DOWN_BLUFF))	// max times before they'll never listen again
			{
				if(MyPawn.Physics == PHYS_WALKING)
				{
					// Ignore other cops and military and swat, only 
					// investigate bystanders (includes dude)
					if(Talker.IsA('Bystander'))
					{
						// Point at the shouter
						Focus = Talker;
						bPreserveMotionValues=true;
						GotoStateSave('DecideToGetDown');
						StateChange=1;
						return;
					}
				}
			}
		break;
		case TALK_askformoney:
			DonateSetup(Talker, StateChange);
		break;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Go to state to see if we care to get down after someone told us to
///////////////////////////////////////////////////////////////////////////////
function ForceGetDown(Pawn Shouter, Pawn AttackingShouter)
{
	if(MyPawn.Physics == PHYS_WALKING
		&& MyPawn.MyBodyFire == None)
	{
		if(!IsInState('LegMotionToTarget'))
		{
			// If the attacker has his pants down *don't* crouch in front of him.. move somehow
			if(Attacker != None
				&& Attacker.HasPantsDown())
			{
				StrategicSideStep();
			}
			else
				MyPawn.ShouldCrouch(true);
		}

		/*
		InterestPawn = P2Pawn(Shouter);
		InterestPawn2 = P2Pawn(AttackingShouter);

		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;

		GotoStateSave('CrouchForOther');
		*/
	}
}

///////////////////////////////////////////////////////////////////////////////
// You've been told by TellingPawn to get out of his way. Decide what to do
///////////////////////////////////////////////////////////////////////////////
function GetOutOfMyWay(P2Pawn Shouter, P2Pawn AttackingShouter, out byte StateChange)
{
	// if it's anyone important, then listen to them.
	if(!Shouter.IsA('Bystander'))
	{
		// just get down, becuase he needs to shoot
		ForceGetDown(Shouter, AttackingShouter);
	}
}

///////////////////////////////////////////////////////////////////////////////
// If this was a live player, tell him to drop his weapon
// with a hint on the hud
// Only team leader do this
///////////////////////////////////////////////////////////////////////////////
function PlayerHintDropWeapon(FPSPawn MyAttacker, bool bTurnHintsOn, optional bool bStartAllowingHints)
{
	local P2Player p2p;
	local bool bRecheck;

	if(!MyPawn.bTeamLeader)
		return;

	if(MyAttacker != None)
		p2p = P2Player(MyAttacker.Controller);

	if(p2p != None)
	{
		// This basically turns on the ability to have hints. This should only happen after
		// the first time this cop yells a command like 'freeze'. This function could get
		// called several times before this is true, so it will just short circuit, otherwise
		// Once it's turned on though, the other states, like running to a suspect will 
		// allow hints
		if(bStartAllowingHints)
			bAllowHints=true;

		if(!bAllowHints)
			return;

		if(bTurnHintsOn)
		{
			p2p.bShowWeaponHints=true;

			if(p2p.LastWeaponSeen != None)
			{
				if(p2p.LastWeaponSeen.default.ViolenceRank <= 0)
				{
					bRecheck=true;
					p2p.LastWeaponSeen = None;
				}
				else
				{
					// If we have a weapon we know he has, check his inventory to see if he's dropped
					// it yet or not.
					// If so, mark him, so we know he's dropped it.
					if(MyAttacker.FindInventoryType(p2p.LastWeaponSeen) == None)
					{
						bRecheck=true;
					}
				}
			}
			else
				bRecheck=true;

			if(bRecheck)
			{
				if(!MyAttacker.ViolentWeaponNotEquipped())
				{
					// Reset everything and say we're concerned about what you have
					SetLastWeaponSeen(MyAttacker, class<P2Weapon>(MyAttacker.Weapon.class));
				}
				else
					SetLastWeaponSeen(MyAttacker, None);
			}
		}
		else
		{
			p2p.bShowWeaponHints=false;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// When you switch attackers, if the old one is the player, check
// to make sure you turn off his hints, if you're not concerned with him
// anymore
///////////////////////////////////////////////////////////////////////////////
function SetAttacker(Pawn NewA, optional bool bDontUpdateLocation)
{
	local P2Player p2p;

	// First turn off possible hints for old attacker
	// And say you don't hate him anymore (because you'd be automatically hating your new attacker)
	if(Attacker != NewA)
	{
		bHateAttacker=false;
		PlayerHintDropWeapon(Attacker, false);
		SetLastWeaponSeen(Attacker, None);
	}

	Super.SetAttacker(NewA, bDontUpdateLocation);
}

///////////////////////////////////////////////////////////////////////////////
// Find a player and kick his butt
///////////////////////////////////////////////////////////////////////////////
function SetToAttackPlayer(FPSPawn PlayerP)
{
	local FPSPawn keepp;

	if(PlayerP == None)
		keepp = GetRandomPlayer().MyPawn;
	else
		keepp = PlayerP;

	// check for some one to attack
	if(keepp != None)
	{
		MyPawn.DropBoltons(Velocity);
		
		// If they're dressed as a cop, just run there and look around
		if(DudeDressedAsCop(keepp))
		{
			DangerPos = keepp.Location;
			SetEndPoint(DangerPos, CHECK_DANGER_DIST);
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			SetNextState('LookAroundForTrouble');
			GotoStateSave('RunToTarget');
		}
		else // Otherwise, attack the player
		{
			if(!MyPawn.bNoTriggerAttackPlayer)
			{
				SetAttacker(keepp);
				GotoStateSave('AssessAttacker');
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// When triggered, they will attack the player, wherever he is
///////////////////////////////////////////////////////////////////////////////
function CopTrigger( actor Other, pawn EventInstigator )
{
	local P2Player keepp;
	
	//log(self@"cop trigger by"@other@eventinstigator);

	// If you're ready, go for it.
	if(!MyPawn.bIgnoresHearing
		&& !MyPawn.bIgnoresSenses)
	{
		if(Attacker == None)
		{
			// When we get triggered, we attack the player.
			keepp = GetRandomPlayer();

			// Check for person to attack
			if(keepp != None)
			{
				// If they're dressed as a cop, just run there and look around
				if(DudeDressedAsCop(keepp.MyPawn))
				{
					DangerPos = keepp.MyPawn.Location;
					SetEndPoint(DangerPos, CHECK_DANGER_DIST);
					if(IsInState('LegMotionToTarget'))
						bPreserveMotionValues=true;
					SetNextState('LookAroundForTrouble');
					GotoStateSave('RunToTarget');
				}
				else // Otherwise, attack the player
				{
					if(!MyPawn.bNoTriggerAttackPlayer)
					{
						SetAttacker(keepp.MyPawn);
						GotoStateSave('AssessAttacker');
					}
				}
			}
		}
	}
	else	// if not ready, get ready, but don't attack yet.
	{
		MyPawn.bIgnoresHearing=false;
		MyPawn.bIgnoresSenses=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// When triggered, they will attack the player, wherever he is
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, pawn EventInstigator )
{
	// Patrolling cops are never allowed normal triggers..they can only
	// be triggered when in their patrolling state
	if(!bPatrolJail)
		CopTrigger(Other, EventInstigator);
	else
	{
		if(ScriptedTrigger(Other) != None)
		{
			if(Attacker == None)
			{
				bPreserveMotionValues=true;

				// Check various options.. maybe they are in the walk/run patrol state, 
				// then act accordingly. If they are not, then each needs to check the old
				// state first. If neither switch on that, test with the next state.
				// If these are bundled together in an OR conditional, it will mess up when
				// the old state is walking, because it just ran and will pick run again
				// even though it really wants to go back to walking.
				if(GetStateName() == WALK_PATROL_STATE)
				{
					// When triggered, start running in panick--someone set off the fire alarm
					GotoStateSave(RUN_PATROL_STATE);
					return;
				}
				else if(GetStateName() == RUN_PATROL_STATE)
				{
					// When triggered, stop running in panick--the fire alarm is off
					GotoStateSave(WALK_PATROL_STATE);
					return;
				}
				else if(MyOldState == WALK_PATROL_STATE)
				{
					// When triggered, start running in panick--someone set off the fire alarm
					GotoStateSave(RUN_PATROL_STATE);
					return;
				}
				else if(MyOldState == RUN_PATROL_STATE)
				{
					// When triggered, stop running in panick--the fire alarm is off
					GotoStateSave(WALK_PATROL_STATE);
					return;
				}
				else if(MyNextState == WALK_PATROL_STATE)
				{
					// When triggered, start running in panick--someone set off the fire alarm
					GotoStateSave(RUN_PATROL_STATE);
					return;
				}
				else if(MyNextState == RUN_PATROL_STATE)
				{
					// When triggered, stop running in panick--the fire alarm is off
					GotoStateSave(WALK_PATROL_STATE);
					return;
				}
			}
		}
		else
			CopTrigger(Other, EventInstigator);
	}
}

///////////////////////////////////////////////////////////////////////////////
// If the player bumps me and I'm looking for him, spin around...
///////////////////////////////////////////////////////////////////////////////
function DangerPawnBump( Actor Other, optional out byte StateChange )
{
	local P2Pawn ppawn;
	
	ppawn = P2Pawn(Other);

	// Only check players, unless he's dressed as a cop
	if(ppawn != None
		&& ppawn.bPlayer
		&& !DudeDressedAsCop(FPSPawn(Other)))
	{
		// Arrest him if wanted
		if(MyPawn.bHasRadio 
			&& P2GameInfoSingle(Level.Game).TheGameState.CopsWantPlayer() > 0)
		{
			SetAttacker(ppawn);
			SaveAttackerData();
			DangerPos = Other.Location;
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			SetNextState('AssessAttacker');
			GotoStateSave('ConfusedByDanger');
			StateChange=1;
		}
		// Arrest him breaking out of jail
		else if(P2GameInfoSingle(Level.Game).TheGameState.bArrestPlayerInJail)
		{
			CheckDisturbanceInJail(Other);
			StateChange=1;
		}
	}

	if(StateChange != 1)
		Super.DangerPawnBump(Other, StateChange);
}

///////////////////////////////////////////////////////////////////////////////
// Look around for zombies and either kill them or run
///////////////////////////////////////////////////////////////////////////////
function LookForZombies(optional out byte StateChange)
{
	local Actor CheckP;
	local FPSPawn KeepP;
	local float checkdist, keepdist;

	if(LookZombieClass != None)
	{
		checkdist = MyPawn.ReportLooksRadius;
		keepdist = checkdist;

		foreach MyPawn.CollidingActors(LookZombieClass, CheckP, MyPawn.ReportLooksRadius, MyPawn.Location)
		{
			// If not me
			if(CheckP != MyPawn
				&& !CheckP.bDeleteMe
				&& FPSPawn(CheckP) != None
				// if still alive (and not dying)
				&& FPSPawn(CheckP).Health > 0)
			{
				if(KeepP == None)
					KeepP = FPSPawn(CheckP);
				checkdist = VSize(CheckP.Location - MyPawn.Location);
				if(checkdist < keepdist)
				{
					KeepP = FPSPawn(CheckP);
					keepdist = checkdist;
				}
			}
		}
	}
	// If we found one deal with him
	if(KeepP != None)
	{
		// Tell the SP NPC's about the zombie
		CheckObservePawnLooks(KeepP);
		StateChange = 1;
		return;
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
	///////////////////////////////////////////////////////////////////////////
	// nothing on my mind when we start
	///////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		SwitchToHands();

		// clear vars
		if(Focus != None)
			FocalPoint = Focus.Location;
		Focus = None;
		FullClearAttacker();
		bReportedPlayer=false;
		InterestPawn=None;
		InterestActor=None;
		CurrentInterestPoint = None;
		UsePatience=MyPawn.Patience;
		UseReactivity = MyPawn.Reactivity;
		EndGoal = None;
		EndRadius = 0;
		DistanceRun = 0;
		bSaidGetDown=false;
		SafePointStatus=SAFE_POINT_INVALID;
		bPanicked=false;
		QLineStatus=EQ_Nothing;
		MyPawn.SetMood(MOOD_Normal, 1.0);
		MyPawn.bTeamLeader=false;
		MyPawn.MyLeader=None;
		MyPawn.StopAllDripping();
		SetNextState('');

		// return to normal alertness
		if(MyPawn != None)
		{
			UseReactivity = MyPawn.Reactivity;
			UsePatience = MyPawn.Patience;
		}

		if(MyPawn.bLookForZombies)
			LookForZombies();

		HandleStasisChange();
	}

Begin:
	Sleep(FRand());

	// Check to do a patrol
	if(MyPawn.PatrolNodes.Length > 0)
	{
		Sleep(2.0);
		SetToPatrolPath();
		GotoNextState();
	}

	// Otherwise walk around randomly
	if(!bPreparingMove)
	{
		// walk to some random place I can see (not through walls)
		SetNextState('Thinking');
		if(!PickRandomDest())
		{
			// If i'm actively seeking the player, then I'm checking to the
			// HQ with the radio. So make some radio noises
			Sleep(RadioHQ());

			Goto('Begin');	// Didn't find a valid point, try again
		}

		// If i'm actively seeking the player, then I'm checking to the
		// HQ with the radio. So make some radio noises
		RadioHQ();

		GotoStateSave('WalkToTarget');
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
// Stand around and don't do too much
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state StandAround
{
	function BeginState()
	{
		Super.BeginState();

		if(FRand() <= BackToHandsFreq)
			SwitchToHands();
	}

Begin:
	// Tell others if you have a weapon out
	ReportViolentWeaponNoStasis();

	Sleep(FRand()*10 + 5);

	// If i'm actively seeking the player, then I'm checking to the
	// HQ with the radio. So make some radio noises
	Sleep(RadioHQ());

	// Randomly, and not very often, check if you want to do an idle
	if(FRand() <= DO_IDLE_FREQ)
		GotoStateSave('PerformIdle');

	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// See what the wetness on us is. If we're facing the pissing person, then
// we short-circuit because we immediately know what's happening.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state InvestigateWetness
{
	///////////////////////////////////////////////////////////////////////////////
	// We've seen the pawn, now decide if we care
	///////////////////////////////////////////////////////////////////////////////
	function ActOnPawnLooks(FPSPawn LookAtMe, optional out byte StateChange)
	{
		local P2Weapon p2weap;
		local vector dir;
		local bool bcheck;

		// if it's a crazy animal, run or fight it
		if(AnimalPawn(LookAtMe) != None)
		{
			if(AnimalPawn(LookAtMe).bDangerous)
			{
				if(MyPawn.bHasViolentWeapon)
				{
					// Drop things if you had them in your hands
					MyPawn.DropBoltons(MyPawn.Velocity);
					SetAttacker(LookAtMe);
					MakeMoreAlert();
					SaveAttackerData(LookAtMe);
					GotoStateSave('RecognizeAttacker');
				}
				else
				{
					GenSafeRangeMin();
					InterestPawn = LookAtMe;
					SetAttacker(InterestPawn);
					DangerPos = Attacker.Location;
					GotoStateSave('FleeFromAttacker');
				}
				StateChange=1;
			}
			return;
		}

		// We don't care about other cops,etc
		if(FriendWithMe(LookAtMe))
			return;

		// If the dude, and you're friends with him, don't care what he looks like
		if(MyPawn.bPlayerIsFriend && LookAtMe.bPlayer)
			return;

		// Check to see if we care what he's doing or what he looks like
		p2weap = P2Weapon(LookAtMe.Weapon);
		if(p2weap != None)
		{
			if(LookAtMe.HasPantsDown()
				&& LookAtMe.Weapon.IsFiring())
			{
				GoKilling();
			}
			// We already know he has his pants down and is peeing on us, so
			// only act differently if he's switched to his gun.
			else if(ConcernedAboutWeapon(p2weap)
				&& WeaponTurnedToUs(LookAtMe, MyPawn))
			{
				if(P2Player(Attacker.Controller) != None)
				{
					GotoStateSave(GetAggressiveState());
					StateChange=1;
					return;
				}
			}
		}
		return;
	}

	///////////////////////////////////////////////////////////////////////////////
	// You currently only care about the looks of your attacker/aggressor
	///////////////////////////////////////////////////////////////////////////////
	function CheckObservePawnLooks(FPSPawn LookAtMe)
	{
		SetRotation(MyPawn.Rotation);

		if(Attacker == LookAtMe
			&& CanSeePawn(MyPawn, LookAtMe))
			// We can see this pawn
			ActOnPawnLooks(LookAtMe);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Run away (to get away from the piss!) then turn around and kick his butt or arrest him
	///////////////////////////////////////////////////////////////////////////////
	function RunAwayOrFight()
	{
		local vector dir;

		SetAttacker(InterestPawn);
		Focus = InterestPawn;

		if(FRand() <= MyPawn.Anger
			|| Enemy == InterestPawn)
		{
			// Make our leader tell everyone to beat you, or do it myself, if I'm the leader
			if(MyPawn.MyLeader != None
				&& PoliceController(MyPawn.MyLeader.Controller) != None)
				PoliceController(MyPawn.MyLeader.Controller).GoKilling();
			else
				GoKilling();
		}
		else
		{
			// Pick a distance away to run to
			dir = MyPawn.Location - Attacker.Location;
			dir = Normal(dir);
			dir = MyPawn.Location + PISS_RUN_AWAY_DIST*dir;

			GetMovePointOrHugWalls(dir, MyPawn.Location, PISS_RUN_AWAY_DIST, true);

			SetEndPoint(dir, DEFAULT_END_RADIUS);

			GetMoreAngry(MyPawn.Temper);
			//PrintDialogue("Ewwww...");
			MyPawn.DisgustedSpitting(MyPawn.myDialog.lGettingPissedOn);
			SetNextState(GetAggressiveState());
			GotoStateSave('RunFromPisser');
		}
	}

	///////////////////////////////////////////////////////////////////////////////	
	// Check to see if you see the pisser already 
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		if(InterestPawn.bPlayer)
			bImportantDialog = true;

		// if they're already pissing on us (we know about it)
		if(Attacker == InterestPawn)
		{
			//PrintDialogue("Oh, that's it.");
			SayTime = Say(MyPawn.myDialog.lAfterGettingPissedOn, bImportantDialog);
		}
		else if(CanSeePawn(MyPawn, InterestPawn)) // see if we're watching them do this
		{
			DetermineLeader();

			PrintDialogue("Hey, what are you doing!!");
			MyPawn.DisgustedSpitting(MyPawn.myDialog.lGettingPissedOn);
		}
		else
			//PrintDialogue("What the...?");
			SayTime = Say(MyPawn.myDialog.lWhatThe, bImportantDialog);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Clear important dialog
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		bImportantDialog=false;
	}

Begin:
	MyPawn.StopAcc();
	// Turn towards the person pissing on us
	Focus = InterestPawn;
	Sleep(SayTime);
	// We don't deal well with the pisser

	RunAwayOrFight();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// We know he's pouring gasoline on us
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ReactToGasoline
{
	///////////////////////////////////////////////////////////////////////////////
	// We've seen the pawn, now decide if we care
	///////////////////////////////////////////////////////////////////////////////
	function ActOnPawnLooks(FPSPawn LookAtMe, optional out byte StateChange)
	{
		local P2Weapon p2weap;
		local vector dir;
		local bool bcheck;

		// We don't care about other cops,etc
		if(FriendWithMe(LookAtMe))
			return;

		// If the dude, and you're friends with him, don't care what he looks like
		if(MyPawn.bPlayerIsFriend && LookAtMe.bPlayer)
			return;

		// Check to see if we care what he's doing or what he looks like
		p2weap = P2Weapon(LookAtMe.Weapon);

		if(p2weap != None)
		{
			// We already know he has his pants down and is peeing on us, so
			// only act differently if he's switched to his gun.
			if(ConcernedAboutWeapon(p2weap)
				&& WeaponTurnedToUs(LookAtMe, MyPawn))
			{
				if(P2Player(Attacker.Controller) != None)
				{
					GotoStateSave(GetAggressiveState());
					StateChange=1;
					return;
				}
			}
		}
		return;
	}

	///////////////////////////////////////////////////////////////////////////////
	// You currently only care about the looks of your attacker/aggressor
	///////////////////////////////////////////////////////////////////////////////
	function CheckObservePawnLooks(FPSPawn LookAtMe)
	{
		SetRotation(MyPawn.Rotation);

		if(Attacker == LookAtMe
			&& CanSeePawn(MyPawn, LookAtMe))
			// We can see this pawn
			ActOnPawnLooks(LookAtMe);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Run away (to get away from the piss!) then turn around and kick his butt or arrest him
	///////////////////////////////////////////////////////////////////////////////
	function RunAwayOrFight()
	{
		local vector dir;

		SetAttacker(InterestPawn);
		// pick a distance away
		dir = MyPawn.Location - Attacker.Location;
		dir = Normal(dir);
		dir = MyPawn.Location + PISS_RUN_AWAY_DIST*dir;

		GetMovePointOrHugWalls(dir, MyPawn.Location, PISS_RUN_AWAY_DIST, true);

		Focus = InterestPawn;
		SetEndPoint(dir, DEFAULT_END_RADIUS);
		//log("new end point "$dir);

		//log("anger "$MyPawn.Anger);
		if(FRand() <= MyPawn.Anger
			|| Enemy == InterestPawn)
		{			
			PrintDialogue("Now youv'e done it...");
			SayTime = Say(MyPawn.myDialog.lCop_SomeoneDisobeyed, bImportantDialog);
			MyPawn.StopAcc();
			SetNextState('AssessAttacker');
		}
		else
		{
			GetMoreAngry(MyPawn.Temper);
			SetNextState(GetAggressiveState());
			GotoStateSave('RunFromPisser');
		}
	}

	///////////////////////////////////////////////////////////////////////////////	
	// Check to see if you see the pisser already 
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		// if they're already pissing on us (we know about it)
		if(Attacker == InterestPawn)
		{
			PrintDialogue("Oh, that's it.");
			SayTime = Say(MyPawn.myDialog.lCop_SomeoneDisobeyed, bImportantDialog);
		}
		else if(CanSeePawn(MyPawn, InterestPawn)) // see if we're watching them do this
		{
			DetermineLeader();

			PrintDialogue("Hey, what are you doing!!");
			MyPawn.DisgustedSpitting(MyPawn.myDialog.lGettingPissedOn);
		}
		else
			PrintDialogue("What the...?");
			SayTime = Say(MyPawn.myDialog.lWhatThe, bImportantDialog);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Clear important dialog
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		bImportantDialog=false;
	}

Begin:
	// Turn towards the person pissing on us
	Focus = InterestPawn;
	Sleep(SayTime);
	// We don't deal well with the pisser

	RunAwayOrFight();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// The Attacker is in our home--react to it
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state IntruderInHome
{
Begin:
	FinishRotation();
	PrintDialogue("Get outta here!");
	SayTime = Say(MyPawn.myDialog.lInvadesHome);
	Sleep(SayTime);
	// If we're capable of defending our place, then start attacking
	if(MyPawn.bHasViolentWeapon)
	{
		GotoStateSave('AssessAttacker');
	}
	else	// if not, then get a cop to help, and run out
	{
		DangerPos = MyPawn.Location;
		GotoStateSave('FleeFromAttacker');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// HandleGuyWithThing
// This guy is doing something bad, so handle it
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state HandleGuyWithThing
{
	ignores RespondToTalker, PerformInterestAction, RatOutAttacker, CheckObservePawnLooks;
	function BeginState()
	{
		PrintThisState();
		// stop moving
		MyPawn.StopAcc();

		Focus = InterestPawn;

		if(InterestPawn.bPlayer)
			bImportantDialog=true;

		DetermineLeader();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Clear important dialog
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		bImportantDialog=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// HandleGuyWithBigGun
// He hasn't attacked or shot anyone, but he's got a very lethal weapon 
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state HandleGuyWithBigGun extends HandleGuyWithThing
{
	///////////////////////////////////////////////////////////////////////////////
	// Set up reactivity to begin looking
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		if(Enemy == None || Enemy != Attacker)
		{
			if(MyPawn.bTeamLeader)
			{
				if(VSize(Attacker.Location - MyPawn.Location) > FREEZE_BASE_DIST)
				// He's far enough away for some friendly banter
				{
					UseAttribute = MyPawn.Reactivity;

					PrintDialogue("Well, well, what do we have here?");
					SayTime = Say(MyPawn.myDialog.lCop_NoticeIllegalThing, bImportantDialog);
				}
			}
		}
		else	// We're already attacking this guy and we know we hate him
			// so get him
		{
			//log("I already know i hate him ");
			GotoStateSave('ShootAtAttacker');
			return;
		}
	}

Begin:
	Focus = Attacker;

	// Stare at the result a minute
	Sleep(SayTime);

	// Found him so decide handle the situation
	UsePatience = MyPawn.Patience;
	GotoStateSave(GetAggressiveState());
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// HandleGuyChangingIntoCop
// Just say something smarmy and arrest him now
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state HandleGuyChangingIntoCop extends HandleGuyWithBigGun
{
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// HandleGuyWithSmallGun
// He hasn't attacked or shot anyone, but he's got something like a Shocker, so it's
// not really a big deal
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state HandleGuyWithSmallGun extends HandleGuyWithThing
{
	///////////////////////////////////////////////////////////////////////////////
	// Set up reactivity to begin looking
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		if(Enemy == None || Enemy != Attacker)
		{
			UseAttribute = MyPawn.Reactivity;
		}
		else if(Attacker == InterestPawn)	
			// We're already attacking this guy and we know we hate him
			// so get him
		{
			GoKilling();
			return;
		}
	}

Begin:
	GotoStateSave('WatchGuyWithSmallGun');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// HandleGuyWithPantsDown
// He hasn't pissed on anyone, but he's running around with his pants down
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state HandleGuyWithPantsDown extends HandleGuyWithThing
{
	///////////////////////////////////////////////////////////////////////////////
	// Set up reactivity to begin looking
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		if(MyPawn.bTeamLeader)
		{
			if(Enemy != InterestPawn
				&& Attacker != InterestPawn)
			{
				UseAttribute = MyPawn.Reactivity;

				PrintDialogue("Okay.. this oughta be good.");
				SayTime = Say(MyPawn.myDialog.lNoticeDickOut, bImportantDialog);
			}
			else	// We're already attacking this guy and we know we hate him
				// so get him
			{
				GoKilling();
				return;
			}
		}
	}

Begin:
	// Stare at the result a minute
	Sleep(SayTime);

	// Found him so decide handle the situation
	UsePatience = MyPawn.Patience;
	SetAttacker(InterestPawn);
	GotoStateSave(GetAggressiveState());
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// HandlePossibleSuspect
// This could be the guy I've been recieving radio reports about.
// This state is only used when i'm on the look out for the dude, and low and
// behold we come across him. Possibly be confused at first, then say something,
// about finding him, then go into arrest mode or attack mode, based on
// how badly he's wanted. 
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state HandlePossibleSuspect extends HandleGuyWithThing
{
	///////////////////////////////////////////////////////////////////////////////
	// Set up reactivity to begin looking
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		if(Attacker != InterestPawn)
		{
			if(MyPawn.bTeamLeader)
			{
				UseAttribute = MyPawn.Reactivity;
				PrintDialogue("Suspect sighted");
				SayTime = Say(MyPawn.myDialog.lCop_SuspectSighted, bImportantDialog);
			}
		}
		else	// We're already attacking this guy and we know we hate him
			// so get him
		{
			GotoStateSave('ShootAtAttacker');
			return;
		}
	}

Begin:
	// Stare at the result a minute
	Sleep(SayTime);

	// Found him so decide handle the situation
	UsePatience = MyPawn.Patience;
	SetAttacker(InterestPawn);
	GotoStateSave(GetAggressiveState());
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// HandleGuyWithGasCan
// This is AFTER we already know he's bad. This goes straight into arrest mode
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state HandleGuyWithGasCan extends HandleGuyWithThing
{
	///////////////////////////////////////////////////////////////////////////////
	// Set up reactivity to begin looking
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		// Found him so decide handle the situation
		UsePatience = MyPawn.Patience;

		if(MyPawn.bTeamLeader)
		{
			UseAttribute = MyPawn.Reactivity;

			PrintDialogue("Hey, hey, hey.. what do you think you're up to, buddy?");
			SayTime = Say(MyPawn.myDialog.lcop_noticegaspouring, bImportantDialog);
		}
	}

Begin:
	// Stare at the result a minute
	Sleep(SayTime);

	GotoStateSave('TellHimToDropWeapon');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WatchGuyWithGasCan
// He has a gas can and he's using it so we investigate
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchGuyWithGasCan extends HandleGuyWithThing
{
	///////////////////////////////////////////////////////////////////////////////
	// See what our interest is up to
	///////////////////////////////////////////////////////////////////////////////
	function CheckInterest()
	{
		// If he's pouring out gas, then get mad
		if(GasCanWeapon(InterestPawn.Weapon) != None)
		{
			if(InterestPawn.Weapon.IsFiring())
			{
				SetAttacker(InterestPawn);
				GotoStateSave('HandleGuyWithGasCan');
				return;
			}
			else if(VSize(InterestPawn.Location - MyPawn.Location) > CurrentFloat)
			// If he's too far away, then advance possibly
			{
				SetEndGoal(InterestPawn, CurrentFloat);
				SetNextState(GetStateName());
				bStraightPath=UseStraightPath();
				SaveAttackerData(InterestPawn); // save where he is now
				GotoStateSave('WalkToInterestPawn');
				return;
			}
			else if(!CanSeePawn(MyPawn, InterestPawn))
			// If he's hiding or something, then advance closely
			{
				// Follow him
				if(FRand() < MyPawn.Curiosity)
				{
					SetEndGoal(InterestPawn, DEFAULT_END_RADIUS);
					SetNextState(GetStateName());
					bStraightPath=UseStraightPath();
					SaveAttackerData(InterestPawn); // save where he is now
					GotoStateSave('WalkToInterestPawn');
				}
				else // Give up on watching
					GotoStateSave('Thinking');
				return;
			}		
		}
		else if(FRand() > MyPawn.Curiosity/2)
		{
			GotoStateSave('Thinking');
			return;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Set up reactivity to begin looking
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		MyPawn.StopAcc();

		Focus = InterestPawn;

		// Found him so decide handle the situation
		UsePatience = MyPawn.Patience;

		if(Enemy == InterestPawn
			|| Attacker == InterestPawn)
			// so get him
		{
			GoKilling();
			return;
		}

		CurrentFloat = P2Weapon(InterestPawn.Weapon).RecognitionDist + InterestPawn.CollisionRadius;
		statecount=0;
		SayTime=0;
	}

Begin:
	// Stare at the result a minute
	Sleep(2.0 - MyPawn.Reactivity);

	CheckInterest();

	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WatchGuyWithCowhead
// He has a cowhead.. it's really gross, but just say stuff if he
// gets too close and make sure he doesn't throw it
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchGuyWithCowhead extends WatchGuyWithGasCan
{
	///////////////////////////////////////////////////////////////////////////////
	// See what our interest is up to
	///////////////////////////////////////////////////////////////////////////////
	function CheckInterest()
	{
		// If he's doing something with the cowhead, then get mad
		if(CowheadBaseWeapon(InterestPawn.Weapon) != None)
		{
			if(InterestPawn.Weapon.IsFiring())
			{
				SetAttacker(InterestPawn);
				GotoStateSave(GetAggressiveState());
				return;
			}
			else if(VSize(InterestPawn.Location - MyPawn.Location) < TALKING_DIST
				&& WeaponPointedDirectlyAtUs(InterestPawn, MyPawn))
			{
				// Say it's pretty gross
				if(statecount == 0)
				{
					MyPawn.SetMood(MOOD_Angry, 1.0);
					PrintDialogue("Gross!");
					SayTime = Say(MyPawn.myDialog.lSomethingIsGross, bImportantDialog);
					statecount++;
				}
			}
			else 
			{
				statecount=0;				
				if(!CanSeePawn(MyPawn, InterestPawn))
				// If he's hiding or something, then advance closely
				{
					// Follow him
					if(FRand() < MyPawn.Curiosity)
					{
						SetEndGoal(InterestPawn, DEFAULT_END_RADIUS);
						SetNextState(GetStateName());
						bStraightPath=UseStraightPath();
						SaveAttackerData(InterestPawn); // save where he is now
						GotoStateSave('WalkToInterestPawn');
					}
					else // Give up on watching
						GotoStateSave('Thinking');
					return;
				}
			}
		}
		else if(FRand() > MyPawn.Curiosity/2)
		{
			GotoStateSave('Thinking');
			return;
		}
	}

Begin:
	// Stare at the result a minute
	Sleep(2.0 - MyPawn.Reactivity);

	CheckInterest();
	// in case he said something, wait
	Sleep(SayTime);
	SayTime=0;

	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WatchGuyWithSmallGun
// He's got something like a Shocker, so watch him
// Let CheckObservePawnLooks do most of the work
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchGuyWithSmallGun
{
	ignores RespondToTalker, PerformInterestAction, RatOutAttacker, CheckObservePawnLooks;

	///////////////////////////////////////////////////////////////////////////////
	// Fool him by walking a way a second then spinning back around to see if he
	// still has his gun out
	// This should just pick the same direction you were already walking towards
	// so hopefully it's still valid
	///////////////////////////////////////////////////////////////////////////////
	function FindTempWalkPoint()
	{
		local vector checkpoint;

		if(EndGoal != None)
			checkpoint = EndGoal.Location;
		else
			checkpoint = EndPoint;

		Focus = None;
		FocalPoint = checkpoint;
		SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
	}

	///////////////////////////////////////////////////////////////////////////////
	// See how close he is and what he's aiming at and decide how to handle things
	///////////////////////////////////////////////////////////////////////////////
	function CheckForInterest()
	{
		local float disttous;

		// He has his legal weapon out, so check on it
		if(CanSeePawn(InterestPawn, MyPawn))
		{
			// If he's got anything more than his hands or a match out, go into
			// arrest mode, if he gets too close
			if(!InterestPawn.ViolentWeaponNotEquipped())
			{
				// Check to see if he's too close.. go into
				// arrest mode
				if(TooCloseWithWeapon(InterestPawn))
				{
					SetAttacker(InterestPawn);
					UsePatience = MyPawn.Patience;
					GotoStateSave(GetAggressiveState());
					return;
				}
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Set up reactivity to begin looking
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		statecount=0;

		UsePatience = MyPawn.Patience;

		CheckForInterest();
	}

Begin:
	// Stare at the result a minute
	Sleep(1.0 - MyPawn.Reactivity);

	// If he walked to a point where we can't see him, then go back to what
	// we were doing
	if(!LineOfSightTo(InterestPawn))
	{
		// wait a few to see if he comes back
		Sleep(3.0);

		if(!LineOfSightTo(InterestPawn))
			// still can't see him, so really stop watching
			GotoState('Thinking');
		else	// we can see him again
			Goto('Begin');
	}

	// If he's put away the weapon, stop watching for a moment, and maybe look
	// back real quick
	if(!ConcernedAboutWeapon(P2Weapon(InterestPawn.Weapon)))
	{
		if(FRand() <= 0.05)	// every once in a while, play a little game
			// where you look away and then look back real quick to see if the
			// guy pulled his gun back out
		{
			FindTempWalkPoint();
			// just walk in this direction for a second or so
			MoveToWithRadius(EndPoint,Focus,DEFAULT_END_RADIUS, MyPawn.WalkingPct);
			// twice because the function comes back after a short time
			MoveToWithRadius(EndPoint,Focus,DEFAULT_END_RADIUS, MyPawn.WalkingPct);
			// now spin around real quick and see if the dude has a weapon out again
			MyPawn.StopAcc();
			Focus = InterestPawn;

			PrintDialogue("Aha!");
			SayTime = Say(MyPawn.myDialog.lCop_SurpriseSomeone);
			Sleep(1.0 + SayTime);

//			if(P2Weapon(InterestPawn.Weapon).ViolenceRank <= 0
//				|| P2Weapon(InterestPawn.Weapon).ViolenceRank > P2Weapon(InterestPawn.Weapon).LEGAL_VIOLENCE_RANK)
//			{
				// He didn't have a legal weapon out again, so see what he does have

				// See if he looks different or not.. if not, just pass on through,
				// if so, we'll leave this state in this function
				ActOnPawnLooks(InterestPawn);

				Sleep(1.0);
				// Be disappointed because interest pawn didn't do anything bad
				PrintDialogue("Hmmph");
				SayTime = Say(MyPawn.myDialog.lCop_Disappointment);
				Sleep(1.0 + SayTime);
//			}
		}

		GotoState('Thinking');
	}
	else
	{
		CheckForInterest();

		Goto('Begin');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WatchGuyToIdentifyWeapon
// You can't tell yet, but this guy has something dangerous in his hands
// Maybe get closer to check it out.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchGuyToIdentifyWeapon
{
	ignores RespondToTalker, PerformInterestAction, RatOutAttacker, TryToSeeWeapon,
		TryToGreetPasserby;

	///////////////////////////////////////////////////////////////////////////////
	// An authority figure just yelled something, 
	// so go run to the point where it was yelled
	///////////////////////////////////////////////////////////////////////////////
	function CheckAuthorityYell(FPSPawn CreatorPawn, vector blipLoc)
	{
		local float usedist;

		LastAttackedTime = Level.TimeSeconds;

		InterestPawn = PersonController(CreatorPawn.Controller).InterestPawn;
		if(InterestPawn == None)
			InterestPawn = PersonController(CreatorPawn.Controller).Attacker;

		DangerPos = blipLoc;
		
		if(IsInState('LegMotionToTarget'))
			bPreserveMotionValues=true;
		SetNextState('WatchGuyToIdentifyWeapon');
		
		if(InterestPawn != None)
			usedist = P2Weapon(InterestPawn.Weapon).RecognitionDist - InterestPawn.CollisionRadius;
		else
			usedist = DEFAULT_END_RADIUS;

		SetEndPoint(blipLoc, usedist);
		GotoStateSave('RunToInterest');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Set up reactivity to begin looking
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		Focus = InterestPawn;
		MyPawn.StopAcc();
	}

Begin:
	Sleep(2.0);

	// If he walked to a point where we can't see him, then go back to thinking
	if(!LineOfSightTo(InterestPawn)
		|| (P2Weapon(InterestPawn.Weapon) != None
		&& !ConcernedAboutWeapon(P2Weapon(InterestPawn.Weapon))))
		GotoStateSave('Thinking');
	else
	{
		// Possibly decide to walk closer to investigate, based on curiosity
		if(FRand() < MyPawn.Curiosity)
		{
			SetNextState('WatchGuyToIdentifyWeapon');
			SetEndGoal(InterestPawn, P2Weapon(InterestPawn.Weapon).RecognitionDist - InterestPawn.CollisionRadius);
			bDontSetFocus=true;
			GotoStateSave('WalkToIdentifyWeapon');
		}

		// otherwise, just keep watching
		Goto('Begin');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RecognizeAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RecognizeAttacker
{
	///////////////////////////////////////////////////////////////////////////////
	// What to do once you've picked a sidestep place
	///////////////////////////////////////////////////////////////////////////////
	function AfterStrategicSideStep(vector checkpoint)
	{
		// Now move to it and get ready to shoot again when you get there
		//log("side stepping");
		bDontSetFocus=true;
		SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
		SetNextState('RecognizeAttacker');
		bStraightPath=UseStraightPath();
		GotoStateSave('RunToTargetIgnoreAll');
	}

	///////////////////////////////////////////////////////////////////////////
	// When attacked while you're attacking
	// ignore cops shooting you, or at least say something
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		// We don't care about friendly fire
		if(FriendWithMe(FPSPawn(Other)))
		{
			PerformStrategicMoves(true);
			return;
		}

		ReportAfterHit();

		PolicedamageAttitudeTo(Other, Damage);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Stare at pawn
	///////////////////////////////////////////////////////////////////////////////
	function PickOutAttacker(FPSPawn Other, vector CheckLoc)
	{
		local FPSPawn usepawn;
		local PoliceController pcont;

		// Start looking at him
		Focus = VisuallyFindPawn(Other, CheckLoc);

		if(Focus == None)
		{
			Focus = InterestPawn2;
		}
		//log("use focus "$Focus);
		//log("interest pawn 2 "$InterestPawn2);

		// if this person has a weapon out already, make him our current suspect
		usepawn = FPSPawn(Focus);
		if(P2Pawn(usepawn) != None)
		{
//			pcont = PoliceController(usepawn.Controller);
//			if(pcont != None)
			if(FriendWithMe(usepawn))
			{
//				if(pcont.
//				GainPartnersKnowledge(pcont);
//				GotoStateSave(usepawn.GetStateName());
				//log(self$" disregarding you "$pcont);
			}
			else if(usepawn.Weapon != None
					&& (P2Weapon(usepawn.Weapon).ViolenceRank > 0
						|| (MyPawn.LastDamageType == class'KickingDamage')))
			{
				//log("making "$usepawn$" our attacker for PickOutAttacker");
				SetAttacker(usepawn);
			}
		}
		//else if(AnimalPawn(usepawn) != None)
		//	Attacker = usepawn;
	}

	///////////////////////////////////////////////////////////////////////////////
	// You're tired of looking for the attacker so start asking who shot you
	///////////////////////////////////////////////////////////////////////////////
	function StartAsking()
	{
		InterestPawn = FPSPawn(Focus);

		if(InterestPawn != None
			&& ClassIsChildOf(MyPawn.LastDamageType, class'BulletDamage'))
			GotoStateSave('RunAndAskWhoShotMe');
		else
		{
			PrintThisState();
			//log("I have no interestpawn so I'm going to investigate "$DangerPos);
			DangerPos = Attacker.Location;
			GotoStateSave('PrepRunToInvestigate');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		DetermineLeader();
	}

Begin:
	// Look for attacker
	PickOutAttacker(Attacker, LastAttackerPos);
	// Stare at the result a minute
	Sleep(1.0 - MyPawn.Reactivity);
	statecount++;
	// Check to see if correct
	if(Focus != Attacker)
	{
		if(Focus == None)
			GiveUpLooking();
		// You didn't find the attacker
		else if(statecount >= MAX_RECOGIZE_TRIES)
		{
			StartAsking();
		}
		else
		{
			// He's the only one around and a gun went off.. probably arrest him
			if(NumberOfPeopleAround(Focus.Location) == 1)
			{
				InterestPawn = FPSPawn(Focus);
				SetAttacker(InterestPawn);
				UsePatience = MyPawn.Patience;
				GotoStateSave(GetAggressiveState());
			}
			// Look again, wrong one
			// This time you're more likely to get it right
			UseAttribute = (UseAttribute + 1.0)/2;
			Goto('Begin');
		}
	}
	else // We're looking at the bad guy. See if he still looks suspicious
	{
		// He just shot me and he's the only one around, arrest him
		if(NumberOfPeopleAround(Attacker.Location) == 1)
			// Found him so decide to attack
			GotoStateSave('AssessAttacker');
		else
		{
			StartAsking();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Check to see if they have a weapon or not
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CheckHimForWeapon
{
	ignores TryToGreetPasserby;

Begin:
	PrintThisState();
	// Call out to this person to turn around so you
	// can see if they have a gun or not
	PrintDialogue("You there... turn around, I need to talk to you");
	SayTime = Say(MyPawn.myDialog.lCop_TurnAround1);
	Sleep(SayTime);
	INeedToSeeYouHaveNoWeapon(MyPawn, InterestPawn);
	// waiting for him to turn around
	//Sleep(3.0);
	//log("Interest pawn "$InterestPawn);
	SetEndGoal(InterestPawn, TALKING_DIST);
	SetNextState(GetStateName(), 'CheckAgain');
	bStraightPath=true;
	GotoStateSave('WalkToSuspect');

CheckAgain:
	// Now check again to see if they're facing
	// us or not
	if(WeaponTurnedToUs(InterestPawn, MyPawn))
	{
		// They're facing us, so check for a weapon
		// on them
		if(P2Weapon(InterestPawn.Weapon).ViolenceRank > 0)
		{
			UsePatience = MyPawn.Patience;
			GotoStateSave(GetAggressiveState());
		}
		// He has no weapon, so check others
		PrintDialogue("Nevermind...");
		SayTime = Say(MyPawn.myDialog.lCop_Nevermind);
		Sleep(SayTime);
	}
	else // he still hasn't turned to face us, so get mad
	{
		if(Frand() <= MyPawn.Anger)
		{
			UsePatience = MyPawn.Patience;
			SetAttacker(InterestPawn);
			GotoStateSave(GetAggressiveState());
		}
		else
		{
			PrintDialogue("Turn around and face me!");
			SayTime = Say(MyPawn.myDialog.lCop_TurnAround2);
			// wait for them to turn around
			Sleep(SayTime + 2*MyPawn.Patience + 1.0);
			// mad because he hasn't obeyed.
			GetMoreAngry(MyPawn.Temper);
			Goto('CheckAgain');
		}
	}

	GotoStateSave('Thinking');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// CauseInterference
// Try to run interference between the dude and the person he's shooting at,
// this is becuase he's shooting at a civilian, and while we don't condone it
// we don't take lethal action against the dude. We simply try to keep him
// from doing it by getting physically in the way. If the dude shoots us
// we'll attack him
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CauseInterference
{
	ignores TryToCauseInterference;

	///////////////////////////////////////////////////////////////////////////////
	// See if our attacker is still attacking
	///////////////////////////////////////////////////////////////////////////////
	function CheckIfStillShooting()
	{
		local P2Weapon p2weap;

		p2weap = P2Weapon(InterestPawn.Weapon);

		// leave him alone now
		if(p2weap == None
			|| p2weap.ViolenceRank <= 0)
			GotoStateSave('WatchACop');
	}

	///////////////////////////////////////////////////////////////////////////////
	// See if we're close enough to not warn our guy again, or maybe we should
	///////////////////////////////////////////////////////////////////////////////
	function bool CloseEnoughToShooter()
	{
		if(VSize(InterestVect - MyPawn.Location) < CurrentDist)
		{
			// warn again anyway
			if(FRand() < 0.1)
				return false;
			else	// too close to last place we warned him--wait
				return true;
		}
		else	// We had to run to a new point, so warn him again when we get there
			return false;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Find a point between the guy who's shooting and his victim. Try to get between
	// them
	///////////////////////////////////////////////////////////////////////////////
	function CheckToFollow()
	{
		local vector runpoint, diff;
		local float prand;

		// If the interest is dead, don't follow
		if(InterestPawn2.Health <= 0)
		{
			GotoStateSave('WatchACop');
		}
		else
		{

	/*
			diff = Normal(InterestPawn.Location - InterestPawn2.Location);
			prand = 2*FRand() + 1;
			runpoint = (prand*DEFAULT_END_RADIUS)*diff + InterestPawn2.Location;

			// Trace a line out from the victim forward to where we plan to stand and see
			// if that's a reasonable place to stand
			AdjustPointForWalls(runpoint, InterestPawn2.Location);

			SetEndPoint(runpoint, DEFAULT_END_RADIUS);
	*/
			InterestVect = MyPawn.Location;
			SetEndGoal(InterestPawn2, CurrentDist);
			SetNextState('CauseInterference');
			GotoStateSave('RunToTarget');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		MyPawn.SetMood(MOOD_Combat, 1.0);
		DetermineLeader();
		CurrentFloat = FRand()/2;
		CurrentDist = INTERFERENCE_DIST + FRand()*INTERFERENCE_DIST;
		MyPawn.StopAcc();
	}
Begin:
	// Check if he has a weapon out
	CheckIfStillShooting();

	Focus = InterestPawn;
	Sleep(CurrentFloat);
	//FinishRotation();
	// Tell him no!
	if(MyPawn.bTeamLeader)
	{
		if(!CloseEnoughToShooter())
		{
			if (Level.TimeSeconds - MIN_WARN_TIME > LastWarnTime)
			{
				LastWarnTime = Level.TimeSeconds;
				PrintDialogue("It's not worth it!");
				SayTime = Say(MyPawn.myDialog.lCop_CopOuttaLine);
				MyPawn.PlayTalkingGesture(1.0);
				Sleep(SayTime);
			}
			// Run to a point between the shooter and shootee
			CheckToFollow();
		}
		else
			Goto('Begin');
	}
	else if(CloseEnoughToShooter())
	{
		Sleep(2.0);
		Goto('Begin');
	}

	// Run to a point between the shooter and shootee
	CheckToFollow();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run to the danger spot to investigate things
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PrepRunToInvestigate
{
	ignores CheckObservePawnLooks, MarkerIsHere;

	function BeginState()
	{
		PrintThisState();
	}
Begin:
	LastAttackerPos = DangerPos;

	// Save the possibility of any suspects
	if(Attacker != None
		|| InterestPawn != None)
		statecount=1;
	else
		statecount=0;

	SetAttacker(None);

	SetEndPoint(DangerPos, CHECK_DANGER_DIST);

	Sleep(0.0);

	// We have reason to believe a bad guy is around, so 
	// look for one
	if(statecount == 1)
		SetNextState('RecognizeNearbyShooter');
	else	// Probably someone just screaming, so only look for
		// trouble, don't make arrests yet
		SetNextState('LookAroundForTrouble');
	GotoStateSave('RunToTarget');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run to the danger spot to investigate things
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PrepRunToInvestigateDanger extends PrepRunToInvestigate
{
Begin:
	// Stop moving
	MyPawn.StopAcc();
	// Wait while the bystander who told you about this talks some
	Sleep(SayTime);

	PrintDialogue("I'll go check out the danger! "$Pawn);
	SayTime = Say(MyPawn.myDialog.lCop_GoingToInvestigate);
	Sleep(SayTime);
	LastAttackerPos = DangerPos;

	// Save the possibility of any suspects
	if(Attacker != None
		|| InterestPawn != None)
		statecount=1;
	else
		statecount=0;

	SetAttacker(None);

	SetEndPoint(DangerPos, CHECK_DANGER_DIST);

	Sleep(0.0);

	// We have reason to believe a bad guy is around, so 
	// look for one
	if(statecount == 1)
		SetNextState('RecognizeNearbyShooter');
	else	// Probably someone just screaming, so only look for
		// trouble, don't make arrests yet
		SetNextState('LookAroundForTrouble');
	GotoStateSave('RunToTarget');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run to the killer spot to investigate things
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PrepRunToInvestigateKiller extends PrepRunToInvestigateDanger
{
	/*
Begin:
	// Stop moving
	MyPawn.StopAcc();
	// Wait while the bystander who told you about this talks some
	Sleep(SayTime);

	PrintDialogue("I'll go find the killer! "$Pawn);
	SayTime = Say(MyPawn.myDialog.lCop_GoingToInvestigate);
	Sleep(SayTime);
	LastAttackerPos = DangerPos;

	//GotoStateSave(GetAggressiveState());
	*/
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RecognizeNearbyShooter
// He's hasn't attacked you, but he is shooting around you, so stop him
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RecognizeNearbyShooter extends RecognizeAttacker
{
	///////////////////////////////////////////////////////////////////////////////
	// Decide what to do with this guy
	///////////////////////////////////////////////////////////////////////////////
	function HandleSuspect(FPSPawn thisguy)
	{
		// He's the only one around and a gun went off.. probably arrest him
		// unless it's the dude and he's a cop
		if(NumberOfPeopleAround(thisguy.Location) == 1
			// We really think it's an animal, so just attack it
			|| AnimalPawn(thisguy) != None
			// Check first, to see if we can see him with his gun out
			// If not, we get him to face us
			|| !WeaponTurnedToUs(thisguy, MyPawn)
			// Found him so decide handle the situation
			// because he still has his gun out
			|| (P2Weapon(thisguy.Weapon) != None
				&& P2Weapon(thisguy.Weapon).ViolenceRank > 0))
		{
			if(!DudeDressedAsCop(thisguy))
			{
				InterestPawn=thisguy;
				SetAttacker(InterestPawn);
				UsePatience = MyPawn.Patience;
				GotoStateSave(GetAggressiveState());
			}
			else
			{
				InterestPawn = thisguy;
				GotoStateSave('WatchACop');
			}
		}
		else // give up
			GiveUpLooking();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Set up reactivity to begin looking
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		// stop moving
		MyPawn.StopAcc();

		SwitchToBestWeapon();

		DetermineLeader();

		// if it's a cop, help him
		// TEAMPLAY
		if(FriendWithMe(Attacker))
		{
			// Make my attacker his attacker
			SetAttacker(PersonController(Attacker.Controller).Attacker, true);
			// Save what he knows
			LastAttackerPos = PersonController(Attacker.Controller).LastAttackerPos;
		}

		// otherwise, handle the shooter
		if((Enemy == None
			|| Enemy != Attacker)
			&& AnimalPawn(Attacker) == None)
		{
			UseAttribute = MyPawn.Reactivity;

			// Check first to see if your straight in front of me
			if(Attacker != None
				&& CanSee(Attacker))
			{
				// Found him so decide handle the situation
				UsePatience = MyPawn.Patience;
				GotoStateSave(GetAggressiveState());
				return;
			}

			// Prep the check radius for the radiusactor searches
			CurrentFloat = VSize(LastAttackerPos - MyPawn.Location);
			CurrentDist = CurrentFloat/VISUALLY_FIND_RADIUS;
			//MyPawn.ClipFloat(CurrentFloat, VISUALLY_FIND_RADIUS, MIN_VISUALLY_FIND_RADIUS);
			CurrentFloat = VISUALLY_FIND_RADIUS;
			// Before we leave, call out and ask for help. Ask for someone
			// if they saw it, to rat you out
			if(Attacker != None)
			{
				if(MyPawn.bTeamLeader)
				{
					PrintDialogue("We've got a problem! I need backup!");
					SayTime = Say(MyPawn.myDialog.lCop_CallForBackup);
				}
				AskWhereAttackerIs(LastAttackerPos);
			}

			// blank the count
			statecount=0;
		}
		else	// We're already attacking this guy and we know we hate him
			// so get him
		{
			//log("I already know i hate him ");
			GotoStateSave('ShootAtAttacker');
			return;
		}
	}

Begin:
	// Look for attacker
	PickOutAttacker(Attacker, LastAttackerPos);
	//log("focus "$Focus);
	// Stare at the result a minute
	Sleep(1.0 - MyPawn.Reactivity);
	statecount++;
	// Check to see if correct
	if(Focus != Attacker
		|| Focus == None)
	{
		if(Focus == None)
		{
			// No one's around at all
			// Just give up, you couldn't find him
			GiveUpLooking();
		}
		else if(statecount >= MAX_RECOGIZE_TRIES)
		// Check on that last guy
		{
			InterestPawn = FPSPawn(Focus);

			// if not a cop,etc
			if(!FriendWithMe(InterestPawn))
			{
				HandleSuspect(InterestPawn);
			}

			// TODO MAKE THIS COP HELP!
			GiveUpLooking();
		}
		else
		{
			// He's the only one around and a gun went off.. probably arrest him
			if(NumberOfPeopleAround(Focus.Location) == 1)
			{
				InterestPawn = FPSPawn(Focus);
				SetAttacker(InterestPawn);
				UsePatience = MyPawn.Patience;
				GotoStateSave(GetAggressiveState());
			}
			// Look again, wrong one
			// This time you're more likely to get it right
			UseAttribute = (UseAttribute + 1.0)/2;
			Goto('Begin');
		}
	}
	else
	{
		HandleSuspect(Attacker);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// AskInterestWhoWasShooter
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state AskInterestWhoWasShooter
{
	ignores TryToGreetPasserby;
Begin:
	PrintDialogue("Don't guess you know who just shot that gun?");
	SayTime = Say(MyPawn.myDialog.lCop_WhoFiredWeapon);
	Sleep(SayTime);
	// Make interest pawn respond or not
	if(PersonController(InterestPawn.Controller) != None)
		PersonController(InterestPawn.Controller).RespondToQuestionNegatively(MyPawn);
	// wait for response
	Sleep(1.0 - MyPawn.Reactivity);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// AskInterestWhoShotMe
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state AskInterestWhoShotMe
{
	ignores TryToGreetPasserby;
Begin:
	PrintDialogue("Who just shot me??");
	SayTime = Say(MyPawn.myDialog.lCop_WhoShotMe);
	Sleep(SayTime);
	// Make interest pawn respond or not
	if(PersonController(InterestPawn.Controller) != None)
		PersonController(InterestPawn.Controller).RespondToQuestionNegatively(MyPawn);
	// wait for response
	Sleep(1.0 - MyPawn.Reactivity);
	GotoStateSave('RunAndAskWhoShotMe');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DecideToGetDown
// Simply turn and look at who said to get down
// Assumes the focus is set to who we want to look at
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DecideToGetDown
{
	ignores RespondToTalker, ForceGetDown, QPointSaysMoveUpInLine, SetupSideStep, 
		SetupBackStep, SetupMoveForRunner, TryToGreetPasserby, AllowOldState;

	///////////////////////////////////////////////////////////////////////////////
	// reset bools
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		bPreserveMotionValues=false;
		MyPawn.StopAcc();
	}

Begin:
	// Look at them for a second
	Sleep(2.0 - UseReactivity);
	// now react to their looks
	ActOnPawnLooks(FPSPawn(Focus));
	// look a little while longer if you didn't do anything
	Sleep(1.0 - UseReactivity);

	// in case we didn't care about their looks
	GotoState(MyOldState);
}
/*
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// CrouchForOther
// Get down and wait a second, while the other person does what they're doing
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CrouchForOther
{
	ignores HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere,
		RespondToTalker, ForceGetDown, PerformInterestAction, MarkerIsHere, 
		RespondToQuestionNegatively, CheckObservePawnLooks, SetupSideStep, 
		SetupBackStep, SetupMoveForRunner;

	///////////////////////////////////////////////////////////////////////////////
	// reset bools
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		bPreserveMotionValues=false;
		MyPawn.StopAcc();
	}

Begin:
	Sleep((1.0 - UseReactivity) + MyPawn.Rebel);

	MyPawn.ShouldCrouch(true);

	Sleep(2.0);	// stay down for a second

	if(AllowOldState())
		GotoState(MyOldState);
	else
		GotoState('Thinking');
}
*/
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// I'm almost ready to attack
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state OnTheOffensive
{
	ignores RespondToTalker, PerformInterestAction, HandleNewImpersonator,
		ForceGetDown, CheckDesiredThing, TryToGreetPasserby, RatOutAttacker;

	///////////////////////////////////////////////////////////////////////////////
	// We've seen the pawn, now decide if we care
	// Returns true if there state changes at some point
	///////////////////////////////////////////////////////////////////////////////
	function ActOnPawnLooks(FPSPawn LookAtMe, optional out byte StateChange)
	{
		// Only team leaders can make decisions based on looks in offensive mode
		if(MyPawn.bTeamLeader
			&& LookAtMe == Attacker)
		{
			// If our attacker has a weapon out, and we hate him, attack now
			if(bHateAttacker
				&& P2Weapon(LookAtMe.Weapon).ViolenceRank > 0)
			{
				GoKilling();
			}
			else
				Super.ActOnPawnLooks(LookAtMe, StateChange);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check our attacker, and attack him, if he's too close
	///////////////////////////////////////////////////////////////////////////////
	function CheckForTooCloseAttacker(optional out byte StateChange)
	{
		local P2Weapon p2weap;
		local vector dir, checkpoint;
		local float dist;

		if(!Attacker.ViolentWeaponNotEquipped())
		{
			// Check to see if he's too close.. if so, go ahead
			// and attack
			if(TooCloseWithWeapon(Attacker))
			{
				// We don't hate him right away, so see what kind of
				// weapon he got too close to me with
				if(!bHateAttacker)
				{
					p2weap = P2Weapon(Attacker.Weapon);

					// Not a bad weapon, really, and he hasn't attacked yet,
					// so just back up
					if(p2weap == None
						|| p2weap.ViolenceRank < p2weap.LEGAL_VIOLENCE_RANK)
					{
						// So first see and we may be mad enough to start attacking anyway
						if(!CheckToGoKilling())
						{
							if(FRand() < 0.5)
							{
								GetMoreAngry(MyPawn.Temper*0.5);
								// Find a place to back up to
								SaveAttackerData();
								dir = LastAttackerPos - MyPawn.Location;
								dist = P2Weapon(MyPawn.Weapon).MinRange + (2*Attacker.CollisionRadius + WEAPON_BASE_DIST*p2weap.ViolenceRank);
								checkpoint = MyPawn.Location - dist*Normal(dir);
								GetMovePointOrHugWalls(checkpoint, MyPawn.Location, UseSafeRangeMin, true);
								SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
								SetNextState(GetAggressiveState());
								bStraightPath=UseStraightPath();
								MyPawn.SetMood(MOOD_Normal, 1.0);	// run with your arms down
								GotoStateSave('RunToTargetIgnoreAll');
								StateChange=1;
								return;
							}
						}
					}
					else
					{
						GoKilling();
						StateChange=1;
						return;
					}
				}
				else
				{
					GoKilling();
					StateChange=1;
					return;
				}
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// What to do once you've picked a sidestep place
	///////////////////////////////////////////////////////////////////////////////
	function AfterStrategicSideStep(vector checkpoint)
	{
		// Now move to it and get ready to shoot again when you get there
		//log("side stepping");
		bDontSetFocus=true;
		SetEndPoint(checkpoint, DEFAULT_END_RADIUS);
		SetNextState('ShootAtAttacker', 'WaitTillFacing');
		bStraightPath=UseStraightPath();
		GotoStateSave('RunToTargetIgnoreAll');
	}

	///////////////////////////////////////////////////////////////////////////
	// When attacked while you're attacking
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		if ( (Other == None) || (Other == Pawn) || (Damage <= 0))
			return;

		// We don't care about friendly fire
		if(FriendWithMe(FPSPawn(Other)))
		{
			PerformStrategicMoves(true);
			return;
		}

		SetAttacker(FPSPawn(Other));
		GetAngryFromDamage(Damage);
		MakeMoreAlert();

		ReportAfterHit();

		// Check to see if you've been hurt past your pain threshold, and then run away
		if(MyPawn.Health < (1.0-MyPawn.PainThreshold)*MyPawn.HealthMax)
		{
			InterestPawn = Attacker;
			MakeMoreAlert();
			DangerPos = InterestPawn.Location;
			GotoStateSave('FleeFromAttacker');
		}
		else
		{
			// randomly pause from the attack
			//PrintDialogue("ARRGGHH!!");
			Say(MyPawn.myDialog.lGotHit);
			SetNextState('ShootAtAttacker');
			MyPawn.StopAcc();
			GotoStateSave('AttackedWhileAttacking');
		}

		return;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Decide what to do about this danger
	// Something bad happened while we were already pissed off
	// We only really care if it's the same attacker we were already
	// pissed about.
	///////////////////////////////////////////////////////////////////////////////
	function GetReadyToReactToDanger(class<TimedMarker> dangerhere, 
									FPSPawn CreatorPawn, 
									Actor OriginActor,
									vector blipLoc,
									optional out byte StateChange)
	{
		local float dist;
		local vector dir;
		local FPSPawn Attacked;

		// if it's a crazy animal, run or fight it
		if((Attacker == None
				|| Attacker == CreatorPawn)
			&& AnimalPawn(CreatorPawn) != None)
		{
			// Only pay attention to attacking animals in this state
			if(dangerhere.default.bCreatorIsAttacker)
			{
				if(MyPawn.bHasViolentWeapon)
				{
					// Drop things if you had them in your hands
					MyPawn.DropBoltons(MyPawn.Velocity);
					SetAttacker(CreatorPawn);
					MakeMoreAlert();
					SaveAttackerData(CreatorPawn);
					GotoStateSave('RecognizeAttacker');
					StateChange=1;
				}
				else
				{
					GenSafeRangeMin();
					InterestPawn = CreatorPawn;
					SetAttacker(InterestPawn);
					DangerPos = Attacker.Location;
					GotoStateSave('FleeFromAttacker');
					StateChange=1;
				}
				LastAttackedTime = Level.TimeSeconds;
			}
			return;
		}

		// If the dude, and you're friends with him, don't care what noises
		// he makes from guns or whatever
		if(CreatorPawn != None
			&& MyPawn.bPlayerIsFriend 
			&& CreatorPawn.bPlayer)
		{
			LastAttackedTime = Level.TimeSeconds;
			return;
		}

		// If it's another authority attacking who we're concerned with, then
		// just go ahead and attack also.
		if(P2Pawn(CreatorPawn) != None
			&& PersonController(CreatorPawn.Controller) != None)
			Attacked = PersonController(CreatorPawn.Controller).Attacker;

		// Someone definitely did something bad, like shooting

		if(LastAttackedTime != Level.TimeSeconds
			&& !ClassIsChildOf(dangerhere, class'AuthorityOrderMarker'))
		{
			if(CreatorPawn == Attacker
				|| (Attacked == Attacker
					&& P2Pawn(CreatorPawn) != None
					&& P2Pawn(CreatorPawn).bAuthorityFigure
					&& MyPawn.MyLeader == P2Pawn(CreatorPawn)))
			{
				if(dangerhere.default.bCreatorIsAttacker)//class'PawnBeatenMarker' != dangerhere)
				{
					// The same guy is now shooting or something, and that's annoying
					// so go into attack mode
					GoKilling();
					StateChange=1;
					LastAttackedTime = Level.TimeSeconds;
					return;
				}
			}
			else if((P2Pawn(CreatorPawn) == None
						|| !P2Pawn(CreatorPawn).bAuthorityFigure)
					&& Attacked == Attacker)
				// As long as the other guy 
				// shooting isn't an authority figure, then go handle him by shooting
				// him yourself, or by sending someone else to go handle him.
				// Unless, he's a friend of ours, then just go ahead and attack your guy once.
			{
				if(FriendWithMe(CreatorPawn))
				{
					GotoStateSave('ShootAtAttacker');
				}
				else
					HandleNewThreat(CreatorPawn);
				StateChange = 1;
				return;
			}

			// TODO: send another cop after the other guy, if a new guy is shooting somewhere
		}
		LastAttackedTime = Level.TimeSeconds;
		return;
	}

	///////////////////////////////////////////////////////////////////////////////
	// see if you're close enough to make stuff happen
	///////////////////////////////////////////////////////////////////////////////
	function NeedToWalkCloser(float CheckDist, optional out byte StateChange)
	{
		local bool bMoveCloser;
		local float usedist;
		local Actor HitActor;
		local FPSPawn HitPawn;
		local vector HitNormal, HitLocation, usepoint;
		local bool bLeaderSwap, bGotoLeader;
		local PoliceController newcont;
		local bool bHiding;

		// recalc distance
		CurrentDist = VSize(Attacker.Location - MyPawn.Location);

		// If you're not close enough or if you can't see him
		// then run closer
		HitActor = MyPawn.Trace(HitLocation, HitNormal, MyPawn.Location, Attacker.Location, true);
		if(HitActor != None)
		{
			bMoveCloser=true;
			usedist = DEFAULT_END_RADIUS;

			HitPawn = FPSPawn(HitActor);
			// If it hit someone other than my attacker, then run to their side
			if(HitPawn != None
				&& HitPawn != Attacker)
			{
				GetSideOfHumanObstacle(HitPawn, Attacker, usepoint);
				// If I'm a leader, apparently there's someone in the way before me
				// check to have them be leader instead
				if(MyPawn.bTeamLeader)
				{
					// We need to run closer to the attacker, and this pawn is in our way
					// if he's on our team, and a cop, then make him the leader, otherwise,
					// make him crouch, and we'll stand still
					// Make sure this guy can help us, before assigning him to help
					newcont = PoliceController(HitPawn.Controller);
					if(newcont != None
						&& newcont.CanHelpOthers())
					{
						DoLeaderSwap(MyPawn, P2Pawn(HitPawn));
						// If we did this, then have me keep running, but go into backup mode
						// and have the new leader go into arrest mode
						bLeaderSwap=true;
					}
				}
			}
			else
			{
				bHiding=true;
				ReportAsWanted(Attacker, true);
			}
		}
		
		if(CurrentDist >= (CheckDist + Attacker.CollisionRadius)
			|| bHiding)
		{
			bMoveCloser=true;
			usedist = CheckDist;//-2*Attacker.CollisionRadius;
			// If we're where we need to be, run to our leader to re-evaulate things
			if(VSize(LastAttackerPos - MyPawn.Location) < CheckDist
				&& MyPawn.MyLeader != None)
			{
				bGotoLeader = true;
				usepoint = MyPawn.MyLeader.Location;
			}
			else
			{
				usepoint = LastAttackerPos;
			}
		}

		if(bMoveCloser)
		{
			// If we swapped leaders, then have me keep running, but go into backup mode
			// and have the new leader go into arrest mode
			if(bLeaderSwap)
			{
				// I back up the new leader
				SetNextState('BackupLeader');
				// New leader goes right into arrest mode
				newcont.GotoStateSave(GetAggressiveState());
			}
			else
			{
				if(bGotoLeader)
					SetNextState(GetAggressiveState());
				else
					SetNextState(GetAggressiveState(), 'LookForAttacker');
			}

			SetEndPoint(usepoint, usedist);
			GotoStateSave('RunToArrestee');
			StateChange=1;
			return;
		}
		else	// If you didn't do anything, then think/check to wipe off your face
		{
			CheckWipeFace();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		PlayerHintDropWeapon(Attacker, false);
		bImportantDialog=false;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Get out your gun when threatened
	// Handle anims
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		// Check if our attacker is dead, if so, don't care about them anymore
		if(Attacker == None
			|| Attacker.Health <= 0
			|| Attacker.Controller == None)
		{
			GotoStateSave('LookAroundForTrouble');
			return;
		}

		MyPawn.StopAcc();
		MyPawn.ShouldCrouch(false);
		SwitchToBestWeapon();
		MyPawn.SetMood(MOOD_Combat, 1.0);

		if(Attacker.bPlayer)
			bImportantDialog=true;
		else
			bImportantDialog=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunAndAskWhoShotMe
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunAndAskWhoShotMe extends OnTheOffensive
{
	ignores CheckDeadBody, CheckDeadHead, WatchFunnyThing;
	///////////////////////////////////////////////////////////////////////////////
	// Find next person to ask
	///////////////////////////////////////////////////////////////////////////////
	function FindNextToAsk()
	{
		local P2Pawn CheckP, KeepP;

		// check all the pawns around me.
		ForEach VisibleCollidingActors(class'P2Pawn', CheckP, ASK_FOR_SHOOTER_RADIUS, InterestPawn.Location)
		{
			if(CheckP != MyPawn
				&& InterestPawn != CheckP
				&& CheckP.Health > 0)
			{
				if(FRand() > 0.6)
				{
					InterestPawn = CheckP;
					return;
				}
				else
					KeepP = CheckP; // keep who we didn't want, in case we need to fall back on this
			}
		}
		if(KeepP != None)
		{
			InterestPawn = KeepP;
			return;
		}

		InterestPawn = None;
		//log("=============================I HAVE NO ONE ELSE TO ASK");
		// Make him run around looking for more people, somehow
		GotoStateSave('Thinking');
	}

Begin:
	PrintThisState();

	FindNextToAsk();

	//log("next to ask is "$InterestPawn);

	SetNextState('AskInterestWhoShotMe');

	SetEndGoal(InterestPawn, TALKING_DIST);

	GotoStateSave('RunToTarget');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Wait for leader to arrest him
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state BackupLeader extends OnTheOffensive
{
	ignores StartWithSuspect;

	///////////////////////////////////////////////////////////////////////////////
	// Determine your sleep time
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		
		//log(MyPawn$" my team leader is "$MyPawn.MyLeader);
		CurrentFloat = Rand(5)*(1.0 - MyPawn.Reactivity) + 1.0;
		CurrentDist = FRand()*NON_LEADER_DIST_TO_ATTACKER + FREEZE_BASE_DIST;
		//log(MyPawn$" wait time "$CurrentFloat$" check dist base "$CurrentDist);
		Focus = Attacker;
	}
Begin:
	Sleep(CurrentFloat);

	// See if he's too close to us with a weapon out
	CheckForTooCloseAttacker();

	// Now see if we're close enough to him
	NeedToWalkCloser(CurrentDist + FRand()*NON_LEADER_DIST_TO_ATTACKER);

	//log(MyPawn$" saving attacker data in BackupLeader");
	SaveAttackerData();

	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// TellHimToFreeze
// Tell the attacker guy to freeze, that is, stop moving
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TellHimToFreeze extends OnTheOffensive
{
	ignores HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere, CheckDeadBody, CheckDeadHead, WatchFunnyThing;

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function DetectAttackerSomehow(FPSPawn CheckPawn, optional name RunState)
	{
		DetectAttacker(CheckPawn, , , , RunState);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check the guy who you told to 'freeze' and see if he has.
	// If he's stopped, then tell him to drop his weapon
	// or pull up his pants
	// If he hasn't see if you have the patience or not, to 
	// ask him again, or to just start shooting.
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextStateBasedOnAttacker(optional bool bStart)
	{
		local byte StateChange;

		// If we can't see him, go after him
		if(!LineOfSightTo(Attacker))
		{
			// Tell every one to follow along with me
			if(MyPawn.bTeamLeader)
			{
				FollowLeadersState('RunToArrestee', 
								'LookingForAttacker',
								'',
								None,
								LastAttackerPos,
								FREEZE_BASE_DIST, 
								false,
								true);
			}

			SetNextState('LookingForAttacker', '');//GetAggressiveState(), 'LookForAttacker');
			SetEndPoint(LastAttackerPos, FREEZE_BASE_DIST);
			GotoStateSave('RunToArrestee');
			return;
		}

		// Now check to make sure he's not pouring gasoline
		if(!bStart
			&& GasCanWeapon(Attacker.Weapon) != None
			&& Attacker.Weapon.IsFiring())
		{
			GoKilling();
			return;
		}

		// Otherwise, check to see if he's done what we asked
		if(Attacker.NoLegMotion())
		{
			// If we didn't do that, check to arrest him
			if(!LeaderSensesWeapon()
				&& Attacker.ViolentWeaponNotEquipped()
				&& !Attacker.HasPantsDown())
			{
				// Check to walk closer first
				NeedToWalkCloser(FREEZE_BASE_DIST, StateChange);
				if(StateChange == 1)
					return;
				// He's stopped moving and already put away the weapon
				GotoStateSave('PrepareToArrestHim');
				return;
			}
			else
			{
				// Check to walk closer first
				NeedToWalkCloser(FREEZE_ADD_DIST*(1.0-MyPawn.Anger) + FREEZE_BASE_DIST, StateChange);
				if(StateChange == 1)
					return;
				// he has stopped, so tell him to drop his weapon
				GotoStateSave('TellHimToDropWeapon');
				return;
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// yell something based on anger
	///////////////////////////////////////////////////////////////////////////////
	function YellCommand()
	{
		local BystanderController bcont;

		OrderYelled(class'AuthorityOrderMarker');

		// Tell the NPC a cop is trying to arrest him.
		bcont = BystanderController(Attacker.Controller);
		if(bcont != None)
		{
			bcont.CopTriesToArrestMe(MyPawn);
		}

		PrintDialogue(self$" Freeze! ");

		SayTime = Say(MyPawn.myDialog.lCop_Freeze1, bImportantDialog);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check how close we are--we may need to go straight to dropping your weapon
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local byte StateChange;

		Super.BeginState();

		if(Attacker != None)
		{
			Focus = Attacker;

			ReportAsWanted(Attacker);

			DetermineLeader();

			if(!MyPawn.bTeamLeader)
				GotoStateSave('BackupLeader');
			//else
			//	log(MyPawn$" TEAM LEADER, TEAM LEADER last attacker pos is here"$LastAttackerPos$" attacker is here "$Attacker.Location);

			statecount=0;
		}
	}

LookForAttacker:
	DetectAttackerSomehow(Attacker, 'RunToArrestee');
	CheckToGoKilling();
	Sleep(0.1);
	// See if the guy stopped like you asked, or not
	DecideNextStateBasedOnAttacker();

Begin:
	if(statecount == 0)
	{
		DecideNextStateBasedOnAttacker(true);
		statecount++;
	}
	if(MyPawn.bTeamLeader)
	{
		PlayerHintDropWeapon(Attacker, true, true);
		YellCommand();
		Sleep(0.1);
		NeedToWalkCloser(FREEZE_ADD_DIST*(1.0-MyPawn.Anger) + FREEZE_BASE_DIST);
		Sleep(SayTime);
	}
	else
		Sleep(NON_LEADER_SLEEP_TIME);

	// If it's the player, check to walk closer
	// if it's AI, just attack
	if(Attacker.bPlayer)
		NeedToWalkCloser(FREEZE_ADD_DIST*(1.0-MyPawn.Anger) + FREEZE_BASE_DIST);
	else
		GoKilling();

	// wait for the dialogue and for him to stop
	Sleep(2*UsePatience);

	// See if the guy stopped like you asked, or not
	DecideNextStateBasedOnAttacker();

	// Get more mad because he disobeyed
	GetMoreAngry(MyPawn.Temper);

	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// TellHimToDropWeapon
// Tell attacker to put away his weapon
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TellHimToDropWeapon extends OnTheOffensive
{
	ignores HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere, CheckDeadBody, CheckDeadHead,
		WatchFunnyThing;

	///////////////////////////////////////////////////////////////////////////////
	// Check our attacker, and attack him, if he's too close
	// And also if he's started pouring gas or something
	///////////////////////////////////////////////////////////////////////////////
	function CheckForInterimMisbehave()
	{
		local byte StateChange;

		// See if he's too close first
		CheckForTooCloseAttacker(StateChange);
		if(StateChange == 1)
			return;

		// Now check to make sure he's not pouring gasoline
		if(GasCanWeapon(Attacker.Weapon) != None
			&& Attacker.Weapon.IsFiring())
		{
			GoKilling();
			return;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// If the subject is an NPC and he's after the player, attack him right now
	///////////////////////////////////////////////////////////////////////////////
	function AttackNPCAfterPlayer()
	{
		if(!Attacker.bPlayer 
			&& PersonController(Attacker.Controller) != None
			&& PersonController(Attacker.Controller).Attacker.bPlayer)
			GoKilling();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check the guy you told to drop his weapon. 
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextStateBasedOnAttacker(optional bool bStart)
	{
		local float disttous;
		local byte StateChange;

		// We check the cop to make him start shooting right after the
		// attacker first disobeys our order. That's why we
		// don't check the weapons, then the stop, then check to
		// start attacking.

		// First check if he has a violent weapon out
		CheckForTooCloseAttacker(StateChange);
		if(StateChange == 1)
			return;

		// If we can't see him, go after him
		if(!LineOfSightTo(Attacker))
		{
			SetNextState(GetAggressiveState(), 'LookForAttacker');
			SetEndPoint(LastAttackerPos, FREEZE_BASE_DIST);
			ReportAsWanted(Attacker, true);
			GotoStateSave('RunToArrestee');
			return;
		}

		// Once we can see the guy, treat him pouring gasoline almost
		// the same as if he just took a shot at you. Get more angry, then
		// check to start attacking him
		// Don't check this on entry to the state, only once you get going
		if(!bStart
			&& GasCanWeapon(Attacker.Weapon) != None
			&& Attacker.Weapon.IsFiring())
		{
			GoKilling();
			return;
		}

		// Handle the case where he's ready to be arrested
		if(!LeaderSensesWeapon()
			&& Attacker.ViolentWeaponNotEquipped()
			&& !Attacker.HasPantsDown())
		{
			if(Attacker.NoLegMotion())
			{
				if(MyPawn.bTeamLeader)
				{
					// Check to walk closer first
					NeedToWalkCloser(FREEZE_BASE_DIST, StateChange);
					if(StateChange == 1)
						return;
					// he has stopped also, so arrest him
					GotoStateSave('PrepareToArrestHim');
					return;
				}
				else
				{
					// Check to walk closer first
					NeedToWalkCloser(FREEZE_ADD_DIST*(1.0-MyPawn.Anger) + FREEZE_BASE_DIST, StateChange);
					if(StateChange == 1)
						return;
					GotoStateSave('BackupLeader');
					return;
				}
			}
			else if(!CheckToGoKilling(true))
			{
				// You didn't attack anyway, so tell him to stop moving.
				// because he's gun is down, but he's running around all stupid
				// You're also more mad now becuase you have stop
				// him from moving when you should just be able to arrest him
				GotoStateSave(GetAggressiveState());
			}
		}
		else if(!Attacker.NoLegMotion())
		{
			if(!CheckToGoKilling(true)) // everything in between, just check to start attacking
			{
				// You're also more mad now becuase you have stop
				// him from moving when you should just be able to arrest him
				GotoStateSave(GetAggressiveState());
			}
		}
		else if(!bStart)
			CheckToGoKilling(true);
	}

	///////////////////////////////////////////////////////////////////////////////
	// yell something based on anger
	///////////////////////////////////////////////////////////////////////////////
	function YellCommand()
	{
		local BystanderController bcont;

		OrderYelled(class'AuthorityOrderMarker');

		PrintDialogue(self$" drop it! ");

		// Tell the NPC a cop is trying to arrest him.
		bcont = BystanderController(Attacker.Controller);
		if(bcont != None)
		{
			bcont.CopTriesToArrestMe(MyPawn);
		}

		if(!Attacker.HasPantsDown())
		{
			//PrintDialogue("Put your weapon down!");
			SayTime = Say(MyPawn.myDialog.lCop_PutDownWeapon1, bImportantDialog);
		}
		else
		{
			//PrintDialogue("Pull your pants up!");
			SayTime = Say(MyPawn.myDialog.lCop_PutAwayDick1, bImportantDialog);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check if he's already put his gun away
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local byte StateChange;

		Super.BeginState();

		if(Attacker != None)
		{
			Focus = Attacker;

			ReportAsWanted(Attacker);

			DetermineLeader(true);

			if(!MyPawn.bTeamLeader)
				GotoStateSave('BackupLeader');

			DecideNextStateBasedOnAttacker(true);
		}
	}

Begin:
	if(MyPawn.bTeamLeader)
	{
		PlayerHintDropWeapon(Attacker, true, true);
		YellCommand();
		Sleep(0.1);
		
		// Attack NPC's after the first warning, no matter what, so we react
		// faster to them. Don't give them same leniance as player.
		AttackNPCAfterPlayer();

		// Otherwise, check to move closer to attacker
		NeedToWalkCloser(FREEZE_ADD_DIST*(1.0-MyPawn.Anger) + FREEZE_BASE_DIST);
		Sleep(SayTime);
	}
	else
	{
		Sleep(0.1);
		// Attack NPC's after the first warning, no matter what, so we react
		// faster to them. Don't give them same leniance as player.
		AttackNPCAfterPlayer();
		Sleep(NON_LEADER_SLEEP_TIME);
	}

	NeedToWalkCloser(FREEZE_ADD_DIST*(1.0-MyPawn.Anger) + FREEZE_BASE_DIST);

	// Wait for him to comply, but make sure he doesn't sneak up on you with the weapon
	statecount = GUN_OUT_WAIT_COUNT;
WaitForCompliance:
	Sleep(UsePatience);
	CheckForInterimMisbehave();
	statecount--;
	if(statecount > 0)
		Goto('WaitForCompliance');

	// If it's the player, check to walk closer
	// if it's AI, just attack
	if(Attacker.bPlayer)
		NeedToWalkCloser(FREEZE_ADD_DIST*(1.0-MyPawn.Anger) + FREEZE_BASE_DIST);
	else
		GoKilling();

	// See if the guy complied or not
	DecideNextStateBasedOnAttacker();

	// get more mad because he disobeyed
	GetMoreAngry(MyPawn.Temper);

	Goto('Begin');
}

// See if there are other officers around watching us
function bool OtherCopsAround()
{
	local P2MoCapPawn P;
	
	foreach DynamicActors(class'P2MoCapPawn',P)
	{
		if (P.Controller != None
			&& P.Controller.LineOfSightTo(MyPawn)
			&& !P.Controller.bStasis
			&& P.bAuthorityFigure
			&& P != MyPawn)
		{
			//log("This police"@P@"can see us",'Debug');
			return true;
		}
	}	
}

// Used at the beginning of any "arresting" state.
// Hook the dude for a possible bribe.
function HookDudeForBribe()
{
	if (P2Player(Attacker.Controller) != None
		&& MyPawn.bTeamLeader)	// Only offer bribes if we're the team leader
	{
		P2Player(Attacker.Controller).InterestPawn = myPawn;
		// Switch to their money as a bribery hint
		// But only if there aren't any other cops around
		if (!OtherCopsAround() && bRejectedBribe)
			P2Player(Attacker.Controller).SwitchToThisPowerup(class'MoneyInv'.default.InventoryGroup, class'MoneyInv'.default.GroupOffset);
	}
}

// Used at the end of any "arresting" state.
// Unhook the dude from bribe
function UnhookDudeForBribe()
{
	if (P2Player(Attacker.Controller) != None
		&& P2Player(Attacker.Controller).InterestPawn == MyPawn)
		P2Player(Attacker.Controller).InterestPawn = None;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You're arresting someone
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PrepareToArrestHim extends OnTheOffensive
{
	ignores HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere, CheckDeadBody, CheckDeadHead,
		WatchFunnyThing;

	///////////////////////////////////////////////////////////////////////////////
	// Check the attacker only, to make sure he's not run off or something
	///////////////////////////////////////////////////////////////////////////////
	function CheckObservePawnLooks(FPSPawn LookAtMe)
	{
		if(Attacker == LookAtMe
			&& CanSeePawn(MyPawn, LookAtMe))
		{
			if(!CheckForPrelimCuff())
				GoKilling();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check for everything being happy before you read him his rights
	// or start walking to cuff him.
	///////////////////////////////////////////////////////////////////////////////
	function bool CheckForPrelimCuff()
	{
		local float dotcheck;
		local vector dir;

		// Check to see if you are facing me, reasonably speaking
		dir = MyPawn.Location - Attacker.Location;
		//dotcheck = Normal(dir) Dot vector(Attacker.Rotation);

		// If not everything is met, he starts attacking
		if(!Attacker.ViolentWeaponNotEquipped()
			|| Attacker.HasPantsDown()
			//|| !Attacker.NoLegMotion()
			|| !CanSeePawn(MyPawn, Attacker)
			//|| (dotcheck < FACING_ME_CONE)
			|| VSize(dir) > FREEZE_BASE_DIST
			// If the dude is suiciding don't try to send him to jail
			|| Attacker.Controller.IsInState('PlayerSuicideByGrenade')
			// If the dude is radar targeting don't try to arrest him
			|| (P2Player(Attacker.Controller) != None && P2Player(Attacker.Controller).RadarTargetState != ERTargetOff)
			)
		{
			return false;
		}
		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check for everything being happy before you really try to cuff him
	///////////////////////////////////////////////////////////////////////////////
	function bool CheckForFinalCuff()
	{
		local float dotcheck;
		local vector dir;

		// Check to see if you are facing me, reasonably speaking
		dir = MyPawn.Location - Attacker.Location;
		dotcheck = Normal(dir) Dot vector(Attacker.Rotation);

		// If not everything is met, he starts attacking
		if(!Attacker.ViolentWeaponNotEquipped()
			|| Attacker.HasPantsDown()
			//|| !Attacker.NoLegMotion()
			|| !CanSeePawn(MyPawn, Attacker)
			//|| (dotcheck < FACING_ME_CONE)
			|| VSize(dir) > CLOSE_ENOUGH_FOR_FINAL_CUFF + Attacker.CollisionRadius
			// If the dude is suiciding don't try to send him to jail
			|| Attacker.Controller.IsInState('PlayerSuicideByGrenade'))
		{
			return false;
		}
		return true;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Get out your gun when threatened
	// Handle anims
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		DetermineLeader(true);

		MyPawn.StopAcc();
		SwitchToBestWeapon();
		MyPawn.SetMood(MOOD_Combat, 1.0);

		// Check if our attacker is dead, if so, don't care about them anymore
		if(Attacker.Health <= 0
			|| Attacker.Controller == None)
		{
			GotoStateSave('LookAroundForTrouble');
			return;
		}

		PlayerHintDropWeapon(Attacker, true, true);
		HookDudeForBribe();
		if(Attacker.bPlayer)
			bImportantDialog=true;
	}
	
	function EndState()
	{
		// Unhook from player if we've hooked him for a possible bribe
		Super.EndState();
		UnhookDudeForBribe();
	}
	
	// Handle dude bribery
	function bool AcceptItem(P2Pawn Payer, Inventory thisitem, 
							out float AmountTaken, float FullAmount)
	{
		// Unhook from interestpawn
		// But only if we're the guy he's trying to pay off
		if (P2Player(Payer.Controller).InterestPawn == MyPawn)
			P2Player(Payer.Controller).InterestPawn = None;
		
		// Only the leader (the guy doing the arrest) can be bribed
		if (!MyPawn.bTeamLeader)
			return false;

		if (bIgnoreFutureBribes)
			return false;
			
		if (Payer == Attacker
			&& thisitem.Class == class'MoneyInv')
		{		
			// After two bribe attempts, ignore future bribes.
			// This is so the player doesn't just sit there spamming the enter key.
			bIgnoreFutureBribes = bRejectedBribe;
			
			// Decide if we want to take the bribe
			if (!bRejectedBribe && !OtherCopsAround() && FullAmount >= BRIBE_MIN)
			{
				// Take the bribe
				AmountTaken = FullAmount;
				GotoState('AcceptedBribe');
				// Award achievement
				if( Level.NetMode != NM_DedicatedServer ) PlayerController(Payer.Controller).GetEntryLevel().EvaluateAchievement(PlayerController(Payer.Controller),'CopBribery');
				return true;
			}
			else
			{
				// Get mad
				GotoState('RejectedBribe');
				return false;
			}
		}	
	}

Begin:
	PrintDialogue("You're under arrest!");
	OrderYelled(class'AuthorityOrderMarker');
	SayTime = Say(MyPawn.myDialog.lCop_UnderArrest, bImportantDialog);
	
	// Tell the dude we're going to arrest him, but hook into InterestPawn in case he might try to bribe his way out.
	// Let them attempt the bribe even if it's going to fail
	HookDudeForBribe();
	
	Sleep(SayTime);
	//PrintDialogue("Now face towards me");
	//sleep(SayTime);
	// Save where we originally said freeze, so if he moves, we can 
	// be mad
	SetEndGoal(Attacker, CLOSE_ENOUGH_FOR_FINAL_CUFF);
	SaveAttackerData();
	EndPoint = LastAttackerPos;
	bStraightPath=true;
	SetNextState('GetOutCuffs');
	GotoStateSave('WalkToArrestee');
}

// Took the bribe
state AcceptedBribe extends PrepareToArrestHim
{
Begin:
	// Say something cool
	PrintDialogue("You rule!");
	SayTime = Say(MyPawn.MyDialog.lThanks, true);
	// Put away the gun or cuffs
	SwitchToHands();
	// Take the money from them
	MyPawn.PlayTakeGesture();
	Sleep(SayTime + 1.0);
	// Set that we rejected the bribe anyway -- we won't let them go if they screw up again.
	bRejectedBribe = true;
	// Reset cop radio time and attacker.
	P2GameInfoSingle(Level.Game).TheGameState.CopRadioTime = 0;
	Attacker = None;
	// Go about our business like nothing happened
	GotoState('Thinking');
}

// Rejected the bribe
state RejectedBribe extends PreparetoArrestHim
{
Begin:
	// Tell them off
	PrintDialogue("You can't bribe me!");
	SayTime = Say(MyPawn.MyDialog.lDefiant, true);
	// Set that we rejected the bribe
	bRejectedBribe = true;
	MyPawn.PlayTellOffAnim();
	Sleep(SayTime);
	// Maybe hit them with the baton
	if (FRand() <= 0.25)
	{
		// Shoot him once
		GotoState('ShootAtAttacker', 'FireNowPrep');
	}
	else
	{
		// Go back to arresting them
		GotoState('PrepareToArrestThem');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Put away your gun and get out the hand cuffs
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state GetOutCuffs extends PrepareToArrestHim
{
	///////////////////////////////////////////////////////////////////////////////
	// Make sure he's still not moving and doesn't have a gun, if either one, attack
	// Or if he's not facing towards the cop
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		DetermineLeader(true);
		if(MyPawn.bTeamLeader)
		{
			if(!CheckForPrelimCuff())
			{
				GoKilling();
				return;
			}
		}
		else
		{
			GotoStateSave('BackupLeader');
			return;
		}

		if(Attacker.bPlayer)
			bImportantDialog=true;

		PlayerHintDropWeapon(Attacker, true, true);
		HookDudeForBribe();
	}

Begin:
	PrintDialogue("Now just hold still...");
	SayTime = Say(MyPawn.myDialog.lCop_HoldStill, bImportantDialog);
	Sleep(SayTime);

	// See if he's ready to be cuffed.
	// If so, get out the cuffs,.. if not, attack.
	if(CheckForPrelimCuff())
	{
		// Check if there's some idiot in the way or something.. if so
		// then handle them or swap leaders
		NeedToWalkCloser(FREEZE_BASE_DIST);

		// If we didn't have to get closer, get out our handcuffs
		SwitchToThisWeapon(class'HandCuffsWeapon'.default.InventoryGroup,
							class'HandCuffsWeapon'.default.GroupOffset);

		// If he haven't told him his rights yet, read them
		//if(!bReadDudeHisRights)
			GotoStateSave('ReadHimHisRights');
		//else // otherwise, just go cuff him
		//{
		//	SetEndGoal(Attacker, CLOSE_ENOUGH_FOR_FINAL_CUFF);
		//	SaveAttackerData();
		//	EndPoint = LastAttackerPos;
		//	SetNextState('CuffHim');
		//	GotoStateSave('WalkToCuffAttacker');
		//}
	}
	else
	{
		GoKilling();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You're putting handcuffs on them.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ReadHimHisRights extends PrepareToArrestHim
{
	///////////////////////////////////////////////////////////////////////////////
	// Have dude make smarmy remark, if he's not getting ready to attack again
	///////////////////////////////////////////////////////////////////////////////
	function DudeRemarks()
	{
		local P2Player p2p;

		p2p = P2Player(Attacker.Controller);

		if(p2p != None)
		{
			CurrentFloat = p2p.CommentOnGettingArrested();
		}
		else
			CurrentFloat = 0;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Override super version and don't do a weapon switch on startup
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		if(Attacker.bPlayer)
			bImportantDialog=true;

		PrintThisState();
		DetermineLeader(true);
		if(!MyPawn.bTeamLeader)
			GotoStateSave('BackupLeader');

		PlayerHintDropWeapon(Attacker, true, true);
		HookDudeForBribe();
	}

Begin:
	PrintDialogue("You have the right to remain silent...");
	OrderYelled(class'AuthorityOrderMarker');
	SayTime = Say(MyPawn.myDialog.lCop_Miranda, bImportantDialog);
	// Check in between for misbehavior, while you read him his rights
	Sleep(SayTime/2);
	if(!CheckForPrelimCuff())
		GoKilling();

	// Have dude make smarmy remark, if he's not getting ready to attack again
	DudeRemarks();

	Sleep(SayTime/2);

	// CurrentFloat stores the extra time the dude is talking.. wait for him to stop also
	CurrentFloat -= SayTime/2;
	if(CurrentFloat > 0)
	{
		if(!CheckForPrelimCuff())
			GoKilling();
		Sleep(CurrentFloat);
	}

	// If we got through all the Miranda rights without a problem, say we read them
	// to him, and mark it so we won't do this state again, if we've already completed it.
	//bReadDudeHisRights=true;

	// if we're good for a cuff, walk to him
	if(CheckForPrelimCuff())
	{
		// Check if there's some idiot in the way or something.. if so
		// then handle them or swap leaders
		NeedToWalkCloser(FREEZE_BASE_DIST);

		SetEndGoal(Attacker, CLOSE_ENOUGH_FOR_FINAL_CUFF);
		SaveAttackerData();
		EndPoint = LastAttackerPos;
		SetNextState('CuffHim');
		GotoStateSave('WalkToCuffAttacker');
	}
	else	// can't cuff him, so attack him
	{
		GoKilling();
	}
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You're putting handcuffs on them.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state CuffHim extends PrepareToArrestHim
{
	///////////////////////////////////////////////////////////////////////////////
	// Actually setup for sending to jail.
	///////////////////////////////////////////////////////////////////////////////
	function SendingPlayerToJail(P2Player p2p)
	{
		local P2GameInfoSingle p2g;

		p2g = P2GameInfoSingle(Level.Game);
		UnhookDudeForBribe();

		if(p2g != None)
		{
			// Can't really send him to jail in demo, so put up menu
			if(Level.IsDemoBuild())
			{
				P2RootWindow(p2p.Player.InteractionMaster.BaseMenu).ArrestedDemo();
			}
			else
			{
				// Do anything special to get out of different states while being
				// sent to jail
				p2p.GettingSentToJail();
				//log(MyPawn$"I SENT YOU TO JAIL "$Attacker);
				// Do the actual level travel
				P2GameInfoSingle(Level.Game).SendPlayerToJail(p2p);
			}
		}
		else
			warn("Can't send him to jail for some reason! player: "$p2p);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Override super version and don't do a weapon switch on startup
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();
		DetermineLeader(true);
		if(!MyPawn.bTeamLeader)
			GotoStateSave('BackupLeader');

		PlayerHintDropWeapon(Attacker, true, true);
		HookDudeForBribe();
	}

Begin:
	if(CheckForFinalCuff())
	{
		// Actual code that begins the sending.
		if(P2Player(Attacker.Controller) != None)
		{
			// Unhook from interestpawn
			P2Player(Attacker.Controller).InterestPawn = None;
			
			SendingPlayerToJail(P2Player(Attacker.Controller));
			Sleep(1.0);
		}
		GotoStateSave('LookAroundForTrouble');
	}
	else	// can't cuff him, so attack him
	{
		GoKilling();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// LookingForAttacker
// Wander around where you last saw him
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state LookingForAttacker
{
	function BeginState()
	{
		Super.BeginState();
		bReportedPlayer=false;
	}

}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ShootAtAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShootAtAttacker
{
	ignores HandleNewImpersonator;

	///////////////////////////////////////////////////////////////////////////////
	// Somebody squirted on me while I was fighting
	///////////////////////////////////////////////////////////////////////////////
	function BodyJuiceSquirtedOnMe(P2Pawn Other, bool bPuke)
	{
		if(!MyPawn.IsTalking())
			MyPawn.DisgustedSpitting(MyPawn.myDialog.lGettingPissedOn);

		if(bPuke)
			// Definitely throw up from puke on me
			CheckToPuke(, true);

		// Check to wipe it off
		if(FRand() < 0.05)
			CheckWipeFace();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check out attacker just before you shoot--you may want to hold your fire
	///////////////////////////////////////////////////////////////////////////////
	function EvaluateAttacker()
	{
		if(Attacker != None
			&& (!Attacker.HasPantsDown()
				|| AnimalPawn(Attacker) != None))
			bHateAttacker=true;
		SwitchToBestWeapon();
	}

	///////////////////////////////////////////////////////////////////////////////
	// During a fight, decide to stop fighting, if he sort of surrenders.
	///////////////////////////////////////////////////////////////////////////////
	function HandleSurrender(FPSPawn LookAtMe, out byte StateChange)
	{
		if(MyPawn.bTeamLeader)
		{
			// Save the last real weapon we've seen
			if(P2Weapon(LookAtMe.Weapon) != None
				&& P2Weapon(LookAtMe.Weapon).ViolenceRank > 0)
				SetLastWeaponSeen(LookAtMe, class<P2Weapon>(LookAtMe.Weapon.class));
		}

		// If he's got nothing out, 
		// OR if he's got a melee weapon, but too far away to use it
		// then try to arrest him again, possibly
		if(P2Pawn(Attacker) != None
			&& Attacker == LookAtMe
			&& (Attacker.ViolentWeaponNotEquipped()
				|| (Attacker.Weapon != None
					&& Attacker.Weapon.bMeleeWeapon
					&& !TooCloseWithWeapon(Attacker, true)
					&& !Attacker.Weapon.IsFiring())))
		{
			// If he has his pants down, but is not actively pissing then give him 
			// a break
			if(!Attacker.HasPantsDown()
				|| Attacker.Weapon != None
				|| (!Attacker.Weapon.IsFiring()
					&& (firecount == 0
						|| !MyPawn.Weapon.bMeleeWeapon)))
			{
				// Check to make sure he doesn't look all innocent by not having any weapons
				// out (which would make you just try to arrest you) but he may have just kicked
				// you, so then you'll want to hurt him first, then arrest him. So clear the last
				// damage you recieved, and go to shooting him once, then quit
				if(MyPawn.LastDamageType == class'KickingDamage')
				{
					// Clear it
					MyPawn.LastDamageType = None;
					// Shoot him once
					GotoStateSave('ShootAtAttacker', 'FireNowPrep');
					StateChange=1;
					return;
				}
				else
				{
					// Since we're changing back from attacking him, to trying to
					// arrest him, make sure, if you're the leader, to tell anyone/everyone
					// else around you, and who considers you the leader, to switch back
					// to backing up in the arrest (and to stop attacking him)
					if(MyPawn.bTeamLeader)
						FollowLeadersState(GetAggressiveState(),,,,,,,,true);
					GotoStateSave(GetAggressiveState());
					Enemy = None;
					firecount=0;
					StateChange=1;
					return;
				}
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// We see our attacker, check his weapons
	///////////////////////////////////////////////////////////////////////////////
	function ActOnPawnLooks(FPSPawn LookAtMe, optional out byte StateChange)
	{
		local byte WasOurGuy;

		HandleSurrender(LookAtMe, WasOurGuy);
		StateChange=WasOurGuy;

		// Continue on, if we didn't change states
		if(WasOurGuy == 0
			&& !FriendWithMe(LookAtMe))
			Super.ActOnPawnLooks(LookAtMe, StateChange);
	}

	///////////////////////////////////////////////////////////////////////////
	// When attacked while you're attacking
	// ignore cops shooting you, or at least say something
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		// We only try to move after friendly fire
		if(FriendWithMe(FPSPawn(Other)))
		{
			PerformStrategicMoves(true);
			return;
		}

		ReportAfterHit();

		PolicedamageAttitudeTo(Other, Damage);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Definitely report the guy we're attacking
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		// Figure out our best weapon now (even though we check again later on)
		EvaluateAttacker();

		Super.BeginState();

		// If we want to fight the player but we're not, think about
		// forgetting him early. This fixes the problem of cops chasing the player,
		// then going after someone else who drops there weapon. They continue to chase
		// them down with the baton (which people like) but they would keep the cop meter
		// active (which people didn't) for the long time it would take them to kill the other guy.
		if(PlayerAttackedMe != None
			&& Attacker != PlayerAttackedMe
			&& Level.TimeSeconds - MAX_REMEMBER_PLAYER_TIME > PlayerAttackTime)
		{
			FullClearAttacker(true);
		}


		ReportAsWanted(Attacker);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ShootAtAttackerDistance
// Just like the above version, but we do this when we can't get any closer
// to the attacker, at least for a little while. 
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShootAtAttackerDistance
{
	///////////////////////////////////////////////////////////////////////////////
	// Somebody squirted on me while I was fighting
	///////////////////////////////////////////////////////////////////////////////
	function BodyJuiceSquirtedOnMe(P2Pawn Other, bool bPuke)
	{
		if(!MyPawn.IsTalking())
			MyPawn.DisgustedSpitting(MyPawn.myDialog.lGettingPissedOn);

		if(bPuke)
			// Definitely throw up from puke on me
			CheckToPuke(, true);

		// Check to wipe it off
		if(FRand() < 0.05)
			CheckWipeFace();
	}

	///////////////////////////////////////////////////////////////////////////////
	// We see our attacker, check his weapons
	///////////////////////////////////////////////////////////////////////////////
	function ActOnPawnLooks(FPSPawn LookAtMe, optional out byte StateChange)
	{
		local byte WasOurGuy;

		HandleSurrender(LookAtMe, WasOurGuy);
		StateChange=WasOurGuy;

		// Continue on, if we didn't change states
		if(WasOurGuy == 0
			&& !FriendWithMe(LookAtMe))
			Super.ActOnPawnLooks(LookAtMe, StateChange);
	}

	///////////////////////////////////////////////////////////////////////////
	// When attacked while you're attacking
	// ignore cops shooting you, or at least say something
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		// We only try to move after friendly fire
		if(FriendWithMe(FPSPawn(Other)))
		{
			PerformStrategicMoves(true);
			return;
		}

		ReportAfterHit();

		PolicedamageAttitudeTo(Other, Damage);
	}

	///////////////////////////////////////////////////////////////////////////////
	// During a fight, decide to stop fighting, if he sort of surrenders.
	///////////////////////////////////////////////////////////////////////////////
	function HandleSurrender(FPSPawn LookAtMe, out byte StateChange)
	{
		if(MyPawn.bTeamLeader)
		{
			// Save the last real weapon we've seen
			if(P2Weapon(LookAtMe.Weapon) != None
				&& P2Weapon(LookAtMe.Weapon).ViolenceRank > 0)
				SetLastWeaponSeen(LookAtMe, class<P2Weapon>(LookAtMe.Weapon.class));
		}

		// If he's got nothing out, 
		// OR if he's got a melee weapon, but too far away to use it
		// then try to arrest him again, possibly
		// At a distance, don't screw around with his pants down--kill him
		if(P2Pawn(Attacker) != None
			&& Attacker == LookAtMe
			&& !Attacker.HasPantsDown()
			&& (Attacker.ViolentWeaponNotEquipped()
				|| (Attacker.Weapon != None
					&& Attacker.Weapon.bMeleeWeapon
					&& !TooCloseWithWeapon(Attacker, true)
					&& !Attacker.Weapon.IsFiring())))
		{
			if(Attacker.Weapon != None
				|| (!Attacker.Weapon.IsFiring()
					&& (firecount == 0
						|| !MyPawn.Weapon.bMeleeWeapon)))
			{
				// Check to make sure he doesn't look all innocent by not having any weapons
				// out (which would make you just try to arrest you) but he may have just kicked
				// you, so then you'll want to hurt him first, then arrest him. So clear the last
				// damage you recieved, and go to shooting him once, then quit
				if(MyPawn.LastDamageType == class'KickingDamage')
				{
					// Clear it
					MyPawn.LastDamageType = None;
					// Shoot him once
					GotoStateSave('ShootAtAttacker', 'FireNowPrep');
					StateChange=1;
					return;
				}
				else
				{
					// We're not getting ready to arrest him, we're just waiting on him
					// to get down and quit being stupid. Tell everyone to do the same.
					if(MyPawn.bTeamLeader)
						FollowLeadersState('WatchAttackerHighUp',,,,,,,,true);
					GotoStateSave('WatchAttackerHighUp');
					Enemy = None;
					firecount=0;
					StateChange=1;
					return;
				}
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////
	// Just try to run to him again after you've shot some
	// But since we can't run closer for the most part (because he's up
	// high and at some stupid point) check to see if he's put down his
	// weapon manually.
	///////////////////////////////////////////////////////////////////////////
	function CheckToMoveAround()
	{
		local byte StateChange;
		local NavigationPoint pnode;
		local int i;

		if(firecount == 0)
		{
			HandleSurrender(Attacker, StateChange);
			// If he didn't put his weapon down, check to run to him again
			if(StateChange == 0)
			{
				// Try for the player again. We're hoping he's down
				// from his silly high point and we can get him.
				if(FRand() < TRY_FOR_ATTACKER_DOWN)
				{
					SetEndPoint(LastAttackerPos, DEFAULT_END_RADIUS);
					SetNextState('ShootAtAttacker', 'WaitTillFacing');
					GotoStateSave('RunToAttacker');
				}
				else
				{
					// If you have an anchor, go through it's reachspec, and 
					// pick a random end.
					if(MyPawn.Anchor != None)
					{
						i = Rand(MyPawn.Anchor.PathList.Length);
						if(MyPawn.Anchor.PathList.Length > 0)
							pnode = MyPawn.Anchor.PathList[i].end;
						if(pnode != None
							&& MyPawn.Anchor != pnode)
						{
							Focus = pnode;

							//log(self$" running to "$pnode);
							SetEndGoal(pnode, DEFAULT_END_RADIUS);
							bStraightPath=UseStraightPath();
							SetNextState('ShootAtAttacker');
							GotoStateSave('RunToAttacker');
						}
					}
				}
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Just switch to your best weapon--no baton, melee stuff here
	///////////////////////////////////////////////////////////////////////////////
	exec function SwitchToBestWeapon()
	{
		Super(PersonController).SwitchToBestWeapon();
	}

	///////////////////////////////////////////////////////////////////////////
	// Always pick your best weapon
	///////////////////////////////////////////////////////////////////////////
	function bool DecideToPickBestWeapon()
	{
		return true;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WatchAttackerHighUp
// Attacker is in some stupid spot without path nodes that you can't really
// reach, so watch him till he gets down and then go beat his ass.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WatchAttackerHighUp
{
	///////////////////////////////////////////////////////////////////////////////
	// Just switch to your best weapon--no baton, melee stuff here
	///////////////////////////////////////////////////////////////////////////////
	exec function SwitchToBestWeapon()
	{
		Super(PersonController).SwitchToBestWeapon();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check if it's our attacker
	///////////////////////////////////////////////////////////////////////////////
	function CheckObservePawnLooks(FPSPawn LookAtMe)
	{
		local vector StartLoc;

		if(LookAtMe == Attacker)
		{
			StartLoc = MyPawn.Location;
			StartLoc.z += MyPawn.EyeHeight;
			// Check first to make sure nothing is in the way
			if(FastTrace(StartLoc, LookAtMe.Location))
			{
				// Check to see if you can see the bad guy better than your
				// team leader
				if(MyPawn.MyLeader != None
					&& PoliceController(MyPawn.MyLeader.Controller) != None
					&& !FastTrace(LookAtMe.Location, MyPawn.MyLeader.Location))
					DoLeaderSwap(MyPawn.MyLeader, MyPawn);

				CurrentFloat = 0; // Reset each time we can see him
				Focus = Attacker;	// Look at him
				LastAttackerPos = LookAtMe.Location;
				// And make sure he has a gun out before we attack him
				if(P2Weapon(Attacker.Weapon) != None
					&& P2Weapon(Attacker.Weapon).ViolenceRank > 0)
					GotoStateSave('ShootAtAttackerDistance');
				else if(FRand() < RUN_TO_NEW_POINT)
				{
					GotoStateSave('WatchAttackerHighUp', 'MoveAround');
				}
			}
			else if(Focus == Attacker) // loose focus
			{
				FocalPoint = Focus.Location;
				Focus = None;
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// yell something based on anger
	///////////////////////////////////////////////////////////////////////////////
	function YellCommand()
	{
		local BystanderController bcont;

		OrderYelled(class'AuthorityOrderMarker');

		PrintDialogue(self$" drop it! ");

		// Tell the NPC a cop is trying to arrest him.
		bcont = BystanderController(Attacker.Controller);
		if(bcont != None)
		{
			bcont.CopTriesToArrestMe(MyPawn);
		}

		if(!Attacker.HasPantsDown())
		{
			PrintDialogue("Put your weapon down!");
			SayTime = Say(MyPawn.myDialog.lCop_PutDownWeapon1, bImportantDialog);
		}
		else
		{
			PrintDialogue("Pull your pants up!");
			SayTime = Say(MyPawn.myDialog.lCop_PutAwayDick1, bImportantDialog);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Say things to him while you can't get to him
	///////////////////////////////////////////////////////////////////////////////
	function float TalkToAttacker()
	{
		SayTime = 0;
		if(MyPawn.bTeamLeader
			&& FRand() < TALK_TO_GUY_HIGH_UP)
		{
			if(LeaderSensesWeapon())
			{
				PlayerHintDropWeapon(Attacker, true, true);
				YellCommand();
			}
			else
			{
				// Yell get down if he's above you
				if(Rand(2) == 0
					&& Attacker.Location.z > (MyPawn.Location.z + MyPawn.CollisionHeight))
				{
					PrintDialogue("Get down here!");
					SayTime = Say(MyPawn.myDialog.lGetDown);
				}
				else
				{
					PrintDialogue("You're not so tough...");
					SayTime = Say(MyPawn.myDialog.lTrashTalk);
				}
			}
		}
		return SayTime;
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		PlayerHintDropWeapon(Attacker, false);
		bImportantDialog=false;
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		// If you're not the leader, crank up your wait time
		if(!MyPawn.bTeamLeader)
			statecount++;

		if(Attacker.bPlayer)
			bImportantDialog=true;
		else
			bImportantDialog=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Shoot at a guy from behind the fire, waiting to advance again
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ShootAttackerBehindFire extends ShootAtAttacker
{
	ignores damageAttitudeTo;

	///////////////////////////////////////////////////////////////////////////////
	// See if there's someone in the way, if so handle it
	///////////////////////////////////////////////////////////////////////////////
	function CheckForObstacle(optional out byte StateChange)
	{
		local Actor HitActor;
		local vector HitLocation, HitNormal;
		//local vector checkdir;

		//checkdir = vector(MyPawn.Rotation);

		//Pawn.Location + (VISUALLY_FIND_RADIUS * checkdir)
		HitActor = Trace(HitLocation, HitNormal, Attacker.Location, MyPawn.Location, true);
		if(HitActor != None)
		// Something was in the way
		{
			if(FPSPawn(HitActor) != None)
			{
				// If it's our target, then leave now, because we want to shoot him
				if(HitActor == Attacker)
					return;

				// If there's someone in the way (other than the person you're trying to kill)
				// then do something about it
				if(P2Pawn(HitActor) != None
					&& FRand() <= MyPawn.Compassion)
				// This means we don't want to kill innocents, so try to move them
				{
					HandleHumanObstacle(P2Pawn(HitActor));
					return;
				}
			}
			else if(MyPawn.PawnInitialState != MyPawn.EPawnInitialState.EP_Turret)
			// It's not a  pawn, and we're not a turret
			// so negotiate it or wait
			{
				// Decide here, that sometimes when we're tracking a guy, we
				// might want to wait before following him around stuff. So 
				// sometimes, we'll go into waiting, hiding mode--that is, if we
				// have cover

				// Check if we have cover
				if(statecount == 0 && FRand() <= MyPawn.WillUseCover)
				{
					RunToSafePoint(Rand(HIDING_WAIT_TIME));
				}
				else // if not ducking and waiting, follow him immediately
				{
					SetEndPoint(LastAttackerPos, MyPawn.AttackRange.Min);
					// and reduce our attack range, so he'll try for closer next time
					SetAttackRange(MyPawn.AttackRange.Min*0.95);
					SetNextState('ShootAtAttacker', 'LookForAttacker');
					bStraightPath=UseStraightPath();
					GotoStateSave('RunToAttacker');
					return;
				}
			}
		}
	}

WaitTillFacing:

	Focus = Attacker;
	FinishRotation();
	//Sleep(0.5);

Begin:
	if(Enemy == None || Enemy.Health <= 0)
	{
		SetAttacker(None);
		Enemy = None;
		GotoStateSave('Thinking');
	}

	//CheckForObstacle();

FireNowPrep:
	DecideFireCount();
FireNow:
	// We know we can still see him here, so record his 
	SaveAttackerData();

	FireWeaponAt(Enemy);
	StopFiring();

	Sleep(MyPawn.Twitch);

	// Test to attacker, if there's no fire, you can go ahead and run to
	// him, otherwise, wait and attack
	InterestActor = CheckForFire(MyPawn.Location, LastAttackerPos);//InterestVect2);

	//log("interest actor "$InterestActor);
	//log("check point "$LastAttackerPos);
	if(InterestActor == None)
	{
		// carry on a normal attack
		//log("i'm ready to attack again");
		GotoStateSave('ShootAtAttacker');
	}
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Cops don't scream when running from a pissing guy
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunFromPisser
{
	ignores TryToScream, CheckObservePawnLooks;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunToFireSafeRange
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToFireSafeRange
{
	function BeginState()
	{
		Super.BeginState();
		SetNextState('ManageBystandersAroundFire');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run to your attacker, or where he last was, and ignore most stuff.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToAttacker
{
	///////////////////////////////////////////////////////////////////////////
	// When attacked while you're attacking
	// ignore cops shooting you, or at least say something
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		// We don't care about friendly fire
		if(FriendWithMe(FPSPawn(Other)))
		{
			return;
		}

		PolicedamageAttitudeTo(Other, Damage);
	}
	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after you got hung up on something
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterHangUp()
	{
		local byte StateChange;

		//log(MyPawn$" NextStateAfterHangUp");
		// He's playing hard to get, so hang around.
		if(Attacker != None
			&& (MyNextState == 'ShootAtAttacker'))
		{
			if(MyPawn.bHasDistanceWeapon
				&& FastTrace(MyPawn.Location, Attacker.Location))
			{
				GotoStateSave('ShootAtAttackerDistance');
			}
			else 
			{
				GotoStateSave('WatchAttackerHighUp');
			}
		}
		if(StateChange == 0)
			Super.NextStateAfterHangUp();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run to a target, but ignore everything we can think of
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToTargetIgnoreAll
{
	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after you got hung up on something
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterHangUp()
	{
		local byte StateChange;

		//log(MyPawn$" NextStateAfterHangUp");
		// He's playing hard to get, so hang around.
		if(Attacker != None
			&& (MyNextState == 'ShootAtAttacker'))
		{
			if(MyPawn.bHasDistanceWeapon
				&& FastTrace(MyPawn.Location, Attacker.Location))
			{
				GotoStateSave('ShootAtAttackerDistance');
				StateChange = 1;
			}
			else 
			{
				GotoStateSave('WatchAttackerHighUp');
				StateChange = 1;
			}
		}
		if(StateChange == 0)
			Super.NextStateAfterHangUp();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run to a enemy that we want to arrest, and ignore most stuff.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToArrestee extends RunToAttacker
{
	///////////////////////////////////////////////////////////////////////////////
	// If the SetActorTarget functions below can't find a proper path and end up
	// just setting the next move target as the destination itself, this function
	// will be called, so you can possibly exit your state and do something else instead.
	///////////////////////////////////////////////////////////////////////////////
	function CantFindPath(Actor Dest, optional vector DestPoint)
	{
		//log(self$" Attacker "$Attacker$" my next "$MyNextState$" distance "$MyPawn.bHasDistanceWeapon$" trace "$FastTrace(MyPawn.Location, Attacker.Location));
		if(Attacker != None
			&& (MyNextState == 'TellHimToFreeze'
				|| MyNextState == 'TellHimToDropWeapon'
				|| MyNextState == 'ShootAtAttacker'))
		{
			if(MyPawn.bHasDistanceWeapon
				&& P2Weapon(Attacker.Weapon) != None
				&& P2Weapon(Attacker.Weapon).ViolenceRank > 0
				&& FastTrace(MyPawn.Location, Attacker.Location))
			{
				GotoStateSave('ShootAtAttackerDistance');
			}
			else 
			{
				GotoStateSave('WatchAttackerHighUp');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after you got hung up on something
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterHangUp()
	{
		local byte StateChange;

		//log(MyPawn$" NextStateAfterHangUp");
		// He's playing hard to get, so hang around.
		if(Attacker != None
			&& (MyNextState == 'TellHimToFreeze'
				|| MyNextState == 'TellHimToDropWeapon'
				|| MyNextState == 'ShootAtAttacker'
			))
		{
			if(MyPawn.bHasDistanceWeapon
				&& P2Weapon(Attacker.Weapon).ViolenceRank > 0
				&& FastTrace(MyPawn.Location, Attacker.Location))
			{
				GotoStateSave('ShootAtAttackerDistance');
			}
			else 
			{
				GotoStateSave('WatchAttackerHighUp');
			}
		}
		if(StateChange == 0)
			Super.NextStateAfterHangUp();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Give hints as you walk to him
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		PlayerHintDropWeapon(Attacker, true);
	}
	function EndState()
	{
		Super.EndState();
		PlayerHintDropWeapon(Attacker, false);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunToDeadThing
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunToDeadThing extends RunToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// Derail us to try again
	///////////////////////////////////////////////////////////////////////////////
	function CantFindPath(Actor Dest, optional vector DestPoint)
	{
		//log(MyPawn$" can't get to it "$Dest$" pt "$DestPoint);
		// Either stare at a while, or give up all together
		if(FRand() > MyPawn.Curiosity)
		{
			DangerPos = InterestActor.Location;
			GotoStateSave('LookAroundDeadBody');
		}
		else // give up
			GotoStateSave('Thinking');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToTargetFindAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToTargetFindAttacker
{
	// Always have your gun out (no baton) when looking for your bad guy like this
	function SwitchToBestWeapon()
	{
		Super(PersonController).SwitchToBestWeapon();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToIdentifyWeapon
// Get a little closer to see what this guy has in his hands
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToIdentifyWeapon extends WalkToTarget
{
	ignores RespondToTalker, PerformInterestAction, CanStartConversation,
		RatOutAttacker, TryToSeeWeapon, TryToGreetPasserby, HandleStasisChange, FreeToSeekPlayer,
		CheckDeadBody, CheckDeadHead, WatchFunnyThing;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToSuspect
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToSuspect extends WalkToTarget
{
	ignores RespondToTalker, PerformInterestAction, RatOutAttacker, DoWaitOnOtherGuy, CanStartConversation,
		CheckForIntruder, TryToGreetPasserby, HandleNewImpersonator, HandleStasisChange, FreeToSeekPlayer,
		CheckDeadBody, CheckDeadHead, WatchFunnyThing;

	///////////////////////////////////////////////////////////////////////////////
	// Decide what to do if you bump a static mesh
	///////////////////////////////////////////////////////////////////////////////
	function BumpStaticMesh(Actor Other)
	{
		CheckBumpStaticMesh(Other);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check to see if he's still still, if not, get mad possibly
	///////////////////////////////////////////////////////////////////////////////
	function CheckForAttackerMoved(out byte StateChange)
	{
		if(VSize(EndPoint - Attacker.Location) > FREEZE_BASE_DIST)
		{
			// So if you didnt' already attack him for moving,
			// then tell him to freeze again
			GetMoreAngry(MyPawn.Temper);
			GotoStateSave(GetAggressiveState());
			StateChange=1;
			return;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// You currently only care about the looks of the one you're going to arrest
	///////////////////////////////////////////////////////////////////////////////
	function CheckObservePawnLooks(FPSPawn LookAtMe)
	{
		local P2Weapon p2weap;
		local byte StateChange;

		SetRotation(MyPawn.Rotation);

		if(LookAtMe == Attacker
			&& CanSeePawn(MyPawn, LookAtMe))
		{
			// if he's moved already, leave early
			CheckForAttackerMoved(StateChange);
			if(StateChange == 1)
				return;

			p2weap = P2Weapon(LookAtMe.Weapon);

			// Check right now for any kind of weapon, don't
			// put up with it at all. 
			if(p2weap != None)
			{
				if(WeaponTurnedToUs(LookAtMe, MyPawn))
				{
					if(p2weap.ViolenceRank > 0
						|| LookAtMe.HasPantsDown())
					{
						if(!CheckToGoKilling())
						// If you didn't decide to attack, at least acknowledge that
						// he's disobeying you and has his gun out again.
						{
							GotoStateSave('TellHimToDropWeapon');
						}
					}
				}
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Decide what to do about this danger
	// Something bad happened while we were already pissed off
	// We only really care if it's the same attacker we were already
	// pissed about.
	///////////////////////////////////////////////////////////////////////////////
	function GetReadyToReactToDanger(class<TimedMarker> dangerhere, 
									FPSPawn CreatorPawn, 
									Actor OriginActor,
									vector blipLoc,
									optional out byte StateChange)
	{
		local float dist;
		local vector dir;
		local FPSPawn Attacked;

		// if it's a crazy animal, run or fight it
		if((Attacker == None
				|| Attacker == CreatorPawn)
			&& AnimalPawn(CreatorPawn) != None)
		{
			// Only pay attention to attacking animals in this state
			if(dangerhere.default.bCreatorIsAttacker)
			{
				if(MyPawn.bHasViolentWeapon)
				{
					// Drop things if you had them in your hands
					MyPawn.DropBoltons(MyPawn.Velocity);
					SetAttacker(CreatorPawn);
					MakeMoreAlert();
					SaveAttackerData(CreatorPawn);
					GotoStateSave('RecognizeAttacker');
					StateChange=1;
				}
				else
				{
					GenSafeRangeMin();
					InterestPawn = CreatorPawn;
					SetAttacker(InterestPawn);
					DangerPos = Attacker.Location;
					GotoStateSave('FleeFromAttacker');
					StateChange=1;
				}
				LastAttackedTime = Level.TimeSeconds;
			}
			return;
		}

		// If the dude, and you're friends with him, don't care what noises
		// he makes from guns or whatever
		if(CreatorPawn != None
			&& MyPawn.bPlayerIsFriend 
			&& CreatorPawn.bPlayer)
		{
			LastAttackedTime = Level.TimeSeconds;
			return;
		}

		if(CreatorPawn != None
			&& PersonController(CreatorPawn.Controller) != None)
			Attacked = PersonController(CreatorPawn.Controller).Attacker;

		if((CreatorPawn == Attacker
			|| Attacked == Attacker)
			&& LastAttackedTime != Level.TimeSeconds
			&& !ClassIsChildOf(dangerhere, class'AuthorityOrderMarker'))
		{
			// The same guy is now shooting or something, and that's annoying
			// so go into attack mode
			GoKilling();
			StateChange=1;
			LastAttackedTime = Level.TimeSeconds;
			return;
		}
		// TODO: send another cop after the other guy, if a new guy is shooting somewhere
		LastAttackedTime = Level.TimeSeconds;
		return;
	}

	///////////////////////////////////////////////////////////////////////////
	// When attacked while you're attacking
	///////////////////////////////////////////////////////////////////////////
	function damageAttitudeTo(pawn Other, float Damage)
	{
		if ( (Other == None) || (Other == Pawn) || (Damage <= 0))
			return;
		// We don't care about friendly fire
		if(FriendWithMe(FPSPawn(Other)))
			return;

		SetAttacker(FPSPawn(Other));
		GetAngryFromDamage(Damage);
		MakeMoreAlert();

		ReportAfterHit();

		// Check to see if you've been hurt past your pain threshold, and then run away
		if(MyPawn.Health < (1.0-MyPawn.PainThreshold)*MyPawn.HealthMax)
		{
			InterestPawn = Attacker;
			MakeMoreAlert();
			DangerPos = InterestPawn.Location;
			GotoStateSave('FleeFromAttacker');
		}
		else
		{
			// randomly pause from the attack
			Say(MyPawn.myDialog.lGotHit);
			SetNextState('ShootAtAttacker');
			MyPawn.StopAcc();
			GotoStateSave('AttackedWhileAttacking');
		}

		return;
	}

	///////////////////////////////////////////////////////////////////////////////
	// See if you're target is complying or not
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		// If we lose sight of him, tell him to freeze
		if(!LineOfSightTo(Attacker))
		{
			// if not, be confused, but keep searching for him
			PrintDialogue("What the...");
			Say(MyPawn.myDialog.lWhatThe);
			GotoStateSave(GetAggressiveState());
		}
		DodgeThinWall();
	}

	///////////////////////////////////////////////////////////////////////////////
	// If the SetActorTarget functions below can't find a proper path and end up
	// just setting the next move target as the destination itself, this function
	// will be called, so you can possibly exit your state and do something else instead.
	///////////////////////////////////////////////////////////////////////////////
	function CantFindPath(Actor Dest, optional vector DestPoint)
	{
		//log(self$" Attacker "$Attacker$" my next "$MyNextState$" distance "$MyPawn.bHasDistanceWeapon$" trace "$FastTrace(MyPawn.Location, Attacker.Location));
		if(Attacker != None
			&& (MyNextState == 'ShootAtAttacker'
				|| MyNextState == 'CuffHim'))
		{
			if(MyPawn.bHasDistanceWeapon
				&& P2Weapon(Attacker.Weapon).ViolenceRank > 0
				&& FastTrace(MyPawn.Location, Attacker.Location))
			{
				if(MyPawn.bTeamLeader)
					FollowLeadersState('ShootAtAttackerDistance',,,,,,,,true);
				GotoStateSave('ShootAtAttackerDistance');
			}
			else 
			{
				if(MyPawn.bTeamLeader)
					FollowLeadersState('WatchAttackerHighUp',,,,,,,,true);
				GotoStateSave('WatchAttackerHighUp');
			}
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Determine what to do after you got hung up on something
	///////////////////////////////////////////////////////////////////////////////
	function NextStateAfterHangUp()
	{
		local byte StateChange;

		//log(MyPawn$" NextStateAfterHangUp");
		// He's playing hard to get, so hang around.
		if(Attacker != None
			&& (MyNextState == 'ShootAtAttacker'
				|| MyNextState == 'CuffHim'))
		{
			if(MyPawn.bHasDistanceWeapon
				&& P2Weapon(Attacker.Weapon).ViolenceRank > 0
				&& FastTrace(MyPawn.Location, Attacker.Location))
			{
				if(MyPawn.bTeamLeader)
					FollowLeadersState('ShootAtAttackerDistance',,,,,,,,true);
				GotoStateSave('ShootAtAttackerDistance');
			}
			else 
			{
				if(MyPawn.bTeamLeader)
					FollowLeadersState('WatchAttackerHighUp',,,,,,,,true);
				GotoStateSave('WatchAttackerHighUp');
			}
		}
		if(StateChange == 0)
			Super.NextStateAfterHangUp();
	}

}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToArrestee
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToArrestee extends WalkToSuspect
{
	ignores HearWhoAttackedMe, HearAboutKiller, HearAboutDangerHere,
		ForceGetDown, CheckDesiredThing;

	///////////////////////////////////////////////////////////////////////////////
	// You currently only care about the looks of the one you're going to arrest
	// We're less lenient here than in the WalkToSuspect version
	///////////////////////////////////////////////////////////////////////////////
	function CheckObservePawnLooks(FPSPawn LookAtMe)
	{
		local P2Weapon p2weap;
		local byte StateChange;

		SetRotation(MyPawn.Rotation);

		if(LookAtMe == Attacker)
		{
			// If we can't see him anymore, then go running him down
			if(!LineOfSightTo(Attacker))
			{
				SaveAttackerData();
				SetEndPoint(LastAttackerPos, FREEZE_BASE_DIST);
				SetNextState(GetAggressiveState(), 'LookForAttacker');
				bPreserveMotionValues=true;
				GotoStateSave('RunToArrestee');
				return;
			}

			// If the dude has gotten any violent weapon out, then
			// just start attacking him
			p2weap = P2Weapon(LookAtMe.Weapon);

			if(p2weap != None)
			{
				if(WeaponTurnedToUs(LookAtMe, MyPawn))
				{
					if(p2weap.ViolenceRank > 0
						|| LookAtMe.HasPantsDown())
					{
						GoKilling();
						return;
					}
				}
			}

			// If he's moved already, leave early
			CheckForAttackerMoved(StateChange);
			if(StateChange==1)
				return;
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// See if you're target is complying or not
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		if(!LineOfSightTo(Attacker))
		{
			SaveAttackerData();
			SetEndPoint(LastAttackerPos, FREEZE_BASE_DIST);
			SetNextState(GetAggressiveState(), 'LookForAttacker');
			bPreserveMotionValues=true;
			ReportAsWanted(Attacker, true);
			GotoStateSave('RunToArrestee');
			return;
		}
		DodgeThinWall();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Give hints as you walk to him
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		PlayerHintDropWeapon(Attacker, true);
	}
	function EndState()
	{
		Super.EndState();
		PlayerHintDropWeapon(Attacker, false);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToCuffAttacker
// You've already read him his rights, you've got the cuffs out, and you're
// about to cuff him
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToCuffAttacker extends WalkToArrestee
{
	///////////////////////////////////////////////////////////////////////////////
	// Check to see if he's still still, if not, attack
	///////////////////////////////////////////////////////////////////////////////
	function CheckForAttackerMoved(out byte StateChange)
	{
		if(VSize(EndPoint - Attacker.Location) > CLOSE_ENOUGH_FOR_FINAL_CUFF + Attacker.CollisionRadius)
		{
			// He's moved too far, since you said to freeze
			GoKilling();
			StateChange=1;
			return;
		}
	}

}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToInterestPawn
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToInterestPawn extends WalkToTarget
{
	ignores PerformInterestAction, CanStartConversation, FreeToSeekPlayer;

	///////////////////////////////////////////////////////////////////////////////
	// Check to see if you can still see who you're tracking.
	// If you lose him, no big deal. Just walk to where you last saw him, and 
	// give up.
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		if(EndGoal != None)
		{
			//log("checking to see "$EndGoal);
			if(CanSeeAnyPart(MyPawn, P2Pawn(EndGoal)))
			{
				//log("i can still see him");
				// Record were we just last saw him
				LastAttackerPos=EndGoal.Location;
				LastAttackerDir = vector(EndGoal.Rotation);
			}
			else
			{
				//log(MyPawn$" I lost him soooooooo go for last position "$LastAttackerPos$" my pos "$MyPawn.Location);
				// Lose your attacker
				EndGoal = None;
				// Head to where you last saw him
				EndPoint = LastAttackerPos;
				SetNextState('LookAroundForTrouble');
				SetActorTargetPoint(EndPoint);
				bPreserveMotionValues=true;
				GotoState('WalkToInterestPawn');
				BeginState();
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WalkToFireSafeRange
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WalkToFireSafeRange
{
	ignores TryToGreetPasserby;

	function BeginState()
	{
		Super.BeginState();
		SetNextState('ManageBystandersAroundFire');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DeathCrawlFromAttacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DeathCrawlFromAttacker
{
	///////////////////////////////////////////////////////////////////////////////
	// Moan, make noises as you crawl
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		// Check how close the dude is and if he is aiming his gun at you. If so
		// curl up and cower
		CurrentDist = VSize(Attacker.Location - MyPawn.Location);

		if(CurrentDist < COWER_DISTANCE)
//			&& FRand() <= 0.5)
		{
			// Check if someone is in front of me
			if(P2Pawn(Attacker) != None
				&& WeaponTurnedToUs(Attacker, MyPawn)
				&& P2Weapon(Attacker.Weapon).ViolenceRank > 0)
			{
				bPreserveMotionValues=true;
				GotoStateSave('CowerInABall');
			}
			else // otherwise just moan
				//PrintDialogue("ehh.. oooh...");
				Say(MyPawn.myDialog.lSniveling);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// We're still mad at/have player as attacker--but we'll never be able to do
	// anything about it.
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		local P2GameInfoSingle p2g;
		Super.BeginState();

		// Remove me from the group looking for the dude
		p2g = P2GameInfoSingle(Level.Game);
		p2g.TheGameState.RemoveCopAfterPlayer(MyPawn);
		// If I'm a leader, make sure I'm not anymore
		MyPawn.bTeamLeader=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// DeathCrawlChem
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state DeathCrawlChem extends DeathCrawlFromAttacker
{
	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////
	function InterimSound()
	{
		Say(MyPawn.myDialog.lBodyFunctions);
	}
	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////
	function StartSound()
	{
		Say(MyPawn.myDialog.lBodyFunctions);
	}
	function EndState()
	{
		Super.BeginState();
		MyPawn.Notify_StopPuking();
	}
	function BeginState()
	{
		Super.BeginState();
		// puke type for when we're deathcrawling
		MyPawn.Notify_StartDeathCrawlPuking();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PatrolToTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PatrolToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// I've reached a patrol goal point
	// Check to play my radio
	///////////////////////////////////////////////////////////////////////////////
	function HitEndPatrol()
	{
		// If i'm actively seeking the player, then I'm checking to the
		// HQ with the radio. So make some radio noises
		RadioHQ();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Force your next state
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		SetNextState('PatrolJailToTarget');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunPatrolToTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunPatrolToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// I've reached a patrol goal point
	// Check to play my radio
	///////////////////////////////////////////////////////////////////////////////
	function HitEndPatrol()
	{
		// If i'm actively seeking the player, then I'm checking to the
		// HQ with the radio. So make some radio noises
		RadioHQ();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Force your next state
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		SetNextState('PatrolJailToTarget');
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// PatrolToTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PatrolJailToTarget extends PatrolToTarget
{
	ignores HandleStasisChange;
	///////////////////////////////////////////////////////////////////////////////
	// Handle bumps with other characters
	// Always investigate other characters if they're not an authority figure
	///////////////////////////////////////////////////////////////////////////////
	event Bump(actor Other)
	{
		// if it's not another cop/military, then check
		if(FPSPawn(Other) != None
			&& FPSPawn(Other).Health > 0
			&& !(FriendWithMe(FPSPawn(Other)))
			&& !DudeDressedAsCop(FPSPawn(Other)))
		{
			CheckDisturbanceInJail(Other);
		}
		else
			Super.Bump(Other);
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		Super.EndState();
		// clear your footsteps sounds
		AmbientSound = None;
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		// set your footsteps sounds
		AmbientSound = HallwayFootstepSounds;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// RunPatrolToTarget
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state RunPatrolJailToTarget extends RunPatrolToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	// Handle bumps with other characters
	// Always investigate other characters if they're not an authority figure
	///////////////////////////////////////////////////////////////////////////////
	event Bump(actor Other)
	{
		// if it's not another cop/military, then check
		if(FPSPawn(Other) != None
			&& FPSPawn(Other).Health > 0
			&& !(FriendWithMe(FPSPawn(Other)))
			&& !DudeDressedAsCop(FPSPawn(Other)))
		{
			CheckDisturbanceInJail(Other);
		}
		else
			Super.Bump(Other);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ManageBystandersAroundFire
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ManageBystandersAroundFire extends WatchFireFromSafeRange
{
	///////////////////////////////////////////////////////////////////////////////
	// check if there are people around, if so, tell them to be careful
	///////////////////////////////////////////////////////////////////////////////
	function ManagePeopleAround()
	{
		local P2Pawn CheckP, KeepP;
		local PersonController Personc;
		local vector checkpoint;
		local float usedist;

		// check all the pawns around me.
		ForEach VisibleCollidingActors(class'P2Pawn', CheckP, MANAGE_PEOPLE_RADIUS, MyPawn.Location)
		{
			//log("checked to manage "$CheckP);
			if(InterestPawn2 != CheckP			// not who we just talked to
				&& CheckP.Health > 0			// is alive
				&& CheckP.IsA('Bystander')		// is a bystander
				&& FastTrace(MyPawn.Location, CheckP.Location))	// make sure there's nothing obvious in the way
			{
				if(FRand() > 0.6)
				{
					KeepP = CheckP;
					break;
				}
				//else
				//	KeepP = CheckP; // keep who we didn't want, in case we need to fall back on this
			}
		}
		if(KeepP != None)
		{
			InterestPawn2 = KeepP;
			Focus = InterestPawn2;	// stare at who you are talking to
			// Watch them now, and tell them to be careful
			PrintDialogue("Stand back! .. Nothing to see here!");
			SayTime = Say(MyPawn.myDialog.lCop_NothingToSee);
			Personc = PersonController(KeepP.Controller);
			if(Personc != None)
				Personc.DecideToListen(MyPawn);

			// Now, as your talking to this person, walk slowly in general direction
			// but only for a little ways and then stop and watch the fire again
			checkpoint = KeepP.Location - MyPawn.Location;
			usedist = VSize(checkpoint);

			// make sure you're not already closer than this to the person
			if(usedist > TALK_WHILE_WALKING_DIST)
				usedist = TALK_WHILE_WALKING_DIST;

			//log("usedist "$usedist);
			checkpoint = MyPawn.Location + usedist*Normal(checkpoint);

			RaisePointFromGround(checkpoint, MyPawn);

			SetNextState('ManageBystandersAroundFire', 'WaitAfterTalking');
			SetEndPoint(checkpoint, DEFAULT_END_RADIUS + MyPawn.CollisionRadius);
			GotoStateSave('WalkToTarget');
			return;
		}
		else
			Focus = InterestActor; // stare at the fire again
	}

	///////////////////////////////////////////////////////////////////////////////
	// Make sure I'm attacking someone
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();

		DetermineLeader();

		InterestPawn2 = None;
	}

WaitAfterTalking:
	Sleep(1.0);

Begin:
	Focus = InterestActor; // stare at the fire again
	// watch it some
	Sleep(2.0 + MyPawn.Curiosity);

	// Check the fire you're supposed to be watching
	statecount = WatchInterestFire();

	if(statecount == 0)
	{
		// no more watching, fire is gone.. darn.
		GotoStateSave('Thinking');
	}
	else if(statecount == 1)
	{
		SetNextState('ManageBystandersAroundFire');
		// A different fire is too close, so make it your new focus, and run
		GotoStateSave('RunToFireSafeRange');
	}
	else if(statecount == 2)
	{
		SetNextState('ManageBystandersAroundFire');
		// A different fire is too close, so make it your new focus, and run
		GotoStateSave('WalkToFireSafeRange');
	}
	else
	{
		ManagePeopleAround();
	}

	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// LookAroundForTrouble
// Just look around and see if there's anything odd (CheckObservePawnLooks will 
// do the work)--You *don't* have a specific attacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state LookAroundForTrouble
{
	ignores CheckDeadBody, CheckDeadHead, WatchFunnyThing;

	///////////////////////////////////////////////////////////////////////////////
	// stop moving, to look around
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		// Get out gun
		MyPawn.SetMood(MOOD_Combat, 1.0);
		Super.SwitchToBestWeapon();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// LookAroundDeadBody
// Just look around and see if there's anything odd (CheckObservePawnLooks will 
// do the work)--You *don't* have a specific attacker
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state LookAroundDeadBody
{
	ignores CheckDeadBody, CheckDeadHead, WatchFunnyThing;

	///////////////////////////////////////////////////////////////////////////////
	// Pick the next point to run to
	///////////////////////////////////////////////////////////////////////////////
	function PickNextDestination()
	{
		local vector checkpos, endpos;
		local Actor HitActor;
		local vector HitLocation, HitNormal;
		local NavigationPoint pnode;
		local int i;

		// See if the area in the direction of our attacker is a valid area
		// to run to
		endpos = DangerPos;
		checkpos = DangerPos;

		if(MyPawn.Anchor != None)
		{
			i = Rand(MyPawn.Anchor.PathList.Length);
			if(MyPawn.Anchor.PathList.Length > 0)
				pnode = MyPawn.Anchor.PathList[i].end;
			if(pnode == None
				|| MyPawn.Anchor == pnode)
			{
				if(MyPawn.Anchor.nextOrdered == None)
					pnode = MyPawn.Anchor.prevOrdered; // choose the other
				else if(MyPawn.Anchor.prevOrdered == None)
					pnode = MyPawn.Anchor.nextOrdered; // choose the other
				else // choose either one
				{
					if(FRand() <= 0.5)
						pnode = MyPawn.Anchor.prevOrdered;
					else
						pnode = MyPawn.Anchor.nextOrdered;
				}
			}

			if(pnode != None
				&& MyPawn.Anchor != pnode)
			{
				Focus = pnode;
				SetEndGoal(pnode, DEFAULT_END_RADIUS);
				bStraightPath=UseStraightPath();
				InterestActor = InterestPawn;
				SetNextState('LookAroundDeadBody', 'TryAgain');
				GotoStateSave('WalkToTargetFindAttacker');
			}
		}
		else // no path nodes, so figure out our new look pos for ourself
		{

			checkpos.x = 2*FRand() - 1.0;
			checkpos.y = 2*FRand() - 1.0;
			checkpos.z = 0.0;
			checkpos = Normal(checkpos);

			checkpos = VISUALLY_FIND_RADIUS*checkpos + MyPawn.Location;
				//LastAttackerPos;

			// Check for things in the way of our new running direction
			HitActor = Trace(HitLocation, HitNormal, checkpos, MyPawn.Location, false);

			if(HitActor != None)
			{
				MovePointFromWall(HitLocation, HitNormal, MyPawn);
				checkpos = HitLocation;
			}

			Focus = None;
			SetEndPoint(checkpos, DEFAULT_END_RADIUS);
			bStraightPath=UseStraightPath();
			InterestActor = InterestPawn;
			SetNextState('LookAroundDeadBody', 'TryAgain');
			GotoStateSave('WalkToTargetFindAttacker');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// stop moving, to look around
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		// Stop and stand up
		MyPawn.StopAcc();
		MyPawn.ShouldCrouch(false);
		// Get out gun
		Super.SwitchToBestWeapon();
	}
TryAgain:
	// If you're body is gone, then quit looking
	if(InterestActor == None
		|| InterestActor.bDeleteMe)
		GotoStateSave('Thinking');
Begin:
	Sleep(Frand() + 0.1);
	// Now look around wildly
	LookInRandomDirection();
	Sleep(Frand() + 0.1);
	LookInRandomDirection();
	Sleep(Frand() + 0.1);
	// Now walk somewhere
	PickNextDestination();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// You see a dead body off in the distance, decide what to do
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state InvestigateDeadThing
{
	function damageAttitudeTo(pawn Other, float Damage)
	{
		MyNextState='';
		PolicedamageAttitudeTo(Other, Damage);
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function MoveCloser()
	{
		local float dist;
		local vector checkpos;

		if(InterestActor != None)
		{
			// Make sure the body isn't on fire first
			if(InterestPawn == None
				|| InterestPawn.MyBodyFire == None)
			{
				dist = VSize(MyPawn.Location - InterestPawn.Location);
				if(dist > UseSafeRangeMin)
				{
					SetEndPoint(InterestActor.Location, UseSafeRangeMin);
					SetNextState(GetStateName(), 'CloseEnough');
					GotoStateSave('RunToTarget');
				}
			}
			else
				GotoStateSave('InvestigateDeadThing');
		}
		else
			GotoStateSave('Thinking');
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		// Be in combat mode on the way to the gross thing
		MyPawn.SetMood(MOOD_Combat, 1.0);
	}

StareALongTime:
	Sleep(Rand(STARE_AT_DEAD_THING) + 1);
Begin:
	Focus = InterestActor;
	Sleep(2.0 - 2*MyPawn.Reactivity);
	MyPawn.StopAcc();
	Sleep(2.0 - 2*MyPawn.Reactivity);
ReadyToMove:
	MoveCloser();

CloseEnough:
	// If it's a non-player or a head, then start looking around for trouble
	if(InterestPawn == None
		|| !InterestPawn.bPlayer)
	{
		DangerPos = InterestActor.Location;
		GotoStateSave('LookAroundDeadBody');
	}

	// Get closer to the body and stare at it or kick it
	SetEndPoint(InterestActor.Location, UseSafeRangeMin/2);
	SetNextState('InvestigateDeadThing', 'StareAtBody');
	GotoStateSave('WalkToTarget');
StareAtBody:
	Focus = InterestActor;
	Sleep(MyPawn.Curiosity + 1);	// stare a while
	if(InterestPawn != None
		&& InterestPawn.bPlayer)
	{
		Sleep(Rand(STARE_AT_DEAD_DUDE));// possibly stare a long while
		// Say something mean about him
		SayTime = Say(MyPawn.myDialog.lDudeDead);
		PrintDialogue("The dude sure was bad...");
		Sleep(MyPawn.Curiosity + Rand(STARE_AT_DEAD_DUDE) + 1);	// stare a long while
	}

	// normal-ish people will just walk up and look
	// or stop if they're bored
	if(FRand() <= MyPawn.Conscience
		|| FRand() > MyPawn.Curiosity)
	{
		GotoStateSave('Thinking');
	}
	else // sick ones will kick the body
	{
TryToKick:
		// If you're close enough, just kick
		if(VSize(InterestActor.Location - MyPawn.Location) <= DEFAULT_END_RADIUS + MyPawn.CollisionRadius)
		{
			SetNextState('InvestigateDeadThing','StareAtBody');
			GotoStateSave('DoKicking');
		}
		else // not close.. then try to get closer
		{
			SetEndPoint(InterestActor.Location, DEFAULT_END_RADIUS);
			SetNextState('InvestigateDeadThing', 'TryToKick');
			GotoStateSave('WalkToTarget');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Confused before next state 
// You probably heard an authority figure shout something. Likely you'll go help
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ConfusedByDanger
{
Begin:
	// First face the interest vect. This should be set to whatever you want
	// them to stare at first.
	Focus = None;
	FocalPoint = DangerPos;
	Sleep(FRand());

	// Stare at our interest actor if we don't have a good pawn to look at
	if(InterestActor != None)
		Focus = InterestActor;
	else
		Focus = InterestPawn;

	if(SayWhat())
	{
		PrintDialogue("What the...?");
		SayTime = Say(MyPawn.myDialog.lWhatThe);
		Sleep(SayTime);
	}

	CheckInterest();

	GotoNextState();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// When you get destroyed, make sure to properly unhook your leader
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Destroying
{
	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		UnhookLeader();
		Super.BeginState();
	}
}

///////////////////////////////////////////////////////////////////////////////
// WalkToTarget
// Let bystanders know of my presence if CopKilla is on
///////////////////////////////////////////////////////////////////////////////
state WalkToTarget
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function InterimChecks()
	{
		Super.InterimChecks();

		if(FRand() < REPORT_LOOKS_FREQ && P2GameInfoSingle(Level.Game).TheGameState.bCopKilla)
			MyPawn.ReportPersonalLooksToOthers();
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function IntermediateGoalReached()
	{
		Super.IntermediateGoalReached();

		if (P2GameInfoSingle(Level.Game).TheGameState.bCopKilla)
			MyPawn.ReportPersonalLooksToOthers();
	}
}

///////////////////////////////////////////////////////////////////////////////
// PerformIdle
// Let bystanders know of my presence if CopKilla is on
///////////////////////////////////////////////////////////////////////////////
state PerformIdle
{
	function BeginState()
	{
		Super.BeginState();
		
		if (P2GameInfoSingle(Level.Game).TheGameState.bCopKilla)
			MyPawn.ReportPersonalLooksToOthers();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Take a piss!
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state TakeALeak
{
	///////////////////////////////////////////////////////////////////////////////
	// Find the next state to use
	///////////////////////////////////////////////////////////////////////////////
	function DecideNextState()
	{
		// Go to my next state
		if(MyNextState != 'None'
			&& MyNextState != '')
		{
			GotoNextState();
		}
		else // or keep dancing
		{
			if(Focus == None)
				GotoState(GetStateName(), 'Begin');
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		PrintThisState();

		MyPawn.StopAcc();
	}
	///////////////////////////////////////////////////////////////////////////////
	// Get out of your dance anim
	///////////////////////////////////////////////////////////////////////////////
	function EndState()
	{
		MyPawn.ChangePhysicsAnimUpdate(true);
		MyPawn.ChangeAnimation();
		MyPawn.SetMood(MOOD_Normal, 1.0);
		// Turn off the waterworks, if any (might have gotten interrupted while peeing)
		if (NPCUrethraWeapon(Pawn.Weapon) != None)
		{
			NPCUrethraWeapon(Pawn.Weapon).ForceEndFire();
			// And switch back to hands
			SwitchToHands();		
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// Aim at the thing we want to pee into
	///////////////////////////////////////////////////////////////////////////////
	function rotator GetViewRotation()
	{
		local rotator ORot;
		local vector VDiff;
		local float PDiff;

		if (Focus != None)
		{
			VDiff = Focus.Location - Pawn.Location;
			VDiff.Z = VDiff.Z - Pawn.EyeHeight;
			ORot = Rotator(VDiff);
			return ORot;
		}
		else
			return Global.GetViewRotation();
	}
	

Begin:
	// Change to pisser
	SwitchToThisWeapon(class'NPCUrethraWeapon'.Default.InventoryGroup, class'NPCUrethraWeapon'.Default.GroupOffset);
	
	// Wait for it to become ready
	while (!Pawn.Weapon.IsInState('Idle'))
		Sleep(0.1);

	// Now fire
	if (NPCUrethraWeapon(Pawn.Weapon) != None)
	{
		NPCUrethraWeapon(Pawn.Weapon).LeakTime = CurrentFloat;
		NPCUrethraWeapon(Pawn.Weapon).bGonorrheaPiss = false;
		NPCUrethraWeapon(Pawn.Weapon).Fire(1);
	}
	
	// Wait it out
	Sleep(CurrentFloat + FRand());
	
	// Zip back up
	SwitchToHands();

	// Wait for it to become ready
	while (!Pawn.Weapon.IsInState('Idle'))
		Sleep(0.1);
		
	// And go back to what we were doing
	DecideNextState();
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

	//RadioSounds[2]=Sound'WMaleDialog.wm_cop_radio3'
	//RadioSounds[3]=Sound'WMaleDialog.wm_cop_radio4'

defaultproperties
{
	RadioSounds(0)=Sound'WMaleDialog.wm_cop_radio1'
	RadioSounds(1)=Sound'WMaleDialog.wm_cop_radio2'
	HallwayFootstepSounds=Sound'MiscSounds.People.footstep'
	InterestInventoryClass=Class'Inventory.MoneyInv'
	BackToHandsFreq=0.600000
	SwitchWeaponFreq=1.000000
	ValentineVaseClass=class'Inventory.VaseInv'
	LookZombieClass=Class'AWZombie'
}
