/////////////////////////////////////////////////////////////////////////////////////
//MrD - May/22/14 - Started BeanBag Weapon.. "Non lethal weapon for crowd control"
//BeanBagGunProjectile - Actual Bean Bag projectile.
/////////////////////////////////////////////////////////////////////////////////////
class BeanBagGunProjectile extends LauncherProjectile;

var bool    bIsSpinner;			// Allowed to spin and bounce off things
var byte	BounceCount;		// Times you've bounced, and it's counted
var byte	BounceMax;			// Max times to bounce till you stick. You'll stick on this number bounce
var Sound	ScissorsWallStick;
var Sound	ScissorsBodyStick;
var Sound	ScissorsBounce;
//var Chaingunv2Wake swake; 
var bool	bRecordBounce;		// If this is false, it's too allow it to bounce in a tight area
								// for a while before it counts it. If it's true and it bounces
								// it'll count against the number of times it can bounce before it sticks.
								// This allows a longer time to stay alive in tight areas.
var class<Emitter> HitEffect;

const UPDATE_ROTATION	=	0.2;
const BOUNCE_RESET_TIME	=	1.5;

///////////////////////////////////////////////////////////////////////////////
// Attach the blurry effect
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	// Speed up in enhanced game
	if (P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime()
		&& Instigator.Controller.bIsPlayer)
		Speed *= 2;

	if ( Level.NetMode != NM_DedicatedServer)
	//{
		//if(Level.Game == None
		//	|| !Level.Game.bIsSinglePlayer)
			//swake = spawn(class'Chaingunv2Wake',self);
		//else
			// Send player as owner so it will keep up in slomo time
			//swake = spawn(class'Chaingunv2Wake',Instigator);
	//}

	//if(swake != None)
		//swake.SetBase(self);
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
	//if(swake != None)
	//{
	//	swake.Destroy();
	//	swake = None;
	//}
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
// Doesn't hurt anyone related to us, or ourselves, but will hurt others.
///////////////////////////////////////////////////////////////////////////////
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local name attachb;
	local AnimNotifyActor sp;
	local coords checkcoords;
	local P2Pawn hitpawn;
	local Rotator rot;

	if ( !RelatedToMe(Pawn(Other)) )
	{
		// Don't bounce off windows, break them
		if(Window(Other) != None)
			Other.Bump(self);
		else if(Pawn(Other) != None
			&& bBounce)
		{
			// Balance damage differently for MP vs SP
			if(Level.NetMode == NM_Standalone)
//			if(Level.Game != None
//				&& FPSGameInfo(Level.Game).bIsSinglePlayer)
				Other.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			else
				Other.TakeDamage( DamageMP, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			log(self@"play"@ScissorsBodyStick);
			Spawn(HitEffect,,,HitLocation).PlaySound(ScissorsBodyStick,,,,TransientSoundRadius,GetRandPitch());
			Destroy();
		}
		// bounce off other stuff if you can
		else //if(BounceCount < BounceMax)
		{
			// only hurt things if you're moving
			if(bBounce)
			{
				// Balance damage differently for MP vs SP
				if(Level.NetMode == NM_Standalone)
//				if(Level.Game != None
//					&& FPSGameInfo(Level.Game).bIsSinglePlayer)
					Other.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
				else
					Other.TakeDamage( DamageMP, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			}
			log(self@"play"@ScissorsWallStick);
			Spawn(HitEffect,,,HitLocation).PlaySound(ScissorsWallStick,,,,TransientSoundRadius,GetRandPitch());
			Destroy();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Blow up and generate effects
///////////////////////////////////////////////////////////////////////////////
simulated function GenExplosion(vector HitLocation, vector HitNormal, Actor Other)
{
	local RocketExplosion exp;
	local vector WallHitPoint, OrigLoc;
	local Actor ViewThing;
	
	if(Other != None
		&& Other.bStatic)
	{
		// Make sure the force of this explosion is all the way against the wall that
		// we hit
		OrigLoc = HitLocation;
		WallHitPoint = HitLocation;
		if(Trace(HitLocation, HitNormal, WallHitPoint, HitLocation) == None)
		{
			HitLocation = OrigLoc;
			WallHitPoint = OrigLoc;
		}
	}
	else
		WallHitPoint = HitLocation;

	//exp = spawn(class'PL_TempScript.BeanBagGunExplosion',GetMaker(),,HitLocation + ExploWallOut*HitNormal);
	log(self@"play"@ScissorsWallStick);
	Spawn(HitEffect,,,HitLocation + ExploWallOut*HitNormal).PlaySound(ScissorsWallStick,,,,TransientSoundRadius,GetRandPitch());
	/*
	exp.CheckForHitType(Other);
	exp.ShakeCamera(exp.ExplosionDamage);
	exp.ForceLocation = WallHitPoint;
	*/

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
	BounceMax=2
	ScissorsWallStick=Sound'PL_BeanBagSounds.BeanBag_HitWall'
	ScissorsBodyStick=Sound'PL_BeanBagSounds.BeanBag_HitBody'
	bRecordBounce=True
	VelDampen=0.000000
	RotDampen=0.000000
	StartSpinMag=100.000000
	//DamageMP=75.000000
	speed=5000.000000
	MaxSpeed=20000.000000
	Damage=50.000000
	MomentumTransfer=50000.000000
	Acceleration=(Z=-100.000000)	 
	MyDamageType=Class'BeanBagGunDamage'
	StaticMesh=StaticMesh'MrD_PL_Mesh.Weapons.BeanBag_Projectile'
	DrawScale=4.5
	AmbientGlow=128
	CollisionRadius=16.000000
	CollisionHeight=16.000000
	bBounce=True
	HitEffect=class'PistolPuff'
	TransientSoundRadius=256
	SoundVolume=255
}
