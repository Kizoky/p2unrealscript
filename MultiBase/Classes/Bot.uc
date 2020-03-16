 //=============================================================================
// Bot.
//=============================================================================
class Bot extends ScriptedController;

// FIXME - no nearby inventory finding currently implemented

// AI Magic numbers - distance based, so scale to bot speed/weapon range
const MAXSTAKEOUTDIST = 2000;
const ENEMYLOCATIONFUZZ = 1200;
const TACTICALHEIGHTADVANTAGE = 400;
const MINSTRAFEDIST = 200;
const MINVIEWDIST = 200;

//AI flags
var		bool		bCanFire;			// used by TacticalMove and Charging states
var		bool		bCanDuck;
var		bool		bStrafeDir;
var		bool		bLeadTarget;		// lead target with projectile attack
var		bool		bChangeDir;			// tactical move boolean
var		bool		bFrustrated;
var		bool		bInitLifeMessage;
var		bool		bReachedGatherPoint;
var		bool		bJumpy;
var		bool		bSoaking;			// pause and focus on this bot if it encounters a problem
var		bool		bWasNearObjective;

var name	OldMessageType;
var int		OldMessageID;

// Advanced AI attributes.
var	vector			HidingSpot;
var	float			Aggressiveness;		// 0.0 to 1.0 (typically)
var float			LastAttractCheck;
var NavigationPoint BlockedPath;
var	float			AcquireTime;		// time at which current enemy was acquired
var float			Aggression;
var float			LoseEnemyCheckTime;

// modifiable AI attributes
var float			BaseAlertness;
var float			Accuracy;
var	float		    BaseAggressiveness; 
var	float			StrafingAbility;
var	float			CombatStyle;		// -1 to 1 = low means tends to stay off and snipe, high means tends to charge and melee
var() class<Weapon> FavoriteWeapon;

// Team AI attributes
var string			GoalString;			// for debugging - used to show what bot is thinking (with 'ShowDebug')
var string			SoakString;			// for debugging - shows problem when soaking
var SquadAI			Squad;
var Bot				NextSquadMember;	// linked list of members of this squad

// Scripted Sequences
var MpScriptedSequence GoalScript;	// ScriptedSequence bot is moving toward (assigned by TeamAI)
var MpScriptedSequence EnemyAcquisitionScript;

enum EScriptFollow
{
	FOLLOWSCRIPT_IgnoreAllStimuli,
	FOLLOWSCRIPT_IgnoreEnemies,
	FOLLOWSCRIPT_StayOnScript,
	FOLLOWSCRIPT_LeaveScriptForCombat
};
var EScriptFollow ScriptedCombat;

var int FormationPosition;

// ChooseAttackMode() state
var pawn		AttackEnemy;	
var squadAI		AttackSquad;
var	int			ChoosingAttackLevel;

// inventory searh
var float		LastSearchTime;
var float		LastSearchWeight;

function Destroyed()
{
	Squad.RemoveBot(self);
	FreeScript();
	Super.Destroyed();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetCombatTimer();
	Aggressiveness = BaseAggressiveness;
	if ( MPGameInfo(Level.Game).bSoaking )
		bSoaking = true;
}

function SetCombatTimer()
{
	SetTimer(2.0 - 0.2 * Skill, True);
}

function InitPlayerReplicationInfo()
{
	Super.InitPlayerReplicationInfo();
	if ( VoiceType != "" )
		PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject(VoiceType,class'Class'));
	// RWS CHANGE: This is now set by the PlayerReplicationInfo as needed
	//PlayerReplicationInfo.bBot = true;
}

function Pawn GetMyPlayer()
{
	if ( PlayerController(Squad.SquadLeader) != None )
		return Squad.SquadLeader.Pawn;
	return Super.GetMyPlayer();
}

// RWS Change 07/23/03 ViewPitch brought over from 2141 to do torso twisting
function UpdatePawnViewPitch()
{
    if (Pawn != None)
        Pawn.ViewPitch = (Rotation.Pitch / 256) % 256;
}

//===========================================================================
// Weapon management functions

/* WeaponReadyToFire()
Notification from weapon when it is ready to fire (either just finished firing,
or just finished coming up/reloading).
Returns true if weapon should fire.
If it returns false, can optionally set up a weapon change
*/
function bool WeaponFireAgain(float RefireRate, bool bFinishedFire)
{
	if ( !Pawn.Weapon.IsFiring() )
	{
		if ( Target == None )
			Target = Enemy;
		if ( !NeedToTurn(Target.Location) && Pawn.Weapon.CanAttack(Target) )
		{
			Focus = Target;
			bCanFire = true;
			return Pawn.Weapon.BotFire(bFinishedFire);
		}
		else
			bCanFire = false;
	}
	else if ( bCanFire && (FRand() < RefireRate) )
	{
		if ( (Target != None) && (Focus == Target) && !Target.bDeleteMe )
			return Pawn.Weapon.BotFire(bFinishedFire);
	}
	StopFiring();
	return false;
}

function bool FireWeaponAt(Actor A)
{
	if ( A == None )
		A = Enemy;
	if ( (A == None) || (Focus != A) )
		return false;
	Target = A;
	if ( (Pawn.Weapon != None) && Pawn.Weapon.HasAmmo() )
		return WeaponFireAgain(Pawn.Weapon.RefireRate(),false);
	return false;
}

function bool CanAttack(Actor Other)
{
	// return true if in range of current weapon
	return ( (Pawn != None) && Pawn.Weapon.CanAttack(Other) );
}

function StopFiring()
{
	bCanFire = false;
	bFire = 0;
	bAltFire = 0;
}

function ChangedWeapon()
{
	if ( Pawn.Weapon != None )
		Pawn.Weapon.SetHand(0);
}

function float WeaponPreference(Weapon W)
{
	if ( (GoalScript != None) && (GoalScript.WeaponPreference != None)
		&& ClassIsChildOf(W.class, GoalScript.WeaponPreference)
		&& Pawn.ReachedDestination(GoalScript.GetMoveTarget()) )
		return 0.3;
	if ( FavoriteWeapon == None )
		return 0;
	if ( ClassIsChildOf(W.class, FavoriteWeapon) )
		return 0.3;
}

//===========================================================================

function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Super.DisplayDebug(Canvas,YL, YPos);

	Canvas.SetDrawColor(255,255,255);	
	Squad.DisplayDebug(Canvas,YL,YPos);
	if ( GoalScript != None )
		Canvas.DrawText("     "$GoalString$" goalscript "$GetItemName(string(GoalScript))$" Sniping "$IsSniping()$" target "$Target, false);
	else
		Canvas.DrawText("     "$GoalString$" NO goalscript  target "$Target$" Formation "$FormationPosition, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

function name GetOrders()
{
	if ( HoldSpot(GoalScript) != None )
		return 'Hold';
	if ( PlayerController(Squad.SquadLeader) != None )
		return 'Follow';
	return Squad.GetOrders();
}

function actor GetOrderObject()
{
	if ( PlayerController(Squad.SquadLeader) != None )
		return Squad.SquadLeader;
	return Squad.SquadObjective;
}
	
/* YellAt()
Tell idiot to stop shooting me
*/
function YellAt(Pawn Moron)
{
	local float Threshold;

	if ( Enemy == None )
		Threshold = 0.3;
	else
		Threshold = 0.7;
	if ( FRand() < Threshold )
		return;

	SendMessage(None, 'FRIENDLYFIRE', 0, 5, 'TEAM');
}	

function byte GetMessageIndex(name PhraseName)
{
	if ( PlayerReplicationInfo.VoiceType == None )
		return 0;
	return PlayerReplicationInfo.Voicetype.Static.GetMessageIndex(PhraseName);
}

function SendMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait, name BroadcastType)
{
	// limit frequency of same message
	if ( (MessageType == OldMessageType) && (MessageID == OldMessageID)
		&& (Level.TimeSeconds - OldMessageTime < Wait) )
		return;

	if ( Level.Game.bGameEnded || Level.Game.bWaitingToStartMatch )
		return;

	OldMessageID = MessageID;
	OldMessageType = MessageType;

	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, BroadcastType);
}

/* SetOrders()
Called when player gives orders to bot
*/
function SetOrders(name NewOrders, Controller OrderGiver)
{
	if ( PlayerReplicationInfo.Team != OrderGiver.PlayerReplicationInfo.Team )
		return;

	Aggressiveness = BaseAggressiveness;
	if ( (NewOrders == 'Hold') || (NewOrders == 'Follow') )
		Aggressiveness += 1;

	SendMessage(OrderGiver.PlayerReplicationInfo, 'ACK', 0, 5, 'TEAM');
	MpTeamInfo(PlayerReplicationInfo.Team).AI.SetOrders(self,NewOrders,OrderGiver);
	WhatToDoNext();
}

function SetEnemy(Pawn P)
{
	Squad.SetEnemy(self,P);
}

function HearNoise(float Loudness, Actor NoiseMaker)
{
	// FIXME - try to acquire, but don't set enemy yet
	Squad.SetEnemy(self,NoiseMaker.instigator);
}

event SeePlayer(Pawn SeenPlayer)
{
	Squad.SetEnemy(self,SeenPlayer);
}

function SetAttractionState()
{
	if ( Enemy != None )
		GotoState('FallBack');
	else
		GotoState('Roaming');
}

function eAttitude AttitudeTo(Pawn Other)
{
	if ( Squad.FriendlyToward(Other) )
		return ATTITUDE_Friendly;
	if ( bFrustrated )
		return ATTITUDE_Hate;
	if ( RelativeStrength(Other) > Aggressiveness + 0.44 - skill * 0.06 )
		return ATTITUDE_Fear;
	return ATTITUDE_Hate;
}

function bool ClearShot(Vector TargetLoc, bool bImmediateFire)
{
	local bool bSeeTarget;

	if ( VSize(Enemy.Location - TargetLoc) > ENEMYLOCATIONFUZZ )
		return false;		
	
	bSeeTarget = FastTrace(TargetLoc, Pawn.Location + Pawn.EyeHeight * vect(0,0,1));
	// if pawn is crouched, check if standing would provide clear shot
	if ( !bImmediateFire && !bSeeTarget && Pawn.bIsCrouched )
		bSeeTarget = FastTrace(TargetLoc, Pawn.Location + (Pawn.Default.EyeHeight + Pawn.Default.CollisionHeight - Pawn.CollisionHeight) * vect(0,0,1));

	if ( !bSeeTarget || !FastTrace(TargetLoc , Enemy.Location + Enemy.BaseEyeHeight * vect(0,0,1)) );
		return false;
	if ( (Pawn.Weapon.SplashDamage() && (VSize(Pawn.Location - TargetLoc) < Pawn.Weapon.GetDamageRadius()))
		|| !FastTrace(TargetLoc + vect(0,0,0.9) * Enemy.CollisionHeight, Pawn.Location) )
	{
		StopFiring();
		return false;
	}
	return true;
}

function bool CanStakeOut()
{
	local float relstr;

	relstr = RelativeStrength(Enemy);

	if ( bFrustrated || !bEnemyInfoValid
		 || (VSize(Enemy.Location - Pawn.Location) > 0.5 * (MAXSTAKEOUTDIST + (FRand() * relstr - CombatStyle) * MAXSTAKEOUTDIST))
		 || (Level.TimeSeconds - FMax(LastSeenTime,AcquireTime) > 2.5 + FMax(-1, 3 * (FRand() + 2 * (relstr - CombatStyle))) ) 
		 || !ClearShot(LastSeenPos,false) )
		return false;
	return true;
}

/* CheckIfShouldCrouch()
returns true if target position still can be shot from crouched position,
or if couldn't hit it from standing position either
*/
function CheckIfShouldCrouch(vector StartPosition, vector TargetPosition, float probability)
{
	local actor HitActor;
	local vector HitNormal,HitLocation, X,Y,Z, projstart;

	if ( !Pawn.bCanCrouch || (!Pawn.bIsCrouched && (FRand() > probability)) )
	{
		Pawn.bWantsToCrouch = false;
		return;
	}

	GetAxes(Rotation,X,Y,Z);
	projStart = Pawn.Weapon.GetFireStart(X,Y,Z);
	projStart = projStart + StartPosition - Pawn.Location;
	projStart.Z = projStart.Z - 1.8 * (Pawn.CollisionHeight - Pawn.CrouchHeight); 
	HitActor = 	Trace(HitLocation, HitNormal, TargetPosition , projStart, false);
	if ( HitActor == None )
	{
		Pawn.bWantsToCrouch = true;
		return;
	}

	projStart.Z = projStart.Z + 1.8 * (Pawn.Default.CollisionHeight - Pawn.CrouchHeight);
	HitActor = 	Trace(HitLocation, HitNormal, TargetPosition , projStart, false);
	if ( HitActor == None )
	{
		Pawn.bWantsToCrouch = false;
		return;
	}
	Pawn.bWantsToCrouch = true;
}

function bool IsSniping()
{
	return ( (GoalScript != None) && GoalScript.bSniping && Pawn.Weapon.bSniping 
			&& Pawn.ReachedDestination(GoalScript.GetMovetarget()) );
}

function FreeScript()
{
	if ( GoalScript != None )
	{
		GoalScript.FreeScript();
		GoalScript = None;
	}
}

function bool SetRouteToGoal(Actor A)
{
	if ( ActorReachable(A) )
		MoveTarget = A;
	else
		MoveTarget = FindPathToward(A);

	if ( MoveTarget == None )
	{
		if ( bSoaking && (Physics != PHYS_Falling) )
			SoakStop("COULDN'T FIND ROUTE TO "$A);
		return false;
	}
	SetAttractionState();
	return true;
}

function bool ShouldStrafeTo(Actor WayPoint)
{
	local NavigationPoint N;

	if ( Skill < 4 )
		return false;

	N = NavigationPoint(WayPoint);
	if ( (N == None) || N.bNeverUseStrafing )
		return false;

	if ( N.bAlwaysUseStrafing && (FRand() < 0.6) )
		return true;
	return ( Skill > 10 * FRand() - 1);
}

function bool AssignSquadResponsibility()
{
	if ( LastAttractCheck == Level.TimeSeconds )
		return false;
	LastAttractCheck = Level.TimeSeconds;

	return Squad.AssignSquadResponsibility(self);
}

/* RelativeStrength()
returns a value indicating the relative strength of other
> 0 means other is stronger than controlled pawn

Since the result will be compared to the creature's aggressiveness, it should be
on the same order of magnitude (-1 to 1)
*/

function float RelativeStrength(Pawn Other)
{
	local float compare;
	local int adjustedOther;

	if ( Pawn == None )
	{
		warn("Relative strength with no pawn in state "$GetStateName());
		return 0;
	}
	adjustedOther = 0.5 * (Other.health + Other.Default.Health);	
	compare = 0.01 * float(adjustedOther - Pawn.health);
	if ( Pawn.Weapon != None )
	{
		compare -= Pawn.DamageScaling * (Pawn.Weapon.RateSelf() - 0.3);
		if ( Pawn.Weapon.AIRating < 0.5 )
		{
			compare += 0.3;
			if ( (Other.Weapon != None) && (Other.Weapon.AIRating > 0.5) )
				compare += 0.35;
		}
	}
	if ( Other.Weapon != None )
		compare += Other.DamageScaling * (Other.Weapon.GetRating() - 0.3);

	if ( Other.Location.Z > Pawn.Location.Z + TACTICALHEIGHTADVANTAGE )
		compare -= 0.2;
	else if ( Pawn.Location.Z > Other.Location.Z + TACTICALHEIGHTADVANTAGE )
		compare += 0.15;
	return compare;
}

function Trigger( actor Other, pawn EventInstigator )
{
	if ( Super.TriggerScript(Other,EventInstigator) )
		return;
	if ( (Other == Pawn) || (Pawn.Health <= 0) )
		return;
	Squad.SetEnemy(self,EventInstigator);
}

function SetEnemyInfo(bool bNewEnemyVisible)
{
	AcquireTime = Level.TimeSeconds;
	if ( bNewEnemyVisible )
	{
		LastSeenTime = Level.TimeSeconds;
		LastSeenPos = Enemy.Location;
		LastSeeingPos = Pawn.Location;
		bEnemyInfoValid = true;
	}
	else
	{
		LastSeenTime = -1000;
		bEnemyInfoValid = false;
	}
}

// EnemyChanged() called by squad when current enemy changes
function EnemyChanged(bool bNewEnemyVisible)
{
	SetEnemyInfo(bNewEnemyVisible);
	ChooseAttackMode(false);
}

function BotVoiceMessage(name messagetype, byte MessageID, Controller Sender)
{
	Squad.BotVoiceMessage(self,messagetype, MessageID, Sender);
}

function bool StrafeFromDamage(float Damage, class<DamageType> DamageType, bool bFindDest);

//**********************************************************************

function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
{
	local vector jumpDir;

	if ( newVolume.bWaterVolume )
	{
		if (!Pawn.bCanSwim)
			MoveTimer = -1.0;
		else if (Pawn.Physics != PHYS_Swimming)
			Pawn.setPhysics(PHYS_Swimming);
	}
	else if (Pawn.Physics == PHYS_Swimming)
	{
		if ( Pawn.bCanFly )
			 Pawn.SetPhysics(PHYS_Flying); 
		else
		{ 
			Pawn.SetPhysics(PHYS_Falling);
			if ( Pawn.bCanWalk && (Abs(Pawn.Acceleration.X) + Abs(Pawn.Acceleration.Y) > 0)
				&& (Destination.Z >= Pawn.Location.Z) 
				&& Pawn.CheckWaterJump(jumpDir) )
				Pawn.JumpOutOfWater(jumpDir);
		}
	}
	return false;
}

function Possess(Pawn aPawn)
{
	if ( MpPawn(aPawn) != None )
	{
		if ( MpPawn(aPawn).Default.VoiceType != "" )
			VoiceType = MpPawn(aPawn).Default.VoiceType;
		if ( VoiceType != "" )
			PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject(VoiceType,class'Class'));
	}
	SetPeripheralVision();
	if ( Skill == 7 )
		RotationRate.Yaw = 100000;
	else
		RotationRate.Yaw = 30000 + 4000 * skill;
	bCanDuck = ( Skill >= 5 );
	Pawn.SetMovementPhysics(); 
	if (Pawn.Physics == PHYS_Walking)
		Pawn.SetPhysics(PHYS_Falling);
	enable('NotifyBump');
	Super.Possess(aPawn);
}

function SetPeripheralVision()
{
	if ( Skill < 4 )
		Pawn.PeripheralVision = 0.7;
	else if ( Skill == 7 )
		Pawn.PeripheralVision = -0.2;
	else
		Pawn.PeripheralVision = 2.0 - 0.33 * skill;

	Pawn.PeripheralVision = FMin(Pawn.PeripheralVision - BaseAlertness, 0.9);
	Pawn.SightRadius = Pawn.Default.SightRadius;
}

function FearThisSpot(Actor aSpot)
{
	Pawn.Acceleration = vect(0,0,0);
	MoveTimer = -1.0;
}

/*
SetAlertness()
Change creature's alertness, and appropriately modify attributes used by engine for determining
seeing and hearing.
SeePlayer() is affected by PeripheralVision, and also by SightRadius and the target's visibility
HearNoise() is affected by HearingThreshold
*/
function SetAlertness(float NewAlertness)
{
	if ( Pawn.Alertness != NewAlertness )
	{
		Pawn.PeripheralVision += 0.707 * (Pawn.Alertness - NewAlertness); //Used by engine for SeePlayer()
		Pawn.Alertness = NewAlertness;
	}
}

//=============================================================================
function WhatToDoNext()
{
	GoalString = "WhatToDoNext at "$Level.TimeSeconds;
	if ( Level.Game.TooManyBots(self) )
	{
		if ( Pawn != None )
		{
			Pawn.Health = 0;
			Pawn.Died( self, class'Suicided', Pawn.Location );
		}
		Destroy();
		return;
	}
	BlockedPath = None;
	bFrustrated = false;
	StopFiring();

	if ( ScriptingOverridesAI() && ShouldPerformScript() )
		return;
	if ( Squad.WhatToDoNext(self) || AssignSquadResponsibility() )
		return;
	if ( ShouldPerformScript() )
		return;
	if ( Enemy != None )
		ChooseAttackMode(true);
	else
		WanderOrCamp(true);
}

function bool FindInventoryGoal(float BestWeight)
{
	local actor BestPath;

	if ( (LastSearchTime == Level.TimeSeconds) && (LastSearchWeight >= BestWeight) )
		return false;

	LastSearchTime = Level.TimeSeconds;
	LastSearchWeight = BestWeight;

	 // look for inventory 
	BestPath = FindBestInventoryPath(BestWeight, false);
	if ( BestPath != None )
	{
		MoveTarget = BestPath;
		return true;
	}
	return false;
}

function bool PickRetreatDestination()
{
	local actor BestPath;

	if ( FindInventoryGoal(0) )
		return true;

	if ( (RouteGoal == None) || (Pawn.Anchor == RouteGoal)
		|| Pawn.ReachedDestination(RouteGoal) )
	{
		RouteGoal = FindRandomDest();
		BestPath = RouteCache[0];
		if ( RouteGoal == None )
			return false;
	}
	
	if ( BestPath == None )
		BestPath = FindPathToward(RouteGoal);
	if ( BestPath != None )
	{
		MoveTarget = BestPath;
		return true;
	}
	RouteGoal = None;
	return false;
}

function SoakStop(string problem)
{
	local MpPlayer PC;

	SoakString = problem;
	ForEach DynamicActors(class'MpPlayer',PC)
	{
		PC.SoakPause(Pawn);
		break;
	}
}

function bool FindRoamDest()
{
	local NavigationPoint N;
	local actor BestPath, HitActor;
	local vector HitNormal, HitLocation;
	local int Num;

	GoalString = "Find roam dest "$Level.TimeSeconds;
	// find random NavigationPoint to roam to
	if ( (RouteGoal == None) || (Pawn.Anchor == RouteGoal)
		|| Pawn.ReachedDestination(RouteGoal) )
	{
		// first look for a scripted sequence
		Squad.SetFreelanceScriptFor(self);
		if ( GoalScript != None )
		{
			RouteGoal = GoalScript.GetMoveTarget();
			BestPath = None;
		}				
		else
		{
			RouteGoal = FindRandomDest();
			BestPath = RouteCache[0];
		}
		if ( RouteGoal == None )
		{
			if ( bSoaking && (Physics != PHYS_Falling) )
				SoakStop("COULDN'T FIND ROAM DESTINATION");
			return false;
		}
	}
	if ( BestPath == None )
		BestPath = FindPathToward(RouteGoal,true);
	if ( BestPath != None )
	{
		MoveTarget = BestPath;
		SetAttractionState();
		return true;
	}
	if ( bSoaking && (Physics != PHYS_Falling) )
		SoakStop("COULDN'T FIND ROAM PATH TO "$RouteGoal);
	RouteGoal = None;
	FreeScript();
	GoalString = "Off navigation network - wandering";
	if ( FRand() < 0.5 )
		return false;

	Num = Rand(6);
	ForEach RadiusActors(class'NavigationPoint',N,1000)
	{
		HitActor = Trace(HitLocation, HitNormal,N.Location, Pawn.Location,false);
		if ( HitActor == None )
		{
			MoveTarget = N;
			Num--;
			if ( Num < 0 )
				break;
		}
	}
	SetAttractionState();
	return true;
}

function bool TestDirection(vector dir, out vector pick)
{	
	local vector HitLocation, HitNormal, dist;
	local actor HitActor;

	pick = dir * (MINSTRAFEDIST + 2 * MINSTRAFEDIST * FRand());

	HitActor = Trace(HitLocation, HitNormal, Pawn.Location + pick + 1.5 * Pawn.CollisionRadius * dir , Pawn.Location, false);
	if (HitActor != None)
	{
		pick = HitLocation + (HitNormal - dir) * 2 * Pawn.CollisionRadius;
		if ( !FastTrace(pick, Pawn.Location) )
			return false;
	}
	else
		pick = Pawn.Location + pick;
	 
	dist = pick - Pawn.Location;
	if (Pawn.Physics == PHYS_Walking)
		dist.Z = 0;
	
	return (VSize(dist) > MINSTRAFEDIST); 
}

function Restart()
{
	Super.Restart();
	ReSetSkill();
	GotoState('Roaming','DoneRoaming');
}

function bool CheckPathToGoalAround(Pawn P)
{
	return false;
}

function CancelCampFor(Controller C);

function ClearPathFor(Controller C)
{
	if ( AdjustAround(C.Pawn) )
		return;
	else if ( Enemy != None )
	{
		if ( LineOfSightTo(Enemy) )
			GotoState('TacticalMove');
	}
	else
		DirectedWander(Normal(Pawn.Location - C.Pawn.Location));
}

function bool AdjustAround(Pawn Other)
{
	local float speed;
	local vector VelDir, OtherDir, SideDir;

	speed = VSize(Pawn.Acceleration);
	if ( speed < Pawn.WalkingPct * Pawn.GroundSpeed )
		return false;

	if(speed != 0)
		VelDir = Pawn.Acceleration/speed;
	VelDir.Z = 0;
	OtherDir = Other.Location - Pawn.Location;
	OtherDir.Z = 0;
	OtherDir = Normal(OtherDir);
	if ( (VelDir Dot OtherDir) > 0.8 )
	{
		bAdjusting = true;
		SideDir.X = VelDir.Y;
		SideDir.Y = -1 * VelDir.X;
		if ( (SideDir Dot OtherDir) > 0 )
			SideDir *= -1;
		AdjustLoc = Pawn.Location + 1.5 * Other.CollisionRadius * (0.5 * VelDir + SideDir);
	}
}

function DirectedWander(vector WanderDir)
{
	Pawn.bWantsToCrouch = Pawn.bIsCrouched;
	if ( TestDirection(WanderDir,Destination) )
		GotoState('RestFormation', 'Moving');
	else
		GotoState('RestFormation', 'Begin');
}

event bool NotifyBump(actor Other)
{
	local Pawn P;

	Disable('NotifyBump');
	P = Pawn(Other);
	if ( (P == None) || (P.Controller == None) )
		return false;
	Squad.SetEnemy(self,P);
	if ( Enemy == P )
		return false;
	if ( CheckPathToGoalAround(P) )
		return false;
	
	if ( !AdjustAround(P) )
		CancelCampFor(P.Controller);
	return false;
}
	
function SetFall()
{
	if (Pawn.bCanFly)
	{
		Pawn.SetPhysics(PHYS_Flying);
		return;
	}			
	if ( Pawn.bNoJumpAdjust )
	{
		Pawn.bNoJumpAdjust = false;
		return;
	}
	else
	{
		Pawn.Velocity = EAdjustJump(Pawn.Velocity.Z,Pawn.GroundSpeed);
		Pawn.Acceleration = vect(0,0,0);
	}
}

function bool NotifyLanded(vector HitNormal)
{
	local vector Vel2D;

	if ( MoveTarget != None )
	{
		Vel2D = Pawn.Velocity;
		Vel2D.Z = 0;
		if ( (Vel2D Dot (MoveTarget.Location - Pawn.Location)) < 0 )
		{
			Pawn.Acceleration = vect(0,0,0);
			MoveTimer = -1;
		}
	}
	return false;
}

/* FindBestPathToward() 
Assumes the desired destination is not directly reachable. 
It tries to set Destination to the location of the best waypoint, and returns true if successful
*/
function bool FindBestPathToward(actor desired, bool bClearPaths)
{
	local Actor path;
	local bool success;
	
	path = FindPathToward(desired,bClearPaths); 
		
	success = (path != None);	
	if (success)
	{
		MoveTarget = path; 
		Destination = path.Location;
	}
	else if ( bSoaking && (Physics != PHYS_Falling) )
		SoakStop("COULDN'T FIND BEST PATH TO "$desired);

	return success;
}	

function bool NeedToTurn(vector targ)
{
	local vector LookDir,AimDir;
	LookDir = Vector(Pawn.Rotation);
	LookDir.Z = 0;
	LookDir = Normal(LookDir);
	AimDir = targ - Pawn.Location;
	AimDir.Z = 0;
	AimDir = Normal(AimDir);

	return ((LookDir Dot AimDir) < 0.93);
}

/* NearWall() 
returns true if there is a nearby barrier at eyeheight, and
changes FocalPoint to a suggested place to look
*/
function bool NearWall(float walldist)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, ViewSpot, ViewDist, LookDir;

	LookDir = vector(Rotation);
	ViewSpot = Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1);
	ViewDist = LookDir * walldist; 
	HitActor = Trace(HitLocation, HitNormal, ViewSpot + ViewDist, ViewSpot, false);
	if ( HitActor == None )
		return false;

	ViewDist = Normal(HitNormal Cross vect(0,0,1)) * walldist;
	if (FRand() < 0.5)
		ViewDist *= -1;

	Focus = None;
	if ( FastTrace(ViewSpot + ViewDist, ViewSpot) )
	{
		FocalPoint = Pawn.Location + ViewDist;
		return true;
	}

	if ( FastTrace(ViewSpot - ViewDist, ViewSpot) )
	{
		FocalPoint = Pawn.Location - ViewDist;
		return true;
	}

	FocalPoint = Pawn.Location - LookDir * 300;
	return true;
}

// check for line of sight to target deltatime from now.
function bool CheckFutureSight(float deltatime)
{
	local vector FutureLoc;

	if ( Target == None )
		Target = Enemy;
	if ( Target == None )
		return false;

	if ( Pawn.Acceleration == vect(0,0,0) )
		FutureLoc = Pawn.Location;
	else
		FutureLoc = Pawn.Location + Pawn.GroundSpeed * Normal(Pawn.Acceleration) * deltaTime;

	if ( Pawn.Base != None ) 
		FutureLoc += Pawn.Base.Velocity * deltaTime;
	//make sure won't run into something
	if ( !FastTrace(FutureLoc, Pawn.Location) && (Pawn.Physics != PHYS_Falling) )
		return false;

	//check if can still see target
	if ( FastTrace(Target.Location + Target.Velocity * deltatime, FutureLoc) )
		return true;

	return false;
}

function float AdjustAimError(float aimerror, float TargetDist, bool bDefendMelee, bool bInstantProj, bool bLeadTargetNow )
{
	// figure out the relative motion of the target across the bots view, and adjust aim error
	// based on magnitude of relative motion
	aimerror = aimerror * (11 - 10 *  
		((Target.Location - Pawn.Location)/TargetDist 
			Dot Normal((Target.Location + 1.25 * Target.Velocity) - (Pawn.Location + Pawn.Velocity)))); 

	// if enemy is charging straight at bot with a melee weapon, improve aim
	if ( bDefendMelee )
		aimerror *= 0.5;

	// if instant hit weapon, then adjust aim error based on skill
	// the initial aim error passed in is much higher for instant hit weapons than for other weapons
	// FIXME - that's a bad idea.
	if ( bInstantProj )
		aimerror *= 0.5 + 0.09 * skill;

	// adjust aim error based on skill
	if ( !bDefendMelee )
		aimerror *= (3.3 - 0.4 * (skill + FRand()));

	// Bots don't aim as well if recently hit, or if they or their target is flying through the air
	if ( (Skill < 6) 
		&& ((Level.TimeSeconds - Pawn.LastPainTime < 0.2) || (Pawn.Physics == PHYS_Falling) || (Target.Physics == PHYS_Falling)) )
		aimerror *= 1.2;

	// Bots don't aim as well at recently acquired targets (because they haven't had a chance to lock in to the target)
	if ( AcquireTime > Level.TimeSeconds - 6 + skill )
	{
		AcquireTime = Level.TimeSeconds - 6;
		aimerror *= 2;
	}
	
	// adjust aim error based on bot accuracy rating 
	if ( !bLeadTargetNow || (accuracy < 0) )
		aimerror -= aimerror * accuracy;

	return (Rand(2 * aimerror) - aimerror);
}

/*
AdjustAim()
Returns a rotation which is the direction the bot should aim - after introducing the appropriate aiming error
*/
function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
	local rotator FireRotation, TargetLook;
	local float FireDist, TargetDist, ProjSpeed;
	local actor HitActor;
	local vector FireSpot, FireDir, TargetVel, HitLocation, HitNormal;
	local int realYaw;
	local bool bDefendMelee, bClean, bLeadTargetNow;

	if ( FiredAmmunition.ProjectileClass != None )
		projspeed = FiredAmmunition.ProjectileClass.default.speed;

	// make sure bot has a valid target
	if ( Target == None )
	{
		Target = Enemy;
		if ( Target == None )
		{
			StopFiring();
			return Rotation;
		}
	}
	FireSpot = Target.Location;
	TargetDist = VSize(Target.Location - Pawn.Location);

	// perfect aim at stationary objects
	if ( Pawn(Target) == None )
	{
		if ( !FiredAmmunition.bTossed )
			return rotator(Target.Location - projstart);
		else
		{
			FireSpot.Z += AdjustToss(FiredAmmunition,ProjStart,Target.Location);
			SetRotation(Rotator(FireSpot - ProjStart));
			// RWS Change 07/23/03 ViewPitch brought over from 2141 to do torso twisting
            UpdatePawnViewPitch();
			return Rotation;
		}					
	}

	bLeadTargetNow = FiredAmmunition.bLeadTarget && bLeadTarget;
	bDefendMelee = ( (Target == Enemy) && DefendMelee(TargetDist) );
	aimerror = AdjustAimError(aimerror,TargetDist,bDefendMelee,FiredAmmunition.bInstantHit, bLeadTargetNow);

	// lead target with non instant hit projectiles
	if ( bLeadTargetNow )
	{
		TargetVel = Target.Velocity;
		// hack guess at projecting falling velocity of target
		if ( Target.Physics == PHYS_Falling )
		{
			if ( Target.PhysicsVolume.Gravity.Z <= Target.PhysicsVolume.Default.Gravity.Z )
				TargetVel.Z = FMin(-160, TargetVel.Z);
			else
				TargetVel.Z = FMin(0, TargetVel.Z);
		}
		if(projSpeed > 0)
			// more or less lead target (with some random variation)
			FireSpot += FMin(1, 0.7 + 0.6 * FRand()) * TargetVel * TargetDist/projSpeed;
		FireSpot.Z = FMin(Target.Location.Z, FireSpot.Z);

		if ( (Target.Physics != PHYS_Falling) && (FRand() < 0.55) && (VSize(FireSpot - ProjStart) > 1000) )
		{
			// don't always lead far away targets, especially if they are moving sideways with respect to the bot
			TargetLook = Target.Rotation;
			if ( Target.Physics == PHYS_Walking )
				TargetLook.Pitch = 0;
			bClean = ( ((Vector(TargetLook) Dot Normal(Target.Velocity)) >= 0.71) && FastTrace(FireSpot, ProjStart) );
		}
		else // make sure that bot isn't leading into a wall
			bClean = FastTrace(FireSpot, ProjStart);
		if ( !bClean)
		{
			// reduce amount of leading
			if ( FRand() < 0.3 )
				FireSpot = Target.Location;
			else
				FireSpot = 0.5 * (FireSpot + Target.Location);
		}
	}

	bClean = false; //so will fail first check unless shooting at feet  
	if ( FiredAmmunition.bTrySplash && (Pawn(Target) != None) && ((Skill >=4) || bDefendMelee) 
		&& (((Target.Physics == PHYS_Falling) && (Pawn.Location.Z + 80 >= Target.Location.Z))
			|| ((Pawn.Location.Z + 19 >= Target.Location.Z) && (bDefendMelee || (skill > 6.5 * FRand() - 0.5)))) )
	{
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot - vect(0,0,1) * (Target.CollisionHeight + 6), FireSpot, false);
 		bClean = (HitActor == None);
		if ( !bClean )
		{
			FireSpot = HitLocation + vect(0,0,3);
			bClean = FastTrace(FireSpot, ProjStart);
		}
		else 
			bClean = ( (Target.Physics == PHYS_Falling) && FastTrace(FireSpot, ProjStart) );
	}
	if ( !bClean )
	{
		//try middle
		FireSpot.Z = Target.Location.Z;
 		bClean = FastTrace(FireSpot, ProjStart);
	}
	if ( FiredAmmunition.bTossed && !bClean && bEnemyInfoValid )
	{
		FireSpot = LastSeenPos;
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if ( HitActor != None )
		{
			StopFiring();
			FireSpot += 2 * Target.CollisionHeight * HitNormal;
		}
		bClean = true;
	}

	if( !bClean ) 
	{
		// try head
 		FireSpot.Z = Target.Location.Z + 0.9 * Target.CollisionHeight;
 		bClean = FastTrace(FireSpot, ProjStart);
	}
	if ( !bClean && (Target == Enemy) && bEnemyInfoValid )
	{
		FireSpot = LastSeenPos;
		if ( Pawn.Location.Z >= LastSeenPos.Z )
			FireSpot.Z -= 0.7 * Enemy.CollisionHeight;
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if ( HitActor != None )
		{
			FireSpot = LastSeenPos + 2 * Enemy.CollisionHeight * HitNormal;
			if ( Pawn.Weapon.SplashDamage() && (Skill >= 4) )
			{
			 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
				if ( HitActor != None )
					FireSpot += 2 * Enemy.CollisionHeight * HitNormal;
			}
			if ( Pawn.Weapon.RefireRate() < 0.99 )
				bCanFire = false;
		}
	}

	// adjust for toss distance
	if ( FiredAmmunition.bTossed && (FRand() < 0.75) )
		FireSpot.Z += AdjustToss(FiredAmmunition,ProjStart,Target.Location);
	
	FireRotation = Rotator(FireSpot - ProjStart);
	realYaw = FireRotation.Yaw;
	FireRotation.Yaw = SetFireYaw(FireRotation.Yaw + aimerror);
	FireDir = vector(FireRotation);
	// avoid shooting into wall
	FireDist = FMin(VSize(FireSpot-ProjStart), 400);
	FireSpot = ProjStart + FireDist * FireDir;
	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false); 
	if ( HitActor != None )
	{
		if ( HitNormal.Z < 0.7 )
		{
			FireRotation.Yaw = SetFireYaw(realYaw - aimerror);
			FireDir = vector(FireRotation);
			FireSpot = ProjStart + FireDist * FireDir;
			HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false); 
		}
		if ( HitActor != None )
		{
			FireSpot += HitNormal * 2 * Target.CollisionHeight;
			if ( Skill >= 4 )
			{
				HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false); 
				if ( HitActor != None )
					FireSpot += Target.CollisionHeight * HitNormal; 
			}
			FireDir = Normal(FireSpot - ProjStart);
			FireRotation = rotator(FireDir);		
		}
	}

	FiredAmmunition.WarnTarget(Target,Pawn,FireDir);
	SetRotation(FireRotation);			
	// RWS Change 07/23/03 ViewPitch brought over from 2141 to do torso twisting
    UpdatePawnViewPitch();
	return FireRotation;
}

function ReceiveWarning(Pawn shooter, float projSpeed, vector FireDir)
{
	local float enemyDist;
	local vector X,Y,Z, enemyDir;

	// AI controlled creatures may duck if not falling
	if ( (Pawn.health <= 0) || !bCanDuck || (Enemy == None) 
		|| (Pawn.Physics == PHYS_Falling) || (Pawn.Physics == PHYS_Swimming) )
		return;

	if ( FRand() > 0.14 * skill )
		return;

	// and projectile time is long enough
	enemyDist = VSize(shooter.Location - Pawn.Location);
	if (projSpeed == 0
		|| enemyDist/projSpeed < 0.11 + 0.15 * FRand()) 
		return;
					
	// only if tight FOV
	GetAxes(Rotation,X,Y,Z);
	if(enemyDist != 0)
		enemyDir = (shooter.Location - Pawn.Location)/enemyDist;
	if ((enemyDir Dot X) < 0.8)
		return;

	if ( (FireDir Dot Y) > 0 )
	{
		Y *= -1;
		TryToDuck(Y, true);
	}
	else
		TryToDuck(Y, false);
}

function bool TryToDuck(vector duckDir, bool bReversed)
{
	local vector HitLocation, HitNormal, Extent;
	local actor HitActor;
	local bool bSuccess, bDuckLeft;

	if ( Pawn.PhysicsVolume.bWaterVolume 
		|| (Pawn.PhysicsVolume.Gravity.Z > Pawn.PhysicsVolume.Default.Gravity.Z) )
		return false;

	duckDir.Z = 0;
	bDuckLeft = !bReversed;
	Extent = Pawn.GetCollisionExtent();
	HitActor = Trace(HitLocation, HitNormal, Pawn.Location + 240 * duckDir, Pawn.Location, false, Extent);
	bSuccess = ( (HitActor == None) || (VSize(HitLocation - Pawn.Location) > 150) );
	if ( !bSuccess )
	{
		bDuckLeft = !bDuckLeft;
		duckDir *= -1;
		HitActor = Trace(HitLocation, HitNormal, Pawn.Location + 240 * duckDir, Pawn.Location, false, Extent);
		bSuccess = ( (HitActor == None) || (VSize(HitLocation - Pawn.Location) > 150) );
	}
	if ( !bSuccess )
		return false;
	
	if ( HitActor == None )
		HitLocation = Pawn.Location + 240 * duckDir; 

	HitActor = Trace(HitLocation, HitNormal, HitLocation - MAXSTEPHEIGHT * vect(0,0,1), HitLocation, false, Extent);
	if (HitActor == None)
		return false;
		
	SetFall();
	Pawn.Velocity = duckDir * Pawn.GroundSpeed;
	Pawn.Velocity.Z = 210;
	if ( bDuckLeft )
		MpPawn(Pawn).CurrentDir = DCLICK_Left;
	else	
		MpPawn(Pawn).CurrentDir = DCLICK_Right;
	Pawn.SetPhysics(PHYS_Falling);
	if ( (Pawn.Weapon != None) && Pawn.Weapon.SplashDamage()
		&& Pawn.Weapon.IsFiring() && (Enemy != None) 
		&& !FastTrace(Enemy.Location, HitLocation) 
		&& FastTrace(Enemy.Location, Pawn.Location) )
	{
		StopFiring();
	}
	return true;
}

function InitializeSkill(float InSkill)
{
	Skill = FClamp(InSkill, 0, 7);	// KEEP THIS AT SEVEN--THE GAME EXPLODES OTHERWISE. Plus anything past 7
									// actually makes the bots stupider.
	ReSetSkill();
}

function ReSetSkill()
{
	local float ftemp;

	Aggressiveness = BaseAggressiveness;
	bLeadTarget = ( Skill >= 4 );
	/* took it back out because it might be causing the bots to just
	 stand around a lot sometimes and we don't have to time to figure them out
	
	// modify the combat style each time, range based off ut2199 bot code
	CombatStyle = Frand()*3 - 1.0;
	// modify strafing, range based off ut2199 bot code
	ftemp = Skill/4.0f;
	StrafingAbility = (FRand()*8 - 4.0)*ftemp;
	// modify base aggression, based off ut2199 bot code
	BaseAggressiveness = FRand()*0.8 + 0.2;
	*/
	SetCombatTimer();
}

function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn)
{
	Squad.NotifyKilled(Killer,Killed,KilledPawn);
	// RWS CHANGE: Clear references to other pawns to avoid accessing pawns that have already been destroyed.
	// This is normally handled by squad but for some reason it doesn't do this after the game has ended.
	if ( Level.Game.bGameEnded )
	{
		Enemy = None;
		Focus = None;
		Target = None;
	}
}	

function bool FaceDestination(float StrafingModifier)
{
	local float RelativeDir;

	if ( Level.TimeSeconds - LastSeenTime > 7.5 - StrafingModifier )
		return true;
	if ( Enemy == None )
		return true;
	if ( (skill >= 6) && !Pawn.Weapon.bMeleeWeapon )
		return false;
	if ( VSize(MoveTarget.Location - Pawn.Location) < 2.5 * Pawn.CollisionRadius )
		return false;	
	if ( Level.TimeSeconds - LastSeenTime > 4 - StrafingModifier)
		return true;

	RelativeDir = Normal(Enemy.Location - Pawn.Location - vect(0,0,1) * (Enemy.Location.Z - Pawn.Location.Z)) 
			Dot Normal(MoveTarget.Location - Pawn.Location - vect(0,0,1) * (MoveTarget.Location.Z - Pawn.Location.Z));

	if ( RelativeDir > 0.93 )
		return false;
	if ( Pawn.Weapon.bMeleeWeapon && (RelativeDir < 0) )
		return true;
	if ( FRand() < 0.2 * (2 - StrafingModifier) )
		return false;
	if ( 0.5 * Skill - StrafingModifier * FRand() + RelativeDir + 0.6 + StrafingAbility < 0 )
		return true;

	return false;
}

function WanderOrCamp(bool bMayCrouch)
{
	Pawn.bWantsToCrouch = bMayCrouch && (Pawn.bIsCrouched || (FRand() < 0.75));
	GotoState('RestFormation');
}

function bool NeedAmmo()
{
	// return true if current weapon low on ammo
	// FIXME - check for acceptable alternate weapons with enough ammo

	if ( Pawn.Weapon != None )
		return (Pawn.Weapon.AmmoStatus() < 0.25);
	return false;
}

event float Desireability(Pickup P)
{
	if ( !MpPawn(Pawn).IsInLoadout(P.InventoryType) )
		return -1;
	return P.BotDesireability(Pawn);
}

function DamageAttitudeTo(Pawn Other, float Damage)
{
	if ( (Pawn.health > 0) && (Damage > 0) )
		Squad.SetEnemy(self,Other);
}

//**********************************************************************************
// AI States

//=======================================================================================================
// No goal/no enemy states

state NoGoal
{
	function EnemyChanged(bool bNewEnemyVisible)
	{
		SetEnemyInfo(bNewEnemyVisible);
		if ( EnemyAcquisitionScript != None )
			EnemyAcquisitionScript.TakeOver(Pawn);
		else
			ChooseAttackMode(false);
	}

	function HearPickup(Pawn Other)
	{
		if ( Skill < 8 * FRand() - 1 )
			return;
		if ( (Pawn.Health > 70) && (Pawn.Weapon.AiRating > 0.6) 
			&& (RelativeStrength(Other) < 0) )
			HearNoise(0.5, Other);
	}
}

function bool Formation()
{
	return false;
}

state RestFormation extends NoGoal
{
	ignores EnemyNotVisible;

	function CancelCampFor(Controller C)
	{
		DirectedWander(Normal(Pawn.Location - C.Pawn.Location));
	}

	function bool Formation()
	{
		return true;
	}

	function Timer()
	{
		enable('NotifyBump');
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Pawn.Location + MINSTRAFEDIST * Normal(Pawn.Location - aSpot.Location); 
	}

	function BeginState()
	{
		Enemy = None;
		SetAlertness(0.2);
		Pawn.bCanJump = false;
		Pawn.bAvoidLedges = true;
		Pawn.bStopAtLedges = true;
		Pawn.SetWalking(true);
		MinHitWall += 0.15;
	}
	
	function EndState()
	{
		MonitoredPawn = None;
		Squad.GetRestingFormation().LeaveFormation(self);
		MinHitWall -= 0.15;
		if ( Pawn != None )
		{
			Pawn.bStopAtLedges = false;
			Pawn.bAvoidLedges = false;
			Pawn.SetWalking(false);
			if (Pawn.JumpZ > 0)
				Pawn.bCanJump = true;
		}
	}

	event MonitoredPawnAlert()
	{
		WhatToDoNext();
	}

	function PickDestination()
	{
		FormationPosition = Squad.GetRestingFormation().RecommendPositionFor(self);
		Destination = Squad.GetRestingFormation().GetLocationFor(FormationPosition,self);
	}

Begin:
	WaitForLanding();
	PickDestination();
	
Moving:
	if ( Squad.FormationCenter() == Squad.SquadLeader.Pawn )
		StartMonitoring(Squad.SquadLeader.Pawn,Squad.GetRestingFormation().FormationSize);
	else
		MonitoredPawn = None;
	if ( PointReachable(Destination) )
		MoveTo(Destination,,,true);
	else
	{
		Destination = Pawn.Location + 0.5 * (Squad.FormationCenter().Location - Location);
		if ( PointReachable(Destination) )
			MoveTo(Destination,,,true);
		else
			Sleep(0.5 + FRand());
	}
	WaitForLanding();
	if ( !Squad.NearFormationCenter(Pawn) ) 
		WhatToDoNext();
Camping:
	Focus = None;
	Pawn.Acceleration = vect(0,0,0);
	FocalPoint = Squad.GetRestingFormation().GetViewPointFor(self,FormationPosition);
	NearWall(MINVIEWDIST);
	FinishRotation();
	if ( Squad.FormationCenter() == Squad.SquadLeader.Pawn )
		StartMonitoring(Squad.SquadLeader.Pawn,Squad.GetRestingFormation().FormationSize);
	else
		MonitoredPawn = None;
	Sleep(3 + FRand());
	WaitForLanding();
	if ( !Squad.WaitAtThisPosition(Pawn) ) 
		WhatToDoNext();
	if ( FRand() < 0.6 )
		Goto('Camping');
	Goto('Begin');
}

function Celebrate()
{
	GotoState('VictoryDance');
}

state VictoryDance extends RestFormation
{
	ignores EnemyNotVisible; 

	function AnimEnd(int channel)
	{
		Pawn.AnimEnd(channel);
		WhatToDoNext();
	}

Begin:
	Focus = Target;
	FinishRotation();
	Focus = None;
	FocalPoint.Z = Pawn.Location.Z;
	Pawn.SetAnimStatus('Victory');
}

//=======================================================================================================
// Move To Goal states

state MoveToGoal
{
	function bool CheckPathToGoalAround(Pawn P)
	{
		if ( (MoveTarget == None) || (Bot(P.Controller) == None) )
			return false;

		if ( Bot(P.Controller).Squad.ClearPathFor(self) )
			return true;
		return false;
	}

	function Timer()
	{
		enable('NotifyBump');
	}

	function BeginState()
	{
		Pawn.bWantsToCrouch = Squad.CautiousAdvance(self);
	}
}

state MoveToGoalNoEnemy extends MoveToGoal
{
	function EnemyChanged(bool bNewEnemyVisible)
	{
		SetEnemyInfo(bNewEnemyVisible);
		if ( EnemyAcquisitionScript != None )
			EnemyAcquisitionScript.TakeOver(Pawn);
		else
			ChooseAttackMode(false);
	}

	function HearPickup(Pawn Other)
	{
		if ( Skill < 8 * FRand() - 1 )
			return;
		if ( (Pawn.Health > 70) && (Pawn.Weapon.AiRating > 0.6) 
			&& (RelativeStrength(Other) < 0) )
			HearNoise(0.5, Other);
	}
}

state MoveToGoalWithEnemy extends MoveToGoal
{
	function Timer()
	{
		FireWeaponAt(Enemy);
	}
}

state Roaming extends MoveToGoalNoEnemy
{
	ignores EnemyNotVisible;

	function MayFall()
	{
		Pawn.bCanJump = ( (MoveTarget != None) 
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Pickup')) );
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Pawn.Location + MINSTRAFEDIST * Normal(Pawn.Location - aSpot.Location); 
		GotoState('RestFormation', 'Moving');
	}

	function ShareWith(Pawn Other)
	{
		local bool bHaveItem, bIsHealth, bOtherHas, bIsWeapon;

		if ( MoveTarget.IsA('WeaponPickup') )
		{
			if ( (Pawn.Weapon.AIRating < 0.5) || WeaponPickup(MoveTarget).bWeaponStay )
				return;
			bIsWeapon = true;
			bHaveItem = (Pawn.FindInventoryType(Pickup(MoveTarget).InventoryType) != None);
		}
		else if ( MoveTarget.IsA('TournamentHealth') )
		{
			bIsHealth = true;
			if ( Pawn.Health < 80 )
				return;
		}

		if ( (Other.Health <= 0) || Other.PlayerReplicationInfo.bIsSpectator || (VSize(Other.Location - Pawn.Location) > 1250)
			|| !LineOfSightTo(Other) )
			return;

		//decide who needs it more
		if ( bIsHealth )
		{
			if ( Pawn.Health > Other.Health + 10 )
			{
				GotoState('RestFormation');
				return;
			}
		}
		else if ( bIsWeapon && (Other.Weapon != None) && (Other.Weapon.AIRating < 0.5) )
		{
			GotoState('RestFormation');
			return;
		}
		else
		{
			bOtherHas = (Other.FindInventoryType(Pickup(MoveTarget).InventoryType) != None);
			if ( bHaveItem && !bOtherHas )
			{
				GotoState('RestFormation');
				return;
			}
		}
	}
	
Begin:
	SwitchToBestWeapon();
	WaitForLanding();
	if ( (InventorySpot(MoveTarget) != None) && (Squad.PriorityObjective(self) == 0) )
	{
		MoveTarget = InventorySpot(MoveTarget).GetMoveTargetFor(self,5);
		if ( (Pickup(MoveTarget) != None) && !Pickup(MoveTarget).ReadyToPickup(0) )
			GotoState('RestFormation','Camping');
	}

	if ( MoveTarget == Squad.SquadLeader.Pawn )
		MoveToward(MoveTarget,,,DesiredLeaderOffset(),ShouldStrafeTo(MoveTarget));
	else
		MoveToward(MoveTarget,,,,ShouldStrafeTo(MoveTarget));
DoneRoaming:
	WaitForLanding();
	WhatToDoNext();
	if ( bSoaking )
		SoakStop("STUCK IN ROAMING!");
}

function float DesiredLeaderOffset()
{
	local float result;
	local vector Dir;

	Dir = Pawn.Location - Squad.SquadLeader.Pawn.Location;
	Dir.Z = 0;
	result = VSize(Dir) - Pawn.CollisionRadius;
	if ( result <= 2 * Pawn.CollisionRadius )
		return 2 * Pawn.CollisionRadius;

	result = FMin(result, 6*FMax(Pawn.CollisionRadius,Squad.SquadLeader.Pawn.CollisionRadius));
	return FMin(Squad.GetRestingFormation().FormationSize*0.5,result);
}

state Fallback extends MoveToGoalWithEnemy
{
	function MayFall()
	{
		Pawn.bCanJump = ( (MoveTarget != None) 
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Pickup')) );
	}

	function EnemyNotVisible()
	{
		if ( Squad.FindNewEnemyFor(self,false) )
			return;
		if ( Enemy == None )
			WhatToDoNext();
		else
		{
			enable('SeePlayer');
			disable('EnemyNotVisible');
		}
	}

	function EnemyChanged(bool bNewEnemyVisible)
	{
		if ( ChoosingAttackLevel > 0 )
		{
			Global.EnemyChanged(bNewEnemyVisible);
			return;
		}
		SetEnemyInfo(bNewEnemyVisible);
		if ( bNewEnemyVisible )
		{
			disable('SeePlayer');
			enable('EnemyNotVisible');
		}
	}

	function BeginState()
	{
		Pawn.bWantsToCrouch = Squad.CautiousAdvance(self);
	}

Begin:
	WaitForLanding();

Moving:
	if ( InventorySpot(MoveTarget) != None )
		MoveTarget = InventorySpot(MoveTarget).GetMoveTargetFor(self,0);
	if ( FaceDestination(1) )
	{
		StopFiring();
		MoveToward(MoveTarget,,,,(Level.TimeSeconds - LastSeenTime < 2.0) && ShouldStrafeTo(MoveTarget));
	}
	else
		MoveToward(MoveTarget, Enemy,,,(Level.TimeSeconds - LastSeenTime < 2.0) && ShouldStrafeTo(MoveTarget));
	ChooseAttackMode(false);
	if ( bSoaking )
		SoakStop("STUCK IN FALLBACK!");
	goalstring = goalstring$" STUCK IN FALLBACK!";
}

// FIXME - implement acquisition state for SP

//=======================================================================================================================
// Tactical Combat states

/* LostContact()
return true if lost contact with enemy
*/
function bool LostContact(float MaxTime)
{
	if ( Enemy == None )
		return true;

	if ( Level.TimeSeconds - FMax(LastSeenTime,AcquireTime) > MaxTime )
		return true;

	return false;
}

/* LoseEnemy()
get rid of old enemy, if squad lets me
*/
function bool LoseEnemy()
{
	if ( LoseEnemyCheckTime > Level.TimeSeconds - 0.2 )
		return false;
	LoseEnemyCheckTime = Level.TimeSeconds;
	if ( Squad.LostEnemy(self) )
	{
		bFrustrated = false;
		if ( Enemy == None )
			WhatToDoNext();
		else
			ChooseAttackMode(false);
		return true;
	}
	// still have same enemy
	return false;
}

function DoStakeOut()
{
	GotoState('StakeOut');
}

function DoCharge()
{
	if ( Enemy.PhysicsVolume.bWaterVolume )
	{
		if ( !Pawn.bCanSwim ) 
			DoTacticalMove();
	}
	else if ( !Pawn.bCanFly && !Pawn.bCanWalk )
		DoTacticalMove();
	GotoState('Charging');
}

function DoTacticalMove()
{
	GotoState('TacticalMove');
}

function DoRetreat()
{
	if ( LostContact(9) && LoseEnemy() )
		return;
	if ( Squad.PickRetreatDestination(self) )
		GotoState('Retreating');

	// if nothing, then tactical move
	if ( LineOfSightTo(Enemy) )
	{
		bFrustrated = true;
		GotoState('TacticalMove');
		return;
	}
	if ( LoseEnemy() )
		return;
	else
		DoStakeOut();
}

/* DefendMelee()
return true if defending against melee attack
*/
function bool DefendMelee(float Dist)
{
	return ( (Enemy.Weapon != None) && Enemy.Weapon.bMeleeWeapon && (Dist < 1000) );
}

function ChooseAttackMode(bool bCheckedSquad)
{
	// if reentering ChooseAttackMode, ignore unless tactical state change (changed enemy or squad)
	if ( (ChoosingAttackLevel > 0) && (Enemy == AttackEnemy) && (Squad == AttackSquad) )
		return;

	AttackEnemy = Enemy;
	AttackSquad = Squad;
	ChoosingAttackLevel++;
	ExecuteChooseAttackMode(bCheckedSquad);
	ChoosingAttackLevel--;
}

/* ChooseAttackMode()
Handles tactical attacking state selection - choose which type of attack to do from here
*/
function ExecuteChooseAttackMode(bool bCheckedSquad)
{
	local eAttitude AttitudeToEnemy;

	if ( Pawn == None )
		warn(self$" ChooseAttackMode with no pawn");

	if ( ScriptingOverridesAI() && ShouldPerformScript() )
		return;

	if (Pawn.Physics == PHYS_None)
		Pawn.SetMovementPhysics(); 
	GoalString = "At start";
	SwitchToBestWeapon();

	// check if squad wants to override my tactical decision
	if ( !bCheckedSquad && AssignSquadResponsibility() ) 
		return;
	GoalString = "perform script";
	if ( ShouldPerformScript() )
		return;

	// make sure have valid enemy
	if ( Enemy == None )
	{
		GoalString = "Lost enemy2";
		WhatToDoNext();
		return;
	}

	// should I run away?
	AttitudeToEnemy = AttitudeTo(Enemy);
	GoalString = GoalString$" ChooseAttackMode attitude "$AttitudeToEnemy$" last seen "$(Level.TimeSeconds - LastSeenTime);	
	if ( AttitudeToEnemy == ATTITUDE_Fear )
	{
		GoalString = "Retreat";
		DoRetreat();
		return;
	}
	FightEnemy(true);
}

function FightEnemy(bool bCanCharge)
{
	local vector X,Y,Z;
	local float enemyDist, SkillMod;

	if ( !LineOfSightTo(Enemy) )
	{
		GoalString = "Enemy not visible";
		// if enemy isn't visible, stake out or hunt
		if ( Squad.FindNewEnemyFor(self,false) )
		{
			GoalString = "Found new enemy";
			return;
		}
		if ( Enemy == None )
		{
			GoalString = "Lost enemy";
			WhatToDoNext();
			return;
		}
		GoalString = "Enemy still not visible";
		if ( !LineOfSightTo(Enemy) )
		{
			if ( Squad.IsDefending(self) && LostContact(5) )
			{
				GoalString = "Lose non visible enemy";
				if ( LoseEnemy() )
					return;
				GoalString = "Stake Out";
				DoStakeOut(); 
			}
			else if ( !bCanCharge || (IsSniping() && CanStakeOut()) )
			{
				GoalString = "Stake Out2";
				DoStakeOut();
			}
			else
			{
				GoalString = "Hunt";
				GotoState('Hunting');
			}
			return;
		}
	}
		
	// see enemy - decide whether to charge it or strafe around/stand and fire
	Target = Enemy;
	if( Pawn.Weapon.bMeleeWeapon )
	{
		GoalString = "Charge";
		DoCharge();
		return;
	}

	enemyDist = VSize(Pawn.Location - Enemy.Location);
	if ( Pawn.Weapon.bSniping && (enemyDist > ENEMYLOCATIONFUZZ) )
		SkillMod = -0.2;
	else
		SkillMod = 0.3;
	if ( IsSniping() || ((FRand() > SkillMod + 0.15 * skill) && !DefendMelee(enemyDist)) )
	{
		GoalString = "Ranged Attack";
		GotoState('RangedAttack');
		return;
	}

	if ( bCanCharge )
	{
		Aggression = 2 * (CombatStyle + FRand()) - 1.1 + 2 * Pawn.Weapon.SuggestAttackStyle()
					+ FRand() * ((Enemy.Velocity - Pawn.Velocity) Dot (Enemy.Location - Pawn.Location));
		if ( Enemy.Weapon != None )
			Aggression += 2 * Enemy.Weapon.SuggestDefenseStyle();
		if ( enemyDist > MAXSTAKEOUTDIST )
			Aggression += 0.5;

		if ( (Pawn.Physics == PHYS_Walking) || (Pawn.Physics == PHYS_Falling) )
		{
			if (Pawn.Location.Z > Enemy.Location.Z + TACTICALHEIGHTADVANTAGE) 
				Aggression = FMax(0.0, Aggression - 1.0 + CombatStyle);
			else if (Pawn.Location.Z < Enemy.Location.Z - Pawn.CollisionHeight) // below enemy
				Aggression += 0.5 * CombatStyle;
		}

		if ( Aggression > 2 * FRand() )
		{
			GoalString = "Charge 2";
			DoCharge();
			return;
		}
	}
	if ( !Pawn.Weapon.RecommendSplashDamage() && (FRand() < 0.35) && (bJumpy || (FRand()*Skill > 3)) )
	{
		GetAxes(Rotation,X,Y,Z);
		GoalString = "Try to Duck ";
		if ( FRand() < 0.5 )
		{
			Y *= -1;
			if ( TryToDuck(Y, true) )
				return;
		}
		else if ( TryToDuck(Y, false) )
			return;
	}
	GoalString = "Do tactical move";
	DoTacticalMove();
}

state Retreating extends Fallback
{
	function bool FaceDestination(float StrafingModifier)
	{
		return Global.FaceDestination(2);
	}

	function BeginState()
	{
		Pawn.bWantsToCrouch = Squad.CautiousAdvance(self);
		if ( AttitudeTo(Enemy) <= ATTITUDE_Fear )
			Squad.CallForHelp(self);
	}
}

state Charging extends MoveToGoalWithEnemy
{
ignores SeePlayer, HearNoise;

	/* MayFall() called by engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting 
		bCanJump to false) to avoid fall
	*/
	function MayFall()
	{
		if ( MoveTarget != Enemy )
			return;

		Pawn.bCanJump = ActorReachable(Enemy);
		if ( !Pawn.bCanJump )
			MoveTimer = -1.0;
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Pawn.Location + 120 * Normal(Normal(Destination - Pawn.Location) + Normal(Pawn.Location - aSpot.Location)); 
		GotoState('TacticalMove', 'DoStrafeMove');
	}

	function bool TryToDuck(vector duckDir, bool bReversed)
	{
		if ( FRand() < 0.6 )
			return Global.TryToDuck(duckDir, bReversed);
		if ( MoveTarget == Enemy ) 
			return TryStrafe(duckDir);
	}

	function bool StrafeFromDamage(float Damage, class<DamageType> DamageType, bool bFindDest)
	{
		local vector sideDir;

		if ( FRand() * Damage < 0.15 * CombatStyle * Pawn.Health ) 
			return false;

		if ( !bFindDest )
			return true;

		sideDir = Normal( Normal(Enemy.Location - Pawn.Location) Cross vect(0,0,1) );
		if ( (Pawn.Velocity Dot sidedir) > 0 )
			sidedir *= -1;

		return TryStrafe(sideDir);
	}

	function bool TryStrafe(vector sideDir)
	{ 
		local vector extent, HitLocation, HitNormal;
		local actor HitActor;

		Extent = Pawn.GetCollisionExtent();
		HitActor = Trace(HitLocation, HitNormal, Pawn.Location + MINSTRAFEDIST * sideDir, Pawn.Location, false, Extent);
		if (HitActor != None)
		{
			sideDir *= -1;
			HitActor = Trace(HitLocation, HitNormal, Pawn.Location + MINSTRAFEDIST * sideDir, Pawn.Location, false, Extent);
		}
		if (HitActor != None)
			return false;
		
		if ( Pawn.Physics == PHYS_Walking )
		{
			HitActor = Trace(HitLocation, HitNormal, Pawn.Location + MINSTRAFEDIST * sideDir - MAXSTEPHEIGHT * vect(0,0,1), Pawn.Location + MINSTRAFEDIST * sideDir, false, Extent);
			if ( HitActor == None )
				return false;
		}
		Destination = Pawn.Location + 2 * MINSTRAFEDIST * sideDir;
		GotoState('TacticalMove', 'DoStrafeMove');
		return true;
	}

	function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
	{	
		local float pick;
		local vector sideDir;
		local bool bWasOnGround;

		Super.NotifyTakeHit(InstigatedBy,HitLocation, Damage,DamageType,Momentum);

		bWasOnGround = (Pawn.Physics == PHYS_Walking);
		if ( Pawn.health <= 0 )
			return;
		if ( StrafeFromDamage(damage, damageType, true) )
			return; 
		else if ( bWasOnGround && (MoveTarget == Enemy) && 
					(Pawn.Physics == PHYS_Falling) ) //weave
		{
			pick = 1.0;
			if ( bStrafeDir )
				pick = -1.0;
			sideDir = Normal( Normal(Enemy.Location - Pawn.Location) Cross vect(0,0,1) );
			sideDir.Z = 0;
			Pawn.Velocity += pick * Pawn.GroundSpeed * 0.7 * sideDir;   
			if ( FRand() < 0.2 )
				bStrafeDir = !bStrafeDir;
		}
	}

	event bool NotifyBump(actor Other)
	{
		if ( (Other == Enemy)
			&& (Pawn.Weapon != None) && !Pawn.Weapon.bMeleeWeapon && (FRand() > 0.4 + 0.1 * skill) )
		{
			Target = Enemy;
			GotoState('RangedAttack');
			return false;
		}
		return Global.NotifyBump(Other);
	}

	function Timer()
	{
		enable('NotifyBump');
		Target = Enemy;	
		FireWeaponAt(Enemy);
	}
	
	function EnemyNotVisible()
	{
		ChooseAttackMode(false); 
	}

	function BeginState()
	{
		Pawn.bWantsToCrouch = Squad.CautiousAdvance(self);
	}

	function EndState()
	{
		if ( (Pawn != None) && Pawn.JumpZ > 0 )
			Pawn.bCanJump = true;
	}

Begin:
	if (Pawn.Physics == PHYS_Falling)
	{
		Focus = Enemy;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	if( actorReachable(Enemy) )
		MoveToward(Enemy);
	else
	{
		if ( !FindBestPathToward(Enemy, true) )
			GotoState('TacticalMove');
Moving:
		if ( FaceDestination(1.5) )
		{
			StopFiring();
			MoveToward(MoveTarget,,,,ShouldStrafeTo(MoveTarget));
		}
		else
			MoveToward(MoveTarget, Enemy,,,ShouldStrafeTo(MoveTarget));
	}
	ChooseAttackMode(false);
	if ( bSoaking )
		SoakStop("STUCK IN CHARGING!");
}

state TacticalMove
{
ignores SeePlayer, HearNoise;

	function ReceiveWarning(Pawn shooter, float projSpeed, vector FireDir)
	{	
		if ( bCanFire && (FRand() < 0.4) ) 
			return;

		Super.ReceiveWarning(shooter, projSpeed, FireDir);
	}

	function SetFall()
	{
		Pawn.Acceleration = vect(0,0,0);
		Destination = Pawn.Location;
		Global.SetFall();
	}

	function bool NotifyHitWall(vector HitNormal, actor Wall)
	{
		if (Pawn.Physics == PHYS_Falling)
			return false;
		if ( Enemy == None )
		{
			ChooseAttackMode(false);
			return false;
		}
		if ( bChangeDir || (FRand() < 0.5) 
			|| (((Enemy.Location - Pawn.Location) Dot HitNormal) < 0) )
		{
			Focus = Enemy;
			ChooseAttackMode(false);
		}
		else
		{
			bChangeDir = true;
			Destination = Pawn.Location - HitNormal * FRand() * 500;
		}
		return true;
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Pawn.Location + 120 * Normal(Pawn.Location - aSpot.Location); 
	}

	function Timer()
	{
		enable('NotifyBump');
		Target = Enemy;
		if ( Enemy == None )
			return;
		FireWeaponAt(Enemy);
	}

	function EnemyNotVisible()
	{
		if ( aggressiveness > relativestrength(enemy) )
		{
			if ( FastTrace(Enemy.Location, LastSeeingPos) )
			{
				bCanFire = false;
				GotoState('TacticalMove','RecoverEnemy');
			}
			else
				ChooseAttackMode(false);
		}
		Disable('EnemyNotVisible');
	}

	function PawnIsInPain(PhysicsVolume PainVolume)
	{
		Destination = Pawn.Location - MINSTRAFEDIST * Normal(Pawn.Velocity);
	}

/* PickDestination()
Choose a destination for the tactical move, based on aggressiveness and the tactical
situation. Make sure destination is reachable
*/
	function PickDestination()
	{
		local vector pickdir, enemydir, enemyPart, Y, HitNormal;
		local float strafeSize;

		if ( Pawn == None )
		{
			warn(self$" Tactical move pick destination with no pawn");
			return;
		}
		bChangeDir = false;
		if ( Pawn.PhysicsVolume.bWaterVolume && !Pawn.bCanSwim && Pawn.bCanFly)
		{
			Destination = Pawn.Location + 75 * (VRand() + vect(0,0,1));
			Destination.Z += 100;
			return;
		}

		enemydir = Normal(Enemy.Location - Pawn.Location);
		Y = (enemydir Cross vect(0,0,1));
		if ( Pawn.Physics == PHYS_Walking )
		{
			Y.Z = 0;
			enemydir.Z = 0;
		}
		else 
			enemydir.Z = FMax(0,enemydir.Z);
			
		strafeSize = FMax(-0.7, FMin(0.85, (2 * Aggression * FRand() - 0.3)));
		enemyPart = enemydir * strafeSize;
		strafeSize = FMax(0.0, 1 - Abs(strafeSize));
		pickdir = strafeSize * Y;
		if ( bStrafeDir )
			pickdir *= -1;
		bStrafeDir = !bStrafeDir;
		
		if ( EngageDirection(enemyPart + pickdir, HitNormal) )
			return;
	
		if ( EngageDirection(enemyPart - pickdir, HitNormal) )
			return;

		if ( EngageDirection(HitNormal, HitNormal) )
			return;
			
		// Failed to find strafe direction
		GoalString = GoalString$" RangedAttack from failed TacticalMove";
		GotoState('RangedAttack'); // FIXME - either allow charge, or make this very rare
	}

	function bool EngageDirection(vector StrafeDir, out vector HitNormal)
	{
		local actor HitActor;
		local vector HitLocation, collspec, MinDest;

		// successfully engage direction if can trace out and down
		MinDest = Pawn.Location + MINSTRAFEDIST * StrafeDir;
		collSpec = Pawn.GetCollisionExtent();
		collSpec.Z = FMax(6, Pawn.CollisionHeight - Pawn.CollisionRadius);

		HitActor = Trace(HitLocation, HitNormal, MinDest, Pawn.Location, false, collSpec);
		if ( HitActor != None )
			return false;

		if ( Pawn.Physics == PHYS_Walking )
		{
			collSpec.X = FMin(14, 0.5 * Pawn.CollisionRadius);
			collSpec.Y = collSpec.X;
			HitActor = Trace(HitLocation, HitNormal, minDest - (Pawn.CollisionRadius + MAXSTEPHEIGHT) * vect(0,0,1), minDest, false, collSpec);
			if ( HitActor == None )
			{
				HitNormal = -1 * StrafeDir;
				return false;
			}
		}
	
		Destination = MinDest + StrafeDir * (0.5 * MINSTRAFEDIST 
											+ FMin(VSize(Enemy.Location - Pawn.Location), MINSTRAFEDIST * (FRand() + FRand())));  
		if ( bJumpy || (Pawn.Weapon.RecommendSplashDamage() 
			&& (FRand() < 0.1 + 0.1 * Skill)
			&& (Enemy.Location.Z - Enemy.CollisionHeight <= Pawn.Location.Z + MAXSTEPHEIGHT - Pawn.CollisionHeight)) 
			&& !NeedToTurn(Enemy.Location) )
		{
			FireWeaponAt(Enemy);
			if ( (bJumpy && (FRand() < 0.75)) || Pawn.Weapon.SplashJump() )
			{
				// try jump move
				Pawn.SetPhysics(PHYS_Falling);
				Pawn.Acceleration = vect(0,0,0);
				Destination = minDest;
				return true;
			}
		}
		return true;
	}

	function BeginState()
	{
		if ( Skill <= 4 ) 
			Pawn.MaxDesiredSpeed = 0.4 + 0.08 * skill;
		MinHitWall += 0.15;
		Pawn.bAvoidLedges = true;
		Pawn.bStopAtLedges = true;
		Pawn.bCanJump = false;
		bAdjustFromWalls = false;
		Pawn.bWantsToCrouch = Squad.CautiousAdvance(self);
	}
	
	function EndState()
	{
		bAdjustFromWalls = true;
		if ( Pawn == None )
			return;
		Pawn.MaxDesiredSpeed = 1;
		Pawn.bAvoidLedges = false;
		Pawn.bStopAtLedges = false;
		MinHitWall -= 0.15;
		if (Pawn.JumpZ > 0)
			Pawn.bCanJump = true;
	}

TacticalTick:
	Sleep(0.02);	
Begin:
	if (Pawn.Physics == PHYS_Falling)
	{
		Focus = Enemy;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	PickDestination();

DoMove:
	if ( !Pawn.bCanStrafe )
	{ 
DoDirectMove:
		StopFiring();
		MoveTo(Destination);
	}
	else
	{
DoStrafeMove:
		MoveTo(Destination, Enemy);	
	}

	if ( (Enemy == None) || LineOfSightTo(Enemy) || !FastTrace(Enemy.Location, LastSeeingPos) )
		Goto('FinishedStrafe');

	CheckIfShouldCrouch(LastSeeingPos,Enemy.Location, 0.5);

RecoverEnemy:
	HidingSpot = Pawn.Location;
	StopFiring();
	Destination = LastSeeingPos + 4 * Pawn.CollisionRadius * Normal(LastSeeingPos - Pawn.Location);
	MoveTo(Destination, Enemy);

	if ( FireWeaponAt(Enemy) )
	{
		Pawn.Acceleration = vect(0,0,0);
		if ( Pawn.Weapon.SplashDamage() )
		{
			StopFiring();
			Sleep(0.2);
		}
		else
			Sleep(0.35 + 0.3 * FRand());
		if ( (FRand() + 0.1 > CombatStyle) )
		{
			StopFiring();
			Enable('EnemyNotVisible');
			Destination = HidingSpot + 4 * Pawn.CollisionRadius * Normal(HidingSpot - Pawn.Location);
			Goto('DoMove');
		}
	}
FinishedStrafe:
	ChooseAttackMode(false);
	if ( bSoaking )
		SoakStop("STUCK IN TACTICAL MOVE!");
}

function bool IsHunting()
{
	return false;
}

state Hunting extends MoveToGoalWithEnemy
{
ignores EnemyNotVisible; 

	/* MayFall() called by engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting 
		bCanJump to false) to avoid fall
	*/
	function bool IsHunting()
	{
		return true;
	}

	function MayFall()
	{
		Pawn.bCanJump = ( ((MoveTarget != None) 
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Pickup')))
					|| PointReachable(Destination) );
	}
	
	function FearThisSpot(Actor aSpot)
	{
		Destination = Pawn.Location + MINSTRAFEDIST * Normal(Normal(Destination - Pawn.Location) + Normal(Pawn.Location - aSpot.Location)); 
		MoveTarget = None;
		GotoState('Hunting', 'SpecialNavig');
	}

	function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
	{	
		Super.NotifyTakeHit(InstigatedBy,HitLocation, Damage,DamageType,Momentum);
		if ( (Pawn.Health > 0) && (Damage > 0) )
			bFrustrated = true;
	}

	function SeePlayer(Pawn SeenPlayer)
	{
		if ( SeenPlayer == Enemy )
		{
			BlockedPath = None;
			Focus = Enemy;
			ChooseAttackMode(false);
		}
		else
			Global.SeePlayer(SeenPlayer);
	} 

	function Timer()
	{
		StopFiring();
	}

	function PickDestination()
	{
		local vector nextSpot, ViewSpot;
		local float posZ;
		local bool bCanSeeLastSeen;
		local int i;

		// If no enemy, or I should see him but don't, then give up	
		if ( LostContact(9) && LoseEnemy() )
			return;
		if ( (Enemy == None) || (Enemy.Health <= 0) )
		{
			WhatToDoNext();
			return;
		}

		if ( Pawn.JumpZ > 0 )
			Pawn.bCanJump = true;
		
		if ( ActorReachable(Enemy) )
		{
			BlockedPath = None;
			if ( (LostContact(6) && (((Enemy.Location - Pawn.Location) Dot vector(Pawn.Rotation)) < 0)) 
				&& LoseEnemy() )
				return;

			Destination = Enemy.Location;
			MoveTarget = None;
			return;
		}

		ViewSpot = Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1);
		bCanSeeLastSeen = bEnemyInfoValid && FastTrace(LastSeenPos, ViewSpot);

		if ( Squad.BeDevious() )
		{
			if ( BlockedPath == None )
			{
				// block the first path visible to the enemy
				if ( FindPathToward(Enemy) != None )
				{
					for ( i=0; i<16; i++ )
					{
						if ( NavigationPoint(RouteCache[i]) == None )
							break;
						else if ( Enemy.Controller.LineOfSightTo(RouteCache[i]) )
						{
							BlockedPath = NavigationPoint(RouteCache[i]);
							break;
						}
					}
				}
				else if ( CanStakeOut() )
				{
					GotoState('StakeOut');
					return;
				}
				else if ( LoseEnemy() )
					return;
				else 
				{
					DoRetreat();
					return;
				}
			}
			// control path weights
			ClearPaths();
			BlockedPath.Cost = 1500;
			if ( FindBestPathToward(Enemy, false) )
				return;
		}
		else if ( FindBestPathToward(Enemy, true) )
			return;

		if ( bSoaking && (Physics != PHYS_Falling) )
			SoakStop("COULDN'T FIND PATH TO ENEMY "$Enemy);

		MoveTarget = None;
		if ( !bEnemyInfoValid && LoseEnemy() )
			return;

		Destination = LastSeeingPos;
		bEnemyInfoValid = false;
		if ( FastTrace(Enemy.Location, ViewSpot) 
			&& VSize(Pawn.Location - Destination) > Pawn.CollisionRadius )
		{
			SeePlayer(Enemy);
			return;
		}

		posZ = LastSeenPos.Z + Pawn.CollisionHeight - Enemy.CollisionHeight;
		nextSpot = LastSeenPos - Normal(Enemy.Velocity) * Pawn.CollisionRadius;
		nextSpot.Z = posZ;
		if ( FastTrace(nextSpot, ViewSpot) )
			Destination = nextSpot;
		else if ( bCanSeeLastSeen )
			Destination = LastSeenPos;
		else
		{
			Destination = LastSeenPos;
			if ( !FastTrace(LastSeenPos, ViewSpot) )
			{
				// check if could adjust and see it
				if ( PickWallAdjust(Normal(LastSeenPos - ViewSpot)) || FindViewSpot() )
				{
					if ( Pawn.Physics == PHYS_Falling )
						SetFall();
					else
						GotoState('Hunting', 'AdjustFromWall');
				}
				else if ( (VSize(Enemy.Location - Pawn.Location) < MAXSTAKEOUTDIST) || !LoseEnemy() )
				{
					GotoState('StakeOut');
					return;
				}
				else
					return;
			}
		}
	}	

	function bool FindViewSpot()
	{
		local vector X,Y,Z;
		local bool bAlwaysTry;

		GetAxes(Rotation,X,Y,Z);

		// try left and right
		// if frustrated, always move if possible
		bAlwaysTry = bFrustrated;
		bFrustrated = false;
		
		if ( FastTrace(Enemy.Location, Pawn.Location + 2 * Y * Pawn.CollisionRadius) )
		{
			Destination = Pawn.Location + 2.5 * Y * Pawn.CollisionRadius;
			return true;
		}

		if ( FastTrace(Enemy.Location, Pawn.Location - 2 * Y * Pawn.CollisionRadius) )
		{
			Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
			return true;
		}
		if ( bAlwaysTry )
		{
			if ( FRand() < 0.5 )
				Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
			else
				Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
			return true;
		}

		return false;
	}

	function BeginState()
	{
		Pawn.bWantsToCrouch = Squad.CautiousAdvance(self);
		SetAlertness(0.5);
	}

	function EndState()
	{
		if ( (Pawn != None) && (Pawn.JumpZ > 0) )
			Pawn.bCanJump = true;
	}

AdjustFromWall:
	MoveTo(Destination, MoveTarget); 

Begin:
	WaitForLanding();
	if ( CanSee(Enemy) )
		SeePlayer(Enemy);
	PickDestination();
SpecialNavig:
	if (MoveTarget == None)
		MoveTo(Destination);
	else
		MoveToward(MoveTarget,,,,(FRand() < 0.75) && ShouldStrafeTo(MoveTarget)); 

	ChooseAttackMode(false);
	if ( bSoaking )
		SoakStop("STUCK IN HUNTING!");
}

state StakeOut
{
ignores EnemyNotVisible; 

	event SeePlayer(Pawn SeenPlayer)
	{
		if ( SeenPlayer == Enemy )
		{
			Focus = Enemy;
			FireWeaponAt(Enemy);
			ChooseAttackMode(false);
		}
		else
			Squad.SetEnemy(self,SeenPlayer);
	}
	/* DoStakeOut()
	called by ChooseAttackMode - if called in this state, means stake out twice in a row
	*/
	function DoStakeOut()
	{
		if ( (FRand() < 0.3) || !FastTrace(FocalPoint + vect(0,0,0.9) * Enemy.CollisionHeight, Pawn.Location + vect(0,0,0.8) * Pawn.CollisionHeight) )
			FindNewStakeOutDir();
		GotoState('StakeOut','Begin');
	}

	function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
	{	
		Super.NotifyTakeHit(InstigatedBy,HitLocation, Damage,DamageType,Momentum);
		if ( (Pawn.Health > 0) && (Damage > 0) )
		{
			bFrustrated = true;
			if ( InstigatedBy == Enemy )
				AcquireTime = Level.TimeSeconds;
			ChooseAttackMode(false);
		}
	}
	
	function Timer()
	{
		enable('NotifyBump');
	}

	function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
	{
		local vector FireSpot;
		local actor HitActor;
		local vector HitLocation, HitNormal;
				
		FireSpot = FocalPoint;
			 
		HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if( HitActor != None ) 
		{
			FireSpot += 2 * Enemy.CollisionHeight * HitNormal;
			if ( !FastTrace(FireSpot, ProjStart) )
			{
				FireSpot = FocalPoint;
				StopFiring();
			}
		}
		
		SetRotation(Rotator(FireSpot - ProjStart));
		// RWS Change 07/23/03 ViewPitch brought over from 2141 to do torso twisting
	    UpdatePawnViewPitch();
		return Rotation;
	}
	
	function FindNewStakeOutDir()
	{
		local NavigationPoint N, Best;
		local vector Dir, EnemyDir;
		local float Dist, BestVal, Val;

		EnemyDir = Normal(Enemy.Location - Pawn.Location);
		for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		{
			Dir = N.Location - Pawn.Location;
			Dist = VSize(Dir);
			if ( (Dist < MAXSTAKEOUTDIST) && (Dist > MINSTRAFEDIST) )
			{
				Val = (EnemyDir Dot Dir/Dist);
				if ( Level.Game.bTeamgame )
					Val += FRand();
				if ( (Val > BestVal) && LineOfSightTo(N) )
				{
					BestVal = Val;
					Best = N;
				}
			}
		}
		if ( Best != None )
			FocalPoint = Best.Location + 0.5 * Pawn.CollisionHeight * vect(0,0,1);			
	}

	function BeginState()
	{
		Pawn.Acceleration = vect(0,0,0);
		Pawn.bCanJump = false;
		SetAlertness(0.5);
		if ( bEnemyInfoValid )
			FocalPoint = LastSeenPos;
		else
			FocalPoint = Enemy.Location;
		if ( !bEnemyInfoValid || !ClearShot(FocalPoint,false) || ((Level.TimeSeconds - LastSeenTime > 6) && (FRand() < 0.5)) )
			FindNewStakeOutDir();
	}

	function EndState()
	{
		if ( (Pawn != None) && (Pawn.JumpZ > 0) )
			Pawn.bCanJump = true;
	}

Begin:
	Pawn.Acceleration = vect(0,0,0);
	Focus = None;
	CheckIfShouldCrouch(Pawn.Location,FocalPoint, 1);
	FinishRotation();
	if ( (Pawn.Weapon != None) && !Pawn.Weapon.bMeleeWeapon && (FRand() < 0.5) && (VSize(Enemy.Location - FocalPoint) < 150) 
		 && ClearShot(FocalPoint,true) )
	{
		FireWeaponAt(Enemy);
	}
	Sleep(1 + FRand());
	// check if uncrouching would help
	if ( Pawn.bIsCrouched 
		&& !FastTrace(FocalPoint, Pawn.Location + Pawn.EyeHeight * vect(0,0,1))
		&& FastTrace(FocalPoint, Pawn.Location + (Pawn.Default.EyeHeight + Pawn.Default.CollisionHeight - Pawn.CollisionHeight) * vect(0,0,1)) )
	{
		Pawn.bWantsToCrouch = false;
		Sleep(0.15 + 0.05 * (1 + FRand()) * (10 - skill));
	}
	ChooseAttackMode(false);
	if ( bSoaking )
		SoakStop("STUCK IN STAKEOUT!");
}

state RangedAttack
{
ignores SeePlayer, HearNoise, Bump;

	function CancelCampFor(Controller C)
	{
		GotoState('TacticalMove');
	}

	function StopFiring()
	{
		Global.StopFiring();
		if ( IsSniping() )
			Pawn.bWantsToCrouch = true;
		else
			ChooseAttackMode(false);
	}

	function StopWaiting()
	{
		Timer();
	}

	function EnemyNotVisible()
	{
		//let attack animation complete
		if ( Pawn.Weapon.bMeleeWeapon || (FRand() < 0.13) )
			ChooseAttackMode(false);
	}

	function Timer()
	{
		if ( Pawn.Weapon.bMeleeWeapon )
			ChooseAttackMode(false);
		else
			FireWeaponAt(Target);
	}
	
	function BeginState()
	{
		Pawn.Acceleration = vect(0,0,0); //stop
		if ( Target == None )
			Target = Enemy;
	}

Begin:
	GoalString = "Ranged attack target "$Target;
	Focus = Target;
	
FaceTarget:
	if ( Enemy != None )
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
	if ( NeedToTurn(Target.Location) )
	{
		Focus = Target;
		FinishRotation();
	}

ReadyToAttack:
	FireWeaponAt(Target);
Firing:
	if ( Pawn.Weapon.bMeleeWeapon || (Target == None) )
		ChooseAttackMode(false);
	if ( Enemy != None )
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
	Focus = Target;
	Sleep(0.6 + 0.3 * Skill); //fixme + weapon recommend ranged time (for combos)
	ChooseAttackMode(false);
	if ( bSoaking )
		SoakStop("STUCK IN RANGEDATTACK!");
}

state Dead
{
ignores SeePlayer, EnemyNotVisible, HearNoise, ReceiveWarning, NotifyLanded, NotifyPhysicsVolumeChange,
		NotifyHeadVolumeChange,NotifyLanded,NotifyHitWall,NotifyBump;

	function ChooseAttackMode(bool bCheckedSquad)
	{
		log(self$" Attack while dead");
	}

	function Celebrate()
	{
		log(self$" Celebrate while dead");
	}

	function SetAttractionState()
	{
		log(self$" SetAttractionState while dead");
	}

	function EnemyChanged(bool bNewEnemyVisible)
	{
		log(self$" EnemyChanged while dead");
	}

	function WhatToDoNext()
	{
		log(self$" WhatToDoNext while dead");
	}

	function WanderOrCamp(bool bMayCrouch)
	{
		log(self$" WanderOrCamp while dead");
	}

	function Timer() {}

	function BeginState()
	{
		if ( Level.Game.TooManyBots(self) )
		{
			Destroy();
			return;
		}
		if ( (GoalScript != None) && (HoldSpot(GoalScript) == None) )
			FreeScript();
		Enemy = None;
		StopFiring();
		bFrustrated = false;
		BlockedPath = None;
		bInitLifeMessage = false;
		bReachedGatherPoint = false;
		bWasNearObjective = false;
	}

Begin:
	if ( Level.Game.bGameEnded )
		GotoState('GameEnded');
	Sleep(0.2);
TryAgain:
	if ( MPGameInfo(Level.Game) == None )
		destroy();
	else
	{
		Sleep(0.25 + MPGameInfo(Level.Game).SpawnWait(self));
		Level.Game.ReStartPlayer(self);
		Goto('TryAgain');
	}

// RWS CHANGE: Merged from UT2003
MPStart:
	Sleep(0.75 + FRand());
	Level.Game.ReStartPlayer(self);
	Goto('TryAgain');
}

state FindAir
{
ignores SeePlayer, HearNoise, Bump;

	function bool NotifyHeadVolumeChange(PhysicsVolume NewHeadVolume)
	{
		Global.NotifyHeadVolumeChange(newHeadVolume);
		if ( !newHeadVolume.bWaterVolume )
			ChooseAttackMode(false);
		return false;
	}

	function bool NotifyHitWall(vector HitNormal, actor Wall)
	{
		//change directions
		Destination = MINSTRAFEDIST * (Normal(Destination - Pawn.Location) + HitNormal);
		return true;
	}

	function Timer() 
	{
		if ( Enemy != None )
			FireWeaponAt(Enemy);
	}

	function EnemyNotVisible() {}

/* PickDestination()
*/
	function PickDestination(bool bNoCharge)
	{
		Destination = VRand();
		Destination.Z = 1;
		Destination = Pawn.Location + MINSTRAFEDIST * Destination;				
	}

	function BeginState()
	{
		Pawn.bWantsToCrouch = false; 
		bAdjustFromWalls = false;
	}

	function EndState()
	{
		bAdjustFromWalls = true;
	}

Begin:
	PickDestination(false);

DoMove:	
	if ( Enemy == None )
		MoveTo(Destination);
	else
		MoveTo(Destination, Enemy);	
	ChooseAttackMode(false);
}

function SetEnemyReaction(int AlertnessLevel)
{
	ScriptedCombat = FOLLOWSCRIPT_IgnoreEnemies;
	if ( AlertnessLevel == 0 )
	{
		ScriptedCombat = FOLLOWSCRIPT_IgnoreAllStimuli;
		bGodMode = true;
	}
	else
		bGodMode = false;

	if ( AlertnessLevel < 2 )
	{
		Disable('HearNoise');
		Disable('SeePlayer');
		Disable('SeeMonster');
		Disable('NotifyBump');
	}
	else
	{
		Enable('HearNoise');
		Enable('SeePlayer');
		Enable('SeeMonster');
		Enable('NotifyBump');
		if ( AlertnessLevel == 2 )
			ScriptedCombat = FOLLOWSCRIPT_StayOnScript;
		else
			ScriptedCombat = FOLLOWSCRIPT_LeaveScriptForCombat;
	}
}

function SetNewScript(ScriptedSequence NewScript)
{
	Super.SetNewScript(NewScript);
	GoalScript = MpScriptedSequence(NewScript);
	if ( GoalScript != None )
	{
		if ( FRand() < GoalScript.EnemyAcquisitionScriptProbability )
			EnemyAcquisitionScript = GoalScript.EnemyAcquisitionScript;
		else
			EnemyAcquisitionScript = None;
	}
}

function bool ScriptingOverridesAI()
{
	return ( (GoalScript != None) && (ScriptedCombat <= FOLLOWSCRIPT_StayOnScript) );
}

function bool ShouldPerformScript()
{
	if ( GoalScript != None )
	{
		if ( (Enemy != None) && (ScriptedCombat == FOLLOWSCRIPT_LeaveScriptForCombat) )
		{
			SequenceScript = None;
			return false;
		}
		if ( SequenceScript != GoalScript )
			SetNewScript(GoalScript);
		GotoState('Scripting','Begin');
		return true;
	}
	return false;
}

State Scripting
{
	ignores EnemyNotVisible;

	function Restart() {}

	function Timer()
	{
		Super.Timer();
		enable('NotifyBump');
	}

	function CompleteAction()
	{
		ActionNum++;
		if ( Enemy != None )
			ChooseAttackMode(false);
		else
			WhatToDoNext();
	}

	/* UnPossess()
	scripted sequence is over - return control to PendingController
	*/
	function LeaveScripting()
	{
		Global.WhatToDoNext();
	}

	function EndState()
	{
		Super.EndState();
		SetCombatTimer();
		if ( Pawn.Health > 0 )
			Pawn.bPhysicsAnimUpdate = true;
	}

	function AbortScript()
	{
		if ( SequenceScript == GoalScript )
			FreeScript();
		WanderOrCamp(true);
	}
	function SetMoveTarget()
	{
		Super.SetMoveTarget();
		if ( Pawn.ReachedDestination(Movetarget) )
		{
			ActionNum++;
			GotoState('Scripting','Begin');
			return;
		}
		if ( (Enemy != None) && (Focus == Movetarget)
			&& (ScriptedCombat == FOLLOWSCRIPT_StayOnScript) )
			GotoState('Fallback');
	}

	function MayShootAtEnemy()
	{
		if ( Enemy != None )
		{
			Target = Enemy;
			GotoState('Scripting','ScriptedRangedAttack'); 
		}
	}

ScriptedRangedAttack:
	GoalString = "Scripted Ranged Attack";
	Focus = Enemy;
	WaitToSeeEnemy();
	if ( Target != None )
		FireWeaponAt(Target);
}

// allow bots to ragdoll even if you kill them as the last kill
state GameEnded
{
	function BeginState()
	{
		if ( Pawn != None )
		{
			Pawn.Velocity = vect(0,0,0);
			if(Pawn.Health > 0)
			{
				Pawn.SetPhysics(PHYS_None);
				Pawn.bPhysicsAnimUpdate = false;
				Pawn.StopAnimating();
				Pawn.SimAnim.AnimRate = 0;
				Pawn.SetCollision(false,false,false);
			}
			Pawn.UnPossessed();
		}
		if ( !bIsPlayer )
			Destroy();
	}
}

defaultproperties
{
	LastSearchTime=-10000.0
     FovAngle=+00085.000000
	bCanOpenDoors=true
	bCanDoSpecial=true
	 bIsPlayer=true
     bLeadTarget=True
     Aggressiveness=+00000.30000
     BaseAggressiveness=+00000.30000
     CombatStyle=+00000.10000
	 bStasis=false
     RotationRate=(Pitch=3072,Yaw=30000,Roll=2048)
     RemoteRole=ROLE_None
	 PlayerReplicationInfoClass=Class'MultiBase.MpPlayerReplicationInfo'
}

