//=============================================================================
// KarmaActor.
// Just a handy class to derive off to make physics objects.
//=============================================================================

class KActor extends Actor
	native
	placeable
	hidecategories(Force,LightColor,Lighting,Shadow);

var (Karma)		bool		bKTakeShot;
// RWS Change 01/12/03	Added impact effect code
var() array<sound>		ImpactSounds;
var() float				ImpactVolume;

//var() class<actor>		ImpactEffect;
//var() bool				bOrientImpactEffect;

var() float				ImpactInterval;
var transient float		LastImpactTime;

var() bool				bPawnMovesMe;	// True means a pawn can interact with this and stop it from moving
										// or push the kactor back.

// RWS Change 01/12/03	Added impact effect code

const VEL_MAX	=	1000.0;


// RWS Change 11/24/02
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();
	// Try for stasis first,.. things will wake you up later
	bStasis=true;

	// Load some vague, default sounds
	if(ImpactSounds.Length < 1)
		ImpactSounds.Insert(ImpactSounds.Length, 1);
	if(ImpactSounds[0] == None)
		ImpactSounds[0] = Sound(DynamicLoadObject("MiscSounds.Props.woodhitsground1", class'Sound'));
	if(ImpactSounds.Length < 2)
		ImpactSounds.Insert(ImpactSounds.Length, 2);
	if(ImpactSounds[1] == None)
		ImpactSounds[1] = Sound(DynamicLoadObject("MiscSounds.Props.plastichitsground2", class'Sound'));
}
// RWS Change 11/24/02

// Default behaviour when shot is to apply an impulse and kick the KActor.
function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	if(bKTakeShot)
	{
		KAddImpulse(momentum, hitlocation);
	}
}

// Default behaviour when triggered is to wake up the physics.
function Trigger( actor Other, pawn EventInstigator )
{
	KWake();
}

// RWS Change 01/12/03	Added impact sounds
// 
event KImpact(actor other, vector pos, vector impactVel, vector impactNorm)
{
	local int numSounds, soundNum;

	// If its time for another impact.
	if(Level.TimeSeconds > LastImpactTime + ImpactInterval)
	{
		// If we have some sounds, play a random one.
		numSounds = ImpactSounds.Length;
		if(numSounds > 0)
		{
			soundNum = Rand(numSounds);
			//Log("Play Sound:"$soundNum);
			PlaySound(ImpactSounds[soundNum], , ImpactVolume, , , 0.96 + FRand()*0.08);
		}
/*		
		// If we have an effect class (and its relevant), spawn it.
		if( (ImpactEffect != None) && EffectIsRelevant(pos, false) )
		{
			if(bOrientImpactEffect)
				spawn(ImpactEffect, self, , pos, rotator(impactVel));
			else
				spawn(ImpactEffect, self, , pos);
		}
*/
		LastImpactTime = Level.TimeSeconds;
	}
}
// RWS Change 01/12/03	Added impact sounds

///////////////////////////////////////////////////////////////////////////////
// RWS Change 1/20/03
// Added code to make the kactors not act so stupid when they hit pawns. 
///////////////////////////////////////////////////////////////////////////////
event Bump( Actor Other )
{
	local Pawn hitpawn;
	local vector pv, kv, usev;

	if(bPawnMovesMe)
	{
		hitpawn = Pawn(Other);
		if(hitpawn != None)
		{
			if(VSize(Velocity) < VEL_MAX)
			{
				//log(self$" before vel "$Velocity$" pvel "$hitpawn.Velocity$" p mass "$hitpawn.mass$" my mass "$mass);
				kv = hitpawn.Velocity;
				// If the pawn isn't standing on the kactor.
				if(hitpawn.Base != self)
					kv.z += (VSize(kv)/2);
				kv = (kv*hitpawn.mass)/mass;
				KAddImpulse(kv, (Location - 10*Normal(hitpawn.Velocity)));
			}

			if(hitpawn.Physics == PHYS_WALKING)
			{
				pv = Velocity;
				pv = (pv*mass)/hitpawn.mass;
				hitpawn.Velocity += pv;
				hitpawn.Acceleration = vect(0,0,0);
			}
			//log(self$" after vel "$Velocity$" pvel "$hitpawn.Velocity);
		}
		/*
		hitpawn = Pawn(Other);
		if(hitpawn != None)
		{
			KAddImpulse(-Velocity, Location);
		}
		*/
	}
}


// RWS Change 02/16/03
///////////////////////////////////////////////////////////////////////////////
// Turn the karma back on, it's probably floating or something.
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
{
	if(!bStasis)
	{
		KWake();
		KAddImpulse(Velocity, Location);
	}
}

defaultproperties
{
	// Change by NickP: MP fix
	bReplicateSkin=true
	// End

	bKTakeShot=true
	DrawType=DT_StaticMesh
	//StaticMesh=StaticMesh'MiscPhysicsMeshes.Barrels.Barrel1'
    Physics=PHYS_Karma
	bEdShouldSnap=True
	bStatic=False
	bShadowCast=False
	bCollideActors=True
	bCollideWorld=False
    bProjTarget=True
	bBlockActors=True
	bBlockNonZeroExtentTraces=True
	bBlockZeroExtentTraces=True
	bBlockPlayers=True
	bWorldGeometry=False
	bBlockKarma=True
	//bAcceptsProjectors=True
	// RWS Change 06/28/02
	bAcceptsProjectors=false
	// RWS Change 06/28/02
    CollisionHeight=+000001.000000
	CollisionRadius=+000001.000000

// RWS Change 01/12/03	Added impact effect code
	ImpactInterval = 0.8
	ImpactVolume = 1.0
	ImpactSounds[0]=None
	ImpactSounds[1]=None
    SoundVolume=255
	Mass=5
	bPawnMovesMe=true
}

