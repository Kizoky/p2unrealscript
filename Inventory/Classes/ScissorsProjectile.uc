///////////////////////////////////////////////////////////////////////////////
// ScissorsProjectile.
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This are the actual scissors that goes flying through the air.
//
// In single player mode when the finally hit a solid surface, they
// stick and make a pickup.
//
// In MP though we found after extensive testing that picking up single 
// scissors pickups was really annoying because we were constantly and unwantedly
// swtiching to them. For people that wanted autoswap on pickup turned on, this
// was really annoying. I tried to make those pickups not autoswap on pickup,
// but because the decision is made in weapon with no knowledge of the pickup,
// this was really hard. So instead they just go away whenever they hit anything.
//
///////////////////////////////////////////////////////////////////////////////
class ScissorsProjectile extends P2Projectile;

var bool    bIsSpinner;			// Allowed to spin and bounce off things
var byte	BounceCount;		// Times you've bounced, and it's counted
var byte	BounceMax;			// Max times to bounce till you stick. You'll stick on this number bounce
var Sound	ScissorsWallStick;
var Sound	ScissorsBodyStick;
var Sound	ScissorsBounce;
var ScissorsWake swake;
var bool	bRecordBounce;		// If this is false, it's too allow it to bounce in a tight area
								// for a while before it counts it. If it's true and it bounces	
								// it'll count against the number of times it can bounce before it sticks.
								// This allows a longer time to stay alive in tight areas.

const UPDATE_ROTATION	=	0.2;
const BOUNCE_RESET_TIME	=	1.5;
var float TimeCreated;
const MIN_TIME_TO_BOUNCE = 0.01;

///////////////////////////////////////////////////////////////////////////////
// Attach the blurry effect
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	TimeCreated = Level.TimeSeconds;

	if ( Level.NetMode != NM_DedicatedServer)
	{
		if(Level.Game == None
			|| !Level.Game.bIsSinglePlayer)
			swake = spawn(class'ScissorsWake',self);
		else
			// Send player as owner so it will keep up in slomo time
			swake = spawn(class'ScissorsWake',Instigator);
	}

	if(swake != None)
		swake.SetBase(self);
	// Setup speed/orientation/timer
	Velocity = GetThrownVelocity(Instigator, Rotation, 0.4);
	UpdateRotation();
	SetTimer(UPDATE_ROTATION, true);
}

///////////////////////////////////////////////////////////////////////////////
// Remove blurry effect
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	if(swake != None)
	{
		swake.Destroy();
		swake = None;
	}
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Recalc the rotation from the velocity
///////////////////////////////////////////////////////////////////////////////
simulated function UpdateRotation()
{
	local vector vel;
	local vector norm;
	local vector rot;

	SetRotation(Rotator(-Velocity));
	
//	vel = Normal(Velocity);
//	norm = vect(0.0, 0.3, 1.0);
//	rot = vect(0.3, 0.0, 0.0);
//	log(self$" vel "$vel$" | rot*vel "$Rotator(rot)+Rotator(vel));
//	SpriteEmitter(swake.Emitters[0]).ProjectionNormal.X = 0.5*vel.y;
//	SpriteEmitter(swake.Emitters[0]).ProjectionNormal.Y = 0.5*vel.x;
//	SpriteEmitter(swake.Emitters[0]).ProjectionNormal.Z = 1.0;
	
	/*
	SpriteEmitter(swake.Emitters[0]).ProjectionNormal.X = vel.y;
	SpriteEmitter(swake.Emitters[0]).ProjectionNormal.Y = vel.x;
	SpriteEmitter(swake.Emitters[0]).ProjectionNormal.Z = vel.z;
	*/
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	UpdateRotation();
}


///////////////////////////////////////////////////////////////////////////////
// Take damage or be force around
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
{
	local float impulse;
	local SparkHit spark1;
	local vector norm;
	
	if (Level.TimeSeconds < TimeCreated + MIN_TIME_TO_BOUNCE)
		return;

	// Only some things effect us
	if(ClassIsChildOf(damageType, class'BulletDamage')
		|| ClassIsChildOf(damageType, class'BludgeonDamage'))
	{
		// Make sure the one that reflected it up gets the points for doing it.
		TransferInstigator(InstigatedBy);

		SetPhysics(PHYS_Projectile);
		// Make sure it can move
		bBounce=true;

		impulse = VSize(Momentum);
		norm = Normal(Momentum);
		Velocity=(impulse*norm + (0.1*impulse)*VRand());
		// Throw off some sparks from the hit
		spark1 = spawn(class'Fx.SparkHitProjectile',Owner,,Location,rotator(Hitlocation - location));
		// make a ricochet noise
		spark1.PlaySound(ScissorsBounce,,,,,GetRandPitch());
	}
}

///////////////////////////////////////////////////////////////////////////////
// Bounces off walls
///////////////////////////////////////////////////////////////////////////////
simulated function HitWall( vector HitNormal, actor Wall )
{
	local rotator userot;
	local SparkHit spark1;
	local SmokeHitPuffGeneric smoke1;
	local ScissorsPickup sp;
	local bool bDoBounce;
	
	if (Level.TimeSeconds < TimeCreated + MIN_TIME_TO_BOUNCE)
		return;

		// Die on doors, so they don't get stuck as much (only in MP games)
	if((Level.Game == None
			|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		&& DoorMover(Wall) != None)
	{
		if(Role == ROLE_Authority)
		{
			// Throw off some sparks from the stick
			spark1 = spawn(class'Fx.SparkHitProjectile',Owner,,Location,rotator(HitNormal));
			
			spark1.PlaySound(ScissorsWallStick,,1.0,false,200.0,GetRandPitch());
		}
		Destroy();
	}
	else if(bBounce == true)
	{
		if(bRecordBounce)
		{
			BounceCount++;
			bRecordBounce=false;
		}

		// If they've bounced enough, just make them stick in the wall
		// unless the wall isn't static, in which case--keep bouncing
		if(BounceCount >= BounceMax
			&& Wall.bStatic)
		{
			if(Role == ROLE_Authority)
			{
				// Only make them turn into single pickups 
				// in single player mode
				if(FPSGameInfo(Level.Game).bIsSinglePlayer)
				{
					// Turn into a pickup in that orientation
					sp = spawn(class'ScissorsPickupSingle',Owner,,Location,Rotation);
					if(sp != None)
					{

						// Move you in some more
						sp.SetLocation(Location-(2*sp.CollisionRadius*HitNormal));
						sp.bRecordAfterPickup=false;
						// Make sure it's ready to be picked up
						sp.GoToState( 'Pickup' );
					}
				}

				// Throw off some sparks from the stick
				spark1 = spawn(class'Fx.SparkHitProjectile',Owner,,Location,rotator(HitNormal));
				
				spark1.PlaySound(ScissorsWallStick,,1.0,false,200.0,GetRandPitch());

				smoke1 = Spawn(class'Fx.SmokeHitPuffGeneric',Owner,,Location,rotator(HitNormal));
			}
			else
				PlaySound(ScissorsWallStick,,1.0,false,200.0,GetRandPitch());

			// Destroy ourselves after we hit something, whether we made a pickup or not
			Destroy();
		}
		else
			bDoBounce=true;

		if(bDoBounce)
		// if not, then make them bounce without losing any energy
		{
			Velocity = Velocity - 2 * HitNormal * (Velocity Dot HitNormal);
			// Face the direction you're moving
			UpdateRotation();
			SetTimer(UPDATE_ROTATION, true);

			if(Role == ROLE_Authority)
			{
				// Throw off some sparks from the hit
				spark1 = spawn(class'Fx.SparkHitScissors',Owner,,Location,rotator(HitNormal));
				// make a ricochet noise
				//spark1.PlaySound(ScissorsBounce,,1.0,false,200.0,GetRandPitch());
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Doesn't hurt anyone related to us, or ourselves, but will hurt others.
///////////////////////////////////////////////////////////////////////////////
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local name attachb;
	local AnimNotifyActor sp;
	local coords checkcoords;
	local P2Pawn hitpawn;
	local Rotator rot;
	
	if (Pawn(Other) == None
		&& Level.TimeSeconds < TimeCreated + MIN_TIME_TO_BOUNCE)
		return;
	
	// Ignore bounces on instigator
	if (Other == Instigator)
		return;

	if ( !RelatedToMe(Pawn(Other)) )
	{
		// Don't bounce off windows, break them
		if(Window(Other) != None)
			Other.Bump(self);
		else if(Pawn(Other) != None
			&& bBounce)
		{
/*
		Failed attempt to get scissors to stick nicely in person. Had trouble making the
		relative rotation of the scissors be preserved once it was attached to a bone.

check newspaper

lower all by 20

75 head

belly 0.25

bottom of crotch 0.0

knees -0.25

-0.5 feet

90 male01 head

80 male01 neck

70 male01 spine2/male01 r upperarm

60 male01 spine1/male01 r forearm

50 male01 spine/male01 r hand

40-20 male01 r thigh

20 male01 r calf

10 male02 r foot



			hitpawn = P2Pawn(Other);
			if(hitpawn != None)
			{
				attachb = hitpawn.FindBodyPart(HitLocation);

				sp = spawn(class'AnimNotifyActor',,,HitLocation,Rotation);
				sp.SetStaticMesh(StaticMesh);
//				sp.AmmoGiveCount = 1;	// only get one back
				sp.SetCollisionSize(CollisionRadius/2, CollisionHeight/2);
//				sp.bRecordAfterPickup=false;

				checkcoords = hitpawn.GetBoneCoords(attachb);
				rot = hitpawn.GetBoneRotation(attachb);
				log(self$" bone rotation "$rot$" current rotation "$Rotation$" pawn rotation "$Other.Rotation);
				//rot = Other.Rotation + rot;
//				rot.Roll = -rot.Roll;
//				rot.Pitch= -rot.Pitch;
//				rot.Yaw  = -rot.Yaw;
rot.Roll=Rotation.Roll;
rot.Roll = rot.Roll&65535;
rot.Pitch=Rotation.Pitch;
rot.Pitch = rot.Pitch&65535;
rot.Yaw=Rotation.Yaw;
rot.Yaw = rot.Yaw&65535;


				log(self$" result "$rot);

				hitpawn.AttachToBone(sp, attachb);
				sp.SetRelativeRotation(rot);
				//sp.SetRelativeLocation(HitLocation - checkcoords.Origin);

				Destroy();
				return;
			}
*/
			PlaySound(ScissorsBodyStick);
			// Balance damage differently for MP vs SP
			if(Level.NetMode == NM_Standalone)
//			if(Level.Game != None
//				&& FPSGameInfo(Level.Game).bIsSinglePlayer)
				Other.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			else
				Other.TakeDamage( DamageMP, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			Destroy();
		}
		// bounce off other stuff if you can
		else //if(BounceCount < BounceMax)
		{
			// only hurt things if you're moving
			if(bBounce)
			{
				PlaySound(ScissorsWallStick,,,,1.0);
				// Balance damage differently for MP vs SP
				if(Level.NetMode == NM_Standalone)
//				if(Level.Game != None
//					&& FPSGameInfo(Level.Game).bIsSinglePlayer)
					Other.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
				else
					Other.TakeDamage( DamageMP, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			}

			Destroy();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Blow up and generate effects
///////////////////////////////////////////////////////////////////////////////
simulated function Explode(vector HitLocation, vector HitNormal)
{
 	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Flying through the air
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto simulated state Moving
{
Begin:
	Sleep(BOUNCE_RESET_TIME);
	bRecordBounce=true;
	Goto('Begin');
}

defaultproperties
{
	 MyDamageType=class'CuttingDamage'
     Speed=2000.000000
     MaxSpeed=3000.000000
     Damage=25.000000
	 DamageMP=51
	 DamageRadius=0
     MomentumTransfer=50000
	 bRotatetoDesired=false
	 bFixedRotationDir=true
	 DrawType=DT_StaticMesh
	 StaticMesh=StaticMesh'stuff.stuff1.scissors'
	 CollisionHeight=18
	 CollisionRadius=18
     AmbientGlow=64
     bBounce=true
	 VelDampen=1.0
	 RotDampen=1.0
	 StartSpinMag=350000
	 Acceleration=(Z=-100)
	 BounceMax=1
	 TossZ=+100.0
	 ScissorsBodyStick=Sound'WeaponSounds.scissors_bodystick'
	 ScissorsWallStick=Sound'WeaponSounds.scissors_wallstick'
	 ScissorsBounce=Sound'WeaponSounds.scissors_bounce'
	 bRecordBounce=true
	 bProjTarget=true
	 bUseCylinderCollision=true
}
