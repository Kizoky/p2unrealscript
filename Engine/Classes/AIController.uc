//=============================================================================
// AIController, the base class of AI.
//
// Controllers are non-physical actors that can be attached to a pawn to control 
// its actions.  AIControllers implement the artificial intelligence for the pawns they control.  
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class AIController extends Controller
	native;

var		bool		bHunting;			// tells navigation code that pawn is hunting another pawn,
										//	so fall back to finding a path to a visible pathnode if none
										//	are reachable
var		bool		bAdjustFromWalls;	// auto-adjust around corners, with no hitwall notification for controller or pawn
										// if wall is hit during a MoveTo() or MoveToward() latent execution.

var		AIScript MyScript;
var     float		Skill;				// skill, scaled by game difficulty (add difficulty to this value)	

native(510) final latent function WaitToSeeEnemy(); // return when looking directly at visible enemy

// RWS CHANGE: Moved this here so SceneManager could use it
function LeaveScripting();

event PreBeginPlay()
{
	Super.PreBeginPlay();
	if ( bDeleteMe )
		return;

	if ( Level.Game != None )
		Skill += Level.Game.GameDifficulty; 
	Skill = FClamp(Skill, 0, 3);
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();

	// by default destroy bots (let game re-create)
	if ( bIsPlayer )
		Destroy();
}

function Trigger( actor Other, pawn EventInstigator )
{
	TriggerScript(Other,EventInstigator);
}

/* WeaponFireAgain()
Notification from weapon when it is ready to fire (either just finished firing,
or just finished coming up/reloading).
Returns true if weapon should fire.
If it returns false, can optionally set up a weapon change
*/
function bool WeaponFireAgain(float RefireRate, bool bFinishedFire)
{
	if ( Pawn.PressingFire() && (FRand() < RefireRate) )
	{
		Pawn.Weapon.BotFire(bFinishedFire);
		return true;
	}
	StopFiring();
	return false;
}

/* AdjustToss()
return adjustment to Z component of aiming vector to compensate for arc given the target
distance
*/
function float AdjustToss(Ammunition TossedAmmunition, vector Start, vector End)
{
	local vector RecommendedVector,Dir2D;
	local float ReachTime, Dist2D, StartVelZ, EndZ;

	// check for negative gravity
	if ( Pawn.PhysicsVolume.Gravity.Z >= 0 ) 
		return 0;

	RecommendedVector = TossedAmmunition.ProjectileClass.Static.GetTossVelocity(Pawn, rot(0,0,0));

	//determine how long I might be in the air 
	StartVelZ = RecommendedVector.Z;
	RecommendedVector.Z = 0;
	Dir2D = End - Start;
	Dir2D.Z = 0;
	Dist2D = VSize(Dir2D);
	ReachTime = Dist2D/VSize(RecommendedVector); 	
	EndZ = StartVelZ/ReachTime - 0.25f * Pawn.PhysicsVolume.Gravity.Z * ReachTime;	
	return FMin(-1 * EndZ,Dist2D);
}

/* TriggerScript()
trigger AI script (this may enable it)
*/
function bool TriggerScript( actor Other, pawn EventInstigator )
{
	if ( MyScript != None )
	{
		MyScript.Trigger(EventInstigator,pawn);
		return true;
	}
	return false;
}
	
/* DisplayDebug()
list important controller attributes on canvas
*/
function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local int i;
	local string T;

	Super.DisplayDebug(Canvas,YL, YPos);

	Canvas.DrawColor.B = 255;	
	Canvas.DrawText("     Skill "$Skill$" NAVIGATION MoveTarget "$GetItemName(String(MoveTarget))$" PendingMover "$PendingMover$" MoveTimer "$MoveTimer, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("     Destination "$Destination$" Focus "$GetItemName(string(Focus)), false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("     RouteGoal "$GetItemName(string(RouteGoal))$" RouteDist "$RouteDist, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	for ( i=0; i<16; i++ )
	{
		if ( RouteCache[i] == None )
		{
			if ( i > 5 )
				T = T$"--"$GetItemName(string(RouteCache[i-1]));
			break;
		}
		else if ( i < 5 )
			T = T$GetItemName(string(RouteCache[i]))$"-";
	}

	Canvas.DrawText("     RouteCache: "$T, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

function HearPickup(Pawn Other);

function float AdjustDesireFor(Pickup P)
{
	return 0;
}

/* GetFacingDirection()
returns direction faced relative to movement dir

0 = forward
16384 = right
32768 = back
49152 = left
*/
function int GetFacingDirection()
{
	local float strafeMag;
	local vector Focus2D, Loc2D, Dest2D, Dir, LookDir, Y;

	// check for strafe or backup
	Focus2D = FocalPoint;
	Focus2D.Z = 0;
	Loc2D = Pawn.Location;
	Loc2D.Z = 0;
	Dest2D = Destination;
	Dest2D.Z = 0;
	lookDir = Normal(Focus2D - Loc2D);
	Dir = Normal(Dest2D - Loc2D);
	strafeMag = lookDir dot Dir;
	Y = (lookDir Cross vect(0,0,1));
	if ((Y Dot (Dest2D - Loc2D)) < 0)
		return ( 49152 + 16384 * strafeMag );	
	else
		return ( 16384 - 16384 * strafeMag );
}

// AdjustView() called if Controller's pawn is viewtarget of a player
function AdjustView(float DeltaTime)
{
	local float TargetYaw, TargetPitch;
	local rotator OldViewRotation,ViewRotation;

	Super.AdjustView(DeltaTime);
	if( !Pawn.bUpdateEyeHeight )
		return;

	// update viewrotation
	ViewRotation = Rotation;
	OldViewRotation = Rotation;			

	if ( Enemy == None )
	{
		ViewRotation.Roll = 0;
		if ( DeltaTime < 0.2 )
		{
			OldViewRotation.Yaw = OldViewRotation.Yaw & 65535;
			OldViewRotation.Pitch = OldViewRotation.Pitch & 65535;
			TargetYaw = float(Rotation.Yaw & 65535);
			if ( Abs(TargetYaw - OldViewRotation.Yaw) > 32768 )
			{
				if ( TargetYaw < OldViewRotation.Yaw )
					TargetYaw += 65536;
				else
					TargetYaw -= 65536;
			}
			TargetYaw = float(OldViewRotation.Yaw) * (1 - 5 * DeltaTime) + TargetYaw * 5 * DeltaTime;
			ViewRotation.Yaw = int(TargetYaw);

			TargetPitch = float(Rotation.Pitch & 65535);
			if ( Abs(TargetPitch - OldViewRotation.Pitch) > 32768 )
			{
				if ( TargetPitch < OldViewRotation.Pitch )
					TargetPitch += 65536;
				else
					TargetPitch -= 65536;
			}
			TargetPitch = float(OldViewRotation.Pitch) * (1 - 5 * DeltaTime) + TargetPitch * 5 * DeltaTime;
			ViewRotation.Pitch = int(TargetPitch);
			SetRotation(ViewRotation);
		}
	}
}

function SetOrders(name NewOrders, Controller OrderGiver);

function actor GetOrderObject()
{
	return None;
} 

function name GetOrders()
{
	return 'None';
}

/* PrepareForMove()
Give controller a chance to prepare for a move along the navigation network, from
Anchor (current node) to Goal, given the reachspec for that movement.

Called if the reachspec doesn't support the pawn's current configuration.
By default, the pawn will crouch when it hits an actual obstruction. However,
Pawns with complex behaviors for setting up their smaller collision may want
to call that behavior from here
*/
event PrepareForMove(NavigationPoint Goal, ReachSpec Path);

/* WaitForMover()
Wait for Mover M to tell me it has completed its move
*/
function WaitForMover(Mover M)
{
    PendingMover = M;
	bPreparingMove = true;
	Pawn.Acceleration = vect(0,0,0);
}

/* MoverFinished()
Called by Mover when it finishes a move, and this pawn has the mover
set as its PendingMover
*/
function MoverFinished()
{
	if ( PendingMover.MyMarker.ProceedWithMove(Pawn) )
	{
		PendingMover = None;
		bPreparingMove = false;
	}
}

/* UnderLift()
called by mover when it hits a pawn with that mover as its pendingmover while moving to its destination
*/
function UnderLift(Mover M)
{
	local NavigationPoint N;

	bPreparingMove = false;
	PendingMover = None;

	// find nearest lift exit and go for that
	if ( (MoveTarget != None) && MoveTarget.IsA('LiftCenter') )
		for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
			if ( N.IsA('LiftExit') && (LiftExit(N).LiftTag == M.Tag)
				&& ActorReachable(N) )
			{
				MoveTarget = N;
				return;
			}
}

defaultproperties
{
	 bAdjustFromWalls=true
	 PlayerReplicationInfoClass=Class'Engine.PlayerReplicationInfo'
     AttitudeToPlayer=ATTITUDE_Hate
     bCanOpenDoors=true
	 bCanDoSpecial=true
	 MinHitWall=-0.5f
}