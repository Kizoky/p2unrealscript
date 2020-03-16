///////////////////////////////////////////////////////////////////////////////
// Our breakable version of a window that blocks when it's not dead
// but turns off collision when broken.
///////////////////////////////////////////////////////////////////////////////

class Window extends PropBreakable;

var ()float BreakPct;	// Percentage of max speed for an object to break the window


// default Postal2 window sizes
const WINDOW_HEIGHT = 140;
const WINDOW_WIDTH	= 112;
const DAMAGE_VEL_RATIO = 10;
const PAWN_DAMAGE_RATIO = 12;
const PICKUP_DAMAGE_RATIO = 10;
const PROJECTILE_DAMAGE_RATIO = 10;
const KACTOR_DAMAGE_RATIO = 5;
const WINDOW_JUMP_DAMAGE = 10;
const MIN_PARTICLES_MADE = 4;


///////////////////////////////////////////////////////////////////////////////
// Orient the breaking effect and size it
///////////////////////////////////////////////////////////////////////////////
function FitTheEffect(P2Emitter pse, int damage, vector HitLocation, vector HitMomentum)
{
	local float xsize, xradsize, yradsize, zradsize;
	local vector vecrot;
	local float totalarea, startarea;
	local float usedot;
	local float velmag;

	local int newmax;

	vecrot = vector(Rotation);
	//log("-------------------------vecrot "$vecrot$" Rotation "$Rotation);

	// Fit the start location range
	xsize = pse.Emitters[0].StartSizeRange.X.Min;
	xradsize = pse.Emitters[0].StartLocationRange.X.Max;
	yradsize = CollisionRadius - xsize;
	zradsize = CollisionHeight*abs(vecrot.z);

	//log("xsize "$xsize$" xrad "$xradsize$" yrad "$yradsize$" zrad "$zradsize);
	//log(" A "$xradsize*vecrot.x + yradsize*vecrot.y + zradsize$" B "$xradsize*vecrot.y + yradsize*vecrot.x + zradsize$" C "$abs(1.0 - vecrot.z)*CollisionHeight);

	// fit the start location
	pse.Emitters[0].StartLocationRange.X.Max =  xradsize*vecrot.x + yradsize*vecrot.y + zradsize;
	pse.Emitters[0].StartLocationRange.X.Min = -pse.Emitters[0].StartLocationRange.X.Max;
	pse.Emitters[0].StartLocationRange.Y.Max =  xradsize*vecrot.y + yradsize*vecrot.x + zradsize;
	pse.Emitters[0].StartLocationRange.Y.Min = -pse.Emitters[0].StartLocationRange.Y.Max;
	pse.Emitters[0].StartLocationRange.Z.Max =  abs(1.0 - vecrot.z)*CollisionHeight;
	pse.Emitters[0].StartLocationRange.Z.Min = -pse.Emitters[0].StartLocationRange.Z.Max;

	// Fit the number of particles
	// Consider this a good starting point for the number of particles per window size
	newmax = pse.Emitters[0].MaxParticles;
	// calc this by the full radius and height squared (thus the 4 from 2*2)
	totalarea = 4*CollisionRadius*CollisionHeight;
	startarea = WINDOW_HEIGHT*WINDOW_WIDTH;
	newmax = newmax*(totalarea/startarea);
	if(newmax < MIN_PARTICLES_MADE)
		newmax = MIN_PARTICLES_MADE;

	//log("total area "$totalarea);
	//log("start area "$startarea);
	//log("new max "$newmax);

	// Set this for both groups
	SuperSpriteEmitter(pse.Emitters[0]).SetMaxParticles(newmax);
	SuperSpriteEmitter(pse.Emitters[1]).SetMaxParticles(newmax);

	// Set the velocity of the particles to be mostly inline with the attack
	HitMomentum.z=0;
	usedot = vecrot dot HitMomentum;
	//log("usedot "$usedot);
	// Flip vector we'll use for velocity
	if(usedot < 0)
		vecrot = -vecrot;

	// Use this as your speed from the emitter, but also throw in some
	// of the damage.
	velmag = pse.Emitters[0].StartVelocityRange.X.Max + damage*DAMAGE_VEL_RATIO;
	pse.Emitters[0].StartVelocityRange.X.Max=velmag*vecrot.x;
	pse.Emitters[0].StartVelocityRange.X.Min=-pse.Emitters[0].StartVelocityRange.X.Max/8;
	pse.Emitters[0].StartVelocityRange.Y.Max=velmag*vecrot.y;
	pse.Emitters[0].StartVelocityRange.Y.Min=-pse.Emitters[0].StartVelocityRange.Y.Max/8;
}

///////////////////////////////////////////////////////////////////////////////
// Something hit this
///////////////////////////////////////////////////////////////////////////////
function Bump( actor Other )
{
	local FPSPawn pawnbumper;
	local Pickup pickbumper;
	local P2PowerupPickup p2pickbumper;
	local Projectile projbumper;
	local kactor kbumper;
	local int damage;
	local float usedot;

	pawnbumper = FPSPawn(Other);
	// Pawn has hit the window
	if(pawnbumper != None)
	{
		// Check if the pawn has pushed through the window and hurt himself or not
		// or if he's dead, always make him break it.
		usedot = abs(vector(Rotation) dot Normal(pawnbumper.Velocity));

		if(usedot*VSize(pawnbumper.Velocity) > pawnbumper.GroundSpeed*BreakPct
			|| pawnbumper.Health <= 0)
		{
			damage = (VSize(pawnbumper.Velocity)/PAWN_DAMAGE_RATIO) + 1;
			TakeDamage(damage, pawnbumper, Location, pawnbumper.Velocity, class'KickingDamage');

			// if the damage effected the window
			if(IsInState('Broken')
				&& pawnbumper.Health > 0)
			{
				// Slow jumping pawn down a little as he jumps through
				pawnbumper.StopAcc();

				// Deliver a small amount of damage to him
				pawnbumper.TakeDamage(WINDOW_JUMP_DAMAGE, None, pawnbumper.Location, 
									-(pawnbumper.Velocity/4), class'WindowJumpThroughDamage');
				return;
			}
		}
	}
	else
	{
		pickbumper = Pickup(Other);
		// pickup breaks the window
		if(pickbumper != None)
		{
			usedot = abs(vector(Rotation) dot Normal(pickbumper.Velocity));
			p2pickbumper = P2PowerupPickup(Other);
			if((p2pickbumper != None
					&& p2pickbumper.bBreaksWindows)
				|| p2pickbumper == None)
			{
				if(usedot*VSize(pickbumper.Velocity) > class'P2MoCapPawn'.default.GroundSpeed*BreakPct)
				{
					damage = VSize(pickbumper.Velocity)/PICKUP_DAMAGE_RATIO;
					TakeDamage(damage, None, Location, -(pickbumper.Velocity/4), class'KickingDamage');
					return;
				}
			}
			// bounce the pickup away
			pickbumper.Velocity = (VRand()*VSize(pickbumper.Velocity)/4) - (pickbumper.Velocity/2);			
		}
		// projectiles breaks the window
		else
		{
			// All projectiles break windows (some used to not--no reason for that now)
			projbumper = Projectile(Other);
			if(projbumper != None)
			{
				damage = (VSize(projbumper.Velocity)/PROJECTILE_DAMAGE_RATIO) + 1;
				TakeDamage(damage, None, Location, -(projbumper.Velocity/4), class'KickingDamage');
				return;
			}
			// kactors break windows
			else
			{
				kbumper = KActor(Other);
				if(kbumper != None)
				{
					damage = (VSize(kbumper.Velocity)/PROJECTILE_DAMAGE_RATIO) + 1;
					TakeDamage(damage, None, Location, -(kbumper.Velocity/4), class'KickingDamage');
					return;
				}
				else if (Other.IsA('PeoplePart'))
				{
					damage = (VSize(Other.Velocity)/PROJECTILE_DAMAGE_RATIO) + 1;
					TakeDamage(damage, None, Location, -(Other.Velocity/4), class'KickingDamage');
					return;
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Specifically, always block some things from breaking a window
///////////////////////////////////////////////////////////////////////////////
function bool AcceptThisDamage(class<DamageType> damageType)
{
	// If the filter let this through, check to block some specific ones
	if(Super.AcceptThisDamage(damageType))
	{
		if(ClassIsChildOf(damageType, class'BurnedDamage')
			|| ClassIsChildOf(damageType, class'OnFireDamage')
			|| ClassIsChildOf(damageType, class'ElectricalDamage')
			|| ClassIsChildOf(damageType, class'AnthDamage'))
			return false;
		else
			return true;
	}
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Something hit this
///////////////////////////////////////////////////////////////////////////////
function Touch( actor Other )
{
	Bump(Other);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Broken
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Broken
{
	ignores TakeDamage;

	///////////////////////////////////////////////////////////////////////////////
	// You've just been freshly broken, generate effects
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		Super.BeginState();
		// turn off the collision now on the window
		SetCollision(false, false, false);
	}
}

defaultproperties
{
	BreakEffectClass=Class'ShatterGlass'
	BreakingSound=Sound'MiscSounds.Glass.glassbreak'
	CollisionRadius=100
	CollisionHeight=100
	DamageFilter=class'BurnedDamage'
	bBlockFilter=true
	bBlockActors=true
	BreakPct=0.70
	DangerMarker=class'PropBreakMarker'
	bStasis=true
	SoundRadius=255
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'STV_Suburbs.windose.window-med-shiney-burban'
}

