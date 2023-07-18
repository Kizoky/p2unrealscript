///////////////////////////////////////////////////////////////////////////////
// Cat rocket
//
// Dead cat getting shot off the end of a weapon
//
///////////////////////////////////////////////////////////////////////////////
class CatRocket extends P2Projectile;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var	P2Emitter Trail;
var Sound   CatStartFlying;
var Sound   CatFlying;
var bool	bExploded;
// cheat stuff only
var bool    bDoBounces;
var int		BounceCount;
var Sound BouncingSound;
// xPatch: AW-Style Cat-Rocket
var bool    bCrazyCat;		
var bool	bSpawned;
var class<AnimalPawn> CrazyCatClass;


///////////////////////////////////////////////////////////////////////////////
// CONSTS
///////////////////////////////////////////////////////////////////////////////
const PELVIS_BONE	=	'Bip01 Pelvis';
const HIT_DAMAGE	=	15;
const BOUNCE_MAX	=	20;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	local vector Dir;

	Super.PostBeginPlay();

	Dir = vector(Rotation);
	Velocity = speed * Dir;
	if(class'P2Player'.static.BloodMode())
	{
		Trail = Spawn(class'BloodChunksDripping ',self);
		AttachToBone(Trail, PELVIS_BONE);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	// Don't call explode here, even though we'd like to explode them if
	// they timed out of existence, rather than just delete them. If we call
	// it here though, we get an infinitely recursing loop.
	//Explode(Location, Normal(Velocity));

	if(Trail != None)
	{
		DetachFromBone(Trail);
		Trail.Destroy();
		Trail = None;
	}

	// Stop all sounds
	PlaySound(CatFlying, SLOT_Misc, 0.01, false, 100.0, 1.0);

	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Bounces off anything that's not your target, in a reflective manner
// and record the bounce. 
// This only for cheat mode, for the cats.
///////////////////////////////////////////////////////////////////////////////
function BounceOffSomething( vector HitNormal, actor Wall )
{
	local vector newhit, newnormal, EndPt;
	local bool bStopped;
	local float speed;
	local SparkHit spark1;
	
	// Update velocity
	Velocity = (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));// + (speed*Frand()*HitNormal);

	// Update direction
	SetRotation(rotator(Velocity));

	// Draw a blood splat on the ground
	if(class'P2Player'.static.BloodMode())
	{
		spawn(class'BloodMachineGunSplatMaker',self,,Location,rotator(HitNormal));
	}
	// Make a sound
	PlaySound(BouncingSound, , 1.0, , , 0.96 + FRand()*0.08);

	// Record that it happened
	BounceCount++;
}

auto state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		local P2Pawn HitPawn;
		local PersonController pcont;
		local DeadCatHitGuyMarker ADanger;
		
		// Hurt it, as we hit it
		Other.TakeDamage(HIT_DAMAGE, Instigator, Location, Mass*Velocity, class'SmashDamage');

		HitPawn = P2Pawn(Other);
		// if we hit a person, make them throw up and tell others
		if( HitPawn != None)
		{
			pcont = PersonController(HitPawn.Controller);

			// Make this guy throw up 
			if(pcont != None)
			{
				pcont.SetAttacker(Instigator);
				// definitely puke
				pcont.CheckToPuke(, true);
			}

			// Tell everyone else you got hit by a flying, dead cat
			ADanger = spawn(class'DeadCatHitGuyMarker',,,HitLocation);
			ADanger.CreatorPawn = P2Pawn(Instigator);
			ADanger.OriginActor = HitPawn;
			// This will cause people to see if they noticed and decide what to do
			ADanger.NotifyAndDie();

		}

		// Break through windows
		if(Window(Other) != None)
		{
			Other.Bump(self);
		}
		else if (Other != instigator) // explode on everything else
			Explode(HitLocation,Normal(HitLocation-Other.Location));
	}

	simulated function HitWall (vector HitNormal, actor Wall)
	{
		// Bounce off static things, if you're supposed to
		if(BounceCount < BOUNCE_MAX
			&& bDoBounces)
		{
			BounceOffSomething(HitNormal, Wall);
		}
		else 
			Super.HitWall(HitNormal, Wall);
	}

	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local CatExplosion exp;
		local Rotator NewRot;
		
		if(!bExploded)
		{
			// xPatch:
			if(bCrazyCat)
			{
				SpawnCrazyCat(HitLocation, HitNormal);
				return;
			}
			// End
			
			if(class'P2Player'.static.BloodMode())
			{
				exp = spawn(class'CatExplosion',,,HitLocation);
				exp.FitToNormal(HitNormal);

				NewRot = Rotator(-HitNormal);
				NewRot.Roll=(65536*FRand());
				spawn(class'BloodMachineGunSplat',self,,HitLocation,NewRot);
			}
			else
				spawn(class'RocketSmokePuff',,,Location);	// gotta give the lame no-blood mode something!

			bExploded=true;

 			Destroy();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	//	A blood splash here
	///////////////////////////////////////////////////////////////////////////////
	function BloodHit(vector BloodHitLocation, vector Momentum)
	{
		local vector BloodOffset, dir, HitLocation, HitNormal, checkpoint;

		// Find direction to center
		dir = BloodHitLocation - Location;
		dir = Normal(BloodHitLocation - Location);
		// push it away from the his center
		BloodOffset = 0.2 * CollisionRadius * dir;
		// pull it up some from the bottom and pull it down from the top
		BloodOffset.Z = BloodOffset.Z * 0.75;
		// Blood that squirts in the air
		spawn(class'BloodImpactMaker',self,,BloodHitLocation+BloodOffset, Rotator(dir));
	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
	{
		if(ClassIsChildOf(DamageType, class'BloodMakingDamage'))
		{
			if(class'P2Player'.static.BloodMode())
				BloodHit(HitLocation, Momentum);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Play your movement noise again
	///////////////////////////////////////////////////////////////////////////////
	simulated function Timer()
	{
		PlaySound(CatFlying, SLOT_Misc, 1.0, false, 100.0, 1.0);
		SetTimer(GetSoundDuration(CatFlying), false);
	}

	function BeginState()
	{
		if ( PhysicsVolume.bWaterVolume )
		{
			//bHitWater = True;
			Velocity=0.6*Velocity;
		}
		// Play initial flying sound
		PlaySound(CatStartFlying, SLOT_Misc, 1.0, false, 100.0, 1.0);
		SetTimer(GetSoundDuration(CatStartFlying), false);

		LoopAnim('fall');
	}
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: Spawn Dervish Cat Rocket Pawn 
// Lives for a while to massacre people and then explodes.
///////////////////////////////////////////////////////////////////////////////
function SpawnCrazyCat(vector HitLocation, vector HitNormal)
{
	local AnimalPawn CrazyCat;
	local CatExplosion exp;
	local Rotator NewRot;
	local vector NewLoc;
	
	log(self@"SpawnCrazyCat()");
	
	if(CrazyCatClass == None)
	{
		CrazyCatClass = class<AnimalPawn>(DynamicLoadObject("AWPStuff.CatRocketPawn", class'Class'));
		default.CrazyCatClass = CrazyCatClass;
	}
	
	if(!bExploded)
	{
		if(!bSpawned)
		{
			log(self@"SpawnCrazyCat() -- Spawning");
			CrazyCat = spawn(CrazyCatClass,,, Location, Rotation);
			// Try once more if it didn't make it.
			if (CrazyCat == None)
				CrazyCat = spawn(CrazyCatClass,,, Location + vect(0,0,20), Rotation);
			
			bSpawned=True;
		}
		
		if(CrazyCat != None) 
		{
			// Destroy glitched cats
			if(Skins[0] == None)
				CrazyCat.Destroy();
			
			CrazyCat.Skins[0] = Skins[0];
			if ( CrazyCat.Controller == None && CrazyCat.Health > 0 )
			{
				if ( (CrazyCat.ControllerClass != None))
					CrazyCat.Controller = spawn(CrazyCat.ControllerClass);
				if ( CrazyCat.Controller != None )
				{
					CrazyCat.Controller.Possess(CrazyCat);
					CrazyCat.Controller.GotoState('FallingStartDervishRocket');
				}
			}
		}
		else // Falied to spawn it
		{
			log(self@"SpawnCrazyCat() --  Falied to spawn it!");
			
			if(class'P2Player'.static.BloodMode())
			{
				exp = spawn(class'CatExplosion',,,HitLocation);
				exp.FitToNormal(HitNormal);
				
				NewRot = Rotator(-HitNormal);
				NewRot.Roll=(65536*FRand());
				spawn(class'BloodMachineGunSplat',self,,HitLocation,NewRot);
			}
			else
				spawn(class'RocketSmokePuff',,,Location);	// gotta give the lame no-blood mode something!
		}
		
		bExploded=true;
		Destroy();
	}
}

defaultproperties
{
//	 ExplosionDecal=class'BlastMark'
	 MyDamageType=class'ExplodedDamage'
     speed=1200.000000
     MaxSpeed=1200.000000
     Damage=10.000000
	 DamageMP=30
	 SoundVolume=255
     MomentumTransfer=80000
  //   SpawnSound=Sound'Ignite'
//     ImpactSound=Sound'.GrenadeFloor'
     LifeSpan=30.000000
//     StaticMesh=StaticMesh'jm_heavydude_rockets.boomstick.jm_coalition_rocket'
//	 DrawType=DT_StaticMesh
	 Mesh=SkeletalMesh'Animals.meshCat'
	 Skins[0]=Texture'AnimalSkins.Cat_Orange'
	 DrawType=DT_Mesh
	 DrawScale=1
//     SoundRadius=255
  //   SoundVolume=255
	// SoundPitch=100
     //AmbientSound=Sound'AnimalSounds.Cat.CatScream'
	 CatStartFlying=Sound'AnimalSounds.Cat.CatScream_fire1'
	 CatFlying=Sound'AnimalSounds.Cat.CatScream_loop1'
	 Mass=30
     bBounce=True
     bFixedRotationDir=True
	 Acceleration=(Z=-300)
     BouncingSound=Sound'WeaponSounds.flesh_explode'
}
