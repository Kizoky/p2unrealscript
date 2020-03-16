//=============================================================================
// A moving trail of deadly gas
//=============================================================================
class AnthTrailPoint extends Anth;

var	float RadVel;
var	vector MainAcc;
var	vector Velocity;
var vector RightDir;
var	vector HitStart, HitEnd;
var vector colpt1, colpt2;
var	float CollisionTime;
var vector VelocityMax;
var AnthTrailPoint Next;

const EXPANDING_TIME = 10;
const VEL_MAG_COL_MULT=5;
const COLLISION_MOVEMENT_FREQ_TIME = 2.0;
const NEXT_TRAIL_COLLISION_TIME = 0.1;
const HURTING_TIME = 100;
const PERFECT_TRAIL_DISTANCE=350;
const PUSH_MAG = 4;
const PULL_MAG = 4;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	RadVel = (CollisionRadius - DamageDistMag)/EXPANDING_TIME;
	VelocityMax = vect(50, 50, 50);
}

function FindRightDir(vector HNormal, vector ForwardDir)
{
	// Find the cross between the direction of travel and the normal for the 
	// surface. This new vector will be used to move the collision line around for
	// greater hit coverage.
//	ForwardDir = SuperSpriteEmitter(Emitters[0]).LineStart - SuperSpriteEmitter(Emitters[0]).LineEnd;
//	ForwardDir = Normal(ForwardDir);
	RightDir = HNormal Cross ForwardDir;
}

function SetLine(vector startline, vector endline)
{
	local int i;
	for(i=0; i<Emitters.length; i++)
	{
		SuperSpriteEmitter(Emitters[i]).LocationShapeExtend=PTLSE_Line;
		SuperSpriteEmitter(Emitters[i]).LineStart = startline;
		SuperSpriteEmitter(Emitters[i]).LineEnd = endline;
	}
}

function SetLineEnd(vector endline)
{
	local int i;
	for(i=0; i<Emitters.length; i++)
		SuperSpriteEmitter(Emitters[i]).LineEnd = endline;
}

function HurtLine( float DamageAmount, class<DamageType> DamageType, float Momentum, 
				vector StartLoc, vector EndLoc )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
	local vector OutHitNorm, OutHitLoc;
	
	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach TraceActors( class 'Actor', Victims, OutHitLoc, OutHitNorm, EndLoc, StartLoc )
	{
		if( Victims != self )
		{
			dir = Victims.Location - OutHitLoc;
			dist = FMax(1,VSize(dir));
			dir = dir/dist; 
			//damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			damageScale=1;
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator, 
				OutHitLoc,//Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
		} 
	}
	bHurtEntry = false;
}

function CheckToHitActors(float DeltaTime)
{
	local int offset;

	// 0 here for momentumtransfer (second from end)
	// Make the line segment be from the start to the end of this emitter
	HitStart = Location;
	//HitStart.z+=DamageDistMag;
	if(Next != None)
	{
		HitEnd = Next.Location;
		//HitEnd.z+=DamageDistMag;
		// Flipflop the vector around the original orientation, so that
		// you cover a wider area, but with a single collision line
		offset = Rand(2*DamageDistMag) - DamageDistMag;
		HitStart = HitStart + offset*RightDir;
		HitEnd = HitEnd + offset*RightDir;
		HurtLine(DeltaTime*Damage, MyDamageType, 0, 
				HitStart, HitEnd );
	}
	else HitEnd = Location;
}

function CapVel(out float vx, float vmax)
{
	if(vx > vmax)
		vx = vmax;
	else if(vx < -vmax)
		vx = -vmax;
}

function CalcVel(float DeltaTime)
{
	Velocity+=MainAcc*DeltaTime;
	// cap velocity
	CapVel(Velocity.x, VelocityMax.x);
	CapVel(Velocity.y, VelocityMax.y);
	CapVel(Velocity.z, VelocityMax.z);
}

function MoveCenters(float DeltaTime)
{
	local int i;
	// Move the main emitter
	SuperSpriteEmitter(Emitters[0]).LineStart += Velocity*DeltaTime;
	// have all the other emitters catch up
	for(i=1; i<Emitters.length; i++)
		SuperSpriteEmitter(Emitters[i]).LineStart = SuperSpriteEmitter(Emitters[0]).LineStart;
	// Location and LineStart match all the time.
	SetLocation(SuperSpriteEmitter(Emitters[0]).LineStart);
	CollisionLocation = Location;

	// Set the end of the emitter based on the next trail's position (doesn't matter if it's
	// a little offset by a frame)
	if(Next != None)
	{
		for(i=0; i<Emitters.length; i++)
		{
			SuperSpriteEmitter(Emitters[i]).LineEnd = Next.Location;
		}
	}
}
/*
auto state Expanding
{
	function Timer()
	{
		GoToState('Hurting');
	}
	
	function Tick(float DeltaTime)
	{
		// increase the radius
		DamageDistMag+=RadVel*DeltaTime;
		// increase the area to emit little particles
		*/
/*		Emitters[1].StartLocationRange.X.Max += RadVel*DeltaTime;
		Emitters[1].StartLocationRange.X.Min = -Emitters[1].StartLocationRange.X.Max;
		Emitters[1].StartLocationRange.Y.Max =  Emitters[1].StartLocationRange.X.Max;
		Emitters[1].StartLocationRange.Y.Min =  Emitters[1].StartLocationRange.X.Min;
		Emitters[1].StartLocationRange.Z.Max =  Emitters[1].StartLocationRange.X.Max;
		Emitters[1].StartLocationRange.Z.Min =  Emitters[1].StartLocationRange.X.Min;
		Emitters[2].StartLocationRange = Emitters[1].StartLocationRange;
		Emitters[0].StartLocationRange.X.Max = Emitters[1].StartLocationRange.X.Max/2;
		Emitters[0].StartLocationRange.X.Min = -Emitters[0].StartLocationRange.X.Max;
		Emitters[0].StartLocationRange.Y.Max =  Emitters[0].StartLocationRange.X.Max;
		Emitters[0].StartLocationRange.Y.Min =  Emitters[0].StartLocationRange.X.Min;
		Emitters[0].StartLocationRange.Z.Max =  Emitters[0].StartLocationRange.X.Max;
		Emitters[0].StartLocationRange.Z.Min =  Emitters[0].StartLocationRange.X.Min;
*/
/*		// deal damage
		CheckToHitActors(DeltaTime);
		// move center emitter to match particles
		MoveCenter(DeltaTime);
	}

	function BeginState()
	{
		SetTimer(EXPANDING_TIME, false);
	}
}

*/
auto state Hurting
{
	function Tick(float DeltaTime)
	{
		CheckToHitActors(DeltaTime);
		// move center emitter to match particles
		CalcVel(DeltaTime);
		MoveCenters(DeltaTime);
	}

//	function BeginState()
//	{
		// set up collision movement timer
//		SetTimer(COLLISION_MOVEMENT_FREQ_TIME, true);
//	}
}

state WaitAndFade
{
	ignores Timer;

	// Don't hurt stuff here, in this state
	function BeginState()
	{
		local int i;

		AutoDestroy=true;
		for(i=0; i<Emitters.length; i++)
		{
			Emitters[i].ParticlesPerSecond=0;
			Emitters[i].RespawnDeadParticles=false;
			Emitters[i].AutoDestroy=true;
		}
	}
}

function ApplyWindEffects(vector NewAcc, vector OldAcc)
{
	local vector newhit, newnormal;
	local float vdist;
	local int i;

	// Scale accelerations down so we don't get too quickly
	// swept away by wind.
	NewAcc/=32;
	OldAcc/=32;
	// Get moved by the wind (a fractional amount though)
	for(i=0; i<2; i++)
	{
		MainAcc -= OldAcc;
		MainAcc += NewAcc;
	}
	Super.ApplyWindEffects(NewAcc, OldAcc);
}

// Perform collision operations
function Timer()
{
	local vector newhit, newnormal;
	local float dist;
	local vector NewAcc, OldAcc, checkv;
	local bool bhit;
	
	//log("collision called "$self);
	OldAcc=vect(0, 0, 0);

	colpt1 = Location;
	colpt2 = VEL_MAG_COL_MULT*Velocity + colpt1;
		
	if(Trace(newhit, newnormal, colpt2, colpt1, false) != None)
	{
		Velocity = (Velocity - 2 * newnormal * (Velocity Dot newnormal))/4;
		//NewAcc = Velocity;
//		NewAcc += (Velocity - 2 * newnormal * (Velocity Dot newnormal))/8;
//		Velocity/=2;
		//MainAcc += NewAcc;
		//Super.ApplyWindEffects(NewAcc, OldAcc);
		//log("new acc from hit: "$NewAcc);
	}

	if(Next != None)
	{
		// If there was not immediate hit, then try to equalize their distance
		// by pulling and pushing the points based on distance between them
		// Do this by reaching forward to the Next trail and finding the distance
		// between them... DON'T use the LineEnd point in this trail. Use the Next trail location
		checkv = Next.Location - Location;
		dist = VSize(checkv);
		if(dist < PERFECT_TRAIL_DISTANCE)
		{
			checkv = PULL_MAG*Normal(checkv);
			// Push them apart gently since they're too close
			//log("too close so push apart"$dist);
			//log("acc "$checkv);
			MainAcc -= checkv;
			Next.MainAcc += checkv;
		}
		else
		{
			checkv = PUSH_MAG*Normal(checkv);
			// Pull them together gently since they're too far away
			//log("too far so pull together"$dist);
			//log("acc "$checkv);
			MainAcc += checkv;
			Next.MainAcc -= checkv;
		}

		// Instead of checking the collision on all points in the trail, put them slightly
		// out of sync so as to don't bog the system.
		Next.SetTimer(NEXT_TRAIL_COLLISION_TIME, false);
	}
	// keep approx time of how long you've been doing this
	CollisionTime += COLLISION_MOVEMENT_FREQ_TIME;
	if(CollisionTime > HURTING_TIME)
		GotoState('WaitAndFade');
}

simulated event RenderOverlays( canvas Canvas )
{
/*
	local color tempcolor;

	if(SHOW_LINES == 1)
	{
		tempcolor.B=255;
		Canvas.DrawColor = tempcolor;
		Canvas.Draw3Line(HitStart, HitEnd, 0);
		tempcolor.R=255;
		Canvas.DrawColor = tempcolor;
		Canvas.Draw3Line(colpt1, colpt2, 0);
		Canvas.Draw3Line(SuperSpriteEmitter(Emitters[0]).LineStart, 
						SuperSpriteEmitter(Emitters[0]).LineEnd, 0);
//		}
		Canvas.Draw3Circle(Location, DamageDistMag, 0);
	}
		*/
}

defaultproperties
{
	LifeSpan=90.000000
	CollisionRadius=300
	CollisionHeight=300
}