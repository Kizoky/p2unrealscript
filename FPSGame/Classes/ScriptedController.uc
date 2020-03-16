///////////////////////////////////////////////////////////////////////////////
// ScriptedController
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Taken directly from epic's code. 
// The only change is we want this to be a native class
//
// Put RWS stuff in FPSController.
//
///////////////////////////////////////////////////////////////////////////////
class ScriptedController extends AIController
	native;

var controller PendingController;	// controller which will get this pawn after scripted sequence is complete
var int ActionNum;
var int AnimsRemaining;
var ScriptedSequence SequenceScript;
var LatentScriptedAction CurrentAction;
var Action_PLAYANIM CurrentAnimation;
var bool bBroken;
var bool bShootTarget;
var bool bShootSpray;
var bool bPendingShoot;
var bool bFakeShot;			// FIXME - this is currently a hack
var bool bUseScriptFacing;
var Actor ScriptedFocus;
var PlayerController MyPlayerController;
var int NumShots;
var name FiringMode;
var int IterationCounter;
var int IterationSectionStart;
var int SongHandle;
// RWS CHANGE: Added delayed deletion mechanism to avoid crashes.
// The problem was that in certain situations, such as saving a
// game, garbage collection would cause the deleted controller
// to be fully destroyed.  Unfortunately, this would occur while
// script the controller called was executing, so when that script
// tried to return control to the controller, a crash would occur.
// By delaying the actual delete and adding a few checks for this
// flag, the whole process becomes safe.
var bool bPendingDestroy;	

// RWS CHANGE: Allow a script in progress to "short circuit" to another
// script if damaged or peed on, for interactive cutscenes.
var ScriptedSequence ShortCircuitScript;

// Same as super, but if we have a short-circuit script set up, jump to that immediately.
function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	Super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, DamageType, Momentum);
	ShortCircuit();
}
// A simple short-circuit function we can call from anything that doesn't cause damage,
// but we want to short-circuit the script anyway. Such as urine.
function ShortCircuit()
{
	if (ShortCircuitScript != None)
	{
		// Turn off any latent scripts we have. MAY NOT WORK PROPERLY
		if (CurrentAction != None)
			Timer();	// force immediate completion
		SetNewScript(ShortCircuitScript);
		ShortCircuitScript = None;
	}
}

// RWS CHANGE: If you're really, only a ScriptedController (you got made to control a pawn
// for a few moments then you went back to your normal LambController-derived activities) 
// then this is true. Use it to do very specific things that LambController would normally
// override. LambController return false for this function.
function bool UsingScript()
{
	return true;
}

// RWS CHANGE: When this gets destroyed, go to a separate state so nothing else can happen
function Destroyed()
	{
	if(UsingScript())
		{
		if (!bDeleteMe)
			GotoState('Graveyard');
		}
	Super.Destroyed();
	}

// RWS CHANGE: Added this to help interpret the scripting insanity
function Possess(Pawn aPawn)
	{
//	Log(self @ "Possess(): Pawn="$aPawn);
	Super.Possess(aPawn);
	}

function TakeControlOf(Pawn aPawn)
{
	if ( Pawn != aPawn )
	{
		aPawn.PossessedBy(self);
		Pawn = aPawn;
	}
	GotoState('Scripting');
}

function SetEnemyReaction(int AlertnessLevel);

function DestroyPawn()
{
	if ( Pawn != None )
		Pawn.Destroy();
	GotoState('DestroySoon');
}

function Pawn GetMyPlayer()
{
	if ( (MyPlayerController == None) || (MyPlayerController.Pawn == None) )
		ForEach DynamicActors(class'PlayerController',MyPlayerController)
			if ( MyPlayerController.Pawn != None )
				break;
	if ( MyPlayerController == None )
		return None;
	return MyPlayerController.Pawn;
}

function Pawn GetInstigator()
{
	if ( Pawn != None )
		return Pawn;
	return Instigator;
}

function Actor GetSoundSource()
{
	if ( Pawn != None )
		return Pawn;
	return SequenceScript;
}

function bool CheckIfNearPlayer(float Distance)
{
	local Pawn MyPlayer;

	MyPlayer = GetMyPlayer();
	return ( (MyPlayer != None) && (VSize(Pawn.Location - MyPlayer.Location) < Distance+CollisionRadius+MyPlayer.CollisionRadius ) && Pawn.PlayerCanSeeMe() );
}

function SetNewScript(ScriptedSequence NewScript)
{
	MyScript = NewScript;
	SequenceScript = NewScript;
	ActionNum = 0;
	Focus = None;
	CurrentAction = None;
	CurrentAnimation = None;
	ScriptedFocus = None;
	Pawn.SetWalking(false);
	Pawn.ShouldCrouch(false);
	SetEnemyReaction(3);
	SequenceScript.SetActions(self);
}

function ClearAnimation()
{
	AnimsRemaining = 0;
	bControlAnimations = false;
	CurrentAnimation = None;
	Pawn.PlayWaiting();
}

function int SetFireYaw(int FireYaw)
{
	FireYaw = FireYaw & 65535;

	if ( (Abs(FireYaw - (Rotation.Yaw & 65535)) > 8192)
		&& (Abs(FireYaw - (Rotation.Yaw & 65535)) < 57343) )
	{
		if ( FireYaw ClockwiseFrom Rotation.Yaw )
			FireYaw = Rotation.Yaw + 8192;
		else
			FireYaw = Rotation.Yaw - 8192;
	}
	return FireYaw;
}

function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int AimError)
{
	local rotator LookDir;

	// make sure bot has a valid target
	if ( Target == None )
		Target = ScriptedFocus;
	if ( Target == None )
	{
		Target = Enemy;
		if ( Target == None )
		{
			bFire = 0;
			bAltFire = 0;
			return Pawn.Rotation;
		}
	}
	LookDir = rotator(Target.Location - projStart);
	LookDir.Yaw = SetFireYaw(LookDir.Yaw);
	return LookDir;
}

// RWS CHANGE: Moved this to AIController so SceneManager could use it
//function LeaveScripting();

state Scripting
{
	function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
	{
		Super.DisplayDebug(Canvas,YL,YPos);
		Canvas.DrawText("AIScript "$SequenceScript$" ActionNum "$ActionNum, false);
		YPos += YL;
		Canvas.SetPos(4,YPos);
		CurrentAction.DisplayDebug(Canvas,YL,YPos);
	}

	/* UnPossess()
	scripted sequence is over - return control to PendingController
	*/
	function UnPossess()
	{
		// RWS CHANGE: Cleaned this up
		if (Pawn != None)
		{
			Log(self @ "Scripting.Unpossess(): Pawn="$Pawn$" PendingController="$PendingController);
			Pawn.UnPossessed();
			if (PendingController != None
				&& Pawn.Health > 0)
			{
				PendingController.bStasis = false;
				PendingController.Possess(Pawn);
			}
		}
		Pawn = None;
		PendingController = None;
		GotoState('DestroySoon');
	}

	function LeaveScripting()
	{
		UnPossess();
	}

	function InitForNextAction()
	{
		SequenceScript.SetActions(self);
		if ( bPendingDestroy )
		{
			LeaveScripting();
			return;
		}

		if ( CurrentAction == None )
		{
			LeaveScripting();
			return;
		}
		MyScript = SequenceScript;
		if ( CurrentAnimation == None )
			ClearAnimation();
	}

	function Trigger( actor Other, pawn EventInstigator )
	{
		if ( CurrentAction.CompleteWhenTriggered() )
			CompleteAction();
	}

	function UnTrigger( actor Other, pawn EventInstigator )
	{
		if ( CurrentAction.CompleteWhenUnTriggered() )
			CompleteAction();
	}

	function Timer()
	{
		if ( CurrentAction.WaitForPlayer() && CheckIfNearPlayer(CurrentAction.GetDistance()) )
			CompleteAction();
		else if ( CurrentAction.CompleteWhenTimer() )
			CompleteAction();
	}

	function AnimEnd(int Channel)
	{
		if ( CurrentAction.CompleteOnAnim(Channel) )
		{
			CompleteAction();
			return;
		}
		if ( Channel == 0 )
		{
			if ( (CurrentAnimation == None) || !CurrentAnimation.PawnPlayBaseAnim(self,false) )
				ClearAnimation();
		}
		else 
		{
			// FIXME - support for CurrentAnimation play on other channels
			Pawn.AnimEnd(Channel);
		}
	}

	function CompleteAction()
	{
		ActionNum++;
		GotoState('Scripting','Begin');
	}

	function SetMoveTarget()
	{
		local Actor NextMoveTarget;

		Focus = ScriptedFocus;
		NextMoveTarget = CurrentAction.GetMoveTargetFor(self);
		if ( NextMoveTarget == None )
		{
			GotoState('Broken');
			return;
		}
		if ( Focus == None )
			Focus = NextMoveTarget;
		MoveTarget = NextMoveTarget;
		if ( !ActorReachable(MoveTarget) )
		{
			MoveTarget = FindPathToward(MoveTarget);
			if ( Movetarget == None )
			{
				warn(self@"SetMoveTarget"@MoveTarget@"FAILED - No path - Aborting script");
				AbortScript();
				return;
			}
			if ( Focus == NextMoveTarget )
				Focus = MoveTarget;				
		}
	}

	function AbortScript()
	{
		LeaveScripting();
	}
	/* WeaponFireAgain()
	Notification from weapon when it is ready to fire (either just finished firing,
	or just finished coming up/reloading).
	Returns true if weapon should fire.
	If it returns false, can optionally set up a weapon change
	*/
	function bool WeaponFireAgain(float RefireRate, bool bFinishedFire)
	{
		if ( Pawn.bIgnorePlayFiring )
		{
			Pawn.bIgnorePlayFiring = false;
			return false;
		}
		if ( NumShots < 0 )
		{
			bShootTarget = false;
			bShootSpray = false;
			StopFiring();
			return false;
		}
		if ( bShootTarget && (ScriptedFocus != None) && !ScriptedFocus.bDeleteMe )
		{
			Target = ScriptedFocus;
			if ( (!bShootSpray && ((Pawn.Weapon.RefireRate() < 0.99) && !Pawn.Weapon.CanAttack(Target)))
				|| !Pawn.Weapon.BotFire(bFinishedFire,FiringMode) )
			{
				Enable('Tick'); //FIXME - use multiple timer for this instead
				bPendingShoot = true;
				return false;
			}
			if ( NumShots > 0 )
			{
				NumShots--;
				if ( NumShots == 0 )
					NumShots = -1;
			}
			return true;
		}
		StopFiring();
		return false;
	}

	function Tick(float DeltaTime)
	{
		if ( bPendingShoot )
		{
			bPendingShoot = false;
			MayShootTarget();
		}
		if ( !bPendingShoot
			&& ((CurrentAction == None) || !CurrentAction.StillTicking(self,DeltaTime)) )
			disable('Tick');
	}

	function MayShootAtEnemy();

	function MayShootTarget()
	{
		WeaponFireAgain(0,false);
	}

	function EndState()
	{
		// RWS CHANGE: Shut down properly before leaving this state
		if (Pawn != None)
		{
			LeaveScripting();
		}

		bUseScriptFacing = true;
		bFakeShot = false;
	}

Begin:
	InitforNextAction();
	if ( bBroken )
	{
		warn(Pawn$" Scripted Sequence BROKEN "$SequenceScript$" ACTION "$CurrentAction);
		GotoState('Broken');
	}
	if ( CurrentAction.TickedAction() )
		enable('Tick');
	if ( !bShootTarget )
	{
		bFire = 0;
		bAltFire = 0;
	}
	else
	{
		Pawn.Weapon.RateSelf();
		if ( bShootSpray )
			MayShootTarget();
	}
	if ( CurrentAction.MoveToGoal() )
	{
		Pawn.SetMovementPhysics();
		WaitForLanding();
KeepMoving:
		SetMoveTarget();
		MayShootTarget();
		MoveToward(MoveTarget, Focus,,,,Pawn.bIsWalking);
		if ( (MoveTarget != CurrentAction.GetMoveTargetFor(self))
			|| !Pawn.ReachedDestination(CurrentAction.GetMoveTargetFor(self)) )
			Goto('KeepMoving');
		// Make him stop, otherwise, after a MoveToPoint, he'll still be animating as
		// walking.
		Pawn.Acceleration = vect(0,0,0);
		CompleteAction();
	}
	else if ( CurrentAction.TurnToGoal() )
	{
		Pawn.SetMovementPhysics();
		Focus = CurrentAction.GetMoveTargetFor(self);
		if ( Focus == None )
			FocalPoint = Pawn.Location + 1000 * vector(SequenceScript.Rotation);
		FinishRotation();
		CompleteAction();
	}
	else
	{
		//Pawn.SetPhysics(PHYS_RootMotion);
		Pawn.Acceleration = vect(0,0,0);
		Focus = ScriptedFocus;
		if ( !bUseScriptFacing )
			FocalPoint = Pawn.Location + 1000 * vector(Pawn.Rotation);
		else if ( Focus == None )
		{
			MayShootAtEnemy();
			FocalPoint = Pawn.Location + 1000 * vector(SequenceScript.Rotation);
		}
		FinishRotation();
		MayShootTarget();
	}
}

// Broken scripted sequence - for debugging
State Broken
{
Begin:
	warn(Pawn$" Scripted Sequence BROKEN "$SequenceScript$" ACTION "$CurrentAction);
	Pawn.bPhysicsAnimUpdate = false;
	Pawn.StopAnimating();
	if ( GetMyPlayer() != None )
		PlayerController(GetMyPlayer().Controller).SetViewTarget(Pawn);
}

State DestroySoon
	{
	function BeginState()
		{
		bPendingDestroy = true;
		}
Begin:
	Sleep(0.5);
	Destroy();
	}

// RWS CHANGE
State Graveyard
{
	// Don't do anything here, this state merely exists to get the controller out
	// of the scripting state so that nothing else can happen once it gets destroyed.
}

defaultproperties
{
	bUseScriptFacing=true
	IterationSectionStart=-1
}
