///////////////////////////////////////////////////////////////////////////////
// Baseclass for all fluid
///////////////////////////////////////////////////////////////////////////////
class Fluid extends P2Emitter
	native;

enum FluidTypeEnum
{
	// update the numbers in comments!
	FLUID_TYPE_None,		//0
	FLUID_TYPE_Gas,			//1
	FLUID_TYPE_Urine,		//2
	FLUID_TYPE_Blood,		//3
	FLUID_TYPE_Puke,		//4
	FLUID_TYPE_BloodyPuke,	//5
	FLUID_TYPE_Gonorrhea,	//6
	FLUID_TYPE_BloodyUrine,	//7
	FLUID_TYPE_Napalm,		//8
};

// Treat the CollisionRadius as a maximum, use this as the 'real' collision radius
var float UseColRadius;
var Fluid Prev;
var Fluid Next;
var FluidTypeEnum MyType;
var bool bOnFire;
var bool bBeingLit;
var bool bCanBeDamaged;
var bool bNeedsDirectHit;
var float Health;
var float Quantity;
var bool bInfiniteQuantity;
var bool bStoppedFlow;	// this toggles with the flow
var bool bStoppedOnce;	// once the flow is stopped, this is set and never toggled
var Actor MyOwner;			// Person or thing that originally made this fluid
var class<FireEmitter> FireClass;		// type of fire we burn into

const SHOW_LINES = 1;
const MIN_HEALTH = 100;
const DEFAULT_STOP_FLOW_TIME=0.2;
const MAX_PUDDLE_SIZE = 600;
const PUDDLE_FUZZ = 30;
const MAX_TO_LIGHT = 5;

///////////////////////////////////////////////////////////////////////////////
// Set my owner
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{	
	Super.PostBeginPlay();
	MyOwner = Owner;
	if(Owner != None)
		Instigator = Owner.Instigator;
	//log(self$" post begin play ");	
}

///////////////////////////////////////////////////////////////////////////////
// Set my owner
///////////////////////////////////////////////////////////////////////////////
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	MyOwner = Owner;
//	log(self$" net my owner "$MyOwner);
	if(Owner != None)
		Instigator = Owner.Instigator;
}

///////////////////////////////////////////////////////////////////////////////
// Reset actor to initial state - used when restarting level without reloading.
///////////////////////////////////////////////////////////////////////////////
simulated function Reset()
{
	Destroy();
	Prev = None;
	Next = None;
	MyOwner = None;
}

///////////////////////////////////////////////////////////////////////////////
// Set whether or not you can be damaged or not
///////////////////////////////////////////////////////////////////////////////
function SetCanBeDamaged(bool bNewCan)
{
	// STUB--don't allow most liquids to change this (make them always 
	// undamageable) unless they specifically override this
}

///////////////////////////////////////////////////////////////////////////////
function FitToNormal(vector HNormal)
{
	// STUB for child actor
}

///////////////////////////////////////////////////////////////////////////////
// Set the colors of the fluid by changing particle colors
///////////////////////////////////////////////////////////////////////////////
function SetFluidColors(FluidTypeEnum newtype)
{
	local int i, j;
	local vector Tinting;
	local bool bDoTint;

	// Handle special coloring
	switch(newtype)
	{
		case FLUID_TYPE_BloodyUrine:
			Tinting.x = 200;
			Tinting.y = 0;
			Tinting.z = 0;
			bDoTint=true;
			break;
		case FLUID_TYPE_BloodyPuke:
			Tinting.x = 200;
			Tinting.y = 0;
			Tinting.z = 0;
			bDoTint=true;
			break;
		case FLUID_TYPE_Gonorrhea:
			Tinting.x = 105+FRand()*70;
			Tinting.y = 255;
			Tinting.z = 0;
			bDoTint=true;
			break;
	}

	if(bDoTint)
	{
		for(i=0; i<Emitters.Length; i++)
		{
			Emitters[i].UseColorScale=True;

			for(j=0; j<Emitters[i].ColorScale.Length; j++)
			{
				Emitters[i].ColorScale[j].Color.R=Tinting.x;
				Emitters[i].ColorScale[j].Color.G=Tinting.y;
				Emitters[i].ColorScale[j].Color.B=Tinting.z;
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Mainly used to set puke and others to special versions like blood puke.
///////////////////////////////////////////////////////////////////////////////
function SetFluidType(FluidTypeEnum newtype)
{
	SetFluidColors(newtype);

	// set it
	MyType = newtype;
}

///////////////////////////////////////////////////////////////////////////////
// This was originally used, but later rejected for ease of use, since we didn't
// have enough fire objects for it to really matter. The idea is, the fire itself
// has a complex collision outline, where it checks hits with other things with,
// then if it hits fluid, it would call this function for the fluid types to
// determine if the fire really hurt them. The fluidtrail is the most complex.
// And since most things were just the collision radius (but I had to also deal
// with the pawns sometimes which *couldn't* extend this function) I just dealt
// with them on a case by case basis inside the fire code, instead of the start
// being in the fire code and the other half being in the fluid code. 
// So, NO, this function isn't used, but it's here to explain why I chose not
// to go that route.
//function bool CheckDirectCollision(float UseRadius, vector HitLocation)
//{
	// STUB for child actor
//	return true;
//}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function AddQuantity(float MoreQ, vector InputPoint, Fluid InputFluid)
{
	Quantity+=MoreQ;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ToggleFlow(float TimeToStop, bool bIsOn)
{
	local bool bOldStopped;
	
	//log(self$" toggling flow to"$bIsOn$" my next is "$Next$" and my prev is "$Prev);
	bOldStopped = bStoppedFlow;

	bStoppedFlow=!bIsOn;

	// record if it's ever stopped at all
	if(bStoppedFlow)
		bStoppedOnce = true;

	if(Next != None
		&& bOldStopped != bStoppedFlow)
	{
		//DEFAULT_STOP_FLOW_TIME
		Next.ToggleFlow(TimeToStop, bIsOn);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SlowlyDestroy()
{
	local int i;

	AutoDestroy=True;
	for(i=0; i<Emitters.length; i++)
	{
		Emitters[i].RespawnDeadParticles=False;
		Emitters[i].ParticlesPerSecond=0;
	}
/*
	// unhook connections
	if(Prev != None)
	{
		if(Prev.Next == self)
			Prev.Next = None;
		Prev = None;
	}
	if(Next != None)
	{
		if(Next.Prev == self)
			Next.Prev = None;
		Next = None;
	}
	*/
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	//log(self$" destroyed "$bDeleteMe$" next "$Next$" prev "$Prev);
	ToggleFlow(0, false);
	// make sure next and prev are going to get nulled correctly
	if(Next != None)
	{
		if(Next.Prev == self)
			Next.Prev = None;
		Next = None;
	}
	if(Prev != None)
	{
		if(Prev.Next == self)
			Prev.Next = None;
		Prev = None;
	}

	MyOwner=None;

	Super.Destroyed();
}
/*
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Timer()
{
	if(Next != None)
	{
		Next.ToggleFlow(DEFAULT_STOP_FLOW_TIME, !bStoppedFlow);
	}
}
*/

///////////////////////////////////////////////////////////////////////////////
// When a lighting entity first hits a fluid that can be lit on fire, but isn't
// currently on fire, or bBeingLit, it scrolls through a certain number of 
// it's connectly fluids and marks them as being lit. This is to make sure the
// heat damage from the fire nearby doesn't set these on fire, too early.
///////////////////////////////////////////////////////////////////////////////
function MarkBeingLit()
{
	local Fluid NextOne, PrevOne;
	local int NumberToLight, i;

	NumberToLight = FRand()*MAX_TO_LIGHT + 1;

	// Go forward, down your next's marking them
	NextOne = Next;
	i=0;
	while(NextOne != None && i < NumberToLight)
	{
		i++;
		NextOne.bBeingLit=true;
		NextOne = NextOne.Next;
	}
	// Go backwards, down your prev's marking them
	PrevOne = Prev;
	i=0;
	while(PrevOne != None && i < NumberToLight)
	{
		i++;
		PrevOne.bBeingLit=true;
		PrevOne = PrevOne.Prev;
	}
	// set me too!
	bBeingLit=true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetAblaze(vector StartPos, bool NewStart)
{
	// STUB for child actor
	log("i got called.. gasoline setablaze: myself :"$self);
	bOnFire=true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool CheckSmallFireHit( int Damage, float hitrad, Vector hitlocation)
{
	local bool bhithere;

	bhithere = false;
//	log("small fire check ");
	if(!bOnFire
		&& !bBeingLit
		&& bCanBeDamaged)
	{
		//bhithere = CheckDirectCollision(hitrad, HitLocation);
		bhithere=true;

		// Ensures that the small fire only can damage things
		// when it's directly touching them. And only after they've
		// been damaged enough will they then set on fire.
		//if(bhithere)
		//{



//			Health -= Damage;
			// If it's been burned enough, or it's directly touching fire, then set it on
			// fire.
//			log("small fire hitting this "$self);
			//log("gas health "$Health);
//			if(Health < MIN_HEALTH)
//			{
				//log("SETTING THIS ON FIRE "$self);
				//log("hitlocation check small fire "$hitlocation);
				//log("hitrad "$hitrad);
				//log("here is the start "$self);
				//ToNextGas(self);
				//ToPrevGas(self);
				SetAblaze(hitlocation, true);
				// go through all links
//			}
		//}
	}
	return bhithere;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local bool bhithere;
	local bool bExplDamage;
	
	//log(self@"taking damage"@Damage@InstigatedBy@HitLocation@Momentum@DamageType,'Debug');

	bExplDamage = ClassIsChildOf(damageType, class'ExplodedDamage');

	if(ClassIsChildOf(damageType, class'BurnedDamage')
		|| bExplDamage
		|| ClassIsChildOf(damageType, class'OnFireDamage'))
	{
		if(!bOnFire
			&& !bBeingLit
			&& bCanBeDamaged)
		{
			//bhithere = CheckDirectCollision(UseColRadius, HitLocation);

			//log("damage from this "$Damage);
			// Make the fire heat it up
			if(!bNeedsDirectHit)
				Health -= Damage;
			//log("current health "$Health$" for "$self);

			// If it's been burned enough, or it's directly touching fire, then set it on
			// fire.
			if(Health < MIN_HEALTH
				|| bExplDamage
				|| ClassIsChildOf(damageType, class'OnFireDamage'))
			{
//				log("hitlocation "$hitlocation);
//				log("TOOK DAMAGE, setting on fire");
				//log(self@"IGNITED! By:"@Damage@InstigatedBy@HitLocation@Momentum@DamageType,'Debug');
				SetAblaze(hitlocation, true);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event RenderOverlays( canvas Canvas )
{
/*
	//local vector endline;
	local color tempcolor;

	if(SHOW_LINES==1)
	{
		// show collision radius
		//endline = Location + vect(200, 0, 200);
		tempcolor.R=255;
		Canvas.DrawColor = tempcolor;
		Canvas.Draw3Circle(Location, UseColRadius, 0);
		//Location, endline, 0);
		tempcolor.G=255;
		tempcolor.R=0;
//		Canvas.DrawColor = tempcolor;
//		Canvas.Draw3Line(SuperSpriteEmitter(Emitters[0]).LineStart, 
//						 Location, 0);
		tempcolor.G=0;
		tempcolor.B=255;
		Canvas.DrawColor = tempcolor;
		Canvas.Draw3Line(Location, 
						 SuperSpriteEmitter(Emitters[0]).LineEnd, 0);
	}
		*/
}

///////////////////////////////////////////////////////////////////////////////
// Native-ized a lot of these slow functions. - Rick
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//	This function finds the closest distance between the the pointval and
//	the line made by points startpoint and endpoint. Use the out u value
//	to find if the point is within the line segment.
//	It is SLOW. So be careful with it.
//	d2line := proc(p,a,v)
//              local lc,lv;
//              lv := sqrt(innerprod(v,v));
//              lc := crossprod(p-a,v);
//              lc := sqrt(innerprod(lc,lc));
//              lc/lv
//          end
///////////////////////////////////////////////////////////////////////////////
native function bool PointToLineDist(vector startpoint, vector endpoint, vector pointval,
							   out float perpdist, out float u);
/*
{
	local vector unitdir;
	local vector lc;
	local vector ps, es;
	local float dist;

	es = endpoint - startpoint;
	unitdir = Normal(es);
	if(!(unitdir.x == 0
		&& unitdir.y == 0
		&& unitdir.z == 0))
	{
//		log("unitdir "$unitdir);
		// We don't need to find this distance or divide by it because it is
		// always going to be 1, since we normalized it. (it doesn't keep any
		// direction information here, so don't worry).
		//dist1 = VSize(unitdir);
		//log("dist1 "$dist1);
		ps = (pointval - startpoint);
		lc = (-ps) Cross unitdir;
//		log("lc "$lc);
		perpdist = VSize(lc);
//		log("perpdist "$perpdist);

		u = ps.x*es.x + ps.y*es.y + ps.z*es.z;//(pointval.x - startpoint.x)*(endpoint.x - startpoint.x) + 
			 //(pointval.y - startpoint.y)*(endpoint.y - startpoint.y) + 
			 //(pointval.z - startpoint.z)*(endpoint.z - startpoint.z);
		dist = VSize(es);
		u = u/(dist*dist);
//		log("u : "$u);
		return true;
	}
	else
		return false;
}
*/
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
native function bool VectorsInFuzz(vector v1, vector v2, float fuzz);
/*
{
	return(v1.x > v2.x-fuzz && v1.x < v2.x+fuzz
		&& v1.y > v2.y-fuzz && v1.y < v2.y+fuzz
		&& v1.z > v2.z-fuzz && v1.z < v2.z+fuzz);

}
*/

///////////////////////////////////////////////////////////////////////////////
// See if this actor's cylinder is hitting this line
///////////////////////////////////////////////////////////////////////////////
/*
native function bool ThickLineCylinderCollide(vector startpt, vector endpt, 
									   float lineradius, float lineheight, 
									   vector ActorLoc, float ActorRad, float ActorHeight);
{
	//local float rad;
	local vector startxy, endxy, Locxy;
	local vector v1, v2, center;
	local float usedist, useang;
	local float hyp;

	//rad = Other.CollisionRadius;

	// Store only the x and y for most tests.
	startxy.x=startpt.x;
	startxy.y=startpt.y;
	endxy.x=endpt.x;
	endxy.y=endpt.y;
	Locxy.x = ActorLoc.x;
	Locxy.y = ActorLoc.y;

	v1 = Locxy - startxy;
	v2 = startxy - endxy;

	// check end points
	if(VSize(v1) <= ActorRad + lineradius
		&& abs(startpt.z - ActorLoc.z) < ActorHeight + lineheight)
		return true;
	if(VSize(endxy - Locxy) <= ActorRad + lineradius
		&& abs(endpt.z - ActorLoc.z) < ActorHeight + lineheight)
		return true;
	
	// Did hit the end points, so check the middle
	// Going with angle between two lines, gives us angle. Take hypotenuse (v1) to
	// cylinder from start, and mult by sine of angle to get distance.
	hyp = Vsize(v1);
	if(hyp <= 0)
		return false;

	useang = atan(v2.y/v2.x) - atan(v1.y/v1.x);
	usedist = abs(hyp*sin(useang));
	center = (startxy + endxy)/2;

	// if within the distance to the line and within the radius of the center to the ends
	if(usedist <= ActorRad + lineradius
		&& VSize(center-Locxy) <= VSize(v2)/2)
		return true;

	return false;
}
*/

/*
//	This function finds the closest distance between the the pointval and
//	the line made by points startpoint and endpoint. Use the out u value
//	to find if the point is within the line segment.
//	It is SLOW. So be careful with it.
//	d2line := proc(p,a,v)
//              local lc,lv;
//              lv := sqrt(innerprod(v,v));
//              lc := crossprod(p-a,v);
//              lc := sqrt(innerprod(lc,lc));
//              lc/lv
//          end
function bool PointToLineDist(vector startpoint, vector endpoint, vector pointval,
							   out float perpdist, out float u)
{
	local vector unitdir;
	local vector lc;
	local vector ps, es;
	local float dist;

	es = endpoint - startpoint;
	unitdir = Normal(es);
	if(!(unitdir.x == 0
		&& unitdir.y == 0
		&& unitdir.z == 0))
	{
//		log("unitdir "$unitdir);
		// We don't need to find this distance or divide by it because it is
		// always going to be 1, since we normalized it. (it doesn't keep any
		// direction information here, so don't worry).
		//dist1 = VSize(unitdir);
		//log("dist1 "$dist1);
		ps = (pointval - startpoint);
		lc = (-ps) Cross unitdir;
//		log("lc "$lc);
		perpdist = VSize(lc);
//		log("perpdist "$perpdist);

		u = ps.x*es.x + ps.y*es.y + ps.z*es.z;//(pointval.x - startpoint.x)*(endpoint.x - startpoint.x) + 
			 //(pointval.y - startpoint.y)*(endpoint.y - startpoint.y) + 
			 //(pointval.z - startpoint.z)*(endpoint.z - startpoint.z);
		dist = VSize(es);
		u = u/(dist*dist);
//		log("u : "$u);
		return true;
	}
	else
		return false;
}
*/

defaultproperties
{
	CollisionRadius=800.000000
	CollisionHeight=800.000000
	UseColRadius=100
	bCanBeDamaged=false
	Health=300
	Quantity=100
	bInfiniteQuantity=true
	bStoppedFlow=false
	FireClass=class'FireEmitter'
	bReplicateMovement=true

	// Kamek edit 2/5
	// Explanation: All fluids appear to use their own collision mechanics based in UnrealScript
	// with traces and such. The engine-level collision hash isn't used at all, just Trace.
	// However, the engine collision remained on, and since fluids have such a large "collision
	// radius" they were causing massive engine slowdown around Karma objects.
	// Three-step solution is as follows.
	// step 1: turn off engine-level collision for all fluids.
	// step 2: ?
	// step 3: profit!
	bBlockActors=false
	bBlockKarma=false
	bProjTarget=false
	bBlockZeroExtentTraces=false
	bBlockNonZeroExtentTraces=false
	bCollideActors=false
	bCollideWorld=false
}